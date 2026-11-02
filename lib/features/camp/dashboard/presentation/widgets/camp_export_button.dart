import 'package:flutter/material.dart';
import 'package:timelay_health/core/theme/portal_text.dart';
import 'package:timelay_health/features/camp/dashboard/presentation/theme/camp_colors.dart';

class CampExportButton extends StatelessWidget {
  const CampExportButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: CampColors.primaryTint,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.file_download_outlined,
                size: 15,
                color: CampColors.primary,
              ),
              const SizedBox(width: 4),
              Text(
                'Export',
                style: portalText(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
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
