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

/// Mirrors the dashboard layout: greeting, profile, attendance banner,
/// stat cards, quick actions and a chart.
class DashboardShimmer extends StatelessWidget {
  const DashboardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      physics: NeverScrollableScrollPhysics(),
      child: Shimmer(
        child: Padding(
          padding: EdgeInsets.fromLTRB(12, 20, 12, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShimmerBox(width: 220, height: 20),
              SizedBox(height: 10),
              ShimmerBox(width: 150, height: 12),
              SizedBox(height: 18),
              ShimmerBox(width: double.infinity, height: 84, radius: 18),
              SizedBox(height: 16),
              ShimmerBox(width: double.infinity, height: 173, radius: 18),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: ShimmerBox(height: 76, radius: 14)),
                  SizedBox(width: 10),
                  Expanded(child: ShimmerBox(height: 76, radius: 14)),
                  SizedBox(width: 10),
                  Expanded(child: ShimmerBox(height: 76, radius: 14)),
                ],
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ShimmerBox(width: 64, height: 64, radius: 16),
                  ShimmerBox(width: 64, height: 64, radius: 16),
                  ShimmerBox(width: 64, height: 64, radius: 16),
                  ShimmerBox(width: 64, height: 64, radius: 16),
                ],
              ),
              SizedBox(height: 16),
              ShimmerBox(width: double.infinity, height: 200, radius: 18),
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
