import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:timelay_health/core/theme/app_logos.dart';
import 'package:timelay_health/core/theme/portal_text.dart';

class LoginBrandCanvas extends StatelessWidget {
  const LoginBrandCanvas({super.key, required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1C1838),
            Color(0xFF2B2452),
            Color(0xFF3C3270),
            Color(0xFF4B4285),
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            28,
            compact ? 12 : 20,
            28,
            compact ? 12 : 36,
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
            _BrandRow(markSize: tight ? 46 : 54),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
              ),
              child: Text(
                'EMPLOYEE SELF SERVICE',
                style: portalText(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Colors.white.withValues(alpha: 0.9),
                  letterSpacing: 1.2,
                ),
              ),
            ),
            SizedBox(height: tight ? 12 : 16),
            Text(
              'Ready for\ntoday’s shift?',
              style: portalText(
                fontSize: tight ? 26 : 32,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: -0.7,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Sign in to manage attendance, leaves & more.',
              style: portalText(
                fontSize: tight ? 12.5 : 13.5,
                fontWeight: FontWeight.w500,
                color: Colors.white.withValues(alpha: 0.75),
              ),
            ),
            SizedBox(height: tight ? 12 : 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.verified_user_outlined,
                    size: 15,
                    color: Color(0xFF5EEAD4),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Secure HR workspace',
                    style: portalText(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withValues(alpha: 0.92),
                    ),
                  ),
                ],
              ),
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
        Container(
          width: markSize,
          height: markSize,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(markSize * 0.28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.22),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: SvgPicture.asset(AppLogos.appIcon, fit: BoxFit.cover),
        ),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Timely Health',
              style: portalText(
                fontSize: markSize > 48 ? 20 : 17,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              'HRMS PORTAL',
              style: portalText(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: Colors.white.withValues(alpha: 0.65),
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
