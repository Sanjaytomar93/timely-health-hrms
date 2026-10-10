class WeekOffRule {
  const WeekOffRule(this.entries);

  final List<({int weekday, Set<int> occurrences})> entries;

  bool get isEmpty => entries.isEmpty;

  static const _weekdayNames = {
    'monday': DateTime.monday,
    'mon': DateTime.monday,
    'tuesday': DateTime.tuesday,
    'tue': DateTime.tuesday,
    'tues': DateTime.tuesday,
    'wednesday': DateTime.wednesday,
    'wed': DateTime.wednesday,
    'thursday': DateTime.thursday,
    'thu': DateTime.thursday,
    'thur': DateTime.thursday,
    'thurs': DateTime.thursday,
    'friday': DateTime.friday,
    'fri': DateTime.friday,
    'saturday': DateTime.saturday,
    'sat': DateTime.saturday,
    'sunday': DateTime.sunday,
    'sun': DateTime.sunday,
  };

  static const _ordinals = {
    '1st': 1,
    'first': 1,
    '2nd': 2,
    'second': 2,
    '3rd': 3,
    'third': 3,
    '4th': 4,
    'fourth': 4,
    '5th': 5,
    'fifth': 5,
    'last': -1,
  };

  static const fullWeekdays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  factory WeekOffRule.parse(String raw) {
    final entries = <({int weekday, Set<int> occurrences})>[];
    final segments = raw
        .toLowerCase()
        .split(RegExp(r'[,;/|]'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty);

    for (final segment in segments) {
      final words = segment
          .split(RegExp(r'[^a-z0-9]+'))
          .where((w) => w.isNotEmpty)
          .toList();
      final occurrences = <int>{};
      final weekdays = <int>[];
      for (final w in words) {
        final ord = _ordinals[w];
        if (ord != null) occurrences.add(ord);
        final day = _weekdayNames[w];
        if (day != null) weekdays.add(day);
      }
      for (final day in weekdays) {
        entries.removeWhere((e) => e.weekday == day && e.occurrences.isEmpty);
        entries.add((weekday: day, occurrences: {...occurrences}));
      }
    }
    return WeekOffRule(entries);
  }

  bool isOff(DateTime date) {
    for (final e in entries) {
      if (e.weekday != date.weekday) continue;
      if (e.occurrences.isEmpty) return true;
      final nth = (date.day - 1) ~/ 7 + 1;
      if (e.occurrences.contains(nth)) return true;
      final daysInMonth = DateTime(date.year, date.month + 1, 0).day;
      if (e.occurrences.contains(-1) && date.day + 7 > daysInMonth) {
        return true;
      }
    }
    return false;
  }

  List<DateTime> offDaysIn(int year, int month) {
    final days = DateTime(year, month + 1, 0).day;
    return [
      for (var d = 1; d <= days; d++)
        if (isOff(DateTime(year, month, d))) DateTime(year, month, d),
    ];
  }

  String get label {
    if (entries.isEmpty) return 'Not configured';
    final parts = <String>[];
    for (final e in entries) {
      final name = fullWeekdays[e.weekday - 1];
      if (e.occurrences.isEmpty) {
        parts.add('Every $name');
      } else {
        final ords = e.occurrences.toList()
          ..sort((a, b) {
            if (a == -1) return 1;
            if (b == -1) return -1;
            return a.compareTo(b);
          });
        parts.add('${ords.map(_ordinalLabel).join(' & ')} $name');
      }
    }
    return parts.join(', ');
  }

  bool get isWeeklyPattern => entries.every((e) => e.occurrences.isEmpty);

  static String _ordinalLabel(int n) => switch (n) {
    -1 => 'Last',
    1 => '1st',
    2 => '2nd',
    3 => '3rd',
    _ => '${n}th',
  };
}
