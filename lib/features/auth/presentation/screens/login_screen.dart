import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:timelay_health/core/theme/app_logos.dart';
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
  late final Animation<Offset> _sheetSlide;
  late final LoginCubit _loginCubit;

  @override
  void initState() {
    super.initState();
    _loginCubit = LoginCubit();
    _intro = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _brandFade = CurvedAnimation(
      parent: _intro,
      curve: const Interval(0, 0.55, curve: Curves.easeOut),
    );
    _sheetSlide = Tween<Offset>(begin: const Offset(0, 0.14), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _intro,
            curve: const Interval(0.18, 1, curve: Curves.easeOutCubic),
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
        ? (MediaQuery.paddingOf(context).top + 64)
        : size.height * 0.40;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: PortalSystemUi.darkStatusBar,
      child: Scaffold(
        backgroundColor: const Color(0xFF1A1235),
        resizeToAvoidBottomInset: true,
        body: Column(
          children: [
            FadeTransition(
              opacity: _brandFade,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(32),
                ),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
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
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFCFCFE),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(32),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x55000000),
                        blurRadius: 36,
                        offset: Offset(0, -6),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(32),
                    ),
                    child: BlocProvider.value(
                      value: _loginCubit,
                      child: const LoginFormPane(),
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
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF1A1535),
                Color(0xFF26204A),
                Color(0xFF2D2060),
                Color(0xFF1E1A42),
              ],
              stops: [0.0, 0.38, 0.72, 1.0],
            ),
          ),
        ),
        if (!compact) ...[
          Positioned(
            top: -50,
            right: -40,
            child: _Orb(
              size: 220,
              color: const Color(0xFF7C6FD4).withValues(alpha: 0.35),
            ),
          ),
          Positioned(
            bottom: 40,
            left: -60,
            child: _Orb(
              size: 170,
              color: const Color(0xFF18AC96).withValues(alpha: 0.12),
            ),
          ),
          Positioned(
            right: 24,
            bottom: 48,
            child: CustomPaint(
              size: const Size(110, 110),
              painter: _ArcMotifPainter(),
            ),
          ),
        ],
        SafeArea(
          bottom: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              28,
              compact ? 8 : 20,
              28,
              compact ? 8 : 28,
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final useCompact = compact || constraints.maxHeight < 200;
                if (useCompact) {
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: SvgPicture.asset(
                      AppLogos.white,
                      height: constraints.maxHeight < 40 ? 28 : 36,
                      fit: BoxFit.contain,
                      alignment: Alignment.centerLeft,
                    ),
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SvgPicture.asset(
                      AppLogos.white,
                      height: 64,
                      fit: BoxFit.contain,
                      alignment: Alignment.centerLeft,
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Text(
                        'ATTENDANCE PORTAL',
                        style: portalText(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Colors.white.withValues(alpha: 0.92),
                          letterSpacing: 1.4,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Every check-in\ntells your story.',
                      style: portalText(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: -0.5,
                        height: 1.18,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      'Be present. Be counted. Be ahead.',
                      style: portalText(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _Orb extends StatelessWidget {
  const _Orb({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    const spread = 60.0;
    final outer = size + spread * 2;
    final solidStop = (size / 2 - spread / 2) / (outer / 2);
    return SizedBox(
      width: size,
      height: size,
      child: OverflowBox(
        maxWidth: outer,
        maxHeight: outer,
        child: IgnorePointer(
          child: Container(
            width: outer,
            height: outer,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [color, color, color.withValues(alpha: 0)],
                stops: [0, solidStop, 1],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ArcMotifPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.55, size.height * 0.55);
    final paint = Paint()..isAntiAlias = true;

    const count = 18;
    for (var i = 0; i < count; i++) {
      final t = i / (count - 1);
      final angle = -2.15 + t * 2.55;
      final r = size.width * 0.42;
      final x = center.dx + r * math.cos(angle);
      final y = center.dy + r * math.sin(angle);
      paint.color = Color.lerp(
        const Color(0xFF67E8F9),
        const Color(0xFFC4B5FD),
        t,
      )!.withValues(alpha: 0.55);
      canvas.drawCircle(Offset(x, y), 2.2 + t * 1.5, paint);
    }

    final check = Paint()
      ..color = Colors.white.withValues(alpha: 0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final path = Path()
      ..moveTo(size.width * 0.34, size.height * 0.54)
      ..lineTo(size.width * 0.48, size.height * 0.66)
      ..lineTo(size.width * 0.72, size.height * 0.38);
    canvas.drawPath(path, check);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
