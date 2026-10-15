import 'package:flutter/material.dart';
import 'package:timelay_health/core/theme/portal_colors.dart';
import 'package:timelay_health/core/theme/portal_text.dart';

class OtInfoBox extends StatefulWidget {
  const OtInfoBox({super.key});

  @override
  State<OtInfoBox> createState() => _OtInfoBoxState();
}

class _OtInfoBoxState extends State<OtInfoBox> {
  static const _bg = Color(0xFFEFF4FE);
  static const _border = Color(0xFFD7E5FB);
  static const _labelBlue = Color(0xFF3B6FE0);

  static const _stopwatchAsset =
      'assets/icons/attendance/ot/ic_ot_stopwatch.png';
  static const _lightbulbAsset =
      'assets/icons/attendance/ot/ic_ot_lightbulb.png';

  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => setState(() => _expanded = !_expanded),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 11, 12, 11),
            child: AnimatedSize(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              alignment: Alignment.topCenter,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 30,
                        height: 30,
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: Image.asset(
                          _stopwatchAsset,
                          filterQuality: FilterQuality.high,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'How OT is calculated',
                              style: portalText(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                color: _labelBlue,
                                height: 15 / 12.5,
                              ),
                            ),
                            const SizedBox(height: 1),
                            Text(
                              'Hours beyond shift + 30 min count as OT',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: portalText(
                                fontSize: 10.5,
                                color: PortalColors.muted,
                                height: 13 / 10.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      AnimatedRotation(
                        turns: _expanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 220),
                        child: const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 20,
                          color: _labelBlue,
                        ),
                      ),
                    ],
                  ),
                  if (_expanded) ...[
                    const SizedBox(height: 10),
                    Container(height: 1, color: _border),
                    const SizedBox(height: 10),
                    _OtRow(
                      iconAsset: _stopwatchAsset,
                      label: 'OT Calculation: ',
                      body:
                          'OT hours are calculated when total hours exceed Assigned Shift Hours by more than 30 minutes (0.5hours).',
                    ),
                    const SizedBox(height: 8),
                    _OtRow(
                      iconAsset: _lightbulbAsset,
                      label: 'Example: ',
                      body: 'If shift is 9h, OT starts after 9h 30m of work.',
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _OtRow extends StatelessWidget {
  const _OtRow({
    required this.iconAsset,
    required this.label,
    required this.body,
  });

  final String iconAsset;
  final String label;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 1),
          child: Image.asset(
            iconAsset,
            width: 15,
            height: 15,
            filterQuality: FilterQuality.high,
          ),
        ),
        const SizedBox(width: 7),
        Expanded(
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: label,
                  style: portalText(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: _OtInfoBoxState._labelBlue,
                    height: 16 / 11.5,
                  ),
                ),
                TextSpan(
                  text: body,
                  style: portalText(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                    color: PortalColors.secondaryText,
                    height: 16 / 11.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
