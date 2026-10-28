import 'package:flutter/material.dart';
import 'package:timelay_health/core/theme/portal_colors.dart';
import 'package:timelay_health/core/theme/portal_text.dart';
import 'package:timelay_health/features/leaves/presentation/models/leave_ui_model.dart';

class LeaveBalanceGrid extends StatelessWidget {
  const LeaveBalanceGrid({super.key, this.stats = LeaveStatsUiModel.empty});

  final LeaveStatsUiModel stats;

  @override
  Widget build(BuildContext context) {
    final cards = [
      _Balance(
        title: 'Casual Leave',
        used: stats.casual,
        total: 12,
        showNational: true,
      ),
      _Balance(
        title: 'Sick Leaves',
        used: stats.sick,
        total: 10,
        showNational: true,
      ),
      _Balance(
        title: 'Earned Leave',
        used: stats.earned,
        total: 15,
        showNational: false,
      ),
      const _Balance(
        title: 'Public Holidays',
        used: 5,
        total: 5,
        showNational: true,
        fillColor: PortalColors.orange,
        hideTotal: true,
      ),
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _BalanceCard(data: cards[0])),
              const SizedBox(width: 12),
              Expanded(child: _BalanceCard(data: cards[1])),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _BalanceCard(data: cards[2])),
              const SizedBox(width: 12),
              Expanded(child: _BalanceCard(data: cards[3])),
            ],
          ),
        ],
      ),
    );
  }
}

class _Balance {
  const _Balance({
    required this.title,
    required this.used,
    required this.total,
    required this.showNational,
    this.fillColor,
    this.hideTotal = false,
  });

  final String title;
  final int used;
  final int total;
  final bool showNational;
  final Color? fillColor;
  final bool hideTotal;
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({required this.data});

  final _Balance data;

  @override
  Widget build(BuildContext context) {
    final progress = data.total == 0 ? 0.0 : data.used / data.total;

    return Container(
      padding: const EdgeInsets.fromLTRB(15, 15, 15, 14),
      decoration: BoxDecoration(
        color: PortalColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: PortalColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            data.title,
            style: portalText(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: PortalColors.secondaryText,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${data.used}',
                style: portalText(
                  fontSize: 21,
                  fontWeight: FontWeight.w700,
                  color: PortalColors.heading,
                  height: 1.1,
                ),
              ),
              if (!data.hideTotal) ...[
                const SizedBox(width: 4),
                Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Text(
                    '/ ${data.total}',
                    style: portalText(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: PortalColors.muted,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 6,
              backgroundColor: PortalColors.border,
              color: data.fillColor ?? PortalColors.border,
            ),
          ),
          if (data.showNational) ...[
            const SizedBox(height: 8),
            Text(
              '0 National',
              style: portalText(fontSize: 10, color: PortalColors.muted),
            ),
          ] else
            const SizedBox(height: 18),
        ],
      ),
    );
  }
}
