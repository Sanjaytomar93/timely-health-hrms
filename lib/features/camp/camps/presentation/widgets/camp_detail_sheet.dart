import 'package:flutter/material.dart';
import 'package:timelay_health/core/theme/portal_text.dart';
import 'package:timelay_health/features/camp/camps/presentation/models/camp_list_ui.dart';
import 'package:timelay_health/features/camp/camps/presentation/widgets/assigned_partners_sheet.dart';
import 'package:timelay_health/features/camp/camps/presentation/widgets/team_volunteers_sheet.dart';
import 'package:timelay_health/features/camp/dashboard/presentation/theme/camp_colors.dart';

Future<void> showCampDetailSheet(
  BuildContext context, {
  required CampItemUi camp,
}) {
  return showDialog<void>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.45),
    builder: (_) => CampDetailSheet(camp: camp),
  );
}

class CampDetailSheet extends StatelessWidget {
  const CampDetailSheet({super.key, required this.camp});

  final CampItemUi camp;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final width = (size.width - 20).clamp(320.0, 440.0);
    final maxH = size.height * 0.88;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 18),
      child: Container(
        width: width,
        constraints: BoxConstraints(maxHeight: maxH),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 28,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            _DetailHeader(camp: camp),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
                children: [
                  _MetaGrid(camp: camp),
                  const SizedBox(height: 12),
                  _AdminRow(camp: camp),
                  const SizedBox(height: 14),
                  _PeopleActionCard(
                    icon: Icons.groups_outlined,
                    label: 'VOLUNTEERS',
                    people: camp.volunteers,
                    emptyLabel: camp.noVolunteers || camp.volunteers.isEmpty
                        ? 'No volunteers'
                        : null,
                    onView: () => showTeamVolunteersSheet(context, camp: camp),
                  ),
                  const SizedBox(height: 10),
                  _PeopleActionCard(
                    icon: Icons.work_outline_rounded,
                    label: 'PARTNERS',
                    people: camp.partners,
                    emptyLabel:
                        camp.partners.isEmpty ? 'No partners' : null,
                    onView: () =>
                        showAssignedPartnersSheet(context, camp: camp),
                  ),
                  const SizedBox(height: 14),
                  _PatientsBlock(patients: camp.patients),
                ],
              ),
            ),
            _DetailFooter(patients: camp.patients),
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
      padding: const EdgeInsets.fromLTRB(16, 14, 10, 14),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF7F5FF), Color(0xFFEEF4FF)],
        ),
        border: Border(bottom: BorderSide(color: CampColors.border)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  camp.name,
                  style: portalText(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: CampColors.heading,
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
                    color: camp.badgeBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: camp.badgeFg.withValues(alpha: 0.18),
                    ),
                  ),
                  child: Text(
                    camp.statusLabel.toUpperCase(),
                    style: portalText(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.4,
                      color: camp.badgeFg,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Material(
            color: Colors.white,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: CampColors.border),
                ),
                child: const Icon(
                  Icons.close_rounded,
                  size: 18,
                  color: CampColors.muted,
                ),
              ),
            ),
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
      (Icons.location_on_outlined, camp.location),
      (Icons.calendar_today_outlined, camp.date),
      (Icons.access_time_rounded, camp.time),
      (Icons.groups_outlined, '${camp.patients} Participants'),
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final item in items)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: CampColors.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: CampColors.border),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(item.$1, size: 14, color: const Color(0xFF5B52D6)),
                const SizedBox(width: 6),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.sizeOf(context).width * 0.55,
                  ),
                  child: Text(
                    item.$2,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: portalText(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: CampColors.secondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
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
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: CampColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text.rich(
              TextSpan(
                style: portalText(fontSize: 12, color: CampColors.muted),
                children: [
                  const TextSpan(text: 'Created by: '),
                  TextSpan(
                    text: camp.createdBy,
                    style: portalText(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: CampColors.heading,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFEDEBFF),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              camp.assignedPartner,
              style: portalText(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF5B52D6),
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
    required this.people,
    required this.onView,
    this.emptyLabel,
  });

  final IconData icon;
  final String label;
  final List<CampPersonUi> people;
  final VoidCallback onView;
  final String? emptyLabel;

  @override
  Widget build(BuildContext context) {
    final visible = people.take(3).toList();
    final extra = people.length > 3 ? people.length - 3 : 0;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onView,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: CampColors.border),
          ),
          child: Row(
            children: [
              Icon(icon, size: 16, color: CampColors.muted),
              const SizedBox(width: 6),
              Text(
                label,
                style: portalText(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                  color: CampColors.muted,
                ),
              ),
              const SizedBox(width: 10),
              if (emptyLabel != null && people.isEmpty)
                Expanded(
                  child: Text(
                    emptyLabel!,
                    style: portalText(
                      fontSize: 11,
                      color: const Color(0xFFBBBAC4),
                    ),
                  ),
                )
              else ...[
                _MiniAvatarStack(people: visible),
                if (extra > 0) ...[
                  const SizedBox(width: 6),
                  Text(
                    '+$extra',
                    style: portalText(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: CampColors.heading,
                    ),
                  ),
                ],
                const Spacer(),
              ],
              Container(
                width: 30,
                height: 30,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: CampColors.primaryTint,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: const Icon(
                  Icons.visibility_outlined,
                  size: 15,
                  color: Color(0xFF5B52D6),
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
    const size = 24.0;
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
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                child: Text(
                  people[i].initial,
                  style: portalText(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
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

  final int patients;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: CampColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            color: const Color(0xFFF6F5FB),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final h in const [
                    'PATIENT NAME',
                    'CONTACT',
                    'AGE / GENDER',
                    'HEALTH CHECK',
                    'ACTIONS',
                  ])
                    Padding(
                      padding: const EdgeInsets.only(right: 18),
                      child: Text(
                        h,
                        style: portalText(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                          color: CampColors.muted,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (patients <= 0)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 28, 16, 28),
              child: Column(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: CampColors.background,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Icon(
                      Icons.groups_outlined,
                      size: 28,
                      color: CampColors.muted.withValues(alpha: 0.55),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No patients found in this camp yet.',
                    textAlign: TextAlign.center,
                    style: portalText(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: CampColors.heading,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Patients will appear here once they are added to the camp.',
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
              padding: const EdgeInsets.all(14),
              child: Text(
                '$patients patient${patients == 1 ? '' : 's'} registered',
                style: portalText(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: CampColors.secondary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _DetailFooter extends StatelessWidget {
  const _DetailFooter({required this.patients});

  final int patients;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: CampColors.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '$patients participants found',
              style: portalText(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: CampColors.muted,
              ),
            ),
          ),
          SizedBox(
            height: 40,
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: OutlinedButton.styleFrom(
                foregroundColor: CampColors.heading,
                side: const BorderSide(color: CampColors.border),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 18),
              ),
              child: Text(
                'Close',
                style: portalText(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: CampColors.heading,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
