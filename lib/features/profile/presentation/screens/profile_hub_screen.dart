import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:timelay_health/core/theme/portal_colors.dart';
import 'package:timelay_health/core/theme/portal_text.dart';
import 'package:timelay_health/core/routes/app_routes.dart';
import 'package:timelay_health/features/auth/data/auth_sign_out.dart';
import 'package:timelay_health/features/auth/domain/entities/employee.dart';
import 'package:timelay_health/features/profile/presentation/bloc/profile_cubit.dart';
import 'package:timelay_health/features/profile/presentation/bloc/profile_state.dart';
import 'package:timelay_health/features/holidays/presentation/widgets/top_calendar_button.dart';
import 'package:timelay_health/features/notifications/presentation/widgets/top_notification_button.dart';

class ProfileHubScreen extends StatelessWidget {
  const ProfileHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          ProfileCubit()..load(showFullScreenLoader: false, refresh: false),
      child: const _ProfileHubView(),
    );
  }
}

class _ProfileHubView extends StatefulWidget {
  const _ProfileHubView();

  @override
  State<_ProfileHubView> createState() => _ProfileHubViewState();
}

class _ProfileHubViewState extends State<_ProfileHubView> {
  static const _items = [
    _HubItem(
      title: 'My Profile',
      subtitle: 'View and manage your profile details',
      icon: 'assets/icons/menu/ic_my_profile.svg',
      tint: PortalColors.purpleTint,
    ),
    _HubItem(
      title: 'Payslips',
      subtitle: 'Download and view salary slips',
      icon: 'assets/icons/menu/ic_payslips.svg',
      tint: PortalColors.greenTint,
    ),
    _HubItem(
      title: 'Expense',
      subtitle: 'Track and submit expense claims',
      icon: 'assets/icons/menu/ic_expense.svg',
      tint: PortalColors.orangeTint,
    ),
    _HubItem(
      title: 'Issues',
      subtitle: 'Raise and follow up on issues',
      icon: 'assets/icons/menu/ic_issues.svg',
      tint: PortalColors.redTint,
    ),
    _HubItem(
      title: 'Holiday Calendar',
      subtitle: 'Company holidays & observances',
      icon: 'assets/icons/menu/ic_holiday.svg',
      tint: PortalColors.purpleTint,
    ),
    _HubItem(
      title: 'My Visits',
      subtitle: 'Field visits and location logs',
      icon: 'assets/icons/menu/ic_visits.svg',
      tint: Color(0xFFE8F1FF),
    ),
    _HubItem(
      title: 'Relieving Letters',
      subtitle: 'Experience & relieving letters',
      icon: 'assets/icons/menu/ic_letters.svg',
      tint: PortalColors.greenTint,
    ),
    _HubItem(
      title: 'My Events',
      subtitle: 'Birthdays, anniversaries & reminders',
      icon: 'assets/icons/menu/ic_holiday.svg',
      tint: Color(0xFFFDECF2),
    ),
  ];

  Future<void> _openItem(BuildContext context, int index) async {
    switch (index) {
      case 0:
        await AppRoutes.push(context, AppRoutes.profile);
        if (!context.mounted) return;
        context.read<ProfileCubit>().syncFromSession();
        return;
      case 1:
        await AppRoutes.push(context, AppRoutes.payslips);
        return;
      case 2:
        await AppRoutes.push(context, AppRoutes.expense);
        return;
      case 3:
        await AppRoutes.push(context, AppRoutes.issues);
        return;
      case 4:
        await AppRoutes.push(context, AppRoutes.holidayCalendar);
        return;
      case 5:
        await AppRoutes.push(context, AppRoutes.visits);
        return;
      case 6:
        await AppRoutes.push(context, AppRoutes.letters);
        return;
      case 7:
        await AppRoutes.push(context, AppRoutes.events);
        return;
      default:
        final item = _items[index];
        await AppRoutes.push(
          context,
          AppRoutes.placeholder,
          arguments: item.title,
        );
        return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: PortalColors.background,
      child: Column(
        children: [
          const _HubAppBar(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
              children: [
                BlocBuilder<ProfileCubit, ProfileState>(
                  builder: (context, state) {
                    final employee = switch (state) {
                      ProfileLoaded(:final employee) => employee,
                      ProfileLoading(:final employee) => employee,
                      ProfileFailure(:final employee) => employee,
                      _ => null,
                    };
                    return _HubHero(employee: employee);
                  },
                ),
                const SizedBox(height: 18),
                Text(
                  'Quick access',
                  style: portalText(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: PortalColors.heading,
                  ),
                ),
                const SizedBox(height: 10),
                for (var i = 0; i < _items.length; i++) ...[
                  if (i > 0) const SizedBox(height: 10),
                  _HubTile(item: _items[i], onTap: () => _openItem(context, i)),
                ],
                const SizedBox(height: 10),
                const _LogoutTile(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HubItem {
  const _HubItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.tint,
  });

  final String title;
  final String subtitle;
  final String icon;
  final Color tint;
}

class _HubAppBar extends StatelessWidget {
  const _HubAppBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: PortalColors.surface,
        border: const Border(bottom: BorderSide(color: PortalColors.border)),
        boxShadow: [
          BoxShadow(
            color: PortalColors.brand.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: PortalColors.brandTint,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: SvgPicture.asset(
              'assets/icons/top_bar/ic_top_menu.svg',
              width: 18,
              height: 18,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Profile',
                  style: portalText(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: PortalColors.heading,
                    letterSpacing: 0.1,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Your workspace shortcuts',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: portalText(
                    fontSize: 11.5,
                    color: PortalColors.muted,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const TopNotificationButton(),
          const SizedBox(width: 12),
          const TopCalendarButton(),
        ],
      ),
    );
  }
}

class _HubHero extends StatelessWidget {
  const _HubHero({this.employee});

  final Employee? employee;

  @override
  Widget build(BuildContext context) {
    final name = employee?.displayName ?? 'Employee';
    final initials = employee?.initials ?? 'E';

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          begin: Alignment(-0.9, -0.4),
          end: Alignment(0.9, 0.8),
          colors: [Color(0xFF26204A), Color(0xFF4B4285)],
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.center,
            child: Text(
              initials,
              style: portalText(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  name,
                  style: portalText(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  employee == null
                      ? 'Choose a section below to continue'
                      : '${employee!.employeeId} · ${employee!.role}',
                  style: portalText(
                    fontSize: 11.5,
                    color: Colors.white.withValues(alpha: 0.88),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HubTile extends StatelessWidget {
  const _HubTile({required this.item, required this.onTap});

  final _HubItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: PortalColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 14, 12, 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: PortalColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: item.tint,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: SvgPicture.asset(item.icon, width: 18, height: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      item.title,
                      style: portalText(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: PortalColors.heading,
                        height: 16 / 13.5,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      item.subtitle,
                      style: portalText(
                        fontSize: 11,
                        color: PortalColors.muted,
                        height: 14 / 11,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: PortalColors.muted,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LogoutTile extends StatelessWidget {
  const _LogoutTile();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: PortalColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () async {
          await AuthSignOut.run();
          if (!context.mounted) return;
          AppRoutes.pushAndRemoveUntil(context, AppRoutes.login);
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 14, 12, 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: PortalColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: PortalColors.redTint,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.logout_rounded,
                  size: 18,
                  color: PortalColors.red,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Logout',
                      style: portalText(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: PortalColors.red,
                        height: 16 / 13.5,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Sign out of your account',
                      style: portalText(
                        fontSize: 11,
                        color: PortalColors.muted,
                        height: 14 / 11,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: PortalColors.muted,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
