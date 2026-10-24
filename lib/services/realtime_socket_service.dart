import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:dating_app/network/api_client.dart';
import 'package:dating_app/utils/constants.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

/// One frame from the server: `{ "event": ..., "data": {...} }`.
class RealtimeEvent {
  const RealtimeEvent(this.event, this.data);

  final String event;
  final Map<String, dynamic> data;
}

enum SocketStatus { disconnected, connecting, connected }

/// Connection to the backend WebSocket gateway (`/ws`).
///
/// Holds one socket for the signed-in user, reconnects with backoff, refreshes
/// the access token when the server rejects it (close code 4001) and exposes
/// every server event as a broadcast stream.
class RealtimeSocketService {
  RealtimeSocketService._internal();

  static final RealtimeSocketService _instance =
      RealtimeSocketService._internal();

  factory RealtimeSocketService() => _instance;

  /// Synthetic event emitted when the server refuses the account (banned or
  /// deleted), so listeners can sign the user out.
  static const String accountUnavailableEvent = 'account_suspended';

  static const int _closeUnauthorized = 4001;
  static const int _closeSuspended = 4003;
  static const Duration _pingInterval = Duration(seconds: 25);
  static const int _maxBackoffSeconds = 30;

  final Logger _logger = Logger();
  final ApiClient _apiClient = ApiClient();
  final Random _random = Random();

  final status = SocketStatus.disconnected.obs;
  final StreamController<RealtimeEvent> _events =
      StreamController<RealtimeEvent>.broadcast();

  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _subscription;
  Timer? _reconnectTimer;
  Timer? _pingTimer;
  bool _wantConnected = false;
  bool _refreshedForThisAttempt = false;
  int _attempt = 0;
  // Bumped for every new channel so callbacks from a replaced one are ignored.
  int _generation = 0;

  bool get isConnected => status.value == SocketStatus.connected;

  Stream<RealtimeEvent> get events => _events.stream;

  Stream<Map<String, dynamic>> on(String event) =>
      events.where((e) => e.event == event).map((e) => e.data);

  /// Starts (or keeps) a connection for the current session.
  void connect() {
    _wantConnected = true;
    if (status.value != SocketStatus.disconnected) return;
    _reconnectTimer?.cancel();
    _open();
  }

  /// Reconnects immediately if the socket dropped, e.g. on app resume.
  void ensureConnected() {
    if (!_wantConnected) return;
    if (status.value != SocketStatus.disconnected) return;
    _attempt = 0;
    _reconnectTimer?.cancel();
    _open();
  }

  /// Closes the socket and stops reconnecting (logout).
  Future<void> disconnect() async {
    _wantConnected = false;
    _attempt = 0;
    _reconnectTimer?.cancel();
    _teardown();
    status.value = SocketStatus.disconnected;
  }

  /// Sends a client event; returns false when not connected.
  bool send(String event, [Map<String, dynamic> data = const {}]) {
    final channel = _channel;
    if (channel == null || !isConnected) return false;
    try {
      channel.sink.add(jsonEncode({'event': event, 'data': data}));
      return true;
    } catch (e) {
      _logger.w('Socket send failed: $e');
      return false;
    }
  }

  Uri _socketUri(String token) {
    final base = Uri.parse(AppConstants.baseUrl);
    return base.replace(
      scheme: base.scheme == 'https' ? 'wss' : 'ws',
      path: '/ws',
      queryParameters: {'token': token},
    );
  }

  Future<void> _open() async {
    final token = _apiClient.accessToken;
    if (token.isEmpty) {
      // Signed out; nothing to connect as.
      _wantConnected = false;
      status.value = SocketStatus.disconnected;
      return;
    }

    _teardown();
    final generation = ++_generation;
    status.value = SocketStatus.connecting;

    try {
      final channel = WebSocketChannel.connect(_socketUri(token));
      _channel = channel;
      await channel.ready;
      if (generation != _generation) return;

      _subscription = channel.stream.listen(
        (raw) => _onFrame(generation, raw),
        onDone: () => _onClosed(generation, channel.closeCode),
        onError: (Object error) {
          _logger.w('Socket error: $error');
        },
        cancelOnError: false,
      );
    } catch (e) {
      if (generation != _generation) return;
      _logger.w('Socket connect failed: $e');
      _onClosed(generation, null);
    }
  }

  void _onFrame(int generation, dynamic raw) {
    if (generation != _generation || raw is! String) return;

    Map<String, dynamic> frame;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return;
      frame = decoded.map((key, value) => MapEntry(key.toString(), value));
    } catch (_) {
      return;
    }

    final event = frame['event']?.toString() ?? '';
    if (event.isEmpty) return;
    final data = frame['data'] is Map
        ? (frame['data'] as Map)
            .map((key, value) => MapEntry(key.toString(), value))
        : <String, dynamic>{};

    if (event == 'connected') {
      _attempt = 0;
      _refreshedForThisAttempt = false;
      status.value = SocketStatus.connected;
      _startPing();
    }
    if (event == 'pong') return;

    _events.add(RealtimeEvent(event, data));
  }

  Future<void> _onClosed(int generation, int? code) async {
    if (generation != _generation) return;
    _teardown();
    status.value = SocketStatus.disconnected;
    if (!_wantConnected) return;

    if (code == _closeSuspended) {
      _wantConnected = false;
      _events.add(const RealtimeEvent(accountUnavailableEvent, {}));
      return;
    }

    if (code == _closeUnauthorized) {
      // Expired access token: refresh once, then reconnect straight away.
      if (!_refreshedForThisAttempt) {
        _refreshedForThisAttempt = true;
        final refreshed = await _apiClient.refreshSession();
        if (generation != _generation || !_wantConnected) return;
        if (refreshed) {
          _open();
          return;
        }
      }
      if (!_apiClient.hasSession) {
        _wantConnected = false;
        return;
      }
    }

    _scheduleReconnect();
  }

  void _scheduleReconnect() {
    _reconnectTimer?.cancel();
    final seconds = min(_maxBackoffSeconds, 1 << min(_attempt, 5));
    _attempt++;
    final jitter = Duration(milliseconds: _random.nextInt(1000));
    _reconnectTimer = Timer(Duration(seconds: seconds) + jitter, () {
      _refreshedForThisAttempt = false;
      if (_wantConnected) _open();
    });
  }

  void _startPing() {
    _pingTimer?.cancel();
    _pingTimer = Timer.periodic(_pingInterval, (_) => send('ping'));
  }

  void _teardown() {
    _pingTimer?.cancel();
    _pingTimer = null;
    _subscription?.cancel();
    _subscription = null;
    final channel = _channel;
    _channel = null;
    if (channel != null) {
      try {
        channel.sink.close();
      } catch (_) {}
    }
  }
}
