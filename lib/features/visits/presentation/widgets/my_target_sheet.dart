import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:timelay_health/core/theme/portal_colors.dart';
import 'package:timelay_health/core/theme/portal_text.dart';
import 'package:timelay_health/features/visits/presentation/bloc/visits_cubit.dart';
import 'package:timelay_health/features/visits/presentation/models/visit_ui_model.dart';

Future<void> showMyTargetSheet(BuildContext context) {
  final cubit = context.read<VisitsCubit>();
  final state = cubit.state;
  final nowLabel = VisitUiMapper.monthLabel(DateTime.now()) ?? 'All Months';

  String monthLabel;
  if (state.month != 'All Months') {
    monthLabel = state.month;
  } else {
    final currentStats = cubit.statsForMonth(nowLabel);
    if (currentStats.total > 0) {
      monthLabel = nowLabel;
    } else {
      final options = state.monthOptions
          .where((m) => m != 'All Months')
          .toList();
      monthLabel = options.isNotEmpty ? options.first : nowLabel;
    }
  }

  final stats = cubit.statsForMonth(monthLabel);

  return showDialog<void>(
    context: context,
    barrierColor: const Color(0x70000000),
    builder: (context) => MyTargetSheet(monthLabel: monthLabel, stats: stats),
  );
}

class MyTargetSheet extends StatelessWidget {
  const MyTargetSheet({
    super.key,
    required this.monthLabel,
    required this.stats,
  });

  final String monthLabel;
  final VisitStatsUiModel stats;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final maxHeight = media.size.height - media.padding.vertical - 24;
    final target = stats.total;
    final completed = stats.total;
    final remaining = (target - completed).clamp(0, target);
    final progress = target == 0 ? 0.0 : completed / target;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Container(
        constraints: BoxConstraints(maxWidth: 405, maxHeight: maxHeight),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _TargetHeader(monthLabel: monthLabel),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 18, 10, 22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _MonthlyTargetCard(target: target),
                      const SizedBox(height: 22),
                      _ProgressSection(
                        completed: completed,
                        target: target,
                        remaining: remaining,
                        progress: progress,
                      ),
                      const SizedBox(height: 18),
                      _StatsGrid(stats: stats),
                      const SizedBox(height: 16),
                      _DataShownBar(monthLabel: monthLabel),
                      const SizedBox(height: 22),
                      Center(
                        child: GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          behavior: HitTestBehavior.opaque,
                          child: Container(
                            width: 140,
                            height: 36,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: PortalColors.brandGradient,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: PortalColors.brand.withValues(
                                    alpha: 0.25,
                                  ),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Text(
                              'Close',
                              style: portalText(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                height: 13 / 11,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TargetHeader extends StatelessWidget {
  const _TargetHeader({required this.monthLabel});

  final String monthLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment(-0.45, -0.9),
          end: Alignment(0.9, 0.75),
          colors: PortalColors.brandGradient,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0x33E9E7F2),
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: SvgPicture.asset(
              'assets/icons/visits/target/ic_target_white.svg',
              width: 22,
              height: 22,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'My Target',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: portalText(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 14 / 11.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  monthLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: portalText(
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                    height: 12 / 10,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset(
                    'assets/icons/visits/target/ic_calendar_white.svg',
                    width: 14,
                    height: 14,
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      monthLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: portalText(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        height: 14 / 11,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0x33E9E7F2),
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: const Icon(Icons.close, size: 20, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _MonthlyTargetCard extends StatelessWidget {
  const _MonthlyTargetCard({required this.target});

  final int target;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 120),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [PortalColors.brandLight, PortalColors.brand],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: PortalColors.brand.withValues(alpha: 0.22),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            right: -24,
            bottom: -34,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.06),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            right: 28,
            top: 32,
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.14),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
              ),
              alignment: Alignment.center,
              child: SvgPicture.asset(
                'assets/icons/visits/target/ic_target_white.svg',
                width: 27,
                height: 27,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'MONTHLY TARGET',
                  style: portalText(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Colors.white.withValues(alpha: 0.8),
                    letterSpacing: 1,
                    height: 12 / 10,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '$target',
                  style: portalText(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 39 / 32,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Visits this month',
                  style: portalText(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.8),
                    height: 12 / 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressSection extends StatelessWidget {
  const _ProgressSection({
    required this.completed,
    required this.target,
    required this.remaining,
    required this.progress,
  });

  final int completed;
  final int target;
  final int remaining;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final progressText = target == 0
        ? 'No visits yet'
        : remaining == 0
        ? 'Target reached'
        : '$remaining more visits to reach target';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                'Progress',
                style: portalText(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                  height: 12 / 10,
                ),
              ),
              const Spacer(),
              Text(
                '$completed/$target Visits',
                style: portalText(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                  height: 12 / 10,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: Container(
              height: 10,
              color: PortalColors.brandTint,
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: progress.clamp(0.0, 1.0),
                heightFactor: 1,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [PortalColors.brandLight, PortalColors.green],
                    ),
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              progressText,
              style: portalText(
                fontSize: 10,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF7A7777),
                height: 12 / 10,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.stats});

  final VisitStatsUiModel stats;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _StatTile(
                bg: const Color(0xFFF0F6FF),
                iconBg: const Color(0xFFDBE9FE),
                iconAsset: 'assets/icons/visits/target/ic_location.svg',
                value: '${stats.total}',
                valueColor: const Color(0xFF1F3A89),
                label: 'Total Visits',
                labelColor: const Color(0xFF3C82F5),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatTile(
                bg: const Color(0xFFF1FDF4),
                iconBg: const Color(0xFFCEFFE0),
                iconAsset: 'assets/icons/visits/target/ic_leads.svg',
                value: '${stats.leads}',
                valueColor: const Color(0xFF15522E),
                label: 'Leads',
                labelColor: const Color(0xFF1FA971),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _StatTile(
                bg: const Color(0xFFFFF2F2),
                iconBg: const Color(0xFFFFE1E1),
                iconAsset: 'assets/icons/visits/target/ic_rejected.svg',
                value: '${stats.rejected}',
                valueColor: const Color(0xFF7E1E1D),
                label: 'Rejected',
                labelColor: const Color(0xFFE0483E),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatTile(
                bg: const Color(0xFFFFFBEA),
                iconBg: const Color(0xFFFEF4C6),
                iconAsset: 'assets/icons/visits/target/ic_pending.svg',
                value: '${stats.pending}',
                valueColor: const Color(0xFF78350F),
                label: 'Pending',
                labelColor: const Color(0xFFD87708),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.bg,
    required this.iconBg,
    required this.iconAsset,
    required this.value,
    required this.valueColor,
    required this.label,
    required this.labelColor,
  });

  final Color bg;
  final Color iconBg;
  final String iconAsset;
  final String value;
  final Color valueColor;
  final String label;
  final Color labelColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 52),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: labelColor.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: SvgPicture.asset(iconAsset, width: 18, height: 18),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: portalText(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: valueColor,
                    height: 24 / 20,
                  ),
                ),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: portalText(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: labelColor,
                    height: 12 / 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DataShownBar extends StatelessWidget {
  const _DataShownBar({required this.monthLabel});

  final String monthLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 41),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFC),
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            'assets/icons/visits/target/ic_calendar.svg',
            width: 15,
            height: 15,
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              'Data Shown for $monthLabel',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: portalText(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: PortalColors.muted,
                height: 12 / 10,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
