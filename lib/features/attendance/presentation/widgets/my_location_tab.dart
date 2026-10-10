import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:timelay_health/core/theme/portal_colors.dart';
import 'package:timelay_health/core/theme/portal_text.dart';
import 'package:timelay_health/core/widgets/shimmer.dart';
import 'package:timelay_health/features/attendance/presentation/bloc/location_cubit.dart';
import 'package:timelay_health/features/attendance/presentation/bloc/location_state.dart';
import 'package:timelay_health/features/attendance/presentation/models/location_ui_model.dart';
import 'package:timelay_health/features/attendance/presentation/widgets/assigned_locations_section.dart';
import 'package:timelay_health/features/attendance/presentation/widgets/location_info_grid.dart';

class MyLocationTab extends StatelessWidget {
  const MyLocationTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LocationCubit()..load(),
      child: const _MyLocationView(),
    );
  }
}

class _MyLocationView extends StatelessWidget {
  const _MyLocationView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocationCubit, LocationState>(
      builder: (context, state) {
        final loading = state is LocationLoading || state is LocationInitial;
        final error = state is LocationFailureState ? state.message : null;
        final location = state.location;
        final headerDate = state.headerDate.isEmpty
            ? LocationUiMapper.headerDateLabel()
            : state.headerDate;

        return RefreshIndicator(
          color: PortalColors.purple,
          onRefresh: () =>
              context.read<LocationCubit>().load(keepExisting: true),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: _LocationHeader(dateLabel: headerDate)),
              if (loading && location == null)
                const SliverToBoxAdapter(child: ShimmerCardList(itemCount: 3))
              else if (error != null && location == null)
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
                          onPressed: () => context.read<LocationCubit>().load(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              else ...[
                SliverToBoxAdapter(child: LocationInfoGrid(location: location)),
                SliverToBoxAdapter(
                  child: AssignedLocationsSection(location: location),
                ),
              ],
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          ),
        );
      },
    );
  }
}

class _LocationHeader extends StatelessWidget {
  const _LocationHeader({required this.dateLabel});

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
                  'My Location',
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
            'View your office assigned location details.',
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
      padding: const EdgeInsets.symmetric(horizontal: 8),
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
