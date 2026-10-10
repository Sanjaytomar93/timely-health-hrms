import 'package:flutter/material.dart';
import 'package:timelay_health/core/theme/portal_text.dart';

class OtInfoBox extends StatelessWidget {
  const OtInfoBox({super.key});

  static const _bg = Color(0xFFEAF1FD);
  static const _border = Color(0xFFD7E5FB);
  static const _labelBlue = Color(0xFF3B6FE0);
  static const _body = Color(0xFF47455C);
  static const _muted = Color(0xFF7C7A91);

  static const _stopwatchAsset =
      'assets/icons/attendance/ot/ic_ot_stopwatch.png';
  static const _lightbulbAsset =
      'assets/icons/attendance/ot/ic_ot_lightbulb.png';

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.fromLTRB(15, 14, 15, 14),
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _OtRow(
            iconAsset: _stopwatchAsset,
            children: [
              TextSpan(
                text: 'OT Calculation: ',
                style: portalText(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _labelBlue,
                  height: 17.25 / 12,
                ),
              ),
              TextSpan(
                text:
                    'OT hours are calculated when total hours exceed Assigned Shift Hours by more than 30 minutes (0.5hours).',
                style: portalText(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: _body,
                  height: 17.25 / 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _OtRow(
            iconAsset: _lightbulbAsset,
            children: [
              TextSpan(
                text: 'Example: ',
                style: portalText(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _labelBlue,
                  height: 17.25 / 12,
                ),
              ),
              TextSpan(
                text: 'If shift is 9h, OT starts after 9h 30m of work.',
                style: portalText(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: _muted,
                  height: 17.25 / 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OtRow extends StatelessWidget {
  const _OtRow({required this.iconAsset, required this.children});

  final String iconAsset;
  final List<InlineSpan> children;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 1),
          child: Image.asset(
            iconAsset,
            width: 16,
            height: 16,
            filterQuality: FilterQuality.high,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(child: Text.rich(TextSpan(children: children))),
      ],
    );
  }
}
