import 'package:flutter/material.dart';
import 'package:timelay_health/features/camp/dashboard/presentation/theme/camp_colors.dart';

class PatientsSearchBar extends StatelessWidget {
  const PatientsSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
    this.onFilter,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback? onFilter;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: CampColors.border),
        ),
        child: Row(
          children: [
            const Icon(Icons.search_rounded, size: 20, color: CampColors.muted),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: controller,
                onChanged: onChanged,
                style: const TextStyle(fontSize: 13, color: CampColors.heading),
                decoration: const InputDecoration(
                  isDense: true,
                  border: InputBorder.none,
                  hintText: 'Search name, camp or phone',
                  hintStyle: TextStyle(fontSize: 13, color: Color(0xFFBBBAC4)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
