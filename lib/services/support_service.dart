import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:dating_app/models/api_models.dart';
import 'package:dating_app/network/api_client.dart';
import 'package:dating_app/network/api_endpoints.dart';

/// A file the user attached to a support request.
class SupportAttachment {
  SupportAttachment({required this.name, required this.bytes});

  final String name;
  final List<int> bytes;

  int get size => bytes.length;
}

/// Sends Contact support / Report a problem requests (`POST /support/tickets`).
/// The backend emails them to the support inbox and replies with a ticket
/// number.
class SupportService {
  final ApiClient _apiClient = ApiClient();

  Future<ApiResponse<String>> submitTicket({
    required String kind, // 'contact' or 'problem'
    required String name,
    required String email,
    required String issueType,
    required String subject,
    required String description,
    Map<String, String> details = const {},
    List<SupportAttachment> attachments = const [],
    void Function(int sent, int total)? onSendProgress,
  }) {
    final formData = FormData();
    formData.fields.addAll([
      MapEntry('kind', kind),
      MapEntry('name', name),
      MapEntry('email', email),
      MapEntry('issueType', issueType),
      MapEntry('subject', subject),
      MapEntry('description', description),
      if (details.isNotEmpty) MapEntry('details', _encodeDetails(details)),
    ]);
    for (final file in attachments) {
      formData.files.add(
        MapEntry(
          'attachments',
          MultipartFile.fromBytes(file.bytes, filename: file.name),
        ),
      );
    }

    return _apiClient.postMultipart<String>(
      ApiEndpoints.supportTickets,
      formData: formData,
      onSendProgress: onSendProgress,
      fromJsonT: (json) =>
          json is Map ? (json['ticketNumber'] ?? '').toString() : '',
    );
  }

  String _encodeDetails(Map<String, String> details) {
    final cleaned = <String, String>{
      for (final e in details.entries)
        if (e.value.trim().isNotEmpty) e.key: e.value.trim(),
    };
    return jsonEncode(cleaned);
  }
}

