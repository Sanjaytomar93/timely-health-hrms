import 'package:flutter/material.dart';
import 'package:timelay_health/core/theme/portal_colors.dart';

/// Sweeps a highlight across [child]. Every opaque pixel of [child] is
/// repainted with the shimmer gradient, so skeletons can use any solid color.
class Shimmer extends StatefulWidget {
  const Shimmer({
    super.key,
    required this.child,
    this.baseColor = PortalColors.border,
    this.highlightColor = const Color(0xFFFAF9FD),
    this.duration = const Duration(milliseconds: 1400),
  });

  final Widget child;
  final Color baseColor;
  final Color highlightColor;
  final Duration duration;

  @override
  State<Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<Shimmer> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) {
        final dx = -1.5 + 3 * _controller.value;
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) => LinearGradient(
            begin: Alignment(dx - 1, -0.3),
            end: Alignment(dx + 1, 0.3),
            colors: [
              widget.baseColor,
              widget.highlightColor,
              widget.baseColor,
            ],
            stops: const [0.35, 0.5, 0.65],
          ).createShader(bounds),
          child: child,
        );
      },
    );
  }
}

class ShimmerBox extends StatelessWidget {
  const ShimmerBox({
    super.key,
    this.width,
    required this.height,
    this.radius = 8,
    this.circle = false,
  });

  final double? width;
  final double height;
  final double radius;
  final bool circle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: circle ? height : width,
      height: height,
      decoration: BoxDecoration(
        color: PortalColors.border,
        shape: circle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: circle ? null : BorderRadius.circular(radius),
      ),
    );
  }
}

/// Placeholder for list screens: a column of cards shaped like list rows.
class ShimmerCardList extends StatelessWidget {
  const ShimmerCardList({
    super.key,
    this.itemCount = 5,
    this.padding = const EdgeInsets.fromLTRB(12, 16, 12, 16),
    this.scrollable = false,
  });

  final int itemCount;
  final EdgeInsets padding;

  /// Wraps the list in a non-interactive scroll view so it can sit inside
  /// bounded parents (e.g. `Expanded`) without overflowing.
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    final content = Shimmer(
      child: Padding(
        padding: padding,
        child: Column(
          children: [
            for (var i = 0; i < itemCount; i++) ...[
              if (i > 0) const SizedBox(height: 12),
              const _ShimmerListCard(),
            ],
          ],
        ),
      ),
    );
    if (!scrollable) return content;
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: content,
    );
  }
}

class _ShimmerListCard extends StatelessWidget {
  const _ShimmerListCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: PortalColors.border),
      ),
      child: const Row(
        children: [
          ShimmerBox(width: 44, height: 44, radius: 12),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerBox(width: 140, height: 12),
                SizedBox(height: 8),
                ShimmerBox(width: double.infinity, height: 10),
                SizedBox(height: 6),
                ShimmerBox(width: 90, height: 10),
              ],
            ),
          ),
          SizedBox(width: 12),
          ShimmerBox(width: 56, height: 22, radius: 11),
        ],
      ),
    );
  }
}

/// Mirrors the home dashboard layout.
class DashboardShimmer extends StatelessWidget {
  const DashboardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      physics: NeverScrollableScrollPhysics(),
      child: Shimmer(
        baseColor: Color(0xFFE4E1EF),
        highlightColor: Color(0xFFF8F7FC),
        child: Padding(
          padding: EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting
              ShimmerBox(width: 200, height: 20, radius: 8),
              SizedBox(height: 8),
              ShimmerBox(width: 140, height: 12, radius: 6),
              SizedBox(height: 12),
              // Profile card
              _ShimmerSurfaceCard(
                height: 92,
                child: Row(
                  children: [
                    ShimmerBox(height: 52, circle: true),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ShimmerBox(width: 130, height: 14, radius: 6),
                          SizedBox(height: 8),
                          ShimmerBox(width: 90, height: 10, radius: 5),
                          SizedBox(height: 6),
                          ShimmerBox(width: 160, height: 10, radius: 5),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 12),
              // Attendance banner
              ShimmerBox(width: double.infinity, height: 88, radius: 18),
              SizedBox(height: 14),
              // Stat cards 2x2
              Row(
                children: [
                  Expanded(child: ShimmerBox(height: 92, radius: 16)),
                  SizedBox(width: 10),
                  Expanded(child: ShimmerBox(height: 92, radius: 16)),
                ],
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: ShimmerBox(height: 92, radius: 16)),
                  SizedBox(width: 10),
                  Expanded(child: ShimmerBox(height: 92, radius: 16)),
                ],
              ),
              SizedBox(height: 16),
              // Quick actions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _QuickActionBone(),
                  _QuickActionBone(),
                  _QuickActionBone(),
                  _QuickActionBone(),
                ],
              ),
              SizedBox(height: 20),
              // Late minutes chart
              ShimmerBox(width: double.infinity, height: 210, radius: 18),
              SizedBox(height: 14),
              // Absent week-wise
              ShimmerBox(width: double.infinity, height: 180, radius: 18),
              SizedBox(height: 14),
              // Recent activity
              ShimmerBox(width: double.infinity, height: 150, radius: 18),
              SizedBox(height: 14),
              // Updates
              ShimmerBox(width: double.infinity, height: 140, radius: 18),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickActionBone extends StatelessWidget {
  const _QuickActionBone();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        ShimmerBox(width: 56, height: 56, radius: 16),
        SizedBox(height: 8),
        ShimmerBox(width: 48, height: 10, radius: 5),
      ],
    );
  }
}

class _ShimmerSurfaceCard extends StatelessWidget {
  const _ShimmerSurfaceCard({required this.height, required this.child});

  final double height;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: height,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: PortalColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: PortalColors.border),
      ),
      child: child,
    );
  }
}

/// Mirrors the My Leaves screen layout.
class LeavesShimmer extends StatelessWidget {
  const LeavesShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      physics: NeverScrollableScrollPhysics(),
      child: Shimmer(
        baseColor: Color(0xFFE4E1EF),
        highlightColor: Color(0xFFF8F7FC),
        child: Padding(
          padding: EdgeInsets.fromLTRB(18, 16, 18, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Horizontal stats
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: NeverScrollableScrollPhysics(),
                child: Row(
                  children: [
                    _LeaveStatBone(),
                    SizedBox(width: 10),
                    _LeaveStatBone(),
                    SizedBox(width: 10),
                    _LeaveStatBone(),
                    SizedBox(width: 10),
                    _LeaveStatBone(),
                    SizedBox(width: 10),
                    _LeaveStatBone(),
                  ],
                ),
              ),
              SizedBox(height: 14),
              // Apply / Permission
              Row(
                children: [
                  Expanded(child: ShimmerBox(height: 36, radius: 11)),
                  SizedBox(width: 10),
                  Expanded(child: ShimmerBox(height: 36, radius: 11)),
                ],
              ),
              SizedBox(height: 16),
              // Balance grid 2x2
              Row(
                children: [
                  Expanded(child: ShimmerBox(height: 110, radius: 14)),
                  SizedBox(width: 12),
                  Expanded(child: ShimmerBox(height: 110, radius: 14)),
                ],
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: ShimmerBox(height: 110, radius: 14)),
                  SizedBox(width: 12),
                  Expanded(child: ShimmerBox(height: 110, radius: 14)),
                ],
              ),
              SizedBox(height: 16),
              // Extra days
              ShimmerBox(width: double.infinity, height: 120, radius: 16),
              SizedBox(height: 16),
              // Filters
              ShimmerBox(width: double.infinity, height: 96, radius: 16),
              SizedBox(height: 18),
              // Segment switcher
              ShimmerBox(width: double.infinity, height: 46, radius: 999),
              SizedBox(height: 20),
              // Section title
              Row(
                children: [
                  ShimmerBox(width: 22, height: 22, radius: 6),
                  SizedBox(width: 8),
                  ShimmerBox(width: 150, height: 14, radius: 6),
                  Spacer(),
                  ShimmerBox(width: 90, height: 11, radius: 5),
                ],
              ),
              SizedBox(height: 12),
              // List cards
              _LeaveListBone(),
              SizedBox(height: 10),
              _LeaveListBone(),
              SizedBox(height: 10),
              _LeaveListBone(),
            ],
          ),
        ),
      ),
    );
  }
}

class _LeaveStatBone extends StatelessWidget {
  const _LeaveStatBone();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 118,
      height: 86,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: PortalColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: PortalColors.border),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerBox(width: 28, height: 28, radius: 8),
          Spacer(),
          ShimmerBox(width: 40, height: 16, radius: 6),
          SizedBox(height: 6),
          ShimmerBox(width: 70, height: 10, radius: 5),
        ],
      ),
    );
  }
}

class _LeaveListBone extends StatelessWidget {
  const _LeaveListBone();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      decoration: BoxDecoration(
        color: PortalColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: PortalColors.border),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ShimmerBox(width: 72, height: 14, radius: 6),
              Spacer(),
              ShimmerBox(width: 64, height: 18, radius: 999),
            ],
          ),
          SizedBox(height: 12),
          ShimmerBox(width: double.infinity, height: 10, radius: 5),
          SizedBox(height: 8),
          ShimmerBox(width: 160, height: 10, radius: 5),
        ],
      ),
    );
  }
}

/// Mirrors the My Attendance (Records) tab layout.
class AttendanceShimmer extends StatelessWidget {
  const AttendanceShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      physics: NeverScrollableScrollPhysics(),
      child: Shimmer(
        baseColor: Color(0xFFE4E1EF),
        highlightColor: Color(0xFFF8F7FC),
        child: Padding(
          padding: EdgeInsets.fromLTRB(16, 12, 16, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Check-in banner
              ShimmerBox(width: double.infinity, height: 88, radius: 18),
              SizedBox(height: 14),
              // Overview stats card (2 rows x 3)
              _AttendanceCardBone(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        ShimmerBox(width: 28, height: 28, radius: 8),
                        SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ShimmerBox(width: 140, height: 13, radius: 6),
                              SizedBox(height: 6),
                              ShimmerBox(width: 180, height: 10, radius: 5),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: _AttendanceStatTileBone()),
                        SizedBox(width: 10),
                        Expanded(child: _AttendanceStatTileBone()),
                        SizedBox(width: 10),
                        Expanded(child: _AttendanceStatTileBone()),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(child: _AttendanceStatTileBone()),
                        SizedBox(width: 10),
                        Expanded(child: _AttendanceStatTileBone()),
                        SizedBox(width: 10),
                        Expanded(child: _AttendanceStatTileBone()),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 12),
              // OT info
              ShimmerBox(width: double.infinity, height: 72, radius: 16),
              SizedBox(height: 12),
              // Filters & actions
              _AttendanceCardBone(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        ShimmerBox(width: 28, height: 28, radius: 8),
                        SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ShimmerBox(width: 120, height: 13, radius: 6),
                              SizedBox(height: 6),
                              ShimmerBox(width: 150, height: 10, radius: 5),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    ShimmerBox(width: 50, height: 10, radius: 5),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(child: ShimmerBox(height: 34, radius: 999)),
                        SizedBox(width: 8),
                        Expanded(child: ShimmerBox(height: 34, radius: 999)),
                        SizedBox(width: 8),
                        Expanded(child: ShimmerBox(height: 34, radius: 999)),
                      ],
                    ),
                    SizedBox(height: 14),
                    ShimmerBox(width: 70, height: 10, radius: 5),
                    SizedBox(height: 8),
                    ShimmerBox(width: double.infinity, height: 42, radius: 12),
                  ],
                ),
              ),
              SizedBox(height: 12),
              // OT available banner
              ShimmerBox(width: double.infinity, height: 56, radius: 14),
              SizedBox(height: 18),
              // Records header
              Row(
                children: [
                  ShimmerBox(width: 22, height: 22, radius: 6),
                  SizedBox(width: 8),
                  ShimmerBox(width: 140, height: 14, radius: 6),
                  Spacer(),
                  ShimmerBox(width: 80, height: 11, radius: 5),
                ],
              ),
              SizedBox(height: 12),
              _AttendanceRecordBone(),
              SizedBox(height: 10),
              _AttendanceRecordBone(),
              SizedBox(height: 10),
              _AttendanceRecordBone(),
              SizedBox(height: 10),
              _AttendanceRecordBone(),
            ],
          ),
        ),
      ),
    );
  }
}

class _AttendanceCardBone extends StatelessWidget {
  const _AttendanceCardBone({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: PortalColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: PortalColors.border),
      ),
      child: child,
    );
  }
}

class _AttendanceStatTileBone extends StatelessWidget {
  const _AttendanceStatTileBone();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 78,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F1F8),
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerBox(width: 22, height: 22, radius: 7),
          Spacer(),
          ShimmerBox(width: 36, height: 14, radius: 5),
          SizedBox(height: 5),
          ShimmerBox(width: 48, height: 9, radius: 4),
        ],
      ),
    );
  }
}

class _AttendanceRecordBone extends StatelessWidget {
  const _AttendanceRecordBone();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      decoration: BoxDecoration(
        color: PortalColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: PortalColors.border),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ShimmerBox(width: 110, height: 13, radius: 6),
              Spacer(),
              ShimmerBox(width: 70, height: 20, radius: 999),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: ShimmerBox(height: 36, radius: 10)),
              SizedBox(width: 8),
              Expanded(child: ShimmerBox(height: 36, radius: 10)),
            ],
          ),
          SizedBox(height: 10),
          ShimmerBox(width: 150, height: 10, radius: 5),
        ],
      ),
    );
  }
}

/// Mirrors My Shift / My Location tab loading layout.
class AttendanceSubTabShimmer extends StatelessWidget {
  const AttendanceSubTabShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      physics: NeverScrollableScrollPhysics(),
      child: Shimmer(
        baseColor: Color(0xFFE4E1EF),
        highlightColor: Color(0xFFF8F7FC),
        child: Padding(
          padding: EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(child: ShimmerBox(height: 72, radius: 14)),
                  SizedBox(width: 10),
                  Expanded(child: ShimmerBox(height: 72, radius: 14)),
                  SizedBox(width: 10),
                  Expanded(child: ShimmerBox(height: 72, radius: 14)),
                ],
              ),
              SizedBox(height: 14),
              _AttendanceCardBone(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerBox(width: 140, height: 14, radius: 6),
                    SizedBox(height: 12),
                    ShimmerBox(width: double.infinity, height: 12, radius: 5),
                    SizedBox(height: 8),
                    ShimmerBox(width: 180, height: 12, radius: 5),
                    SizedBox(height: 14),
                    ShimmerBox(width: double.infinity, height: 48, radius: 12),
                  ],
                ),
              ),
              SizedBox(height: 12),
              _AttendanceCardBone(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerBox(width: 120, height: 14, radius: 6),
                    SizedBox(height: 12),
                    ShimmerBox(width: double.infinity, height: 12, radius: 5),
                    SizedBox(height: 8),
                    ShimmerBox(width: 200, height: 12, radius: 5),
                  ],
                ),
              ),
              SizedBox(height: 12),
              _AttendanceCardBone(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerBox(width: 100, height: 14, radius: 6),
                    SizedBox(height: 12),
                    ShimmerBox(width: double.infinity, height: 12, radius: 5),
                    SizedBox(height: 8),
                    ShimmerBox(width: 160, height: 12, radius: 5),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Mirrors the profile layout: avatar header followed by detail cards.
class ProfileShimmer extends StatelessWidget {
  const ProfileShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      physics: NeverScrollableScrollPhysics(),
      child: Shimmer(
        child: Padding(
          padding: EdgeInsets.fromLTRB(12, 24, 12, 24),
          child: Column(
            children: [
              ShimmerBox(height: 84, circle: true),
              SizedBox(height: 14),
              ShimmerBox(width: 160, height: 16),
              SizedBox(height: 8),
              ShimmerBox(width: 110, height: 12),
              SizedBox(height: 24),
              ShimmerBox(width: double.infinity, height: 64, radius: 14),
              SizedBox(height: 12),
              ShimmerBox(width: double.infinity, height: 64, radius: 14),
              SizedBox(height: 12),
              ShimmerBox(width: double.infinity, height: 64, radius: 14),
              SizedBox(height: 12),
              ShimmerBox(width: double.infinity, height: 64, radius: 14),
              SizedBox(height: 12),
              ShimmerBox(width: double.infinity, height: 64, radius: 14),
            ],
          ),
        ),
      ),
    );
  }
}

/// Mirrors the payslips screen: header, stats, filters, salary record.
class PayslipsShimmer extends StatelessWidget {
  const PayslipsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      physics: NeverScrollableScrollPhysics(),
      child: Shimmer(
        baseColor: Color(0xFFE4E1EF),
        highlightColor: Color(0xFFF8F7FC),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(18, 16, 18, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: ShimmerBox(width: 100, height: 16, radius: 6)),
                      ShimmerBox(width: 120, height: 30, radius: 11),
                    ],
                  ),
                  SizedBox(height: 8),
                  ShimmerBox(width: 220, height: 10, radius: 5),
                ],
              ),
            ),
            SizedBox(height: 14),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: NeverScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 18),
              child: Row(
                children: [
                  _PayslipStatBone(),
                  SizedBox(width: 10),
                  _PayslipStatBone(),
                  SizedBox(width: 10),
                  _PayslipStatBone(),
                  SizedBox(width: 10),
                  _PayslipStatBone(),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(18, 14, 18, 0),
              child: _PayslipFiltersBone(),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(18, 18, 18, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerBox(width: 120, height: 13, radius: 5),
                  SizedBox(height: 6),
                  ShimmerBox(width: 200, height: 10, radius: 5),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(18, 14, 18, 28),
              child: _PayslipRecordBone(),
            ),
          ],
        ),
      ),
    );
  }
}

class _PayslipStatBone extends StatelessWidget {
  const _PayslipStatBone();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 128,
      padding: const EdgeInsets.fromLTRB(13, 13, 10, 12),
      decoration: BoxDecoration(
        color: PortalColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: PortalColors.border),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerBox(width: 28, height: 28, radius: 8),
          SizedBox(height: 10),
          ShimmerBox(width: 72, height: 9, radius: 4),
          SizedBox(height: 6),
          ShimmerBox(width: 56, height: 16, radius: 5),
          SizedBox(height: 4),
          ShimmerBox(width: 48, height: 9, radius: 4),
        ],
      ),
    );
  }
}

class _PayslipFiltersBone extends StatelessWidget {
  const _PayslipFiltersBone();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(17, 17, 17, 16),
      decoration: BoxDecoration(
        color: PortalColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: PortalColors.border),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ShimmerBox(width: 56, height: 13, radius: 5),
              Spacer(),
              ShimmerBox(width: 58, height: 11, radius: 5),
            ],
          ),
          SizedBox(height: 14),
          ShimmerBox(width: double.infinity, height: 42, radius: 11),
          SizedBox(height: 12),
          ShimmerBox(width: double.infinity, height: 42, radius: 11),
          SizedBox(height: 12),
          ShimmerBox(width: double.infinity, height: 40, radius: 11),
          SizedBox(height: 12),
          ShimmerBox(width: 140, height: 11, radius: 5),
        ],
      ),
    );
  }
}

class _PayslipRecordBone extends StatelessWidget {
  const _PayslipRecordBone();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: PortalColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: PortalColors.border),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerBox(width: 110, height: 14, radius: 5),
          SizedBox(height: 6),
          ShimmerBox(width: 160, height: 9, radius: 4),
          SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: ShimmerBox(height: 48, radius: 11)),
              SizedBox(width: 8),
              Expanded(child: ShimmerBox(height: 48, radius: 11)),
              SizedBox(width: 8),
              Expanded(child: ShimmerBox(height: 48, radius: 11)),
            ],
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: ShimmerBox(height: 48, radius: 11)),
              SizedBox(width: 8),
              Expanded(child: ShimmerBox(height: 48, radius: 11)),
              SizedBox(width: 8),
              Expanded(child: ShimmerBox(height: 48, radius: 11)),
            ],
          ),
          SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerBox(width: 90, height: 13, radius: 5),
                    SizedBox(height: 6),
                    ShimmerBox(width: 140, height: 10, radius: 4),
                    SizedBox(height: 4),
                    ShimmerBox(width: 70, height: 10, radius: 4),
                  ],
                ),
              ),
              ShimmerBox(width: 34, height: 34, radius: 10),
              SizedBox(width: 8),
              ShimmerBox(width: 34, height: 34, radius: 10),
            ],
          ),
        ],
      ),
    );
  }
}
