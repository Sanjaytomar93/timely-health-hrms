import 'package:flutter/material.dart';
import 'package:timelay_health/core/theme/portal_colors.dart';
import 'package:timelay_health/core/theme/portal_text.dart';
import 'package:timelay_health/features/auth/data/auth_session.dart';

Future<bool> showMarkAttendanceWelcomeDialog(BuildContext context) async {
  final employee = AuthSession.currentEmployee ?? await AuthSession.load();
  final name = employee?.displayName.trim().isNotEmpty == true
      ? employee!.displayName.trim()
      : 'there';
  final now = DateTime.now();

  if (!context.mounted) return false;
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.black.withValues(alpha: 0.45),
    builder: (context) => _MarkAttendanceWelcomeDialog(name: name, now: now),
  );
  return result == true;
}

class _MarkAttendanceWelcomeDialog extends StatelessWidget {
  const _MarkAttendanceWelcomeDialog({required this.name, required this.now});

  final String name;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final local = now.toLocal();
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
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
    final dateLabel =
        '${weekdays[local.weekday - 1]}, ${months[local.month - 1]} ${local.day}, ${local.year}';
    final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
    final minute = local.minute.toString().padLeft(2, '0');
    final ampm = local.hour >= 12 ? 'PM' : 'AM';
    final timeLabel = '$hour:$minute $ampm IST';

    return Dialog(
      backgroundColor: PortalColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 28),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 12, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                onPressed: () => Navigator.pop(context, false),
                icon: const Icon(
                  Icons.close,
                  size: 20,
                  color: Color(0xFF7C7A91),
                ),
              ),
            ),
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: PortalColors.brandGradient,
                ),
              ),
              alignment: Alignment.center,
              child: const Text('👋', style: TextStyle(fontSize: 34)),
            ),
            const SizedBox(height: 16),
            Text(
              'Welcome, $name! 🌟',
              textAlign: TextAlign.center,
              style: portalText(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: PortalColors.heading,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.calendar_today_rounded,
                  size: 14,
                  color: Color(0xFF26204A),
                ),
                const SizedBox(width: 6),
                Text(
                  dateLabel,
                  style: portalText(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF26204A),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.access_time_rounded,
                  size: 15,
                  color: Color(0xFF26204A),
                ),
                const SizedBox(width: 6),
                Text(
                  timeLabel,
                  style: portalText(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF26204A),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: Material(
                borderRadius: BorderRadius.circular(28),
                child: InkWell(
                  onTap: () => Navigator.pop(context, true),
                  borderRadius: BorderRadius.circular(28),
                  child: Ink(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      gradient: const LinearGradient(
                        colors: PortalColors.brandGradient,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: Center(
                        child: Text(
                          "🚀 Let's Get Started",
                          style: portalText(
                            fontSize: 14,
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
      ),
    );
  }
}
