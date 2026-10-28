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

  static const double _sidePad = 18;
  static const double _gap = 8;
  static const int _visibleCount = 3;

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
        valueColor: PortalColors.orange,
      ),
      _Stat(
        label: 'Rejected',
        value: '${stats.rejected}',
        subtitle: 'rejected leaves',
        icon: 'assets/icons/leaves/ic_leave_rejected.svg',
        valueColor: PortalColors.red,
      ),
      _Stat(
        label: 'Comp-off',
        value: '${compOffCount ?? stats.compOff}',
        subtitle: 'comp-off requests',
        icon: 'assets/icons/leaves/ic_leave_compoff.svg',
        valueColor: PortalColors.green,
      ),
    ];

    final screenWidth = MediaQuery.sizeOf(context).width;
    final cardWidth =
        (screenWidth - (_sidePad * 2) - (_gap * (_visibleCount - 1))) /
        _visibleCount;

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(_sidePad, 0, _sidePad, 2),
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: [
            for (var i = 0; i < items.length; i++) ...[
              if (i > 0) const SizedBox(width: _gap),
              SizedBox(
                width: cardWidth,
                child: _StatCard(item: items[i]),
              ),
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
      padding: const EdgeInsets.fromLTRB(11, 10, 9, 9),
      decoration: BoxDecoration(
        color: PortalColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: PortalColors.border),
        boxShadow: [
          BoxShadow(
            color: PortalColors.brand.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(item.icon, width: 22, height: 22),
          const SizedBox(height: 8),
          Text(
            item.label.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: portalText(
              fontSize: 8.5,
              fontWeight: FontWeight.w700,
              color: PortalColors.muted,
              letterSpacing: 0.35,
              height: 1.2,
            ),
          ),
          Text(
            item.value,
            style: portalText(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: item.valueColor,
              height: 1.2,
            ),
          ),
          Text(
            item.subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: portalText(
              fontSize: 9,
              color: PortalColors.muted,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
