import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:timelay_health/core/theme/portal_text.dart';
import 'package:timelay_health/core/widgets/portal_safe_area.dart';
import 'package:timelay_health/features/op/walkin/presentation/models/op_walkin_ui.dart';
import 'package:timelay_health/features/op/walkin/presentation/screens/op_inactive_patients_screen.dart';
import 'package:timelay_health/features/op/walkin/presentation/screens/op_register_screen.dart';
import 'package:timelay_health/features/op/dashboard/presentation/theme/op_colors.dart';
import 'package:timelay_health/features/op/dashboard/presentation/models/op_dashboard_ui.dart';
import 'package:timelay_health/features/op/walkin/data/datasources/op_walkin_remote_datasource.dart';
import 'package:timelay_health/features/op/walkin/presentation/widgets/op_amount_items_sheet.dart';
import 'package:timelay_health/features/op/walkin/presentation/widgets/op_patient_actions_sheet.dart';
import 'package:timelay_health/features/op/dashboard/presentation/widgets/op_dashboard_sections.dart';
import 'package:timelay_health/features/op/walkin/presentation/widgets/op_vitals_sheet.dart';

class OpWalkinScreen extends StatefulWidget {
  const OpWalkinScreen({super.key, this.onMenuTap});

  final VoidCallback? onMenuTap;

  @override
  State<OpWalkinScreen> createState() => _OpWalkinScreenState();
}

class _CachedWalkinData {
  const _CachedWalkinData({
    required this.patients,
    required this.metrics,
    this.totalCollected,
    this.clinicRevenue,
    this.labRevenue,
    this.pharmacyRevenue,
  });

  final List<OpWalkinPatientUi> patients;
  final List<OpMetricUi> metrics;
  final int? totalCollected;
  final int? clinicRevenue;
  final int? labRevenue;
  final int? pharmacyRevenue;
}

class _OpWalkinScreenState extends State<OpWalkinScreen> {
  final _search = TextEditingController();
  final OpWalkinRemoteDataSource _dataSource = OpWalkinRemoteDataSource();

  late String _period;
  String _query = '';
  bool _isLoading = false;
  int _requestId = 0;
  final Map<String, _CachedWalkinData> _periodCache = {};

  List<OpWalkinPatientUi> _allPatients = List.of(OpWalkinUi.demo.patients);
  List<OpMetricUi> _metrics = List.of(OpWalkinUi.demo.metrics);

  int? _apiTotalCollected;
  int? _apiClinicRevenue;
  int? _apiLabRevenue;
  int? _apiPharmacyRevenue;

  @override
  void initState() {
    super.initState();
    _period = OpWalkinUi.demo.selectedPeriod;
    _search.addListener(() => setState(() => _query = _search.text.trim()));
    _loadBookings();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  static String _formatYmd(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  (String?, String?) _getDateRange(String period) {
    final now = DateTime.now().toLocal();
    final today = DateTime(now.year, now.month, now.day);
    switch (period) {
      case 'Today':
        final s = _formatYmd(today);
        return (s, s);
      case 'Yesterday':
        final y = today.subtract(const Duration(days: 1));
        final s = _formatYmd(y);
        return (s, s);
      case 'This Week':
        final start = today.subtract(Duration(days: today.weekday - 1));
        final end = start.add(const Duration(days: 6));
        return (_formatYmd(start), _formatYmd(end));
      case 'Last 7 Days':
        final start = today.subtract(const Duration(days: 6));
        return (_formatYmd(start), _formatYmd(today));
      case 'This Month':
        final start = DateTime(today.year, today.month, 1);
        final end = DateTime(today.year, today.month + 1, 0);
        return (_formatYmd(start), _formatYmd(end));
      case 'Last Month':
        final start = DateTime(today.year, today.month - 1, 1);
        final end = DateTime(today.year, today.month, 0);
        return (_formatYmd(start), _formatYmd(end));
      case 'This Year':
        final start = DateTime(today.year, 1, 1);
        final end = DateTime(today.year, 12, 31);
        return (_formatYmd(start), _formatYmd(end));
      case 'All':
      default:
        return (null, null);
    }
  }

  Future<void> _loadBookings({bool isRefresh = false}) async {
    final currentPeriod = _period;
    final currentReqId = ++_requestId;

    if (!isRefresh && _periodCache.containsKey(currentPeriod)) {
      final cached = _periodCache[currentPeriod]!;
      setState(() {
        _allPatients = cached.patients;
        _metrics = cached.metrics;
        _apiTotalCollected = cached.totalCollected;
        _apiClinicRevenue = cached.clinicRevenue;
        _apiLabRevenue = cached.labRevenue;
        _apiPharmacyRevenue = cached.pharmacyRevenue;
        _isLoading = false;
      });
    } else if (!isRefresh) {
      setState(() => _isLoading = true);
    }

    final (from, to) = _getDateRange(currentPeriod);
    try {
      final res = await _dataSource.getAllBookings(apptFrom: from, apptTo: to);
      if (!mounted || currentReqId != _requestId) return;

      List<OpWalkinPatientUi> parsedPatients = [];
      if (res['bookings'] is List) {
        final list = res['bookings'] as List;
        int idx = 1;
        for (final item in list) {
          if (item is Map<String, dynamic>) {
            parsedPatients.add(OpWalkinPatientUi.fromJson(item, index: idx++));
          }
        }
      }

      List<OpMetricUi> parsedMetrics = List.of(_metrics);
      if (res['stats'] is Map<String, dynamic>) {
        final s = res['stats'] as Map<String, dynamic>;
        final totalPatients = s['totalPatients'] ?? parsedPatients.length;
        final active = s['active'] ?? totalPatients;
        final inactive = s['inactive'] ?? 0;
        final paid = s['paid'] ?? 0;
        final partial = s['partial'] ?? 0;
        final due = s['due'] ?? 0;
        final rev = s['revenueBreakdown'] is Map<String, dynamic>
            ? s['revenueBreakdown'] as Map<String, dynamic>
            : null;
        final cat = res['categoryBreakdown'] is Map<String, dynamic>
            ? res['categoryBreakdown'] as Map<String, dynamic>
            : null;

        final clinicNum = rev?['clinicRevenue'] ?? cat?['clinic']?['total'];
        final labNum = rev?['labRevenue'] ?? cat?['lab']?['total'];
        final pharmNum = rev?['pharmacyRevenue'] ?? cat?['pharmacy']?['total'];

        _apiClinicRevenue = (clinicNum is num) ? clinicNum.round() : null;
        _apiLabRevenue = (labNum is num) ? labNum.round() : null;
        _apiPharmacyRevenue = (pharmNum is num) ? pharmNum.round() : null;

        final int totalCategorySum = (_apiClinicRevenue ?? 0) +
            (_apiLabRevenue ?? 0) +
            (_apiPharmacyRevenue ?? 0);

        final revCollected = rev?['totalCollected'] is num
            ? (rev!['totalCollected'] as num).round()
            : (s['totalRevenue'] is num ? (s['totalRevenue'] as num).round() : null);

        _apiTotalCollected = revCollected ?? (totalCategorySum > 0 ? totalCategorySum : 0);

        parsedMetrics = [
          OpMetricUi(
            title: 'TOTAL CLINIC PATIENTS',
            value: '$totalPatients',
            activeLabel: 'Active: $active',
            inactiveLabel: 'Inactive: $inactive',
            accent: const Color(0xFF4F46E5),
            icon: Icons.people_outline_rounded,
            tint: const Color(0xFFEEF2FF),
          ),
          OpMetricUi(
            title: 'PAID',
            value: '$paid',
            subtitle: 'completed payments',
            accent: const Color(0xFF059669),
            icon: Icons.person_outline_rounded,
            tint: const Color(0xFFECFDF5),
          ),
          OpMetricUi(
            title: 'PARTIAL',
            value: '$partial',
            subtitle: 'partially paid',
            accent: const Color(0xFF2563EB),
            icon: Icons.access_time_rounded,
            tint: const Color(0xFFEFF6FF),
          ),
          OpMetricUi(
            title: 'DUE',
            value: '$due',
            subtitle: 'overdue payments',
            accent: const Color(0xFFEA580C),
            icon: Icons.cancel_outlined,
            tint: const Color(0xFFFFF7ED),
          ),
          OpMetricUi(
            title: 'TOTAL COLLECTED',
            value: '₹${_formatCurrency(_apiTotalCollected ?? 0)}',
            accent: const Color(0xFF059669),
            icon: Icons.currency_rupee_rounded,
            tint: const Color(0xFFECFDF5),
            wide: true,
            breakdown: [
              (
                label: 'Clinic',
                value: '₹${_formatCurrency(_apiClinicRevenue ?? 0)}',
                color: const Color(0xFF2563EB),
              ),
              (
                label: 'Lab',
                value: '₹${_formatCurrency(_apiLabRevenue ?? 0)}',
                color: const Color(0xFF7C3AED),
              ),
              (
                label: 'Pharmacy',
                value: '₹${_formatCurrency(_apiPharmacyRevenue ?? 0)}',
                color: const Color(0xFF059669),
              ),
            ],
          ),
        ];
      }

      _periodCache[currentPeriod] = _CachedWalkinData(
        patients: parsedPatients,
        metrics: parsedMetrics,
        totalCollected: _apiTotalCollected,
        clinicRevenue: _apiClinicRevenue,
        labRevenue: _apiLabRevenue,
        pharmacyRevenue: _apiPharmacyRevenue,
      );

      setState(() {
        _allPatients = parsedPatients;
        _metrics = parsedMetrics;
        _isLoading = false;
      });
    } catch (_) {
      if (mounted && currentReqId == _requestId) {
        setState(() => _isLoading = false);
      }
    }
  }

  static String _formatCurrency(int val) {
    if (val == 0) return '0';
    final s = val.toString();
    final len = s.length;
    if (len <= 3) return s;
    final last3 = s.substring(len - 3);
    var rest = s.substring(0, len - 3);
    final buffer = StringBuffer();
    while (rest.length > 2) {
      buffer.write(',${rest.substring(rest.length - 2)}');
      rest = rest.substring(0, rest.length - 2);
    }
    return '$rest$buffer,$last3';
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

  void _openInactivePatients() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (ctx) => OpInactivePatientsScreen(
          onMenuTap: widget.onMenuTap,
        ),
      ),
    );
  }

  List<OpWalkinPatientUi> _filtered() {
    if (_query.isEmpty) return _allPatients;
    final q = _query.toLowerCase();
    return _allPatients
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
    final patients = _filtered();

    return ColoredBox(
      color: const Color(0xFFF6F8FC),
      child: Column(
        children: [
          _WalkinTopBar(onMenuTap: widget.onMenuTap),
          if (_isLoading)
            const LinearProgressIndicator(
              minHeight: 2.5,
              color: OpColors.primary,
              backgroundColor: Color(0xFFE2E8F0),
            ),
          Expanded(
            child: RefreshIndicator(
              color: OpColors.primary,
              onRefresh: () => _loadBookings(isRefresh: true),
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
                          onSelected: (value) {
                            if (_period == value && !_isLoading) return;
                            setState(() => _period = value);
                            _loadBookings();
                          },
                        ),
                        const SizedBox(height: 14),
                        _RevenueSummary(
                          patients: patients,
                          totalOverride: _apiTotalCollected,
                          clinicOverride: _apiClinicRevenue,
                          labOverride: _apiLabRevenue,
                          pharmacyOverride: _apiPharmacyRevenue,
                        ),
                        const SizedBox(height: 16),
                        _WalkinStatsGrid(metrics: _metrics),
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
                              const Spacer(),
                              Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: _openInactivePatients,
                                  borderRadius: BorderRadius.circular(20),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 11,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFF7ED),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: const Color(0xFFFFEDD5),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.history_toggle_off_rounded,
                                          size: 13,
                                          color: Color(0xFFEA580C),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Inactive Patients',
                                          style: portalText(
                                            fontSize: 11.5,
                                            fontWeight: FontWeight.w800,
                                            color: const Color(0xFFEA580C),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
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
  const _RevenueSummary({
    required this.patients,
    this.totalOverride,
    this.clinicOverride,
    this.labOverride,
    this.pharmacyOverride,
  });

  final List<OpWalkinPatientUi> patients;
  final int? totalOverride;
  final int? clinicOverride;
  final int? labOverride;
  final int? pharmacyOverride;

  int _amount(String value) =>
      int.tryParse(value.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

  @override
  Widget build(BuildContext context) {
    final int clinic = clinicOverride ??
        patients.fold<int>(0, (sum, p) => sum + _amount(p.clinic));
    final int lab = labOverride ??
        patients.fold<int>(0, (sum, p) => sum + _amount(p.lab));
    final int pharmacy = pharmacyOverride ??
        patients.fold<int>(0, (sum, p) => sum + _amount(p.pharmacy));
    final int total = totalOverride ?? (clinic + lab + pharmacy);

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
                          '₹${_OpWalkinScreenState._formatCurrency(total)}',
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
                          _RevenuePartSmall(
                            label: 'Clinic',
                            value: '₹${_OpWalkinScreenState._formatCurrency(clinic)}',
                          ),
                          const SizedBox(width: 6),
                          _RevenuePartSmall(
                            label: 'Lab',
                            value: '₹${_OpWalkinScreenState._formatCurrency(lab)}',
                          ),
                          const SizedBox(width: 6),
                          _RevenuePartSmall(
                            label: 'Pharmacy',
                            value: '₹${_OpWalkinScreenState._formatCurrency(pharmacy)}',
                          ),
                        ],
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
              ],
            ),
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              const gap = 8.0;
              final standardWidth =
                  ((constraints.maxWidth - (gap * 2) - 14) / 3).clamp(126.0, 160.0);
              return SizedBox(
                height: 114,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.only(right: 14, bottom: 2),
                  itemCount: metrics.length,
                  separatorBuilder: (_, _) => const SizedBox(width: gap),
                  itemBuilder: (_, i) {
                    final m = metrics[i];
                    final width = m.breakdown.isNotEmpty
                        ? (standardWidth * 1.55).clamp(185.0, 240.0)
                        : standardWidth;
                    return SizedBox(
                      width: width,
                      child: _CompactStatCard(data: m),
                    );
                  },
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  data.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: portalText(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Container(
                width: 26,
                height: 26,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: data.tint,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(data.icon, size: 14, color: data.accent),
              ),
            ],
          ),
          Text(
            data.value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: portalText(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0F172A),
            ),
          ),
          if (data.breakdown.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (data.breakdown.isNotEmpty)
                      Flexible(
                        child: Text(
                          '${data.breakdown[0].label}: ${data.breakdown[0].value}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: portalText(
                            fontSize: 8.5,
                            fontWeight: FontWeight.w700,
                            color: data.breakdown[0].color,
                          ),
                        ),
                      ),
                    if (data.breakdown.length > 1) ...[
                      const SizedBox(width: 5),
                      Flexible(
                        child: Text(
                          '${data.breakdown[1].label}: ${data.breakdown[1].value}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: portalText(
                            fontSize: 8.5,
                            fontWeight: FontWeight.w700,
                            color: data.breakdown[1].color,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                if (data.breakdown.length > 2) ...[
                  const SizedBox(height: 1.5),
                  Text(
                    '${data.breakdown[2].label}: ${data.breakdown[2].value}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: portalText(
                      fontSize: 8.5,
                      fontWeight: FontWeight.w700,
                      color: data.breakdown[2].color,
                    ),
                  ),
                ],
              ],
            )
          else if (data.activeLabel != null)
            Row(
              children: [
                Text(
                  data.activeLabel!,
                  style: portalText(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF059669),
                  ),
                ),
                if (data.inactiveLabel != null) ...[
                  const SizedBox(width: 5),
                  Text(
                    data.inactiveLabel!,
                    style: portalText(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFDC2626),
                    ),
                  ),
                ],
              ],
            )
          else if (data.subtitle.isNotEmpty)
            Text(
              data.subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: portalText(
                fontSize: 9.5,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF94A3B8),
              ),
            )
          else
            const SizedBox(height: 12),
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
