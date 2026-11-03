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
    barrierColor: Colors.black.withValues(alpha: 0.5),
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
        icon: Icons.handshake_outlined,
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
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final p = people[i];
                final pending = (p.status ?? '').toUpperCase() == 'PENDING';
                return Container(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAFAFC),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: CampColors.border),
                  ),
                  child: Row(
                    children: [
                      CampPersonAvatar(person: p, size: 40),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              p.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: portalText(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                color: CampColors.heading,
                              ),
                            ),
                            if (p.role != null) ...[
                              const SizedBox(height: 3),
                              Text(
                                p.role!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: portalText(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: CampColors.muted,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (p.status != null)
                        Text(
                          p.status!.toUpperCase(),
                          style: portalText(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: pending
                                ? const Color(0xFF9A7B3C)
                                : CampColors.green,
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
