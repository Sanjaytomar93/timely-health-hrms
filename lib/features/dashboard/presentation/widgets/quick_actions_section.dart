import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:timelay_health/core/theme/portal_colors.dart';
import 'package:timelay_health/core/theme/portal_text.dart';
import 'package:timelay_health/features/attendance/presentation/widgets/check_in_sheet.dart';

class QuickActionsSection extends StatelessWidget {
  const QuickActionsSection({
    super.key,
    this.onHistory,
    this.onLeaves,
    this.onPermission,
  });

  final VoidCallback? onHistory;
  final VoidCallback? onLeaves;
  final VoidCallback? onPermission;

  @override
  Widget build(BuildContext context) {
    final actions = <_QuickActionData>[
      const _QuickActionData(
        label: 'Mark\nAttendance',
        iconAsset: 'assets/icons/quick_actions/ic_qa_mark_attendance.svg',
        opensCheckIn: true,
      ),
      _QuickActionData(
        label: 'History',
        iconAsset: 'assets/icons/quick_actions/ic_qa_history.svg',
        onTap: onHistory,
      ),
      _QuickActionData(
        label: 'Permission',
        iconAsset: 'assets/icons/quick_actions/ic_qa_permission.svg',
        onTap: onPermission,
      ),
      _QuickActionData(
        label: 'Leaves',
        iconAsset: 'assets/icons/quick_actions/ic_qa_leaves.svg',
        onTap: onLeaves,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 2),
            child: Text(
              'Quick Actions',
              style: portalText(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: PortalColors.heading,
                height: 17 / 14,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              for (var i = 0; i < actions.length; i++) ...[
                if (i > 0) const SizedBox(width: 10),
                Expanded(child: _ActionTile(data: actions[i])),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickActionData {
  const _QuickActionData({
    required this.label,
    required this.iconAsset,
    this.opensCheckIn = false,
    this.onTap,
  });

  final String label;
  final String iconAsset;
  final bool opensCheckIn;
  final VoidCallback? onTap;
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({required this.data});

  final _QuickActionData data;

  @override
  Widget build(BuildContext context) {
    final VoidCallback? tap = data.opensCheckIn
        ? () => showCheckInSheet(context)
        : data.onTap;

    return Material(
      color: PortalColors.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: tap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: 74,
          padding: const EdgeInsets.fromLTRB(4, 10, 4, 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: PortalColors.border),
          ),
          child: Column(
            children: [
              SvgPicture.asset(data.iconAsset, width: 28, height: 28),
              const SizedBox(height: 5),
              Expanded(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Text(
                    data.label,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: portalText(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: PortalColors.secondaryText,
                      height: 12 / 10,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
