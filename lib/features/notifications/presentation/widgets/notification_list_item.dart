import 'package:flutter/material.dart';
import 'package:timelay_health/core/theme/portal_colors.dart';
import 'package:timelay_health/core/theme/portal_text.dart';
import 'package:timelay_health/features/notifications/presentation/models/notification_ui_model.dart';

class NotificationListItem extends StatelessWidget {
  const NotificationListItem({
    super.key,
    required this.item,
    required this.onTap,
    this.onDelete,
    this.selected = false,
    this.selecting = false,
    this.onToggleSelect,
  });

  final NotificationUiModel item;
  final VoidCallback onTap;
  final VoidCallback? onDelete;
  final bool selected;
  final bool selecting;
  final VoidCallback? onToggleSelect;

  @override
  Widget build(BuildContext context) {
    final unread = !item.isRead;
    final borderColor = selected
        ? PortalColors.purple
        : unread
        ? PortalColors.purple.withValues(alpha: 0.28)
        : PortalColors.border;

    return Material(
      color: selected
          ? PortalColors.purpleTint
          : unread
          ? const Color(0xFFFBF9FF)
          : PortalColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: selecting ? onToggleSelect : onTap,
        onLongPress: onToggleSelect,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 12, 6, 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (selecting)
                Padding(
                  padding: const EdgeInsets.only(right: 8, top: 8),
                  child: Icon(
                    selected
                        ? Icons.check_circle_rounded
                        : Icons.circle_outlined,
                    size: 22,
                    color: selected ? PortalColors.purple : PortalColors.muted,
                  ),
                ),
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: item.accentSoft,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(item.icon, color: item.accent, size: 21),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (unread) ...[
                          Container(
                            width: 7,
                            height: 7,
                            margin: const EdgeInsets.only(top: 5, right: 6),
                            decoration: const BoxDecoration(
                              color: PortalColors.purple,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                        Expanded(
                          child: Text(
                            item.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: portalText(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: PortalColors.heading,
                              height: 1.25,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (item.message.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        item.message,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: portalText(
                          fontSize: 12,
                          color: PortalColors.muted,
                          height: 1.35,
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: item.accentSoft,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            item.categoryLabel,
                            style: portalText(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: item.accent,
                              letterSpacing: 0.3,
                              height: 1.2,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          item.timeLabel,
                          style: portalText(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: PortalColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (!selecting && onDelete != null)
                IconButton(
                  visualDensity: VisualDensity.compact,
                  onPressed: onDelete,
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    color: PortalColors.red,
                    size: 18,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
