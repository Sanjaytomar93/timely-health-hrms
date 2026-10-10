import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:timelay_health/core/theme/app_logos.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timelay_health/core/theme/portal_colors.dart';
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
  late final AnimationController _intro;
  late final AnimationController _progress;
  late final Animation<double> _fade;
  late final Animation<double> _scale;
  late final Animation<double> _load;

  @override
  void initState() {
    super.initState();
    _intro = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _progress = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fade = CurvedAnimation(
      parent: _intro,
      curve: const Interval(0, 0.7, curve: Curves.easeOut),
    );
    _scale = Tween<double>(begin: 0.92, end: 1).animate(
      CurvedAnimation(
        parent: _intro,
        curve: const Interval(0, 0.85, curve: Curves.easeOutCubic),
      ),
    );
    _load = CurvedAnimation(parent: _progress, curve: Curves.easeInOutCubic);
    _intro.forward();
    _progress.forward();
    _boot();
  }

  Future<void> _boot() async {
    final sessionFuture = AuthSession.load();
    await Future.wait([
      sessionFuture,
      Future<void>.delayed(const Duration(milliseconds: 900)),
      _progress.forward(),
    ]);
    if (!mounted) return;
    final employee = await sessionFuture;
    if (!mounted) return;
    final next = employee != null
        ? const EmployeeHomeShell()
        : const LoginScreen();
    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        pageBuilder: (context, animation, secondaryAnimation) => next,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 280),
      ),
    );
  }

  @override
  void dispose() {
    _intro.dispose();
    _progress.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: PortalSystemUi.darkStatusBar,
      child: Scaffold(
        backgroundColor: PortalColors.brand,
        body: Stack(
          fit: StackFit.expand,
          children: [
            SafeArea(
              child: FadeTransition(
                opacity: _fade,
                child: ScaleTransition(
                  scale: _scale,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 36),
                    child: Column(
                      children: [
                        const Spacer(flex: 3),
                        SvgPicture.asset(
                          AppLogos.mark,
                          width: 150,
                          height: 150,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(height: 22),
                        Text(
                          'TIMELY\nHEALTH',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.montserrat(
                            fontSize: 34,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 3,
                            height: 1.05,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Connecting Communities...',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.caveat(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            height: 1.1,
                          ),
                        ),
                        const Spacer(flex: 2),
                        Text(
                          'Empowering People',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withValues(alpha: 0.95),
                            height: 1.35,
                          ),
                        ),
                        Text(
                          'Enabling Communities',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withValues(alpha: 0.95),
                            height: 1.35,
                          ),
                        ),
                        const Spacer(flex: 3),
                        AnimatedBuilder(
                          animation: _load,
                          builder: (context, child) {
                            return Column(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(999),
                                  child: SizedBox(
                                    width: 168,
                                    height: 4,
                                    child: LinearProgressIndicator(
                                      value: _load.value.clamp(0.08, 1),
                                      backgroundColor: Colors.white.withValues(
                                        alpha: 0.28,
                                      ),
                                      valueColor:
                                          const AlwaysStoppedAnimation<Color>(
                                            Colors.white,
                                          ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Loading...',
                                  style: GoogleFonts.inter(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white.withValues(alpha: 0.92),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 42),
                      ],
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
