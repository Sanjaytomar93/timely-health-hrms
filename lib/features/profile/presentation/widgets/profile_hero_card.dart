import 'package:flutter/material.dart';
import 'package:timelay_health/core/theme/portal_colors.dart';
import 'package:timelay_health/core/theme/portal_text.dart';
import 'package:timelay_health/features/auth/domain/entities/employee.dart';

class ProfileHeroCard extends StatelessWidget {
  const ProfileHeroCard({super.key, required this.employee, this.onTap});

  final Employee employee;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final first = employee.displayName.split(RegExp(r'\s+')).first;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(22),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF26204A), Color(0xFF3D3670), Color(0xFF4B4285)],
              ),
              boxShadow: [
                BoxShadow(
                  color: PortalColors.brand.withValues(alpha: 0.28),
                  blurRadius: 22,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: Stack(
                children: [
                  Positioned(
                    right: -36,
                    top: -40,
                    child: _Glow(size: 160, opacity: 0.12),
                  ),
                  Positioned(
                    left: -28,
                    bottom: -48,
                    child: _Glow(size: 130, opacity: 0.08),
                  ),
                  Positioned(
                    right: 24,
                    bottom: 18,
                    child: _Glow(size: 56, opacity: 0.1),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _Avatar(letter: employee.avatarLetter),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Welcome back, $first',
                                    style: portalText(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white.withValues(alpha: 0.72),
                                      height: 1.2,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    employee.displayName,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: portalText(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                      height: 1.2,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    employee.role.toUpperCase(),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: portalText(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFFB8B0E8),
                                      letterSpacing: 0.7,
                                      height: 1.2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            _StatusPill(
                              label: employee.statusLabel,
                              active: employee.isActive,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.12),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: _MetaItem(
                                  icon: Icons.badge_outlined,
                                  label: employee.employeeId,
                                ),
                              ),
                              _Divider(),
                              Expanded(
                                child: _MetaItem(
                                  icon: Icons.apartment_rounded,
                                  label: employee.department.isEmpty
                                      ? '—'
                                      : employee.department,
                                ),
                              ),
                              _Divider(),
                              Expanded(
                                child: _MetaItem(
                                  icon: Icons.payments_outlined,
                                  label: employee.salaryLabel,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(
                              Icons.mail_outline_rounded,
                              size: 14,
                              color: Colors.white.withValues(alpha: 0.7),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                employee.email,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: portalText(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white.withValues(alpha: 0.85),
                                  height: 1.2,
                                ),
                              ),
                            ),
                            Text(
                              'View details',
                              style: portalText(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(width: 2),
                            const Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 11,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Glow extends StatelessWidget {
  const _Glow({required this.size, required this.opacity});

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

class _Avatar extends StatelessWidget {
  const _Avatar({required this.letter});

  final String letter;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 62,
      height: 62,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.35), width: 2),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF6B63A8), Color(0xFF3D3670)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        letter,
        style: portalText(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          height: 1,
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label, required this.active});

  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: active
            ? const Color(0xFF1FA971).withValues(alpha: 0.22)
            : PortalColors.red.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: active
              ? const Color(0xFF6EE7B7).withValues(alpha: 0.45)
              : PortalColors.redSoft.withValues(alpha: 0.45),
        ),
      ),
      child: Text(
        label,
        style: portalText(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: active ? const Color(0xFFA7F3D0) : const Color(0xFFFFCDD2),
          height: 1.1,
        ),
      ),
    );
  }
}

class _MetaItem extends StatelessWidget {
  const _MetaItem({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 15, color: Colors.white.withValues(alpha: 0.75)),
        const SizedBox(height: 5),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: portalText(
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            height: 1.15,
          ),
        ),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 28,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      color: Colors.white.withValues(alpha: 0.18),
    );
  }
}
