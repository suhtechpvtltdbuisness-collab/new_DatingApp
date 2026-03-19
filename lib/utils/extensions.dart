import 'package:intl/intl.dart';

extension StringExtensions on String {
  // Capitalize first letter
  String get capitalize => isEmpty ? '' : '${this[0].toUpperCase()}${substring(1)}';

  // Check if valid email
  bool get isValidEmail {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(this);
  }

  // Check if valid phone
  bool get isValidPhone {
    final phoneRegex = RegExp(r'^\+?1?\d{9,15}$');
    return phoneRegex.hasMatch(replaceAll(RegExp(r'[^\d+]'), ''));
  }

  // Check if valid URL
  bool get isValidUrl {
    final urlRegex = RegExp(
      r'^(https?|ftp):\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
    );
    return urlRegex.hasMatch(this);
  }

  // Check if string is numeric
  bool get isNumeric => RegExp(r'^\d+$').hasMatch(this);

  // Remove special characters
  String get removeSpecialCharacters =>
      replaceAll(RegExp(r'[^\w\s]'), '');

  // Convert to title case
  String get toTitleCase => split(' ')
      .map((word) =>
          word.isEmpty ? '' : '${word[0].toUpperCase()}${word.substring(1)}')
      .join(' ');

  // Truncate string with ellipsis
  String truncate(int length) =>
      this.length > length ? '${substring(0, length)}...' : this;

  // Check if contains only letters
  bool get isAlpha => RegExp(r'^[a-zA-Z]+$').hasMatch(this);

  // Check if contains only alphanumeric
  bool get isAlphaNumeric => RegExp(r'^[a-zA-Z0-9]+$').hasMatch(this);

  // Get first N characters
  String firstN(int n) => length > n ? substring(0, n) : this;

  // Get last N characters
  String lastN(int n) => length > n ? substring(length - n) : this;
}

extension IntExtensions on int {
  // Convert milliseconds to Duration
  Duration get milliseconds => Duration(milliseconds: this);

  // Convert seconds to Duration
  Duration get seconds => Duration(seconds: this);

  // Convert minutes to Duration
  Duration get minutes => Duration(minutes: this);

  // Convert hours to Duration
  Duration get hours => Duration(hours: this);

  // Check if positive
  bool get isPositive => this > 0;

  // Check if negative
  bool get isNegative => this < 0;

  // Check if even
  bool get isEven => this % 2 == 0;

  // Check if odd
  bool get isOdd => this % 2 != 0;

  // Get absolute value
  int get abs => this.abs();

  // Format as distance (km)
  String get distanceString => '$this km';

  // Format as age
  String get ageString => '$this years old';
}

extension DoubleExtensions on double {
  // Round to N decimal places
  double roundToDecimals(int decimals) {
    final factor = 10.0 * decimals;
    return (this * factor).round() / factor;
  }

  // Check if positive
  bool get isPositive => this > 0;

  // Check if negative
  bool get isNegative => this < 0;

  // Get absolute value
  double get abs => this.abs();

  // Format as distance (km)
  String get distanceString => '${roundToDecimals(1)} km';

  // Format as currency
  String get currencyString => '\$${roundToDecimals(2)}';
}

extension DateTimeExtensions on DateTime {
  // Get age from date of birth
  int get age => DateTime.now().year - year;

  // Format as short date (MM/dd/yyyy)
  String get shortDate => DateFormat('MM/dd/yyyy').format(this);

  // Format as medium date (MMM dd, yyyy)
  String get mediumDate => DateFormat('MMM dd, yyyy').format(this);

  // Format as long date (MMMM dd, yyyy)
  String get longDate => DateFormat('MMMM dd, yyyy').format(this);

  // Format as time (HH:mm)
  String get shortTime => DateFormat('HH:mm').format(this);

  // Format as time with seconds (HH:mm:ss)
  String get longTime => DateFormat('HH:mm:ss').format(this);

  // Format as date time (MM/dd/yyyy HH:mm)
  String get dateTime => DateFormat('MM/dd/yyyy HH:mm').format(this);

  // Check if today
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  // Check if yesterday
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(Duration(days: 1));
    return year == yesterday.year &&
        month == yesterday.month &&
        day == yesterday.day;
  }

  // Check if same day as another date
  bool isSameDayAs(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }

  // Get time ago string (e.g., "2 hours ago")
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(this);

    if (difference.inSeconds < 60) {
      return 'just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks week${weeks == 1 ? '' : 's'} ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months month${months == 1 ? '' : 's'} ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years year${years == 1 ? '' : 's'} ago';
    }
  }

  // Add days
  DateTime addDaysLike(int days) => add(Duration(days: days));

  // Subtract days
  DateTime subtractDays(int days) =>
      subtract(Duration(days: days));
}

extension ListExtensions<T> on List<T> {
  // Check if list is empty
  bool get isEmpty => length == 0;

  // Check if list has elements
  bool get isNotEmpty => length > 0;

  // Get first element or null
  T? get firstOrNull => isEmpty ? null : first;

  // Get last element or null
  T? get lastOrNull => isEmpty ? null : last;

  // Check if list contains any element that satisfies condition
  bool anyWhere(bool Function(T) test) => any(test);

  // Group list elements by key
  Map<K, List<T>> groupBy<K>(K Function(T) key) {
    final map = <K, List<T>>{};
    for (final item in this) {
      final k = key(item);
      map.putIfAbsent(k, () => []).add(item);
    }
    return map;
  }

  // Check if all elements satisfy condition
  bool allWhere(bool Function(T) test) => every(test);
}

extension MapExtensions<K, V> on Map<K, V> {
  // Check if map is empty
  bool get isEmpty => length == 0;

  // Check if map has entries
  bool get isNotEmpty => length > 0;

  // Get value or default
  V? getOrDefault(K key, V? defaultValue) {
    return containsKey(key) ? this[key] : defaultValue;
  }

  // Filter map by key
  Map<K, V> filterByKey(bool Function(K) test) {
    final result = <K, V>{};
    forEach((key, value) {
      if (test(key)) {
        result[key] = value;
      }
    });
    return result;
  }

  // Filter map by value
  Map<K, V> filterByValue(bool Function(V) test) {
    final result = <K, V>{};
    forEach((key, value) {
      if (test(value)) {
        result[key] = value;
      }
    });
    return result;
  }
}
