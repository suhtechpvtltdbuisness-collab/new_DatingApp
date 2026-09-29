/// Shared chat content moderation — blocks abusive language before send.
class ContentModeration {
  ContentModeration._();

  static const List<String> _bannedWords = [
    'fuck',
    'fucker',
    'fucking',
    'shit',
    'bitch',
    'bastard',
    'asshole',
    'dick',
    'cock',
    'pussy',
    'slut',
    'whore',
    'cunt',
    'motherfucker',
    'mf',
    'stfu',
    'wtf',
    'idiot',
    'stupid',
    'dumbass',
    'retard',
    'nigger',
    'nigga',
    'chutiya',
    'chutia',
    'madarchod',
    'behenchod',
    'bhenchod',
    'bhosdike',
    'bhosdi',
    'randi',
    'harami',
    'kamina',
    'kutte',
    'kutta',
    'saala',
    'sala',
    'gandu',
    'gaand',
    'lund',
    'lawda',
    'lavda',
    'bsdk',
    'mc',
    'bc',
  ];

  static const String warningMessage =
      'Abusive language is not allowed. Please rephrase your message.';

  static String _normalize(String text) {
    var normalized = text.toLowerCase();
    const leetMap = {
      '0': 'o',
      '1': 'i',
      '!': 'i',
      '3': 'e',
      '4': 'a',
      '5': 's',
      '7': 't',
      '@': 'a',
      '\$': 's',
    };
    for (final entry in leetMap.entries) {
      normalized = normalized.replaceAll(entry.key, entry.value);
    }
    return normalized
        .replaceAll(RegExp(r'[^a-z\s]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  /// Returns a warning when [text] contains abusive language; otherwise null.
  static String? abusiveWarning(String text) {
    final normalized = _normalize(text);
    if (normalized.isEmpty) return null;

    final tokens = normalized.split(' ').where((t) => t.isNotEmpty).toSet();
    for (final word in _bannedWords) {
      if (tokens.contains(word)) return warningMessage;
      if (word.length >= 4 && normalized.contains(word)) return warningMessage;
    }
    return null;
  }
}
