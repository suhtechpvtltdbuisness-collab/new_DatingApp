import 'package:dio/dio.dart';
import 'package:dating_app/models/api_models.dart';
import 'package:dating_app/utils/constants.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';

class ApiClient {
  late Dio _dio;
  late Logger _logger;
  late String _accessToken = '';
  String _refreshToken = '';
  bool _isRefreshing = false;

  /// Set by [AuthService] at startup. Given the current refresh token,
  /// should call the refresh-token endpoint and return the new access
  /// token, or null if the refresh failed (expired/invalid session).
  Future<String?> Function(String refreshToken)? onRefreshToken;

  /// Called when the session can no longer be refreshed — the app should
  /// clear local auth state and route the user back to sign in.
  void Function()? onSessionExpired;

  // Singleton pattern
  static final ApiClient _instance = ApiClient._internal();

  factory ApiClient() {
    return _instance;
  }

  ApiClient._internal() {
    _logger = Logger();
    _initializeDio();
  }

  void _initializeDio() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: AppConstants.apiTimeout,
        receiveTimeout: AppConstants.apiTimeout,
        sendTimeout: AppConstants.apiTimeout,
        contentType: Headers.jsonContentType,
        responseType: ResponseType.json,
      ),
    );

    // Add interceptors
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: _onRequest,
        onResponse: _onResponse,
        onError: _onError,
      ),
    );

    // Add retry interceptor
    _dio.interceptors.add(
      RetryInterceptor(
        _dio,
        maxRetries: AppConstants.maxRetries,
      ),
    );
  }

  // Request interceptor
  Future<void> _onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    _logger.i('→ Request: ${options.method} ${options.path}');
    _logger.d('Headers: ${options.headers}');
    _logger.d('Data: ${options.data}');

    // Add authentication token if available
    if (_accessToken.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $_accessToken';
    }

    // Default content-type is JSON. FormData must set its own multipart
    // boundary or the browser hangs and the upload times out.
    if (options.data is FormData) {
      options.headers.remove(Headers.contentTypeHeader);
      options.contentType = null;
    }

    handler.next(options);
  }

  // Response interceptor
  Future<void> _onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) async {
    _logger.i('← Response: ${response.statusCode} ${response.requestOptions.path}');
    _logger.d('Data: ${response.data}');

    handler.next(response);
  }

  // Error interceptor
  Future<void> _onError(
    DioError dioError,
    ErrorInterceptorHandler handler,
  ) async {
    _logger.e(
      'Error: ${dioError.type} - ${dioError.message}',
      error: dioError.error,
      stackTrace: dioError.stackTrace,
    );

    // Handle specific error cases
    if (dioError.response?.statusCode == 401) {
      final requestOptions = dioError.requestOptions;
      final alreadyRetried = requestOptions.extra['retriedAfterRefresh'] == true;

      if (!alreadyRetried && _refreshToken.isNotEmpty && onRefreshToken != null) {
        _logger.i('Access token expired — attempting refresh...');

        try {
          final newAccessToken = await _refreshAccessTokenOnce();

          if (newAccessToken != null && newAccessToken.isNotEmpty) {
            // Retry the original request once with the fresh token.
            requestOptions.extra['retriedAfterRefresh'] = true;
            requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';

            final retryResponse = await _dio.fetch(requestOptions);
            return handler.resolve(retryResponse);
          }
        } catch (refreshError) {
          _logger.e('Token refresh failed', error: refreshError);
        }

        // Refresh failed (or returned no token) — session is no longer valid.
        _logger.w('Session expired — clearing tokens.');
        clearTokens();
        onSessionExpired?.call();
      }
    }

    if (dioError.response?.statusCode == 403) {
      // Forbidden - forbidden access
      _logger.w('Access forbidden');
    }

    handler.next(dioError);
  }

  /// Ensures only one refresh call is in flight at a time; concurrent 401s
  /// while a refresh is already running wait for the same result instead of
  /// each firing their own refresh request.
  Future<String?> _refreshAccessTokenOnce() async {
    if (_isRefreshing) {
      // Wait briefly for the in-flight refresh to complete, then reuse
      // whatever token it produced.
      while (_isRefreshing) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
      return _accessToken.isNotEmpty ? _accessToken : null;
    }

    _isRefreshing = true;
    try {
      final newAccessToken = await onRefreshToken?.call(_refreshToken);
      if (newAccessToken != null && newAccessToken.isNotEmpty) {
        setTokens(newAccessToken);
      }
      return newAccessToken;
    } finally {
      _isRefreshing = false;
    }
  }

  // Set tokens
  void setTokens(String accessToken, {String? refreshToken}) {
    _accessToken = accessToken;
    if (refreshToken != null) {
      _refreshToken = refreshToken;
    }
    _logger.i('Tokens set');
  }

  // Clear tokens
  void clearTokens() {
    _accessToken = '';
    _refreshToken = '';
    _logger.i('Tokens cleared');
  }

  // Get Dio error message
  String _getDioErrorMessage(DioException error) {
    if (error.response?.statusCode == 401) {
      return 'Unauthorized. Please login again.';
    } else if (error.response?.statusCode == 403) {
      return 'Access forbidden.';
    } else if (error.response?.statusCode == 404) {
      return 'Resource not found.';
    } else if (error.response?.statusCode == 500) {
      return 'Server error. Please try again later.';
    }
    return error.message ?? AppConstants.serverError;
  }

  // GET request
  Future<ApiResponse<T>> get<T>(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJsonT,
    CancelToken? cancelToken,
  }) async {
    try {
      _logger.i('GET $endpoint');
      final response = await _dio.get(
        endpoint,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
      );
      return _parseResponse(response, fromJsonT);
    } catch (e) {
      _logger.e('Error in GET request', error: e);
      if (e is DioException) {
        return ApiResponse.error(
          message: _getDioErrorMessage(e),
          error: e.toString(),
          statusCode: e.response?.statusCode ?? 0,
        );
      }
      return ApiResponse.error(
        message: AppConstants.serverError,
        error: e.toString(),
        statusCode: 500,
      );
    }
  }

  // POST request
  Future<ApiResponse<T>> post<T>(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJsonT,
    CancelToken? cancelToken,
  }) async {
    try {
      _logger.i('POST $endpoint');
      final response = await _dio.post(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
      );

      return _parseResponse(response, fromJsonT);
    } on DioError catch (e) {
      return _handleError(e);
    } catch (e) {
      _logger.e('Unexpected error', error: e);
      return ApiResponse.error(
        message: AppConstants.serverError,
        error: e.toString(),
        statusCode: 500,
      );
    }
  }

  // PUT request
  Future<ApiResponse<T>> put<T>(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJsonT,
    CancelToken? cancelToken,
  }) async {
    try {
      _logger.i('PUT $endpoint');
      final response = await _dio.put(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
      );

      return _parseResponse(response, fromJsonT);
    } on DioError catch (e) {
      return _handleError(e);
    } catch (e) {
      _logger.e('Unexpected error', error: e);
      return ApiResponse.error(
        message: AppConstants.serverError,
        error: e.toString(),
        statusCode: 500,
      );
    }
  }

  // DELETE request
  Future<ApiResponse<T>> delete<T>(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJsonT,
    CancelToken? cancelToken,
  }) async {
    try {
      _logger.i('DELETE $endpoint');
      final response = await _dio.delete(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
      );

      return _parseResponse(response, fromJsonT);
    } on DioError catch (e) {
      return _handleError(e);
    } catch (e) {
      _logger.e('Unexpected error', error: e);
      return ApiResponse.error(
        message: AppConstants.serverError,
        error: e.toString(),
        statusCode: 500,
      );
    }
  }

  // PATCH request
  Future<ApiResponse<T>> patch<T>(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJsonT,
    CancelToken? cancelToken,
  }) async {
    try {
      _logger.i('PATCH $endpoint');
      final response = await _dio.patch(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
      );

      return _parseResponse(response, fromJsonT);
    } on DioError catch (e) {
      return _handleError(e);
    } catch (e) {
      _logger.e('Unexpected error', error: e);
      return ApiResponse.error(
        message: AppConstants.serverError,
        error: e.toString(),
        statusCode: 500,
      );
    }
  }

  /// Works on web and mobile. `fromFile` needs dart:io and fails in Chrome.
  Future<MultipartFile> _multipartFromPath(String filePath) async {
    final file = XFile(filePath);
    final bytes = await file.readAsBytes();
    final name = file.name.trim().isNotEmpty ? file.name : 'photo.jpg';
    return MultipartFile.fromBytes(bytes, filename: name);
  }

  /// Upload already-read bytes. The signup flow holds the picked image as
  /// bytes (a dart:io File path is unusable on web), so it uploads this way.
  Future<ApiResponse<T>> uploadBytes<T>(
    String endpoint, {
    required List<int> bytes,
    required String filename,
    String fieldName = 'file',
    Map<String, dynamic>? additionalData,
    T Function(dynamic)? fromJsonT,
    void Function(int, int)? onSendProgress,
    CancelToken? cancelToken,
  }) async {
    try {
      final formData = FormData.fromMap({
        fieldName: MultipartFile.fromBytes(bytes, filename: filename),
        ...?additionalData,
      });

      _logger.i('Upload bytes: $endpoint');
      final response = await _dio.post(
        endpoint,
        data: formData,
        options: Options(
          sendTimeout: const Duration(minutes: 2),
          receiveTimeout: const Duration(minutes: 2),
          extra: {'skipRetry': true},
        ),
        onSendProgress: onSendProgress,
        cancelToken: cancelToken,
      );

      return _parseResponse(response, fromJsonT);
    } on DioError catch (e) {
      return _handleError(e);
    } catch (e) {
      _logger.e('Unexpected error', error: e);
      return ApiResponse.error(
        message: AppConstants.serverError,
        error: e.toString(),
        statusCode: 500,
      );
    }
  }

  // Upload file
  Future<ApiResponse<T>> uploadFile<T>(
    String endpoint, {
    required String filePath,
    String fieldName = 'file',
    Map<String, dynamic>? additionalData,
    T Function(dynamic)? fromJsonT,
    void Function(int, int)? onSendProgress,
    CancelToken? cancelToken,
  }) async {
    try {
      final formData = FormData.fromMap({
        fieldName: await _multipartFromPath(filePath),
        ...?additionalData,
      });

      _logger.i('Upload file: $endpoint');
      final response = await _dio.post(
        endpoint,
        data: formData,
        options: Options(
          sendTimeout: const Duration(minutes: 2),
          receiveTimeout: const Duration(minutes: 2),
          extra: {'skipRetry': true},
        ),
        onSendProgress: onSendProgress,
        cancelToken: cancelToken,
      );

      return _parseResponse(response, fromJsonT);
    } on DioError catch (e) {
      return _handleError(e);
    } catch (e) {
      _logger.e('Unexpected error', error: e);
      return ApiResponse.error(
        message: AppConstants.serverError,
        error: e.toString(),
        statusCode: 500,
      );
    }
  }

  // Upload multiple files
  Future<ApiResponse<T>> uploadMultipleFiles<T>(
    String endpoint, {
    required List<String> filePaths,
    String fieldName = 'files',
    Map<String, dynamic>? additionalData,
    T Function(dynamic)? fromJsonT,
    void Function(int, int)? onSendProgress,
    CancelToken? cancelToken,
  }) async {
    try {
      final List<MultipartFile> files = [];
      for (final filePath in filePaths) {
        files.add(await _multipartFromPath(filePath));
      }

      final formData = FormData.fromMap({
        fieldName: files,
        ...?additionalData,
      });

      _logger.i('Upload multiple files: $endpoint');
      final response = await _dio.post(
        endpoint,
        data: formData,
        options: Options(
          sendTimeout: const Duration(minutes: 2),
          receiveTimeout: const Duration(minutes: 2),
          extra: {'skipRetry': true},
        ),
        onSendProgress: onSendProgress,
        cancelToken: cancelToken,
      );

      return _parseResponse(response, fromJsonT);
    } on DioError catch (e) {
      return _handleError(e);
    } catch (e) {
      _logger.e('Unexpected error', error: e);
      return ApiResponse.error(
        message: AppConstants.serverError,
        error: e.toString(),
        statusCode: 500,
      );
    }
  }

  // Parse response
  ApiResponse<T> _parseResponse<T>(
    Response response,
    T Function(dynamic)? fromJsonT,
  ) {
    try {
      final statusCode = response.statusCode ?? 200;

      if (statusCode >= 200 && statusCode < 300) {
        final data = response.data;

        if (data is Map<String, dynamic>) {
          final payload = data.containsKey('data') ? data['data'] : data;

          return ApiResponse.success(
            message: data['message'] ?? 'Success',
            data: fromJsonT != null ? fromJsonT(payload) : payload as T,
            statusCode: statusCode,
          );
        } else {
          return ApiResponse.success(
            message: 'Success',
            data: fromJsonT != null ? fromJsonT(data) : data as T,
            statusCode: statusCode,
          );
        }
      } else {
        String errorMessage = 'Server error';

        if (response.data is Map<String, dynamic>) {
          final responseMap = response.data as Map<String, dynamic>;
          errorMessage = responseMap['message']?.toString() ?? errorMessage;
        } else if (response.statusMessage != null) {
          errorMessage = response.statusMessage!;
        }

        return ApiResponse.error(
          message: errorMessage,
          error: response.data?.toString() ?? 'Unknown error',
          statusCode: statusCode,
        );
      }
    } catch (e) {
      _logger.e('Error parsing response', error: e);
      return ApiResponse.error(
        message: AppConstants.serverError,
        error: e.toString(),
        statusCode: response.statusCode ?? 500,
      );
    }
  }

  // Handle errors
  ApiResponse<T> _handleError<T>(DioError error) {
    late String message;
    late String errorDetails;

    switch (error.type) {
      case DioErrorType.badResponse:
        final status = error.response?.statusCode;
        final body = error.response?.data;

        if (body is Map<String, dynamic> && body['message'] != null) {
          message = body['message'].toString();
        } else if (status == 401) {
          message = 'Please sign in to continue.';
        } else if (status == 403) {
          message = "You don't have access to this.";
        } else if (status == 404) {
          message = 'Not found.';
        } else if (status != null && status >= 500) {
          message = 'The server had a problem. Please try again shortly.';
        } else {
          message = error.response?.statusMessage ?? 'Server error occurred';
        }

        errorDetails = body?.toString() ?? 'Unknown error';
        break;
      case DioErrorType.connectionTimeout:
      case DioErrorType.sendTimeout:
      case DioErrorType.receiveTimeout:
        message = AppConstants.networkError;
        errorDetails = 'Request timeout';
        break;
      case DioErrorType.badCertificate:
      case DioErrorType.connectionError:
        message = AppConstants.networkError;
        errorDetails = 'Connection failed';
        break;
      case DioErrorType.unknown:
      case DioErrorType.cancel:
        message = AppConstants.serverError;
        errorDetails = error.message ?? 'Unknown error';
        break;
    }

    return ApiResponse<T>.error(
      message: message,
      error: errorDetails,
      statusCode: error.response?.statusCode ?? 500,
    );
  }
}

/// Retry Interceptor implementation
class RetryInterceptor extends Interceptor {
  final Dio _dio;
  final int maxRetries;
  int _retryCount = 0;

  RetryInterceptor(this._dio, {this.maxRetries = 3});

  @override
  Future<void> onError(
    DioError err,
    ErrorInterceptorHandler handler,
  ) async {
    // Only retry on network errors or specific status codes
    final isNetworkError = err.type == DioErrorType.unknown ||
        err.type == DioErrorType.connectionTimeout ||
        err.type == DioErrorType.sendTimeout ||
        err.type == DioErrorType.receiveTimeout;

    final isRetryableStatusCode = err.response?.statusCode == 408 ||
        err.response?.statusCode == 429; // Too many requests

    final skipRetry = err.requestOptions.extra['skipRetry'] == true ||
        err.requestOptions.data is FormData;

    if (!skipRetry && (isNetworkError || isRetryableStatusCode)) {
      if (_retryCount < maxRetries) {
        _retryCount++;
        Logger().i('Retrying request ($_retryCount/$maxRetries)...');

        // Wait before retry
        await Future.delayed(Duration(milliseconds: 500 * _retryCount));

        try {
          final response = await _dio.request(
            err.requestOptions.path,
            options: Options(
              method: err.requestOptions.method,
              headers: err.requestOptions.headers,
            ),
            data: err.requestOptions.data,
            queryParameters: err.requestOptions.queryParameters,
          );

          _retryCount = 0;
          return handler.resolve(response);
        } on DioError catch (e) {
          return handler.next(e);
        }
      }
    }

    _retryCount = 0;
    return handler.next(err);
  }
}
