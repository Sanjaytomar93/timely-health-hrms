import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:timelay_health/core/theme/portal_colors.dart';
import 'package:timelay_health/core/theme/portal_text.dart';
import 'package:timelay_health/core/widgets/shimmer.dart';
import 'package:timelay_health/features/visits/presentation/widgets/my_target_sheet.dart';
import 'package:timelay_health/features/visits/presentation/bloc/visits_cubit.dart';
import 'package:timelay_health/features/visits/presentation/bloc/visits_state.dart';
import 'package:timelay_health/features/visits/presentation/models/visit_ui_model.dart';
import 'package:timelay_health/features/visits/presentation/widgets/add_visit_sheet.dart';
import 'package:timelay_health/features/visits/domain/failures/visit_failure.dart';
import 'package:timelay_health/features/notifications/presentation/widgets/top_notification_button.dart';
import 'package:timelay_health/core/widgets/portal_back_button.dart';
import 'package:timelay_health/core/widgets/portal_safe_area.dart';

class VisitsScreen extends StatelessWidget {
  const VisitsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => VisitsCubit()..load(),
      child: const _VisitsView(),
    );
  }
}

class _VisitsView extends StatefulWidget {
  const _VisitsView();

  @override
  State<_VisitsView> createState() => _VisitsViewState();
}

class _VisitsViewState extends State<_VisitsView> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _confirmDelete(BuildContext context, VisitUiModel visit) async {
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
      await context.read<VisitsCubit>().deleteVisit(visit.id);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Visit deleted successfully'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e is VisitFailure ? e.message : 'Failed to delete visit.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PortalColors.background,
      body: PortalSafeArea(
        bottom: false,
        child: Column(
          children: [
            BlocBuilder<VisitsCubit, VisitsState>(
              buildWhen: (prev, next) =>
                  prev.month != next.month ||
                  prev.monthOptions != next.monthOptions,
              builder: (context, state) {
                final month = state.month.isEmpty
                    ? (VisitUiMapper.monthLabel(DateTime.now()) ?? 'All Months')
                    : state.month;
                return _VisitsFigmaHeader(
                  monthLabel: month,
                  monthOptions: state.monthOptions,
                  onMonthSelected: (v) =>
                      context.read<VisitsCubit>().setMonth(v),
                );
              },
            ),
            Expanded(
              child: BlocBuilder<VisitsCubit, VisitsState>(
                builder: (context, state) {
                  final loading =
                      state is VisitsLoading && state.visits.isEmpty;
                  final refreshing =
                      state is VisitsLoading && state.visits.isNotEmpty;

                  if (loading) {
                    return const VisitsShimmer();
                  }

                  return ListView(
                    padding: const EdgeInsets.only(bottom: 32),
                    children: [
                      if (state is VisitsFailureState && state.visits.isEmpty)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                          child: Text(
                            state.message,
                            textAlign: TextAlign.center,
                            style: portalText(
                              fontSize: 12,
                              color: PortalColors.muted,
                            ),
                          ),
                        ),
                      _StatCardsRow(stats: state.stats),
                      _FiltersCard(
                        search: _search,
                        month: state.month.isEmpty
                            ? (VisitUiMapper.monthLabel(DateTime.now()) ??
                                  'All Months')
                            : state.month,
                        monthOptions: state.monthOptions,
                        status: state.status,
                        shown: state.visits.length,
                        total: state.allVisits.length,
                        isRefreshing: refreshing,
                        onSearch: (v) =>
                            context.read<VisitsCubit>().setSearch(v),
                        onMonth: (v) => context.read<VisitsCubit>().setMonth(v),
                        onStatus: (v) =>
                            context.read<VisitsCubit>().setStatus(v),
                        onRefresh: () => context.read<VisitsCubit>().load(
                          keepExisting: true,
                        ),
                      ),
                      _VisitRecordsSection(
                        visits: state.visits,
                        month: state.month.isEmpty
                            ? (VisitUiMapper.monthLabel(DateTime.now()) ??
                                  'All Months')
                            : state.month,
                        onEdit: (visit) =>
                            showAddVisitSheet(context, visit: visit),
                        onDelete: (visit) => _confirmDelete(context, visit),
                        onAddVisit: () => showAddVisitSheet(context),
                      ),
                      _VisitsFooter(
                        shown: state.visits.length,
                        month: state.month.isEmpty
                            ? (VisitUiMapper.monthLabel(DateTime.now()) ??
                                  'All Months')
                            : state.month,
                        stats: state.stats,
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VisitsFigmaHeader extends StatelessWidget {
  const _VisitsFigmaHeader({
    required this.monthLabel,
    required this.monthOptions,
    required this.onMonthSelected,
  });

  final String monthLabel;
  final List<String> monthOptions;
  final ValueChanged<String> onMonthSelected;

  @override
  Widget build(BuildContext context) {
    final chipLabel = monthLabel == 'All Months' ? 'All Months' : monthLabel;

    return ColoredBox(
      color: PortalColors.surface,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
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
                        'My Visits',
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
                        'Field visits and location logs',
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
                GestureDetector(
                  onTap: () => openNotificationsScreen(context),
                  child: SvgPicture.asset(
                    'assets/icons/visits/ic_notification.svg',
                    width: 34,
                    height: 34,
                  ),
                ),
                const SizedBox(width: 14),
                _MonthMenu(
                  options: monthOptions,
                  onSelected: onMonthSelected,
                  child: SvgPicture.asset(
                    'assets/icons/visits/ic_notification_cal.svg',
                    width: 34,
                    height: 34,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 61,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 11),
              child: Row(
                children: [
                  Expanded(
                    child: _MonthMenu(
                      options: monthOptions,
                      onSelected: onMonthSelected,
                      child: Container(
                        width: double.infinity,
                        height: 40,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF6F5FB),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              'assets/icons/visits/ic_calendar_chip.svg',
                              width: 15,
                              height: 15,
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                chipLabel,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: portalText(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF000000),
                                  height: 14 / 11.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => showMyTargetSheet(context),
                      child: Container(
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFF26204A),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              'assets/icons/visits/target/ic_target_white.svg',
                              width: 12,
                              height: 12,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'View Targets',
                              style: portalText(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                height: 14 / 11.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => showAddVisitSheet(context),
                      child: Container(
                        height: 40,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: PortalColors.brand,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '+Add Visit',
                          style: portalText(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            height: 14 / 11.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MonthMenu extends StatelessWidget {
  const _MonthMenu({
    required this.options,
    required this.onSelected,
    required this.child,
  });

  final List<String> options;
  final ValueChanged<String> onSelected;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      padding: EdgeInsets.zero,
      offset: const Offset(0, 42),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      onSelected: onSelected,
      itemBuilder: (_) => [
        for (final o in options)
          PopupMenuItem(
            value: o,
            child: Text(
              o,
              style: portalText(fontSize: 12, color: PortalColors.heading),
            ),
          ),
      ],
      child: child,
    );
  }
}

class _StatCardsRow extends StatelessWidget {
  const _StatCardsRow({required this.stats});

  final VisitStatsUiModel stats;

  @override
  Widget build(BuildContext context) {
    final items = [
      _StatItem(
        label: 'TOTAL VISITS',
        value: '${stats.total}',
        subtitle: 'this month',
        iconBg: const Color(0xFFEEEDF0),
        iconAsset: 'assets/icons/visits/ic_stat_visits.svg',
      ),
      _StatItem(
        label: 'PENDING',
        value: '${stats.pending}',
        subtitle: 'needs follow-up',
        iconBg: const Color(0xFFE7F7F0),
        iconAsset: 'assets/icons/visits/ic_stat_pending.svg',
      ),
      _StatItem(
        label: 'LEADS',
        value: '${stats.leads}',
        subtitle: 'positive outcomes',
        iconBg: const Color(0xFFFDF3E3),
        iconAsset: 'assets/icons/visits/ic_stat_leads.svg',
      ),
      _StatItem(
        label: 'REJECTED',
        value: '${stats.rejected}',
        subtitle: 'not interested',
        iconBg: const Color(0xFFEAF1FD),
        iconAsset: 'assets/icons/visits/ic_stat_rejected.svg',
      ),
    ];

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(13, 0, 13, 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < items.length; i++) ...[
              if (i > 0) const SizedBox(width: 10),
              _StatCard(item: items[i]),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatItem {
  const _StatItem({
    required this.label,
    required this.value,
    required this.subtitle,
    required this.iconBg,
    required this.iconAsset,
  });

  final String label;
  final String value;
  final String subtitle;
  final Color iconBg;
  final String iconAsset;
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.item});

  final _StatItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 128,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: PortalColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: PortalColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: item.iconBg,
                  borderRadius: BorderRadius.circular(9),
                ),
                alignment: Alignment.center,
                child: SvgPicture.asset(item.iconAsset, width: 13, height: 13),
              ),
              const SizedBox(height: 6),
              Text(
                item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: portalText(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w700,
                  color: PortalColors.muted,
                  letterSpacing: 0.4,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                item.value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: portalText(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: PortalColors.green,
                  height: 1.05,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            item.subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: portalText(
              fontSize: 9.5,
              fontWeight: FontWeight.w400,
              color: PortalColors.muted,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}

class _FiltersCard extends StatelessWidget {
  const _FiltersCard({
    required this.search,
    required this.month,
    required this.monthOptions,
    required this.status,
    required this.shown,
    required this.total,
    required this.isRefreshing,
    required this.onSearch,
    required this.onMonth,
    required this.onStatus,
    required this.onRefresh,
  });

  final TextEditingController search;
  final String month;
  final List<String> monthOptions;
  final String status;
  final int shown;
  final int total;
  final bool isRefreshing;
  final ValueChanged<String> onSearch;
  final ValueChanged<String> onMonth;
  final ValueChanged<String> onStatus;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final monthLabel = month == 'All Months' ? 'all months' : month;

    return Container(
      margin: const EdgeInsets.fromLTRB(10, 5, 10, 0),
      padding: const EdgeInsets.fromLTRB(17, 17, 17, 16),
      decoration: BoxDecoration(
        color: PortalColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: PortalColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                Icons.filter_alt_outlined,
                size: 16,
                color: PortalColors.heading,
              ),
              const SizedBox(width: 4),
              Text(
                'Filters & Actions',
                style: portalText(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: PortalColors.heading,
                  height: 16 / 13.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Filter by month, status, or search by center / client name.',
            style: portalText(
              fontSize: 10.5,
              color: PortalColors.muted,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'SEARCH',
            style: portalText(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: PortalColors.muted,
              letterSpacing: 0.3,
              height: 13 / 10.5,
            ),
          ),
          const SizedBox(height: 5),
          TextField(
            controller: search,
            onChanged: onSearch,
            decoration: InputDecoration(
              hintText: 'Center, client or contact..',
              hintStyle: portalText(
                fontSize: 12,
                color: PortalColors.muted,
                height: 15 / 12,
              ),
              filled: true,
              fillColor: PortalColors.background,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 13,
                vertical: 11,
              ),
              border: _border(),
              enabledBorder: _border(),
              focusedBorder: _border(PortalColors.purple),
            ),
            style: portalText(
              fontSize: 12,
              color: PortalColors.heading,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _DropdownLook(
                  label: 'MONTH',
                  value: month,
                  options: monthOptions,
                  onChanged: onMonth,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _DropdownLook(
                  label: 'STATUS',
                  value: status,
                  options: const ['All Status', 'Pending', 'Lead', 'Rejected'],
                  onChanged: onStatus,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: isRefreshing ? null : onRefresh,
                  child: Container(
                    height: 36,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: PortalColors.background,
                      borderRadius: BorderRadius.circular(11),
                      border: Border.all(color: PortalColors.border),
                    ),
                    child: isRefreshing
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.refresh_rounded,
                                size: 15,
                                color: PortalColors.muted,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Refresh',
                                style: portalText(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  color: PortalColors.muted,
                                  height: 15 / 12,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: () => showAddVisitSheet(context),
                  child: Container(
                    height: 36,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xFF26204A),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '+Add Visit',
                      style: portalText(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        height: 14 / 11.5,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text.rich(
            TextSpan(
              style: portalText(
                fontSize: 8,
                fontWeight: FontWeight.w400,
                color: Colors.black.withValues(alpha: 0.61),
                height: 10 / 8,
              ),
              children: [
                const TextSpan(text: 'Showing '),
                TextSpan(
                  text: '$shown',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const TextSpan(text: ' of '),
                TextSpan(
                  text: '$total',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const TextSpan(text: ' records for '),
                TextSpan(
                  text: monthLabel,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  OutlineInputBorder _border([Color? color]) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(11),
      borderSide: BorderSide(color: color ?? PortalColors.border),
    );
  }
}

class _DropdownLook extends StatelessWidget {
  const _DropdownLook({
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final String label;
  final String value;
  final List<String> options;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: portalText(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: PortalColors.muted,
            letterSpacing: 0.3,
            height: 12 / 10,
          ),
        ),
        const SizedBox(height: 6),
        PopupMenuButton<String>(
          onSelected: onChanged,
          offset: const Offset(0, 40),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          itemBuilder: (_) => [
            for (final o in options)
              PopupMenuItem(
                value: o,
                child: Text(
                  o,
                  style: portalText(fontSize: 12, color: PortalColors.heading),
                ),
              ),
          ],
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: PortalColors.background,
              borderRadius: BorderRadius.circular(11),
              border: Border.all(color: PortalColors.border),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value == 'All Status' ? 'All Status ⌄' : value,
                    overflow: TextOverflow.ellipsis,
                    style: portalText(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: PortalColors.muted,
                      height: 15 / 12,
                    ),
                  ),
                ),
                if (value != 'All Status')
                  Text(
                    '⌄',
                    style: portalText(
                      fontSize: 14,
                      color: PortalColors.muted,
                      height: 1,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _VisitRecordsSection extends StatelessWidget {
  const _VisitRecordsSection({
    required this.visits,
    required this.month,
    required this.onEdit,
    required this.onDelete,
    required this.onAddVisit,
  });

  final List<VisitUiModel> visits;
  final String month;
  final ValueChanged<VisitUiModel> onEdit;
  final ValueChanged<VisitUiModel> onDelete;
  final VoidCallback onAddVisit;

  @override
  Widget build(BuildContext context) {
    final monthLabel = month == 'All Months' ? 'all months' : month;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 22, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: PortalColors.brandTint,
                  borderRadius: BorderRadius.circular(9),
                ),
                alignment: Alignment.center,
                child: SvgPicture.asset(
                  'assets/icons/visits/ic_stat_visits.svg',
                  width: 15,
                  height: 15,
                  colorFilter: const ColorFilter.mode(
                    PortalColors.brand,
                    BlendMode.srcIn,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Visit Records',
                style: portalText(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  color: PortalColors.heading,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: PortalColors.brand.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${visits.length}',
                  style: portalText(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: PortalColors.brand,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'All your visit and client interactions for $monthLabel.',
            style: portalText(
              fontSize: 11,
              fontWeight: FontWeight.w400,
              color: PortalColors.muted,
            ),
          ),
          const SizedBox(height: 14),
          if (visits.isEmpty)
            _EmptyVisitsCard(onAddVisit: onAddVisit)
          else
            for (var i = 0; i < visits.length; i++) ...[
              if (i > 0) const SizedBox(height: 12),
              _VisitRecordCard(
                record: visits[i],
                onEdit: () => onEdit(visits[i]),
                onDelete: () => onDelete(visits[i]),
              ),
            ],
        ],
      ),
    );
  }
}

class _EmptyVisitsCard extends StatelessWidget {
  const _EmptyVisitsCard({required this.onAddVisit});

  final VoidCallback onAddVisit;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
      decoration: BoxDecoration(
        color: PortalColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: PortalColors.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: const BoxDecoration(
              color: PortalColors.brandTint,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.location_city_outlined,
              size: 26,
              color: PortalColors.brand,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'No Visit Records Found',
            style: portalText(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: PortalColors.heading,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'There are no visit records recorded for the selected filter.',
            textAlign: TextAlign.center,
            style: portalText(
              fontSize: 11.5,
              fontWeight: FontWeight.w400,
              color: PortalColors.muted,
            ),
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: onAddVisit,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
              decoration: BoxDecoration(
                color: PortalColors.brand,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.add_rounded, size: 16, color: Colors.white),
                  const SizedBox(width: 6),
                  Text(
                    'Add Visit',
                    style: portalText(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VisitRecordCard extends StatelessWidget {
  const _VisitRecordCard({
    required this.record,
    required this.onEdit,
    required this.onDelete,
  });

  final VisitUiModel record;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  void _copyToClipboard(BuildContext context, String text, String label) {
    if (text.trim().isEmpty || text == '—') return;
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label copied to clipboard'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasRemark = record.remark != '--' && record.remark.trim().isNotEmpty;
    final hasValidPhone = record.phone.trim().isNotEmpty && record.phone != '—';
    final hasValidAddress =
        record.address.trim().isNotEmpty && record.address != '—';

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: PortalColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: PortalColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x061C1B29),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Top Header: Index & Date on left, Status chip on right
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Index Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: PortalColors.background,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: PortalColors.border.withValues(alpha: 0.6),
                    ),
                  ),
                  child: Text(
                    record.index,
                    style: portalText(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: PortalColors.brand,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Date
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 13,
                      color: PortalColors.muted,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      record.date,
                      style: portalText(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: PortalColors.muted,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                // Status Pill with dot
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: record.statusBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: record.statusColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        record.status,
                        style: portalText(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: record.statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1, thickness: 1, color: PortalColors.border),

          // Main Card Content
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Center / Clinic Title
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: PortalColors.brand.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.local_hospital_outlined,
                        size: 17,
                        color: PortalColors.brand,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            record.center,
                            style: portalText(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w700,
                              color: PortalColors.heading,
                              height: 1.25,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              const Icon(
                                Icons.person_outline_rounded,
                                size: 14,
                                color: PortalColors.muted,
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  record.contact,
                                  style: portalText(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: PortalColors.secondaryText,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Phone Row (if available)
                if (hasValidPhone) ...[
                  const SizedBox(height: 10),
                  InkWell(
                    onTap: () => _copyToClipboard(
                      context,
                      record.phone,
                      'Phone number',
                    ),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: PortalColors.background,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: PortalColors.border.withValues(alpha: 0.6),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.phone_outlined,
                            size: 13,
                            color: PortalColors.green,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            record.phone,
                            style: portalText(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: PortalColors.heading,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(
                            Icons.copy_rounded,
                            size: 11,
                            color: PortalColors.muted,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],

                // Location / Address Row
                if (hasValidAddress) ...[
                  const SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 2),
                        child: Icon(
                          Icons.location_on_outlined,
                          size: 15,
                          color: PortalColors.brandLight,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          record.address,
                          style: portalText(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w400,
                            color: PortalColors.secondaryText,
                            height: 1.35,
                          ),
                        ),
                      ),
                      if (record.locationExtra != null) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEAF1FD),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.my_location_rounded,
                                size: 10,
                                color: Color(0xFF319DF0),
                              ),
                              const SizedBox(width: 3),
                              Text(
                                'GPS',
                                style: portalText(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF319DF0),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ],

                // Remarks Box (if present)
                if (hasRemark) ...[
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: PortalColors.background,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: PortalColors.border.withValues(alpha: 0.7),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 1),
                          child: Icon(
                            Icons.sticky_note_2_outlined,
                            size: 13,
                            color: PortalColors.muted,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Remark: ',
                                  style: portalText(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: PortalColors.secondaryText,
                                    height: 1.3,
                                  ),
                                ),
                                TextSpan(
                                  text: record.remark,
                                  style: portalText(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w400,
                                    color: PortalColors.heading,
                                    height: 1.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Bottom Actions
                const SizedBox(height: 12),
                const Divider(height: 1, thickness: 1, color: PortalColors.border),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    InkWell(
                      onTap: onEdit,
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: PortalColors.brand.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SvgPicture.asset(
                              'assets/icons/visits/ic_edit.svg',
                              width: 13,
                              height: 13,
                              colorFilter: const ColorFilter.mode(
                                PortalColors.brand,
                                BlendMode.srcIn,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              'Edit',
                              style: portalText(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: PortalColors.brand,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    InkWell(
                      onTap: onDelete,
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: PortalColors.redTint,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SvgPicture.asset(
                              'assets/icons/visits/ic_delete.svg',
                              width: 13,
                              height: 13,
                              colorFilter: const ColorFilter.mode(
                                PortalColors.red,
                                BlendMode.srcIn,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              'Delete',
                              style: portalText(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: PortalColors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _VisitsFooter extends StatelessWidget {
  const _VisitsFooter({
    required this.shown,
    required this.month,
    required this.stats,
  });

  final int shown;
  final String month;
  final VisitStatsUiModel stats;

  @override
  Widget build(BuildContext context) {
    if (shown == 0) return const SizedBox.shrink();
    final monthLabel = month == 'All Months' ? 'All Months' : month;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        decoration: BoxDecoration(
          color: PortalColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: PortalColors.border),
          boxShadow: [
            BoxShadow(
              color: PortalColors.brand.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: PortalColors.brandGradient,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.insights_rounded,
                      size: 15,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Showing $shown records',
                          style: portalText(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'for $monthLabel',
                          style: portalText(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withValues(alpha: 0.85),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _SummaryPill(
                    label: 'Leads',
                    count: stats.leads,
                    color: const Color(0xFF319DF0),
                    bgColor: const Color(0xFFEAF1FD),
                    align: Alignment.centerLeft,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _SummaryPill(
                    label: 'Pending',
                    count: stats.pending,
                    color: PortalColors.orange,
                    bgColor: PortalColors.orangeTint,
                    align: Alignment.center,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _SummaryPill(
                    label: 'Rejected',
                    count: stats.rejected,
                    color: PortalColors.red,
                    bgColor: PortalColors.redTint,
                    align: Alignment.centerRight,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryPill extends StatelessWidget {
  const _SummaryPill({
    required this.label,
    required this.count,
    required this.color,
    required this.bgColor,
    this.align = Alignment.center,
  });

  final String label;
  final int count;
  final Color color;
  final Color bgColor;
  final Alignment align;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: align,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 9),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(11),
          border: Border.all(color: color.withValues(alpha: 0.18)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$count',
              style: portalText(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: color,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: portalText(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
