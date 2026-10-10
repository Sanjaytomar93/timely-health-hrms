import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:timelay_health/core/theme/portal_colors.dart';
import 'package:timelay_health/core/theme/portal_text.dart';
import 'package:timelay_health/features/dashboard/presentation/models/dashboard_home_ui.dart';

Future<void> showUpdateDetailDialog(
  BuildContext context, {
  required DashboardUpdateItemUi item,
}) {
  return showDialog<void>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.45),
    builder: (_) => UpdateDetailDialog(item: item),
  );
}

class UpdateDetailDialog extends StatelessWidget {
  const UpdateDetailDialog({super.key, required this.item});

  final DashboardUpdateItemUi item;

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
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
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
              color: const Color(0xFFF5F4FB),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(11),
                      boxShadow: [
                        BoxShadow(
                          color: PortalColors.brand.withValues(alpha: 0.12),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: SvgPicture.asset(
                      'assets/icons/updates/ic_updates_shift.svg',
                      width: 22,
                      height: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: portalText(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                            color: PortalColors.heading,
                            height: 18 / 14.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _kindLabel(item.kind),
                          style: portalText(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: PortalColors.brand,
                            height: 14 / 11.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(
                      Icons.close_rounded,
                      size: 20,
                      color: PortalColors.secondaryText,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  item.subtitle,
                  style: portalText(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: PortalColors.secondaryText,
                    height: 18 / 13,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _kindLabel(String kind) {
    return switch (kind) {
      'shift' => 'Shift update',
      'birthday' => 'Birthday',
      'anniversary' => 'Anniversary',
      'leave' => 'Leave',
      _ => 'Update',
    };
  }
}
