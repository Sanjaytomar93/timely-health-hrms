import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:timelay_health/core/theme/portal_colors.dart';
import 'package:timelay_health/core/theme/portal_text.dart';
import 'package:timelay_health/core/widgets/shimmer.dart';
import 'package:timelay_health/features/issues/domain/failures/issue_failure.dart';
import 'package:timelay_health/features/issues/presentation/bloc/issues_cubit.dart';
import 'package:timelay_health/features/issues/presentation/bloc/issues_state.dart';
import 'package:timelay_health/features/issues/presentation/models/issue_ui_model.dart';
import 'package:timelay_health/features/issues/presentation/widgets/issue_details_dialog.dart';
import 'package:timelay_health/features/issues/presentation/widgets/raise_issue_sheet.dart';
import 'package:timelay_health/features/holidays/presentation/widgets/top_calendar_button.dart';
import 'package:timelay_health/features/notifications/presentation/widgets/top_notification_button.dart';
import 'package:timelay_health/core/widgets/portal_safe_area.dart';
import 'package:timelay_health/features/dashboard/presentation/screens/employee_home_shell.dart';
import 'package:timelay_health/features/dashboard/presentation/widgets/employee_bottom_nav.dart';
import 'package:timelay_health/features/dashboard/presentation/widgets/home_side_drawer.dart';

class IssuesScreen extends StatelessWidget {
  const IssuesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => IssuesCubit()..load(),
      child: const _IssuesView(),
    );
  }
}

class _IssuesView extends StatefulWidget {
  const _IssuesView();

  @override
  State<_IssuesView> createState() => _IssuesViewState();
}

class _IssuesViewState extends State<_IssuesView> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _confirmDelete(BuildContext context, IssueUiModel issue) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Are you sure?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    try {
      await context.read<IssuesCubit>().deleteIssue(issue.id);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Issue deleted successfully'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e is IssueFailure ? e.message : 'Failed to delete issue.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _openDetails(IssueUiModel issue) async {
    final action = await showIssueDetailsDialog(context, issue: issue);
    if (!mounted || action == null) return;
    if (action == IssueDetailAction.edit) {
      showEditIssueSheet(context, issue: issue);
    } else {
      _confirmDelete(context, issue);
    }
  }

  void _resetFilters() {
    _search.clear();
    context.read<IssuesCubit>().resetFilters();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: PortalColors.background,
      drawer: const HomeSideDrawer(),
      drawerScrimColor: PortalColors.brand.withValues(alpha: 0.28),
      body: PortalSafeArea(
        bottom: false,
        child: Column(
          children: [
            _IssuesAppBar(
              onMenuTap: () => _scaffoldKey.currentState?.openDrawer(),
            ),
            Expanded(
              child: BlocBuilder<IssuesCubit, IssuesState>(
                builder: (context, state) {
                  final loading =
                      state is IssuesInitial || state is IssuesLoading;
                  final failure = state is IssuesFailureState ? state : null;
                  final showSpinner = loading && state.allIssues.isEmpty;
                  final showError = failure != null && state.allIssues.isEmpty;

                  final openCount = state.allIssues
                      .where((e) => e.status.toLowerCase() == 'open')
                      .length;
                  final progressCount = state.allIssues
                      .where(
                        (e) => e.status.toLowerCase().contains('progress'),
                      )
                      .length;
                  final resolvedCount = state.allIssues.where((e) {
                    final s = e.status.toLowerCase();
                    return s == 'resolved' || s == 'closed';
                  }).length;

                  if (showSpinner) {
                    return const IssuesShimmer();
                  }

                  return RefreshIndicator(
                    color: PortalColors.purple,
                    onRefresh: () =>
                        context.read<IssuesCubit>().load(keepExisting: true),
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.only(bottom: 36),
                      children: [
                        _SearchSection(
                          controller: _search,
                          onChanged: context.read<IssuesCubit>().setSearch,
                          total: state.allIssues.length,
                          open: openCount,
                          inProgress: progressCount,
                          resolved: resolvedCount,
                        ),
                        _RaiseBanner(
                          onRaise: () => showRaiseIssueSheet(context),
                        ),
                        _FiltersCard(
                          priority: state.priority,
                          status: state.status,
                          type: state.type,
                          onPriority: context.read<IssuesCubit>().setPriority,
                          onStatus: context.read<IssuesCubit>().setStatus,
                          onType: context.read<IssuesCubit>().setType,
                          onReset: _resetFilters,
                        ),
                        const _SectionHeader(),
                        if (showError)
                          _IssuesError(
                            message: failure.message,
                            onRetry: () => context.read<IssuesCubit>().load(),
                          )
                        else if (state.issues.isEmpty)
                          const _EmptyIssues()
                        else ...[
                          ...state.issues.map(
                            (issue) => Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                              child: _IssueCard(
                                issue: issue,
                                onView: () => _openDetails(issue),
                                onEdit: () =>
                                    showEditIssueSheet(context, issue: issue),
                                onDelete: () => _confirmDelete(context, issue),
                              ),
                            ),
                          ),
                          _ListCountFooter(
                            showing: state.issues.length,
                            total: state.allIssues.length,
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    
      bottomNavigationBar: EmployeeBottomNav(
        currentIndex: 3,
        onTap: (i) => EmployeeHomeShell.goToTab(context, i),
      ),
    );
  }
}

class _IssuesAppBar extends StatelessWidget {
  const _IssuesAppBar({required this.onMenuTap});

  final VoidCallback onMenuTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: PortalColors.surface,
        border: const Border(bottom: BorderSide(color: PortalColors.border)),
        boxShadow: [
          BoxShadow(
            color: PortalColors.brand.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: onMenuTap,
            behavior: HitTestBehavior.opaque,
            child: Container(
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
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'My Issues',
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
                  'Track & resolve reported issues',
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
          const TopNotificationButton(
            asset: 'assets/icons/issues/ic_notification.svg',
          ),
          const SizedBox(width: 12),
          const TopCalendarButton(
            asset: 'assets/icons/issues/ic_notification_cal.svg',
          ),
        ],
      ),
    );
  }
}

class _SearchSection extends StatelessWidget {
  const _SearchSection({
    required this.controller,
    required this.onChanged,
    required this.total,
    required this.open,
    required this.inProgress,
    required this.resolved,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final int total;
  final int open;
  final int inProgress;
  final int resolved;

  static const double _gap = 6;
  static const int _visibleCount = 3;

  @override
  Widget build(BuildContext context) {
    final items = [
      _StatData(
        label: 'TOTAL',
        value: '$total',
        subtitle: 'all reports',
        icon: Icons.assignment_outlined,
        iconBg: PortalColors.brandTint,
        iconColor: PortalColors.brand,
        valueColor: PortalColors.heading,
      ),
      _StatData(
        label: 'OPEN',
        value: '$open',
        subtitle: 'needs action',
        icon: Icons.radio_button_checked_rounded,
        iconBg: const Color(0xFFE8F0FE),
        iconColor: const Color(0xFF305CEA),
        valueColor: const Color(0xFF305CEA),
      ),
      _StatData(
        label: 'PROGRESS',
        value: '$inProgress',
        subtitle: 'being worked',
        icon: Icons.timelapse_rounded,
        iconBg: PortalColors.orangeTint,
        iconColor: PortalColors.orange,
        valueColor: PortalColors.orange,
      ),
      _StatData(
        label: 'RESOLVED',
        value: '$resolved',
        subtitle: 'completed',
        icon: Icons.check_circle_outline_rounded,
        iconBg: PortalColors.greenTint,
        iconColor: PortalColors.green,
        valueColor: PortalColors.green,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: controller,
            onChanged: onChanged,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText:
                  'Search issues by title, description, or employee name...',
              hintStyle: portalText(
                fontSize: 12.5,
                color: const Color(0xFF9A98AB),
              ),
              prefixIcon: Padding(
                padding: const EdgeInsets.only(left: 14, right: 8),
                child: SvgPicture.asset(
                  'assets/icons/issues/ic_search.svg',
                  width: 16,
                  height: 16,
                ),
              ),
              prefixIconConstraints: const BoxConstraints(
                minWidth: 40,
                minHeight: 0,
              ),
              suffixIcon: ValueListenableBuilder<TextEditingValue>(
                valueListenable: controller,
                builder: (_, value, __) {
                  if (value.text.isEmpty) return const SizedBox.shrink();
                  return IconButton(
                    onPressed: () {
                      controller.clear();
                      onChanged('');
                    },
                    icon: const Icon(
                      Icons.close_rounded,
                      size: 18,
                      color: PortalColors.muted,
                    ),
                  );
                },
              ),
              filled: true,
              fillColor: PortalColors.surface,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 14,
              ),
              border: _border(),
              enabledBorder: _border(),
              focusedBorder: _border(PortalColors.brand),
            ),
            style: portalText(fontSize: 13.5, color: PortalColors.heading),
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final statWidth =
                  (constraints.maxWidth - (_gap * (_visibleCount - 1))) /
                  _visibleCount;
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    for (var i = 0; i < items.length; i++) ...[
                      if (i > 0) const SizedBox(width: _gap),
                      SizedBox(
                        width: statWidth,
                        child: _StatCard(data: items[i]),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  OutlineInputBorder _border([Color? color]) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: color ?? PortalColors.border),
    );
  }
}

class _StatData {
  const _StatData({
    required this.label,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.valueColor,
  });

  final String label;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final Color valueColor;
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.data});

  final _StatData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
      decoration: BoxDecoration(
        color: PortalColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: PortalColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: data.iconBg,
              borderRadius: BorderRadius.circular(6),
            ),
            alignment: Alignment.center,
            child: Icon(data.icon, size: 11, color: data.iconColor),
          ),
          const SizedBox(height: 6),
          Text(
            data.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: portalText(
              fontSize: 8.5,
              fontWeight: FontWeight.w700,
              color: PortalColors.muted,
              letterSpacing: 0.25,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            data.value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: portalText(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: data.valueColor,
              height: 1.1,
            ),
          ),
          Text(
            data.subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: portalText(fontSize: 8.5, color: PortalColors.muted),
          ),
        ],
      ),
    );
  }
}

class _RaiseBanner extends StatelessWidget {
  const _RaiseBanner({required this.onRaise});

  final VoidCallback onRaise;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment(-0.9, -0.4),
          end: Alignment(0.9, 0.5),
          colors: PortalColors.brandGradient,
        ),
        boxShadow: [
          BoxShadow(
            color: PortalColors.brand.withValues(alpha: 0.28),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          Positioned(
            right: -36,
            top: -42,
            child: IgnorePointer(
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),
            ),
          ),
          Positioned(
            right: 28,
            bottom: -48,
            child: IgnorePointer(
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.06),
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'NEED HELP?',
                style: portalText(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Colors.white.withValues(alpha: 0.75),
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Raise a new issue in seconds',
                style: portalText(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Report technical, HR or other concerns and track progress until resolved.',
                style: portalText(
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: 0.85),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  onTap: onRaise,
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.add_rounded,
                          size: 18,
                          color: PortalColors.brand,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Raise Issue',
                          style: portalText(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: PortalColors.brand,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FiltersCard extends StatelessWidget {
  const _FiltersCard({
    required this.priority,
    required this.status,
    required this.type,
    required this.onPriority,
    required this.onStatus,
    required this.onType,
    required this.onReset,
  });

  final String priority;
  final String status;
  final String type;
  final ValueChanged<String> onPriority;
  final ValueChanged<String> onStatus;
  final ValueChanged<String> onType;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        color: PortalColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: PortalColors.border),
        boxShadow: [
          BoxShadow(
            color: PortalColors.brand.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: PortalColors.brandTint,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: SvgPicture.asset(
                  'assets/icons/issues/ic_filter.svg',
                  width: 14,
                  height: 14,
                  colorFilter: const ColorFilter.mode(
                    PortalColors.brand,
                    BlendMode.srcIn,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Filters',
                      style: portalText(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: PortalColors.heading,
                      ),
                    ),
                    Text(
                      'Narrow down by priority, status & type',
                      style: portalText(
                        fontSize: 11,
                        color: PortalColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: onReset,
                style: TextButton.styleFrom(
                  foregroundColor: PortalColors.brandLight,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Reset',
                  style: portalText(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: PortalColors.brandLight,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _DropdownField(
            label: 'PRIORITY',
            value: priority,
            items: const ['All', 'Critical', 'High', 'Medium', 'Low'],
            onChanged: onPriority,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _DropdownField(
                  label: 'STATUS',
                  value: status,
                  items: const [
                    'All Status',
                    'Open',
                    'In Progress',
                    'Resolved',
                    'Closed',
                  ],
                  onChanged: onStatus,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _DropdownField(
                  label: 'TYPE',
                  value: type,
                  items: const [
                    'All',
                    'Technical',
                    'HR',
                    'Facility',
                    'IT Support',
                    'Finance',
                    'Other',
                  ],
                  onChanged: onType,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DropdownField extends StatelessWidget {
  const _DropdownField({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: portalText(
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
            color: PortalColors.muted,
            letterSpacing: 0.35,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 42,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: PortalColors.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: PortalColors.border),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              icon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 20,
                color: PortalColors.muted,
              ),
              style: portalText(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: PortalColors.heading,
              ),
              dropdownColor: PortalColors.surface,
              borderRadius: BorderRadius.circular(12),
              items: [
                for (final item in items)
                  DropdownMenuItem(value: item, child: Text(item)),
              ],
              onChanged: (v) {
                if (v != null) onChanged(v);
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 12),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: PortalColors.brandTint,
              borderRadius: BorderRadius.circular(9),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.list_alt_rounded,
              size: 15,
              color: PortalColors.brand,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Issues List',
            style: portalText(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: PortalColors.heading,
            ),
          ),
        ],
      ),
    );
  }
}

class _ListCountFooter extends StatelessWidget {
  const _ListCountFooter({required this.showing, required this.total});

  final int showing;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 4, 18, 8),
      child: Center(
        child: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: 'Showing ',
                style: portalText(
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  color: PortalColors.muted,
                ),
              ),
              TextSpan(
                text: '$showing',
                style: portalText(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: PortalColors.secondaryText,
                ),
              ),
              TextSpan(
                text: ' of ',
                style: portalText(
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  color: PortalColors.muted,
                ),
              ),
              TextSpan(
                text: '$total',
                style: portalText(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: PortalColors.secondaryText,
                ),
              ),
              TextSpan(
                text: ' Issues',
                style: portalText(
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
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

class _IssueCard extends StatelessWidget {
  const _IssueCard({
    required this.issue,
    required this.onView,
    required this.onEdit,
    required this.onDelete,
  });

  final IssueUiModel issue;
  final VoidCallback onView;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final typeColors = _typeTagColors();
    final priorityColors = _priorityTagColors(issue.priority);
    final statusColors = _statusTagColors(issue.status);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onView,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          decoration: BoxDecoration(
            color: PortalColors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: PortalColors.border),
            boxShadow: [
              BoxShadow(
                color: PortalColors.brand.withValues(alpha: 0.05),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 12, 13),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        issue.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: portalText(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                          color: PortalColors.heading,
                          height: 1.25,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _ActionChip(
                      icon: Icons.visibility_outlined,
                      onTap: onView,
                    ),
                    const SizedBox(width: 4),
                    _ActionChip(icon: Icons.edit_outlined, onTap: onEdit),
                    const SizedBox(width: 4),
                    _ActionChip(
                      icon: Icons.delete_outline_rounded,
                      onTap: onDelete,
                      danger: true,
                    ),
                  ],
                ),
                if (issue.description.trim().isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    issue.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: portalText(
                      fontSize: 12.5,
                      color: PortalColors.muted,
                      height: 1.4,
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _Tag(
                      label: issue.issueType,
                      background: typeColors.$1,
                      color: typeColors.$2,
                    ),
                    _Tag(
                      label: issue.priority,
                      background: priorityColors.$1,
                      color: priorityColors.$2,
                    ),
                    _Tag(
                      label: issue.status,
                      background: statusColors.$1,
                      color: statusColors.$2,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(top: 10),
                  decoration: const BoxDecoration(
                    border: Border(
                      top: BorderSide(color: PortalColors.border),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_rounded,
                        size: 13,
                        color: PortalColors.muted,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        issue.dateLabel,
                        style: portalText(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                          color: PortalColors.muted,
                        ),
                      ),
                      if (issue.department.trim().isNotEmpty) ...[
                        const SizedBox(width: 12),
                        const Icon(
                          Icons.apartment_rounded,
                          size: 14,
                          color: PortalColors.muted,
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            issue.department,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: portalText(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w500,
                              color: PortalColors.muted,
                            ),
                          ),
                        ),
                      ] else
                        const Spacer(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  (Color, Color) _typeTagColors() {
    return (const Color(0xFFF1F0F4), const Color(0xFF6B6680));
  }

  (Color, Color) _priorityTagColors(String priority) {
    switch (priority.toLowerCase()) {
      case 'critical':
        return (const Color(0xFFFDECEC), const Color(0xFFB71C1C));
      case 'high':
        return (const Color(0xFFFDECEC), const Color(0xFFE53935));
      case 'medium':
        return (const Color(0xFFFEF4E3), const Color(0xFFF0A72E));
      case 'low':
        return (const Color(0xFFE7F7F0), const Color(0xFF1FA971));
      default:
        return (const Color(0xFFF1F0F4), const Color(0xFF6B6680));
    }
  }

  (Color, Color) _statusTagColors(String status) {
    final normalized = status.toLowerCase();
    if (normalized == 'resolved' || normalized == 'closed') {
      return (const Color(0xFFE7F7F0), const Color(0xFF1FA971));
    }
    if (normalized == 'open') {
      return (const Color(0xFFE8F0FE), const Color(0xFF305CEA));
    }
    if (normalized.contains('progress')) {
      return (const Color(0xFFFEF4E3), const Color(0xFFF0A72E));
    }
    return (const Color(0xFFF1F0F4), const Color(0xFF6B6680));
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({
    required this.icon,
    required this.onTap,
    this.danger = false,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: danger ? PortalColors.redTint : PortalColors.background,
      borderRadius: BorderRadius.circular(9),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(9),
        child: SizedBox(
          width: 30,
          height: 30,
          child: Icon(
            icon,
            size: 15,
            color: danger ? PortalColors.red : PortalColors.secondaryText,
          ),
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({
    required this.label,
    required this.background,
    required this.color,
  });

  final String label;
  final Color background;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: portalText(
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
          color: color,
          height: 1.1,
        ),
      ),
    );
  }
}

class _EmptyIssues extends StatelessWidget {
  const _EmptyIssues();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 0),
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 28),
      decoration: BoxDecoration(
        color: PortalColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: PortalColors.border),
        boxShadow: [
          BoxShadow(
            color: PortalColors.brand.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: PortalColors.brand.withValues(alpha: 0.05),
                ),
              ),
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: PortalColors.brandGradient,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: PortalColors.brand.withValues(alpha: 0.25),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.task_alt_rounded,
                  size: 34,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            'All clear for now',
            style: portalText(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: PortalColors.heading,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'No issues match your search or filters.\nRaise a new issue if something needs attention.',
            textAlign: TextAlign.center,
            style: portalText(
              fontSize: 12.5,
              color: PortalColors.muted,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: PortalColors.brandTint,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.lightbulb_outline_rounded,
                  size: 16,
                  color: PortalColors.brand,
                ),
                const SizedBox(width: 8),
                Text(
                  'Tip: Reset filters to see everything',
                  style: portalText(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: PortalColors.brand,
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

class _IssuesError extends StatelessWidget {
  const _IssuesError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 0),
      child: Column(
        children: [
          Text(
            message,
            textAlign: TextAlign.center,
            style: portalText(
              fontSize: 12,
              color: PortalColors.muted,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            child: Ink(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: const LinearGradient(
                  colors: PortalColors.brandGradient,
                ),
              ),
              child: InkWell(
                onTap: onRetry,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  child: Text(
                    'Retry',
                    style: portalText(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
