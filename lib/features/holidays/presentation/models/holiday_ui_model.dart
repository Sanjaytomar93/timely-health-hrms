import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:timelay_health/core/theme/portal_colors.dart';
import 'package:timelay_health/features/holidays/domain/entities/holiday.dart';

class HolidayStatsUiModel extends Equatable {
  const HolidayStatsUiModel({
    required this.total,
    required this.upcoming,
    required this.year,
  });

  final int total;
  final int upcoming;
  final int year;

  static const empty = HolidayStatsUiModel(total: 0, upcoming: 0, year: 0);

  @override
  List<Object?> get props => [total, upcoming, year];
}

class HolidayUiModel extends Equatable {
  const HolidayUiModel({
    required this.id,
    required this.index,
    required this.name,
    required this.category,
    required this.categoryColor,
    required this.categoryBg,
    required this.dateRange,
    required this.fromDate,
    required this.type,
    required this.totalDays,
    required this.isActive,
  });

  final String id;
  final String index;
  final String name;
  final String category;
  final Color categoryColor;
  final Color categoryBg;
  final String dateRange;
  final DateTime? fromDate;
  final String type;
  final int totalDays;
  final bool isActive;

  String get daysLabel {
    final d = totalDays <= 0 ? 1 : totalDays;
    return d == 1 ? '1 day' : '$d days';
  }

  @override
  List<Object?> get props => [
    id,
    index,
    name,
    category,
    dateRange,
    fromDate,
    type,
    totalDays,
    isActive,
  ];
}

class HolidayUiMapper {
  const HolidayUiMapper._();

  static List<HolidayUiModel> toUiList(List<Holiday> holidays) {
    final sorted = [...holidays]
      ..sort((a, b) {
        final ad = a.fromDate ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bd = b.fromDate ?? DateTime.fromMillisecondsSinceEpoch(0);
        return ad.compareTo(bd);
      });
    return [for (var i = 0; i < sorted.length; i++) toUi(sorted[i], i + 1)];
  }

  static HolidayUiModel toUi(Holiday holiday, int index) {
    final colors = _typeColors(holiday.type);
    final state = holiday.state.trim().isEmpty
        ? 'All States'
        : holiday.state.trim();
    return HolidayUiModel(
      id: holiday.id,
      index: index.toString().padLeft(2, '0'),
      name: holiday.name.trim().isEmpty ? '—' : holiday.name.trim(),
      category: holiday.type.trim().isEmpty ? 'Holiday' : holiday.type.trim(),
      categoryColor: colors.$1,
      categoryBg: colors.$2,
      dateRange:
          '$state · ${_dateLabel(holiday.fromDate)} → ${_dateLabel(holiday.toDate)}',
      fromDate: holiday.fromDate,
      type: holiday.type,
      totalDays: holiday.totalDays <= 0 ? 1 : holiday.totalDays,
      isActive: holiday.isActive,
    );
  }

  static HolidayStatsUiModel toStats(List<Holiday> holidays) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yearHolidays = holidays.where((h) {
      final d = h.fromDate;
      return d != null && d.year == now.year;
    }).toList();
    final upcoming = yearHolidays.where((h) {
      final d = h.fromDate?.toLocal();
      if (d == null) return false;
      final day = DateTime(d.year, d.month, d.day);
      return !day.isBefore(today) && h.isActive;
    }).length;

    return HolidayStatsUiModel(
      total: yearHolidays.isEmpty ? holidays.length : yearHolidays.length,
      upcoming: upcoming,
      year: now.year,
    );
  }

  static (Color, Color) _typeColors(String type) {
    switch (type.toLowerCase()) {
      case 'national holiday':
        return (const Color(0xFF1FA971), PortalColors.greenTint);
      case 'festival':
        return (const Color(0xFFEE7D3D), const Color(0xFFFDF3E3));
      case 'company holiday':
        return (const Color(0xFF26204A), PortalColors.purpleTint);
      case 'restricted':
        return (const Color(0xFFE0499B), const Color(0xFFFCEAF4));
      case 'observance':
        return (const Color(0xFF319DF0), const Color(0xFFEAF1FD));
      default:
        return (PortalColors.muted, PortalColors.background);
    }
  }

  static String _dateLabel(DateTime? date) {
    if (date == null) return '—';
    final local = date.toLocal();
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${local.day} ${months[local.month - 1]} ${local.year}';
  }

  static String todayLabel([DateTime? date]) {
    final local = (date ?? DateTime.now()).toLocal();
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${weekdays[local.weekday - 1]}, ${months[local.month - 1]} ${local.day}, ${local.year}';
  }
}
