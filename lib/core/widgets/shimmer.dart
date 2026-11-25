import 'package:flutter/material.dart';
import 'package:timelay_health/core/theme/portal_colors.dart';

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

class ShimmerCardList extends StatelessWidget {
  const ShimmerCardList({
    super.key,
    this.itemCount = 5,
    this.padding = const EdgeInsets.fromLTRB(12, 16, 12, 16),
    this.scrollable = false,
  });

  final int itemCount;
  final EdgeInsets padding;

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
        color: PortalColors.surface,
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
              ShimmerBox(width: 210, height: 22, radius: 8),
              SizedBox(height: 8),
              ShimmerBox(width: 150, height: 12, radius: 6),
              SizedBox(height: 12),
              _ShimmerSurfaceCard(
                height: 108,
                child: Row(
                  children: [
                    ShimmerBox(height: 52, circle: true),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ShimmerBox(width: 140, height: 14, radius: 6),
                          SizedBox(height: 8),
                          ShimmerBox(width: 100, height: 10, radius: 5),
                          SizedBox(height: 6),
                          ShimmerBox(width: 170, height: 10, radius: 5),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              ShimmerBox(width: double.infinity, height: 148, radius: 18),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: ShimmerBox(height: 78, radius: 16)),
                  SizedBox(width: 10),
                  Expanded(child: ShimmerBox(height: 78, radius: 16)),
                ],
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: ShimmerBox(height: 78, radius: 16)),
                  SizedBox(width: 10),
                  Expanded(child: ShimmerBox(height: 78, radius: 16)),
                ],
              ),
              SizedBox(height: 20),
              ShimmerBox(width: 120, height: 12, radius: 5),
              SizedBox(height: 10),
              _QuickActionsBone(),
              SizedBox(height: 24),
              ShimmerBox(width: double.infinity, height: 210, radius: 18),
              SizedBox(height: 14),
              ShimmerBox(width: double.infinity, height: 180, radius: 18),
              SizedBox(height: 14),
              ShimmerBox(width: double.infinity, height: 150, radius: 18),
              SizedBox(height: 14),
              ShimmerBox(width: double.infinity, height: 140, radius: 18),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickActionsBone extends StatelessWidget {
  const _QuickActionsBone();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: PortalColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: PortalColors.border),
      ),
      child: const Row(
        children: [
          Expanded(child: _QuickActionTileBone()),
          Expanded(child: _QuickActionTileBone()),
          Expanded(child: _QuickActionTileBone()),
        ],
      ),
    );
  }
}

class _QuickActionTileBone extends StatelessWidget {
  const _QuickActionTileBone();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        ShimmerBox(width: 40, height: 40, circle: true),
        SizedBox(height: 10),
        ShimmerBox(width: 52, height: 10, radius: 5),
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

class DashboardContentShimmer extends StatelessWidget {
  const DashboardContentShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return const Shimmer(
      baseColor: Color(0xFFE4E1EF),
      highlightColor: Color(0xFFF8F7FC),
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, 8, 16, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: ShimmerBox(height: 78, radius: 16)),
                SizedBox(width: 10),
                Expanded(child: ShimmerBox(height: 78, radius: 16)),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: ShimmerBox(height: 78, radius: 16)),
                SizedBox(width: 10),
                Expanded(child: ShimmerBox(height: 78, radius: 16)),
              ],
            ),
            SizedBox(height: 10),
            ShimmerBox(width: double.infinity, height: 78, radius: 16),
            SizedBox(height: 20),
            ShimmerBox(width: 110, height: 14, radius: 6),
            SizedBox(height: 10),
            ShimmerBox(width: double.infinity, height: 78, radius: 18),
            SizedBox(height: 24),
            ShimmerBox(width: double.infinity, height: 210, radius: 18),
            SizedBox(height: 14),
            ShimmerBox(width: double.infinity, height: 180, radius: 18),
            SizedBox(height: 14),
            ShimmerBox(width: double.infinity, height: 156, radius: 18),
            SizedBox(height: 14),
            ShimmerBox(width: double.infinity, height: 140, radius: 18),
          ],
        ),
      ),
    );
  }
}

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
              Row(
                children: [
                  Expanded(child: ShimmerBox(height: 36, radius: 11)),
                  SizedBox(width: 10),
                  Expanded(child: ShimmerBox(height: 36, radius: 11)),
                ],
              ),
              SizedBox(height: 16),
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
              ShimmerBox(width: double.infinity, height: 120, radius: 16),
              SizedBox(height: 16),
              ShimmerBox(width: double.infinity, height: 96, radius: 16),
              SizedBox(height: 18),
              ShimmerBox(width: double.infinity, height: 46, radius: 999),
              SizedBox(height: 20),
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
              ShimmerBox(width: double.infinity, height: 88, radius: 18),
              SizedBox(height: 14),
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
              ShimmerBox(width: double.infinity, height: 72, radius: 16),
              SizedBox(height: 12),
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
              ShimmerBox(width: double.infinity, height: 56, radius: 14),
              SizedBox(height: 18),
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

class PayslipRecordsShimmer extends StatelessWidget {
  const PayslipRecordsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return const Shimmer(
      baseColor: Color(0xFFE4E1EF),
      highlightColor: Color(0xFFF8F7FC),
      child: Padding(
        padding: EdgeInsets.fromLTRB(18, 14, 18, 0),
        child: _PayslipRecordBone(),
      ),
    );
  }
}

class VisitsShimmer extends StatelessWidget {
  const VisitsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      physics: NeverScrollableScrollPhysics(),
      child: Shimmer(
        baseColor: Color(0xFFE4E1EF),
        highlightColor: Color(0xFFF8F7FC),
        child: Padding(
          padding: EdgeInsets.fromLTRB(16, 14, 16, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: ShimmerBox(height: 88, radius: 14)),
                  SizedBox(width: 8),
                  Expanded(child: ShimmerBox(height: 88, radius: 14)),
                  SizedBox(width: 8),
                  Expanded(child: ShimmerBox(height: 88, radius: 14)),
                ],
              ),
              SizedBox(height: 14),
              ShimmerBox(width: double.infinity, height: 210, radius: 18),
              SizedBox(height: 18),
              Row(
                children: [
                  ShimmerBox(width: 30, height: 30, radius: 9),
                  SizedBox(width: 8),
                  ShimmerBox(width: 110, height: 14, radius: 6),
                  SizedBox(width: 8),
                  ShimmerBox(width: 28, height: 18, radius: 999),
                ],
              ),
              SizedBox(height: 6),
              ShimmerBox(width: 200, height: 10, radius: 4),
              SizedBox(height: 14),
              ShimmerBox(width: double.infinity, height: 150, radius: 16),
              SizedBox(height: 10),
              ShimmerBox(width: double.infinity, height: 150, radius: 16),
              SizedBox(height: 10),
              ShimmerBox(width: double.infinity, height: 150, radius: 16),
              SizedBox(height: 16),
              ShimmerBox(width: double.infinity, height: 120, radius: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class IssuesShimmer extends StatelessWidget {
  const IssuesShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      physics: NeverScrollableScrollPhysics(),
      child: Shimmer(
        baseColor: Color(0xFFE4E1EF),
        highlightColor: Color(0xFFF8F7FC),
        child: Padding(
          padding: EdgeInsets.fromLTRB(16, 14, 16, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShimmerBox(width: double.infinity, height: 48, radius: 12),
              SizedBox(height: 14),
              Row(
                children: [
                  Expanded(child: ShimmerBox(height: 78, radius: 14)),
                  SizedBox(width: 8),
                  Expanded(child: ShimmerBox(height: 78, radius: 14)),
                  SizedBox(width: 8),
                  Expanded(child: ShimmerBox(height: 78, radius: 14)),
                ],
              ),
              SizedBox(height: 14),
              ShimmerBox(width: double.infinity, height: 128, radius: 16),
              SizedBox(height: 14),
              ShimmerBox(width: double.infinity, height: 96, radius: 16),
              SizedBox(height: 18),
              Row(
                children: [
                  ShimmerBox(width: 22, height: 22, radius: 6),
                  SizedBox(width: 8),
                  ShimmerBox(width: 100, height: 13, radius: 6),
                ],
              ),
              SizedBox(height: 12),
              _AdminListCardBone(),
              SizedBox(height: 10),
              _AdminListCardBone(),
              SizedBox(height: 10),
              _AdminListCardBone(),
              SizedBox(height: 10),
              _AdminListCardBone(),
            ],
          ),
        ),
      ),
    );
  }
}

class AdminDashboardShimmer extends StatelessWidget {
  const AdminDashboardShimmer({super.key});

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
              ShimmerBox(width: 180, height: 22, radius: 8),
              SizedBox(height: 8),
              ShimmerBox(width: 140, height: 12, radius: 6),
              SizedBox(height: 14),
              Row(
                children: [
                  Expanded(child: ShimmerBox(height: 40, radius: 12)),
                  SizedBox(width: 10),
                  Expanded(child: ShimmerBox(height: 40, radius: 12)),
                ],
              ),
              SizedBox(height: 14),
              ShimmerBox(width: double.infinity, height: 96, radius: 16),
              SizedBox(height: 12),
              ShimmerBox(width: double.infinity, height: 180, radius: 18),
              SizedBox(height: 12),
              ShimmerBox(width: double.infinity, height: 220, radius: 18),
              SizedBox(height: 12),
              ShimmerBox(width: double.infinity, height: 160, radius: 18),
              SizedBox(height: 12),
              ShimmerBox(width: double.infinity, height: 150, radius: 18),
              SizedBox(height: 12),
              ShimmerBox(width: double.infinity, height: 170, radius: 18),
              SizedBox(height: 12),
              ShimmerBox(width: double.infinity, height: 140, radius: 18),
            ],
          ),
        ),
      ),
    );
  }
}

class AdminListShimmer extends StatelessWidget {
  const AdminListShimmer({
    super.key,
    this.statCount = 4,
    this.cardCount = 5,
    this.showSearch = true,
    this.showFilters = true,
  });

  final int statCount;
  final int cardCount;
  final bool showSearch;
  final bool showFilters;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Shimmer(
        baseColor: const Color(0xFFE4E1EF),
        highlightColor: const Color(0xFFF8F7FC),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showSearch) ...[
                const ShimmerBox(width: double.infinity, height: 48, radius: 12),
                const SizedBox(height: 14),
              ],
              Row(
                children: [
                  for (var i = 0; i < statCount; i++) ...[
                    if (i > 0) const SizedBox(width: 8),
                    const Expanded(child: ShimmerBox(height: 78, radius: 14)),
                  ],
                ],
              ),
              if (showFilters) ...[
                const SizedBox(height: 14),
                const ShimmerBox(width: double.infinity, height: 96, radius: 16),
              ],
              const SizedBox(height: 18),
              const Row(
                children: [
                  ShimmerBox(width: 22, height: 22, radius: 6),
                  SizedBox(width: 8),
                  ShimmerBox(width: 120, height: 14, radius: 6),
                  Spacer(),
                  ShimmerBox(width: 60, height: 11, radius: 5),
                ],
              ),
              const SizedBox(height: 12),
              for (var i = 0; i < cardCount; i++) ...[
                if (i > 0) const SizedBox(height: 10),
                const _AdminListCardBone(),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class AdminListCardsShimmer extends StatelessWidget {
  const AdminListCardsShimmer({super.key, this.cardCount = 4});

  final int cardCount;

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      baseColor: const Color(0xFFE4E1EF),
      highlightColor: const Color(0xFFF8F7FC),
      child: Column(
        children: [
          for (var i = 0; i < cardCount; i++) ...[
            if (i > 0) const SizedBox(height: 10),
            const _AdminListCardBone(),
          ],
        ],
      ),
    );
  }
}

class DrawerShimmer extends StatelessWidget {
  const DrawerShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: EdgeInsets.fromLTRB(14, top + 12, 12, 16),
          color: const Color(0xFF161234),
          child: const Shimmer(
            baseColor: Color(0xFFE4E1EF),
            highlightColor: Color(0xFFF8F7FC),
            child: Row(
              children: [
                ShimmerBox(width: 44, height: 44, radius: 14),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShimmerBox(width: 120, height: 14, radius: 6),
                      SizedBox(height: 8),
                      ShimmerBox(width: 90, height: 10, radius: 5),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: ColoredBox(
            color: const Color(0xFFF8FAFC),
            child: SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
              child: Shimmer(
                baseColor: const Color(0xFFE4E1EF),
                highlightColor: const Color(0xFFF8F7FC),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        ShimmerBox(width: 72, height: 10, radius: 4),
                        Spacer(),
                        ShimmerBox(width: 40, height: 16, radius: 8),
                      ],
                    ),
                    const SizedBox(height: 12),
                    for (var i = 0; i < 6; i++) ...[
                      if (i > 0) const SizedBox(height: 8),
                      const _DrawerMenuBone(),
                    ],
                    const SizedBox(height: 18),
                    const ShimmerBox(width: 90, height: 10, radius: 4),
                    const SizedBox(height: 12),
                    for (var i = 0; i < 4; i++) ...[
                      if (i > 0) const SizedBox(height: 8),
                      const _DrawerMenuBone(),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _AdminListCardBone extends StatelessWidget {
  const _AdminListCardBone();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 14, 12, 12),
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
              ShimmerBox(width: 40, height: 40, radius: 12),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerBox(width: 130, height: 12, radius: 5),
                    SizedBox(height: 6),
                    ShimmerBox(width: 90, height: 9, radius: 4),
                  ],
                ),
              ),
              ShimmerBox(width: 56, height: 20, radius: 999),
            ],
          ),
          SizedBox(height: 12),
          ShimmerBox(width: double.infinity, height: 9, radius: 4),
          SizedBox(height: 6),
          ShimmerBox(width: 160, height: 9, radius: 4),
        ],
      ),
    );
  }
}

class _DrawerMenuBone extends StatelessWidget {
  const _DrawerMenuBone();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: PortalColors.surface,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: PortalColors.border),
      ),
      child: const Row(
        children: [
          ShimmerBox(width: 38, height: 38, radius: 12),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerBox(width: 100, height: 12, radius: 5),
                SizedBox(height: 6),
                ShimmerBox(width: 70, height: 9, radius: 4),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
