import 'package:flutter/material.dart';
import 'package:timelay_health/core/theme/portal_colors.dart';
import 'package:timelay_health/core/theme/portal_text.dart';
import 'package:timelay_health/features/payslips/presentation/models/payslip_ui_model.dart';
import 'package:timelay_health/features/payslips/presentation/utils/payslip_pdf.dart';

Future<void> showSalaryDetailsSheet(
  BuildContext context, {
  required PayslipUiModel payslip,
}) {
  return showDialog<void>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.45),
    builder: (context) => SalaryDetailsSheet(payslip: payslip),
  );
}

class SalaryDetailsSheet extends StatelessWidget {
  const SalaryDetailsSheet({super.key, required this.payslip});

  final PayslipUiModel payslip;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final dialogWidth = (size.width - 32).clamp(300.0, 400.0);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Container(
        width: dialogWidth,
        decoration: BoxDecoration(
          color: PortalColors.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.14),
              blurRadius: 28,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _Header(payslip: payslip),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _NetPayBanner(payslip: payslip),
                  const SizedBox(height: 10),
                  if (payslip.pairs.isNotEmpty)
                    _CompactPairs(pairs: payslip.pairs)
                  else
                    _CompactStats(rows: payslip.detailRows),
                  const SizedBox(height: 10),
                  _MetaStrip(
                    leaves: payslip.approvedLeaves,
                    monthMeta: payslip.monthMeta,
                  ),
                  if (payslip.weeks.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    _WeekChips(weeks: payslip.weeks),
                  ],
                  const SizedBox(height: 10),
                  _CompOffStrip(
                    taken: payslip.compOffTaken,
                    used: payslip.compOffUsed,
                    balance: payslip.compOffBalance,
                  ),
                  if (!payslip.canDownload) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Payslip opens after the 26th. Earlier months anytime.',
                      textAlign: TextAlign.center,
                      style: portalText(
                        fontSize: 10,
                        color: PortalColors.muted,
                        height: 1.3,
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _SheetBtn(
                          label: 'Close',
                          onTap: () => Navigator.of(context).pop(),
                          outlined: true,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 3,
                        child: _SheetBtn(
                          label: 'Download Payslip',
                          onTap: payslip.canDownload
                              ? () =>
                                    downloadOfficialPayslip(context, payslip)
                              : null,
                          enabled: payslip.canDownload,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.payslip});

  final PayslipUiModel payslip;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: PortalColors.brandGradient,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.28)),
            ),
            alignment: Alignment.center,
            child: Text(
              payslip.initials,
              style: portalText(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  payslip.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: portalText(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${payslip.employeeCode}  ·  ${payslip.monthLabel}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: portalText(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.78),
                    height: 1.2,
                  ),
                ),
                Text(
                  '${payslip.department}  ·  ${payslip.designation}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: portalText(
                    fontSize: 10,
                    color: Colors.white.withValues(alpha: 0.62),
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            visualDensity: VisualDensity.compact,
            icon: Icon(
              Icons.close_rounded,
              size: 20,
              color: Colors.white.withValues(alpha: 0.9),
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

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: PortalColors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: PortalColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Net / Final Pay',
                  style: portalText(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: PortalColors.muted,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  finalPay == '₹0' ? payslip.calculatedLabel : finalPay,
                  style: portalText(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: isZero ? PortalColors.red : PortalColors.heading,
                    height: 1.15,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                payslip.salaryLabel,
                style: portalText(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF3D7AFE),
                  height: 1.2,
                ),
              ),
              Text(
                payslip.dailyRateLabel,
                style: portalText(
                  fontSize: 10,
                  color: PortalColors.muted,
                  height: 1.25,
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: payslip.statusBackground,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  payslip.statusLabel,
                  style: portalText(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    color: payslip.statusColor,
                  ),
                ),
              ),
            ],
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
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: PortalColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: PortalColors.border),
          ),
          child: Column(
            children: [
              for (var i = 0; i < tiles.length; i += 3)
                Padding(
                  padding: EdgeInsets.only(bottom: i + 3 < tiles.length ? 6 : 0),
                  child: Row(
                    children: [
                      for (var j = 0; j < 3; j++) ...[
                        if (j > 0) const SizedBox(width: 6),
                        Expanded(
                          child: i + j < tiles.length
                              ? _MiniTile(tiles[i + j])
                              : const SizedBox.shrink(),
                        ),
                      ],
                    ],
                  ),
                ),
            ],
          ),
        ),
        if (highlight != null) ...[
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: PortalColors.greenTint,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: PortalColors.green.withValues(alpha: 0.25),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    highlight.leftLabel,
                    style: portalText(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: PortalColors.heading,
                    ),
                  ),
                ),
                Text(
                  highlight.leftValue,
                  style: portalText(
                    fontSize: 14,
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
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 7),
      decoration: BoxDecoration(
        color: PortalColors.background,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(
            data.value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: portalText(
              fontSize: 12.5,
              fontWeight: FontWeight.w800,
              color: data.color,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            data.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: portalText(
              fontSize: 8.5,
              fontWeight: FontWeight.w600,
              color: PortalColors.muted,
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: PortalColors.border),
      ),
      child: Column(
        children: [
          for (final row in rows)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      row.label,
                      style: portalText(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: PortalColors.muted,
                      ),
                    ),
                  ),
                  Text(
                    row.value,
                    style: portalText(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: row.valueColor,
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
        const SizedBox(width: 8),
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: PortalColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: PortalColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: portalText(
              fontSize: 9.5,
              fontWeight: FontWeight.w600,
              color: PortalColors.muted,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: portalText(
              fontSize: 11.5,
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
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
      decoration: BoxDecoration(
        color: PortalColors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: PortalColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Weekly Attendance',
            style: portalText(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: PortalColors.heading,
            ),
          ),
          const SizedBox(height: 6),
          for (var i = 0; i < weeks.length; i++) ...[
            if (i > 0) const SizedBox(height: 4),
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: PortalColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: PortalColors.border),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 42,
            child: Text(
              week.title.replaceAll('Week ', 'W'),
              style: portalText(
                fontSize: 11,
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
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
                color: PortalColors.secondaryText,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            week.total.replaceAll('Total: ', ''),
            style: portalText(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: PortalColors.heading,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
              color: week.eligible
                  ? PortalColors.greenTint
                  : PortalColors.redTint,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              week.weekOffLabel,
              style: portalText(
                fontSize: 9.5,
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: PortalColors.purpleTint,
        borderRadius: BorderRadius.circular(14),
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
            style: portalText(fontSize: 9, color: PortalColors.muted),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: portalText(
              fontSize: 16,
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
    return GestureDetector(
      onTap: active ? onTap : null,
      child: Container(
        height: 38,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: outlined
              ? Colors.transparent
              : active
              ? PortalColors.brand
              : const Color(0xFFE4E4E4),
          borderRadius: BorderRadius.circular(12),
          border: outlined
              ? Border.all(color: PortalColors.border, width: 1)
              : null,
        ),
        child: Text(
          label,
          style: portalText(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: outlined
                ? PortalColors.heading
                : active
                ? Colors.white
                : const Color(0xFF9A9A9A),
          ),
        ),
      ),
    );
  }
}
