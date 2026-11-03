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

  Color get _accent => camp.badgeFg;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _accent.withValues(alpha: 0.18)),
        boxShadow: [
          BoxShadow(
            color: _accent.withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 4,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [_accent, _accent.withValues(alpha: 0.35)],
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  camp.name,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 15.5,
                                    fontWeight: FontWeight.w800,
                                    height: 1.25,
                                    color: CampColors.heading,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: camp.badgeBg,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: _accent.withValues(alpha: 0.25),
                                  ),
                                ),
                                child: Text(
                                  camp.statusLabel.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.3,
                                    color: camp.badgeFg,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          _InfoLine(
                            icon: Icons.location_on_rounded,
                            text: camp.location,
                            color: CampColors.primary,
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Expanded(
                                child: _InfoLine(
                                  icon: Icons.calendar_today_rounded,
                                  text: camp.date,
                                  color: CampColors.blue,
                                ),
                              ),
                              _InfoLine(
                                icon: Icons.access_time_filled_rounded,
                                text: camp.time,
                                color: CampColors.orange,
                                expand: false,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text.rich(
                            TextSpan(
                              style: const TextStyle(
                                fontSize: 12,
                                color: CampColors.muted,
                              ),
                              children: [
                                const TextSpan(text: 'By '),
                                TextSpan(
                                  text: camp.createdBy,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: CampColors.heading,
                                  ),
                                ),
                                const TextSpan(text: ' · Partner '),
                                TextSpan(
                                  text: camp.assignedPartner,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: CampColors.heading,
                                  ),
                                ),
                              ],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: CampColors.background.withValues(alpha: 0.65),
                        border: const Border(
                          top: BorderSide(color: CampColors.border),
                        ),
                      ),
                      child: Column(
                        children: [
                          _PeopleRow(
                            icon: Icons.groups_rounded,
                            label: 'VOLUNTEERS',
                            people: camp.volunteers,
                            extra: camp.volunteerExtra,
                            emptyLabel:
                                camp.noVolunteers ? 'No volunteers' : null,
                            onTap: () =>
                                showTeamVolunteersSheet(context, camp: camp),
                          ),
                          const Divider(
                            height: 1,
                            indent: 14,
                            endIndent: 14,
                            color: CampColors.border,
                          ),
                          _PeopleRow(
                            icon: Icons.handshake_rounded,
                            label: 'PARTNERS',
                            people: camp.partners,
                            extra: camp.partnerExtra,
                            showDot: true,
                            emptyLabel:
                                camp.partners.isEmpty ? 'No partners' : null,
                            onTap: () =>
                                showAssignedPartnersSheet(context, camp: camp),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: CampColors.primaryTint,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              '${camp.patients} Patients',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: CampColors.primary,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Material(
                            color: CampColors.primary,
                            borderRadius: BorderRadius.circular(14),
                            child: InkWell(
                              onTap: onView ??
                                  () => showCampDetailSheet(
                                        context,
                                        camp: camp,
                                      ),
                              borderRadius: BorderRadius.circular(14),
                              child: const Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 9,
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.visibility_rounded,
                                      size: 15,
                                      color: Colors.white,
                                    ),
                                    SizedBox(width: 6),
                                    Text(
                                      'View',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({
    required this.icon,
    required this.text,
    required this.color,
    this.expand = true,
  });

  final IconData icon;
  final String text;
  final Color color;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final textWidget = Text(
      text,
      maxLines: 1,
      overflow: expand ? TextOverflow.ellipsis : TextOverflow.visible,
      softWrap: false,
      style: const TextStyle(
        fontSize: 13,
        height: 1.2,
        fontWeight: FontWeight.w500,
        color: CampColors.secondary,
      ),
    );

    return Row(
      mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: color),
        const SizedBox(width: 6),
        if (expand) Expanded(child: textWidget) else textWidget,
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
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            children: [
              Icon(icon, size: 16, color: CampColors.muted),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.3,
                  color: CampColors.muted,
                ),
              ),
              const SizedBox(width: 8),
              if (emptyLabel != null && people.isEmpty)
                Expanded(
                  child: Text(
                    emptyLabel!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFFBBBAC4),
                    ),
                  ),
                )
              else ...[
                _AvatarStack(
                  people: people.take(3).toList(),
                  size: 26,
                  showDot: showDot,
                ),
                if (extra > 0) ...[
                  const SizedBox(width: 6),
                  Text(
                    '+$extra',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: CampColors.primary,
                    ),
                  ),
                ],
                const Spacer(),
              ],
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

class _AvatarStack extends StatelessWidget {
  const _AvatarStack({
    required this.people,
    this.size = 26,
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
      width: size + (visible.length - 1) * (size - 7),
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          for (var i = 0; i < visible.length; i++)
            Positioned(
              left: i * (size - 7),
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
                        fontSize: size * 0.38,
                        fontWeight: FontWeight.w700,
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
                          border: Border.all(color: Colors.white, width: 1),
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
