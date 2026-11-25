import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:timelay_health/core/theme/portal_text.dart';
import 'package:timelay_health/features/op/dashboard/presentation/models/op_dashboard_ui.dart';
import 'package:timelay_health/features/op/dashboard/presentation/theme/op_colors.dart';

BoxDecoration _whiteCard({double radius = 24}) => BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: const Color(0xFFE8ECF3)),
      boxShadow: const [
        BoxShadow(
          color: Color(0x0F0F172A),
          blurRadius: 16,
          offset: Offset(0, 4),
        ),
      ],
    );

class OpRevenueBreakdownHeader extends StatefulWidget {
  const OpRevenueBreakdownHeader({
    super.key,
    required this.patientsLabel,
    required this.channels,
    this.onPatientsTap,
  });

  final String patientsLabel;
  final List<OpRevenueChannelUi> channels;
  final VoidCallback? onPatientsTap;

  @override
  State<OpRevenueBreakdownHeader> createState() =>
      _OpRevenueBreakdownHeaderState();
}

class _OpRevenueBreakdownHeaderState extends State<OpRevenueBreakdownHeader> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.all(16),
      decoration: _whiteCard(),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: OpColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.credit_card_rounded,
                  size: 15,
                  color: OpColors.primary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'REVENUE BREAKDOWN',
                      style: portalText(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF0F172A),
                        letterSpacing: 0.25,
                      ),
                    ),
                    Text(
                      '(based on current filters)',
                      style: portalText(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: widget.onPatientsTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF2FF),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE0E7FF)),
                  ),
                  child: Text(
                    widget.patientsLabel,
                    style: portalText(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: OpColors.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: () => setState(() => _expanded = !_expanded),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _expanded ? 'Hide' : 'Show',
                        style: portalText(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF334155),
                        ),
                      ),
                      Icon(
                        _expanded
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.keyboard_arrow_down_rounded,
                        size: 14,
                        color: const Color(0xFF64748B),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (_expanded) ...[
            const SizedBox(height: 12),
            for (var i = 0; i < widget.channels.length; i++) ...[
              if (i > 0) const SizedBox(height: 8),
              _ChannelCard(channel: widget.channels[i]),
            ],
          ],
        ],
      ),
    );
  }
}

class _ChannelCard extends StatelessWidget {
  const _ChannelCard({required this.channel});

  final OpRevenueChannelUi channel;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: channel.bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: channel.isTotal
              ? const Color(0xFFE2E8F0)
              : channel.accent.withValues(alpha: 0.16),
        ),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(channel.icon, size: 16, color: channel.accent),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  channel.title,
                  style: portalText(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: channel.accent,
                    letterSpacing: 0.25,
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'FootFall: ${channel.footfall}',
                    style: portalText(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: channel.accent.withValues(alpha: 0.8),
                    ),
                  ),
                  Text(
                    channel.amount,
                    style: portalText(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: channel.accent,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(height: 1, color: channel.accent.withValues(alpha: 0.12)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (final line in channel.lines)
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '${line.label}: ',
                        style: portalText(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: line.color,
                        ),
                      ),
                      TextSpan(
                        text: line.value,
                        style: portalText(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: line.color,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class OpSummaryCard extends StatelessWidget {
  const OpSummaryCard({super.key, required this.rows});

  final List<OpSummaryRowUi> rows;

  IconData _icon(String label) {
    final l = label.toLowerCase();
    if (l.contains('patient')) return Icons.groups_rounded;
    if (l.contains('collect')) return Icons.verified_rounded;
    if (l.contains('due')) return Icons.error_outline_rounded;
    if (l.contains('review')) return Icons.star_rounded;
    return Icons.card_giftcard_rounded;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.all(16),
      decoration: _whiteCard(),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: OpColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.checklist_rounded,
                  size: 14,
                  color: OpColors.primary,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Summary',
                style: portalText(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF0F172A),
                ),
              ),
              const Spacer(),
              Text(
                'Current filter overview',
                style: portalText(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF94A3B8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          for (final row in rows)
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: row.color.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: row.color.withValues(alpha: 0.14)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: row.color.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: Icon(_icon(row.label), size: 15, color: row.color),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      row.label.toUpperCase(),
                      style: portalText(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF334155),
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                  Text(
                    row.value,
                    style: portalText(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: row.color,
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

class OpPaymentStatusCard extends StatelessWidget {
  const OpPaymentStatusCard({super.key, required this.slices});

  final List<OpSliceUi> slices;

  @override
  Widget build(BuildContext context) {
    final total = slices.fold<int>(0, (s, e) => s + e.count);
    return Container(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.all(16),
      decoration: _whiteCard(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 9,
                          height: 9,
                          decoration: const BoxDecoration(
                            color: Color(0xFF10B981),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Payment Status',
                          style: portalText(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Paid vs Pending breakdown',
                      style: portalText(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$total total',
                  style: portalText(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF475569),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          for (final s in slices) ...[
            Row(
              children: [
                Expanded(
                  child: Text(
                    s.label,
                    style: portalText(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF475569),
                    ),
                  ),
                ),
                Text(
                  '${s.count} (${s.percent.toStringAsFixed(1)}%)',
                  style: portalText(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: s.color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: (s.percent / 100).clamp(0.03, 1),
                minHeight: 8,
                backgroundColor: const Color(0xFFF1F5F9),
                valueColor: AlwaysStoppedAnimation(s.color),
              ),
            ),
            const SizedBox(height: 12),
          ],
          Container(height: 1, color: const Color(0xFFF1F5F9)),
          const SizedBox(height: 12),
          Row(
            children: [
              for (var i = 0; i < slices.length; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Text(
                          slices[i].label.toUpperCase(),
                          style: portalText(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF94A3B8),
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${slices[i].count}',
                          style: portalText(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            color: slices[i].color,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class OpPaymentModeCard extends StatelessWidget {
  const OpPaymentModeCard({super.key, required this.slices});

  final List<OpSliceUi> slices;

  String _short(String label) {
    final l = label.toLowerCase();
    if (l.contains('cash')) return 'Cash';
    if (l.contains('online')) return 'Online';
    if (l.contains('insurance')) return 'Insurance';
    if (l.contains('card')) return 'Card';
    return label;
  }

  @override
  Widget build(BuildContext context) {
    final paidTotal = slices.fold<int>(0, (s, e) => s + e.count);
    return Container(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.all(16),
      decoration: _whiteCard(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 9,
                          height: 9,
                          decoration: const BoxDecoration(
                            color: OpColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Payment Mode (Paid)',
                          style: portalText(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Cash • Online • Insurance • Card',
                      style: portalText(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: OpColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: OpColors.primary.withValues(alpha: 0.18),
                  ),
                ),
                child: Text(
                  '$paidTotal Paid',
                  style: portalText(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: OpColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          for (final s in slices) ...[
            Row(
              children: [
                Expanded(
                  child: Text(
                    s.label,
                    style: portalText(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF475569),
                    ),
                  ),
                ),
                Text(
                  '${s.count} (${s.percent.toStringAsFixed(1)}%)',
                  style: portalText(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: s.color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: math.max(0.03, s.percent / 100),
                minHeight: 7,
                backgroundColor: const Color(0xFFF1F5F9),
                valueColor: AlwaysStoppedAnimation(s.color),
              ),
            ),
            const SizedBox(height: 12),
          ],
          Container(height: 1, color: const Color(0xFFF1F5F9)),
          const SizedBox(height: 12),
          Row(
            children: [
              for (var i = 0; i < slices.length; i++) ...[
                if (i > 0) const SizedBox(width: 6),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 9),
                    decoration: BoxDecoration(
                      color: slices[i].color.withValues(alpha: 0.07),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: slices[i].color.withValues(alpha: 0.12),
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          _short(slices[i].label).toUpperCase(),
                          style: portalText(
                            fontSize: 8,
                            fontWeight: FontWeight.w800,
                            color: slices[i].color.withValues(alpha: 0.75),
                            letterSpacing: 0.2,
                          ),
                        ),
                        Text(
                          '${slices[i].count}',
                          style: portalText(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            color: slices[i].color,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class OpGenderCard extends StatelessWidget {
  const OpGenderCard({
    super.key,
    required this.slices,
    required this.total,
  });

  final List<OpSliceUi> slices;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _whiteCard(),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: const Color(0xFF26204A).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(
                            Icons.person_outline_rounded,
                            size: 13,
                            color: Color(0xFF26204A),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Gender Demographics',
                          style: portalText(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF0F172A),
                            letterSpacing: -0.2,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Patient gender distribution',
                      style: portalText(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '$total tracked',
                  style: portalText(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 112,
                height: 112,
                child: CustomPaint(
                  painter: _DonutPainter(slices: slices),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$total',
                          style: portalText(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF0F172A),
                            height: 1,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'TOTAL',
                          style: portalText(
                            fontSize: 8,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF94A3B8),
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var i = 0; i < slices.length; i++) ...[
                    if (i > 0) const SizedBox(height: 10),
                    _GenderLegendRow(slice: slices[i]),
                  ],
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GenderLegendRow extends StatelessWidget {
  const _GenderLegendRow({required this.slice});

  final OpSliceUi slice;

  @override
  Widget build(BuildContext context) {
    final muted = slice.percent <= 0;
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 12,
          height: 12,
          margin: const EdgeInsets.only(top: 2),
          decoration: BoxDecoration(
            color: slice.color,
            shape: BoxShape.circle,
            boxShadow: muted
                ? null
                : [
                    BoxShadow(
                      color: slice.color.withValues(alpha: 0.35),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
          ),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${slice.label} ${slice.percent.toStringAsFixed(0)}%',
              style: portalText(
                fontSize: 12,
                fontWeight: muted ? FontWeight.w700 : FontWeight.w800,
                color: muted
                    ? const Color(0xFF64748B)
                    : const Color(0xFF1E293B),
              ),
            ),
            Text(
              '${slice.count} patients',
              style: portalText(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class OpTrendWithFooterCard extends StatefulWidget {
  const OpTrendWithFooterCard({
    super.key,
    required this.trend,
    required this.footer,
    required this.fyLabel,
    this.onFyTap,
  });

  final List<OpMonthRevenueUi> trend;
  final List<OpSummaryRowUi> footer;
  final String fyLabel;
  final VoidCallback? onFyTap;

  @override
  State<OpTrendWithFooterCard> createState() => _OpTrendWithFooterCardState();
}

class _OpTrendWithFooterCardState extends State<OpTrendWithFooterCard> {
  String _mode = 'Composed';

  static const clinic = Color(0xFF3B82F6);
  static const lab = Color(0xFF8B5CF6);
  static const pharmacy = Color(0xFF10B981);
  static const _modes = ['Composed', 'Area', 'Bar', 'Line'];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _whiteCard(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: OpColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(
                            Icons.trending_up_rounded,
                            size: 12,
                            color: OpColors.primary,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Financial Year Trend (2026)',
                          style: portalText(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Month-by-month (Apr-Mar) breakdown of Clinic, Lab & Pharmacy Revenue',
                      style: portalText(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: widget.onFyTap,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: OpColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: OpColors.primary.withValues(alpha: 0.18),
                    ),
                  ),
                  child: Text(
                    widget.fyLabel,
                    style: portalText(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: OpColors.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const _Dot(color: clinic, label: 'Clinic'),
              const SizedBox(width: 10),
              const _Dot(color: lab, label: 'Lab'),
              const SizedBox(width: 10),
              const _Dot(color: pharmacy, label: 'Pharmacy'),
            ],
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final m in _modes)
                    _ChartToggle(
                      label: m,
                      selected: _mode == m,
                      onTap: () => setState(() => _mode = m),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 184,
            child: Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: _MiniTrendPainter(
                      items: widget.trend,
                      mode: _mode,
                    ),
                  ),
                ),
                Align(
                  alignment: const Alignment(0.18, -0.92),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF26204A),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0x66C084FC),
                      ),
                    ),
                    child: Text(
                      'Peak: ₹3.8L',
                      style: portalText(
                        fontSize: 8,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              for (var i = 0; i < widget.footer.length; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: widget.footer[i].color.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: widget.footer[i].color.withValues(alpha: 0.14),
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          widget.footer[i].label.toUpperCase(),
                          textAlign: TextAlign.center,
                          style: portalText(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF64748B),
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          widget.footer[i].value,
                          textAlign: TextAlign.center,
                          style: portalText(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            color: widget.footer[i].color,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _ChartToggle extends StatelessWidget {
  const _ChartToggle({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF2563EB) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: portalText(
            fontSize: 9,
            fontWeight: FontWeight.w800,
            color: selected ? Colors.white : const Color(0xFF334155),
          ),
        ),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: portalText(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF475569),
          ),
        ),
      ],
    );
  }
}

class _DonutPainter extends CustomPainter {
  const _DonutPainter({required this.slices});

  final List<OpSliceUi> slices;

  @override
  void paint(Canvas canvas, Size size) {
    final total = slices.fold<int>(0, (s, e) => s + e.count);
    final center = Offset(size.width / 2, size.height / 2);
    final stroke = size.shortestSide * 0.125;
    final radius = (size.shortestSide - stroke) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    canvas.drawArc(
      rect,
      0,
      math.pi * 2,
      false,
      Paint()
        ..color = const Color(0xFFF1F5F9)
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke,
    );

    if (total <= 0) return;

    final active = slices.where((s) => s.count > 0).toList()
      ..sort((a, b) => a.count.compareTo(b.count));

    for (final s in active) {
      var start = -math.pi / 2;
      for (final prev in slices) {
        if (identical(prev, s)) break;
        if (prev.count <= 0) continue;
        start += (prev.count / total) * math.pi * 2;
      }
      final sweep = (s.count / total) * math.pi * 2;
      canvas.drawArc(
        rect,
        start,
        sweep,
        false,
        Paint()
          ..color = s.color
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) =>
      oldDelegate.slices != slices;
}

class _MiniTrendPainter extends CustomPainter {
  const _MiniTrendPainter({required this.items, this.mode = 'Composed'});

  final List<OpMonthRevenueUi> items;
  final String mode;
  static const axisMax = 260000.0;
  static const _yLabels = ['₹2.6L', '₹1.9L', '₹1.3L', '₹65k', '0'];
  static const _colors = [Color(0xFF3B82F6), Color(0xFF8B5CF6), Color(0xFF10B981)];

  @override
  void paint(Canvas canvas, Size size) {
    if (items.isEmpty) return;
    const labelH = 18.0;
    const leftPad = 32.0;
    final chartH = size.height - labelH;
    final chartW = size.width - leftPad;
    final groupW = chartW / items.length;

    for (var i = 0; i <= 4; i++) {
      final y = chartH * i / 4;
      final dash = Paint()
        ..color = const Color(0xFFE2E8F0)
        ..strokeWidth = 1;
      var x = leftPad;
      while (x < size.width) {
        canvas.drawLine(
          Offset(x, y),
          Offset(math.min(x + 4, size.width), y),
          dash,
        );
        x += 7;
      }
      final tp = TextPainter(
        text: TextSpan(
          text: _yLabels[i],
          style: const TextStyle(
            fontSize: 9,
            color: Color(0xFF475569),
            fontWeight: FontWeight.w700,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(0, y - tp.height / 2));
    }

    final useLine = mode == 'Line' || mode == 'Area';
    final useArea = mode == 'Area';
    final composed = mode == 'Composed';

    if (useLine) {
      for (var s = 0; s < 3; s++) {
        final path = Path();
        var started = false;
        for (var i = 0; i < items.length; i++) {
          final values = [items[i].opd, items[i].lab, items[i].pharmacy];
          final v = values[s];
          final cx = leftPad + groupW * i + groupW / 2;
          final y = chartH - (v <= 0 ? 0.0 : (v / axisMax) * (chartH - 4));
          if (!started) {
            path.moveTo(cx, y);
            started = true;
          } else {
            path.lineTo(cx, y);
          }
        }
        if (useArea) {
          final fill = Path.from(path)
            ..lineTo(leftPad + groupW * (items.length - 1) + groupW / 2, chartH)
            ..lineTo(leftPad + groupW / 2, chartH)
            ..close();
          canvas.drawPath(
            fill,
            Paint()
              ..color = _colors[s].withValues(alpha: 0.18)
              ..style = PaintingStyle.fill,
          );
        }
        canvas.drawPath(
          path,
          Paint()
            ..color = _colors[s]
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2
            ..strokeCap = StrokeCap.round
            ..strokeJoin = StrokeJoin.round,
        );
      }
    } else {
      final barW = composed ? 4.5 : 6.0;
      for (var i = 0; i < items.length; i++) {
        final item = items[i];
        final cx = leftPad + groupW * i + groupW / 2;
        final values = [item.opd, item.lab, item.pharmacy];
        final startX = cx - (3 * barW + 2) / 2;
        for (var b = 0; b < 3; b++) {
          final h =
              values[b] <= 0 ? 0.0 : (values[b] / axisMax) * (chartH - 4);
          if (h <= 0) continue;
          final left = startX + b * (barW + 1);
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTWH(left, chartH - h, barW, h),
              const Radius.circular(2),
            ),
            Paint()..color = _colors[b].withValues(alpha: composed ? 0.9 : 1),
          );
        }
      }
    }

    for (var i = 0; i < items.length; i++) {
      final cx = leftPad + groupW * i + groupW / 2;
      final tp = TextPainter(
        text: TextSpan(
          text: items[i].label,
          style: TextStyle(
            fontSize: 9,
            fontWeight:
                items[i].label == 'Oct' ? FontWeight.w800 : FontWeight.w500,
            color: items[i].label == 'Oct'
                ? const Color(0xFF26204A)
                : const Color(0xFF94A3B8),
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(cx - tp.width / 2, chartH + 4));
    }
  }

  @override
  bool shouldRepaint(covariant _MiniTrendPainter oldDelegate) =>
      oldDelegate.items != items || oldDelegate.mode != mode;
}
