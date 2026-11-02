import 'package:flutter/material.dart';
import 'package:timelay_health/features/camp/camps/presentation/models/camp_list_ui.dart';
import 'package:timelay_health/features/camp/camps/presentation/widgets/assigned_partners_sheet.dart';
import 'package:timelay_health/features/camp/camps/presentation/widgets/camp_detail_sheet.dart';
import 'package:timelay_health/features/camp/camps/presentation/widgets/team_volunteers_sheet.dart';
import 'package:timelay_health/features/camp/dashboard/presentation/theme/camp_colors.dart';

class CampListCard extends StatelessWidget {
  const CampListCard({super.key, required this.camp, this.onView});

  final CampItemUi camp;
  final VoidCallback? onView;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: CampColors.primary.withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(
            color: CampColors.primary.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(11, 10, 11, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        camp.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: CampColors.heading,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: camp.badgeBg,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        camp.statusLabel.toUpperCase(),
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                          color: camp.badgeFg,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 7),
                _InfoLine(icon: Icons.location_on_outlined, text: camp.location),
                const SizedBox(height: 4),
                _InfoLine(icon: Icons.calendar_today_outlined, text: camp.date),
                const SizedBox(height: 4),
                _InfoLine(icon: Icons.access_time_rounded, text: camp.time),
                const SizedBox(height: 6),
                Text.rich(
                  TextSpan(
                    style: const TextStyle(fontSize: 10, color: CampColors.muted),
                    children: [
                      const TextSpan(text: 'Created by: '),
                      TextSpan(
                        text: camp.createdBy,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: CampColors.heading,
                        ),
                      ),
                      const TextSpan(text: '    Assigned Partner: '),
                      TextSpan(
                        text: camp.assignedPartner,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: CampColors.heading,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Divider(height: 1, color: CampColors.border),
          _PeopleRow(
            icon: Icons.groups_outlined,
            label: 'VOLUNTEERS:',
            people: camp.volunteers,
            extra: camp.volunteerExtra,
            emptyLabel: camp.noVolunteers ? 'No volunteers' : null,
            onTap: () => showTeamVolunteersSheet(context, camp: camp),
          ),
          const Divider(height: 1, color: CampColors.border),
          _PeopleRow(
            icon: Icons.work_outline_rounded,
            label: 'PARTNERS:',
            people: camp.partners,
            extra: camp.partnerExtra,
            showDot: true,
            emptyLabel: camp.partners.isEmpty ? 'No partners' : null,
            onTap: () => showAssignedPartnersSheet(context, camp: camp),
          ),
          const Divider(height: 1, color: CampColors.border),
          Padding(
            padding: const EdgeInsets.fromLTRB(11, 8, 11, 9),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: CampColors.background,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: CampColors.border),
                  ),
                  child: Text(
                    '${camp.patients} Patients',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: CampColors.secondary,
                    ),
                  ),
                ),
                const Spacer(),
                Material(
                  color: CampColors.primaryTint,
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    onTap: onView ??
                        () => showCampDetailSheet(context, camp: camp),
                    borderRadius: BorderRadius.circular(16),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 11,
                        vertical: 6,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.visibility_outlined,
                            size: 14,
                            color: CampColors.primary,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'View',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: CampColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
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

class _InfoLine extends StatelessWidget {
  const _InfoLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 13, color: CampColors.muted),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 11,
              height: 1.2,
              color: CampColors.secondary,
            ),
          ),
        ),
      ],
    );
  }
}

class _PeopleRow extends StatelessWidget {
  const _PeopleRow({
    required this.icon,
    required this.label,
    required this.people,
    required this.onTap,
    this.extra = 0,
    this.showDot = false,
    this.emptyLabel,
  });

  final IconData icon;
  final String label;
  final List<CampPersonUi> people;
  final VoidCallback onTap;
  final int extra;
  final bool showDot;
  final String? emptyLabel;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
          child: Row(
            children: [
              Icon(icon, size: 14, color: CampColors.muted),
              const SizedBox(width: 5),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                  color: CampColors.muted,
                ),
              ),
              const SizedBox(width: 6),
              if (emptyLabel != null && people.isEmpty)
                Expanded(
                  child: Text(
                    emptyLabel!,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFFBBBAC4),
                    ),
                  ),
                )
              else ...[
                _AvatarStack(
                  people: people.take(3).toList(),
                  size: 22,
                  showDot: showDot,
                ),
                if (extra > 0) ...[
                  const SizedBox(width: 5),
                  Text(
                    '+$extra',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: CampColors.heading,
                    ),
                  ),
                ],
                const Spacer(),
              ],
              Container(
                width: 24,
                height: 24,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: CampColors.primaryTint,
                  borderRadius: BorderRadius.circular(7),
                ),
                child: const Icon(
                  Icons.visibility_outlined,
                  size: 13,
                  color: CampColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AvatarStack extends StatelessWidget {
  const _AvatarStack({
    required this.people,
    this.size = 22,
    this.showDot = false,
  });

  final List<CampPersonUi> people;
  final double size;
  final bool showDot;

  @override
  Widget build(BuildContext context) {
    if (people.isEmpty) return const SizedBox.shrink();
    final visible = people.take(3).toList();
    return SizedBox(
      width: size + (visible.length - 1) * (size - 6),
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          for (var i = 0; i < visible.length; i++)
            Positioned(
              left: i * (size - 6),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: size,
                    height: size,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: visible[i].bg,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    child: Text(
                      visible[i].initial,
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: visible[i].fg,
                      ),
                    ),
                  ),
                  if (showDot)
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF9F27),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.2),
                        ),
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
