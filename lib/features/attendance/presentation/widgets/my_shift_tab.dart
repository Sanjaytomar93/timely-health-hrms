import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:timelay_health/core/theme/portal_colors.dart';
import 'package:timelay_health/core/theme/portal_text.dart';
import 'package:timelay_health/core/widgets/shimmer.dart';
import 'package:timelay_health/features/attendance/presentation/bloc/shift_cubit.dart';
import 'package:timelay_health/features/attendance/presentation/bloc/shift_state.dart';
import 'package:timelay_health/features/attendance/presentation/models/shift_ui_model.dart';
import 'package:timelay_health/features/attendance/presentation/widgets/shift_schedule_section.dart';
import 'package:timelay_health/features/attendance/presentation/widgets/shift_stats_row.dart';

class MyShiftTab extends StatelessWidget {
  const MyShiftTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ShiftCubit()..load(),
      child: const _MyShiftView(),
    );
  }
}

class _MyShiftView extends StatelessWidget {
  const _MyShiftView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ShiftCubit, ShiftState>(
      builder: (context, state) {
        final loading = state is ShiftLoading || state is ShiftInitial;
        final error = state is ShiftFailureState ? state.message : null;
        final shift = state.shift;
        final stats = state.stats;
        final headerDate = state.headerDate.isEmpty
            ? ShiftUiMapper.headerDateLabel(DateTime.now())
            : state.headerDate;

        if (loading && shift == null) {
          return const AttendanceSubTabShimmer();
        }

        return RefreshIndicator(
          color: PortalColors.purple,
          onRefresh: () => context.read<ShiftCubit>().load(keepExisting: true),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: _ShiftHeader(dateLabel: headerDate)),
              SliverToBoxAdapter(child: ShiftStatsRow(stats: stats)),
              if (error != null && shift == null)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 40, 24, 0),
                    child: Column(
                      children: [
                        Text(
                          error,
                          textAlign: TextAlign.center,
                          style: portalText(
                            fontSize: 12,
                            color: PortalColors.muted,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: () => context.read<ShiftCubit>().load(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverToBoxAdapter(
                  child: ShiftScheduleSection(
                    shifts: shift == null ? const [] : [shift],
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          ),
        );
      },
    );
  }
}

class _ShiftHeader extends StatelessWidget {
  const _ShiftHeader({required this.dateLabel});

  final String dateLabel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  'My Shift',
                  style: portalText(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: PortalColors.heading,
                    height: 24 / 20,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
              _DateChip(label: dateLabel),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'See your current and upcoming shift schedule.',
            style: portalText(
              fontSize: 12.5,
              fontWeight: FontWeight.w400,
              color: PortalColors.muted,
              height: 15 / 12.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _DateChip extends StatelessWidget {
  const _DateChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 22,
      padding: const EdgeInsets.only(left: 8, right: 8),
      decoration: BoxDecoration(
        color: PortalColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: PortalColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: portalText(
              fontSize: 10.5,
              fontWeight: FontWeight.w500,
              color: PortalColors.secondaryText,
              height: 13 / 10.5,
            ),
          ),
          const SizedBox(width: 6),
          SvgPicture.asset(
            'assets/icons/check_in/ic_calendar.svg',
            width: 11,
            height: 11,
            colorFilter: const ColorFilter.mode(
              Color(0xFF000000),
              BlendMode.srcIn,
            ),
          ),
        ],
      ),
    );
  }
}
