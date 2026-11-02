import 'package:flutter/material.dart';
import 'package:timelay_health/features/camp/members/presentation/widgets/member_tokens.dart';

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
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: kMemberSurface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: kMemberBorder),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const SizedBox(width: 14),
                  const Icon(Icons.search_rounded, size: 18, color: kMemberMuted),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: controller,
                      onChanged: onChanged,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        color: kMemberHeading,
                      ),
                      decoration: const InputDecoration(
                        isDense: true,
                        border: InputBorder.none,
                        hintText: 'Search name, camp or phone...',
                        hintStyle: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          color: Color(0xFFBBBAC4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Filter icon button
          Material(
            color: kMemberPrimary,
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              onTap: onFilter,
              borderRadius: BorderRadius.circular(14),
              child: const SizedBox(
                width: 44,
                height: 44,
                child: Icon(Icons.tune_rounded, size: 18, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  FILTER CHIPS
// ─────────────────────────────────────────────────────────────
