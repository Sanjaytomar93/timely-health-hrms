import 'dart:async';

import 'package:flutter/material.dart';
import 'package:timelay_health/core/routes/app_routes.dart';
import 'package:timelay_health/core/theme/portal_colors.dart';
import 'package:timelay_health/core/theme/portal_text.dart';

Future<void> showLoginSuccessAndGoHome(
  BuildContext context, {
  required String displayName,
  required String role,
  Duration redirectAfter = const Duration(seconds: 5),
}) {
  return showGeneralDialog<void>(
    context: context,
    useRootNavigator: true,
    barrierDismissible: true,
    barrierLabel: 'Dismiss',
    barrierColor: Colors.black.withValues(alpha: 0.45),
    transitionDuration: const Duration(milliseconds: 280),
    pageBuilder: (context, animation, secondaryAnimation) {
      return LoginSuccessDialog(
        displayName: displayName,
        role: role,
        redirectAfter: redirectAfter,
      );
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      );
      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.92, end: 1).animate(curved),
          child: child,
        ),
      );
    },
  );
}

class LoginSuccessDialog extends StatefulWidget {
  const LoginSuccessDialog({
    super.key,
    required this.displayName,
    required this.role,
    required this.redirectAfter,
  });

  final String displayName;
  final String role;
  final Duration redirectAfter;

  @override
  State<LoginSuccessDialog> createState() => _LoginSuccessDialogState();
}

class _LoginSuccessDialogState extends State<LoginSuccessDialog>
    with SingleTickerProviderStateMixin {
  static const _gradStart = Color(0xFF45B69F);
  static const _gradMid = Color(0xFF4F83CC);
  static const _gradEnd = Color(0xFF9C75EB);

  late final AnimationController _progress;
  Timer? _tick;
  late int _secondsLeft;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    _secondsLeft = widget.redirectAfter.inSeconds;
    _progress = AnimationController(vsync: this, duration: widget.redirectAfter)
      ..forward();

    _progress.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _goHome();
      }
    });

    _tick = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_secondsLeft <= 1) {
        timer.cancel();
        setState(() => _secondsLeft = 0);
        return;
      }
      setState(() => _secondsLeft -= 1);
    });
  }

  @override
  void dispose() {
    _tick?.cancel();
    _progress.dispose();
    super.dispose();
  }

  void _goHome() {
    if (_navigated || !mounted) return;
    _navigated = true;
    _tick?.cancel();

    Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil(
      AppRoutes.home,
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final dialogWidth = (width - 48).clamp(280.0, 340.0);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _goHome();
      },
      child: GestureDetector(
        onTap: _goHome,
        behavior: HitTestBehavior.opaque,
        child: Center(
          child: GestureDetector(
            onTap: () {},
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: dialogWidth,
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.fromLTRB(22, 18, 18, 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 32,
                      offset: const Offset(0, 16),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Align(
                      alignment: Alignment.topRight,
                      child: InkWell(
                        onTap: _goHome,
                        borderRadius: BorderRadius.circular(20),
                        child: const Padding(
                          padding: EdgeInsets.all(4),
                          child: Icon(
                            Icons.close_rounded,
                            size: 20,
                            color: Color(0xFFB0AEBE),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [_gradStart, _gradMid],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: _gradStart.withValues(alpha: 0.35),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.sentiment_satisfied_alt_rounded,
                        color: Colors.white,
                        size: 38,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: 'Welcome, ',
                            style: portalText(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: PortalColors.heading,
                            ),
                          ),
                          WidgetSpan(
                            alignment: PlaceholderAlignment.baseline,
                            baseline: TextBaseline.alphabetic,
                            child: ShaderMask(
                              blendMode: BlendMode.srcIn,
                              shaderCallback: (bounds) => const LinearGradient(
                                colors: [_gradStart, _gradMid],
                              ).createShader(bounds),
                              child: Text(
                                '${widget.displayName}!',
                                style: portalText(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (widget.role.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F4F8),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFE4E2EC)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.person_outline_rounded,
                              size: 14,
                              color: Color(0xFF6B697C),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              widget.role,
                              style: portalText(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF6B697C),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    Text.rich(
                      TextSpan(
                        style: portalText(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF6B697C),
                          height: 1.4,
                        ),
                        children: [
                          const TextSpan(
                            text: 'You have been successfully logged in to ',
                          ),
                          TextSpan(
                            text: 'Timely Health',
                            style: portalText(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w800,
                              color: PortalColors.heading,
                            ),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 14),
                    Text(
                      '⌛ Redirecting to dashboard in $_secondsLeft seconds...',
                      textAlign: TextAlign.center,
                      style: portalText(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFFA09EAE),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '🔊 Voice speaking...',
                      style: portalText(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF9A7BE8),
                      ),
                    ),
                    const SizedBox(height: 18),
                    AnimatedBuilder(
                      animation: _progress,
                      builder: (context, _) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: SizedBox(
                            height: 8,
                            width: double.infinity,
                            child: Stack(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEFEDF5),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                ),
                                FractionallySizedBox(
                                  widthFactor: _progress.value.clamp(0.0, 1.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(999),
                                      gradient: const LinearGradient(
                                        colors: [
                                          _gradStart,
                                          _gradMid,
                                          _gradEnd,
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Click anywhere to dismiss',
                      style: portalText(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFFB0AEBE),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
