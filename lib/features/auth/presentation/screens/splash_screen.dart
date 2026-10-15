import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timelay_health/core/theme/app_logos.dart';
import 'package:timelay_health/core/theme/portal_system_ui.dart';
import 'package:timelay_health/core/routes/app_routes.dart';
import 'package:timelay_health/features/auth/data/auth_session.dart';

const _bgTop = Color(0xFF2D2060);
const _bgBottom = Color(0xFF14102B);
const _teal = Color(0xFF18AC96);
const _violet = Color(0xFF7C6FD4);

const _splashDuration = Duration(milliseconds: 3200);

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _intro = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  )..forward();

  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  )..repeat();

  @override
  void initState() {
    super.initState();
    _boot();
  }

  Future<void> _boot() async {
    final results = await Future.wait<dynamic>([
      AuthSession.load(),
      Future<void>.delayed(_splashDuration),
    ]);
    if (!mounted) return;
    final nextRoute = results.first != null ? AppRoutes.home : AppRoutes.login;
    AppRoutes.pushReplacement(context, nextRoute);
  }

  @override
  void dispose() {
    _intro.dispose();
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: PortalSystemUi.darkStatusBar,
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0, -0.3),
              radius: 1.2,
              colors: [_bgTop, _bgBottom],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 5),
                _Reveal(
                  animation: _intro,
                  interval: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
                  scale: true,
                  child: _PulsingLogo(pulse: _pulse),
                ),
                const SizedBox(height: 40),
                _Reveal(
                  animation: _intro,
                  interval: const Interval(0.3, 0.8, curve: Curves.easeOutCubic),
                  child: const _Title(),
                ),
                const SizedBox(height: 16),
                _Reveal(
                  animation: _intro,
                  interval: const Interval(0.5, 1.0, curve: Curves.easeOutCubic),
                  child: Text(
                    'Empowering People · Enabling Communities',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.55),
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
                const Spacer(flex: 4),
                _Reveal(
                  animation: _intro,
                  interval: const Interval(0.6, 1.0),
                  child: const _ProgressBar(),
                ),
                const SizedBox(height: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Fades and slides [child] up (optionally scaling it) during [interval].
class _Reveal extends StatelessWidget {
  const _Reveal({
    required this.animation,
    required this.interval,
    required this.child,
    this.scale = false,
  });

  final Animation<double> animation;
  final Interval interval;
  final Widget child;
  final bool scale;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      child: child,
      builder: (_, child) {
        final t = interval.transform(animation.value);
        return Opacity(
          opacity: t.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, 24 * (1 - t)),
            child: Transform.scale(
              scale: scale ? 0.6 + 0.4 * t : 1,
              child: child,
            ),
          ),
        );
      },
    );
  }
}

class _PulsingLogo extends StatelessWidget {
  const _PulsingLogo({required this.pulse});

  final Animation<double> pulse;

  static const _logoSize = 120.0;
  static const _ringCount = 3;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: _logoSize * 2.2,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: pulse,
            builder: (_, _) => Stack(
              alignment: Alignment.center,
              children: [
                for (var i = 0; i < _ringCount; i++)
                  _ring((pulse.value + i / _ringCount) % 1),
              ],
            ),
          ),
          Container(
            width: _logoSize,
            height: _logoSize,
            padding: const EdgeInsets.all(26),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [_violet, _teal],
              ),
              boxShadow: [
                BoxShadow(
                  color: _violet.withValues(alpha: 0.6),
                  blurRadius: 40,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: SvgPicture.asset(
              AppLogos.mark,
              fit: BoxFit.contain,
              colorFilter:
                  const ColorFilter.mode(Colors.white, BlendMode.srcIn),
            ),
          ),
        ],
      ),
    );
  }

  Widget _ring(double t) {
    final size = _logoSize + _logoSize * 1.2 * t;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: _teal.withValues(alpha: 0.5 * (1 - t)),
          width: 1.5,
        ),
      ),
    );
  }
}

class _Title extends StatelessWidget {
  const _Title();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Colors.white, Color(0xFFCFC8FF)],
          ).createShader(bounds),
          child: Text(
            'TIMELY HEALTH',
            style: GoogleFonts.montserrat(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: 4,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'HRMS PORTAL',
          style: GoogleFonts.montserrat(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: _teal,
            letterSpacing: 6,
          ),
        ),
      ],
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar();

  static const _width = 160.0;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: _splashDuration,
      curve: Curves.easeInOut,
      builder: (_, value, _) => Container(
        width: _width,
        height: 4,
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(99),
        ),
        child: Container(
          width: _width * value,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(99),
            gradient: const LinearGradient(colors: [_teal, _violet]),
            boxShadow: [
              BoxShadow(color: _teal.withValues(alpha: 0.6), blurRadius: 8),
            ],
          ),
        ),
      ),
    );
  }
}
