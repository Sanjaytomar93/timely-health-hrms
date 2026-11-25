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
import 'package:timelay_health/features/payslips/presentation/utils/payslip_download.dart';
import 'package:timelay_health/features/profile/presentation/widgets/salary_details_sheet.dart';
import 'package:timelay_health/features/holidays/presentation/widgets/top_calendar_button.dart';
import 'package:timelay_health/features/notifications/presentation/widgets/top_notification_button.dart';
import 'package:timelay_health/core/widgets/portal_safe_area.dart';
import 'package:timelay_health/features/dashboard/presentation/screens/employee_home_shell.dart';
import 'package:timelay_health/features/dashboard/presentation/widgets/employee_bottom_nav.dart';
import 'package:timelay_health/features/dashboard/presentation/widgets/home_side_drawer.dart';

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

class _PayslipsView extends StatefulWidget {
  const _PayslipsView();

  @override
  State<_PayslipsView> createState() => _PayslipsViewState();
}

class _PayslipsViewState extends State<_PayslipsView> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

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
            _PayslipsAppBar(
              onMenuTap: () => _scaffoldKey.currentState?.openDrawer(),
            ),
            Expanded(
              child: BlocBuilder<PayslipsCubit, PayslipsState>(
                builder: (context, state) {
                  final loading =
                      state is PayslipsLoading && state.payslip == null;
                  final refreshing =
                      state is PayslipsLoading && state.payslip != null;

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
                          isRefreshing: refreshing,
                        ),
                        const _RecordsHeader(),
                        if (refreshing)
                          const PayslipRecordsShimmer()
                        else if (showRecord)
                          _SalaryRecordCard(payslip: payslip),
                        const _NoMoreRecordsCard(),
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

class _PayslipsAppBar extends StatelessWidget {
  const _PayslipsAppBar({required this.onMenuTap});

  final VoidCallback onMenuTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: PortalColors.surface,
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
                  'Payslips',
                  style: portalText(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: PortalColors.heading,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Monthly salary summary',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: portalText(
                    fontSize: 11,
                    color: PortalColors.muted,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const TopNotificationButton(
            asset: 'assets/icons/payslips/ic_notification.svg',
          ),
          const SizedBox(width: 12),
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
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: PortalColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: PortalColors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
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

    const hPad = 18.0;
    const gap = 10.0;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final cardWidth = (screenWidth - (hPad * 2) - (gap * 2)) / 3;

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: hPad),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < items.length; i++) ...[
              if (i > 0) const SizedBox(width: gap),
              _StatCard(item: items[i], width: cardWidth),
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
  const _StatCard({required this.item, required this.width});
  final _Stat item;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.fromLTRB(13, 13, 10, 12),
      decoration: BoxDecoration(
        color: PortalColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: PortalColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
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
    this.isRefreshing = false,
  });

  final String monthLabel;
  final int showingCount;
  final int totalCount;
  final bool isRefreshing;

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
      margin: const EdgeInsets.fromLTRB(18, 10, 18, 0),
      padding: const EdgeInsets.fromLTRB(17, 17, 17, 16),
      decoration: BoxDecoration(
        color: PortalColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: PortalColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
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
                onTap: widget.isRefreshing
                    ? null
                    : () => context
                        .read<PayslipsCubit>()
                        .load(keepExisting: true),
                behavior: HitTestBehavior.opaque,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.isRefreshing)
                      const SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(
                          strokeWidth: 1.8,
                          color: Color(0xFF3B6FE0),
                        ),
                      )
                    else
                      SvgPicture.asset(
                        'assets/icons/payslips/ic_refresh.svg',
                        width: 12,
                        height: 12,
                      ),
                    const SizedBox(width: 4),
                    Text(
                      widget.isRefreshing ? 'Refreshing' : 'Refresh',
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

class _NoMoreRecordsCard extends StatelessWidget {
  const _NoMoreRecordsCard();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 0),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: PortalColors.brandTint,
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              width: 110,
              child: CustomPaint(painter: _WavePainter()),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 90, 14),
              child: Row(
                children: [
                  const Icon(
                    Icons.trending_up_rounded,
                    size: 24,
                    color: PortalColors.brand,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'No more records',
                          style: portalText(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                            color: PortalColors.brand,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Your salary records will appear here',
                          style: portalText(
                            fontSize: 11,
                            color: PortalColors.brandLight,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final soft = Paint()
      ..color = PortalColors.brand.withValues(alpha: 0.08);
    final mid = Paint()
      ..color = PortalColors.brand.withValues(alpha: 0.12);

    final path1 = Path()
      ..moveTo(size.width * 0.35, 0)
      ..quadraticBezierTo(
        size.width * 0.15,
        size.height * 0.35,
        size.width * 0.45,
        size.height * 0.55,
      )
      ..quadraticBezierTo(
        size.width * 0.75,
        size.height * 0.78,
        size.width * 0.4,
        size.height,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(size.width, 0)
      ..close();

    final path2 = Path()
      ..moveTo(size.width * 0.55, 0)
      ..quadraticBezierTo(
        size.width * 0.35,
        size.height * 0.4,
        size.width * 0.62,
        size.height * 0.62,
      )
      ..quadraticBezierTo(
        size.width * 0.9,
        size.height * 0.82,
        size.width * 0.55,
        size.height,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(path1, soft);
    canvas.drawPath(path2, mid);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _RecordsHeader extends StatelessWidget {
  const _RecordsHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
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
              size: 18,
              color: PortalColors.brand,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Salary Records',
                  style: portalText(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: PortalColors.heading,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Month-wise salary and payslip availability.',
                  style: portalText(
                    fontSize: 11,
                    color: PortalColors.muted,
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

class _SalaryRecordCard extends StatelessWidget {
  const _SalaryRecordCard({required this.payslip});

  final PayslipUiModel payslip;

  String get _calendarDays {
    final raw = payslip.daysMeta.split('|').first.trim();
    if (raw.toLowerCase().endsWith('days')) {
      return raw.replaceFirst(
        RegExp(r'\s*days$', caseSensitive: false),
        ' calendar days',
      );
    }
    return raw;
  }

  String get _weekOffLine {
    final parts = payslip.daysMeta.split('|');
    if (parts.length > 1) {
      final wo = parts[1].trim().replaceFirst(RegExp(r'^WO:\s*'), '');
      return 'Weekly Off (WO): $wo';
    }
    return 'Weekly Off (WO): ${payslip.weekOffLabel}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(18, 12, 18, 0),
      decoration: BoxDecoration(
        color: PortalColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: PortalColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            color: PortalColors.brand,
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        payslip.monthLabel,
                        style: portalText(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        _calendarDays,
                        style: portalText(
                          fontSize: 11,
                          color: Colors.white.withValues(alpha: 0.75),
                          height: 1.25,
                        ),
                      ),
                      Text(
                        _weekOffLine,
                        style: portalText(
                          fontSize: 11,
                          color: Colors.white.withValues(alpha: 0.75),
                          height: 1.25,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: _StatusChip(
                      label: payslip.statusLabel,
                      color: payslip.statusColor,
                      background: payslip.statusBackground,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (payslip.metrics.isNotEmpty) ...[
                  Row(
                    children: [
                      for (var i = 0;
                          i < 3 && i < payslip.metrics.length;
                          i++) ...[
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
                      for (var i = 3;
                          i < 6 && i < payslip.metrics.length;
                          i++) ...[
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
                    border: Border(
                      top: BorderSide(color: PortalColors.border),
                    ),
                  ),
                  padding: const EdgeInsets.only(top: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'Net Payout: ',
                                    style: portalText(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: PortalColors.heading,
                                      height: 1.2,
                                    ),
                                  ),
                                  TextSpan(
                                    text: payslip.finalPayLabel,
                                    style: portalText(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      color: PortalColors.green,
                                      height: 1.2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              'Gross: ${payslip.salaryLabel}  ·  ${payslip.dailyRateLabel}',
                              style: portalText(
                                fontSize: 10.5,
                                color: PortalColors.muted,
                                height: 1.25,
                              ),
                            ),
                            Text(
                              'Final Calculated: ${payslip.calculatedLabel}',
                              style: portalText(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF3D7AFE),
                                height: 1.25,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _ActionBtn(
                        asset: 'assets/icons/payslips/ic_view.svg',
                        onTap: () => showSalaryDetailsSheet(
                          context,
                          payslip: payslip,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _ActionBtn(
                        asset: 'assets/icons/payslips/ic_download.svg',
                        filled: payslip.canDownload,
                        enabled: payslip.canDownload,
                        onTap: payslip.canDownload
                            ? () =>
                                downloadOfficialPayslip(context, payslip)
                            : null,
                      ),
                    ],
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

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.label,
    required this.color,
    required this.background,
  });

  final String label;
  final Color color;
  final Color background;

  bool get _isLive => label.toLowerCase().contains('last day');

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.28)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _isLive ? Icons.schedule_rounded : Icons.check_circle_rounded,
            size: 13,
            color: color,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: portalText(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: color,
              height: 1.2,
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

  IconData get _icon {
    final key = label.trim().toLowerCase();
    if (key.contains('present')) return Icons.check_circle_outline_rounded;
    if (key.contains('working')) return Icons.work_outline_rounded;
    if (key.contains('half')) return Icons.access_time_rounded;
    if (key.contains('earned') || key.contains('wo')) {
      return Icons.event_busy_rounded;
    }
    if (key.contains('leave')) return Icons.beach_access_rounded;
    if (key.contains('comp')) return Icons.swap_horiz_rounded;
    return Icons.info_outline_rounded;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: PortalColors.brandTint,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon, size: 18, color: PortalColors.brand),
          const SizedBox(height: 6),
          Text(
            value,
            style: portalText(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: PortalColors.heading,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: portalText(
              fontSize: 9.5,
              fontWeight: FontWeight.w600,
              color: PortalColors.brandLight,
              height: 1.15,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  const _ActionBtn({
    required this.asset,
    this.onTap,
    this.enabled = true,
    this.filled = false,
  });
  final String asset;
  final VoidCallback? onTap;
  final bool enabled;
  final bool filled;

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
            color: filled ? PortalColors.brand : PortalColors.purpleTint,
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: SvgPicture.asset(
            asset,
            width: 14,
            height: 14,
            colorFilter: filled
                ? const ColorFilter.mode(Colors.white, BlendMode.srcIn)
                : null,
          ),
        ),
      ),
    );
  }
}
