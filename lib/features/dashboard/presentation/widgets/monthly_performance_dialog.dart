import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:timelay_health/core/theme/portal_text.dart';
import 'package:timelay_health/features/dashboard/domain/entities/employee_performance.dart';

Future<void> showMonthlyPerformanceDialog(
  BuildContext context, {
  required EmployeePerformance review,
}) {
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Dismiss performance review',
    barrierColor: Colors.black.withValues(alpha: 0.48),
    transitionDuration: const Duration(milliseconds: 340),
    pageBuilder: (context, animation, secondaryAnimation) {
      return MonthlyPerformanceDialog(review: review);
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      return FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.86, end: 1).animate(curved),
          child: child,
        ),
      );
    },
  );
}

class MonthlyPerformanceDialog extends StatefulWidget {
  const MonthlyPerformanceDialog({super.key, required this.review});

  final EmployeePerformance review;

  @override
  State<MonthlyPerformanceDialog> createState() =>
      _MonthlyPerformanceDialogState();
}

class _MonthlyPerformanceDialogState extends State<MonthlyPerformanceDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _score;

  @override
  void initState() {
    super.initState();
    HapticFeedback.mediumImpact();
    _score = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
  }

  @override
  void dispose() {
    _score.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final review = widget.review;
    final tone = _toneFor(review.performancePercentage);
    final notes = _attentionNotes(review);
    final width = (MediaQuery.sizeOf(context).width - 56).clamp(260.0, 320.0);
    final maxHeight = MediaQuery.sizeOf(context).height * 0.78;

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: width,
          constraints: BoxConstraints(maxHeight: maxHeight),
          margin: const EdgeInsets.symmetric(horizontal: 28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: tone.headerEnd.withValues(alpha: 0.28),
                blurRadius: 28,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _Header(
                  monthLabel: review.monthLabel,
                  tone: tone,
                  onClose: () => Navigator.of(context).pop(),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                  child: Column(
                    children: [
                      Text(
                        'Your Performance Score',
                        style: portalText(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF8B8A99),
                        ),
                      ),
                      const SizedBox(height: 2),
                      AnimatedBuilder(
                        animation: _score,
                        builder: (context, _) {
                          final value =
                              review.performancePercentage *
                              Curves.easeOutCubic.transform(_score.value);
                          return Text(
                            '${value.toStringAsFixed(2)}%',
                            style: portalText(
                              fontSize: 34,
                              fontWeight: FontWeight.w800,
                              color: tone.score,
                              letterSpacing: -1,
                              height: 1.05,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
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
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: tone.score,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF4F6F9),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          _summary(review, tone),
                          textAlign: TextAlign.center,
                          style: portalText(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF2C2B3A),
                            height: 1.35,
                          ),
                        ),
                      ),
                      if (notes.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF4F4),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFFFD9D6)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.error_outline_rounded,
                                    size: 16,
                                    color: Color(0xFFE53935),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'ATTENTION NEEDED',
                                    style: portalText(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFFE53935),
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              for (final note in notes)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 6),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '•  ',
                                        style: portalText(
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w700,
                                          color: const Color(0xFFE53935),
                                          height: 1.35,
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          note,
                                          style: portalText(
                                            fontSize: 12.5,
                                            fontWeight: FontWeight.w500,
                                            color: const Color(0xFFE53935),
                                            height: 1.35,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: LinearGradient(
                              colors: [tone.headerStart, tone.headerEnd],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: tone.headerEnd.withValues(alpha: 0.35),
                                blurRadius: 14,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () => Navigator.of(context).pop(),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                child: Center(
                                  child: Text(
                                    'Okay, Understood!',
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
              ],
            ),
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
      _ScoreLevel.onTrack =>
        'Your performance looks solid this month, $name. Keep this pace going. 🌟',
      _ScoreLevel.outstanding =>
        'Outstanding month, $name. You are well above the expected line. 🎉',
    };
  }

  List<String> _attentionNotes(EmployeePerformance review) {
    final notes = <String>[];
    if (review.absentDays > 0) {
      final days = review.absentDays == 1 ? 'day' : 'days';
      notes.add(
        'You have been absent ${review.absentDays} $days this month. Please try to maintain regular attendance.',
      );
    }
    if (notes.isEmpty && review.lateComingDays > 0) {
      final days = review.lateComingDays == 1 ? 'day' : 'days';
      notes.add(
        'You were late ${review.lateComingDays} $days this month. Try to start the shift on time.',
      );
    }
    return notes;
  }

  _ScoreTone _toneFor(double percentage) {
    if (percentage >= 85) {
      return const _ScoreTone(
        level: _ScoreLevel.outstanding,
        badge: 'OUTSTANDING',
        score: Color(0xFF1B9A63),
        badgeBg: Color(0xFFE8F8F0),
        badgeBorder: Color(0xFFB7E7CF),
        headerStart: Color(0xFF3DDC97),
        headerEnd: Color(0xFF1FA971),
        headerIcon: Icons.emoji_events_rounded,
      );
    }
    if (percentage >= 70) {
      return const _ScoreTone(
        level: _ScoreLevel.onTrack,
        badge: 'ON TRACK',
        score: Color(0xFF1B8F5A),
        badgeBg: Color(0xFFE8F8F0),
        badgeBorder: Color(0xFFB7E7CF),
        headerStart: Color(0xFF5ED6A0),
        headerEnd: Color(0xFF2BB673),
        headerIcon: Icons.verified_rounded,
      );
    }
    if (percentage >= 50) {
      return const _ScoreTone(
        level: _ScoreLevel.average,
        badge: 'AVERAGE',
        score: Color(0xFFE08A12),
        badgeBg: Color(0xFFFFF6E8),
        badgeBorder: Color(0xFFFFE0B2),
        headerStart: Color(0xFFFFC14D),
        headerEnd: Color(0xFFFF8A2A),
        headerIcon: Icons.trending_flat_rounded,
      );
    }
    return const _ScoreTone(
      level: _ScoreLevel.needsImprovement,
      badge: 'NEEDS IMPROVEMENT',
      score: Color(0xFFE23B32),
      badgeBg: Color(0xFFFFF1EF),
      badgeBorder: Color(0xFFFFD5D1),
      headerStart: Color(0xFFFF9A2E),
      headerEnd: Color(0xFFFF4E3A),
      headerIcon: Icons.warning_rounded,
    );
  }
}

enum _ScoreLevel { needsImprovement, average, onTrack, outstanding }

class _ScoreTone {
  const _ScoreTone({
    required this.level,
    required this.badge,
    required this.score,
    required this.badgeBg,
    required this.badgeBorder,
    required this.headerStart,
    required this.headerEnd,
    required this.headerIcon,
  });

  final _ScoreLevel level;
  final String badge;
  final Color score;
  final Color badgeBg;
  final Color badgeBorder;
  final Color headerStart;
  final Color headerEnd;
  final IconData headerIcon;
}

class _Header extends StatelessWidget {
  const _Header({
    required this.monthLabel,
    required this.tone,
    required this.onClose,
  });

  final String monthLabel;
  final _ScoreTone tone;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [tone.headerStart, tone.headerEnd],
        ),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            child: Column(
              children: [
                Icon(tone.headerIcon, color: const Color(0xFFFFE14A), size: 26),
                const SizedBox(height: 4),
                Text(
                  'Monthly Performance Review',
                  textAlign: TextAlign.center,
                  style: portalText(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                if (monthLabel.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    'For the month of $monthLabel',
                    textAlign: TextAlign.center,
                    style: portalText(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Positioned(
            top: 10,
            right: 10,
            child: Material(
              color: Colors.white.withValues(alpha: 0.22),
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: onClose,
                child: const Padding(
                  padding: EdgeInsets.all(6),
                  child: Icon(
                    Icons.close_rounded,
                    size: 18,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
