import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:timelay_health/core/theme/portal_text.dart';
import 'package:timelay_health/features/auth/domain/entities/employee.dart';

class ProfileWelcomeBanner extends StatelessWidget {
  const ProfileWelcomeBanner({super.key, required this.employee});

  final Employee employee;

  @override
  Widget build(BuildContext context) {
    final first = employee.displayName.split(RegExp(r'\s+')).first;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          begin: Alignment(-0.85, -0.4),
          end: Alignment(0.9, 0.8),
          colors: [Color(0xFF26204A), Color(0xFF4B4285)],
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            right: -30,
            top: -32,
            child: Container(
              width: 140,
              height: 140,
              decoration: const BoxDecoration(
                color: Color(0x14FFFFFF),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 26, 18, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Opacity(
                  opacity: 0.8,
                  child: Text(
                    'EMPLOYEE WORKSPACE',
                    style: portalText(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 1,
                      height: 12 / 10,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Welcome back, $first',
                  style: portalText(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 19 / 15.5,
                  ),
                ),
                const SizedBox(height: 6),
                Opacity(
                  opacity: 0.9,
                  child: Text(
                    'Keep your profile info and records handy — experience, documents, letters, and medical details in one place.',
                    style: portalText(
                      fontSize: 11,
                      color: Colors.white,
                      height: 16 / 11,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0x26FFFFFF),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SvgPicture.asset(
                        'assets/icons/profile/ic_email.svg',
                        width: 12,
                        height: 12,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          employee.email,
                          style: portalText(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            height: 13 / 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
