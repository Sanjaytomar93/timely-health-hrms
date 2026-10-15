import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:timelay_health/core/theme/app_logos.dart';
import 'package:timelay_health/core/theme/portal_text.dart';
import 'package:timelay_health/features/auth/presentation/bloc/login_cubit.dart';
import 'package:timelay_health/features/auth/presentation/widgets/login_form_pane.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final LoginCubit _loginCubit = LoginCubit();

  @override
  void dispose() {
    _loginCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 80;
    final brandHeight = keyboardOpen
        ? MediaQuery.paddingOf(context).top + 72
        : size.height * 0.42;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F3F9),
        resizeToAvoidBottomInset: true,
        body: Column(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(36),
              ),
              child: SizedBox(
                height: brandHeight,
                width: double.infinity,
                child: _BrandCanvas(compact: keyboardOpen),
              ),
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(32),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF26204A).withValues(alpha: 0.08),
                      blurRadius: 24,
                      offset: const Offset(0, -4),
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
                Color(0xFF1C1838),
                Color(0xFF2B2452),
                Color(0xFF3C3270),
                Color(0xFF4B4285),
              ],
              stops: [0.0, 0.35, 0.7, 1.0],
            ),
          ),
        ),
        Align(
          alignment: const Alignment(1.1, -1.1),
          child: _GlowOrb(
            size: 300,
            color: const Color(0xFF6D4AFF).withValues(alpha: 0.35),
          ),
        ),
        Align(
          alignment: const Alignment(-1.2, 1.1),
          child: _GlowOrb(
            size: 240,
            color: const Color(0xFF18AC96).withValues(alpha: 0.18),
          ),
        ),
        if (!compact) ...[
          const Positioned(top: -110, right: -120, child: _Rings(size: 320)),
          const Positioned(bottom: -90, left: -110, child: _Rings(size: 240)),
          Positioned(
            top: 110,
            right: 40,
            child: Transform.rotate(
              angle: 0.5,
              child: Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
        ],
        SafeArea(
          bottom: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              28,
              compact ? 12 : 20,
              28,
              compact ? 12 : 40,
            ),
            child: compact
                ? const ClipRect(
                    child: OverflowBox(
                      alignment: Alignment.topLeft,
                      maxHeight: double.infinity,
                      child: _BrandRow(markSize: 40),
                    ),
                  )
                : const _BrandHero(),
          ),
        ),
      ],
    );
  }
}

class _BrandHero extends StatelessWidget {
  const _BrandHero();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxHeight < 200) {
          return const ClipRect(
            child: OverflowBox(
              alignment: Alignment.topLeft,
              maxHeight: double.infinity,
              child: _BrandRow(markSize: 40),
            ),
          );
        }
        final tight = constraints.maxHeight < 280;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _BrandRow(markSize: tight ? 44 : 52),
            const Spacer(),
            const _GlassPill(
              letterSpacing: 1.2,
              child: Text('EMPLOYEE SELF SERVICE'),
            ),
            SizedBox(height: tight ? 10 : 14),
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Colors.white, Color(0xFFD9D2FF)],
              ).createShader(bounds),
              child: Text(
                'Welcome back.',
                style: portalText(
                  fontSize: tight ? 26 : 32,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.8,
                  height: 1.05,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your workday starts here.',
              style: portalText(
                fontSize: tight ? 13 : 14,
                fontWeight: FontWeight.w500,
                color: Colors.white.withValues(alpha: 0.75),
              ),
            ),
            SizedBox(height: tight ? 12 : 18),
            const _GlassPill(
              icon: Icons.verified_user_outlined,
              child: Text('Secure HR workspace'),
            ),
          ],
        );
      },
    );
  }
}

class _BrandRow extends StatelessWidget {
  const _BrandRow({required this.markSize});

  final double markSize;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _BrandMark(size: markSize),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Timely Health',
              style: portalText(
                fontSize: markSize > 44 ? 20 : 17,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: -0.4,
                height: 1.0,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'HRMS PORTAL',
              style: portalText(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: Colors.white.withValues(alpha: 0.6),
                letterSpacing: 1.6,
                height: 1.0,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _GlassPill extends StatelessWidget {
  const _GlassPill({required this.child, this.icon, this.letterSpacing = 0.2});

  final Widget child;
  final IconData? icon;
  final double letterSpacing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 12,
        vertical: icon == null ? 6 : 9,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.16),
            Colors.white.withValues(alpha: 0.06),
          ],
        ),
        borderRadius: BorderRadius.circular(icon == null ? 999 : 12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: const Color(0xFF5EEAD4)),
            const SizedBox(width: 8),
          ],
          DefaultTextStyle(
            style: portalText(
              fontSize: icon == null ? 10 : 12,
              fontWeight: FontWeight.w700,
              color: Colors.white.withValues(alpha: 0.92),
              letterSpacing: letterSpacing,
            ),
            child: child,
          ),
        ],
      ),
    );
  }
}

class _Rings extends StatelessWidget {
  const _Rings({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(painter: _RingsPainter()),
    );
  }
}

class _RingsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    for (var i = 0; i < 3; i++) {
      paint.color = Colors.white.withValues(alpha: 0.12 - i * 0.03);
      canvas.drawCircle(center, radius * (1 - i * 0.22), paint);
    }
    final dot = Paint()..color = Colors.white.withValues(alpha: 0.5);
    canvas.drawCircle(center + Offset(-radius * 0.707, radius * 0.707), 3, dot);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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
        gradient: RadialGradient(colors: [color, color.withValues(alpha: 0)]),
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
      padding: EdgeInsets.all(size * 0.22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.2),
            Colors.white.withValues(alpha: 0.06),
          ],
        ),
        borderRadius: BorderRadius.circular(size * 0.3),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.24),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6D4AFF).withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
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
