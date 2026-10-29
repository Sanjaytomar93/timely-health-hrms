import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:timelay_health/core/theme/portal_colors.dart';
import 'package:timelay_health/core/theme/portal_text.dart';
import 'package:timelay_health/core/widgets/shimmer.dart';
import 'package:timelay_health/features/expense/domain/failures/expense_failure.dart';
import 'package:timelay_health/features/expense/presentation/bloc/expense_cubit.dart';
import 'package:timelay_health/features/expense/presentation/bloc/expense_state.dart';
import 'package:timelay_health/features/expense/presentation/models/expense_claim_ui_model.dart';
import 'package:timelay_health/features/expense/presentation/widgets/edit_expense_sheet.dart';
import 'package:timelay_health/features/expense/presentation/widgets/expense_details_dialog.dart';
import 'package:timelay_health/features/expense/presentation/widgets/record_expense_sheet.dart';
import 'package:timelay_health/features/holidays/presentation/widgets/top_calendar_button.dart';
import 'package:timelay_health/features/notifications/presentation/widgets/top_notification_button.dart';
import 'package:timelay_health/core/widgets/portal_back_button.dart';
import 'package:timelay_health/core/widgets/portal_safe_area.dart';
import 'package:timelay_health/features/auth/data/auth_session.dart';

class ExpenseScreen extends StatelessWidget {
  const ExpenseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ExpenseCubit()..load(),
      child: const _ExpenseView(),
    );
  }
}

class _ExpenseView extends StatelessWidget {
  const _ExpenseView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PortalColors.background,
      body: PortalSafeArea(
        bottom: false,
        child: Column(
          children: [
            const _ExpenseAppBar(),
            Expanded(
              child: BlocConsumer<ExpenseCubit, ExpenseState>(
                listenWhen: (previous, current) =>
                    current is ExpenseFailureState &&
                    current.expenses.isNotEmpty,
                listener: (context, state) {
                  if (state is ExpenseFailureState) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  final expenses = switch (state) {
                    ExpenseLoaded(:final expenses) => expenses,
                    ExpenseLoading(:final expenses) => expenses,
                    ExpenseFailureState(:final expenses) => expenses,
                    _ => const <ExpenseClaimUiModel>[],
                  };
                  final summary = switch (state) {
                    ExpenseLoaded(:final summary) => summary,
                    ExpenseLoading(:final summary) => summary,
                    ExpenseFailureState(:final summary) => summary,
                    _ => ExpenseSummaryUi.empty,
                  };
                  final loading =
                      state is ExpenseLoading || state is ExpenseInitial;
                  final refreshing =
                      state is ExpenseLoading && expenses.isNotEmpty;
                  final error = state is ExpenseFailureState
                      ? state.message
                      : null;

                  return RefreshIndicator(
                    color: PortalColors.purple,
                    onRefresh: () =>
                        context.read<ExpenseCubit>().load(keepExisting: true),
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.only(bottom: 32),
                      children: [
                        _ExpenseHeader(dateLabel: summary.dateLabel),
                        _StatCardsRow(summary: summary),
                        _TravelBanner(
                          rateLabel: summary.rateLabel,
                          isRefreshing: refreshing,
                          onRefresh: () {
                            context.read<ExpenseCubit>().load(
                              keepExisting: true,
                            );
                          },
                        ),
                        if (loading && expenses.isEmpty)
                          const ShimmerCardList(itemCount: 4)
                        else if (error != null && expenses.isEmpty)
                          _ExpenseError(
                            message: error,
                            onRetry: () => context.read<ExpenseCubit>().load(),
                          )
                        else
                          _ExpenseRecordsArea(
                            expenses: expenses,
                            totalAmountLabel: summary.totalAmountLabel,
                            isRefreshing: refreshing,
                            onRefresh: () {
                              context.read<ExpenseCubit>().load(
                                keepExisting: true,
                              );
                            },
                          ),
                      ],
                    ),
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

class _ExpenseAppBar extends StatelessWidget {
  const _ExpenseAppBar();

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
          const PortalBackButton(),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Expense',
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
                  'Claims & reimbursements',
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
          const TopNotificationButton(
            asset: 'assets/icons/expense/ic_notification.svg',
          ),
          const SizedBox(width: 14),
          const TopCalendarButton(
            asset: 'assets/icons/expense/ic_notification_cal.svg',
          ),
        ],
      ),
    );
  }
}

class _ExpenseHeader extends StatelessWidget {
  const _ExpenseHeader({required this.dateLabel});

  final String dateLabel;

  @override
  Widget build(BuildContext context) {
    final employeeId =
        AuthSession.currentEmployee?.performanceCode.trim() ?? '';

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 0),
      child: Row(
        children: [
          if (employeeId.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
              decoration: BoxDecoration(
                color: PortalColors.surface,
                borderRadius: BorderRadius.circular(11),
                border: Border.all(color: PortalColors.border),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.person_rounded,
                    size: 13,
                    color: Color(0xFF3B6FE0),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    employeeId,
                    style: portalText(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: PortalColors.heading,
                      height: 14 / 11.5,
                    ),
                  ),
                ],
              ),
            ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
            decoration: BoxDecoration(
              color: PortalColors.surface,
              borderRadius: BorderRadius.circular(11),
              border: Border.all(color: PortalColors.border),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset(
                  'assets/icons/expense/ic_calendar_chip.svg',
                  width: 13,
                  height: 13,
                ),
                const SizedBox(width: 6),
                Text(
                  dateLabel.isEmpty ? '—' : dateLabel,
                  style: portalText(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: PortalColors.heading,
                    height: 14 / 11.5,
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

class _StatCardsRow extends StatelessWidget {
  const _StatCardsRow({required this.summary});

  final ExpenseSummaryUi summary;

  static const double _sidePad = 18;
  static const double _gap = 8;
  static const int _visibleCount = 3;

  @override
  Widget build(BuildContext context) {
    final distance = summary.distanceLabel.replaceAll(' km', '');
    final amount = summary.totalAmountLabel.replaceAll('₹', '');
    final cards = [
      (
        'CLAIMS',
        summary.totalClaims,
        'total records submitted',
        'assets/icons/expense/ic_claims.svg',
      ),
      (
        'DISTANCE',
        distance,
        'km claimed overall',
        'assets/icons/expense/ic_distance.svg',
      ),
      (
        'REIMBURSABLE',
        amount,
        'rupees across all claims',
        'assets/icons/expense/ic_reimbursable.svg',
      ),
      (
        'THIS MONTH',
        summary.monthlyClaims,
        'claims in current month',
        'assets/icons/expense/ic_this_month.svg',
      ),
    ];

    final screenWidth = MediaQuery.sizeOf(context).width;
    final cardWidth =
        (screenWidth - (_sidePad * 2) - (_gap * (_visibleCount - 1))) /
        _visibleCount;

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(_sidePad, 0, _sidePad, 2),
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: [
            for (var i = 0; i < cards.length; i++) ...[
              if (i > 0) const SizedBox(width: _gap),
              SizedBox(
                width: cardWidth,
                child: _LiveStatCard(
                  label: cards[i].$1,
                  value: cards[i].$2,
                  subtitle: cards[i].$3,
                  icon: cards[i].$4,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _LiveStatCard extends StatelessWidget {
  const _LiveStatCard({
    required this.label,
    required this.value,
    required this.subtitle,
    required this.icon,
  });

  final String label;
  final String value;
  final String subtitle;
  final String icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(11, 10, 9, 9),
      decoration: BoxDecoration(
        color: PortalColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: PortalColors.border),
        boxShadow: [
          BoxShadow(
            color: PortalColors.brand.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(icon, width: 22, height: 22),
          const SizedBox(height: 8),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: portalText(
              fontSize: 8.5,
              fontWeight: FontWeight.w700,
              color: PortalColors.muted,
              letterSpacing: 0.35,
              height: 1.2,
            ),
          ),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: portalText(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: PortalColors.green,
              height: 1.2,
            ),
          ),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: portalText(
              fontSize: 9,
              color: PortalColors.muted,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _TravelBanner extends StatelessWidget {
  const _TravelBanner({
    required this.onRefresh,
    required this.rateLabel,
    this.isRefreshing = false,
  });

  final VoidCallback onRefresh;
  final String rateLabel;
  final bool isRefreshing;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(17, 16, 18, 0),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          begin: Alignment(-0.92, -0.4),
          end: Alignment(0.92, 0.4),
          colors: PortalColors.brandGradient,
        ),
      ),
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          Positioned(
            right: -48,
            top: -58,
            child: IgnorePointer(
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Opacity(
                opacity: 0.8,
                child: Text(
                  'TRAVEL REIMBURSEMENT',
                  style: portalText(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 1,
                    height: 12 / 10,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Current travel rate: ${rateLabel.isEmpty ? '₹0 per KM' : rateLabel}',
                style: portalText(
                  fontSize: 16.5,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  height: 20 / 16.5,
                ),
              ),
              const SizedBox(height: 6),
              Opacity(
                opacity: 0.9,
                child: Text(
                  'Stops-based distance is used automatically when you enter visit- wise KM. Keep each stop clear so approvals stay clean.',
                  style: portalText(
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                    height: 16 / 11,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: isRefreshing
                          ? null
                          : () async {
                              final saved = await showRecordExpenseSheet(
                                context,
                              );
                              if (saved == true && context.mounted) {
                                await context.read<ExpenseCubit>().load(
                                  keepExisting: true,
                                );
                              }
                            },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(11),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              'assets/icons/expense/ic_plus.svg',
                              width: 12,
                              height: 12,
                              colorFilter: const ColorFilter.mode(
                                PortalColors.brand,
                                BlendMode.srcIn,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Record Expense',
                              style: portalText(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: PortalColors.brand,
                                height: 14 / 11.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: isRefreshing ? null : onRefresh,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(11),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (isRefreshing)
                              const SizedBox(
                                width: 12,
                                height: 12,
                                child: CircularProgressIndicator(
                                  strokeWidth: 1.8,
                                  color: Colors.white,
                                ),
                              )
                            else
                              SvgPicture.asset(
                                'assets/icons/expense/ic_refresh_banner.svg',
                                width: 12,
                                height: 12,
                              ),
                            const SizedBox(width: 6),
                            Text(
                              isRefreshing ? 'Refreshing' : 'Refresh',
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
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ExpenseError extends StatelessWidget {
  const _ExpenseError({required this.message, required this.onRetry});

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
            style: portalText(fontSize: 13, color: PortalColors.muted),
          ),
          const SizedBox(height: 12),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

class _ExpenseRecordsArea extends StatefulWidget {
  const _ExpenseRecordsArea({
    required this.expenses,
    required this.totalAmountLabel,
    required this.isRefreshing,
    required this.onRefresh,
  });

  final List<ExpenseClaimUiModel> expenses;
  final String totalAmountLabel;
  final bool isRefreshing;
  final VoidCallback onRefresh;

  @override
  State<_ExpenseRecordsArea> createState() => _ExpenseRecordsAreaState();
}

class _ExpenseRecordsAreaState extends State<_ExpenseRecordsArea> {
  static const _statusOptions = [
    'All Statuses',
    'Pending',
    'Approved',
    'Rejected',
  ];

  String _query = '';
  String _status = 'All Statuses';

  List<ExpenseClaimUiModel> get _filtered {
    final q = _query.trim().toLowerCase();
    return widget.expenses.where((c) {
      if (_status != 'All Statuses' &&
          c.status.toLowerCase() != _status.toLowerCase()) {
        return false;
      }
      if (q.isEmpty) return true;
      if (c.purpose.toLowerCase().contains(q)) return true;
      if (c.remark.toLowerCase().contains(q)) return true;
      if (c.status.toLowerCase().contains(q)) return true;
      return c.stops.any((s) => s.outcome.toLowerCase().contains(q));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final records = _filtered;
    final hasFilters =
        _query.trim().isNotEmpty || _status != 'All Statuses';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ExpenseFiltersCard(
          query: _query,
          status: _status,
          statusOptions: _statusOptions,
          shown: records.length,
          total: widget.expenses.length,
          isRefreshing: widget.isRefreshing,
          onQuery: (v) => setState(() => _query = v),
          onStatus: (v) => setState(() => _status = v),
          onRefresh: widget.onRefresh,
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 0),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: PortalColors.brandTint,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.receipt_long_rounded,
                  size: 16,
                  color: PortalColors.brand,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Expense Records',
                      style: portalText(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: PortalColors.heading,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Review travel claims and open any record for details.',
                      style: portalText(
                        fontSize: 11,
                        color: PortalColors.muted,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: PortalColors.greenTint,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  widget.totalAmountLabel,
                  style: portalText(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    color: PortalColors.green,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (records.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: _ExpenseEmptyState(
              filtered: hasFilters || widget.expenses.isNotEmpty,
              onRecord: () async {
                final saved = await showRecordExpenseSheet(context);
                if (saved == true && context.mounted) {
                  await context.read<ExpenseCubit>().load(keepExisting: true);
                }
              },
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Column(
              children: [
                for (var i = 0; i < records.length; i++) ...[
                  if (i > 0) const SizedBox(height: 10),
                  _ExpenseRecordCard(claim: records[i]),
                ],
              ],
            ),
          ),
      ],
    );
  }
}

class _ExpenseFiltersCard extends StatelessWidget {
  const _ExpenseFiltersCard({
    required this.query,
    required this.status,
    required this.statusOptions,
    required this.shown,
    required this.total,
    required this.isRefreshing,
    required this.onQuery,
    required this.onStatus,
    required this.onRefresh,
  });

  final String query;
  final String status;
  final List<String> statusOptions;
  final int shown;
  final int total;
  final bool isRefreshing;
  final ValueChanged<String> onQuery;
  final ValueChanged<String> onStatus;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(18, 14, 18, 0),
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 11),
      decoration: BoxDecoration(
        color: PortalColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: PortalColors.border),
        boxShadow: [
          BoxShadow(
            color: PortalColors.brand.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: PortalColors.brandTint,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.filter_alt_rounded,
                  size: 13,
                  color: PortalColors.brand,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Filters & Actions',
                      style: portalText(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        color: PortalColors.heading,
                      ),
                    ),
                    Text(
                      'Search claims or filter by approval status.',
                      style: portalText(
                        fontSize: 9.5,
                        color: PortalColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: PortalColors.background,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: PortalColors.border),
                ),
                child: Text(
                  '$shown / $total',
                  style: portalText(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: PortalColors.secondaryText,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'SEARCH',
            style: portalText(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: PortalColors.muted,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 36,
                  child: TextField(
                    onChanged: onQuery,
                    style: portalText(
                      fontSize: 11.5,
                      color: PortalColors.heading,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search purpose, outcome, remark...',
                      hintStyle: portalText(
                        fontSize: 11.5,
                        color: PortalColors.muted,
                      ),
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        size: 16,
                        color: PortalColors.muted,
                      ),
                      prefixIconConstraints: const BoxConstraints(
                        minWidth: 36,
                        minHeight: 36,
                      ),
                      filled: true,
                      fillColor: PortalColors.background,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      border: _inputBorder(),
                      enabledBorder: _inputBorder(),
                      focusedBorder: _inputBorder(PortalColors.brand),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: isRefreshing ? null : onRefresh,
                child: Container(
                  height: 36,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: PortalColors.background,
                    borderRadius: BorderRadius.circular(9),
                    border: Border.all(color: PortalColors.border),
                  ),
                  child: Row(
                    children: [
                      if (isRefreshing)
                        const SizedBox(
                          width: 13,
                          height: 13,
                          child: CircularProgressIndicator(strokeWidth: 1.8),
                        )
                      else
                        const Icon(
                          Icons.refresh_rounded,
                          size: 14,
                          color: PortalColors.brand,
                        ),
                      const SizedBox(width: 4),
                      Text(
                        'Refresh',
                        style: portalText(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: PortalColors.brand,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          Text(
            'STATUS',
            style: portalText(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: PortalColors.muted,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 4),
          _StatusDropdown(
            value: status,
            options: statusOptions,
            onChanged: onStatus,
          ),
        ],
      ),
    );
  }

  static OutlineInputBorder _inputBorder([Color? color]) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(9),
      borderSide: BorderSide(color: color ?? PortalColors.border),
    );
  }
}

class _StatusDropdown extends StatelessWidget {
  const _StatusDropdown({
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final String value;
  final List<String> options;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: onChanged,
      offset: const Offset(0, 40),
      color: PortalColors.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 10,
      shadowColor: PortalColors.brand.withValues(alpha: 0.18),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      itemBuilder: (_) => [
        for (final option in options)
          PopupMenuItem<String>(
            value: option,
            height: 38,
            child: Row(
              children: [
                SizedBox(
                  width: 20,
                  child: option == value
                      ? const Icon(
                          Icons.check_rounded,
                          size: 15,
                          color: PortalColors.brand,
                        )
                      : null,
                ),
                const SizedBox(width: 4),
                Text(
                  option,
                  style: portalText(
                    fontSize: 12,
                    fontWeight:
                        option == value ? FontWeight.w700 : FontWeight.w500,
                    color: option == value
                        ? PortalColors.brand
                        : PortalColors.heading,
                  ),
                ),
              ],
            ),
          ),
      ],
      child: Container(
        width: double.infinity,
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: PortalColors.background,
          borderRadius: BorderRadius.circular(9),
          border: Border.all(color: PortalColors.border),
        ),
        child: Row(
          children: [
            Icon(
              Icons.tune_rounded,
              size: 14,
              color: PortalColors.muted.withValues(alpha: 0.95),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                value,
                overflow: TextOverflow.ellipsis,
                style: portalText(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: PortalColors.secondaryText,
                ),
              ),
            ),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 20,
              color: PortalColors.muted,
            ),
          ],
        ),
      ),
    );
  }
}

class _ExpenseEmptyState extends StatelessWidget {
  const _ExpenseEmptyState({
    required this.filtered,
    required this.onRecord,
  });

  final bool filtered;
  final VoidCallback onRecord;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 34, 22, 30),
      decoration: BoxDecoration(
        color: PortalColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: PortalColors.border),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            PortalColors.brandTint.withValues(alpha: 0.45),
            PortalColors.surface,
          ],
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: PortalColors.surface,
              border: Border.all(color: PortalColors.border),
              boxShadow: [
                BoxShadow(
                  color: PortalColors.brand.withValues(alpha: 0.08),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Center(
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: const LinearGradient(
                    colors: PortalColors.brandGradient,
                  ),
                ),
                child: Icon(
                  filtered
                      ? Icons.search_off_rounded
                      : Icons.receipt_long_rounded,
                  size: 20,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            filtered ? 'No matching expenses' : 'No expense records yet',
            textAlign: TextAlign.center,
            style: portalText(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: PortalColors.heading,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            filtered
                ? 'Try another status or clear your search to see more claims.'
                : 'Record your first travel expense to track distance and reimbursements here.',
            textAlign: TextAlign.center,
            style: portalText(
              fontSize: 12,
              color: PortalColors.muted,
              height: 1.45,
            ),
          ),
          if (!filtered) ...[
            const SizedBox(height: 18),
            GestureDetector(
              onTap: onRecord,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: PortalColors.brand,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.add_rounded, size: 16, color: Colors.white),
                    const SizedBox(width: 6),
                    Text(
                      'Record Expense',
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
        ],
      ),
    );
  }
}

class _ExpenseRecordCard extends StatelessWidget {
  const _ExpenseRecordCard({required this.claim});

  final ExpenseClaimUiModel claim;

  Future<void> _onEdit(BuildContext context) async {
    final saved = await showEditExpenseSheet(context, claim: claim);
    if (saved == true && context.mounted) {
      await context.read<ExpenseCubit>().load(keepExisting: true);
    }
  }

  Future<void> _onDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Delete expense?',
          style: portalText(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: PortalColors.heading,
          ),
        ),
        content: Text(
          'This will remove “${claim.purpose}” from your records.',
          style: portalText(fontSize: 13, color: PortalColors.muted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: PortalColors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    try {
      await context.read<ExpenseCubit>().deleteExpense(claim.id);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Expense deleted successfully'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e is ExpenseFailure ? e.message : 'Failed to delete expense.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final outcomes = claim.stops
        .map((s) => s.outcome.trim())
        .where((o) => o.isNotEmpty)
        .join(', ');
    final note = outcomes.isNotEmpty
        ? outcomes
        : claim.remark.trim().isNotEmpty
        ? claim.remark.trim()
        : null;

    return Container(
      decoration: BoxDecoration(
        color: PortalColors.surface,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: PortalColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x061C1B29),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(11, 9, 11, 8),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: PortalColors.brand.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.directions_car_filled_outlined,
                    size: 14,
                    color: PortalColors.brand,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        claim.purpose,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: portalText(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                          color: PortalColors.heading,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today_outlined,
                            size: 10,
                            color: PortalColors.muted,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            claim.dateLabel,
                            style: portalText(
                              fontSize: 10,
                              color: PortalColors.muted,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: claim.statusBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                          color: claim.statusColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        claim.status,
                        style: portalText(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          color: claim.statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1, color: PortalColors.border),
          Padding(
            padding: const EdgeInsets.fromLTRB(11, 9, 11, 9),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _MetaChip(
                        icon: Icons.route_rounded,
                        label: claim.kmLabel,
                        background: const Color(0xFFEAF1FD),
                        foreground: const Color(0xFF3B6FE0),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: _MetaChip(
                        icon: Icons.place_outlined,
                        label: claim.stopsCountLabel,
                        background: PortalColors.purpleTint,
                        foreground: PortalColors.purple,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: PortalColors.greenTint,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        claim.amountLabel,
                        style: portalText(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                          color: PortalColors.green,
                        ),
                      ),
                    ),
                  ],
                ),
                if (note != null) ...[
                  const SizedBox(height: 7),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: PortalColors.background,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      note,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: portalText(
                        fontSize: 10,
                        color: PortalColors.muted,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _ActionBtn(
                        label: 'View',
                        color: PortalColors.purple,
                        tint: PortalColors.purpleTint,
                        iconAsset: 'assets/icons/expense/ic_view.svg',
                        onTap: () =>
                            showExpenseDetailsDialog(context, claim: claim),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: _ActionBtn(
                        label: 'Edit',
                        color: PortalColors.green,
                        tint: PortalColors.greenTint,
                        iconAsset: 'assets/icons/visits/ic_edit.svg',
                        onTap: () => _onEdit(context),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Material(
                      color: PortalColors.redTint,
                      borderRadius: BorderRadius.circular(8),
                      child: InkWell(
                        onTap: () => _onDelete(context),
                        borderRadius: BorderRadius.circular(8),
                        child: SizedBox(
                          width: 34,
                          height: 30,
                          child: Center(
                            child: SvgPicture.asset(
                              'assets/icons/visits/ic_delete.svg',
                              width: 12,
                              height: 12,
                              colorFilter: const ColorFilter.mode(
                                PortalColors.red,
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
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

class _MetaChip extends StatelessWidget {
  const _MetaChip({
    required this.icon,
    required this.label,
    required this.background,
    required this.foreground,
  });

  final IconData icon;
  final String label;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 12, color: foreground),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: portalText(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: foreground,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  const _ActionBtn({
    required this.label,
    required this.color,
    required this.tint,
    required this.iconAsset,
    required this.onTap,
  });

  final String label;
  final Color color;
  final Color tint;
  final String iconAsset;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: tint,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          height: 30,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                iconAsset,
                width: 12,
                height: 12,
                colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: portalText(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
