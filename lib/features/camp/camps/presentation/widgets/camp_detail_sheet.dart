import 'package:flutter/material.dart';
import 'package:timelay_health/core/theme/portal_text.dart';
import 'package:timelay_health/features/camp/camps/presentation/models/camp_list_ui.dart';
import 'package:timelay_health/features/camp/camps/presentation/widgets/assigned_partners_sheet.dart';
import 'package:timelay_health/features/camp/camps/presentation/widgets/team_volunteers_sheet.dart';
import 'package:timelay_health/features/camp/dashboard/presentation/theme/camp_colors.dart';
import 'package:timelay_health/features/camp/patients/presentation/screens/patient_detail_screen.dart';

Future<void> showCampDetailSheet(
  BuildContext context, {
  required CampItemUi camp,
}) {
  return showDialog<void>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.5),
    builder: (_) => CampDetailSheet(camp: camp),
  );
}

class CampDetailSheet extends StatelessWidget {
  const CampDetailSheet({super.key, required this.camp});

  final CampItemUi camp;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final width = (size.width - 24).clamp(320.0, 440.0);
    final maxH = size.height * 0.9;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      child: Container(
        width: width,
        constraints: BoxConstraints(maxHeight: maxH),
        decoration: BoxDecoration(
          color: CampColors.background,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: CampColors.primary.withValues(alpha: 0.22),
              blurRadius: 32,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            _DetailHeader(camp: camp),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
                children: [
                  _MetaGrid(camp: camp),
                  const SizedBox(height: 12),
                  _AdminRow(camp: camp),
                  const SizedBox(height: 12),
                  _PeopleActionCard(
                    icon: Icons.groups_rounded,
                    label: 'Volunteers',
                    count: camp.volunteers.length,
                    people: camp.volunteers,
                    emptyLabel: camp.noVolunteers || camp.volunteers.isEmpty
                        ? 'No volunteers assigned'
                        : null,
                    onView: () => showTeamVolunteersSheet(context, camp: camp),
                  ),
                  const SizedBox(height: 10),
                  _PeopleActionCard(
                    icon: Icons.handshake_outlined,
                    label: 'Partners',
                    count: camp.partners.length,
                    people: camp.partners,
                    emptyLabel:
                        camp.partners.isEmpty ? 'No partners assigned' : null,
                    onView: () =>
                        showAssignedPartnersSheet(context, camp: camp),
                  ),
                  const SizedBox(height: 14),
                  _PatientsBlock(patients: camp.patientItems),
                ],
              ),
            ),
            _DetailFooter(patients: camp.patientItems),
          ],
        ),
      ),
    );
  }
}

class _DetailHeader extends StatelessWidget {
  const _DetailHeader({required this.camp});

  final CampItemUi camp;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 12, 18),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [CampColors.primary, Color(0xFF3A3268), CampColors.primaryLight],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.22),
                  ),
                ),
                child: const Icon(
                  Icons.local_hospital_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      camp.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: portalText(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.25),
                        ),
                      ),
                      child: Text(
                        camp.statusLabel.toUpperCase(),
                        style: portalText(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Material(
                color: Colors.white.withValues(alpha: 0.16),
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () => Navigator.of(context).pop(),
                  child: const SizedBox(
                    width: 34,
                    height: 34,
                    child: Icon(
                      Icons.close_rounded,
                      size: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetaGrid extends StatelessWidget {
  const _MetaGrid({required this.camp});

  final CampItemUi camp;

  @override
  Widget build(BuildContext context) {
    final items = [
      (Icons.location_on_rounded, camp.location, CampColors.blue, CampColors.blueTint),
      (Icons.calendar_month_rounded, camp.date, CampColors.primary, CampColors.primaryTint),
      (Icons.schedule_rounded, camp.time, CampColors.orange, CampColors.orangeTint),
      (
        Icons.groups_rounded,
        '${camp.patients} Participants',
        CampColors.green,
        CampColors.greenTint,
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: CampColors.card(radius: 18),
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: items[i].$4,
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Icon(items[i].$1, size: 16, color: items[i].$3),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    items[i].$2,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: portalText(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: CampColors.secondary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _AdminRow extends StatelessWidget {
  const _AdminRow({required this.camp});

  final CampItemUi camp;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: CampColors.card(radius: 16),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: CampColors.primaryTint,
              borderRadius: BorderRadius.circular(11),
            ),
            child: const Icon(
              Icons.person_outline_rounded,
              size: 17,
              color: CampColors.primary,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Created by',
                  style: portalText(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: CampColors.muted,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  camp.createdBy,
                  style: portalText(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: CampColors.heading,
                  ),
                ),
              ],
            ),
          ),
          if (camp.assignedPartner.trim().isNotEmpty &&
              camp.assignedPartner.trim() != '—')
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: CampColors.primaryTint,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: CampColors.primary.withValues(alpha: 0.12),
                ),
              ),
              child: Text(
                camp.assignedPartner,
                style: portalText(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: CampColors.primary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _PeopleActionCard extends StatelessWidget {
  const _PeopleActionCard({
    required this.icon,
    required this.label,
    required this.count,
    required this.people,
    required this.onView,
    this.emptyLabel,
  });

  final IconData icon;
  final String label;
  final int count;
  final List<CampPersonUi> people;
  final VoidCallback onView;
  final String? emptyLabel;

  @override
  Widget build(BuildContext context) {
    final visible = people.take(4).toList();
    final extra = people.length > 4 ? people.length - 4 : 0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onView,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          padding: const EdgeInsets.all(12),
          decoration: CampColors.card(radius: 16),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: CampColors.primaryTint,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 18, color: CampColors.primary),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$label ($count)',
                      style: portalText(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        color: CampColors.heading,
                      ),
                    ),
                    const SizedBox(height: 6),
                    if (emptyLabel != null && people.isEmpty)
                      Text(
                        emptyLabel!,
                        style: portalText(
                          fontSize: 11,
                          color: CampColors.muted,
                        ),
                      )
                    else
                      Row(
                        children: [
                          _MiniAvatarStack(people: visible),
                          if (extra > 0) ...[
                            const SizedBox(width: 6),
                            Text(
                              '+$extra more',
                              style: portalText(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: CampColors.muted,
                              ),
                            ),
                          ],
                        ],
                      ),
                  ],
                ),
              ),
              Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [CampColors.primary, CampColors.primaryLight],
                  ),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Icon(
                  Icons.visibility_rounded,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniAvatarStack extends StatelessWidget {
  const _MiniAvatarStack({required this.people});

  final List<CampPersonUi> people;

  @override
  Widget build(BuildContext context) {
    if (people.isEmpty) return const SizedBox.shrink();
    const size = 26.0;
    return SizedBox(
      width: size + (people.length - 1) * (size - 8),
      height: size,
      child: Stack(
        children: [
          for (var i = 0; i < people.length; i++)
            Positioned(
              left: i * (size - 8),
              child: Container(
                width: size,
                height: size,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: people[i].bg,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.8),
                  boxShadow: [
                    BoxShadow(
                      color: people[i].fg.withValues(alpha: 0.12),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Text(
                  people[i].initial,
                  style: portalText(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: people[i].fg,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _PatientsBlock extends StatelessWidget {
  const _PatientsBlock({required this.patients});

  final List<CampPatientUi> patients;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: CampColors.card(radius: 18),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFF3F1FA), Color(0xFFEBE8F7)],
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.personal_injury_outlined,
                    size: 16,
                    color: CampColors.primary,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Patients',
                  style: portalText(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: CampColors.heading,
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: CampColors.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${patients.length}',
                    style: portalText(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (patients.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 28, 16, 28),
              child: Column(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: CampColors.primaryTint,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Icon(
                      Icons.groups_outlined,
                      size: 28,
                      color: CampColors.primary.withValues(alpha: 0.55),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No patients yet',
                    textAlign: TextAlign.center,
                    style: portalText(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: CampColors.heading,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Patients will appear here once registered.',
                    textAlign: TextAlign.center,
                    style: portalText(
                      fontSize: 11,
                      color: CampColors.muted,
                    ),
                  ),
                ],
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
              child: Column(
                children: [
                  for (var i = 0; i < patients.length; i++) ...[
                    if (i > 0) const SizedBox(height: 8),
                    _PatientDetailRow(patient: patients[i]),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _PatientDetailRow extends StatelessWidget {
  const _PatientDetailRow({required this.patient});

  final CampPatientUi patient;

  Future<void> _openDetails(BuildContext context) async {
    final id = patient.id.trim();
    if (id.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Patient id missing.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    await openPatientDetailById(context, patientId: id);
  }

  @override
  Widget build(BuildContext context) {
    final screened = patient.isScreened;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _openDetails(context),
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          padding: const EdgeInsets.fromLTRB(12, 12, 10, 12),
          decoration: BoxDecoration(
            color: const Color(0xFFFAFAFC),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: CampColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: CampColors.primaryTint,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  patient.initial,
                  style: portalText(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: CampColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      patient.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: portalText(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: CampColors.heading,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${patient.contact}  ·  ${patient.age}Y · ${patient.genderLabel}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: portalText(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: CampColors.muted,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      patient.healthLabel,
                      style: portalText(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: screened
                            ? CampColors.green
                            : const Color(0xFF9A7B3C),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'View Details',
                style: portalText(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: CampColors.primary,
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: CampColors.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailFooter extends StatelessWidget {
  const _DetailFooter({required this.patients});

  final List<CampPatientUi> patients;

  @override
  Widget build(BuildContext context) {
    final screened = patients.where((p) => p.isScreened).length;
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(top: BorderSide(color: CampColors.border)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: portalText(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: CampColors.muted,
                    ),
                    children: [
                      TextSpan(text: '${patients.length} participants · '),
                      TextSpan(
                        text: '$screened screened',
                        style: portalText(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: CampColors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: CampColors.green,
                      borderRadius: BorderRadius.circular(13),
                      boxShadow: [
                        BoxShadow(
                          color: CampColors.green.withValues(alpha: 0.28),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Report download started'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(13),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.description_outlined,
                              size: 16,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Download Report',
                              style: portalText(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                height: 44,
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: CampColors.heading,
                    side: const BorderSide(color: CampColors.border),
                    backgroundColor: CampColors.background,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                  ),
                  child: Text(
                    'Close',
                    style: portalText(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: CampColors.heading,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
