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
                          _ExpenseRecordsList(
                            expenses: expenses,
                            totalAmountLabel: summary.totalAmountLabel,
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 0),
      child: Align(
        alignment: Alignment.centerRight,
        child: Container(
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

class _ExpenseRecordsList extends StatefulWidget {
  const _ExpenseRecordsList({
    required this.expenses,
    required this.totalAmountLabel,
  });

  final List<ExpenseClaimUiModel> expenses;
  final String totalAmountLabel;

  @override
  State<_ExpenseRecordsList> createState() => _ExpenseRecordsListState();
}

class _ExpenseRecordsListState extends State<_ExpenseRecordsList> {
  String _query = '';

  List<ExpenseClaimUiModel> get _filtered {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return widget.expenses;
    return widget.expenses.where((c) {
      if (c.purpose.toLowerCase().contains(q)) return true;
      if (c.remark.toLowerCase().contains(q)) return true;
      return c.stops.any((s) => s.outcome.toLowerCase().contains(q));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final records = _filtered;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 18, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: PortalColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: PortalColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Expense Records',
                  style: portalText(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: PortalColors.heading,
                    height: 16 / 13.5,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(11, 5, 11, 6),
                decoration: BoxDecoration(
                  color: PortalColors.purpleTint,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  widget.totalAmountLabel,
                  style: portalText(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: PortalColors.purple,
                    height: 13 / 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              'Review submitted travel claims and open any record for full details.',
              style: portalText(
                fontSize: 10.5,
                color: PortalColors.muted,
                height: 13 / 10.5,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Container(
            height: 38,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: PortalColors.background,
              borderRadius: BorderRadius.circular(11),
              border: Border.all(color: PortalColors.border),
            ),
            child: Row(
              children: [
                const Icon(Icons.search, size: 14, color: PortalColors.muted),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    onChanged: (v) => setState(() => _query = v),
                    style: portalText(
                      fontSize: 11.3,
                      color: PortalColors.heading,
                      height: 14 / 11.3,
                    ),
                    decoration: InputDecoration(
                      isDense: true,
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                      hintText: 'Search by purpose, outcome, or remark...',
                      hintStyle: portalText(
                        fontSize: 11.3,
                        color: const Color(0xFF757575),
                        height: 14 / 11.3,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Align(
              alignment: Alignment.centerRight,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: PortalColors.background,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: PortalColors.border),
                ),
                child: Text(
                  '📋 Found ${records.length}',
                  style: portalText(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: PortalColors.secondaryText,
                    height: 13 / 10.5,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          if (records.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: PortalColors.border),
              ),
              child: Text(
                widget.expenses.isEmpty
                    ? 'Record your first travel expense to see it here.'
                    : 'No records match your search.',
                textAlign: TextAlign.center,
                style: portalText(fontSize: 12, color: PortalColors.muted),
              ),
            )
          else
            for (var i = 0; i < records.length; i++) ...[
              if (i > 0) const SizedBox(height: 10),
              _ExpenseRecordCard(claim: records[i]),
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
        ? 'Outcome: $outcomes'
        : claim.remark.trim().isNotEmpty
        ? 'Remark: ${claim.remark.trim()}'
        : null;

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      claim.purpose,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: portalText(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: PortalColors.heading,
                        height: 16 / 13.5,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 11,
                          color: PortalColors.muted,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          claim.dateLabel,
                          style: portalText(
                            fontSize: 10.5,
                            color: PortalColors.muted,
                            height: 13 / 10.5,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: PortalColors.greenTint,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  claim.amountLabel,
                  style: portalText(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: PortalColors.green,
                    height: 17 / 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: [
              _Pill(
                text: '📏 ${claim.kmLabel}',
                background: const Color(0xFFEAF1FD),
                foreground: const Color(0xFF3B6FE0),
              ),
              _Pill(
                text: '⇄ ${claim.stopsCountLabel}',
                background: PortalColors.purpleTint,
                foreground: PortalColors.purple,
              ),
            ],
          ),
          if (note != null) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: PortalColors.background,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                note,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: portalText(
                  fontSize: 11,
                  color: PortalColors.muted,
                  height: 14 / 11,
                ),
              ),
            ),
          ],
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.only(top: 10),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: PortalColors.border)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Material(
                  color: PortalColors.purpleTint,
                  borderRadius: BorderRadius.circular(8),
                  child: InkWell(
                    onTap: () =>
                        showExpenseDetailsDialog(context, claim: claim),
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SvgPicture.asset(
                            'assets/icons/expense/ic_view.svg',
                            width: 13,
                            height: 13,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'View',
                            style: portalText(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: PortalColors.purple,
                              height: 13 / 10.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Material(
                  color: PortalColors.greenTint,
                  borderRadius: BorderRadius.circular(8),
                  child: InkWell(
                    onTap: () => _onEdit(context),
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SvgPicture.asset(
                            'assets/icons/visits/ic_edit.svg',
                            width: 13,
                            height: 13,
                            colorFilter: const ColorFilter.mode(
                              PortalColors.green,
                              BlendMode.srcIn,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            'Edit',
                            style: portalText(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: PortalColors.green,
                              height: 13 / 10.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Material(
                  color: PortalColors.redTint,
                  borderRadius: BorderRadius.circular(8),
                  child: InkWell(
                    onTap: () => _onDelete(context),
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 6,
                      ),
                      child: SvgPicture.asset(
                        'assets/icons/visits/ic_delete.svg',
                        width: 13,
                        height: 13,
                        colorFilter: const ColorFilter.mode(
                          PortalColors.red,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
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

class _Pill extends StatelessWidget {
  const _Pill({
    required this.text,
    required this.background,
    required this.foreground,
  });

  final String text;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: portalText(
          fontSize: 9.5,
          fontWeight: FontWeight.w700,
          color: foreground,
          height: 11 / 9.5,
        ),
      ),
    );
  }
}
