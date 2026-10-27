import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timelay_health/core/theme/portal_colors.dart';
import 'package:timelay_health/core/theme/portal_text.dart';
import 'package:timelay_health/features/attendance/presentation/bloc/attendance_cubit.dart';
import 'package:timelay_health/features/attendance/presentation/bloc/attendance_state.dart';
import 'package:timelay_health/features/attendance/presentation/mappers/attendance_ui_mapper.dart';
import 'package:timelay_health/features/attendance/presentation/widgets/claim_ot_sheet.dart';

class OtColors {
  const OtColors._();

  static const accent = PortalColors.orange;
  static const tint = PortalColors.orangeTint;
  static const bg = Color(0xFFFFFAF1);
  static const border = Color(0xFFF5DDB0);
  static const text = Color(0xFFB26A00);
  static const gradient = [Color(0xFFF5B544), Color(0xFFE8930C)];
}

class OtAvailableBanner extends StatelessWidget {
  const OtAvailableBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AttendanceCubit, AttendanceState>(
      buildWhen: (p, c) =>
          p.allRecords != c.allRecords ||
          p.stats != c.stats ||
          p.selectedOtIds != c.selectedOtIds ||
          p.filter.otOnly != c.filter.otOnly,
      builder: (context, state) {
        final otRecords = state.otRecords;
        if (otRecords.isEmpty) return const SizedBox.shrink();

        final cubit = context.read<AttendanceCubit>();
        final totalOt = otRecords.fold<double>(
          0,
          (s, r) => s + r.claimableOtHours,
        );
        final selectedCount = state.selectedOtRecords.length;
        final allSelected = selectedCount == otRecords.length;
        final otOnly = state.filter.otOnly;

        return Container(
          margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFFFF6E6), PortalColors.surface],
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: OtColors.border),
            boxShadow: [
              BoxShadow(
                color: OtColors.accent.withValues(alpha: 0.10),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: OtColors.gradient,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.timer_rounded,
                      size: 18,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'OT Available',
                          style: portalText(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: PortalColors.heading,
                            height: 16 / 13.5,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text.rich(
                          TextSpan(
                            style: portalText(
                              fontSize: 10.5,
                              color: PortalColors.muted,
                              height: 13 / 10.5,
                            ),
                            children: [
                              TextSpan(
                                text: AttendanceUiMapper.hoursLabel(totalOt),
                                style: portalText(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                  color: OtColors.text,
                                ),
                              ),
                              TextSpan(
                                text:
                                    ' across ${otRecords.length} record${otRecords.length == 1 ? '' : 's'}',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  _OtOnlyChip(
                    active: otOnly,
                    onTap: () => cubit.setOtOnly(!otOnly),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(height: 1, color: OtColors.border),
              const SizedBox(height: 10),
              Row(
                children: [
                  _SelectAllAction(
                    allSelected: allSelected,
                    selectedCount: selectedCount,
                    onTap: allSelected
                        ? cubit.clearOtSelection
                        : cubit.selectAllOt,
                  ),
                  const Spacer(),
                  _ClaimButton(
                    count: selectedCount,
                    onTap: selectedCount == 0
                        ? null
                        : () => ClaimOtSheet.show(context),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _OtOnlyChip extends StatelessWidget {
  const _OtOnlyChip({required this.active, required this.onTap});

  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 26,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: active ? OtColors.tint : PortalColors.background,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: active ? OtColors.accent : PortalColors.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              active ? Icons.filter_alt_rounded : Icons.filter_alt_outlined,
              size: 12,
              color: active ? OtColors.text : PortalColors.muted,
            ),
            const SizedBox(width: 4),
            Text(
              'OT only',
              style: portalText(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: active ? OtColors.text : PortalColors.muted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SelectAllAction extends StatelessWidget {
  const _SelectAllAction({
    required this.allSelected,
    required this.selectedCount,
    required this.onTap,
  });

  final bool allSelected;
  final int selectedCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              allSelected
                  ? Icons.check_box_rounded
                  : selectedCount > 0
                  ? Icons.indeterminate_check_box_rounded
                  : Icons.check_box_outline_blank_rounded,
              size: 17,
              color: selectedCount > 0 ? OtColors.accent : PortalColors.muted,
            ),
            const SizedBox(width: 6),
            Text(
              allSelected ? 'Deselect all' : 'Select all',
              style: portalText(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: PortalColors.secondaryText,
              ),
            ),
            if (selectedCount > 0) ...[
              const SizedBox(width: 6),
              Text(
                '· $selectedCount selected',
                style: portalText(fontSize: 10.5, color: PortalColors.muted),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ClaimButton extends StatelessWidget {
  const _ClaimButton({required this.count, required this.onTap});

  final int count;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 180),
      opacity: enabled ? 1 : 0.45,
      child: Material(
        color: Colors.transparent,
        child: Ink(
          height: 32,
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: OtColors.gradient),
            borderRadius: BorderRadius.circular(10),
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    count > 0 ? 'Claim OT ($count)' : 'Claim OT',
                    style: portalText(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 2),
                  const Icon(
                    Icons.chevron_right_rounded,
                    size: 16,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
