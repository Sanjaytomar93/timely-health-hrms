import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:timelay_health/core/theme/portal_colors.dart';
import 'package:timelay_health/core/theme/portal_text.dart';
import 'package:timelay_health/features/leaves/presentation/models/leave_ui_model.dart';

class LeaveStatsRow extends StatelessWidget {
  const LeaveStatsRow({
    super.key,
    this.stats = LeaveStatsUiModel.empty,
    this.compOffCount,
  });

  final LeaveStatsUiModel stats;
  final int? compOffCount;

  @override
  Widget build(BuildContext context) {
    final items = [
      _Stat(
        label: 'Total',
        value: '${stats.total}',
        subtitle: 'all leaves',
        icon: 'assets/icons/leaves/ic_leave_total.svg',
        valueColor: PortalColors.green,
      ),
      _Stat(
        label: 'Approved',
        value: '${stats.approved}',
        subtitle: 'approved leaves',
        icon: 'assets/icons/leaves/ic_leave_approved.svg',
        valueColor: PortalColors.green,
      ),
      _Stat(
        label: 'Pending',
        value: '${stats.pending}',
        subtitle: 'awaiting approval',
        icon: 'assets/icons/leaves/ic_leave_pending.svg',
        valueColor: PortalColors.green,
      ),
      _Stat(
        label: 'Rejected',
        value: '${stats.rejected}',
        subtitle: 'rejected leaves',
        icon: 'assets/icons/leaves/ic_leave_rejected.svg',
        valueColor: PortalColors.green,
      ),
      _Stat(
        label: 'Comp-off',
        value: '${compOffCount ?? stats.compOff}',
        subtitle: 'comp-off requests',
        icon: 'assets/icons/leaves/ic_leave_compoff.svg',
        valueColor: PortalColors.green,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(18, 0, 18, 4),
        child: Row(
          children: [
            for (var i = 0; i < items.length; i++) ...[
              if (i > 0) const SizedBox(width: 10),
              _StatCard(item: items[i]),
            ],
          ],
        ),
      ),
    );
  }
}

class _Stat {
  const _Stat({
    required this.label,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.valueColor,
  });

  final String label;
  final String value;
  final String subtitle;
  final String icon;
  final Color valueColor;
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.item});

  final _Stat item;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 128,
      padding: const EdgeInsets.fromLTRB(13, 13, 10, 12),
      decoration: BoxDecoration(
        color: PortalColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: PortalColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(item.icon, width: 26, height: 26),
          const SizedBox(height: 10),
          Text(
            item.label.toUpperCase(),
            style: portalText(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: PortalColors.muted,
              letterSpacing: 0.4,
              height: 1.2,
            ),
          ),
          Text(
            item.value,
            style: portalText(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: item.valueColor,
              height: 1.2,
            ),
          ),
          Text(
            item.subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: portalText(
              fontSize: 9.5,
              color: PortalColors.muted,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
