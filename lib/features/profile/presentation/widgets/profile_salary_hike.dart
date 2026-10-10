import 'package:flutter/material.dart';
import 'package:timelay_health/core/theme/portal_colors.dart';
import 'package:timelay_health/core/theme/portal_text.dart';
import 'package:timelay_health/features/auth/domain/entities/employee.dart';

class ProfileSalaryHike extends StatelessWidget {
  const ProfileSalaryHike({super.key, required this.employee});

  final Employee employee;

  @override
  Widget build(BuildContext context) {
    final increments = [...employee.salaryIncrements]
      ..sort((a, b) {
        final aDate = a.effectiveFrom ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bDate = b.effectiveFrom ?? DateTime.fromMillisecondsSinceEpoch(0);
        return aDate.compareTo(bDate);
      });
    final current = employee.salaryPerMonth ?? 0;
    final initial = increments.isEmpty
        ? current
        : increments.first.oldSalaryPerMonth;
    final hike = increments.fold<double>(0, (sum, item) {
      final delta = item.newSalaryPerMonth - item.oldSalaryPerMonth;
      return sum + (delta != 0 ? delta : item.incrementValue);
    });
    final percent = initial == 0 ? 0 : (hike / initial * 100).round();

    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SalaryStatScroller(
            current: current,
            initial: initial,
            hike: hike,
            percent: percent,
            revisions: increments.length,
          ),
          const SizedBox(height: 14),
          _SalaryBreakdown(employee: employee, net: current),
          const SizedBox(height: 14),
          _IncrementHistory(increments: increments),
        ],
      ),
    );
  }
}

class _SalaryStatScroller extends StatelessWidget {
  const _SalaryStatScroller({
    required this.current,
    required this.initial,
    required this.hike,
    required this.percent,
    required this.revisions,
  });

  final double current;
  final double initial;
  final double hike;
  final int percent;
  final int revisions;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 96,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _StatCard(
            label: 'Current Salary',
            value: _money(current, comma: true),
            subtitle: 'per month',
          ),
          const SizedBox(width: 10),
          _StatCard(
            label: 'Initial Salary',
            value: _money(initial, comma: true),
            subtitle: 'starting',
          ),
          const SizedBox(width: 10),
          _StatCard(
            label: 'Total Hike',
            value: _money(hike, comma: true, signed: true),
            subtitle: '$percent%',
            valueColor: PortalColors.green,
          ),
          const SizedBox(width: 10),
          _StatCard(
            label: 'Revisions',
            value: '$revisions',
            subtitle: 'hikes',
            valueColor: PortalColors.green,
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.subtitle,
    this.valueColor = PortalColors.green,
  });

  final String label;
  final String value;
  final String subtitle;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 128,
      padding: const EdgeInsets.fromLTRB(14, 14, 12, 10),
      decoration: BoxDecoration(
        color: PortalColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: PortalColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: portalText(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: PortalColors.muted,
              height: 12 / 10,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: portalText(
              fontSize: 19,
              fontWeight: FontWeight.w700,
              color: valueColor,
              height: 23 / 19,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            subtitle,
            style: portalText(
              fontSize: 9.5,
              color: PortalColors.muted,
              height: 11 / 9.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _SalaryBreakdown extends StatelessWidget {
  const _SalaryBreakdown({required this.employee, required this.net});

  final Employee employee;
  final double net;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: PortalColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: PortalColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '₹ Salary Breakdown',
            style: portalText(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: PortalColors.heading,
              height: 16 / 13.5,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: _Tile('Basic', _money(employee.basicPay))),
              const SizedBox(width: 10),
              Expanded(
                child: _Tile(
                  'HRA',
                  _money(employee.hra),
                  valueWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _Tile(
                  'Conveyance',
                  _money(employee.conveyanceAllowance),
                  valueWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _Tile(
                  'Medical',
                  _money(employee.medicalAllowance),
                  valueWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _Tile(
                  'Performance',
                  _money(employee.performanceAllowance),
                  valueWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _Tile(
                  'Special',
                  _money(employee.specialAllowance),
                  valueWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _Tile(
                  'Deductions',
                  _money(employee.otherDeductions),
                  background: PortalColors.redTint,
                  labelColor: PortalColors.red,
                  valueColor: PortalColors.red,
                  valueWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _Tile(
                  'Net',
                  _money(net, comma: true),
                  background: const Color(0xFFEAF1FD),
                  labelColor: const Color(0xFF3B6FE0),
                  valueColor: const Color(0xFF2547C9),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile(
    this.label,
    this.value, {
    this.background = PortalColors.background,
    this.labelColor = PortalColors.muted,
    this.valueColor = PortalColors.heading,
    this.valueWeight = FontWeight.w700,
  });

  final String label;
  final String value;
  final Color background;
  final Color labelColor;
  final Color valueColor;
  final FontWeight valueWeight;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: portalText(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: labelColor,
              height: 13 / 10.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: portalText(
              fontSize: 15,
              fontWeight: valueWeight,
              color: valueColor,
              height: 18 / 15,
            ),
          ),
        ],
      ),
    );
  }
}

class _IncrementHistory extends StatelessWidget {
  const _IncrementHistory({required this.increments});

  final List<SalaryIncrement> increments;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: PortalColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: PortalColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '📈 Increment History',
            style: portalText(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: PortalColors.heading,
              height: 16 / 13.5,
            ),
          ),
          const SizedBox(height: 10),
          if (increments.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: PortalColors.border),
              ),
              child: Text(
                'No increments yet',
                style: portalText(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: PortalColors.muted,
                  height: 16 / 12,
                ),
              ),
            )
          else
            for (var i = 0; i < increments.length; i++) ...[
              if (i > 0) const SizedBox(height: 10),
              _IncrementCard(index: i + 1, increment: increments[i]),
            ],
        ],
      ),
    );
  }
}

class _IncrementCard extends StatelessWidget {
  const _IncrementCard({required this.index, required this.increment});

  final int index;
  final SalaryIncrement increment;

  @override
  Widget build(BuildContext context) {
    final amountStyle = portalText(
      fontSize: 13,
      fontWeight: FontWeight.w700,
      height: 16 / 13,
    );
    final metaStyle = portalText(
      fontSize: 10.5,
      color: PortalColors.muted,
      height: 13 / 10.5,
    );
    final hike = increment.newSalaryPerMonth - increment.oldSalaryPerMonth;
    final hikeValue = hike != 0 ? hike : increment.incrementValue;
    final isPercent = increment.incrementType.toLowerCase() == 'percent';
    final reason = increment.reason.trim();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: PortalColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '#$index',
                style: portalText(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFB7B5C7),
                  height: 12 / 10,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.fromLTRB(9, 3, 9, 4),
                decoration: BoxDecoration(
                  color: PortalColors.purpleTint,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  isPercent ? '% Increment' : '₹ Increment',
                  style: portalText(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: PortalColors.purple,
                    height: 12 / 10,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          Row(
            children: [
              Text(
                _money(increment.oldSalaryPerMonth),
                style: amountStyle.copyWith(color: PortalColors.muted),
              ),
              const SizedBox(width: 8),
              Text(
                '→',
                style: amountStyle.copyWith(color: const Color(0xFFB7B5C7)),
              ),
              const SizedBox(width: 8),
              Text(
                _money(increment.newSalaryPerMonth),
                style: amountStyle.copyWith(color: PortalColors.green),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                'Value: ${_money(increment.incrementValue)}',
                style: metaStyle,
              ),
              const SizedBox(width: 14),
              Text(
                'Date: ${_hikeDate(increment.effectiveFrom)}',
                style: metaStyle,
              ),
            ],
          ),
          const SizedBox(height: 7),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
            decoration: BoxDecoration(
              color: PortalColors.greenTint,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              '${_money(hikeValue, signed: true)} hike',
              style: portalText(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: PortalColors.green,
                height: 12 / 10,
              ),
            ),
          ),
          if (reason.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              '“$reason”',
              style: metaStyle.copyWith(fontStyle: FontStyle.italic),
            ),
          ],
        ],
      ),
    );
  }
}

String _money(num value, {bool comma = false, bool signed = false}) {
  final rounded = value.round();
  final digits = rounded.abs().toString();
  final formatted = comma
      ? digits.replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]},',
        )
      : digits;
  final sign = rounded < 0 ? '-' : (signed && rounded > 0 ? '+' : '');
  return '$sign₹$formatted';
}

String _hikeDate(DateTime? date) {
  if (date == null) return '—';
  final local = date.toLocal();
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  final day = local.day.toString().padLeft(2, '0');
  return '$day ${months[local.month - 1]} ${local.year}';
}
