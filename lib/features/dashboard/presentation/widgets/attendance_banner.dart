import 'package:flutter/material.dart';
import 'package:timelay_health/core/theme/portal_colors.dart';
import 'package:timelay_health/core/theme/portal_text.dart';
import 'package:timelay_health/features/attendance/presentation/widgets/check_in_sheet.dart';
import 'package:timelay_health/features/dashboard/presentation/models/dashboard_home_ui.dart';

class AttendanceBanner extends StatelessWidget {
  const AttendanceBanner({super.key, this.data});

  final DashboardAttendanceBannerUi? data;

  @override
  Widget build(BuildContext context) {
    final statusLabel = data?.statusLabel ?? 'Not checked in yet';
    final isCheckedIn = data?.isCheckedIn ?? false;
    final checkIn = data?.checkIn ?? '—';
    final checkOut = data?.checkOut ?? '—';
    final shift = data?.shift ?? '—';
    final statusColor = isCheckedIn ? PortalColors.green : PortalColors.redSoft;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Container(
        constraints: const BoxConstraints(minHeight: 173),
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: const LinearGradient(
            begin: Alignment(-0.45, -0.9),
            end: Alignment(0.9, 0.75),
            colors: PortalColors.brandGradient,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Positioned(
              right: -30,
              top: -40,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "TODAY'S ATTENDANCE",
                    style: portalText(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.white.withValues(alpha: 0.85),
                      letterSpacing: 1,
                      height: 13 / 11,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _BlinkingDot(color: statusColor),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          statusLabel,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: portalText(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            height: 19 / 15.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: _Metric(label: 'Check In', value: checkIn),
                      ),
                      Expanded(
                        flex: 2,
                        child: _Metric(label: 'Check Out', value: checkOut),
                      ),
                      Expanded(
                        flex: 3,
                        child: _Metric(label: 'Shift', value: shift),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    height: 39,
                    child: Material(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        onTap: () => showCheckInSheet(context),
                        borderRadius: BorderRadius.circular(12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.access_time,
                              size: 14,
                              color: PortalColors.brand,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Mark Attendance',
                              style: portalText(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                color: PortalColors.brand,
                                height: 16 / 13.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
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

class _BlinkingDot extends StatefulWidget {
  const _BlinkingDot({required this.color});

  final Color color;

  @override
  State<_BlinkingDot> createState() => _BlinkingDotState();
}

class _BlinkingDotState extends State<_BlinkingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final t = Curves.easeInOut.transform(_controller.value);
          return Opacity(
            opacity: 0.35 + 0.65 * t,
            child: Container(
              width: 9,
              height: 9,
              decoration: BoxDecoration(
                color: widget.color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: widget.color.withValues(alpha: 0.45 * t),
                    blurRadius: 4 + 4 * t,
                    spreadRadius: 1 + 4 * t,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: portalText(
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
            color: Colors.white.withValues(alpha: 0.75),
            height: 13 / 10.5,
          ),
        ),
        const SizedBox(height: 1),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            value,
            style: portalText(
              fontSize: 14.5,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              height: 18 / 14.5,
            ),
          ),
        ),
      ],
    );
  }
}
