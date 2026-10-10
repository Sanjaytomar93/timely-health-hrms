import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:timelay_health/core/theme/portal_colors.dart';
import 'package:timelay_health/features/notifications/domain/entities/app_notification.dart';

enum NotificationFilter {
  all,
  unread,
  leaves,
  shifts,
  attendance,
  announcements,
}

enum NotificationVisualKind { system, leave, attendance, shift, announcement }

class NotificationUiModel extends Equatable {
  const NotificationUiModel({
    required this.id,
    required this.title,
    required this.message,
    required this.typeRaw,
    required this.isRead,
    required this.createdAt,
    required this.timeLabel,
    required this.categoryLabel,
    required this.kind,
    required this.accent,
    required this.accentSoft,
    required this.icon,
  });

  final String id;
  final String title;
  final String message;
  final String typeRaw;
  final bool isRead;
  final DateTime? createdAt;
  final String timeLabel;
  final String categoryLabel;
  final NotificationVisualKind kind;
  final Color accent;
  final Color accentSoft;
  final IconData icon;

  NotificationUiModel copyWith({bool? isRead}) {
    return NotificationUiModel(
      id: id,
      title: title,
      message: message,
      typeRaw: typeRaw,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
      timeLabel: timeLabel,
      categoryLabel: categoryLabel,
      kind: kind,
      accent: accent,
      accentSoft: accentSoft,
      icon: icon,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    message,
    typeRaw,
    isRead,
    createdAt,
    timeLabel,
    categoryLabel,
    kind,
  ];
}

class NotificationUiMapper {
  const NotificationUiMapper._();

  static List<NotificationUiModel> toUiList(List<AppNotification> items) {
    final sorted = [...items]
      ..sort((a, b) {
        final at = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bt = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bt.compareTo(at);
      });
    return sorted.map(toUi).toList();
  }

  static NotificationUiModel toUi(AppNotification n) {
    final kind = _kindFor(n);
    final colors = _colorsFor(kind);
    return NotificationUiModel(
      id: n.id,
      title: n.title.trim().isEmpty ? 'Notification' : n.title.trim(),
      message: n.message.trim(),
      typeRaw: n.type,
      isRead: n.isRead,
      createdAt: n.createdAt,
      timeLabel: relativeTime(n.createdAt),
      categoryLabel: _categoryLabel(kind),
      kind: kind,
      accent: colors.$1,
      accentSoft: colors.$2,
      icon: _iconFor(kind, n),
    );
  }

  static NotificationVisualKind _kindFor(AppNotification n) {
    final type = n.type.toLowerCase().trim();
    final title = n.title.toLowerCase();
    final message = n.message.toLowerCase();

    if (type.contains('comp_off') || type.contains('compoff')) {
      return NotificationVisualKind.system;
    }
    if (type.contains('leave')) {
      return NotificationVisualKind.leave;
    }
    if (type.contains('shift') ||
        title.contains('shift') ||
        message.contains('shift')) {
      return NotificationVisualKind.shift;
    }
    if (type.contains('attendance') ||
        title.contains('week off') ||
        message.contains('week off')) {
      return NotificationVisualKind.attendance;
    }
    if (type.contains('general') ||
        type.contains('announce') ||
        title.contains('holiday')) {
      return NotificationVisualKind.announcement;
    }
    return NotificationVisualKind.system;
  }

  static String _categoryLabel(NotificationVisualKind kind) {
    return switch (kind) {
      NotificationVisualKind.system => 'SYSTEM ALERT',
      NotificationVisualKind.leave => 'LEAVE UPDATE',
      NotificationVisualKind.attendance => 'ATTENDANCE RECORD',
      NotificationVisualKind.shift => 'SHIFT UPDATE',
      NotificationVisualKind.announcement => 'GENERAL ANNOUNCEMENT',
    };
  }

  static (Color, Color) _colorsFor(NotificationVisualKind kind) {
    return switch (kind) {
      NotificationVisualKind.system => (
        PortalColors.purple,
        PortalColors.purpleTint,
      ),
      NotificationVisualKind.leave => (
        PortalColors.orange,
        PortalColors.orangeTint,
      ),
      NotificationVisualKind.attendance => (
        PortalColors.green,
        PortalColors.greenTint,
      ),
      NotificationVisualKind.shift => (
        PortalColors.purpleMid,
        PortalColors.purpleTint,
      ),
      NotificationVisualKind.announcement => (
        PortalColors.purpleSoft,
        PortalColors.purpleTint,
      ),
    };
  }

  static IconData _iconFor(NotificationVisualKind kind, AppNotification n) {
    final title = n.title.toLowerCase();
    return switch (kind) {
      NotificationVisualKind.system => Icons.notifications_rounded,
      NotificationVisualKind.leave => Icons.calendar_month_rounded,
      NotificationVisualKind.attendance => Icons.check_circle_rounded,
      NotificationVisualKind.shift => Icons.schedule_rounded,
      NotificationVisualKind.announcement =>
        title.contains('holiday')
            ? Icons.wb_sunny_rounded
            : Icons.campaign_rounded,
    };
  }

  static String relativeTime(DateTime? date) {
    if (date == null) return '';
    final local = date.toLocal();
    final now = DateTime.now();
    final diff = now.difference(local);

    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';

    final yesterday = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(const Duration(days: 1));
    final day = DateTime(local.year, local.month, local.day);
    if (day == yesterday) return 'Yesterday';

    if (diff.inDays < 7) return '${diff.inDays}d ago';
    if (diff.inDays < 30) {
      final weeks = (diff.inDays / 7).floor();
      return weeks <= 1 ? '1w ago' : '${weeks}w ago';
    }

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
    return '${local.day} ${months[local.month - 1]}';
  }

  static String detailTimestamp(DateTime? date) {
    if (date == null) return '—';
    final local = date.toLocal();
    final d = local.day.toString().padLeft(2, '0');
    final m = local.month.toString().padLeft(2, '0');
    final h = local.hour.toString().padLeft(2, '0');
    final min = local.minute.toString().padLeft(2, '0');
    final s = local.second.toString().padLeft(2, '0');
    return '$d/$m/${local.year}, $h:$min:$s';
  }

  static bool matchesFilter(
    NotificationUiModel item,
    NotificationFilter filter,
  ) {
    return switch (filter) {
      NotificationFilter.all => true,
      NotificationFilter.unread => !item.isRead,
      NotificationFilter.leaves => item.kind == NotificationVisualKind.leave,
      NotificationFilter.shifts => item.kind == NotificationVisualKind.shift,
      NotificationFilter.attendance =>
        item.kind == NotificationVisualKind.attendance,
      NotificationFilter.announcements =>
        item.kind == NotificationVisualKind.announcement,
    };
  }
}
