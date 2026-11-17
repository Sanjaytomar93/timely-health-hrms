import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:timelay_health/core/theme/portal_text.dart';
import 'package:timelay_health/core/widgets/portal_safe_area.dart';
import 'package:timelay_health/features/op/dashboard/presentation/models/op_walkin_ui.dart';
import 'package:timelay_health/features/op/dashboard/presentation/screens/op_register_screen.dart';
import 'package:timelay_health/features/op/dashboard/presentation/theme/op_colors.dart';
import 'package:timelay_health/features/op/dashboard/presentation/models/op_dashboard_ui.dart';
import 'package:timelay_health/features/op/dashboard/presentation/widgets/op_amount_items_sheet.dart';
import 'package:timelay_health/features/op/dashboard/presentation/widgets/op_patient_actions_sheet.dart';
import 'package:timelay_health/features/op/dashboard/presentation/widgets/op_dashboard_sections.dart';
import 'package:timelay_health/features/op/dashboard/presentation/widgets/op_vitals_sheet.dart';

class OpWalkinScreen extends StatefulWidget {
  const OpWalkinScreen({super.key, this.onMenuTap});

  final VoidCallback? onMenuTap;

  @override
  State<OpWalkinScreen> createState() => _OpWalkinScreenState();
}

class _OpWalkinScreenState extends State<OpWalkinScreen> {
  final _search = TextEditingController();
  late String _period;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _period = OpWalkinUi.demo.selectedPeriod;
    _search.addListener(() => setState(() => _query = _search.text.trim()));
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
            child: OpRegisterScreen(onMenuTap: () => Navigator.of(ctx).pop()),
          ),
        ),
      ),
    );
  }

  List<OpWalkinPatientUi> _filtered(OpWalkinUi data) {
    if (_query.isEmpty) return data.patients;
    final q = _query.toLowerCase();
    return data.patients
        .where(
          (p) =>
              p.name.toLowerCase().contains(q) ||
              p.pid.toLowerCase().contains(q) ||
              p.phone.contains(q) ||
              p.doctor.toLowerCase().contains(q),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final data = OpWalkinUi.demo;
    final patients = _filtered(data);

    return ColoredBox(
      color: const Color(0xFFF6F8FC),
      child: Column(
        children: [
          _WalkinTopBar(onMenuTap: widget.onMenuTap),
          Expanded(
            child: RefreshIndicator(
              color: OpColors.primary,
              onRefresh: () async {},
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 14),
                        _WalkinSearchFiltersBar(
                          controller: _search,
                          filters: data.periodFilters,
                          selected: _period,
                          onSelected: (value) => setState(() => _period = value),
                        ),
                        const SizedBox(height: 14),
                        _RevenueSummary(patients: patients),
                        const SizedBox(height: 16),
                        _WalkinStatsGrid(metrics: data.metrics),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(14, 18, 14, 8),
                          child: Row(
                            children: [
                              Container(
                                width: 4,
                                height: 18,
                                decoration: BoxDecoration(
                                  color: OpColors.primary,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'PATIENT QUEUE',
                                style: portalText(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: OpColors.heading,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: OpColors.primaryTint,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '${patients.length} Active',
                                  style: portalText(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: OpColors.primary,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              _AddPatientButton(onTap: _openRegister),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (patients.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Text(
                          'No walkin patients found',
                          style: portalText(
                            fontSize: 14,
                            color: OpColors.muted,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(14, 0, 14, 28),
                      sliver: SliverList.separated(
                        itemCount: patients.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (context, i) =>
                            _WalkinPatientCard(patient: patients[i]),
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


class _WalkinTopBar extends StatelessWidget {
  const _WalkinTopBar({this.onMenuTap});
  final VoidCallback? onMenuTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
        boxShadow: [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onMenuTap,
            child: Container(
              width: 34,
              height: 34,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(11),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
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
              children: [
                Text(
                  'OP Management',
                  style: portalText(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F172A),
                    height: 1.15,
                  ),
                ),
                Text(
                  'City Health Care Clinic',
                  style: portalText(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),
          _HeaderIconBox(icon: Icons.notifications_none_rounded, dot: true),
        ],
      ),
    );
  }
}


class _WalkinSearchFiltersBar extends StatelessWidget {
  const _WalkinSearchFiltersBar({
    required this.controller,
    required this.filters,
    required this.selected,
    required this.onSelected,
  });

  final TextEditingController controller;
  final List<String> filters;
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                const Icon(
                  Icons.search_rounded,
                  size: 16,
                  color: Color(0xFF94A3B8),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: controller,
                    style: portalText(
                      fontSize: 12,
                      color: OpColors.heading,
                    ),
                    textAlignVertical: TextAlignVertical.center,
                    decoration: InputDecoration(
                      hintText: 'Search Name, Phone, PID...',
                      hintStyle: portalText(
                        fontSize: 12,
                        color: const Color(0xFF94A3B8),
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(
                  Icons.tune_rounded,
                  size: 18,
                  color: Color(0xFF94A3B8),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          OpPeriodFiltersRow(
            filters: filters,
            selected: selected,
            onSelected: onSelected,
          ),
        ],
      ),
    );
  }
}

class _HeaderIconBox extends StatelessWidget {
  const _HeaderIconBox({required this.icon, this.dot = false});
  final IconData icon;
  final bool dot;

  @override
  Widget build(BuildContext context) => Stack(
    clipBehavior: Clip.none,
    children: [
      Container(
        width: 34,
        height: 34,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(11),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Icon(icon, size: 17, color: const Color(0xFF64748B)),
      ),
      if (dot)
        Positioned(
          right: 7,
          top: 7,
          child: Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: const Color(0xFFF43F5E),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 1.2),
            ),
          ),
        ),
    ],
  );
}


class _RevenueSummary extends StatelessWidget {
  const _RevenueSummary({required this.patients});

  final List<OpWalkinPatientUi> patients;

  int _amount(String value) =>
      int.tryParse(value.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

  @override
  Widget build(BuildContext context) {
    final clinic = patients.fold(0, (sum, p) => sum + _amount(p.clinic));
    final lab = patients.fold(0, (sum, p) => sum + _amount(p.lab));
    final pharmacy = patients.fold(0, (sum, p) => sum + _amount(p.pharmacy));
    final total = clinic + lab + pharmacy;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1A1635), OpColors.primary, Color(0xFF4A3C7E)],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: OpColors.primary.withValues(alpha: 0.28),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.account_balance_wallet_rounded,
                      color: Color(0xFFC7BEF8),
                      size: 15,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'REVENUE BREAKDOWN',
                      style: portalText(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFFC7BEF8),
                        letterSpacing: 0.6,
                      ),
                    ),
                    const Spacer(),
                    _RevenuePill(text: '${patients.length} patients'),
                    const SizedBox(width: 6),
                    _RevenuePill(text: '✓ Paid', green: true),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'TOTAL COLLECTED',
                          style: portalText(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFFAFA5EC),
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '₹$total',
                          style: portalText(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 12),
                    Container(
                      width: 1,
                      height: 36,
                      color: const Color(0x33FFFFFF),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Row(
                        children: [
                          _RevenuePartSmall(label: 'Clinic', value: '₹$clinic'),
                          const SizedBox(width: 6),
                          _RevenuePartSmall(label: 'Lab', value: '₹$lab'),
                          const SizedBox(width: 6),
                          _RevenuePartSmall(label: 'Pharmacy', value: '₹$pharmacy'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Material(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(10),
                  child: InkWell(
                    onTap: () {},
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      height: 32,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFBBF7D0)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.download_rounded, color: Color(0xFF047857), size: 13),
                          const SizedBox(width: 5),
                          Text(
                            'Export CSV',
                            style: portalText(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF047857),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  child: InkWell(
                    onTap: () {},
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      height: 32,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.history_toggle_off_rounded, color: Color(0xFFF97316), size: 13),
                          const SizedBox(width: 5),
                          Text(
                            'Inactive Patients',
                            style: portalText(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF334155)),
                          ),
                        ],
                      ),
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

class _RevenuePill extends StatelessWidget {
  const _RevenuePill({required this.text, this.green = false});
  final String text;
  final bool green;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
    decoration: BoxDecoration(
      color: green ? const Color(0x3322C55E) : const Color(0x26FFFFFF),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: green ? const Color(0x6652E398) : const Color(0x33FFFFFF),
      ),
    ),
    child: Text(
      text,
      style: portalText(
        fontSize: 10,
        fontWeight: FontWeight.w800,
        color: green ? const Color(0xFF86EFAC) : Colors.white,
      ),
    ),
  );
}

class _RevenuePartSmall extends StatelessWidget {
  const _RevenuePartSmall({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0x1AFFFFFF),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0x1FFFFFFF)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: portalText(fontSize: 9, color: const Color(0xFFD5D0F7)),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: portalText(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ],
      ),
    ),
  );
}


class _AddPatientButton extends StatelessWidget {
  const _AddPatientButton({required this.onTap});
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Material(
    color: OpColors.primary,
    borderRadius: BorderRadius.circular(12),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.add_rounded, color: Colors.white, size: 16),
            const SizedBox(width: 3),
            Text(
              'Add Patient',
              style: portalText(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}


class _WalkinStatsGrid extends StatelessWidget {
  const _WalkinStatsGrid({required this.metrics});

  final List<OpMetricUi> metrics;

  @override
  Widget build(BuildContext context) {
    if (metrics.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 0, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 14, bottom: 7),
            child: Row(
              children: [
                const Icon(
                  Icons.trending_up_rounded,
                  size: 15,
                  color: OpColors.primary,
                ),
                const SizedBox(width: 6),
                Text(
                  'OVERVIEW STATS',
                  style: portalText(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                    color: const Color(0xFF64748B),
                  ),
                ),
                const Spacer(),
                const Icon(Icons.circle, size: 7, color: Color(0xFF34D399)),
                const SizedBox(width: 4),
                Text(
                  'Realtime',
                  style: portalText(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: OpColors.primary,
                  ),
                ),
                const SizedBox(width: 14),
              ],
            ),
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              const gap = 7.0;
              final cardWidth = (constraints.maxWidth - (gap * 2) - 14) / 3;
              return SizedBox(
                height: 105,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.only(right: 14, bottom: 2),
                  itemCount: metrics.length,
                  separatorBuilder: (_, _) => const SizedBox(width: gap),
                  itemBuilder: (_, i) => SizedBox(
                    width: cardWidth,
                    child: _CompactStatCard(data: metrics[i]),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _CompactStatCard extends StatelessWidget {
  const _CompactStatCard({required this.data});

  final OpMetricUi data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: OpColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: OpColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  data.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: portalText(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF475569),
                  ),
                ),
              ),
              Container(
                width: 23,
                height: 23,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: data.accent.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(data.icon, size: 13, color: data.accent),
              ),
            ],
          ),
          const SizedBox(height: 7),
          Text(
            data.value,
            style: portalText(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            data.subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: portalText(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF94A3B8),
            ),
          ),
        ],
      ),
    );
  }
}


class _WalkinPatientCard extends StatelessWidget {
  const _WalkinPatientCard({required this.patient});

  final OpWalkinPatientUi patient;

  void _copyPhone(BuildContext context) {
    Clipboard.setData(ClipboardData(text: patient.phone));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Phone copied',
          style: portalText(
            fontSize: 13,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = patient;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: OpColors.border),
        boxShadow: [
          BoxShadow(
            color: OpColors.primary.withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                p.pid,
                style: portalText(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: OpColors.heading,
                ),
              ),
              const Spacer(),
              const Icon(Icons.access_time_rounded, size: 12, color: Color(0xFF94A3B8)),
              const SizedBox(width: 3),
              Text(
                '${p.createdDate} • ${p.createdTime}',
                style: portalText(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF94A3B8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: OpColors.primaryTint,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  p.initial,
                  style: portalText(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: OpColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: portalText(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: OpColors.heading,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${p.age} yrs · ${p.gender}',
                      style: portalText(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: OpColors.muted,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.phone_rounded,
                          size: 13,
                          color: OpColors.muted,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          p.phone,
                          style: portalText(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: OpColors.secondary,
                          ),
                        ),
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: () => _copyPhone(context),
                          child: const Icon(
                            Icons.copy_rounded,
                            size: 13,
                            color: OpColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _Chip(
                    text: p.rType,
                    color: p.rType.startsWith('N') ? OpColors.primary : OpColors.orange,
                  ),
                  const SizedBox(height: 5),
                  _StatusChip(text: p.status),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          const Divider(height: 1, color: Color(0xFFEEF0F7)),
          const SizedBox(height: 10),

          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.medical_services_outlined,
                  size: 14,
                  color: OpColors.muted,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CONSULTING DOCTOR',
                      style: portalText(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: OpColors.muted,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      p.doctor.isEmpty || p.doctor == 'N/A'
                          ? 'N/A (Direct Lab)'
                          : p.doctor,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: portalText(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: OpColors.heading,
                      ),
                    ),
                  ],
                ),
              ),
              if (p.visitDate.isNotEmpty && p.visitDate != 'N/A')
                Text(
                  p.visitDate,
                  style: portalText(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: OpColors.muted,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F6FC),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SERVICE BREAKDOWN',
                  style: portalText(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: OpColors.muted,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _ServiceChip(
                      prefix: 'Clinic',
                      value: p.clinic,
                      color: OpColors.blue,
                      onAdd: () => showOpAmountItemsSheet(
                        context: context,
                        patient: p,
                        kind: OpAmountItemKind.clinic,
                      ),
                    ),
                    const SizedBox(width: 6),
                    _ServiceChip(
                      prefix: 'Lab',
                      value: p.lab,
                      color: OpColors.purple,
                      onAdd: () => showOpAmountItemsSheet(
                        context: context,
                        patient: p,
                        kind: OpAmountItemKind.lab,
                      ),
                    ),
                    const SizedBox(width: 6),
                    _ServiceChip(
                      prefix: 'Pharmacy',
                      value: p.pharmacy,
                      color: OpColors.green,
                      onAdd: () => showOpAmountItemsSheet(
                        context: context,
                        patient: p,
                        kind: OpAmountItemKind.pharmacy,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Divider(height: 1, color: Color(0xFFE8E5F5)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _BillCell(
                        label: 'TOTAL BILL',
                        value: p.total,
                        valueColor: OpColors.heading,
                      ),
                    ),
                    _VerticalDivider(),
                    Expanded(
                      child: _BillCell(
                        label: 'DISCOUNT',
                        value: p.discount,
                        valueColor: p.discount == '—'
                            ? OpColors.muted
                            : OpColors.purple,
                      ),
                    ),
                    _VerticalDivider(),
                    Expanded(
                      child: _BillCell(
                        label: 'DUE AMOUNT',
                        value: p.due,
                        valueColor: p.due == '₹0'
                            ? OpColors.muted
                            : OpColors.orange,
                      ),
                    ),
                    _VerticalDivider(),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'PAID AMOUNT',
                            style: portalText(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: OpColors.muted,
                              letterSpacing: 0.4,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            p.paid,
                            style: portalText(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: OpColors.green,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: OpColors.green.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              p.payType,
                              style: portalText(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: OpColors.green,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          Row(
            children: [
              const Icon(
                Icons.bookmark_outline_rounded,
                size: 13,
                color: OpColors.muted,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  'Booked: ${p.bookedBy} (${p.bookedByCode})',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: portalText(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: OpColors.muted,
                  ),
                ),
              ),
              _ActionIcon(
                icon: Icons.chat_bubble_outline_rounded,
                color: const Color(0xFF64748B),
                onTap: () {},
              ),
              const SizedBox(width: 4),
              _ActionIcon(
                icon: Icons.favorite_border_rounded,
                color: const Color(0xFFEC4899),
                onTap: () => showOpVitalsSheet(context: context, patient: p),
              ),
              const SizedBox(width: 4),
              _ActionIcon(
                icon: Icons.more_vert_rounded,
                color: const Color(0xFF64748B),
                onTap: () => showOpPatientActionsSheet(
                  context: context,
                  patient: p,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}


class _Chip extends StatelessWidget {
  const _Chip({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: portalText(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFECFDF5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFBBF7D0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Color(0xFF22C55E),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: portalText(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: Color(0xFF047857),
            ),
          ),
        ],
      ),
    );
  }
}

class _ServiceChip extends StatelessWidget {
  const _ServiceChip({
    required this.prefix,
    required this.value,
    required this.color,
    required this.onAdd,
  });

  final String prefix;
  final String value;
  final Color color;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: color.withValues(alpha: 0.075),
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onAdd,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            height: 34,
            padding: const EdgeInsets.symmetric(horizontal: 7),
            decoration: BoxDecoration(
              border: Border.all(color: color.withValues(alpha: 0.17)),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Text(
                  prefix,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: portalText(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
                const Spacer(),
                Text(
                  value,
                  style: portalText(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
                const SizedBox(width: 2),
                Container(
                  width: 14,
                  height: 14,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.14),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.add_rounded, size: 9.5, color: color),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BillCell extends StatelessWidget {
  const _BillCell({
    required this.label,
    required this.value,
    required this.valueColor,
  });

  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: portalText(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            color: OpColors.muted,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: portalText(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 36,
      color: const Color(0xFFE8E5F5),
      margin: const EdgeInsets.symmetric(horizontal: 4),
    );
  }
}

class _ActionIcon extends StatelessWidget {
  const _ActionIcon({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 16, color: color),
      ),
    );
  }
}
