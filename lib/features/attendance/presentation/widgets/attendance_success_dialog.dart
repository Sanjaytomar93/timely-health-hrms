import 'dart:async';

import 'package:flutter/material.dart';
import 'package:timelay_health/core/theme/portal_colors.dart';
import 'package:timelay_health/core/theme/portal_text.dart';
import 'package:timelay_health/features/attendance/presentation/bloc/check_in_state.dart';
import 'package:timelay_health/features/attendance/presentation/utils/attendance_feedback.dart';

Future<void> showAttendanceSuccessDialog(
  BuildContext context, {
  required CheckInReadyData data,
  required CheckInSuccess success,
}) {
  final isCheckout = data.mode == MarkAttendanceMode.checkOut;
  final title = data.requirePhoto
      ? (isCheckout
            ? '✅ Check-out Successful with Photo! 📸'
            : '✅ Check-in Successful with Photo! 📸')
      : (isCheckout ? '✅ Check-out Successful!' : '✅ Check-in Successful!');

  final name =
      (success.result?.employeeName ??
              success.checkOutResult?.employeeName ??
              data.displayName)
          .trim();

  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    useRootNavigator: true,
    builder: (_) => _AttendanceSuccessDialog(
      title: title,
      isCheckout: isCheckout,
      employeeName: name,
    ),
  );
}

class _AttendanceSuccessDialog extends StatefulWidget {
  const _AttendanceSuccessDialog({
    required this.title,
    required this.isCheckout,
    required this.employeeName,
  });

  final String title;
  final bool isCheckout;
  final String employeeName;

  @override
  State<_AttendanceSuccessDialog> createState() =>
      _AttendanceSuccessDialogState();
}

class _AttendanceSuccessDialogState extends State<_AttendanceSuccessDialog>
    with SingleTickerProviderStateMixin {
  bool _speaking = true;
  bool _closed = false;
  late final AnimationController _bars;

  @override
  void initState() {
    super.initState();
    _bars = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);
    _playFeedback();
  }

  Future<void> _playFeedback() async {
    await AttendanceFeedback.playSuccessSound();
    if (!mounted || _closed) return;
    if (widget.isCheckout) {
      await AttendanceFeedback.speakCheckOutSuccess(widget.employeeName);
    } else {
      await AttendanceFeedback.speakCheckInSuccess(widget.employeeName);
    }
    if (mounted && !_closed) setState(() => _speaking = false);
  }

  Future<void> _close() async {
    if (_closed) return;
    _closed = true;
    await AttendanceFeedback.stop();
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _closed = true;
    _bars.dispose();
    unawaited(AttendanceFeedback.stop());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) {
          _closed = true;
          unawaited(AttendanceFeedback.stop());
        }
      },
      child: Dialog(
        backgroundColor: PortalColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 32),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 28, 22, 22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 78,
                height: 78,
                decoration: BoxDecoration(
                  color: PortalColors.green,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: PortalColors.green.withValues(alpha: 0.35),
                      blurRadius: 18,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 28),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                widget.title,
                textAlign: TextAlign.center,
                style: portalText(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: PortalColors.heading,
                ),
              ),
              if (_speaking) ...[
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedBuilder(
                      animation: _bars,
                      builder: (context, _) {
                        return Row(
                          children: List.generate(4, (i) {
                            final t = (_bars.value + i * 0.18) % 1.0;
                            final h = 6.0 + t * 12;
                            return Container(
                              width: 3.5,
                              height: h,
                              margin: const EdgeInsets.symmetric(
                                horizontal: 1.5,
                              ),
                              decoration: BoxDecoration(
                                color: PortalColors.green,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            );
                          }),
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.volume_up_rounded,
                      size: 16,
                      color: PortalColors.green,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Speaking...',
                      style: portalText(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: PortalColors.green,
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                child: Material(
                  color: PortalColors.brand,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    onTap: _close,
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      child: Center(
                        child: Text(
                          'OK',
                          style: portalText(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
