import 'package:flutter/material.dart';
import 'package:timelay_health/core/theme/portal_text.dart';
import 'package:timelay_health/features/camp/camps/presentation/models/camp_list_ui.dart';
import 'package:timelay_health/features/camp/camps/presentation/widgets/camp_sheet_chrome.dart';
import 'package:timelay_health/features/camp/dashboard/presentation/theme/camp_colors.dart';

Future<void> showTeamVolunteersSheet(
  BuildContext context, {
  required CampItemUi camp,
}) {
  return showDialog<void>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.45),
    builder: (_) => TeamVolunteersSheet(camp: camp),
  );
}

class TeamVolunteersSheet extends StatelessWidget {
  const TeamVolunteersSheet({super.key, required this.camp});

  final CampItemUi camp;

  @override
  Widget build(BuildContext context) {
    final people = camp.volunteers;
    final count = people.length;

    return CampSheetFrame(
      header: CampSheetGradientHeader(
        icon: Icons.groups_rounded,
        title: 'Team Volunteers',
        subtitle: '$count member${count == 1 ? '' : 's'} assigned',
      ),
      footer: const CampSheetCloseButton(),
      child: people.isEmpty
          ? Padding(
              padding: const EdgeInsets.all(28),
              child: Text(
                'No volunteers assigned',
                textAlign: TextAlign.center,
                style: portalText(fontSize: 13, color: CampColors.muted),
              ),
            )
          : ListView.separated(
              shrinkWrap: true,
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 6),
              itemCount: people.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final p = people[i];
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: CampColors.border),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x081C1B29),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      CampPersonAvatar(person: p, size: 42),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          p.name,
                          style: portalText(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: CampColors.heading,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
