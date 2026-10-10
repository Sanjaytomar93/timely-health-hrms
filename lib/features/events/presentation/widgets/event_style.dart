import 'package:flutter/material.dart';
import 'package:timelay_health/core/theme/portal_colors.dart';
import 'package:timelay_health/features/events/data/models/my_event.dart';

extension EventTypeStyle on EventType {
  Color get color => switch (this) {
    EventType.birthday => const Color(0xFFE8467C),
    EventType.anniversary => const Color(0xFFE08A12),
    EventType.achievement => const Color(0xFF7B5CE0),
    EventType.appointment => const Color(0xFF3B6FE0),
    EventType.other => PortalColors.green,
  };

  Color get tint => switch (this) {
    EventType.birthday => const Color(0xFFFDECF2),
    EventType.anniversary => PortalColors.orangeTint,
    EventType.achievement => const Color(0xFFF0ECFD),
    EventType.appointment => const Color(0xFFEAF1FD),
    EventType.other => PortalColors.greenTint,
  };
}

const eventMonths = [
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

String formatEventDate(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')} ${eventMonths[d.month - 1]} ${d.year}';

String countdownLabel(int days) {
  if (days == 0) return 'Today';
  if (days == 1) return 'Tomorrow';
  if (days == -1) return 'Yesterday';
  return days > 0 ? 'in ${days}d' : '${-days}d ago';
}

String reminderLabel(int days) => switch (days) {
  0 => 'On the day',
  1 => '1 day before',
  _ => '$days days before',
};
