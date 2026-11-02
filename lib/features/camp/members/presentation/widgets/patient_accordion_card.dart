import 'package:flutter/material.dart';
import 'package:timelay_health/features/camp/members/presentation/models/patient_list_ui.dart';
import 'package:timelay_health/features/camp/members/presentation/widgets/member_tokens.dart';

class PatientAccordionCard extends StatelessWidget {
  const PatientAccordionCard({
    super.key,
    required this.patient,
    required this.index,
    this.onView,
    this.onEdit,
    this.onDelete,
    this.onWhatsApp,
  });

  final PatientUi patient;
  final int index;
  final VoidCallback? onView;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onWhatsApp;

  @override
  Widget build(BuildContext context) {
    final p = patient;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: kMemberBorder),
          boxShadow: [
            BoxShadow(
              color: kMemberPrimary.withValues(alpha: 0.08),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 14, 14, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Avatar(patient: p),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                p.name,
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: kMemberHeading,
                                  height: 1.2,
                                ),
                              ),
                            ),
                            if (p.campTag != null)
                              _SoftTag(
                                label: p.campTag!,
                                bg: const Color(0xFFF0EEF8),
                                fg: kMemberPrimary,
                              )
                            else if (p.statusTag != null)
                              _SoftTag(
                                label: p.statusTag!,
                                bg: const Color(0xFFF0EEF8),
                                fg: kMemberPrimary,
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          p.ageGenderLine,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: kMemberMuted,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _HealthStatusBadge(status: p.healthStatus),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F6FB),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.phone_rounded,
                      size: 14,
                      color: kMemberPrimary,
                    ),
                    const SizedBox(width: 7),
                    Expanded(
                      child: Text(
                        p.phone,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                          color: kMemberHeading,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${p.age} yrs',
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: kMemberMuted,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _ActionBtn(
                      label: 'View',
                      icon: Icons.visibility_rounded,
                      bg: kMemberPrimary,
                      fg: Colors.white,
                      onTap: onView,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _ActionBtn(
                      label: 'WhatsApp',
                      icon: Icons.chat_rounded,
                      bg: const Color(0xFF18AC96),
                      fg: Colors.white,
                      onTap: onWhatsApp,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _IconAction(
                    icon: Icons.edit_rounded,
                    bg: const Color(0xFFF3F2F7),
                    fg: kMemberHeading,
                    onTap: onEdit,
                  ),
                  const SizedBox(width: 6),
                  _IconAction(
                    icon: Icons.delete_outline_rounded,
                    bg: const Color(0xFFFDECEC),
                    fg: const Color(0xFFE0483E),
                    onTap: onDelete,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.patient});

  final PatientUi patient;

  @override
  Widget build(BuildContext context) {
    final p = patient;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 52,
          height: 52,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                p.resolvedAvatarBg,
                Color.lerp(p.resolvedAvatarBg, Colors.white, 0.35)!,
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: p.resolvedAvatarFg.withValues(alpha: 0.28),
              width: 1.4,
            ),
            boxShadow: [
              BoxShadow(
                color: p.resolvedAvatarFg.withValues(alpha: 0.18),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            p.initials,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: p.resolvedAvatarFg,
            ),
          ),
        ),
        Positioned(
          right: -2,
          bottom: -2,
          child: Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              color: p.gender == PatientGender.female
                  ? const Color(0xFF0F6E56)
                  : p.gender == PatientGender.male
                      ? const Color(0xFF185FA5)
                      : kMemberPrimary,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: Icon(
              p.gender == PatientGender.female
                  ? Icons.female_rounded
                  : Icons.male_rounded,
              size: 10,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}

class _SoftTag extends StatelessWidget {
  const _SoftTag({
    required this.label,
    required this.bg,
    required this.fg,
  });

  final String label;
  final Color bg;
  final Color fg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: fg,
        ),
      ),
    );
  }
}

class _HealthStatusBadge extends StatelessWidget {
  const _HealthStatusBadge({required this.status});

  final PatientHealthStatus status;

  @override
  Widget build(BuildContext context) {
    final screened = status == PatientHealthStatus.screened;

    return Container(
      padding: EdgeInsets.fromLTRB(screened ? 6 : 9, 4, 9, 4),
      decoration: BoxDecoration(
        color: screened ? const Color(0xFFE7F7F0) : const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: screened ? const Color(0xFFB7E8D8) : const Color(0xFFE5E7EB),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (screened) ...[
            const Icon(
              Icons.check_circle_rounded,
              size: 12,
              color: Color(0xFF0F766E),
            ),
            const SizedBox(width: 4),
          ],
          Text(
            screened ? 'Screened' : 'Pending',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: screened
                  ? const Color(0xFF0F766E)
                  : const Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  const _ActionBtn({
    required this.label,
    required this.icon,
    required this.bg,
    required this.fg,
    this.onTap,
  });

  final String label;
  final IconData icon;
  final Color bg;
  final Color fg;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(
          height: 32,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 13, color: fg),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  color: fg,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IconAction extends StatelessWidget {
  const _IconAction({
    required this.icon,
    required this.bg,
    required this.fg,
    this.onTap,
  });

  final IconData icon;
  final Color bg;
  final Color fg;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(
          width: 32,
          height: 32,
          child: Icon(icon, size: 15, color: fg),
        ),
      ),
    );
  }
}
