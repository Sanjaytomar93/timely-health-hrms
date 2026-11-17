import 'package:flutter/material.dart';
import 'package:timelay_health/core/theme/portal_text.dart';
import 'package:timelay_health/core/widgets/portal_safe_area.dart';
import 'package:timelay_health/features/op/dashboard/presentation/models/op_dashboard_ui.dart';
import 'package:timelay_health/features/op/dashboard/presentation/screens/op_appointment_slots_screen.dart';
import 'package:timelay_health/features/op/dashboard/presentation/screens/op_register_screen.dart';
import 'package:timelay_health/features/op/dashboard/presentation/theme/op_colors.dart';
import 'package:timelay_health/features/op/dashboard/presentation/widgets/op_dashboard_analytics.dart';
import 'package:timelay_health/features/op/dashboard/presentation/widgets/op_dashboard_sections.dart';

class OpDashboardScreen extends StatefulWidget {
  const OpDashboardScreen({
    super.key,
    this.onOpenTab,
    this.onMenuTap,
  });

  final ValueChanged<int>? onOpenTab;
  final VoidCallback? onMenuTap;

  @override
  State<OpDashboardScreen> createState() => _OpDashboardScreenState();
}

class _OpDashboardScreenState extends State<OpDashboardScreen> {
  final _search = TextEditingController();
  late String _period;

  @override
  void initState() {
    super.initState();
    _period = OpDashboardUi.demo.selectedPeriod;
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _openRegister() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (ctx) => Scaffold(
          backgroundColor: const Color(0xFFF6F8FC),
          body: PortalSafeArea(
            bottom: false,
            statusBarColor: Colors.white,
            child: OpRegisterScreen(
              onMenuTap: () => Navigator.of(ctx).pop(),
            ),
          ),
        ),
      ),
    );
  }

  void _openSlots() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (ctx) => Scaffold(
          backgroundColor: OpColors.background,
          body: PortalSafeArea(
            bottom: false,
            statusBarColor: OpColors.primary,
            child: OpAppointmentSlotsScreen(
              onMenuTap: () => Navigator.of(ctx).pop(),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = OpDashboardUi.demo;

    return ColoredBox(
      color: const Color(0xFFF6F8FC),
      child: Column(
        children: [
          OpStickyHeader(onMenuTap: widget.onMenuTap),
          Expanded(
            child: RefreshIndicator(
              color: OpColors.primary,
              onRefresh: () async {},
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 28),
                children: [
                  OpSearchFiltersBar(
                    searchController: _search,
                    filters: data.periodFilters,
                    selectedPeriod: _period,
                    onPeriodSelected: (v) => setState(() => _period = v),
                  ),
                  const SizedBox(height: 14),
                  OpRegisterBanner(onTap: _openRegister),
                  const SizedBox(height: 14),
                  OpQuickActionsRow(
                    actions: data.quickActions,
                    onTap: (action) {
                      if (action.label == 'Slots') {
                        _openSlots();
                        return;
                      }
                      final tab = action.tabIndex;
                      if (tab != null) widget.onOpenTab?.call(tab);
                    },
                  ),
                  const SizedBox(height: 14),
                  OpTotalCollectedCard(data: data.collected),
                  const SizedBox(height: 14),
                  OpMetricsGrid(
                    metrics: data.metrics,
                    dueInvoices: data.dueInvoices,
                  ),
                  const SizedBox(height: 14),
                  OpRevenueBreakdownHeader(
                    patientsLabel: '${data.metrics.first.value} patients',
                    channels: data.revenueChannels,
                    onPatientsTap: () => widget.onOpenTab?.call(1),
                  ),
                  const SizedBox(height: 14),
                  OpPaymentStatusCard(slices: data.paymentStatus),
                  const SizedBox(height: 14),
                  OpPaymentModeCard(slices: data.paymentModes),
                  const SizedBox(height: 14),
                  OpGenderCard(
                    slices: data.gender,
                    total: data.genderTotal,
                  ),
                  const SizedBox(height: 14),
                  OpTrendWithFooterCard(
                    trend: data.trend,
                    footer: data.fyFooter,
                    fyLabel: data.fyLabel,
                    onFyTap: () => _showFySheet(context, data.fyLabel),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showFySheet(BuildContext context, String current) {
    const years = ['FY 2025-26', 'FY 2024-25', 'FY 2023-24'];
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: OpColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final y in years)
                  ListTile(
                    title: Text(
                      y,
                      style: portalText(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: OpColors.heading,
                      ),
                    ),
                    trailing: y == current
                        ? const Icon(
                            Icons.check_rounded,
                            color: OpColors.primary,
                          )
                        : null,
                    onTap: () => Navigator.pop(context),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
