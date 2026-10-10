import 'package:flutter/material.dart';
import 'package:timelay_health/core/theme/portal_colors.dart';
import 'package:timelay_health/core/theme/portal_text.dart';
import 'package:timelay_health/features/expense/presentation/models/expense_claim_ui_model.dart';

Future<void> showExpenseDetailsDialog(
  BuildContext context, {
  required ExpenseClaimUiModel claim,
}) {
  return showDialog<void>(
    context: context,
    barrierColor: const Color(0x70000000),
    builder: (_) => ExpenseDetailsDialog(claim: claim),
  );
}

class ExpenseDetailsDialog extends StatelessWidget {
  const ExpenseDetailsDialog({super.key, required this.claim});

  final ExpenseClaimUiModel claim;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: 405,
          maxHeight: size.height * 0.85,
        ),
        decoration: BoxDecoration(
          color: PortalColors.surface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Expense Details',
                            style: portalText(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: PortalColors.heading,
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () => Navigator.of(context).pop(),
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: const BoxDecoration(
                              color: PortalColors.border,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close, size: 18),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    const Divider(height: 1, color: PortalColors.border),
                    const SizedBox(height: 14),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                claim.purpose,
                                style: portalText(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: PortalColors.heading,
                                  height: 16 / 13,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                claim.dateLabel,
                                style: portalText(
                                  fontSize: 10.5,
                                  color: PortalColors.muted,
                                  height: 13 / 10.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          claim.amountLabel,
                          style: portalText(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: PortalColors.green,
                            height: 18 / 15,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _Section(
                      children: [
                        _KvRow(label: 'Distance', value: claim.kmLabel),
                        const SizedBox(height: 10),
                        _KvRow(label: 'Rate', value: claim.rateLabel),
                        const SizedBox(height: 10),
                        _KvRow(label: 'Stops', value: claim.stopsCountLabel),
                      ],
                    ),
                    if (claim.stops.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      _Section(
                        children: [
                          _SectionTitle('Stops'),
                          const SizedBox(height: 10),
                          for (var i = 0; i < claim.stops.length; i++) ...[
                            if (i > 0) const SizedBox(height: 10),
                            _StopRow(stop: claim.stops[i]),
                          ],
                        ],
                      ),
                    ],
                    if (claim.remark.trim().isNotEmpty) ...[
                      const SizedBox(height: 12),
                      _Section(
                        children: [
                          _SectionTitle('Remark'),
                          const SizedBox(height: 8),
                          Text(
                            claim.remark.trim(),
                            style: portalText(
                              fontSize: 11,
                              color: PortalColors.muted,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(48, 4, 48, 22),
              child: SizedBox(
                width: double.infinity,
                height: 34,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: PortalColors.brand,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Close',
                    style: portalText(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: PortalColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: PortalColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: portalText(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: PortalColors.heading,
      ),
    );
  }
}

class _KvRow extends StatelessWidget {
  const _KvRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: portalText(
            fontSize: 10.5,
            fontWeight: FontWeight.w500,
            color: PortalColors.muted,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: portalText(
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
            color: PortalColors.heading,
          ),
        ),
      ],
    );
  }
}

class _StopRow extends StatelessWidget {
  const _StopRow({required this.stop});

  final ExpenseStopUiModel stop;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.place_outlined, size: 14, color: PortalColors.purple),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                stop.locationName,
                style: portalText(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: PortalColors.heading,
                  height: 14 / 11,
                ),
              ),
              if (stop.outcome.trim().isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  'Outcome: ${stop.outcome.trim()}',
                  style: portalText(
                    fontSize: 10.5,
                    color: PortalColors.muted,
                    height: 13 / 10.5,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          stop.kmLabel,
          style: portalText(
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
            color: PortalColors.heading,
          ),
        ),
      ],
    );
  }
}
