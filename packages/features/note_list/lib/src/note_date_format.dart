import 'package:intl/intl.dart';

/// Formats note timestamps the way list UIs usually do: the time for today,
/// a word for yesterday, the weekday within the last week and a short date
/// otherwise.
///
/// Create one per build and reuse it for every card: constructing
/// [DateFormat] instances is far more expensive than formatting with them.
/// Falls back to English, then to the system default, when the requested
/// locale has no date symbols loaded.
class NoteDateFormatter {
  NoteDateFormatter({
    required String locale,
    required this.yesterdayLabel,
    DateTime? now,
  }) : now = now ?? DateTime.now(),
       _formats = _Formats.forLocale(locale);

  final String yesterdayLabel;
  final DateTime now;
  final _Formats _formats;

  String format(DateTime date) {
    final day = DateTime(date.year, date.month, date.day);
    final today = DateTime(now.year, now.month, now.day);
    final days = today.difference(day).inDays;

    if (days == 0) return _formats.time.format(date);
    if (days == 1) return yesterdayLabel;
    if (days > 1 && days < 7) return _formats.weekday.format(date);
    if (date.year == now.year) return _formats.monthDay.format(date);
    return _formats.full.format(date);
  }
}

class _Formats {
  _Formats._(String? locale)
    : time = DateFormat.Hm(locale),
      weekday = DateFormat.EEEE(locale),
      monthDay = DateFormat.MMMd(locale),
      full = DateFormat.yMMMd(locale);

  /// Tries [locale], then English, then the intl default locale (which always
  /// has symbols) so construction never throws.
  factory _Formats.forLocale(String locale) {
    for (final candidate in [locale, 'en', null]) {
      try {
        return _Formats._(candidate);
      } on ArgumentError {
        continue;
      }
    }
    throw StateError('unreachable: default locale always exists');
  }

  final DateFormat time;
  final DateFormat weekday;
  final DateFormat monthDay;
  final DateFormat full;
}
