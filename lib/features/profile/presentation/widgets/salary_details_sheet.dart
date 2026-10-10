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
    barrierColor: const Color(0x70000000),
    builder: (context) => SalaryDetailsSheet(payslip: payslip),
  );
}

class SalaryDetailsSheet extends StatelessWidget {
  const SalaryDetailsSheet({super.key, required this.payslip});

  final PayslipUiModel payslip;

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.sizeOf(context).height * 0.88;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 28),
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(maxWidth: 405, maxHeight: maxHeight),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 24, 18, 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Salary Details - ${payslip.name}',
                          style: portalText(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: PortalColors.heading,
                            height: 16 / 13.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          payslip.monthLabel,
                          style: portalText(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: PortalColors.muted,
                            height: 12 / 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: PortalColors.border,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.close, size: 20),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _ProfileCard(payslip: payslip),
              const SizedBox(height: 14),
              if (payslip.pairs.isNotEmpty)
                _PairsCard(pairs: payslip.pairs)
              else
                _StatsCard(rows: payslip.detailRows),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Approved Leaves',
                      style: portalText(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: PortalColors.heading,
                        height: 15 / 12,
                      ),
                    ),
                  ),
                  Text(
                    payslip.approvedLeaves,
                    style: portalText(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: payslip.approvedLeaves == 'No Leaves'
                          ? PortalColors.muted
                          : PortalColors.red,
                      height: 15 / 12,
                    ),
                  ),
                ],
              ),
              if (payslip.weeks.isNotEmpty) ...[
                const SizedBox(height: 14),
                _WeeklyCard(weeks: payslip.weeks),
              ],
              const SizedBox(height: 14),
              _CompOffCard(
                month: payslip.monthLabel,
                taken: payslip.compOffTaken,
                used: payslip.compOffUsed,
                balance: payslip.compOffBalance,
              ),
              const SizedBox(height: 16),
              const Divider(
                height: 1,
                thickness: 0.5,
                color: PortalColors.border,
              ),
              const SizedBox(height: 12),
              if (!payslip.canDownload)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(
                    'This month’s payslip opens after the 26th. Earlier months can be downloaded anytime.',
                    style: portalText(
                      fontSize: 11,
                      color: PortalColors.muted,
                      height: 1.35,
                    ),
                  ),
                ),
              Row(
                children: [
                  Expanded(
                    flex: 118,
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        height: 32,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: PortalColors.muted,
                            width: 0.5,
                          ),
                        ),
                        child: Text(
                          'Close',
                          style: portalText(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: PortalColors.heading,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 25),
                  Expanded(
                    flex: 177,
                    child: GestureDetector(
                      onTap: payslip.canDownload
                          ? () => downloadOfficialPayslip(context, payslip)
                          : null,
                      child: Container(
                        height: 32,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: payslip.canDownload
                              ? const Color(0xFF175CD2)
                              : const Color(0xFFE4E4E4),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Download Payslip',
                          style: portalText(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: payslip.canDownload
                                ? Colors.white
                                : const Color(0xFF9A9A9A),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.payslip});

  final PayslipUiModel payslip;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: PortalColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF26204A), Color(0xFF4B4285)],
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  payslip.initials,
                  style: portalText(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 18 / 15,
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
                      style: portalText(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w700,
                        color: PortalColors.heading,
                        height: 19 / 15.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Emp ID: ${payslip.employeeCode}',
                      style: portalText(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                        color: PortalColors.muted,
                        height: 14 / 11.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.only(left: 58),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Department: ${payslip.department}',
                  style: portalText(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                    color: PortalColors.heading,
                    height: 14 / 11.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Role: ${payslip.designation}',
                  style: portalText(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                    color: PortalColors.heading,
                    height: 14 / 11.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  payslip.monthMeta,
                  style: portalText(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w400,
                    color: PortalColors.muted,
                    height: 14 / 11.5,
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

class _StatsCard extends StatelessWidget {
  const _StatsCard({required this.rows});

  final List<PayslipDetailRowUiModel> rows;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: PortalColors.border),
      ),
      child: Column(children: [for (final row in rows) _StatRow(data: row)]),
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({required this.data});

  final PayslipDetailRowUiModel data;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: data.topBorder
          ? const BoxDecoration(
              border: Border(top: BorderSide(color: PortalColors.border)),
            )
          : null,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              data.label,
              style: portalText(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: PortalColors.muted,
                height: 15 / 12,
              ),
            ),
          ),
          Text(
            data.value,
            style: portalText(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: data.valueColor,
              height: 15 / 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _PairsCard extends StatelessWidget {
  const _PairsCard({required this.pairs});

  final List<SalaryPairUi> pairs;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: PortalColors.border),
      ),
      child: Column(
        children: [
          for (final pair in pairs)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: pair.highlight
                    ? const Color(0xFFF3FBF6)
                    : Colors.transparent,
                border: const Border(
                  bottom: BorderSide(color: PortalColors.border),
                ),
              ),
              child: pair.highlight
                  ? Row(
                      children: [
                        Expanded(
                          child: Text(
                            pair.leftLabel,
                            style: portalText(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: PortalColors.heading,
                            ),
                          ),
                        ),
                        Text(
                          pair.leftValue,
                          style: portalText(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: pair.leftColor,
                          ),
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        Expanded(
                          child: _PairCell(
                            pair.leftLabel,
                            pair.leftValue,
                            pair.leftColor,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _PairCell(
                            pair.rightLabel,
                            pair.rightValue,
                            pair.rightColor,
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

class _PairCell extends StatelessWidget {
  const _PairCell(this.label, this.value, this.color);

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: portalText(
            fontSize: 10.5,
            color: PortalColors.muted,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: portalText(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: color,
            height: 1.2,
          ),
        ),
      ],
    );
  }
}

class _WeeklyCard extends StatelessWidget {
  const _WeeklyCard({required this.weeks});

  final List<SalaryWeekUi> weeks;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: PortalColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Weekly Attendance Breakdown',
            style: portalText(
              fontSize: 12.5,
              fontWeight: FontWeight.w800,
              color: PortalColors.heading,
            ),
          ),
          const SizedBox(height: 8),
          for (final week in weeks)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  SizedBox(
                    width: 58,
                    child: Text(
                      week.title,
                      style: portalText(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: PortalColors.heading,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      week.detail,
                      style: portalText(
                        fontSize: 11,
                        color: PortalColors.muted,
                      ),
                    ),
                  ),
                  Text(
                    week.total,
                    style: portalText(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: PortalColors.heading,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    week.weekOffLabel,
                    style: portalText(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: week.eligible
                          ? PortalColors.green
                          : PortalColors.red,
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

class _CompOffCard extends StatelessWidget {
  const _CompOffCard({
    required this.month,
    required this.taken,
    required this.used,
    required this.balance,
  });

  final String month;
  final String taken;
  final String used;
  final String balance;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F0FF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            'Comp-off Summary - $month',
            textAlign: TextAlign.center,
            style: portalText(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF26204A),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _CompValue('Earned', taken, const Color(0xFF3D7AFE)),
              Text(
                '−',
                style: portalText(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: PortalColors.muted,
                ),
              ),
              _CompValue('Comp-off Used', used, const Color(0xFF26204A)),
              Text(
                '=',
                style: portalText(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: PortalColors.muted,
                ),
              ),
              _CompValue('Balance', balance, const Color(0xFF26204A)),
            ],
          ),
        ],
      ),
    );
  }
}

class _CompValue extends StatelessWidget {
  const _CompValue(this.label, this.value, this.color);

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
            textAlign: TextAlign.center,
            style: portalText(fontSize: 10, color: PortalColors.muted),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: portalText(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
