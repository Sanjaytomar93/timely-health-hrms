import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import 'package:timelay_health/core/theme/portal_colors.dart';
import 'package:timelay_health/core/theme/portal_text.dart';
import 'package:timelay_health/features/attendance/domain/failures/attendance_failure.dart';
import 'package:timelay_health/features/attendance/presentation/bloc/attendance_cubit.dart';
import 'package:timelay_health/features/attendance/presentation/bloc/attendance_state.dart';
import 'package:timelay_health/features/attendance/presentation/models/attendance_record_ui_model.dart';

class FiltersActionsCard extends StatelessWidget {
  const FiltersActionsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AttendanceCubit, AttendanceState>(
      builder: (context, state) {
        final filter = state.filter;
        final showing = state.records.length;
        final total = state.allRecords.length;
        final cubit = context.read<AttendanceCubit>();

        return Container(
          margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          padding: const EdgeInsets.fromLTRB(17, 18, 17, 18),
          decoration: BoxDecoration(
            color: PortalColors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: PortalColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '▽ Filters & Actions',
                      style: portalText(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: PortalColors.heading,
                        height: 16 / 13.5,
                      ),
                    ),
                  ),
                  if (filter.hasActiveFilters)
                    GestureDetector(
                      onTap: cubit.clearFilters,
                      child: Text(
                        'Clear',
                        style: portalText(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: PortalColors.purple,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Search and filter records by date, status, and location.',
                style: portalText(
                  fontSize: 10.5,
                  color: PortalColors.muted,
                  height: 13 / 10.5,
                ),
              ),
              if (filter.otOnly) ...[
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () => cubit.setOtOnly(false),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: PortalColors.orangeTint,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: PortalColors.orange),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Showing OT records only',
                          style: portalText(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFFB26A00),
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.close_rounded,
                          size: 13,
                          color: Color(0xFFB26A00),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 14),
              const _FieldLabel('Date'),
              const SizedBox(height: 5),
              _DateField(
                value: filter.exactDate,
                hint: 'dd/mm/yyyy',
                onPick: cubit.setExactDate,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _FieldLabel('From Date'),
                        const SizedBox(height: 5),
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _FieldLabel('To Date'),
                        const SizedBox(height: 5),
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
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _FieldLabel('Status'),
                        const SizedBox(height: 5),
                        _DropdownField<AttendanceStatusFilter>(
                          value: filter.status,
                          label: _statusLabel(filter.status),
                          items: const [
                            (AttendanceStatusFilter.all, 'All Status'),
                            (AttendanceStatusFilter.active, 'checked-in'),
                            (AttendanceStatusFilter.loggedOut, 'checked-out'),
                          ],
                          onChanged: cubit.setStatus,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _FieldLabel('Location'),
                        const SizedBox(height: 5),
                        _DropdownField<AttendanceLocationFilter>(
                          value: filter.location,
                          label: _locationLabel(filter.location),
                          items: const [
                            (AttendanceLocationFilter.all, 'All Locations'),
                            (AttendanceLocationFilter.onsite, 'Onsite'),
                            (AttendanceLocationFilter.wfh, 'WFH'),
                          ],
                          onChanged: cubit.setLocation,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Center(
                child: Builder(
                  builder: (buttonContext) {
                    return Material(
                      color: PortalColors.green,
                      borderRadius: BorderRadius.circular(10),
                      child: InkWell(
                        onTap: () async {
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

                            final box =
                                buttonContext.findRenderObject() as RenderBox?;
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
                                  e is AttendanceFailure
                                      ? e.message
                                      : 'Failed to export CSV: $e',
                                ),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        },
                        borderRadius: BorderRadius.circular(10),
                        child: SizedBox(
                          width: 160,
                          height: 29,
                          child: Center(
                            child: Text(
                              '⬇ Export CSV',
                              style: portalText(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Showing $showing of $total',
                  style: portalText(fontSize: 8, color: PortalColors.muted),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _statusLabel(AttendanceStatusFilter status) {
    return switch (status) {
      AttendanceStatusFilter.all => 'All Status ⌄',
      AttendanceStatusFilter.active => 'Active ⌄',
      AttendanceStatusFilter.loggedOut => 'Logged Out ⌄',
    };
  }

  String _locationLabel(AttendanceLocationFilter location) {
    return switch (location) {
      AttendanceLocationFilter.all => 'All Locations ⌄',
      AttendanceLocationFilter.onsite => 'Onsite ⌄',
      AttendanceLocationFilter.wfh => 'WFH ⌄',
    };
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
        fontSize: 10.5,
        fontWeight: FontWeight.w700,
        color: PortalColors.muted,
        letterSpacing: 0.3,
      ),
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
      onLongPress: value == null ? null : () => onPick(null),
      child: _Box(
        text: value == null ? hint : _format(value!),
        isHint: value == null,
        trailing: value == null
            ? const Icon(
                Icons.calendar_today_outlined,
                size: 14,
                color: PortalColors.muted,
              )
            : GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onPick(null),
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(
                    Icons.close_rounded,
                    size: 15,
                    color: PortalColors.muted,
                  ),
                ),
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

class _DropdownField<T> extends StatelessWidget {
  const _DropdownField({
    required this.value,
    required this.label,
    required this.items,
    required this.onChanged,
  });

  final T value;
  final String label;
  final List<(T, String)> items;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<T>(
      onSelected: onChanged,
      offset: const Offset(0, 40),
      itemBuilder: (context) => [
        for (final item in items)
          PopupMenuItem<T>(
            value: item.$1,
            child: Text(
              item.$2,
              style: portalText(fontSize: 12, color: PortalColors.heading),
            ),
          ),
      ],
      child: _Box(text: label, isHint: false),
    );
  }
}

class _Box extends StatelessWidget {
  const _Box({required this.text, required this.isHint, this.trailing});

  final String text;
  final bool isHint;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      width: double.infinity,
      padding: EdgeInsets.only(left: 13, right: trailing == null ? 13 : 8),
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        color: PortalColors.background,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: PortalColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: portalText(
                fontSize: 12,
                color: isHint ? PortalColors.muted : PortalColors.heading,
                height: 15 / 12,
              ),
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}
