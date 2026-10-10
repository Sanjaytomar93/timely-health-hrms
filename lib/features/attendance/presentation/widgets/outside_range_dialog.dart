import 'package:flutter/material.dart';
import 'package:timelay_health/core/theme/portal_colors.dart';
import 'package:timelay_health/core/theme/portal_text.dart';

const kOutsideRangeReasons = <String>[
  'Field Work',
  'Work From Home',
  'Client Meeting',
  'Other',
];

Future<String?> showOutsideRangeDialog(
  BuildContext context, {
  required int distanceMeters,
}) {
  return showDialog<String>(
    context: context,
    barrierDismissible: false,
    useRootNavigator: true,
    builder: (context) => _OutsideRangeDialog(distanceMeters: distanceMeters),
  );
}

class _OutsideRangeDialog extends StatefulWidget {
  const _OutsideRangeDialog({required this.distanceMeters});
  final int distanceMeters;

  @override
  State<_OutsideRangeDialog> createState() => _OutsideRangeDialogState();
}

class _OutsideRangeDialogState extends State<_OutsideRangeDialog> {
  String? _reason;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 28),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFFFD54F), Color(0xFFFF9800)],
                ),
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.warning_amber_rounded,
                color: Color(0xFF1C1B29),
                size: 34,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Outside Office Range',
              textAlign: TextAlign.center,
              style: portalText(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: PortalColors.heading,
              ),
            ),
            const SizedBox(height: 10),
            Text.rich(
              TextSpan(
                style: portalText(
                  fontSize: 13.5,
                  color: PortalColors.heading,
                  height: 1.35,
                ),
                children: [
                  const TextSpan(text: 'You are '),
                  TextSpan(
                    text: '${widget.distanceMeters}m',
                    style: portalText(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: PortalColors.red,
                    ),
                  ),
                  const TextSpan(text: ' away from the office.'),
                ],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              'Please select a reason for check-in.',
              textAlign: TextAlign.center,
              style: portalText(
                fontSize: 12.5,
                color: PortalColors.secondaryText,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: PortalColors.border),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: _reason,
                  hint: Text(
                    '-- Select Reason --',
                    style: portalText(fontSize: 13, color: PortalColors.muted),
                  ),
                  items: [
                    for (final reason in kOutsideRangeReasons)
                      DropdownMenuItem(
                        value: reason,
                        child: Text(
                          reason,
                          style: portalText(
                            fontSize: 13,
                            color: PortalColors.heading,
                          ),
                        ),
                      ),
                  ],
                  onChanged: (v) => setState(() => _reason = v),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: Material(
                    color: const Color(0xFFF0F0F3),
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      onTap: () => Navigator.pop(context),
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Center(
                          child: Text(
                            'Cancel',
                            style: portalText(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: PortalColors.heading,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Material(
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      onTap: _reason == null
                          ? null
                          : () => Navigator.pop(context, _reason),
                      borderRadius: BorderRadius.circular(12),
                      child: Ink(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: LinearGradient(
                            colors: _reason == null
                                ? const [Color(0xFFCFCFCF), Color(0xFFBDBDBD)]
                                : const [Color(0xFFFFB300), Color(0xFFFF7043)],
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Center(
                            child: Text(
                              'Confirm',
                              style: portalText(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
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
    );
  }
}
