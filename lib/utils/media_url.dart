import 'package:dating_app/utils/constants.dart';

/// Rewrites legacy backend hosts (e.g. old Vercel deployment) to [AppConstants.baseUrl].
String resolveMediaUrl(String url) {
  final trimmed = url.trim();
  if (trimmed.isEmpty) return trimmed;

  final base = AppConstants.baseUrl.replaceAll(RegExp(r'/+$'), '');
  if (base.isEmpty) return trimmed;

  if (!trimmed.startsWith('http://') && !trimmed.startsWith('https://')) {
    if (trimmed.startsWith('/')) {
      return '$base$trimmed';
    }
    return trimmed;
  }

  try {
    final parsed = Uri.parse(trimmed);
    if (!parsed.path.startsWith('/media')) {
      return trimmed;
    }
    final baseUri = Uri.parse(base);
    if (parsed.host == baseUri.host) {
      return trimmed;
    }
    return Uri(
      scheme: baseUri.scheme,
      host: baseUri.host,
      port: baseUri.hasPort ? baseUri.port : null,
      path: parsed.path,
      query: parsed.query.isEmpty ? null : parsed.query,
    ).toString();
  } catch (_) {
    return trimmed;
  }
}
