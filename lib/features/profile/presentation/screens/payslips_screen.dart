import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:timelay_health/core/theme/portal_colors.dart';
import 'package:timelay_health/core/theme/portal_text.dart';
import 'package:timelay_health/core/widgets/month_picker.dart';
import 'package:timelay_health/core/widgets/shimmer.dart';
import 'package:timelay_health/features/payslips/presentation/bloc/payslips_cubit.dart';
import 'package:timelay_health/features/payslips/presentation/bloc/payslips_state.dart';
import 'package:timelay_health/features/payslips/presentation/models/payslip_ui_model.dart';
import 'package:timelay_health/features/payslips/presentation/utils/payslip_pdf.dart';
import 'package:timelay_health/features/profile/presentation/widgets/salary_details_sheet.dart';
import 'package:timelay_health/features/holidays/presentation/widgets/top_calendar_button.dart';
import 'package:timelay_health/features/notifications/presentation/widgets/top_notification_button.dart';
import 'package:timelay_health/core/widgets/portal_back_button.dart';
import 'package:timelay_health/core/widgets/portal_safe_area.dart';

class PayslipsScreen extends StatelessWidget {
  const PayslipsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PayslipsCubit()..load(),
      child: const _PayslipsView(),
    );
  }
}

class _PayslipsView extends StatelessWidget {
  const _PayslipsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PortalColors.background,
      body: PortalSafeArea(
        bottom: false,
        child: Column(
          children: [
            const _PayslipsAppBar(),
            Expanded(
              child: BlocBuilder<PayslipsCubit, PayslipsState>(
                builder: (context, state) {
                  final loading =
                      state is PayslipsLoading && state.payslip == null;

                  if (loading) {
                    return const PayslipsShimmer();
                  }

                  final payslip =
                      state.payslip ??
                      PayslipUiModel.emptyFor(state.selectedDate);
                  final showRecord =
                      context.read<PayslipsCubit>().matchesSearch(payslip) &&
                      state.payslip != null &&
                      state.payslip!.metrics.isNotEmpty;

                  return RefreshIndicator(
                    onRefresh: () =>
                        context.read<PayslipsCubit>().load(keepExisting: true),
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.only(bottom: 32),
                      children: [
                        if (state is PayslipsFailureState &&
                            state.payslip == null)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(18, 16, 18, 0),
                            child: Text(
                              state.message,
                              textAlign: TextAlign.center,
                              style: portalText(
                                fontSize: 12,
                                color: PortalColors.muted,
                              ),
                            ),
                          ),
                        _SalaryHeader(dateLabel: payslip.headerDateLabel),
                        _PayslipStatsRow(stats: state.stats),
                        _PayslipFiltersCard(
                          monthLabel: payslip.monthFilterLabel,
                          showingCount: showRecord ? 1 : 0,
                          totalCount: state.payslip == null ? 0 : 1,
                        ),
                        const _RecordsHeader(),
                        if (showRecord)
                          _SalaryRecordCard(payslip: payslip)
                        else if (state.payslip != null)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(18, 24, 18, 0),
                            child: Text(
                              'No records match your search.',
                              textAlign: TextAlign.center,
                              style: portalText(
                                fontSize: 12,
                                color: PortalColors.muted,
                              ),
                            ),
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

class _PayslipsAppBar extends StatelessWidget {
  const _PayslipsAppBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: PortalColors.surface,
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
      child: Row(
        children: [
          const PortalBackButton(),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Payslips',
              style: portalText(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: PortalColors.heading,
                letterSpacing: 0.2,
                height: 1.2,
              ),
            ),
          ),
          const TopNotificationButton(
            asset: 'assets/icons/payslips/ic_notification.svg',
          ),
          const SizedBox(width: 14),
          const TopCalendarButton(
            asset: 'assets/icons/payslips/ic_notification_cal.svg',
          ),
        ],
      ),
    );
  }
}

class _SalaryHeader extends StatelessWidget {
  const _SalaryHeader({required this.dateLabel});

  final String dateLabel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'My Salary',
                  style: portalText(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: PortalColors.heading,
                    height: 1.2,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 13,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: PortalColors.surface,
                  borderRadius: BorderRadius.circular(11),
                  border: Border.all(color: PortalColors.border),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.asset(
                      'assets/icons/payslips/ic_calendar_chip.svg',
                      width: 13,
                      height: 13,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      dateLabel,
                      style: portalText(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: PortalColors.heading,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'View monthly salary summary and download payslips.',
            style: portalText(
              fontSize: 10.5,
              fontWeight: FontWeight.w400,
              color: PortalColors.muted,
              height: 1.25,
            ),
          ),
        ],
      ),
    );
  }
}

class _PayslipStatsRow extends StatelessWidget {
  const _PayslipStatsRow({required this.stats});

  final PayslipStatsUiModel stats;

  @override
  Widget build(BuildContext context) {
    final items = [
      _Stat(
        'Total Records',
        stats.totalRecords,
        'months',
        'assets/icons/payslips/ic_records.svg',
      ),
      _Stat(
        'Total Net Pay',
        stats.totalSalaryLabel,
        'sum',
        'assets/icons/payslips/ic_salary.svg',
      ),
      _Stat(
        'Payslips',
        stats.payslipsCount,
        'available',
        'assets/icons/payslips/ic_payslips.svg',
      ),
      _Stat(
        'Avg Salary',
        stats.avgSalaryLabel,
        'per month',
        'assets/icons/payslips/ic_avg_salary.svg',
      ),
    ];

    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 18),
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

class _Stat {
  const _Stat(this.label, this.value, this.subtitle, this.icon);
  final String label;
  final String value;
  final String subtitle;
  final String icon;
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.item});
  final _Stat item;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 128,
      padding: const EdgeInsets.fromLTRB(13, 13, 10, 12),
      decoration: BoxDecoration(
        color: PortalColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: PortalColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(item.icon, width: 28, height: 28),
          const SizedBox(height: 8),
          Text(
            item.label.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: portalText(
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
              color: PortalColors.muted,
              letterSpacing: 0.4,
              height: 1.15,
            ),
          ),
          Text(
            item.value,
            style: portalText(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: PortalColors.green,
              height: 1.2,
            ),
          ),
          Text(
            item.subtitle,
            style: portalText(
              fontSize: 9.5,
              color: PortalColors.muted,
              height: 1.15,
            ),
          ),
        ],
      ),
    );
  }
}

class _PayslipFiltersCard extends StatefulWidget {
  const _PayslipFiltersCard({
    required this.monthLabel,
    required this.showingCount,
    required this.totalCount,
  });

  final String monthLabel;
  final int showingCount;
  final int totalCount;

  @override
  State<_PayslipFiltersCard> createState() => _PayslipFiltersCardState();
}

class _PayslipFiltersCardState extends State<_PayslipFiltersCard> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _pickMonth() async {
    final cubit = context.read<PayslipsCubit>();
    final picked = await showMonthPicker(
      context,
      initial: cubit.state.selectedDate,
    );
    if (picked == null || !mounted) return;
    await cubit.selectMonth(picked);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(18, 14, 18, 0),
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
              Text(
                'Filters',
                style: portalText(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: PortalColors.heading,
                  height: 1.2,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () =>
                    context.read<PayslipsCubit>().load(keepExisting: true),
                behavior: HitTestBehavior.opaque,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.asset(
                      'assets/icons/payslips/ic_refresh.svg',
                      width: 12,
                      height: 12,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Refresh',
                      style: portalText(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF3B6FE0),
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'SEARCH',
            style: portalText(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: PortalColors.muted,
              letterSpacing: 0.3,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _search,
            onChanged: (v) => context.read<PayslipsCubit>().setSearch(v),
            decoration: InputDecoration(
              hintText: 'Search by month...',
              hintStyle: portalText(
                fontSize: 11.4,
                color: const Color(0xFF757575),
                height: 1.2,
              ),
              prefixIcon: const Icon(
                Icons.search,
                size: 16,
                color: PortalColors.muted,
              ),
              prefixIconConstraints: const BoxConstraints(
                minWidth: 36,
                minHeight: 0,
              ),
              filled: true,
              fillColor: PortalColors.background,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
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
          Text(
            'MONTH',
            style: portalText(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: PortalColors.muted,
              letterSpacing: 0.3,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: _pickMonth,
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                color: PortalColors.background,
                borderRadius: BorderRadius.circular(11),
                border: Border.all(color: PortalColors.border),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.monthLabel,
                      style: portalText(
                        fontSize: 12,
                        color: PortalColors.heading,
                        height: 1.2,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.calendar_month_rounded,
                    size: 18,
                    color: PortalColors.muted,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: Material(
              color: PortalColors.purple,
              borderRadius: BorderRadius.circular(11),
              child: InkWell(
                onTap: () => context.read<PayslipsCubit>().selectCurrentMonth(),
                borderRadius: BorderRadius.circular(11),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  child: Center(
                    child: Text(
                      'Current',
                      style: portalText(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        height: 1.2,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Showing ${widget.showingCount} of ${widget.totalCount} records',
            style: portalText(
              fontSize: 11,
              color: PortalColors.muted,
              height: 1.2,
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

class _RecordsHeader extends StatelessWidget {
  const _RecordsHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Salary Records',
            style: portalText(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: PortalColors.heading,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Month-wise salary and payslip availability.',
            style: portalText(
              fontSize: 10.5,
              color: PortalColors.muted,
              height: 1.25,
            ),
          ),
        ],
      ),
    );
  }
}

class _SalaryRecordCard extends StatelessWidget {
  const _SalaryRecordCard({required this.payslip});

  final PayslipUiModel payslip;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(18, 14, 18, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: PortalColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: PortalColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      payslip.monthLabel,
                      style: portalText(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: PortalColors.heading,
                        height: 1.2,
                      ),
                    ),
                    Text(
                      payslip.daysMeta,
                      style: portalText(
                        fontSize: 8,
                        color: PortalColors.muted,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: payslip.statusBackground,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  payslip.statusLabel,
                  style: portalText(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: payslip.statusColor,
                    height: 1.2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (payslip.metrics.isNotEmpty) ...[
            Row(
              children: [
                for (var i = 0; i < 3 && i < payslip.metrics.length; i++) ...[
                  if (i > 0) const SizedBox(width: 8),
                  Expanded(
                    child: _MetricTile(
                      value: payslip.metrics[i].value,
                      label: payslip.metrics[i].label,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                for (var i = 3; i < 6 && i < payslip.metrics.length; i++) ...[
                  if (i > 3) const SizedBox(width: 8),
                  Expanded(
                    child: _MetricTile(
                      value: payslip.metrics[i].value,
                      label: payslip.metrics[i].label,
                    ),
                  ),
                ],
              ],
            ),
          ],
          const SizedBox(height: 12),
          Container(
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: PortalColors.border)),
            ),
            padding: const EdgeInsets.only(top: 12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        payslip.calculatedLabel,
                        style: portalText(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF3D7AFE),
                          height: 1.2,
                        ),
                      ),
                      Text(
                        '${payslip.salaryLabel}  ·  ${payslip.dailyRateLabel}',
                        style: portalText(
                          fontSize: 10.5,
                          color: PortalColors.muted,
                          height: 1.25,
                        ),
                      ),
                      Text(
                        'Final ${payslip.finalPayLabel}',
                        style: portalText(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: payslip.finalPayLabel == '₹0'
                              ? PortalColors.red
                              : PortalColors.green,
                          height: 1.25,
                        ),
                      ),
                    ],
                  ),
                ),
                _ActionBtn(
                  asset: 'assets/icons/payslips/ic_view.svg',
                  onTap: () =>
                      showSalaryDetailsSheet(context, payslip: payslip),
                ),
                const SizedBox(width: 8),
                _ActionBtn(
                  asset: 'assets/icons/payslips/ic_download.svg',
                  enabled: payslip.canDownload,
                  onTap: payslip.canDownload
                      ? () => downloadOfficialPayslip(context, payslip)
                      : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: PortalColors.background,
        borderRadius: BorderRadius.circular(11),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: portalText(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: PortalColors.heading,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: portalText(
              fontSize: 8.5,
              fontWeight: FontWeight.w700,
              color: PortalColors.muted,
              letterSpacing: 0.3,
              height: 1.15,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  const _ActionBtn({required this.asset, this.onTap, this.enabled = true});
  final String asset;
  final VoidCallback? onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      behavior: HitTestBehavior.opaque,
      child: Opacity(
        opacity: enabled ? 1 : 0.35,
        child: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: PortalColors.purpleTint,
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: SvgPicture.asset(asset, width: 14, height: 14),
        ),
      ),
    );
  }
}
