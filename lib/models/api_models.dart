/// Generic API Response wrapper for all API calls
class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final int? statusCode;
  final String? error;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.statusCode,
    this.error,
  });

  factory ApiResponse.success({
    required String message,
    required T data,
    int? statusCode,
  }) {
    return ApiResponse(
      success: true,
      message: message,
      data: data,
      statusCode: statusCode ?? 200,
    );
  }

  factory ApiResponse.error({
    required String message,
    required String error,
    int? statusCode,
  }) {
    return ApiResponse(
      success: false,
      message: message,
      statusCode: statusCode ?? 400,
      error: error,
    );
  }

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT,
  ) {
    return ApiResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: fromJsonT != null && json['data'] != null
          ? fromJsonT(json['data'])
          : null,
      statusCode: json['statusCode'],
      error: json['error'],
    );
  }

  Map<String, dynamic> toJson(Map<String, dynamic> Function(T)? toJsonT) {
    return {
      'success': success,
      'message': message,
      'data': toJsonT != null && data != null ? toJsonT(data as T) : null,
      'statusCode': statusCode,
      'error': error,
    };
  }
}

// Pagination response
class PaginatedResponse<T> {
  final List<T> items;
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final int pageSize;

  PaginatedResponse({
    required this.items,
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.pageSize,
  });

  bool get hasNextPage => currentPage < totalPages;
  bool get hasPreviousPage => currentPage > 1;

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT,
  ) {
    return PaginatedResponse(
      items: fromJsonT != null && json['items'] != null
          ? List<T>.from((json['items'] as List).map((e) => fromJsonT(e)))
          : [],
      currentPage: json['currentPage'] ?? 1,
      totalPages: json['totalPages'] ?? 0,
      totalItems: json['totalItems'] ?? 0,
      pageSize: json['pageSize'] ?? 10,
    );
  }

  Map<String, dynamic> toJson(Map<String, dynamic> Function(T)? toJsonT) {
    return {
      'items': toJsonT != null ? items.map((e) => toJsonT(e)).toList() : [],
      'currentPage': currentPage,
      'totalPages': totalPages,
      'totalItems': totalItems,
      'pageSize': pageSize,
    };
  }
}

// Authentication models
class SignUpRequest {
  final String name;
  final String phoneNumber;
  final String dob;
  final String gender;
  final String profile;
  final String interestedIn;
  final String email;
  final String password;
  final Location location;

  SignUpRequest({
    required this.name,
    required this.phoneNumber,
    required this.dob,
    required this.gender,
    required this.profile,
    required this.interestedIn,
    required this.email,
    required this.password,
    required this.location,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phoneNumber': phoneNumber,
      'dob': dob,
      'gender': gender,
      'profile': profile,
      'interestedIn': interestedIn,
      'email': email,
      'password': password,
      'location': location.toJson(),
    };
  }
}

class Location {
  final List<String> coordinates;

  Location({required this.coordinates});

  Map<String, dynamic> toJson() {
    return {
      'coordinates': coordinates,
    };
  }
}

class LoginRequest {
  final String email;
  final String password;

  LoginRequest({
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }
}

class AuthResponse {
  final String accessToken;
  final String refreshToken;
  final String userId;
  final int expiresIn;
  final String userEmail;

  AuthResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.userId,
    required this.expiresIn,
    required this.userEmail,
  });

  /// Decode the `sub` claim from a JWT payload (base64url encoded, no signature verification).
  static String _extractSubFromJwt(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return '';
      // Base64url decode the payload part
      var payload = parts[1];
      // Pad to multiple of 4
      switch (payload.length % 4) {
        case 2:
          payload += '==';
          break;
        case 3:
          payload += '=';
          break;
        default:
          break;
      }
      // Replace url-safe chars
      payload = payload.replaceAll('-', '+').replaceAll('_', '/');
      final decoded = String.fromCharCodes(
        _base64Decode(payload),
      );
      final match = RegExp(r'"sub"\s*:\s*"([^"]+)"').firstMatch(decoded);
      return match?.group(1) ?? '';
    } catch (_) {
      return '';
    }
  }

  static List<int> _base64Decode(String s) {
    const chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
    final lookup = <int, int>{};
    for (var i = 0; i < chars.length; i++) {
      lookup[chars.codeUnitAt(i)] = i;
    }
    final output = <int>[];
    var buffer = 0;
    var bitsLeft = 0;
    for (final char in s.codeUnits) {
      final val = lookup[char];
      if (val == null) continue;
      buffer = (buffer << 6) | val;
      bitsLeft += 6;
      if (bitsLeft >= 8) {
        bitsLeft -= 8;
        output.add((buffer >> bitsLeft) & 0xFF);
      }
    }
    return output;
  }

  /// The API login response shape:
  /// { "message": "Login successful", "data": { "accessToken": "...", "refreshToken": "..." } }
  /// ApiClient._parseResponse extracts `data` before calling fromJson,
  /// so `json` here = { "accessToken": "...", "refreshToken": "..." }.
  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    final accessToken = json['accessToken'] as String? ?? '';
    final refreshToken = json['refreshToken'] as String? ?? '';
    // Decode userId from JWT sub claim (no secret needed — just parsing payload)
    final userId = json['userId'] as String? ?? _extractSubFromJwt(accessToken);
    return AuthResponse(
      accessToken: accessToken,
      refreshToken: refreshToken,
      userId: userId,
      expiresIn: json['expiresIn'] as int? ?? 900, // 15 min default
      userEmail: json['userEmail'] as String? ?? json['email'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'userId': userId,
      'expiresIn': expiresIn,
      'userEmail': userEmail,
    };
  }
}
