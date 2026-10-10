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
    '💼 Jobs / Experience',
    '📁 Personal Documents',
    '✉️ My Letters',
    '📄 Medical Certificate',
    '📈 Salary Hike',
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
    return MediaQuery.withClampedTextScaling(
      maxScaleFactor: 1.2,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
        child: Row(
          children: [
            for (var index = 0; index < ProfileSectionTabs.tabs.length; index++)
              Padding(
                padding: EdgeInsets.only(
                  right: index == ProfileSectionTabs.tabs.length - 1 ? 0 : 3,
                ),
                child: _TabChip(
                  key: _itemKeys[index],
                  label: ProfileSectionTabs.tabs[index],
                  selected: index == widget.selectedIndex,
                  onTap: () => widget.onChanged(index),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _TabChip extends StatelessWidget {
  const _TabChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? PortalColors.purple : PortalColors.surface,
      borderRadius: BorderRadius.circular(11),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(11),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(11),
            border: Border.all(
              color: selected ? PortalColors.purple : PortalColors.border,
            ),
          ),
          child: Text(
            label,
            maxLines: 1,
            style: portalText(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: selected ? Colors.white : PortalColors.secondaryText,
              height: 14 / 11.5,
            ),
          ),
        ),
      ),
    );
  }
}
