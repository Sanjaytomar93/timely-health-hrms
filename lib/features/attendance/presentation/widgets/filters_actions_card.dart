import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import 'package:timelay_health/core/theme/portal_colors.dart';
import 'package:timelay_health/core/theme/portal_text.dart';
import 'package:timelay_health/features/attendance/domain/failures/attendance_failure.dart';
import 'package:timelay_health/features/attendance/presentation/bloc/attendance_cubit.dart';
import 'package:timelay_health/features/attendance/presentation/bloc/attendance_state.dart';
import 'package:timelay_health/features/attendance/presentation/models/attendance_record_ui_model.dart';
import 'package:timelay_health/features/attendance/presentation/widgets/ot_available_banner.dart';
import 'package:timelay_health/features/dashboard/presentation/widgets/dashboard_card.dart';

class FiltersActionsCard extends StatefulWidget {
  const FiltersActionsCard({super.key});

  @override
  State<FiltersActionsCard> createState() => _FiltersActionsCardState();
}

class _FiltersActionsCardState extends State<FiltersActionsCard> {
  bool _datesExpanded = false;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AttendanceCubit, AttendanceState>(
      builder: (context, state) {
        final filter = state.filter;
        final showing = state.records.length;
        final total = state.allRecords.length;
        final cubit = context.read<AttendanceCubit>();
        final dateCount = [
          filter.exactDate,
          filter.fromDate,
          filter.toDate,
        ].where((d) => d != null).length;

        return DashboardCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DashboardCardHeader(
                icon: Icons.tune_rounded,
                color: PortalColors.brand,
                title: 'Filters & Actions',
                subtitle: 'Showing $showing of $total records',
                trailing: filter.hasActiveFilters
                    ? _ClearButton(onTap: cubit.clearFilters)
                    : null,
              ),
              if (filter.otOnly) ...[
                const SizedBox(height: 12),
                _OtOnlyPill(onTap: () => cubit.setOtOnly(false)),
              ],
              const SizedBox(height: 14),
              const _FieldLabel('Status'),
              const SizedBox(height: 7),
              _ChipGroup<AttendanceStatusFilter>(
                value: filter.status,
                items: const [
                  (AttendanceStatusFilter.all, 'All', Icons.apps_rounded),
                  (
                    AttendanceStatusFilter.active,
                    'Active',
                    Icons.radio_button_checked_rounded,
                  ),
                  (
                    AttendanceStatusFilter.loggedOut,
                    'Logged Out',
                    Icons.logout_rounded,
                  ),
                ],
                onChanged: cubit.setStatus,
              ),
              const SizedBox(height: 12),
              const _FieldLabel('Location'),
              const SizedBox(height: 7),
              _ChipGroup<AttendanceLocationFilter>(
                value: filter.location,
                items: const [
                  (AttendanceLocationFilter.all, 'All', Icons.public_rounded),
                  (
                    AttendanceLocationFilter.onsite,
                    'Onsite',
                    Icons.apartment_rounded,
                  ),
                  (AttendanceLocationFilter.wfh, 'WFH', Icons.home_rounded),
                ],
                onChanged: cubit.setLocation,
              ),
              const SizedBox(height: 12),
              _DateToggle(
                expanded: _datesExpanded || dateCount > 0,
                activeCount: dateCount,
                onTap: () => setState(() => _datesExpanded = !_datesExpanded),
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                alignment: Alignment.topCenter,
                child: (_datesExpanded || dateCount > 0)
                    ? Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const _FieldLabel('Exact Date'),
                            const SizedBox(height: 6),
                            _DateField(
                              value: filter.exactDate,
                              hint: 'dd/mm/yyyy',
                              onPick: cubit.setExactDate,
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const _FieldLabel('From'),
                                      const SizedBox(height: 6),
                                      _DateField(
                                        value: filter.fromDate,
                                        hint: 'dd/mm/yyyy',
                                        onPick: cubit.setFromDate,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const _FieldLabel('To'),
                                      const SizedBox(height: 6),
                                      _DateField(
                                        value: filter.toDate,
                                        hint: 'dd/mm/yyyy',
                                        onPick: cubit.setToDate,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      )
                    : const SizedBox(width: double.infinity),
              ),
              const SizedBox(height: 16),
              _ExportButton(state: state, cubit: cubit),
            ],
          ),
        );
      },
    );
  }
}

class _ClearButton extends StatelessWidget {
  const _ClearButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: PortalColors.redTint,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.close_rounded,
                size: 13,
                color: PortalColors.red,
              ),
              const SizedBox(width: 3),
              Text(
                'Clear',
                style: portalText(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  color: PortalColors.red,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OtOnlyPill extends StatelessWidget {
  const _OtOnlyPill({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: OtColors.tint,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: OtColors.accent),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.timer_rounded, size: 12, color: OtColors.text),
            const SizedBox(width: 5),
            Text(
              'Showing OT records only',
              style: portalText(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                color: OtColors.text,
              ),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.close_rounded, size: 13, color: OtColors.text),
          ],
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: portalText(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        color: PortalColors.muted,
        letterSpacing: 0.5,
      ),
    );
  }
}

class _ChipGroup<T> extends StatelessWidget {
  const _ChipGroup({
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final T value;
  final List<(T, String, IconData)> items;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          Expanded(
            child: _FilterChip(
              label: items[i].$2,
              icon: items[i].$3,
              selected: items[i].$1 == value,
              onTap: () => onChanged(items[i].$1),
            ),
          ),
        ],
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fg = selected ? Colors.white : PortalColors.secondaryText;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 34,
        padding: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          color: selected ? PortalColors.brand : PortalColors.background,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? PortalColors.brand : PortalColors.border,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 13, color: fg),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: portalText(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: fg,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DateToggle extends StatelessWidget {
  const _DateToggle({
    required this.expanded,
    required this.activeCount,
    required this.onTap,
  });

  final bool expanded;
  final int activeCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: PortalColors.background,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: activeCount > 0 ? null : onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: PortalColors.border),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.date_range_rounded,
                size: 16,
                color: PortalColors.brandLight,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Filter by date',
                  style: portalText(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: PortalColors.heading,
                  ),
                ),
              ),
              if (activeCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: PortalColors.brand,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '$activeCount active',
                    style: portalText(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                )
              else
                AnimatedRotation(
                  turns: expanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 220),
                  child: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 20,
                    color: PortalColors.muted,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExportButton extends StatelessWidget {
  const _ExportButton({required this.state, required this.cubit});

  final AttendanceState state;
  final AttendanceCubit cubit;

  Future<void> _export(BuildContext context, BuildContext buttonContext) async {
    final count = state.records.length;
    if (count == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No records to export.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    try {
      final result = await cubit.exportCsv();
      if (!context.mounted) return;

      final box = buttonContext.findRenderObject() as RenderBox?;
      final origin = box == null
          ? null
          : box.localToGlobal(Offset.zero) & box.size;

      await SharePlus.instance.share(
        ShareParams(
          files: [
            XFile(
              result.filePath,
              mimeType: 'text/csv',
              name: result.fileName,
            ),
          ],
          sharePositionOrigin: origin,
        ),
      );

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Exported ${result.fileName}'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e is AttendanceFailure ? e.message : 'Failed to export CSV: $e',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (buttonContext) {
        return Material(
          color: PortalColors.green,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: () => _export(context, buttonContext),
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              height: 42,
              width: double.infinity,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.file_download_outlined,
                    size: 17,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Export CSV',
                    style: portalText(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.22),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '${state.records.length}',
                      style: portalText(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.value,
    required this.hint,
    required this.onPick,
  });

  final DateTime? value;
  final String hint;
  final ValueChanged<DateTime?> onPick;

  @override
  Widget build(BuildContext context) {
    final hasValue = value != null;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () async {
        final now = DateTime.now();
        final picked = await showDatePicker(
          context: context,
          initialDate: value ?? now,
          firstDate: DateTime(now.year - 3),
          lastDate: DateTime(now.year + 1),
        );
        if (picked != null) onPick(picked);
      },
      onLongPress: hasValue ? () => onPick(null) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 38,
        padding: EdgeInsets.only(left: 11, right: hasValue ? 4 : 10),
        decoration: BoxDecoration(
          color: hasValue ? PortalColors.brandTint : PortalColors.background,
          borderRadius: BorderRadius.circular(11),
          border: Border.all(
            color: hasValue ? PortalColors.brandLight : PortalColors.border,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_rounded,
              size: 13,
              color: hasValue ? PortalColors.brand : PortalColors.muted,
            ),
            const SizedBox(width: 7),
            Expanded(
              child: Text(
                hasValue ? _format(value!) : hint,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: portalText(
                  fontSize: 12,
                  fontWeight: hasValue ? FontWeight.w600 : FontWeight.w400,
                  color: hasValue ? PortalColors.heading : PortalColors.muted,
                ),
              ),
            ),
            if (hasValue)
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onPick(null),
                child: const Padding(
                  padding: EdgeInsets.all(6),
                  child: Icon(
                    Icons.close_rounded,
                    size: 15,
                    color: PortalColors.muted,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _format(DateTime date) {
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    return '$d/$m/${date.year}';
  }
}
