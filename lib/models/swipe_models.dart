import 'package:dating_app/models/match_model.dart';

enum SwipeAction {
  like,
  superLike,
  dislike,
}

class SwipeActionResponse {
  final bool isMatch;
  final MatchModel? match;

  const SwipeActionResponse({
    required this.isMatch,
    this.match,
  });

  factory SwipeActionResponse.fromJson(Map<String, dynamic> json) {
    final normalized = _unwrapMap(json);
    final matchJson = normalized['match'];

    MatchModel? match;
    if (matchJson is Map<String, dynamic>) {
      match = MatchModel.fromJson(matchJson);
    } else if (_looksLikeMatch(normalized)) {
      match = MatchModel.fromJson(normalized);
    }

    // A match is only real when the backend says so explicitly. A missing or
    // unrecognised `status` used to default to "accepted", which made every
    // one-sided like / super like look like a mutual match.
    bool? explicitFlag;
    for (final key in const ['isMatch', 'matched', 'isMatched']) {
      final value = normalized[key];
      if (value is bool) {
        explicitFlag = (explicitFlag ?? false) || value;
      }
    }
    final rawStatus = (matchJson is Map<String, dynamic>
            ? matchJson['status']
            : normalized['status'])
        ?.toString()
        .toLowerCase();
    final statusSaysMatched = rawStatus == 'accepted' || rawStatus == 'matched';
    final isMatch = explicitFlag ?? (statusSaysMatched && match != null);

    return SwipeActionResponse(
      isMatch: isMatch,
      match: match,
    );
  }

  static Map<String, dynamic> _unwrapMap(Map<String, dynamic> source) {
    final nestedKeys = ['swipe', 'result', 'data'];

    for (final key in nestedKeys) {
      final value = source[key];
      if (value is Map<String, dynamic>) {
        return value;
      }
    }

    return source;
  }

  static bool _looksLikeMatch(Map<String, dynamic> json) {
    return json.containsKey('status') ||
        json.containsKey('targetUserId') ||
        json.containsKey('matchedUser') ||
        json.containsKey('user');
  }
}
