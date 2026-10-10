import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timelay_health/core/theme/app_logos.dart';
import 'package:timelay_health/core/theme/portal_system_ui.dart';
import 'package:timelay_health/features/auth/data/auth_session.dart';
import 'package:timelay_health/features/auth/presentation/screens/login_screen.dart';
import 'package:timelay_health/features/dashboard/presentation/screens/employee_home_shell.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // Logo entrance
  late final AnimationController _logoCtrl;
  late final Animation<double> _logoFade;
  late final Animation<double> _logoScale;
  late final Animation<Offset> _logoSlide;

  // Title entrance
  late final AnimationController _titleCtrl;
  late final Animation<double> _titleFade;
  late final Animation<Offset> _titleSlide;

  // Tagline entrance
  late final AnimationController _tagCtrl;
  late final Animation<double> _tagFade;
  late final Animation<Offset> _tagSlide;

  // Progress bar fill
  late final AnimationController _progressCtrl;
  late final Animation<double> _progressFill;

  // Floating orbs rotation
  late final AnimationController _orbCtrl;

  // Dot pulse
  late final AnimationController _dotCtrl;

  @override
  void initState() {
    super.initState();
    _initControllers();
    _runSequence();
    _boot();
  }

  void _initControllers() {
    // Logo
    _logoCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    );
    _logoFade = CurvedAnimation(parent: _logoCtrl, curve: Curves.easeOut);
    _logoScale = Tween<double>(begin: 0.60, end: 1.0).animate(
      CurvedAnimation(parent: _logoCtrl, curve: Curves.elasticOut),
    );
    _logoSlide = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _logoCtrl, curve: Curves.easeOutCubic));

    // Title
    _titleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _titleFade = CurvedAnimation(parent: _titleCtrl, curve: Curves.easeOut);
    _titleSlide = Tween<Offset>(
      begin: const Offset(0, 0.35),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _titleCtrl, curve: Curves.easeOutCubic));

    // Tagline
    _tagCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );
    _tagFade = CurvedAnimation(parent: _tagCtrl, curve: Curves.easeOut);
    _tagSlide = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _tagCtrl, curve: Curves.easeOutCubic));

    // Progress bar
    _progressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 8500),
    );
    _progressFill = CurvedAnimation(
      parent: _progressCtrl,
      curve: Curves.easeInOutSine,
    );

    // Orb rotation — infinite slow spin
    _orbCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();

    // Dot pulse — infinite
    _dotCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  Future<void> _runSequence() async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    _logoCtrl.forward();
    await Future<void>.delayed(const Duration(milliseconds: 340));
    _titleCtrl.forward();
    await Future<void>.delayed(const Duration(milliseconds: 260));
    _tagCtrl.forward();
    await Future<void>.delayed(const Duration(milliseconds: 300));
    _progressCtrl.forward();
  }

  Future<void> _boot() async {
    final sessionFuture = AuthSession.load();
    await Future.wait<dynamic>([
      sessionFuture,
      Future<void>.delayed(const Duration(seconds: 10)),
    ]);
    if (!mounted) return;
    final employee = await sessionFuture;
    if (!mounted) return;
    final next = employee != null
        ? const EmployeeHomeShell()
        : const LoginScreen();
    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        pageBuilder: (_, animation, __) => next,
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 320),
      ),
    );
  }

  @override
  void dispose() {
    _logoCtrl.dispose();
    _titleCtrl.dispose();
    _tagCtrl.dispose();
    _progressCtrl.dispose();
    _orbCtrl.dispose();
    _dotCtrl.dispose();
    super.dispose();
  }

  // ── Build ────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: PortalSystemUi.darkStatusBar,
      child: Scaffold(
        backgroundColor: const Color(0xFF1A1535),
        body: Stack(
          fit: StackFit.expand,
          children: [
            // Background gradient
            const _GradientBackground(),

            // Floating decorative orbs
            AnimatedBuilder(
              animation: _orbCtrl,
              builder: (_, __) => _FloatingOrbs(progress: _orbCtrl.value),
            ),

            // Main content
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  children: [
                    const Spacer(flex: 5),

                    // ── Logo ──────────────────────────────
                    FadeTransition(
                      opacity: _logoFade,
                      child: SlideTransition(
                        position: _logoSlide,
                        child: ScaleTransition(
                          scale: _logoScale,
                          child: _LogoContainer(),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // ── Brand name ────────────────────────
                    FadeTransition(
                      opacity: _titleFade,
                      child: SlideTransition(
                        position: _titleSlide,
                        child: const _BrandTitle(),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // ── Tagline ───────────────────────────
                    FadeTransition(
                      opacity: _tagFade,
                      child: SlideTransition(
                        position: _tagSlide,
                        child: const _Tagline(),
                      ),
                    ),

                    const Spacer(flex: 4),

                    // ── Progress section ──────────────────
                    FadeTransition(
                      opacity: _tagFade,
                      child: _ProgressSection(
                        fill: _progressFill,
                        dotAnim: _dotCtrl,
                      ),
                    ),

                    const SizedBox(height: 48),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Gradient Background
// ─────────────────────────────────────────────

class _GradientBackground extends StatelessWidget {
  const _GradientBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1A1535), // near-black purple
            Color(0xFF26204A), // brand deep purple
            Color(0xFF2D2060), // rich purple
            Color(0xFF1E1A42), // dark indigo
          ],
          stops: [0.0, 0.38, 0.72, 1.0],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Floating Orbs (decorative background circles)
// ─────────────────────────────────────────────

class _FloatingOrbs extends StatelessWidget {
  const _FloatingOrbs({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final angle = progress * 2 * math.pi;

    return Stack(
      children: [
        // Top-right large orb
        Positioned(
          top: -size.height * 0.08 + math.sin(angle) * 18,
          right: -size.width * 0.18 + math.cos(angle) * 12,
          child: _Orb(diameter: size.width * 0.72, opacity: 0.13),
        ),
        // Bottom-left medium orb
        Positioned(
          bottom: size.height * 0.10 + math.cos(angle) * 14,
          left: -size.width * 0.22 + math.sin(angle) * 10,
          child: _Orb(diameter: size.width * 0.62, opacity: 0.10),
        ),
        // Center accent orb (small)
        Positioned(
          top: size.height * 0.30 + math.sin(angle * 1.3) * 8,
          right: size.width * 0.06 + math.cos(angle * 0.9) * 6,
          child: _Orb(
            diameter: size.width * 0.22,
            opacity: 0.18,
            color: const Color(0xFF7C6FD4),
          ),
        ),
        // Bottom-right tiny orb
        Positioned(
          bottom: size.height * 0.22 + math.cos(angle * 0.7) * 10,
          right: size.width * 0.10,
          child: _Orb(
            diameter: size.width * 0.14,
            opacity: 0.22,
            color: const Color(0xFF18AC96),
          ),
        ),
      ],
    );
  }
}

class _Orb extends StatelessWidget {
  const _Orb({
    required this.diameter,
    required this.opacity,
    this.color = const Color(0xFF4B4285),
  });

  final double diameter;
  final double opacity;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color.withValues(alpha: opacity),
            color.withValues(alpha: 0),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Logo Container with glassmorphism card
// ─────────────────────────────────────────────

class _LogoContainer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 136,
      height: 136,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF3D3472),
            Color(0xFF26204A),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4B4285).withValues(alpha: 0.55),
            blurRadius: 48,
            spreadRadius: 4,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.14),
          width: 1.5,
        ),
      ),
      padding: const EdgeInsets.all(28),
      child: SvgPicture.asset(
        AppLogos.mark,
        fit: BoxFit.contain,
        colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Brand Title
// ─────────────────────────────────────────────

class _BrandTitle extends StatelessWidget {
  const _BrandTitle();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Thin accent line above title
        Container(
          width: 40,
          height: 2,
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(99),
            gradient: const LinearGradient(
              colors: [Color(0xFF18AC96), Color(0xFF7C6FD4)],
            ),
          ),
        ),
        Text(
          'TIMELY HEALTH',
          textAlign: TextAlign.center,
          style: GoogleFonts.montserrat(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: 4.5,
            height: 1.0,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'HRMS PORTAL',
          textAlign: TextAlign.center,
          style: GoogleFonts.montserrat(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: Colors.white.withValues(alpha: 0.45),
            letterSpacing: 5,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// Tagline
// ─────────────────────────────────────────────

class _Tagline extends StatelessWidget {
  const _Tagline();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Divider with dots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _dot(),
            const SizedBox(width: 8),
            Text(
              'Empowering People · Enabling Communities',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: Colors.white.withValues(alpha: 0.52),
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(width: 8),
            _dot(),
          ],
        ),
      ],
    );
  }

  Widget _dot() => Container(
        width: 4,
        height: 4,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF18AC96).withValues(alpha: 0.7),
        ),
      );
}

// ─────────────────────────────────────────────
// Progress Section
// ─────────────────────────────────────────────

class _ProgressSection extends StatelessWidget {
  const _ProgressSection({
    required this.fill,
    required this.dotAnim,
  });

  final Animation<double> fill;
  final AnimationController dotAnim;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Animated progress bar
        AnimatedBuilder(
          animation: fill,
          builder: (_, __) {
            return Column(
              children: [
                Stack(
                  children: [
                    // Track
                    Container(
                      width: 180,
                      height: 3,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(99),
                        color: Colors.white.withValues(alpha: 0.12),
                      ),
                    ),
                    // Fill with gradient
                    ClipRRect(
                      borderRadius: BorderRadius.circular(99),
                      child: Container(
                        width: 180 * fill.value.clamp(0.06, 1.0),
                        height: 3,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(99),
                          gradient: const LinearGradient(
                            colors: [Color(0xFF18AC96), Color(0xFF7C6FD4)],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  const Color(0xFF18AC96).withValues(alpha: 0.6),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),

        const SizedBox(height: 16),

        // Animated loading dots + label
        AnimatedBuilder(
          animation: dotAnim,
          builder: (_, __) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Loading',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.45),
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(width: 4),
                _PulseDot(delay: 0.0, anim: dotAnim),
                const SizedBox(width: 3),
                _PulseDot(delay: 0.25, anim: dotAnim),
                const SizedBox(width: 3),
                _PulseDot(delay: 0.5, anim: dotAnim),
              ],
            );
          },
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// Pulse Dot (loading indicator dot)
// ─────────────────────────────────────────────

class _PulseDot extends StatelessWidget {
  const _PulseDot({required this.delay, required this.anim});

  final double delay;
  final AnimationController anim;

  @override
  Widget build(BuildContext context) {
    // Offset animation value by delay (wrap-around 0..1)
    final raw = (anim.value + delay) % 1.0;
    final opacity = 0.25 + (raw < 0.5 ? raw * 1.5 : (1.0 - raw) * 1.5);

    return Container(
      width: 4,
      height: 4,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: opacity.clamp(0.25, 1.0)),
      ),
    );
  }
}
