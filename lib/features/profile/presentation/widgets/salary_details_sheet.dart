import 'package:flutter/material.dart';
import 'package:timelay_health/core/theme/portal_colors.dart';
import 'package:timelay_health/core/theme/portal_text.dart';
import 'package:timelay_health/core/widgets/portal_back_button.dart';
import 'package:timelay_health/core/widgets/portal_safe_area.dart';
import 'package:timelay_health/features/holidays/presentation/widgets/top_calendar_button.dart';
import 'package:timelay_health/features/notifications/presentation/widgets/top_notification_button.dart';
import 'package:timelay_health/features/payslips/presentation/models/payslip_ui_model.dart';
import 'package:timelay_health/features/payslips/presentation/utils/payslip_pdf.dart';

Future<void> showSalaryDetailsSheet(
  BuildContext context, {
  required PayslipUiModel payslip,
}) {
  return Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => SalaryDetailsSheet(payslip: payslip),
    ),
  );
}

class SalaryDetailsSheet extends StatelessWidget {
  const SalaryDetailsSheet({super.key, required this.payslip});

  final PayslipUiModel payslip;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: PortalColors.background,
      body: PortalSafeArea(
        bottom: false,
        child: Column(
          children: [
            _AppBar(payslip: payslip),
            Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _EmployeeStrip(payslip: payslip),
                  const SizedBox(height: 12),
                  _NetPayBanner(payslip: payslip),
                  const SizedBox(height: 14),
                  if (payslip.pairs.isNotEmpty)
                    _CompactPairs(pairs: payslip.pairs)
                  else
                    _CompactStats(rows: payslip.detailRows),
                  const SizedBox(height: 12),
                  _MetaStrip(
                    leaves: payslip.approvedLeaves,
                    monthMeta: payslip.monthMeta,
                  ),
                  if (payslip.weeks.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _WeekChips(weeks: payslip.weeks),
                  ],
                  const SizedBox(height: 12),
                  _CompOffStrip(
                    taken: payslip.compOffTaken,
                    used: payslip.compOffUsed,
                    balance: payslip.compOffBalance,
                  ),
                  if (!payslip.canDownload) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: PortalColors.orangeTint,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Payslip opens after the 26th. Earlier months anytime.',
                        textAlign: TextAlign.center,
                        style: portalText(
                          fontSize: 11,
                          color: PortalColors.secondaryText,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + bottomInset),
            decoration: BoxDecoration(
              color: PortalColors.surface,
              border: Border(
                top: BorderSide(
                  color: PortalColors.border.withValues(alpha: 0.9),
                ),
              ),
            ),
            child: _SheetBtn(
              label: 'Download Payslip',
              onTap: payslip.canDownload
                  ? () => downloadOfficialPayslip(context, payslip)
                  : null,
              enabled: payslip.canDownload,
            ),
          ),
          ],
        ),
      ),
    );
  }
}

class _AppBar extends StatelessWidget {
  const _AppBar({required this.payslip});

  final PayslipUiModel payslip;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: PortalColors.surface,
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
      child: Row(
        children: [
          const PortalBackButton(),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Salary Details',
                  style: portalText(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: PortalColors.heading,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  payslip.monthLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: portalText(
                    fontSize: 11,
                    color: PortalColors.muted,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
          const TopNotificationButton(
            asset: 'assets/icons/payslips/ic_notification.svg',
          ),
          const SizedBox(width: 14),
          const TopCalendarButton(
            asset: 'assets/icons/payslips/ic_notification_cal.svg',
          ),
        ],
      ),
    );
  }
}

class _EmployeeStrip extends StatelessWidget {
  const _EmployeeStrip({required this.payslip});

  final PayslipUiModel payslip;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: PortalColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: PortalColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: PortalColors.brandGradient,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              payslip.initials,
              style: portalText(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  payslip.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: portalText(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: PortalColors.heading,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${payslip.employeeCode} · ${payslip.designation}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: portalText(
                    fontSize: 11.5,
                    color: PortalColors.muted,
                    height: 1.2,
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

class _NetPayBanner extends StatelessWidget {
  const _NetPayBanner({required this.payslip});

  final PayslipUiModel payslip;

  @override
  Widget build(BuildContext context) {
    final finalPay = payslip.finalPayLabel;
    final isZero = finalPay == '₹0' || finalPay == '₹0.00';
    final amount = finalPay == '₹0' ? payslip.calculatedLabel : finalPay;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: PortalColors.brandGradient,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Net / Final Pay',
                style: portalText(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withValues(alpha: 0.72),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  payslip.statusLabel,
                  style: portalText(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            amount,
            style: portalText(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: isZero ? PortalColors.redSoft : Colors.white,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _PayMeta(
                  label: 'Gross',
                  value: payslip.salaryLabel,
                ),
              ),
              Container(
                width: 1,
                height: 28,
                color: Colors.white.withValues(alpha: 0.18),
              ),
              Expanded(
                child: _PayMeta(
                  label: 'Daily Rate',
                  value: payslip.dailyRateLabel,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PayMeta extends StatelessWidget {
  const _PayMeta({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: portalText(
              fontSize: 10.5,
              color: Colors.white.withValues(alpha: 0.65),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: portalText(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _CompactPairs extends StatelessWidget {
  const _CompactPairs({required this.pairs});

  final List<SalaryPairUi> pairs;

  @override
  Widget build(BuildContext context) {
    final tiles = <_MiniTileData>[];
    SalaryPairUi? highlight;

    for (final pair in pairs) {
      if (pair.highlight) {
        highlight = pair;
        continue;
      }
      tiles.add(
        _MiniTileData(pair.leftLabel, pair.leftValue, pair.leftColor),
      );
      if (pair.rightLabel.isNotEmpty) {
        tiles.add(
          _MiniTileData(pair.rightLabel, pair.rightValue, pair.rightColor),
        );
      }
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: PortalColors.background,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: PortalColors.border),
          ),
          child: Column(
            children: [
              for (var i = 0; i < tiles.length; i += 2)
                Padding(
                  padding: EdgeInsets.only(bottom: i + 2 < tiles.length ? 8 : 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: _MiniTile(tiles[i]),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: i + 1 < tiles.length
                            ? _MiniTile(tiles[i + 1])
                            : const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        if (highlight != null) ...[
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: PortalColors.greenTint,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: PortalColors.green.withValues(alpha: 0.22),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    highlight.leftLabel,
                    style: portalText(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: PortalColors.heading,
                    ),
                  ),
                ),
                Text(
                  highlight.leftValue,
                  style: portalText(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: highlight.leftColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _MiniTileData {
  const _MiniTileData(this.label, this.value, this.color);
  final String label;
  final String value;
  final Color color;
}

class _MiniTile extends StatelessWidget {
  const _MiniTile(this.data);
  final _MiniTileData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: PortalColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: PortalColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            data.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: portalText(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: PortalColors.muted,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            data.value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: portalText(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: data.color,
              height: 1.15,
            ),
          ),
        ],
      ),
    );
  }
}

class _CompactStats extends StatelessWidget {
  const _CompactStats({required this.rows});

  final List<PayslipDetailRowUiModel> rows;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: PortalColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: PortalColors.border),
      ),
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0)
              Divider(
                height: 1,
                color: PortalColors.border.withValues(alpha: 0.8),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      rows[i].label,
                      style: portalText(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: PortalColors.muted,
                      ),
                    ),
                  ),
                  Text(
                    rows[i].value,
                    style: portalText(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: rows[i].valueColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MetaStrip extends StatelessWidget {
  const _MetaStrip({required this.leaves, required this.monthMeta});

  final String leaves;
  final String monthMeta;

  @override
  Widget build(BuildContext context) {
    final noLeaves = leaves == 'No Leaves';
    return Row(
      children: [
        Expanded(
          child: _InfoChip(
            label: 'Approved Leaves',
            value: leaves,
            valueColor: noLeaves ? PortalColors.muted : PortalColors.red,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _InfoChip(
            label: 'Period',
            value: monthMeta,
            valueColor: PortalColors.heading,
          ),
        ),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.label,
    required this.value,
    required this.valueColor,
  });

  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: PortalColors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: PortalColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: portalText(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: PortalColors.muted,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: portalText(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _WeekChips extends StatelessWidget {
  const _WeekChips({required this.weeks});

  final List<SalaryWeekUi> weeks;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
      decoration: BoxDecoration(
        color: PortalColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: PortalColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Weekly Attendance',
            style: portalText(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: PortalColors.heading,
            ),
          ),
          const SizedBox(height: 10),
          for (var i = 0; i < weeks.length; i++) ...[
            if (i > 0) const SizedBox(height: 6),
            _WeekRow(week: weeks[i]),
          ],
        ],
      ),
    );
  }
}

class _WeekRow extends StatelessWidget {
  const _WeekRow({required this.week});

  final SalaryWeekUi week;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: PortalColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: PortalColors.border),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 36,
            child: Text(
              week.title.replaceAll('Week ', 'W'),
              style: portalText(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: PortalColors.heading,
              ),
            ),
          ),
          Expanded(
            child: Text(
              week.detail,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: portalText(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: PortalColors.secondaryText,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            week.total.replaceAll('Total: ', ''),
            style: portalText(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: PortalColors.heading,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: week.eligible
                  ? PortalColors.greenTint
                  : PortalColors.redTint,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              week.weekOffLabel,
              style: portalText(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: week.eligible ? PortalColors.green : PortalColors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CompOffStrip extends StatelessWidget {
  const _CompOffStrip({
    required this.taken,
    required this.used,
    required this.balance,
  });

  final String taken;
  final String used;
  final String balance;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: PortalColors.brandTint,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          _CompCell('Earned', taken, const Color(0xFF3D7AFE)),
          _CompOp('−'),
          _CompCell('Used', used, PortalColors.heading),
          _CompOp('='),
          _CompCell('Balance', balance, PortalColors.brand),
        ],
      ),
    );
  }
}

class _CompOp extends StatelessWidget {
  const _CompOp(this.op);
  final String op;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Text(
        op,
        style: portalText(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: PortalColors.muted,
        ),
      ),
    );
  }
}

class _CompCell extends StatelessWidget {
  const _CompCell(this.label, this.value, this.color);

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: portalText(fontSize: 10, color: PortalColors.muted),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: portalText(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: color,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}

class _SheetBtn extends StatelessWidget {
  const _SheetBtn({
    required this.label,
    this.onTap,
    this.outlined = false,
    this.enabled = true,
  });

  final String label;
  final VoidCallback? onTap;
  final bool outlined;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final active = enabled && onTap != null;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: active ? onTap : null,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          height: 46,
          decoration: BoxDecoration(
            color: outlined
                ? PortalColors.surface
                : active
                ? PortalColors.brand
                : const Color(0xFFE8E8EE),
            borderRadius: BorderRadius.circular(14),
            border: outlined
                ? Border.all(color: PortalColors.border, width: 1.2)
                : null,
          ),
          child: Center(
            child: Text(
              label,
              style: portalText(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: outlined
                    ? PortalColors.heading
                    : active
                    ? Colors.white
                    : const Color(0xFF9A9A9A),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
