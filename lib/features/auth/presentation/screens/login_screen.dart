import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:timelay_health/core/theme/app_logos.dart';
import 'package:timelay_health/core/theme/portal_colors.dart';
import 'package:timelay_health/core/theme/portal_system_ui.dart';
import 'package:timelay_health/core/theme/portal_text.dart';
import 'package:timelay_health/features/auth/presentation/bloc/login_cubit.dart';
import 'package:timelay_health/features/auth/presentation/widgets/login_form_pane.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _intro;
  late final Animation<double> _brandFade;
  late final Animation<double> _logoScale;
  late final Animation<Offset> _sheetSlide;
  late final Animation<double> _sheetFade;
  late final LoginCubit _loginCubit;

  @override
  void initState() {
    super.initState();
    _loginCubit = LoginCubit();
    _intro = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _brandFade = CurvedAnimation(
      parent: _intro,
      curve: const Interval(0, 0.5, curve: Curves.easeOut),
    );
    _logoScale = Tween<double>(begin: 0.8, end: 1).animate(
      CurvedAnimation(
        parent: _intro,
        curve: const Interval(0.1, 0.6, curve: Curves.easeOutBack),
      ),
    );
    _sheetSlide = Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _intro,
            curve: const Interval(0.25, 1, curve: Curves.easeOutCubic),
          ),
        );
    _sheetFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _intro,
        curve: const Interval(0.3, 1, curve: Curves.easeOut),
      ),
    );
    _intro.forward();
  }

  @override
  void dispose() {
    _loginCubit.close();
    _intro.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 80;
    final brandHeight = keyboardOpen
        ? (MediaQuery.paddingOf(context).top + 70)
        : size.height * 0.42;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: PortalSystemUi.darkStatusBar,
      child: Scaffold(
        backgroundColor: const Color(0xFFFAFAFC),
        resizeToAvoidBottomInset: true,
        body: Column(
          children: [
            FadeTransition(
              opacity: _brandFade,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(40),
                ),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 280),
                  curve: Curves.easeOutCubic,
                  height: brandHeight,
                  width: double.infinity,
                  child: _BrandCanvas(compact: keyboardOpen),
                ),
              ),
            ),
            Expanded(
              child: SlideTransition(
                position: _sheetSlide,
                child: FadeTransition(
                  opacity: _sheetFade,
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAFAFC),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(40),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: PortalColors.brand.withValues(alpha: 0.08),
                          blurRadius: 32,
                          offset: const Offset(0, -8),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(40),
                      ),
                      child: BlocProvider.value(
                        value: _loginCubit,
                        child: const LoginFormPane(),
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

class _BrandCanvas extends StatelessWidget {
  const _BrandCanvas({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF1A1636),
                Color(0xFF26204A),
                Color(0xFF352D63),
                Color(0xFF4B4285),
              ],
              stops: [0.0, 0.3, 0.7, 1.0],
            ),
          ),
        ),
        if (!compact) ...[
          Positioned(
            top: -120,
            right: -80,
            child: _GlowOrb(
              size: 280,
              color: const Color(0xFF5B2FE0).withValues(alpha: 0.25),
            ),
          ),
          Positioned(
            top: -60,
            right: -30,
            child: _GlowOrb(
              size: 200,
              color: const Color(0xFF18AC96).withValues(alpha: 0.15),
            ),
          ),
          Positioned(
            bottom: -100,
            left: -70,
            child: _GlowOrb(
              size: 220,
              color: const Color(0xFF7C6FD4).withValues(alpha: 0.2),
            ),
          ),
          Positioned(
            top: 120,
            right: 50,
            child: _FloatingDiamond(
              size: 16,
              color: Colors.white.withValues(alpha: 0.15),
              rotation: 0.5,
            ),
          ),
          Positioned(
            bottom: 140,
            left: 40,
            child: _FloatingDiamond(
              size: 12,
              color: Colors.white.withValues(alpha: 0.1),
              rotation: -0.3,
            ),
          ),
          Positioned(
            top: 80,
            left: 30,
            child: _DotRing(size: 60, dotColor: Colors.white.withValues(alpha: 0.12)),
          ),
        ],
        SafeArea(
          bottom: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              32,
              compact ? 12 : 20,
              32,
              compact ? 12 : 24,
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final useCompact = compact || constraints.maxHeight < 200;
                if (useCompact) {
                  return Row(
                    children: [
                      _BrandMark(size: constraints.maxHeight < 40 ? 32 : 40),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Timely Health',
                            style: portalText(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: -0.3,
                              height: 1.0,
                            ),
                          ),
                          const SizedBox(height: 1),
                          Text(
                            'HRMS',
                            style: portalText(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Colors.white.withValues(alpha: 0.7),
                              letterSpacing: 1.5,
                              height: 1.0,
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                }

                return LayoutBuilder(
                  builder: (context, constraints) {
                    final isTight = constraints.maxHeight < 300;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            _BrandMark(size: isTight ? 44 : 52),
                            SizedBox(width: isTight ? 10 : 14),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Timely Health',
                                  style: portalText(
                                    fontSize: isTight ? 17 : 20,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    letterSpacing: -0.4,
                                    height: 1.0,
                                  ),
                                ),
                                SizedBox(height: isTight ? 1 : 2),
                                Text(
                                  'HRMS PORTAL',
                                  style: portalText(
                                    fontSize: isTight ? 9 : 10,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white.withValues(alpha: 0.65),
                                    letterSpacing: isTight ? 1.2 : 1.4,
                                    height: 1.0,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: isTight ? 8 : 16),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: isTight ? 10 : 12,
                            vertical: isTight ? 4 : 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.18),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.business_center_rounded,
                                size: isTight ? 12 : 14,
                                color: Colors.white.withValues(alpha: 0.9),
                              ),
                              SizedBox(width: isTight ? 6 : 8),
                              Text(
                                'EMPLOYEE SELF SERVICE',
                                style: portalText(
                                  fontSize: isTight ? 9 : 10,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white.withValues(alpha: 0.9),
                                  letterSpacing: isTight ? 1.0 : 1.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: isTight ? 8 : 16),
                        Text(
                          'Welcome back',
                          style: portalText(
                            fontSize: isTight ? 24 : 30,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -0.7,
                            height: 1.0,
                          ),
                        ),
                        SizedBox(height: isTight ? 4 : 6),
                        Text(
                          'Manage your HR experience seamlessly',
                          style: portalText(
                            fontSize: isTight ? 11 : 13.5,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withValues(alpha: 0.75),
                            height: 1.1,
                          ),
                        ),
                        SizedBox(height: isTight ? 8 : 16),
                        const _SecureWorkspacePill(),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color,
            color.withValues(alpha: 0),
          ],
          stops: const [0.0, 1.0],
        ),
      ),
    );
  }
}

class _FloatingDiamond extends StatelessWidget {
  const _FloatingDiamond({
    required this.size,
    required this.color,
    required this.rotation,
  });

  final double size;
  final Color color;
  final double rotation;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: rotation,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(3),
        ),
      ),
    );
  }
}

class _DotRing extends StatelessWidget {
  const _DotRing({required this.size, required this.dotColor});

  final double size;
  final Color dotColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          for (int i = 0; i < 8; i++)
            Positioned(
              top: size / 2 - 2,
              child: Transform.rotate(
                angle: (i * 45) * 3.14159 / 180,
                child: Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    color: dotColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _BrandMark extends StatelessWidget {
  const _BrandMark({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(size * 0.20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.18),
            Colors.white.withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(size * 0.28),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.22),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: const Color(0xFF5B2FE0).withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SvgPicture.asset(
        AppLogos.mark,
        fit: BoxFit.contain,
        colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
      ),
    );
  }
}

class _SecureWorkspacePill extends StatelessWidget {
  const _SecureWorkspacePill();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.12),
            Colors.white.withValues(alpha: 0.06),
          ],
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.18),
          width: 1.2,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFF18AC96).withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              Icons.verified_user_rounded,
              size: 12,
              color: const Color(0xFF18AC96),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            'Safe & secure login',
            style: portalText(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: Colors.white.withValues(alpha: 0.95),
              letterSpacing: 0.2,
              height: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}
