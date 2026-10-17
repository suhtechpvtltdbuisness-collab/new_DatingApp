import 'package:shared_preferences/shared_preferences.dart';

/// Device-side record of who Super Liked whom.
///
/// Stand-in until the backend returns `isSuperLike` on the liked-you list:
/// when a Super Like is sent from this device it is written here, so the
/// receiving account (signed in on the same device) can show the star badge.
/// A flag coming from the API always wins; this only fills the gap.
class SuperLikeLedger {
  SuperLikeLedger._();

  static const _key = 'super_like_ledger';
  static const _seenKey = 'super_like_ledger_seen';

  static String _pair(String senderId, String targetId) => '$senderId>$targetId';

  /// A person can be known by an id or an email depending on which API
  /// returned them, so every call takes all the keys we have for them and a
  /// pair matches when any sender key meets any target key.
  static Set<String> _clean(Iterable<String?> keys) => keys
      .map((k) => (k ?? '').trim().toLowerCase())
      .where((k) => k.isNotEmpty)
      .toSet();

  static Future<void> record({
    required Iterable<String?> senderKeys,
    required Iterable<String?> targetKeys,
  }) async {
    final senders = _clean(senderKeys);
    final targets = _clean(targetKeys);
    if (senders.isEmpty || targets.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final all = (prefs.getStringList(_key) ?? <String>[]).toSet();
    for (final s in senders) {
      for (final t in targets) {
        all.add(_pair(s, t));
      }
    }
    await prefs.setStringList(_key, all.toList());
  }

  static Future<bool> has({
    required Iterable<String?> senderKeys,
    required Iterable<String?> targetKeys,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final all = (prefs.getStringList(_key) ?? const <String>[]).toSet();
    for (final s in _clean(senderKeys)) {
      for (final t in _clean(targetKeys)) {
        if (all.contains(_pair(s, t))) return true;
      }
    }
    return false;
  }

  /// Returns true only the first time this Super Like is announced.
  static Future<bool> markAnnounced({
    required String senderId,
    required String targetId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final seen = (prefs.getStringList(_seenKey) ?? <String>[]).toSet();
    final added = seen.add(_pair(senderId.toLowerCase(), targetId.toLowerCase()));
    if (added) await prefs.setStringList(_seenKey, seen.toList());
    return added;
  }
}
