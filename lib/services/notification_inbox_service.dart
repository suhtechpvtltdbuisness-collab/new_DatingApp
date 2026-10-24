import 'package:dating_app/models/api_models.dart';
import 'package:dating_app/models/notification_model.dart';
import 'package:dating_app/network/api_client.dart';
import 'package:dating_app/network/api_endpoints.dart';

/// REST access to the in-app notification list (`/notifications`).
class NotificationInboxService {
  final ApiClient _apiClient = ApiClient();

  Future<ApiResponse<NotificationPage>> getNotifications({
    int page = 1,
    int limit = 30,
  }) {
    return _apiClient.get<NotificationPage>(
      ApiEndpoints.notifications,
      queryParameters: {'page': page, 'limit': limit},
      fromJsonT: (json) => NotificationPage.fromJson(
        json is Map<String, dynamic> ? json : <String, dynamic>{},
      ),
    );
  }

  Future<ApiResponse<int>> getUnreadCount() {
    return _apiClient.get<int>(
      ApiEndpoints.notificationsUnreadCount,
      fromJsonT: (json) =>
          json is Map ? int.tryParse('${json['unreadCount'] ?? 0}') ?? 0 : 0,
    );
  }

  Future<ApiResponse<void>> markRead(String notificationId) {
    return _apiClient.patch<void>(
      ApiEndpoints.getEndpoint(
        ApiEndpoints.notificationRead,
        {'notificationId': notificationId},
      ),
      fromJsonT: (_) {},
    );
  }

  Future<ApiResponse<void>> markAllRead() {
    return _apiClient.patch<void>(
      ApiEndpoints.notificationsReadAll,
      fromJsonT: (_) {},
    );
  }

  Future<ApiResponse<void>> delete(String notificationId) {
    return _apiClient.delete<void>(
      ApiEndpoints.getEndpoint(
        ApiEndpoints.notificationDelete,
        {'notificationId': notificationId},
      ),
      fromJsonT: (_) {},
    );
  }

  Future<ApiResponse<void>> clearAll() {
    return _apiClient.delete<void>(
      ApiEndpoints.notifications,
      fromJsonT: (_) {},
    );
  }
}
