import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:timelay_health/core/theme/portal_colors.dart';
import 'package:timelay_health/core/theme/portal_text.dart';
import 'package:timelay_health/core/widgets/shimmer.dart';
import 'package:timelay_health/features/auth/domain/entities/employee.dart';
import 'package:timelay_health/features/profile/presentation/bloc/profile_cubit.dart';
import 'package:timelay_health/features/profile/presentation/bloc/profile_state.dart';
import 'package:timelay_health/features/profile/presentation/screens/employee_details_screen.dart';
import 'package:timelay_health/features/profile/presentation/widgets/profile_experience_stats.dart';
import 'package:timelay_health/features/profile/presentation/widgets/profile_hero_card.dart';
import 'package:timelay_health/features/profile/presentation/widgets/profile_info_tiles.dart';
import 'package:timelay_health/features/profile/presentation/widgets/profile_personal_documents.dart';
import 'package:timelay_health/features/profile/presentation/widgets/profile_search_filters.dart';
import 'package:timelay_health/features/profile/presentation/widgets/profile_salary_hike.dart';
import 'package:timelay_health/features/profile/presentation/widgets/profile_section_tabs.dart';
import 'package:timelay_health/features/profile/presentation/widgets/profile_summary_card.dart';
import 'package:timelay_health/features/profile/presentation/widgets/profile_welcome_banner.dart';
import 'package:timelay_health/features/letters/presentation/widgets/resignation_form_sheet.dart';
import 'package:timelay_health/features/holidays/presentation/widgets/top_calendar_button.dart';
import 'package:timelay_health/features/notifications/presentation/widgets/top_notification_button.dart';
import 'package:timelay_health/core/widgets/portal_back_button.dart';
import 'package:timelay_health/core/widgets/portal_safe_area.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProfileCubit()..load(),
      child: const _ProfileView(),
    );
  }
}

class _ProfileView extends StatefulWidget {
  const _ProfileView();

  @override
  State<_ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<_ProfileView> {
  int _tabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PortalColors.background,
      body: PortalSafeArea(
        bottom: false,
        child: Column(
          children: [
            const _ProfileAppBar(),
            Expanded(
              child: BlocConsumer<ProfileCubit, ProfileState>(
                listenWhen: (previous, current) =>
                    current is ProfileFailure && current.employee != null,
                listener: (context, state) {
                  if (state is ProfileFailure) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  return _buildBody(context, state);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, ProfileState state) {
    final Employee? employee = switch (state) {
      ProfileLoaded(:final employee) => employee,
      ProfileLoading(:final employee) => employee,
      ProfileFailure(:final employee) => employee,
      _ => null,
    };

    final loading = state is ProfileLoading || state is ProfileInitial;
    final error = state is ProfileFailure ? state.message : null;

    if (loading && employee == null) {
      return const ProfileShimmer();
    }

    if (error != null && employee == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                error,
                textAlign: TextAlign.center,
                style: portalText(fontSize: 13, color: PortalColors.muted),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => context.read<ProfileCubit>().load(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final data = employee!;
    return RefreshIndicator(
      color: PortalColors.purple,
      onRefresh: () =>
          context.read<ProfileCubit>().load(showFullScreenLoader: false),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: ProfileHeroCard(
              employee: data,
              onTap: () => EmployeeDetailsScreen.open(context, data),
            ),
          ),
          SliverToBoxAdapter(child: ProfileInfoTiles(employee: data)),
          SliverToBoxAdapter(child: ProfileWelcomeBanner(employee: data)),
          SliverToBoxAdapter(child: ProfileSummaryCard(employee: data)),
          const SliverToBoxAdapter(child: ProfileExperienceStats()),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 14),
              child: ProfileSectionTabs(
                selectedIndex: _tabIndex,
                onChanged: (i) => setState(() => _tabIndex = i),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: _TabBody(tabIndex: _tabIndex, employee: data),
          ),
          SliverToBoxAdapter(child: _ResignButton(employee: data)),
          const SliverToBoxAdapter(child: SizedBox(height: 28)),
        ],
      ),
    );
  }
}

class _TabBody extends StatelessWidget {
  const _TabBody({required this.tabIndex, required this.employee});

  final int tabIndex;
  final Employee employee;

  @override
  Widget build(BuildContext context) {
    switch (tabIndex) {
      case 1:
        return const ProfilePersonalDocuments();
      case 4:
        return ProfileSalaryHike(employee: employee);
      case 0:
        return const Column(
          mainAxisSize: MainAxisSize.min,
          children: [ProfileSearchFilters(), _EmptyExperience()],
        );
      default:
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Text(
            'Coming soon',
            textAlign: TextAlign.center,
            style: portalText(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: PortalColors.muted,
            ),
          ),
        );
    }
  }
}

class _ProfileAppBar extends StatelessWidget {
  const _ProfileAppBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: PortalColors.surface,
        border: Border(bottom: BorderSide(color: PortalColors.border)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 10, 18, 10),
      child: Row(
        children: [
          const PortalBackButton(),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'My Profile',
                  style: portalText(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: PortalColors.heading,
                    letterSpacing: 0.1,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Your employee details',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: portalText(
                    fontSize: 11,
                    color: PortalColors.muted,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const TopNotificationButton(),
          const SizedBox(width: 14),
          const TopCalendarButton(),
        ],
      ),
    );
  }
}

class _EmptyExperience extends StatelessWidget {
  const _EmptyExperience();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: _ProfileSvg(asset: 'assets/icons/profile/empty_state.svg'),
    );
  }
}

class _ResignButton extends StatelessWidget {
  const _ResignButton({required this.employee});

  final Employee employee;

  Future<void> _open(BuildContext context) async {
    final submitted = await showResignationFormSheet(
      context,
      employeeId: employee.employeeId,
    );
    if (!submitted || !context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Resignation submitted successfully.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(31, 16, 31, 0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _open(context),
          borderRadius: BorderRadius.circular(11),
          child: const _ProfileSvg(
            asset: 'assets/icons/profile/resign_button.svg',
          ),
        ),
      ),
    );
  }
}

class _ProfileSvg extends StatelessWidget {
  const _ProfileSvg({required this.asset});

  final String asset;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SvgPicture.asset(
          asset,
          width: constraints.maxWidth,
          fit: BoxFit.fitWidth,
        );
      },
    );
  }
}
