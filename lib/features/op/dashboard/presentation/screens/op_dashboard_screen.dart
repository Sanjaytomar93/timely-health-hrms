import 'package:flutter/material.dart';
import 'package:timelay_health/core/theme/portal_text.dart';
import 'package:timelay_health/core/widgets/portal_safe_area.dart';
import 'package:timelay_health/features/op/dashboard/presentation/models/op_dashboard_ui.dart';
import 'package:timelay_health/features/op/dashboard/presentation/screens/op_register_screen.dart';
import 'package:timelay_health/features/op/dashboard/presentation/theme/op_colors.dart';
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

  @override
  Widget build(BuildContext context) {
    final data = OpDashboardUi.demo;

    return ColoredBox(
      color: OpColors.background,
      child: RefreshIndicator(
        color: OpColors.primary,
        onRefresh: () async {},
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 28),
          children: [
            OpHeroHeader(
              greeting: data.greeting,
              fyLabel: data.fyLabel,
              onMenuTap: widget.onMenuTap,
              onFyTap: () => _showFySheet(context, data.fyLabel),
            ),
            OpSearchBar(controller: _search),
            OpPeriodFilters(
              filters: data.periodFilters,
              selected: _period,
              onSelected: (v) => setState(() => _period = v),
              onRegister: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (ctx) => Scaffold(
                      backgroundColor: OpColors.background,
                      body: PortalSafeArea(
                        bottom: false,
                        statusBarColor: OpColors.primary,
                        child: OpRegisterScreen(
                          onMenuTap: () => Navigator.of(ctx).pop(),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            OpQuickActionsRow(
              actions: data.quickActions,
              onTap: (action) {
                final tab = action.tabIndex;
                if (tab != null) widget.onOpenTab?.call(tab);
              },
            ),
            OpMetricsGrid(metrics: data.metrics),
            OpRevenueBreakdownHeader(
              patientsLabel: '${data.genderTotal} patients',
              channels: data.revenueChannels,
              onPatientsTap: () => widget.onOpenTab?.call(1),
            ),
            OpRevenueTrendCard(
              trend: data.trend,
              fyLabel: data.fyLabel,
              onFyTap: () => _showFySheet(context, data.fyLabel),
            ),
            OpSummaryCard(rows: data.summaryRows),
            OpPaymentStatusCard(slices: data.paymentStatus),
            OpPaymentModeCard(slices: data.paymentModes),
            OpGenderCard(
              slices: data.gender,
              total: data.genderTotal,
            ),
            OpFinancialYearTrendCard(
              trend: data.fyTrend,
              footer: data.fyFooter,
              fyLabel: data.fyLabel,
              onFyTap: () => _showFySheet(context, data.fyLabel),
            ),
          ],
        ),
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
                        ? const Icon(Icons.check_rounded, color: OpColors.primary)
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
