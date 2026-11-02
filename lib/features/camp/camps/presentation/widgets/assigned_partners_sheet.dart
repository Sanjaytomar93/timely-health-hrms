import 'package:flutter/material.dart';
import 'package:timelay_health/core/theme/portal_text.dart';
import 'package:timelay_health/features/camp/camps/presentation/models/camp_list_ui.dart';
import 'package:timelay_health/features/camp/camps/presentation/widgets/camp_sheet_chrome.dart';
import 'package:timelay_health/features/camp/dashboard/presentation/theme/camp_colors.dart';

Future<void> showAssignedPartnersSheet(
  BuildContext context, {
  required CampItemUi camp,
}) {
  return showDialog<void>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.45),
    builder: (_) => AssignedPartnersSheet(camp: camp),
  );
}

class AssignedPartnersSheet extends StatelessWidget {
  const AssignedPartnersSheet({super.key, required this.camp});

  final CampItemUi camp;

  @override
  Widget build(BuildContext context) {
    final people = camp.partners;
    final count = people.length;

    return CampSheetFrame(
      header: CampSheetGradientHeader(
        icon: Icons.work_outline_rounded,
        title: 'Assigned Partners',
        subtitle: '$count clinic${count == 1 ? '' : 's'} assigned',
      ),
      footer: const CampSheetCloseButton(),
      child: people.isEmpty
          ? Padding(
              padding: const EdgeInsets.all(28),
              child: Text(
                'No partners assigned',
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
                final pending = (p.status ?? '').toUpperCase() == 'PENDING';
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              p.name,
                              style: portalText(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: CampColors.heading,
                              ),
                            ),
                            if (p.role != null) ...[
                              const SizedBox(height: 3),
                              Text(
                                p.role!,
                                style: portalText(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.4,
                                  color: CampColors.muted,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (p.status != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: pending
                                ? const Color(0xFFFFF4DF)
                                : CampColors.greenTint,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                pending
                                    ? Icons.schedule_rounded
                                    : Icons.check_circle_outline_rounded,
                                size: 13,
                                color: pending
                                    ? const Color(0xFFA15C07)
                                    : CampColors.green,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                p.status!.toUpperCase(),
                                style: portalText(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: pending
                                      ? const Color(0xFFA15C07)
                                      : CampColors.green,
                                ),
                              ),
                            ],
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
