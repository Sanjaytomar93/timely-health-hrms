import 'package:flutter/material.dart';
import 'package:timelay_health/core/theme/portal_text.dart';
import 'package:timelay_health/core/widgets/portal_back_button.dart';
import 'package:timelay_health/core/widgets/portal_safe_area.dart';
import 'package:timelay_health/features/op/referral/presentation/models/op_referral_booking_ui.dart';

class OpReferralBookingScreen extends StatefulWidget {
  const OpReferralBookingScreen({super.key, this.initialTab = 0});

  final int initialTab;

  @override
  State<OpReferralBookingScreen> createState() =>
      _OpReferralBookingScreenState();
}

class _OpReferralBookingScreenState extends State<OpReferralBookingScreen> {
  late int _selectedTab; // 0: Customer Referral, 1: Doctor Referral
  final TextEditingController _searchController = TextEditingController();
  String _timeFilter = 'Today';
  bool _isBreakdownExpanded = false;

  late List<OpReferralBookingUi> _bookings;

  final List<String> _timeFilterOptions = const [
    'Today',
    'Yesterday',
    'This Week',
    'Last 7 Days',
    'This Month',
  ];

  @override
  void initState() {
    super.initState();
    _selectedTab = widget.initialTab;
    _bookings = List.of(OpReferralBookingData.demoBookings);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<OpReferralBookingUi> get _filteredBookings {
    final query = _searchController.text.trim().toLowerCase();
    final isCustomer = _selectedTab == 0;

    return _bookings.where((b) {
      if (b.isCustomerReferral != isCustomer) return false;

      if (query.isNotEmpty) {
        final matchesId = b.id.toLowerCase().contains(query);
        final matchesPatient = b.patientName.toLowerCase().contains(query);
        final matchesPatientPhone = b.patientPhone.toLowerCase().contains(query);
        final matchesReferred = b.referredByName.toLowerCase().contains(query);
        final matchesDoctor = b.doctorName.toLowerCase().contains(query);
        if (!matchesId &&
            !matchesPatient &&
            !matchesPatientPhone &&
            !matchesReferred &&
            !matchesDoctor) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg,
          style: portalText(
            fontSize: 13,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredBookings;

    final totalBookings = filtered.length;
    final uniqueCount =
        filtered.map((b) => b.referredByName.trim().toLowerCase()).toSet().length;
    final paidCount =
        filtered.where((b) => b.paymentStatus == 'PAID').length;
    final partialCount =
        filtered.where((b) => b.paymentStatus == 'PARTIAL').length;
    final pendingCount = filtered
        .where((b) => b.paymentStatus != 'PAID' && b.paymentStatus != 'PARTIAL')
        .length;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      body: PortalSafeArea(
        bottom: false,
        statusBarColor: Colors.white,
        child: Column(
          children: [
            _buildTopAppBar(),

            Expanded(
              child: RefreshIndicator(
                color: const Color(0xFF26204A),
                onRefresh: () async {
                  await Future<void>.delayed(const Duration(milliseconds: 300));
                  setState(() {
                    _bookings = List.of(OpReferralBookingData.demoBookings);
                  });
                  _snack('Referral bookings refreshed');
                },
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                  children: [
                    _buildSegmentedTabs(),
                    const SizedBox(height: 14),

                    _buildSearchBar(),
                    const SizedBox(height: 12),

                    _buildTimeFilterChips(),
                    const SizedBox(height: 14),

                    _buildRevenueBreakdownCard(),
                    const SizedBox(height: 14),

                    _buildKpiRow(
                      total: totalBookings,
                      count: uniqueCount > 0 ? uniqueCount : totalBookings,
                      paid: paidCount,
                      partial: partialCount,
                      pending: pendingCount,
                    ),
                    const SizedBox(height: 16),

                    _buildBookingsHeader(),
                    const SizedBox(height: 12),

                    for (final booking in filtered) ...[
                      _buildBookingCard(booking),
                      const SizedBox(height: 14),
                    ],

                    if (filtered.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Center(
                        child: Text(
                          'Showing ${filtered.length} of ${_selectedTab == 0 ? _bookings.where((b) => b.isCustomerReferral).length : _bookings.where((b) => !b.isCustomerReferral).length} referral bookings',
                          style: portalText(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF94A3B8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],

                    if (filtered.isEmpty) _buildEmptyState(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopAppBar() {
    final isCustomer = _selectedTab == 0;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.98),
        border: const Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
      ),
      child: Row(
        children: [
          const PortalBackButton(),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: portalText(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0F172A),
                      height: 1.15,
                    ),
                    children: [
                      TextSpan(
                        text: isCustomer ? 'Customer Referral ' : 'Doctor Referral ',
                      ),
                      const TextSpan(
                        text: 'OP',
                        style: TextStyle(
                          color: Color(0xFF2563EB),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  'Healthcare Outpatient',
                  style: portalText(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => _snack('Notifications'),
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(11),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(
                    Icons.notifications_none_rounded,
                    size: 17,
                    color: Color(0xFF64748B),
                  ),
                  Positioned(
                    top: 7,
                    right: 8,
                    child: Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF43F5E),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
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

  Widget _buildSegmentedTabs() {
    final customerCount =
        _bookings.where((b) => b.isCustomerReferral).length;
    final doctorCount =
        _bookings.where((b) => !b.isCustomerReferral).length;

    return Container(
      height: 48,
      padding: const EdgeInsets.all(3.5),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTab = 0),
              behavior: HitTestBehavior.opaque,
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _selectedTab == 0 ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(11),
                  boxShadow: _selectedTab == 0
                      ? const [
                          BoxShadow(
                            color: Color(0x0F000000),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.person_outline_rounded,
                      size: 16,
                      color: _selectedTab == 0
                          ? const Color(0xFF1E1B4B)
                          : const Color(0xFF64748B),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Customer Referral',
                      style: portalText(
                        fontSize: 12,
                        fontWeight: _selectedTab == 0
                            ? FontWeight.w800
                            : FontWeight.w600,
                        color: _selectedTab == 0
                            ? const Color(0xFF1E1B4B)
                            : const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(width: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6.5,
                        vertical: 1.5,
                      ),
                      decoration: BoxDecoration(
                        color: _selectedTab == 0
                            ? const Color(0xFFF1F5F9)
                            : const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$customerCount',
                        style: portalText(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: _selectedTab == 0
                              ? const Color(0xFF1E1B4B)
                              : const Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTab = 1),
              behavior: HitTestBehavior.opaque,
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _selectedTab == 1 ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(11),
                  boxShadow: _selectedTab == 1
                      ? const [
                          BoxShadow(
                            color: Color(0x0F000000),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.people_outline_rounded,
                      size: 16,
                      color: _selectedTab == 1
                          ? const Color(0xFF1E1B4B)
                          : const Color(0xFF64748B),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Doctor Referral',
                      style: portalText(
                        fontSize: 12,
                        fontWeight: _selectedTab == 1
                            ? FontWeight.w800
                            : FontWeight.w600,
                        color: _selectedTab == 1
                            ? const Color(0xFF1E1B4B)
                            : const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(width: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6.5,
                        vertical: 1.5,
                      ),
                      decoration: BoxDecoration(
                        color: _selectedTab == 1
                            ? const Color(0xFFF1F5F9)
                            : const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$doctorCount',
                        style: portalText(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: _selectedTab == 1
                              ? const Color(0xFF1E1B4B)
                              : const Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
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
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              style: portalText(
                fontSize: 12,
                color: const Color(0xFF0F172A),
              ),
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: 'Search PID, Name, Doctor...',
                hintStyle: portalText(
                  fontSize: 12,
                  color: const Color(0xFF94A3B8),
                ),
              ),
            ),
          ),
          if (_searchController.text.isNotEmpty)
            GestureDetector(
              onTap: () {
                _searchController.clear();
                setState(() {});
              },
              child: const Icon(
                Icons.clear_rounded,
                size: 16,
                color: Color(0xFF94A3B8),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTimeFilterChips() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth = (constraints.maxWidth - (3 * 6)) / 4;
        return SizedBox(
          height: 32,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                for (var i = 0; i < _timeFilterOptions.length; i++) ...[
                  if (i > 0) const SizedBox(width: 6),
                  GestureDetector(
                    onTap: () => setState(() => _timeFilter = _timeFilterOptions[i]),
                    child: Container(
                      constraints: BoxConstraints(minWidth: itemWidth),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      height: 32,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: _timeFilter == _timeFilterOptions[i]
                            ? const Color(0xFF26204A)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _timeFilter == _timeFilterOptions[i]
                              ? const Color(0xFF26204A)
                              : const Color(0xFFE2E8F0),
                        ),
                      ),
                      child: Text(
                        _timeFilterOptions[i],
                        style: portalText(
                          fontSize: 11.5,
                          fontWeight: _timeFilter == _timeFilterOptions[i]
                              ? FontWeight.w700
                              : FontWeight.w600,
                          color: _timeFilter == _timeFilterOptions[i]
                              ? Colors.white
                              : const Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRevenueBreakdownCard() {
    return Container(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: const Color(0xFF26204A).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.credit_card_rounded,
                  size: 15,
                  color: Color(0xFF26204A),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'REVENUE BREAKDOWN',
                      style: portalText(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF0F172A),
                        letterSpacing: 0.25,
                      ),
                    ),
                    Text(
                      '(based on current filters)',
                      style: portalText(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE0E7FF)),
                ),
                child: Text(
                  '52 bookings',
                  style: portalText(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF26204A),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: () => setState(() => _isBreakdownExpanded = !_isBreakdownExpanded),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _isBreakdownExpanded ? 'Hide' : 'Show',
                        style: portalText(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF334155),
                        ),
                      ),
                      Icon(
                        _isBreakdownExpanded
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.keyboard_arrow_down_rounded,
                        size: 14,
                        color: const Color(0xFF64748B),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (_isBreakdownExpanded) ...[
            const SizedBox(height: 12),
            _channelCard(
              title: 'SERVICE REVENUE',
              icon: Icons.layers_outlined,
              footfall: '17',
              amount: '₹3,300',
              bg: const Color(0xFFEFF6FF),
              accent: const Color(0xFF1D4ED8),
              lines: const [
                ('Cash', '₹200', Color(0xFF047857)),
                ('Online', '₹3,093', Color(0xFF4338CA)),
                ('Wallet', '₹0', Color(0xFF64748B)),
                ('Pending', '₹0', Color(0xFFE11D48)),
              ],
            ),
            const SizedBox(height: 8),

            _channelCard(
              title: 'LAB REVENUE',
              icon: Icons.science_outlined,
              footfall: '7',
              amount: '₹17,570',
              bg: const Color(0xFFFAF5FF),
              accent: const Color(0xFF6D28D9),
              lines: const [
                ('Cash', '₹0', Color(0xFF047857)),
                ('Online', '₹17,475', Color(0xFF4338CA)),
                ('Wallet', '₹0', Color(0xFF64748B)),
                ('Pending', '₹0', Color(0xFFE11D48)),
              ],
            ),
            const SizedBox(height: 8),

            _channelCard(
              title: 'PHARMACY REVENUE',
              icon: Icons.local_pharmacy_outlined,
              footfall: '44',
              amount: '₹26,746',
              bg: const Color(0xFFECFDF5),
              accent: const Color(0xFF047857),
              lines: const [
                ('Cash', '₹1,911', Color(0xFF047857)),
                ('Online', '₹24,692', Color(0xFF4338CA)),
                ('Wallet', '₹0', Color(0xFF64748B)),
                ('Pending', '₹100', Color(0xFFE11D48)),
              ],
            ),
            const SizedBox(height: 8),

            _channelCard(
              title: 'FEES REVENUE',
              icon: Icons.receipt_long_outlined,
              footfall: '50',
              amount: '₹14,950',
              bg: const Color(0xFFFFFBEB),
              accent: const Color(0xFFD97706),
              lines: const [
                ('Cash', '₹1,900', Color(0xFF047857)),
                ('Online', '₹12,845', Color(0xFF4338CA)),
                ('Wallet', '₹0', Color(0xFF64748B)),
                ('Pending', '₹200', Color(0xFFE11D48)),
              ],
            ),
            const SizedBox(height: 8),

            _channelCard(
              title: 'TOTAL REVENUE',
              icon: Icons.currency_rupee_rounded,
              footfall: '118',
              amount: '₹62,566',
              bg: const Color(0xFFF8FAFC),
              accent: const Color(0xFF1E293B),
              isTotal: true,
              lines: const [
                ('Svc', '₹3,300', Color(0xFF1D4ED8)),
                ('Lab', '₹17,570', Color(0xFF6D28D9)),
                ('Pharm', '₹26,746', Color(0xFF047857)),
                ('Fees', '₹14,950', Color(0xFFD97706)),
              ],
            ),
            const SizedBox(height: 8),

            _channelCard(
              title: 'TOTAL PAYABLE',
              icon: Icons.call_made_rounded,
              footfall: 'Referral',
              amount: '₹13,863',
              bg: const Color(0xFFFFF1F2),
              accent: const Color(0xFFE11D48),
              isTotal: true,
              lines: const [
                ('Svc', '₹240', Color(0xFF1D4ED8)),
                ('Lab', '₹3,514', Color(0xFF6D28D9)),
                ('Pharm', '₹2,609', Color(0xFF047857)),
                ('Fees', '₹7,500', Color(0xFFD97706)),
              ],
            ),
            const SizedBox(height: 8),

            _channelCard(
              title: 'REFERRAL PAYOUT %',
              icon: Icons.percent_rounded,
              footfall: 'of Revenue',
              amount: '22.16%',
              bg: const Color(0xFFFDF4FF),
              accent: const Color(0xFFC026D3),
              lines: const [
                ('Booking', '₹62,566', Color(0xFF1E293B)),
                ('Payable', '₹13,863', Color(0xFFE11D48)),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _channelCard({
    required String title,
    required IconData icon,
    required String footfall,
    required String amount,
    required Color bg,
    required Color accent,
    bool isTotal = false,
    required List<(String, String, Color)> lines,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isTotal
              ? const Color(0xFFE2E8F0)
              : accent.withValues(alpha: 0.16),
        ),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 16, color: accent),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  title,
                  style: portalText(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: accent,
                    letterSpacing: 0.25,
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    footfall.startsWith('of') || footfall == 'Referral'
                        ? footfall
                        : 'FootFall: $footfall',
                    style: portalText(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: accent.withValues(alpha: 0.8),
                    ),
                  ),
                  Text(
                    amount,
                    style: portalText(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: accent,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(height: 1, color: accent.withValues(alpha: 0.12)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (final line in lines)
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '${line.$1}: ',
                        style: portalText(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: line.$3,
                        ),
                      ),
                      TextSpan(
                        text: line.$2,
                        style: portalText(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: line.$3,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKpiRow({
    required int total,
    required int count,
    required int paid,
    required int partial,
    required int pending,
  }) {
    final isCustomer = _selectedTab == 0;
    return Row(
      children: [
        Expanded(
          child: _kpiCard(
            title: isCustomer ? 'TOTAL CUSTOMERS' : 'TOTAL DOCTORS',
            value: '$count',
            sub: '$total bookings',
            icon: isCustomer
                ? Icons.groups_2_outlined
                : Icons.medical_services_outlined,
            iconBg: const Color(0xFFEFF6FF),
            iconColor: const Color(0xFF2563EB),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _kpiCard(
            title: 'PAID',
            value: '$paid',
            sub: 'completed payments',
            subColor: const Color(0xFF94A3B8),
            icon: Icons.check_circle_outline_rounded,
            iconBg: const Color(0xFFECFDF5),
            iconColor: const Color(0xFF10B981),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _kpiCard(
            title: 'PARTIAL',
            value: '$partial',
            sub: 'partially paid',
            subColor: const Color(0xFF94A3B8),
            icon: Icons.pie_chart_rounded,
            iconBg: const Color(0xFFEFF6FF),
            iconColor: const Color(0xFF2563EB),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _kpiCard(
            title: 'PENDING',
            value: '$pending',
            sub: 'pending payments',
            subColor: const Color(0xFF94A3B8),
            icon: Icons.cancel_outlined,
            iconBg: const Color(0xFFFFF7ED),
            iconColor: const Color(0xFFF97316),
          ),
        ),
      ],
    );
  }

  Widget _kpiCard({
    required String title,
    required String value,
    required String sub,
    Color? subColor,
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: portalText(
                    fontSize: 8.5,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ),
              const SizedBox(width: 2),
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(6),
                ),
                alignment: Alignment.center,
                child: Icon(icon, size: 12, color: iconColor),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: portalText(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF0F172A),
              height: 1.1,
            ),
          ),
          Text(
            sub,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: portalText(
              fontSize: 8.5,
              fontWeight: FontWeight.w500,
              color: subColor ?? const Color(0xFF94A3B8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingsHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: const Color(0xFF26204A).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(7),
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.assignment_outlined,
                size: 14,
                color: Color(0xFF26204A),
              ),
            ),
            const SizedBox(width: 7),
            Text(
              'REFERRAL BOOKINGS',
              style: portalText(
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1E293B),
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),

        GestureDetector(
          onTap: () => _snack('Exported Referral Bookings to CSV'),
          child: Container(
            height: 28,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x06000000),
                  blurRadius: 4,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.file_download_outlined,
                  size: 13,
                  color: Color(0xFF059669),
                ),
                const SizedBox(width: 4),
                Text(
                  'Export',
                  style: portalText(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF334155),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBookingCard(OpReferralBookingUi b) {
    final isPaid = b.paymentStatus == 'PAID';
    final isPartial = b.paymentStatus == 'PARTIAL';

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3.5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      b.id,
                      style: portalText(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0F172A),
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    b.bookingDate,
                    style: portalText(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 3.5,
                ),
                decoration: BoxDecoration(
                  color: isPaid
                      ? const Color(0xFFECFDF5)
                      : (isPartial
                          ? const Color(0xFFFFFBEB)
                          : const Color(0xFFFEF2F2)),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isPaid
                        ? const Color(0xFFD1FAE5)
                        : (isPartial
                            ? const Color(0xFFFDE68A)
                            : const Color(0xFFFECACA)),
                    width: 0.8,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 5.5,
                      height: 5.5,
                      decoration: BoxDecoration(
                        color: isPaid
                            ? const Color(0xFF10B981)
                            : (isPartial
                                ? const Color(0xFFD97706)
                                : const Color(0xFFEF4444)),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      b.paymentStatus,
                      style: portalText(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        color: isPaid
                            ? const Color(0xFF059669)
                            : (isPartial
                                ? const Color(0xFFB45309)
                                : const Color(0xFFDC2626)),
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        b.isCustomerReferral
                            ? 'REFERRED BY CUSTOMER'
                            : 'REFERRED BY DOCTOR',
                        style: portalText(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF94A3B8),
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: !b.isCustomerReferral
                                  ? const Color(0xFF8B5CF6)
                                  : const Color(0xFF26204A),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              !b.isCustomerReferral
                                  ? 'D'
                                  : (b.referredByName.isNotEmpty
                                      ? b.referredByName[0].toUpperCase()
                                      : 'R'),
                              style: portalText(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  b.referredByName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: portalText(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF0F172A),
                                  ),
                                ),
                                Text(
                                  !b.isCustomerReferral && b.orgName.isNotEmpty
                                      ? b.orgName
                                      : b.referredByPhone,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: portalText(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF64748B),
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
                Container(
                  width: 1,
                  height: 48,
                  color: const Color(0xFFE2E8F0),
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'PATIENT DETAILS',
                        style: portalText(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF94A3B8),
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        b.patientName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: portalText(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      Text(
                        b.patientAgeGender,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: portalText(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                      Text(
                        b.patientPhone,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: portalText(
                          fontSize: 10,
                          color: const Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFDCFCE7)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  margin: const EdgeInsets.only(right: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: const Color(0xFFA7F3D0)),
                  ),
                  child: Text(
                    b.bookingType,
                    style: portalText(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF047857),
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    b.slotTime,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: portalText(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF047857),
                    ),
                  ),
                ),
                Text(
                  'Total: ${b.totalAmount}',
                  style: portalText(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
          ),

          if (b.labAmount.isNotEmpty ||
              b.pharmacyAmount.isNotEmpty ||
              b.feesAmount.isNotEmpty ||
              b.serviceAmount.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                if (b.labAmount.isNotEmpty) ...[
                  _tag(
                    'Lab: ${b.labAmount}',
                    const Color(0xFFFAF5FF),
                    const Color(0xFFE9D5FF),
                    const Color(0xFF7E22CE),
                  ),
                  const SizedBox(width: 6),
                ],
                if (b.serviceAmount.isNotEmpty) ...[
                  _tag(
                    'Service: ${b.serviceAmount}',
                    const Color(0xFFEFF6FF),
                    const Color(0xFFBFDBFE),
                    const Color(0xFF2563EB),
                  ),
                  const SizedBox(width: 6),
                ],
                if (b.pharmacyAmount.isNotEmpty) ...[
                  _tag(
                    'Pharmacy: ${b.pharmacyAmount}',
                    const Color(0xFFECFDF5),
                    const Color(0xFFA7F3D0),
                    const Color(0xFF059669),
                  ),
                  const SizedBox(width: 6),
                ],
                if (b.feesAmount.isNotEmpty) ...[
                  _tag(
                    'Fees: ${b.feesAmount}',
                    const Color(0xFFFFF7ED),
                    const Color(0xFFFED7AA),
                    const Color(0xFFEA580C),
                  ),
                ],
              ],
            ),
          ],
          const SizedBox(height: 10),

          if (b.breakdownText.isNotEmpty)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Text(
                b.breakdownText,
                style: portalText(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF475569),
                  height: 1.35,
                ),
              ),
            ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                b.isCustomerReferral
                    ? 'Customer Payable (Total):'
                    : 'Doctor Payable (Total):',
                style: portalText(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0F172A),
                ),
              ),
              Text(
                b.customerPayable,
                style: portalText(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF0F172A),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: b.isSettled ? const Color(0xFFECFDF5) : const Color(0xFFFEF2F2),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: b.isSettled ? const Color(0xFFA7F3D0) : const Color(0xFFFECACA),
              ),
            ),
            child: Row(
              children: [
                Text(
                  b.isSettled ? 'Paid at: ${b.settledAt}' : 'To Pay: ${b.customerPayable}',
                  style: portalText(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: b.isSettled ? const Color(0xFF065F46) : const Color(0xFFDC2626),
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    Icon(
                      b.isSettled ? Icons.check_circle_rounded : Icons.pending_outlined,
                      size: 13,
                      color: b.isSettled ? const Color(0xFF059669) : const Color(0xFFDC2626),
                    ),
                    const SizedBox(width: 3),
                    Text(
                      b.isSettled ? 'Settled' : 'PENDING',
                      style: portalText(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: b.isSettled ? const Color(0xFF059669) : const Color(0xFFDC2626),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),
          const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 10),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 2.5,
                    ),
                    decoration: BoxDecoration(
                      color: b.payoutStatus == 'PAID'
                          ? const Color(0xFFECFDF5)
                          : const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 5,
                          height: 5,
                          decoration: BoxDecoration(
                            color: b.payoutStatus == 'PAID'
                                ? const Color(0xFF10B981)
                                : const Color(0xFFEF4444),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          b.payoutStatus,
                          style: portalText(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                            color: b.payoutStatus == 'PAID'
                                ? const Color(0xFF059669)
                                : const Color(0xFFDC2626),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Payout: ${b.payoutPercentage}',
                    style: portalText(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () => _showBookingDetails(b),
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      width: 32,
                      height: 32,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.visibility_outlined,
                        size: 17,
                        color: Color(0xFF2563EB),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _showUpdatePaymentSheet(b),
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      width: 32,
                      height: 32,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFBEB),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.edit_outlined,
                        size: 17,
                        color: Color(0xFFD97706),
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

  Widget _tag(String label, Color bg, Color border, Color textCol) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: border, width: 0.8),
      ),
      child: Text(
        label,
        style: portalText(
          fontSize: 9.5,
          fontWeight: FontWeight.w700,
          color: textCol,
        ),
      ),
    );
  }

  void _showBookingDetails(OpReferralBookingUi b) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.92,
        ),
        margin: const EdgeInsets.fromLTRB(14, 0, 14, 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(
              color: Color(0x26000000),
              blurRadius: 25,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 12, 12),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4F46E5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      b.isCustomerReferral
                          ? Icons.person_rounded
                          : Icons.medical_services_rounded,
                      size: 22,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          b.isCustomerReferral
                              ? 'Customer Referral Details'
                              : 'Doctor Referral Details',
                          style: portalText(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'ID: 6ac07d881dc001ab294c6c04',
                          style: portalText(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(ctx),
                    icon: const Icon(Icons.close_rounded, size: 20),
                    color: const Color(0xFF94A3B8),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),

            Flexible(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: const BoxDecoration(
                              color: Color(0xFF4F46E5),
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              !b.isCustomerReferral
                                  ? 'D'
                                  : (b.referredByName.isNotEmpty
                                      ? b.referredByName[0].toUpperCase()
                                      : 'K'),
                              style: portalText(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  b.referredByName,
                                  style: portalText(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF0F172A),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.phone_outlined,
                                      size: 13,
                                      color: Color(0xFF64748B),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      !b.isCustomerReferral && b.orgName.isNotEmpty
                                          ? b.orgName
                                          : b.referredByPhone,
                                      style: portalText(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                        color: const Color(0xFF64748B),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    Text(
                      '₹ ${b.isCustomerReferral ? 'CUSTOMER' : 'DOCTOR'} WISE TOTAL AMOUNT RECEIVED',
                      style: portalText(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF64748B),
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 8),

                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: const Color(0xFFDBEAFE)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.change_history_rounded,
                                      size: 13,
                                      color: Color(0xFF2563EB),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'SERVICE',
                                      style: portalText(
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.w800,
                                        color: const Color(0xFF1D4ED8),
                                      ),
                                    ),
                                    const Spacer(),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 5,
                                        vertical: 1.5,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(
                                          color: const Color(0xFFBFDBFE),
                                        ),
                                      ),
                                      child: Text(
                                        '10%',
                                        style: portalText(
                                          fontSize: 8.5,
                                          fontWeight: FontWeight.w700,
                                          color: const Color(0xFF2563EB),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  b.serviceReceived,
                                  style: portalText(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w900,
                                    color: const Color(0xFF1D4ED8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0FDF4),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: const Color(0xFFDCFCE7)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.medication_outlined,
                                      size: 13,
                                      color: Color(0xFF059669),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'PHARMACY',
                                      style: portalText(
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.w800,
                                        color: const Color(0xFF047857),
                                      ),
                                    ),
                                    const Spacer(),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 5,
                                        vertical: 1.5,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(
                                          color: const Color(0xFFA7F3D0),
                                        ),
                                      ),
                                      child: Text(
                                        '10%',
                                        style: portalText(
                                          fontSize: 8.5,
                                          fontWeight: FontWeight.w700,
                                          color: const Color(0xFF059669),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  b.pharmacyReceived,
                                  style: portalText(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w900,
                                    color: const Color(0xFF059669),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFAF5FF),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: const Color(0xFFF3E8FF)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.science_outlined,
                                      size: 13,
                                      color: Color(0xFF7E22CE),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'LAB',
                                      style: portalText(
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.w800,
                                        color: const Color(0xFF6B21A8),
                                      ),
                                    ),
                                    const Spacer(),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 5,
                                        vertical: 1.5,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(
                                          color: const Color(0xFFE9D5FF),
                                        ),
                                      ),
                                      child: Text(
                                        !b.isCustomerReferral
                                            ? b.payoutPercentage
                                            : '20%',
                                        style: portalText(
                                          fontSize: 8.5,
                                          fontWeight: FontWeight.w700,
                                          color: const Color(0xFF7E22CE),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  b.labReceived,
                                  style: portalText(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w900,
                                    color: const Color(0xFF7E22CE),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFFBEB),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: const Color(0xFFFEF3C7)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.confirmation_number_outlined,
                                      size: 13,
                                      color: Color(0xFFD97706),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'FEES',
                                      style: portalText(
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.w800,
                                        color: const Color(0xFF92400E),
                                      ),
                                    ),
                                    const Spacer(),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 5,
                                        vertical: 1.5,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(
                                          color: const Color(0xFFFDE68A),
                                        ),
                                      ),
                                      child: Text(
                                        '₹150',
                                        style: portalText(
                                          fontSize: 8.5,
                                          fontWeight: FontWeight.w700,
                                          color: const Color(0xFFD97706),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  b.feesReceived,
                                  style: portalText(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w900,
                                    color: const Color(0xFFD97706),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEF2FF),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFC7D2FE)),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.military_tech_outlined,
                            size: 18,
                            color: Color(0xFF4F46E5),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'TOTAL ${b.isCustomerReferral ? 'CUSTOMER' : 'DOCTOR'} PAYABLE',
                            style: portalText(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF3730A3),
                              letterSpacing: 0.3,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            b.totalPayableAll,
                            style: portalText(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFF1E1B4B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),

                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0FDF4),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFFDCFCE7)),
                            ),
                            alignment: Alignment.center,
                            child: Column(
                              children: [
                                Text(
                                  'ALREADY PAID',
                                  style: portalText(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF059669),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  b.alreadyPaid,
                                  style: portalText(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w900,
                                    color: const Color(0xFF059669),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF2F2),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFFFEE2E2)),
                            ),
                            alignment: Alignment.center,
                            child: Column(
                              children: [
                                Text(
                                  'REMAINING TO PAY',
                                  style: portalText(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFFDC2626),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  b.remainingToPay,
                                  style: portalText(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w900,
                                    color: const Color(0xFFDC2626),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    Text(
                      'SELECTED BOOKING DETAILS',
                      style: portalText(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF64748B),
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        children: [
                          _modalRow('PID:', b.id),
                          _modalRow('Created At:', b.bookingDate),
                          _modalRow('Patient:', b.patientName),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Booking Type:',
                                  style: portalText(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF64748B),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFECFDF5),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(
                                      color: const Color(0xFFA7F3D0),
                                    ),
                                  ),
                                  child: Text(
                                    b.bookingType,
                                    style: portalText(
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF047857),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _modalRow('Appt. Date:', '18/11/26'),
                          _modalRow('Total Amount:', b.totalAmount),
                          _modalRow('Referral Payout:', b.payoutPercentage),
                          _modalRow('To Pay:', b.customerPayable),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 2),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  b.isCustomerReferral
                                      ? 'Customer Payment:'
                                      : 'Doctor Payment:',
                                  style: portalText(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF64748B),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: b.payoutStatus == 'PAID'
                                        ? const Color(0xFFECFDF5)
                                        : const Color(0xFFFEF2F2),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(
                                      color: b.payoutStatus == 'PAID'
                                          ? const Color(0xFFA7F3D0)
                                          : const Color(0xFFFECACA),
                                    ),
                                  ),
                                  child: Text(
                                    b.payoutStatus,
                                    style: portalText(
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w700,
                                      color: b.payoutStatus == 'PAID'
                                          ? const Color(0xFF059669)
                                          : const Color(0xFFDC2626),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    Text(
                      'SERVICE-WISE COMMISSION',
                      style: portalText(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF64748B),
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        children: [
                          Container(
                            color: const Color(0xFFF8FAFC),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    'SERVICE',
                                    style: portalText(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFF64748B),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    'CATEGORY',
                                    style: portalText(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFF64748B),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    'PRICE',
                                    style: portalText(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFF64748B),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    'RATE',
                                    style: portalText(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFF64748B),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    'PAYABLE',
                                    textAlign: TextAlign.right,
                                    style: portalText(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFF64748B),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Divider(height: 1, thickness: 1, color: Color(0xFFE2E8F0)),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 10,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    b.isCustomerReferral
                                        ? 'Doctor Consultation Fees'
                                        : 'Lab Services',
                                    style: portalText(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF0F172A),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 5,
                                        vertical: 1.5,
                                      ),
                                      decoration: BoxDecoration(
                                        color: b.isCustomerReferral
                                            ? const Color(0xFFFFFBEB)
                                            : const Color(0xFFFAF5FF),
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(
                                          color: b.isCustomerReferral
                                              ? const Color(0xFFFDE68A)
                                              : const Color(0xFFE9D5FF),
                                        ),
                                      ),
                                      child: Text(
                                        b.isCustomerReferral ? 'FEES' : 'LAB',
                                        style: portalText(
                                          fontSize: 8.5,
                                          fontWeight: FontWeight.w800,
                                          color: b.isCustomerReferral
                                              ? const Color(0xFFD97706)
                                              : const Color(0xFF7E22CE),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    b.totalAmount,
                                    style: portalText(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF0F172A),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    b.isCustomerReferral
                                        ? '₹150'
                                        : b.payoutPercentage,
                                    style: portalText(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF0F172A),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    b.customerPayable,
                                    textAlign: TextAlign.right,
                                    style: portalText(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFF2563EB),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            color: const Color(0xFFEEF2FF),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8,
                            ),
                            child: Row(
                              children: [
                                Text(
                                  'Total ${b.isCustomerReferral ? 'Customer' : 'Doctor'} Payable',
                                  style: portalText(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF3730A3),
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  b.customerPayable,
                                  style: portalText(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w900,
                                    color: const Color(0xFF2563EB),
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
            ),

            const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),

            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _showUpdatePaymentSheet(b);
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 11),
                        side: const BorderSide(color: Color(0xFFCBD5E1)),
                        backgroundColor: const Color(0xFFF8FAFC),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      icon: const Icon(
                        Icons.edit_outlined,
                        size: 15,
                        color: Color(0xFF2563EB),
                      ),
                      label: Text(
                        'Update Referral Payment',
                        style: portalText(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF2563EB),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 11,
                      ),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'Close',
                      style: portalText(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
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

  void _showUpdatePaymentSheet(OpReferralBookingUi b) {
    final payAmountController = TextEditingController(
      text: b.customerPayable.replaceAll('₹', '').replaceAll(',', '').trim(),
    );
    String selectedPayType = 'Cash';
    String selectedPayStatus = 'Paid';

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          final enteredAmt = payAmountController.text.trim();
          final previewText = enteredAmt.isNotEmpty && selectedPayType != 'Select Payment Type'
              ? 'Payment: ₹$enteredAmt via $selectedPayType (Status: $selectedPayStatus)'
              : 'Not selected';

          return Container(
            margin: EdgeInsets.only(
              left: 14,
              right: 14,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x26000000),
                  blurRadius: 25,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 12, 12),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: const Color(0xFF4F46E5),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.payments_outlined,
                            size: 22,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Update Referral Payment',
                                style: portalText(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF0F172A),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                b.referredByName,
                                style: portalText(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(ctx),
                          icon: const Icon(Icons.close_rounded, size: 20),
                          color: const Color(0xFF94A3B8),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),

                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEEF2FF),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFE0E7FF)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${b.isCustomerReferral ? 'Customer' : 'Doctor'} Name: ${b.referredByName}',
                                        style: portalText(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: const Color(0xFF0F172A),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        b.isCustomerReferral
                                            ? 'CUSTOMER PAYABLE'
                                            : 'DOCTOR PAYABLE',
                                        style: portalText(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w800,
                                          color: const Color(0xFF4F46E5),
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        b.customerPayable,
                                        style: portalText(
                                          fontSize: 22,
                                          fontWeight: FontWeight.w900,
                                          color: const Color(0xFF312E81),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        'Patient',
                                        style: portalText(
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.w500,
                                          color: const Color(0xFF64748B),
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        b.patientName,
                                        style: portalText(
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w800,
                                          color: const Color(0xFF0F172A),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFEF9C3),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: const Color(0xFFFDE047)),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.confirmation_number_outlined,
                                      size: 13,
                                      color: Color(0xFFD97706),
                                    ),
                                    const SizedBox(width: 5),
                                    Expanded(
                                      child: Text(
                                        b.isCustomerReferral
                                            ? 'Fees: (₹150) ₹300 -> ₹150'
                                            : (b.breakdownText.isNotEmpty
                                                ? b.breakdownText.split('\n').first
                                                : 'Lab: (40%) ₹1300 -> ₹520'),
                                        style: portalText(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF92400E),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: const Color(0xFFC7D2FE)),
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      'TOTAL:',
                                      style: portalText(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                        color: const Color(0xFF3730A3),
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      b.customerPayable,
                                      style: portalText(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w900,
                                        color: const Color(0xFF3730A3),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        Text(
                          'PAYMENT NEED TO PAY (₹)',
                          style: portalText(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF64748B),
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFCBD5E1)),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Row(
                            children: [
                              Text(
                                '₹ ',
                                style: portalText(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF64748B),
                                ),
                              ),
                              Expanded(
                                child: TextField(
                                  controller: payAmountController,
                                  keyboardType: TextInputType.number,
                                  onChanged: (_) => setSheetState(() {}),
                                  style: portalText(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF0F172A),
                                  ),
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding:
                                        EdgeInsets.symmetric(vertical: 12),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              'Pending: ${b.customerPayable}',
                              style: portalText(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFFDC2626),
                              ),
                            ),
                            const Spacer(),
                            GestureDetector(
                              onTap: () {
                                setSheetState(() {
                                  payAmountController.text = b.customerPayable
                                      .replaceAll('₹', '')
                                      .replaceAll(',', '')
                                      .trim();
                                });
                              },
                              child: Text(
                                'Set Full (${b.customerPayable})',
                                style: portalText(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF2563EB),
                                ).copyWith(
                                  decoration: TextDecoration.underline,
                                  decorationColor: const Color(0xFF2563EB),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'PAYMENT TYPE',
                                    style: portalText(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFF64748B),
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: const Color(0xFFCBD5E1),
                                      ),
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        value: selectedPayType,
                                        isExpanded: true,
                                        icon: const Icon(
                                          Icons.keyboard_arrow_down_rounded,
                                          size: 18,
                                        ),
                                        style: portalText(
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF0F172A),
                                        ),
                                        items: const [
                                          DropdownMenuItem(
                                            value: 'Cash',
                                            child: Text('Cash'),
                                          ),
                                          DropdownMenuItem(
                                            value: 'Online / UPI',
                                            child: Text('Online / UPI'),
                                          ),
                                          DropdownMenuItem(
                                            value: 'Bank Transfer',
                                            child: Text('Bank Transfer'),
                                          ),
                                          DropdownMenuItem(
                                            value: 'Wallet',
                                            child: Text('Wallet'),
                                          ),
                                        ],
                                        onChanged: (v) {
                                          if (v != null) {
                                            setSheetState(
                                              () => selectedPayType = v,
                                            );
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'PAYMENT STATUS',
                                    style: portalText(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFF64748B),
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: const Color(0xFFCBD5E1),
                                      ),
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        value: selectedPayStatus,
                                        isExpanded: true,
                                        icon: const Icon(
                                          Icons.keyboard_arrow_down_rounded,
                                          size: 18,
                                        ),
                                        style: portalText(
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF0F172A),
                                        ),
                                        items: const [
                                          DropdownMenuItem(
                                            value: 'Paid',
                                            child: Text('Paid'),
                                          ),
                                          DropdownMenuItem(
                                            value: 'Partial',
                                            child: Text('Partial'),
                                          ),
                                          DropdownMenuItem(
                                            value: 'Pending',
                                            child: Text('Pending'),
                                          ),
                                        ],
                                        onChanged: (v) {
                                          if (v != null) {
                                            setSheetState(
                                              () => selectedPayStatus = v,
                                            );
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'LIVE PREVIEW:',
                                style: portalText(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF64748B),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                previewText,
                                style: portalText(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF0F172A),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),

                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton(
                          onPressed: () => Navigator.pop(ctx),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 11,
                            ),
                            side: const BorderSide(color: Color(0xFFCBD5E1)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            'Cancel',
                            style: portalText(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF475569),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton.icon(
                          onPressed: () {
                            final amt = payAmountController.text.trim();
                            final idx = _bookings.indexWhere((x) => x.id == b.id);
                            if (idx != -1) {
                              setState(() {
                                final isNowPaid = selectedPayStatus == 'Paid';
                                _bookings[idx] = b.copyWith(
                                  paymentStatus: isNowPaid
                                      ? 'PAID'
                                      : (selectedPayStatus == 'Partial'
                                          ? 'PARTIAL'
                                          : 'PENDING'),
                                  payoutStatus: isNowPaid ? 'PAID' : 'PENDING',
                                  isSettled: isNowPaid,
                                  settledAt: '18/11/26 12:30 pm',
                                );
                              });
                            }
                            Navigator.pop(ctx);
                            _snack(
                              'Payment of ₹$amt for ${b.id} saved successfully!',
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4F46E5),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 22,
                              vertical: 11,
                            ),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          icon: const Icon(
                            Icons.check_rounded,
                            size: 16,
                            color: Colors.white,
                          ),
                          label: Text(
                            'Save Payment',
                            style: portalText(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _modalRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: portalText(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF64748B),
            ),
          ),
          Text(
            value,
            style: portalText(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Column(
          children: [
            const Icon(
              Icons.receipt_long_outlined,
              size: 44,
              color: Color(0xFFCBD5E1),
            ),
            const SizedBox(height: 10),
            Text(
              'No referral bookings found',
              style: portalText(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
