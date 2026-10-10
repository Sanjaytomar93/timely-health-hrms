import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timelay_health/core/theme/portal_colors.dart';
import 'package:timelay_health/core/theme/portal_text.dart';
import 'package:timelay_health/features/attendance/domain/failures/attendance_failure.dart';
import 'package:timelay_health/features/attendance/presentation/bloc/attendance_cubit.dart';
import 'package:timelay_health/features/attendance/presentation/bloc/attendance_state.dart';
import 'package:timelay_health/features/attendance/presentation/mappers/attendance_ui_mapper.dart';
import 'package:timelay_health/features/attendance/presentation/widgets/ot_available_banner.dart';

class ClaimOtSheet extends StatefulWidget {
  const ClaimOtSheet({super.key});

  static Future<void> show(BuildContext context) {
    final cubit = context.read<AttendanceCubit>();
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          BlocProvider.value(value: cubit, child: const ClaimOtSheet()),
    );
  }

  @override
  State<ClaimOtSheet> createState() => _ClaimOtSheetState();
}

class _ClaimOtSheetState extends State<ClaimOtSheet> {
  final _reason = TextEditingController();
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _reason.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  Future<void> _submit(AttendanceState state) async {
    final records = state.selectedOtRecords;
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    setState(() => _submitting = true);
    try {
      final message = await context.read<AttendanceCubit>().claimOt(
        records: records,
        reason: _reason.text.trim(),
      );
      navigator.pop();
      messenger.showSnackBar(
        SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            e is AttendanceFailure ? e.message : 'Failed to claim OT.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return BlocConsumer<AttendanceCubit, AttendanceState>(
      listenWhen: (p, c) =>
          !_submitting &&
          p.selectedOtIds.isNotEmpty &&
          c.selectedOtRecords.isEmpty,
      listener: (context, _) => Navigator.of(context).pop(),
      builder: (context, state) {
        final records = state.selectedOtRecords;
        final total = records.fold<double>(0, (s, r) => s + r.claimableOtHours);
        final canSubmit =
            !_submitting &&
            records.isNotEmpty &&
            _reason.text.trim().isNotEmpty;

        return Padding(
          padding: EdgeInsets.only(bottom: bottomInset),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.85,
            ),
            decoration: const BoxDecoration(
              color: PortalColors.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      margin: const EdgeInsets.only(top: 10),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: PortalColors.border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 14, 12, 0),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.access_time_filled_rounded,
                          color: OtColors.accent,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Claim OT (${records.length} record${records.length == 1 ? '' : 's'})',
                            style: portalText(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: OtColors.text,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: _submitting
                              ? null
                              : () => Navigator.of(context).pop(),
                          icon: const Icon(
                            Icons.close_rounded,
                            color: PortalColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Claim overtime for selected records',
                          style: portalText(
                            fontSize: 12,
                            color: PortalColors.secondaryText,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '💡 Tap ✕ on any record to remove it from claim',
                          style: portalText(
                            fontSize: 11,
                            color: OtColors.accent,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 1, color: PortalColors.border),
                  Flexible(
                    child: ListView(
                      shrinkWrap: true,
                      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                      children: [
                        for (final r in records) ...[
                          _ClaimRow(
                            date: r.date,
                            hours: AttendanceUiMapper.hoursLabel(
                              r.claimableOtHours,
                            ),
                            onRemove: _submitting
                                ? null
                                : () => context
                                      .read<AttendanceCubit>()
                                      .toggleOtSelection(r.id),
                          ),
                          const SizedBox(height: 8),
                        ],
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: OtColors.tint,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Total OT Hours',
                                  style: portalText(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: PortalColors.heading,
                                  ),
                                ),
                              ),
                              Text(
                                AttendanceUiMapper.hoursLabel(total),
                                style: portalText(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: OtColors.text,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'REASON FOR OT CLAIM',
                          style: portalText(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: PortalColors.muted,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _reason,
                          enabled: !_submitting,
                          minLines: 3,
                          maxLines: 4,
                          style: portalText(
                            fontSize: 13,
                            color: PortalColors.heading,
                          ),
                          decoration: InputDecoration(
                            hintText:
                                'Why are you claiming overtime for these days?',
                            hintStyle: portalText(
                              fontSize: 12,
                              color: PortalColors.muted,
                            ),
                            filled: true,
                            fillColor: PortalColors.background,
                            contentPadding: const EdgeInsets.all(12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(11),
                              borderSide: const BorderSide(
                                color: PortalColors.border,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(11),
                              borderSide: const BorderSide(
                                color: PortalColors.border,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(11),
                              borderSide: const BorderSide(
                                color: OtColors.accent,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: _SheetButton(
                            label: 'Cancel',
                            filled: false,
                            onTap: _submitting
                                ? null
                                : () => Navigator.of(context).pop(),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _SheetButton(
                            label: 'Claim ${records.length} OT',
                            filled: true,
                            loading: _submitting,
                            onTap: canSubmit ? () => _submit(state) : null,
                          ),
                        ),
                      ],
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

class _ClaimRow extends StatelessWidget {
  const _ClaimRow({
    required this.date,
    required this.hours,
    required this.onRemove,
  });

  final String date;
  final String hours;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 4, 4, 4),
      decoration: BoxDecoration(
        color: OtColors.bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: OtColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              date,
              style: portalText(fontSize: 13, color: PortalColors.heading),
            ),
          ),
          Text(
            '+$hours',
            style: portalText(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: OtColors.accent,
            ),
          ),
          IconButton(
            onPressed: onRemove,
            visualDensity: VisualDensity.compact,
            tooltip: 'Remove from selection',
            icon: const Icon(
              Icons.close_rounded,
              size: 18,
              color: PortalColors.red,
            ),
          ),
        ],
      ),
    );
  }
}

class _SheetButton extends StatelessWidget {
  const _SheetButton({
    required this.label,
    required this.filled,
    required this.onTap,
    this.loading = false,
  });

  final String label;
  final bool filled;
  final bool loading;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    final bg = filled
        ? (enabled || loading
              ? OtColors.accent
              : OtColors.accent.withValues(alpha: 0.45))
        : PortalColors.background;

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(11),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(11),
        child: SizedBox(
          height: 44,
          child: Center(
            child: loading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    label,
                    style: portalText(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: filled ? Colors.white : PortalColors.heading,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
