import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:timelay_health/core/theme/portal_colors.dart';
import 'package:timelay_health/core/theme/portal_text.dart';
import 'package:timelay_health/core/widgets/portal_safe_area.dart';
import 'package:timelay_health/features/admin/digital_leads/data/datasources/digital_leads_remote_datasource.dart';
import 'package:timelay_health/features/admin/digital_leads/data/models/digital_lead_model.dart';
import 'package:timelay_health/features/dashboard/presentation/screens/employee_home_shell.dart';
import 'package:timelay_health/features/dashboard/presentation/widgets/employee_bottom_nav.dart';
import 'package:timelay_health/features/dashboard/presentation/widgets/home_side_drawer.dart';
import 'package:timelay_health/features/holidays/presentation/widgets/top_calendar_button.dart';
import 'package:timelay_health/features/notifications/presentation/widgets/top_notification_button.dart';

class DigitalLeadsScreen extends StatefulWidget {
  const DigitalLeadsScreen({super.key});

  @override
  State<DigitalLeadsScreen> createState() => _DigitalLeadsScreenState();
}

class _DigitalLeadsScreenState extends State<DigitalLeadsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final DigitalLeadsRemoteDataSource _datasource =
      DigitalLeadsRemoteDataSource();
  final TextEditingController _searchController = TextEditingController();

  late List<DigitalLead> _allLeads;
  LeadCounts? _leadCounts;
  bool _isLoading = false;

  String _searchQuery = '';
  DateTime? _selectedDate;
  String _selectedMonth = 'All Months';
  LeadStatus? _selectedStatusFilter;

  final List<String> _months = const [
    'All Months',
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  @override
  void initState() {
    super.initState();
    _allLeads = List<DigitalLead>.from(DigitalLead.sampleLeads());
    _selectedMonth = 'All Months';
    _loadLeads();
  }

  Future<void> _loadLeads() async {
    setState(() => _isLoading = true);
    try {
      final res = await _datasource.getConsultationLeads();
      if (!mounted) return;
      setState(() {
        _allLeads = res.leads;
        if (res.counts != null) {
          _leadCounts = res.counts;
        }
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<DigitalLead> get _filteredLeads {
    return _allLeads.where((lead) {
      if (_selectedStatusFilter != null && lead.status != _selectedStatusFilter) {
        return false;
      }

      if (_selectedMonth != 'All Months') {
        final shortMonth = _selectedMonth.substring(0, 3).toLowerCase();
        final matchStr = lead.date.toLowerCase().contains(shortMonth) ||
            lead.date.toLowerCase().contains(_selectedMonth.toLowerCase());
        final matchDate = lead.createdAtDate != null &&
            _monthName(lead.createdAtDate!.month).toLowerCase() ==
                _selectedMonth.toLowerCase();
        if (!matchStr && !matchDate) {
          return false;
        }
      }

      if (_selectedDate != null) {
        final dayStr = '${_selectedDate!.day} ${_monthShort(_selectedDate!.month)}';
        final matchStr = lead.date.toLowerCase().contains(dayStr.toLowerCase());
        final matchDate = lead.createdAtDate != null &&
            lead.createdAtDate!.year == _selectedDate!.year &&
            lead.createdAtDate!.month == _selectedDate!.month &&
            lead.createdAtDate!.day == _selectedDate!.day;
        if (!matchStr && !matchDate) {
          return false;
        }
      }

      if (_searchQuery.trim().isNotEmpty) {
        final q = _searchQuery.trim().toLowerCase();
        final match = lead.name.toLowerCase().contains(q) ||
            lead.leadNumber.toLowerCase().contains(q) ||
            lead.phone.toLowerCase().contains(q) ||
            lead.email.toLowerCase().contains(q) ||
            lead.businessType.toLowerCase().contains(q) ||
            lead.lookingFor.toLowerCase().contains(q) ||
            lead.source.toLowerCase().contains(q);
        if (!match) return false;
      }

      return true;
    }).toList();
  }

  int get _totalCount => _leadCounts?.totalLeads ?? _allLeads.length;
  int get _newCount =>
      _leadCounts?.newLeads ??
      _allLeads.where((l) => l.status == LeadStatus.newLead).length;
  int get _contactedCount =>
      _leadCounts?.contacted ??
      _allLeads.where((l) => l.status == LeadStatus.contacted).length;
  int get _convertedCount =>
      _leadCounts?.converted ??
      _allLeads.where((l) => l.status == LeadStatus.converted).length;
  int get _rejectedCount =>
      _leadCounts?.rejected ??
      _allLeads.where((l) => l.status == LeadStatus.rejected).length;

  void _onStatusChange(DigitalLead lead, LeadStatus newStatus) {
    HapticFeedback.lightImpact();
    setState(() {
      final index = _allLeads.indexWhere((l) => l.id == lead.id);
      if (index != -1) {
        _allLeads[index] = _allLeads[index].copyWith(status: newStatus);
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Lead "${lead.name}" marked as ${newStatus.label}'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _copyToClipboard(String text, String label) {
    HapticFeedback.lightImpact();
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label copied to clipboard: $text'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _pickSingleDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: PortalColors.brand,
              onPrimary: Colors.white,
              onSurface: PortalColors.heading,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _clearAllFilters() {
    setState(() {
      _searchController.clear();
      _searchQuery = '';
      _selectedDate = null;
      _selectedMonth = 'All Months';
      _selectedStatusFilter = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredLeads;
    final hasActiveFilter = _searchQuery.isNotEmpty ||
        _selectedMonth != 'All Months' ||
        _selectedStatusFilter != null ||
        _selectedDate != null;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF8FAFC),
      drawer: const HomeSideDrawer(),
      drawerScrimColor: PortalColors.brand.withValues(alpha: 0.28),
      body: PortalSafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildAttendanceStyleAppBar(),
            if (_isLoading)
              const LinearProgressIndicator(
                minHeight: 2.5,
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation<Color>(PortalColors.brand),
              ),
            Expanded(
              child: RefreshIndicator(
                color: PortalColors.brand,
                onRefresh: _loadLeads,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 32),
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    _buildTotalLeadsCard(),
                    const SizedBox(height: 12),
                    _buildMetricCardsGrid(),
                    const SizedBox(height: 16),
                    _buildSearchBarAnd3Filters(),
                    if (hasActiveFilter) ...[
                      const SizedBox(height: 8),
                      _buildActiveFiltersChips(),
                    ],
                    const SizedBox(height: 18),
                    _buildInquiriesHeader(),
                    const SizedBox(height: 12),
                    if (filtered.isEmpty)
                      _buildEmptyState()
                    else
                      ...filtered.map((lead) => _buildLeadCard(lead)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: EmployeeBottomNav(
        currentIndex: 0,
        onTap: (i) => EmployeeHomeShell.goToTab(context, i),
      ),
    );
  }

  Widget _buildAttendanceStyleAppBar() {
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
          GestureDetector(
            onTap: () => _scaffoldKey.currentState?.openDrawer(),
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
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Digital Leads',
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
                  'Real-time Inbound Management',
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
          const SizedBox(width: 8),
          const TopNotificationButton(),
          const SizedBox(width: 12),
          const TopCalendarButton(),
        ],
      ),
    );
  }

  Widget _buildTotalLeadsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF1E1B4B),
            Color(0xFF2E1065),
            Color(0xFF312E81),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E1B4B).withValues(alpha: 0.25),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'TOTAL LEADS',
                style: portalText(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: Colors.white70,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '$_totalCount',
                    style: portalText(
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'all in a pipeline',
                    style: portalText(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                      color: Colors.white60,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.18),
                width: 1,
              ),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.all_inbox_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCardsGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildSleekStatCard(
                title: 'NEW',
                value: '$_newCount',
                caption: 'awaiting',
                cardColor: const Color(0xFFD97706),
                icon: Icons.fiber_new_rounded,
                badgeText: 'Action',
                badgeBg: const Color(0xFFFEF3C7),
                badgeColor: const Color(0xFFD97706),
                isSelected: _selectedStatusFilter == LeadStatus.newLead,
                onTap: () {
                  setState(() {
                    _selectedStatusFilter =
                        _selectedStatusFilter == LeadStatus.newLead
                            ? null
                            : LeadStatus.newLead;
                  });
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildSleekStatCard(
                title: 'CONTACTED',
                value: '$_contactedCount',
                caption: 'in progress',
                cardColor: PortalColors.brandLight,
                icon: Icons.phone_in_talk_rounded,
                isSelected: _selectedStatusFilter == LeadStatus.contacted,
                onTap: () {
                  setState(() {
                    _selectedStatusFilter =
                        _selectedStatusFilter == LeadStatus.contacted
                            ? null
                            : LeadStatus.contacted;
                  });
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildSleekStatCard(
                title: 'CONVERTED',
                value: '$_convertedCount',
                caption: 'won deals',
                cardColor: const Color(0xFF059669),
                icon: Icons.task_alt_rounded,
                isSelected: _selectedStatusFilter == LeadStatus.converted,
                onTap: () {
                  setState(() {
                    _selectedStatusFilter =
                        _selectedStatusFilter == LeadStatus.converted
                            ? null
                            : LeadStatus.converted;
                  });
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildSleekStatCard(
                title: 'REJECTED',
                value: '$_rejectedCount',
                caption: 'closed',
                cardColor: const Color(0xFFDC2626),
                icon: Icons.cancel_outlined,
                isSelected: _selectedStatusFilter == LeadStatus.rejected,
                onTap: () {
                  setState(() {
                    _selectedStatusFilter =
                        _selectedStatusFilter == LeadStatus.rejected
                            ? null
                            : LeadStatus.rejected;
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSleekStatCard({
    required String title,
    required String value,
    required String caption,
    required Color cardColor,
    required IconData icon,
    String? badgeText,
    Color? badgeBg,
    Color? badgeColor,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? cardColor.withValues(alpha: 0.08) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? cardColor : const Color(0xFFE2E8F0),
            width: isSelected ? 1.6 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? cardColor.withValues(alpha: 0.15)
                  : Colors.black.withValues(alpha: 0.02),
              blurRadius: isSelected ? 8 : 4,
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
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: cardColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  alignment: Alignment.center,
                  child: Icon(icon, size: 16, color: cardColor),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: portalText(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF334155),
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
                if (badgeText != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: badgeBg ?? const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      badgeText,
                      style: portalText(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        color: badgeColor ?? const Color(0xFFD97706),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  value,
                  style: portalText(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF0F172A),
                    height: 1.0,
                  ),
                ),
                Text(
                  caption,
                  style: portalText(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? cardColor : const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBarAnd3Filters() {
    final hasDate = _selectedDate != null;
    final hasMonth = _selectedMonth != 'All Months';
    final hasStatus = _selectedStatusFilter != null;

    final dateDisplay = hasDate
        ? '${_selectedDate!.day} ${_monthShort(_selectedDate!.month)}'
        : 'Date';
    final monthDisplay = hasMonth ? _selectedMonth : 'Month';
    final statusDisplay = hasStatus ? _selectedStatusFilter!.label : 'Status';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          alignment: Alignment.center,
          child: Row(
            children: [
              const Icon(Icons.search_rounded, size: 20, color: Color(0xFF64748B)),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val;
                    });
                  },
                  style: portalText(fontSize: 13, color: PortalColors.heading),
                  decoration: InputDecoration(
                    hintText: 'Search name, phone, email, business...',
                    hintStyle: portalText(
                      fontSize: 13,
                      color: const Color(0xFF94A3B8),
                    ),
                    isDense: true,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              if (_searchController.text.isNotEmpty)
                GestureDetector(
                  onTap: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                  child: const Icon(Icons.close_rounded, size: 18, color: Color(0xFF94A3B8)),
                ),
            ],
          ),
        ),

        const SizedBox(height: 10),

        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: _pickSingleDate,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 9),
                  decoration: BoxDecoration(
                    color: hasDate ? PortalColors.brandTint : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: hasDate ? PortalColors.brand : const Color(0xFFE2E8F0),
                      width: hasDate ? 1.4 : 1.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        size: 14,
                        color: hasDate ? PortalColors.brand : const Color(0xFF64748B),
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          dateDisplay,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: portalText(
                            fontSize: 12,
                            fontWeight: hasDate ? FontWeight.w700 : FontWeight.w600,
                            color: hasDate ? PortalColors.brand : const Color(0xFF334155),
                          ),
                        ),
                      ),
                      if (hasDate)
                        GestureDetector(
                          onTap: () {
                            setState(() => _selectedDate = null);
                          },
                          behavior: HitTestBehavior.opaque,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: PortalColors.brand.withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close_rounded,
                              size: 12,
                              color: PortalColors.brand,
                            ),
                          ),
                        )
                      else
                        const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 16,
                          color: Color(0xFF94A3B8),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),

            Expanded(
              child: PopupMenuButton<String>(
                offset: const Offset(0, 44),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                color: Colors.white,
                elevation: 4,
                onSelected: (val) {
                  setState(() {
                    _selectedMonth = val;
                  });
                },
                itemBuilder: (context) => _months.map((m) {
                  final isSelected = m == _selectedMonth;
                  return PopupMenuItem<String>(
                    value: m,
                    height: 38,
                    child: Text(
                      m,
                      style: portalText(
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected ? PortalColors.brand : const Color(0xFF334155),
                      ),
                    ),
                  );
                }).toList(),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 9),
                  decoration: BoxDecoration(
                    color: hasMonth ? PortalColors.brandTint : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: hasMonth ? PortalColors.brand : const Color(0xFFE2E8F0),
                      width: hasMonth ? 1.4 : 1.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_month_rounded,
                        size: 15,
                        color: hasMonth ? PortalColors.brand : const Color(0xFF64748B),
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          monthDisplay,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: portalText(
                            fontSize: 12,
                            fontWeight: hasMonth ? FontWeight.w700 : FontWeight.w600,
                            color: hasMonth ? PortalColors.brand : const Color(0xFF334155),
                          ),
                        ),
                      ),
                      if (hasMonth)
                        GestureDetector(
                          onTap: () {
                            setState(() => _selectedMonth = 'All Months');
                          },
                          behavior: HitTestBehavior.opaque,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: PortalColors.brand.withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close_rounded,
                              size: 12,
                              color: PortalColors.brand,
                            ),
                          ),
                        )
                      else
                        const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 16,
                          color: Color(0xFF94A3B8),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),

            Expanded(
              child: PopupMenuButton<String>(
                offset: const Offset(0, 44),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                color: Colors.white,
                elevation: 4,
                onSelected: (val) {
                  setState(() {
                    switch (val) {
                      case 'All':
                        _selectedStatusFilter = null;
                        break;
                      case 'New':
                        _selectedStatusFilter = LeadStatus.newLead;
                        break;
                      case 'Contacted':
                        _selectedStatusFilter = LeadStatus.contacted;
                        break;
                      case 'Converted':
                        _selectedStatusFilter = LeadStatus.converted;
                        break;
                      case 'Rejected':
                        _selectedStatusFilter = LeadStatus.rejected;
                        break;
                    }
                  });
                },
                itemBuilder: (context) {
                  const options = ['All', 'New', 'Contacted', 'Converted', 'Rejected'];
                  return options.map((opt) {
                    final bool isSelected = (opt == 'All' && _selectedStatusFilter == null) ||
                        (_selectedStatusFilter != null && _selectedStatusFilter!.label == opt);
                    return PopupMenuItem<String>(
                      value: opt,
                      height: 40,
                      child: Text(
                        opt,
                        style: portalText(
                          fontSize: 13.5,
                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                          color: isSelected ? PortalColors.brand : const Color(0xFF334155),
                        ),
                      ),
                    );
                  }).toList();
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 9),
                  decoration: BoxDecoration(
                    color: hasStatus ? PortalColors.brandTint : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: hasStatus ? PortalColors.brand : const Color(0xFFE2E8F0),
                      width: hasStatus ? 1.4 : 1.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.tune_rounded,
                        size: 15,
                        color: hasStatus ? PortalColors.brand : const Color(0xFF64748B),
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          statusDisplay,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: portalText(
                            fontSize: 12,
                            fontWeight: hasStatus ? FontWeight.w700 : FontWeight.w600,
                            color: hasStatus ? PortalColors.brand : const Color(0xFF334155),
                          ),
                        ),
                      ),
                      if (hasStatus)
                        GestureDetector(
                          onTap: () {
                            setState(() => _selectedStatusFilter = null);
                          },
                          behavior: HitTestBehavior.opaque,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: PortalColors.brand.withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close_rounded,
                              size: 12,
                              color: PortalColors.brand,
                            ),
                          ),
                        )
                      else
                        const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 16,
                          color: Color(0xFF94A3B8),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActiveFiltersChips() {
    return Row(
      children: [
        Text(
          'Active:',
          style: portalText(fontSize: 11, color: PortalColors.muted),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                if (_selectedStatusFilter != null)
                  _buildChip(
                    'Status: ${_selectedStatusFilter!.label}',
                    () => setState(() => _selectedStatusFilter = null),
                  ),
                if (_selectedDate != null)
                  _buildChip(
                    'Date: ${_selectedDate!.day} ${_monthShort(_selectedDate!.month)}',
                    () => setState(() => _selectedDate = null),
                  ),
                if (_selectedMonth != 'All Months')
                  _buildChip(
                    'Month: $_selectedMonth',
                    () => setState(() => _selectedMonth = 'All Months'),
                  ),
                if (_searchQuery.isNotEmpty)
                  _buildChip(
                    'Search: "$_searchQuery"',
                    () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                  ),
                GestureDetector(
                  onTap: _clearAllFilters,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Clear all',
                      style: portalText(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: PortalColors.brand,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChip(String label, VoidCallback onRemove) {
    return Container(
      margin: const EdgeInsets.only(right: 6),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: PortalColors.brandTint,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: PortalColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: portalText(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: PortalColors.brand,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(Icons.close, size: 12, color: PortalColors.brand),
          ),
        ],
      ),
    );
  }

  Widget _buildInquiriesHeader() {
    return Row(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: PortalColors.brandTint,
            borderRadius: BorderRadius.circular(9),
          ),
          alignment: Alignment.center,
          child: const Icon(
            Icons.mark_email_unread_outlined,
            size: 17,
            color: PortalColors.brand,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          'Inbound Inquiries',
          style: portalText(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF1E293B),
          ),
        ),
      ],
    );
  }

  Widget _buildLeadCard(DigitalLead lead) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: lead.avatarBgColor,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  lead.name.isNotEmpty ? lead.name[0].toUpperCase() : '?',
                  style: portalText(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 10),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lead.name,
                      style: portalText(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0F172A),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        if (lead.source == 'Meta') ...[
                          const Icon(Icons.circle_outlined, size: 12, color: PortalColors.brandLight),
                          const SizedBox(width: 3),
                          Text(
                            'Meta',
                            style: portalText(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: PortalColors.brandLight,
                            ),
                          ),
                        ] else if (lead.source == 'TIMELY HEALTH') ...[
                          const Icon(Icons.change_history_rounded, size: 12, color: Color(0xFF059669)),
                          const SizedBox(width: 3),
                          Text(
                            'TIMELY HEALTH',
                            style: portalText(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF059669),
                              letterSpacing: 0.3,
                            ),
                          ),
                        ] else ...[
                          Text(
                            lead.source,
                            style: portalText(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              PopupMenuButton<LeadStatus>(
                offset: const Offset(0, 36),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                color: Colors.white,
                elevation: 4,
                onSelected: (newStatus) => _onStatusChange(lead, newStatus),
                itemBuilder: (context) => LeadStatus.values.map((st) {
                  return PopupMenuItem<LeadStatus>(
                    value: st,
                    height: 38,
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: st.textColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          st.label,
                          style: portalText(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: st.textColor,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: lead.status.bgColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: lead.status.borderColor),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        lead.status.label,
                        style: portalText(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: lead.status.textColor,
                        ),
                      ),
                      const SizedBox(width: 2),
                      Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 14,
                        color: lead.status.textColor,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFF1F5F9)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'BUSINESS TYPE',
                        style: portalText(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF94A3B8),
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        lead.businessType,
                        style: portalText(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF334155),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'LOOKING FOR',
                        style: portalText(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF94A3B8),
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        lead.lookingFor,
                        style: portalText(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: PortalColors.brandLight,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          GestureDetector(
            onTap: () => _copyToClipboard(lead.phone, 'Phone number'),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  const Icon(Icons.phone_outlined, size: 13, color: PortalColors.brandLight),
                  const SizedBox(width: 8),
                  Text(
                    lead.phone,
                    style: portalText(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: PortalColors.brandLight,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 3),
          GestureDetector(
            onTap: () => _copyToClipboard(lead.email, 'Email address'),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  const Icon(Icons.email_outlined, size: 13, color: Color(0xFF64748B)),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      lead.email,
                      style: portalText(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF475569),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 10),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 8),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.access_time_rounded,
                    size: 13,
                    color: Color(0xFF94A3B8),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    lead.date,
                    style: portalText(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () => _copyToClipboard(lead.phone, 'Dialing number'),
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: const BoxDecoration(
                        color: Color(0xFFECFDF5),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.phone_outlined,
                        size: 14,
                        color: Color(0xFF059669),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),

                  GestureDetector(
                    onTap: () => _copyToClipboard(lead.email, 'Emailing address'),
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: const BoxDecoration(
                        color: PortalColors.brandTint,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.email_outlined,
                        size: 14,
                        color: PortalColors.brandLight,
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

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      alignment: Alignment.center,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              color: Color(0xFFF1F5F9),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.search_off_rounded,
              size: 28,
              color: Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'No leads found',
            style: portalText(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: PortalColors.heading,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Try adjusting your search or filters',
            style: portalText(
              fontSize: 12,
              color: PortalColors.muted,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _clearAllFilters,
            style: ElevatedButton.styleFrom(
              backgroundColor: PortalColors.brand,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: Text(
              'Reset Filters',
              style: portalText(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  static String _monthShort(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[(month - 1).clamp(0, 11)];
  }

  static String _monthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[(month - 1).clamp(0, 11)];
  }
}
