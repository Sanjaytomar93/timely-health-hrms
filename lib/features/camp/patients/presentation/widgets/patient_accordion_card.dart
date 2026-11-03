import 'package:flutter/material.dart';
import 'package:timelay_health/features/camp/patients/presentation/models/patient_list_ui.dart';
import 'package:timelay_health/features/camp/patients/presentation/widgets/patient_tokens.dart';

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
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: kPatientBorder),
          boxShadow: [
            BoxShadow(
              color: kPatientPrimary.withValues(alpha: 0.06),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Avatar(patient: p),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Text(
                                p.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w800,
                                  color: kPatientHeading,
                                  height: 1.1,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            _HealthStatusBadge(status: p.healthStatus),
                          ],
                        ),
                        Text(
                          p.ageGenderLine,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: kPatientMuted,
                            height: 1.15,
                          ),
                        ),
                        if (p.campTag != null)
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on_rounded,
                                size: 12,
                                color: kPatientMuted,
                              ),
                              const SizedBox(width: 3),
                              Expanded(
                                child: Text(
                                  p.campTag!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: kPatientMuted,
                                    height: 1.15,
                                  ),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F6FB),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.phone_rounded,
                      size: 13,
                      color: kPatientPrimary,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        p.phone,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: kPatientHeading,
                          height: 1.1,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _SoftActionBtn(
                      label: 'View',
                      icon: Icons.visibility_rounded,
                      onTap: onView,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _SoftActionBtn(
                      label: 'WhatsApp',
                      icon: Icons.chat_rounded,
                      bg: const Color(0xFFE7F7F0),
                      fg: const Color(0xFF0F766E),
                      border: const Color(0xFFB7E8D8),
                      onTap: onWhatsApp,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _IconAction(
                    icon: Icons.edit_rounded,
                    bg: const Color(0xFFF3F2F7),
                    fg: kPatientHeading,
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
    return Container(
      width: 42,
      height: 42,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: p.resolvedAvatarBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: p.resolvedAvatarFg.withValues(alpha: 0.22),
        ),
      ),
      child: Text(
        p.initials,
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 13,
          fontWeight: FontWeight.w800,
          color: p.resolvedAvatarFg,
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
      padding: EdgeInsets.fromLTRB(screened ? 6 : 8, 4, 8, 4),
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
              size: 11,
              color: Color(0xFF0F766E),
            ),
            const SizedBox(width: 3),
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

class _SoftActionBtn extends StatelessWidget {
  const _SoftActionBtn({
    required this.label,
    required this.icon,
    this.bg = const Color(0xFFF3F4F6),
    this.fg = const Color(0xFF6B7280),
    this.border = const Color(0xFFE5E7EB),
    this.onTap,
  });

  final String label;
  final IconData icon;
  final Color bg;
  final Color fg;
  final Color border;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          height: 32,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: border),
          ),
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
                  fontWeight: FontWeight.w700,
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
