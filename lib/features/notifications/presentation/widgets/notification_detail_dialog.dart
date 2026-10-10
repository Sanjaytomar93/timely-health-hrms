import 'package:flutter/material.dart';
import 'package:timelay_health/core/theme/portal_colors.dart';
import 'package:timelay_health/core/theme/portal_text.dart';
import 'package:timelay_health/features/notifications/presentation/models/notification_ui_model.dart';

enum NotificationDetailAction { closed, goToDashboard }

Future<NotificationDetailAction?> showNotificationDetailDialog(
  BuildContext context, {
  required NotificationUiModel item,
}) {
  return showDialog<NotificationDetailAction>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.45),
    builder: (_) => NotificationDetailDialog(item: item),
  );
}

class NotificationDetailDialog extends StatelessWidget {
  const NotificationDetailDialog({super.key, required this.item});

  final NotificationUiModel item;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final dialogWidth = (width - 36).clamp(300.0, 420.0);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
      child: Container(
        width: dialogWidth,
        decoration: BoxDecoration(
          color: PortalColors.surface,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 28,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 14, 10, 14),
              color: PortalColors.background,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: PortalColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: item.accent.withValues(alpha: 0.12),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(item.icon, color: item.accent, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: item.accentSoft,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            item.categoryLabel,
                            style: portalText(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: item.accent,
                              letterSpacing: 0.35,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          NotificationUiMapper.detailTimestamp(item.createdAt),
                          style: portalText(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500,
                            color: PortalColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(
                      context,
                    ).pop(NotificationDetailAction.closed),
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(
                      Icons.close_rounded,
                      size: 20,
                      color: PortalColors.muted,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: PortalColors.border),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: portalText(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: PortalColors.heading,
                      height: 1.3,
                    ),
                  ),
                  if (item.message.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(
                      item.message,
                      style: portalText(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w400,
                        color: PortalColors.secondaryText,
                        height: 1.45,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Divider(height: 1, color: PortalColors.border),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.of(
                      context,
                    ).pop(NotificationDetailAction.closed),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: PortalColors.secondaryText,
                      side: const BorderSide(color: PortalColors.border),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    child: Text(
                      'Close',
                      style: portalText(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: PortalColors.secondaryText,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () => Navigator.of(
                      context,
                    ).pop(NotificationDetailAction.goToDashboard),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: PortalColors.purple,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Go to Dashboard',
                          style: portalText(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.chevron_right_rounded,
                          size: 18,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
