import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:timelay_health/core/theme/portal_colors.dart';
import 'package:timelay_health/core/theme/portal_text.dart';
import 'package:timelay_health/features/dashboard/presentation/widgets/dashboard_card.dart';

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
      padding: const EdgeInsets.fromLTRB(
        kDashboardGutter,
        kDashboardSectionGap + 4,
        kDashboardGutter,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const DashboardSectionTitle('Quick Actions'),
          Container(
            decoration: dashboardCardDecoration(),
            clipBehavior: Clip.antiAlias,
            child: IntrinsicHeight(
              child: Row(
                children: [
                  for (var i = 0; i < actions.length; i++) ...[
                    if (i > 0)
                      const VerticalDivider(
                        width: 1,
                        thickness: 1,
                        indent: 14,
                        endIndent: 14,
                        color: PortalColors.border,
                      ),
                    Expanded(child: _ActionTile(data: actions[i])),
                  ],
                ],
              ),
            ),
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
    this.onTap,
  });

  final String label;
  final String iconAsset;
  final VoidCallback? onTap;
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({required this.data});

  final _QuickActionData data;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: data.onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipOval(
                child: SvgPicture.asset(
                  data.iconAsset,
                  width: 40,
                  height: 40,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                data.label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: portalText(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: PortalColors.secondaryText,
                  height: 15 / 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
