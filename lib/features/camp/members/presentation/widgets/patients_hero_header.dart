import 'package:flutter/material.dart';
import 'package:timelay_health/features/camp/members/presentation/models/patient_list_ui.dart';
import 'package:timelay_health/features/camp/members/presentation/widgets/member_tokens.dart';

class PatientsHeroHeader extends StatelessWidget {
  const PatientsHeroHeader({super.key, required this.data, this.onAddPatient});

  final PatientListUi data;
  final VoidCallback? onAddPatient;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(gradient: kMemberHeroGradient),
      child: Stack(
        children: [
          Positioned(
            right: -30,
            top: -30,
            child: _GlowCircle(size: 140, opacity: 0.08),
          ),
          Positioned(
            right: 40,
            bottom: -20,
            child: _GlowCircle(size: 90, opacity: 0.06),
          ),
          Positioned(
            left: -20,
            bottom: 10,
            child: _GlowCircle(size: 70, opacity: 0.05),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.grid_view_rounded,
                              size: 11, color: Colors.white70),
                          SizedBox(width: 5),
                          Text(
                            'Camp · Patients',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: Colors.white70,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _AddPatientButton(onTap: onAddPatient),
                  ],
                ),
                const SizedBox(height: 14),
                const Text(
                  'All Patients',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 1.1,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFF7EFFD4),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      data.subtitle,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GlowCircle extends StatelessWidget {
  const _GlowCircle({required this.size, required this.opacity});
  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: opacity),
      ),
    );
  }
}

class _AddPatientButton extends StatelessWidget {
  const _AddPatientButton({this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 34,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: kMemberPrimaryDark.withValues(alpha: 0.30),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add_rounded, size: 15, color: kMemberPrimary),
              SizedBox(width: 5),
              Text(
                'Add patient',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: kMemberPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
