class TimeFormat {
  const TimeFormat._();

  /// `9:56 AM`
  static String clock(DateTime? date, {String fallback = '—'}) {
    if (date == null) return fallback;
    final local = date.toLocal();
    final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
    final minute = local.minute.toString().padLeft(2, '0');
    final period = local.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  /// `10:00 AM – 07:00 PM`, accepting 12h or 24h input.
  static String shiftRange(String raw, {String fallback = '—'}) {
    final value = raw.trim();
    if (value.isEmpty || value == 'Not Assigned' || value == '—') {
      return fallback;
    }
    final parts = value.split(RegExp(r'\s*[–—-]\s*'));
    if (parts.length != 2) return value;
    final start = _shiftClock(parts[0]);
    final end = _shiftClock(parts[1]);
    if (start == null || end == null) return value;
    return '$start – $end';
  }

  /// Minutes after midnight for the start of `10:00 AM – 07:00 PM`.
  static int? shiftStartMinutes(String raw) {
    final value = raw.trim();
    if (value.isEmpty || value == 'Not Assigned' || value == '—') return null;
    final first = value.split(RegExp(r'\s*(?:[–—-]|\bto\b)\s*')).first;
    final m = RegExp(
      r'^(\d{1,2}):(\d{2})(?::\d{2})?\s*(am|pm)?$',
      caseSensitive: false,
    ).firstMatch(first.trim());
    if (m == null) return null;
    var hour = int.parse(m.group(1)!);
    final minute = int.parse(m.group(2)!);
    final period = m.group(3)?.toLowerCase();
    if (period != null) {
      if (hour < 1 || hour > 12) return null;
      hour = hour % 12 + (period == 'pm' ? 12 : 0);
    } else if (hour > 23) {
      return null;
    }
    if (minute > 59) return null;
    return hour * 60 + minute;
  }

  static String? _shiftClock(String raw) {
    final m = RegExp(
      r'^(\d{1,2}):(\d{2})(?::\d{2})?\s*(am|pm)?$',
      caseSensitive: false,
    ).firstMatch(raw.trim());
    if (m == null) return null;
    var hour = int.parse(m.group(1)!);
    final minute = m.group(2)!;
    final period = m.group(3)?.toUpperCase();
    if (period == null) {
      if (hour > 23) return null;
      final p = hour >= 12 ? 'PM' : 'AM';
      hour = hour % 12 == 0 ? 12 : hour % 12;
      return '${hour.toString().padLeft(2, '0')}:$minute $p';
    }
    if (hour < 1 || hour > 12) return null;
    return '${hour.toString().padLeft(2, '0')}:$minute $period';
  }
}
