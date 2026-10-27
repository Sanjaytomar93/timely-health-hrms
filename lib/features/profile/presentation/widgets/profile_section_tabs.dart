import 'package:flutter/material.dart';
import 'package:timelay_health/core/theme/portal_colors.dart';
import 'package:timelay_health/core/theme/portal_text.dart';

class ProfileSectionTabs extends StatefulWidget {
  const ProfileSectionTabs({
    super.key,
    required this.selectedIndex,
    required this.onChanged,
  });

  final int selectedIndex;
  final ValueChanged<int> onChanged;

  static const tabs = [
    (Icons.work_outline_rounded, 'Jobs / Experience'),
    (Icons.folder_outlined, 'Personal Documents'),
    (Icons.mail_outline_rounded, 'My Letters'),
    (Icons.medical_services_outlined, 'Medical Certificate'),
    (Icons.trending_up_rounded, 'Salary Hike'),
  ];

  @override
  State<ProfileSectionTabs> createState() => _ProfileSectionTabsState();
}

class _ProfileSectionTabsState extends State<ProfileSectionTabs> {
  final _itemKeys = List.generate(
    ProfileSectionTabs.tabs.length,
    (_) => GlobalKey(),
  );

  @override
  void didUpdateWidget(ProfileSectionTabs oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedIndex != widget.selectedIndex) {
      _revealSelected();
    }
  }

  void _revealSelected() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final context = _itemKeys[widget.selectedIndex].currentContext;
      if (context == null) return;
      Scrollable.ensureVisible(
        context,
        alignment: 0.5,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Text(
            'Records & documents',
            style: portalText(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: PortalColors.heading,
              height: 1.2,
            ),
          ),
        ),
        MediaQuery.withClampedTextScaling(
          maxScaleFactor: 1.2,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
            child: Row(
              children: [
                for (var index = 0;
                    index < ProfileSectionTabs.tabs.length;
                    index++)
                  Padding(
                    padding: EdgeInsets.only(
                      right: index == ProfileSectionTabs.tabs.length - 1
                          ? 0
                          : 8,
                    ),
                    child: _TabChip(
                      key: _itemKeys[index],
                      icon: ProfileSectionTabs.tabs[index].$1,
                      label: ProfileSectionTabs.tabs[index].$2,
                      selected: index == widget.selectedIndex,
                      onTap: () => widget.onChanged(index),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _TabChip extends StatelessWidget {
  const _TabChip({
    super.key,
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? PortalColors.brand : PortalColors.surface,
      borderRadius: BorderRadius.circular(999),
      elevation: selected ? 2 : 0,
      shadowColor: PortalColors.brand.withValues(alpha: 0.35),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: selected ? PortalColors.brand : PortalColors.border,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 14,
                color: selected ? Colors.white : PortalColors.muted,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                maxLines: 1,
                style: portalText(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: selected ? Colors.white : PortalColors.secondaryText,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
