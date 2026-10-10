import 'package:flutter/material.dart';
import 'package:timelay_health/core/theme/portal_colors.dart';
import 'package:timelay_health/core/theme/portal_text.dart';

class ProfileSearchFilters extends StatelessWidget {
  const ProfileSearchFilters({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.fromLTRB(14, 22, 14, 14),
      decoration: BoxDecoration(
        color: PortalColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: PortalColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '💼 Jobs / Experience',
            style: portalText(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: PortalColors.heading,
              height: 16 / 13,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Search and review your experience records',
            style: portalText(
              fontSize: 10.5,
              color: PortalColors.muted,
              height: 13 / 10.5,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 38,
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by company, role or location...',
                hintStyle: portalText(
                  fontSize: 11.3,
                  color: const Color(0xFF757575),
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  size: 16,
                  color: PortalColors.muted,
                ),
                prefixIconConstraints: const BoxConstraints(
                  minWidth: 36,
                  minHeight: 38,
                ),
                filled: true,
                fillColor: PortalColors.background,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                border: _border(),
                enabledBorder: _border(),
                focusedBorder: _border(PortalColors.purple),
              ),
              style: portalText(fontSize: 12, color: PortalColors.heading),
            ),
          ),
          const SizedBox(height: 10),
          const Row(
            children: [
              Expanded(child: _FilterHint(text: 'dd/mm/yyyy')),
              SizedBox(width: 10),
              Expanded(child: _FilterHint(text: '---- ----')),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: PortalColors.background,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: PortalColors.border),
                ),
                child: Text(
                  'Showing 0 / 0',
                  style: portalText(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: PortalColors.secondaryText,
                    height: 13 / 10.5,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                'New · experience status',
                style: portalText(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: PortalColors.muted,
                  height: 12 / 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static OutlineInputBorder _border([Color? color]) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(11),
      borderSide: BorderSide(color: color ?? PortalColors.border),
    );
  }
}

class _FilterHint extends StatelessWidget {
  const _FilterHint({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 37,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        color: PortalColors.background,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: PortalColors.border),
      ),
      child: Text(
        text,
        style: portalText(
          fontSize: 12,
          color: PortalColors.muted,
          height: 15 / 12,
        ),
      ),
    );
  }
}
