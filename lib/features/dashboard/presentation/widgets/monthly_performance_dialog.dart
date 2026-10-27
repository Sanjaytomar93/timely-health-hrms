import 'package:flutter/material.dart';
import 'package:timelay_health/core/theme/portal_text.dart';
import 'package:timelay_health/features/dashboard/domain/entities/employee_performance.dart';

Future<void> showMonthlyPerformanceDialog(
  BuildContext context, {
  required EmployeePerformance review,
}) {
  return showDialog<void>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.5),
    builder: (_) => MonthlyPerformanceDialog(review: review),
  );
}

class MonthlyPerformanceDialog extends StatelessWidget {
  const MonthlyPerformanceDialog({super.key, required this.review});

  final EmployeePerformance review;

  @override
  Widget build(BuildContext context) {
    final tone = _toneFor(review);
    final notes = _attentionNotes(review);
    final width = (MediaQuery.sizeOf(context).width - 48).clamp(280.0, 350.0);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        width: width,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: tone.headerEnd.withValues(alpha: 0.24),
              blurRadius: 30,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 22),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [tone.headerStart, tone.headerEnd],
                  ),
                ),
                child: Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    Column(
                      children: [
                        Icon(tone.icon, color: tone.iconColor, size: 32),
                        const SizedBox(height: 8),
                        Text(
                          'Monthly Performance Review',
                          textAlign: TextAlign.center,
                          style: portalText(
                            fontSize: 16.5,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        if (review.monthLabel.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            'For the month of ${review.monthLabel}',
                            style: portalText(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                        ],
                      ],
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.22),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close_rounded,
                            size: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Body
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 22, 16, 22),
                child: Column(
                  children: [
                    Text(
                      'Your Performance Score',
                      style: portalText(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${review.performancePercentage.round()}%',
                      style: portalText(
                        fontSize: 40,
                        fontWeight: FontWeight.w800,
                        color: tone.scoreColor,
                        letterSpacing: -1,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: tone.badgeBg,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: tone.badgeBorder),
                      ),
                      child: Text(
                        tone.badge,
                        style: portalText(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                          color: tone.scoreColor,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Text(
                        _summary(review, tone),
                        textAlign: TextAlign.center,
                        style: portalText(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1E293B),
                          height: 1.45,
                        ),
                      ),
                    ),
                    if (notes.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF5F5),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFFFD9D6)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.error_outline_rounded,
                                  size: 17,
                                  color: Color(0xFFDC2626),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'ATTENTION NEEDED',
                                  style: portalText(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFFDC2626),
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            for (final note in notes)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Text(
                                  '•  $note',
                                  style: portalText(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFFDC2626),
                                    height: 1.4,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: LinearGradient(
                            colors: [tone.buttonStart, tone.buttonEnd],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: tone.buttonEnd.withValues(alpha: 0.32),
                              blurRadius: 14,
                              offset: const Offset(0, 7),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () => Navigator.of(context).pop(),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              child: Center(
                                child: Text(
                                  'Okay, Understood!',
                                  style: portalText(
                                    fontSize: 15,
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
            ],
          ),
        ),
      ),
    );
  }

  String _summary(EmployeePerformance review, _ScoreTone tone) {
    final name = review.firstName;
    return switch (tone.level) {
      _ScoreLevel.needsImprovement =>
        'Your performance is low this month. Need to improve your performance, $name. Please focus on improvement. ⚠️',
      _ScoreLevel.average =>
        'Your performance is average this month, $name. A little more consistency will lift your score. 💪',
      _ScoreLevel.good =>
        'Your performance is good, $name! You are doing well, but there is still room for improvement. Let\'s aim higher! 💪',
      _ScoreLevel.outstanding =>
        'Outstanding month, $name! You are well above the expected line. Keep up the fantastic work! 🎉',
    };
  }

  List<String> _attentionNotes(EmployeePerformance review) {
    final notes = <String>[];
    if (review.lateComingDays > 0) {
      final times = review.lateComingDays == 1 ? 'time' : 'times';
      notes.add(
        'You have checked in late ${review.lateComingDays} $times this month. Please check-in on time to maintain discipline.',
      );
    }
    if (review.absentDays > 0) {
      final days = review.absentDays == 1 ? 'day' : 'days';
      notes.add(
        'You have been absent ${review.absentDays} $days this month. Please try to maintain regular attendance.',
      );
    }
    return notes;
  }

  _ScoreTone _toneFor(EmployeePerformance review) {
    final rawStatus = review.status?.trim().toLowerCase() ?? '';
    if (rawStatus.contains('outstand') || rawStatus.contains('excel')) {
      return _ScoreTone.outstanding;
    }
    if (rawStatus.contains('good')) {
      return _ScoreTone.good;
    }
    if (rawStatus.contains('average')) {
      return _ScoreTone.average;
    }
    if (rawStatus.contains('need') ||
        rawStatus.contains('low') ||
        rawStatus.contains('poor')) {
      return _ScoreTone.needsImprovement;
    }

    // Align with web portal bands.
    final percentage = review.performancePercentage;
    if (percentage >= 85) return _ScoreTone.outstanding;
    if (percentage >= 70) return _ScoreTone.good;
    if (percentage >= 60) return _ScoreTone.average;
    return _ScoreTone.needsImprovement;
  }
}

enum _ScoreLevel { needsImprovement, average, good, outstanding }

class _ScoreTone {
  const _ScoreTone({
    required this.level,
    required this.badge,
    required this.scoreColor,
    required this.badgeBg,
    required this.badgeBorder,
    required this.headerStart,
    required this.headerEnd,
    required this.icon,
    required this.iconColor,
    required this.buttonStart,
    required this.buttonEnd,
  });

  final _ScoreLevel level;
  final String badge;
  final Color scoreColor;
  final Color badgeBg;
  final Color badgeBorder;
  final Color headerStart;
  final Color headerEnd;
  final IconData icon;
  final Color iconColor;
  final Color buttonStart;
  final Color buttonEnd;

  static const outstanding = _ScoreTone(
    level: _ScoreLevel.outstanding,
    badge: 'OUTSTANDING',
    scoreColor: Color(0xFF059669),
    badgeBg: Color(0xFFECFDF5),
    badgeBorder: Color(0xFFA7F3D0),
    headerStart: Color(0xFF10B981),
    headerEnd: Color(0xFF047857),
    icon: Icons.emoji_events_rounded,
    iconColor: Color(0xFFFFD43F),
    buttonStart: Color(0xFF10B981),
    buttonEnd: Color(0xFF059669),
  );

  static const good = _ScoreTone(
    level: _ScoreLevel.good,
    badge: 'GOOD',
    scoreColor: Color(0xFF4F46E5),
    badgeBg: Color(0xFFEEF2FF),
    badgeBorder: Color(0xFFC7D2FE),
    headerStart: Color(0xFF6366F1),
    headerEnd: Color(0xFFD946EF),
    icon: Icons.auto_awesome_rounded,
    iconColor: Color(0xFFFFDE43),
    buttonStart: Color(0xFF6366F1),
    buttonEnd: Color(0xFF8B5CF6),
  );

  static const average = _ScoreTone(
    level: _ScoreLevel.average,
    badge: 'AVERAGE',
    scoreColor: Color(0xFFD97706),
    badgeBg: Color(0xFFFFFBEB),
    badgeBorder: Color(0xFFFDE68A),
    headerStart: Color(0xFFFFC14D),
    headerEnd: Color(0xFFFF8A2A),
    icon: Icons.trending_flat_rounded,
    iconColor: Color(0xFFFFE14A),
    buttonStart: Color(0xFFFFC14D),
    buttonEnd: Color(0xFFFF8A2A),
  );

  static const needsImprovement = _ScoreTone(
    level: _ScoreLevel.needsImprovement,
    badge: 'NEEDS IMPROVEMENT',
    scoreColor: Color(0xFFDC2626),
    badgeBg: Color(0xFFFEF2F2),
    badgeBorder: Color(0xFFFFD5D1),
    headerStart: Color(0xFFFF6B6B),
    headerEnd: Color(0xFFEE3B3B),
    icon: Icons.warning_rounded,
    iconColor: Colors.white,
    buttonStart: Color(0xFFFF6B6B),
    buttonEnd: Color(0xFFEE3B3B),
  );
}
