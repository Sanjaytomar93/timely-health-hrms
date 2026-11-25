import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:timelay_health/core/routes/app_routes.dart';
import 'package:timelay_health/core/theme/portal_colors.dart';
import 'package:timelay_health/core/theme/portal_system_ui.dart';
import 'package:timelay_health/core/theme/portal_text.dart';
import 'package:timelay_health/core/widgets/portal_safe_area.dart';
import 'package:timelay_health/features/dashboard/presentation/screens/employee_home_shell.dart';
import 'package:timelay_health/features/dashboard/presentation/widgets/employee_bottom_nav.dart';
import 'package:timelay_health/features/dashboard/presentation/widgets/home_side_drawer.dart';
import 'package:timelay_health/features/events/data/datasources/event_remote_datasource.dart';
import 'package:timelay_health/features/events/data/models/celebration_event_model.dart';
import 'package:timelay_health/features/notifications/presentation/widgets/top_notification_button.dart';

class AdminEventsScreen extends StatefulWidget {
  const AdminEventsScreen({super.key});

  @override
  State<AdminEventsScreen> createState() => _AdminEventsScreenState();
}

class _AdminEventsScreenState extends State<AdminEventsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();
  final _api = EventRemoteDataSource();

  List<CelebrationEvent> _allEvents = const [];
  CompanyEventStats _stats = CompanyEventStats.empty;
  bool _loading = true;
  String? _error;
  String _searchQuery = '';
  CelebrationType? _selectedTypeFilter;
  int? _selectedMonthIndex = DateTime.now().month; // 1-based (null = All Months)
  int _selectedYear = DateTime.now().year;

  final List<String> _monthNames = const [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String? get _monthQuery {
    if (_selectedMonthIndex == null) return null;
    final m = _selectedMonthIndex!.toString().padLeft(2, '0');
    return '$_selectedYear-$m';
  }

  Future<void> _load() async {
    setState(() {
      _loading = _allEvents.isEmpty;
      _error = null;
    });
    try {
      final result = await _api.getCompanyEventsByEmployee(month: _monthQuery);
      if (!mounted) return;
      setState(() {
        _allEvents = result.events;
        _stats = result.stats;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  List<CelebrationEvent> get _filteredEvents {
    return _allEvents.where((e) {
      if (_selectedTypeFilter != null && e.type != _selectedTypeFilter) {
        return false;
      }

      if (_searchQuery.trim().isNotEmpty) {
        final q = _searchQuery.trim().toLowerCase();
        final match = e.name.toLowerCase().contains(q) ||
            e.employeeCode.toLowerCase().contains(q) ||
            e.role.toLowerCase().contains(q) ||
            e.department.toLowerCase().contains(q);
        if (!match) return false;
      }

      return true;
    }).toList();
  }

  int get _totalCount => _stats.totalEvents;
  int get _birthdayCount => _stats.totalBirthdays;
  int get _anniversaryCount => _stats.totalAnniversaries;

  void _showWishDialog(CelebrationEvent event) {
    HapticFeedback.mediumImpact();
    final isBday = event.type == CelebrationType.birthday;
    final messageCtrl = TextEditingController(
      text: isBday
          ? 'Happy Birthday, ${event.name}! Wishing you great health, success and happiness! 🎂🎉'
          : 'Happy Work Anniversary, ${event.name}! Congratulations on ${event.anniversaryYears ?? 1} successful years at Timely Health! 🌟🎗️',
    );

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: EdgeInsets.fromLTRB(
          20,
          20,
          20,
          MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: event.avatarBg,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    event.initials,
                    style: portalText(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: event.avatarTextColor,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isBday
                            ? 'Wish ${event.name} 🎂'
                            : 'Celebrate ${event.name} 🎗️',
                        style: portalText(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${event.role} · ${event.department} (${event.employeeCode})',
                        style: portalText(
                          fontSize: 12,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              'Your Celebration Message:',
              style: portalText(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF475569),
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: messageCtrl,
              maxLines: 3,
              style: portalText(fontSize: 13, color: const Color(0xFF1E293B)),
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                    color: PortalColors.brand,
                    width: 1.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      side: const BorderSide(color: Color(0xFFCBD5E1)),
                    ),
                    onPressed: () => Navigator.pop(ctx),
                    child: Text(
                      'Cancel',
                      style: portalText(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isBday
                          ? const Color(0xFFE11D48)
                          : const Color(0xFFD97706),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Wishes sent to ${event.name}! 🎉',
                          ),
                          behavior: SnackBarBehavior.floating,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    child: Text(
                      'Send Wishes 🎉',
                      style: portalText(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Filter Events',
              style: portalText(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 14),
            ListTile(
              leading: const Icon(Icons.all_inclusive_rounded, color: PortalColors.brand),
              title: const Text('Show All Celebrations'),
              trailing: _selectedTypeFilter == null
                  ? const Icon(Icons.check_circle_rounded, color: PortalColors.brand)
                  : null,
              onTap: () {
                setState(() => _selectedTypeFilter = null);
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              leading: const Icon(Icons.cake_outlined, color: Color(0xFFE11D48)),
              title: const Text('Birthdays Only'),
              trailing: _selectedTypeFilter == CelebrationType.birthday
                  ? const Icon(Icons.check_circle_rounded, color: Color(0xFFE11D48))
                  : null,
              onTap: () {
                setState(() => _selectedTypeFilter = CelebrationType.birthday);
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              leading: const Icon(Icons.workspace_premium_outlined, color: Color(0xFFD97706)),
              title: const Text('Anniversaries Only'),
              trailing: _selectedTypeFilter == CelebrationType.anniversary
                  ? const Icon(Icons.check_circle_rounded, color: Color(0xFFD97706))
                  : null,
              onTap: () {
                setState(() => _selectedTypeFilter = CelebrationType.anniversary);
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredEvents;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: PortalSystemUi.darkStatusBar,
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: const Color(0xFFF8FAFC),
        drawer: const HomeSideDrawer(),
        drawerScrimColor: PortalColors.brand.withValues(alpha: 0.28),
        body: PortalSafeArea(
          bottom: false,
          statusBarColor: PortalColors.brand,
          child: Column(
            children: [
              _TopBar(
                onMenuTap: () => _scaffoldKey.currentState?.openDrawer(),
              ),
              Expanded(
                child: RefreshIndicator(
                  color: PortalColors.brand,
                  onRefresh: _load,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 32),
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      _buildTotalEventsCard(),
                      const SizedBox(height: 12),
                      _buildTwoStatCards(),
                      const SizedBox(height: 14),
                      _buildSearchBar(),
                      const SizedBox(height: 12),
                      _buildFilterPillsRow(),
                      const SizedBox(height: 18),
                      _buildUpcomingCelebrationsSectionHeader(),
                      const SizedBox(height: 12),
                      if (_loading)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 40),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: PortalColors.brand,
                              strokeWidth: 2.5,
                            ),
                          ),
                        )
                      else if (_error != null && _allEvents.isEmpty)
                        _buildErrorState(_error!)
                      else if (filtered.isEmpty)
                        _buildEmptyState()
                      else
                        ...filtered.map((event) => _buildCelebrationCard(event)),
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
      ),
    );
  }

  Widget _buildTotalEventsCard() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() {
          _selectedTypeFilter = null;
          _searchController.clear();
          _searchQuery = '';
        });
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1E143E), // Timely Health Brand Deep Purple
              Color(0xFF2B1A56),
              Color(0xFF38236E),
            ],
          ),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.12),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1E143E).withValues(alpha: 0.28),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Positioned(
              right: -25,
              top: -25,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.05),
                ),
              ),
            ),
            Positioned(
              left: 90,
              bottom: -35,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF818CF8).withValues(alpha: 0.08),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'TOTAL CELEBRATIONS',
                              style: portalText(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: Colors.white.withValues(alpha: 0.72),
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              '$_totalCount',
                              style: portalText(
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                height: 1.0,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'scheduled events',
                              style: portalText(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w500,
                                color: Colors.white.withValues(alpha: 0.75),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Text(
                              'tap to view all celebrations',
                              style: portalText(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFFC4B5FD),
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.arrow_forward_rounded,
                              size: 12,
                              color: Color(0xFFC4B5FD),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.18),
                        width: 1,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.celebration_rounded,
                      color: Color(0xFFFBBF24),
                      size: 26,
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

  Widget _buildTwoStatCards() {
    final isBdaySelected = _selectedTypeFilter == CelebrationType.birthday;
    final isAnnivSelected = _selectedTypeFilter == CelebrationType.anniversary;

    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              setState(() {
                _selectedTypeFilter =
                    isBdaySelected ? null : CelebrationType.birthday;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: isBdaySelected ? const Color(0xFFFFF1F2) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isBdaySelected
                      ? const Color(0xFFE11D48)
                      : const Color(0xFFE2E8F0),
                  width: isBdaySelected ? 1.4 : 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'BIRTHDAYS',
                        style: portalText(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF64748B),
                          letterSpacing: 0.5,
                        ),
                      ),
                      Container(
                        width: 24,
                        height: 24,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFFF1F2),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.cake_outlined,
                          size: 13,
                          color: Color(0xFFE11D48),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '$_birthdayCount',
                    style: portalText(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isBdaySelected ? 'filtering ✓' : 'tap to filter ›',
                    style: portalText(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFE11D48),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),

        Expanded(
          child: GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              setState(() {
                _selectedTypeFilter =
                    isAnnivSelected ? null : CelebrationType.anniversary;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: isAnnivSelected ? const Color(0xFFFEF3C7) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isAnnivSelected
                      ? const Color(0xFFD97706)
                      : const Color(0xFFE2E8F0),
                  width: isAnnivSelected ? 1.4 : 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'ANNIVERSARIES',
                        style: portalText(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF64748B),
                          letterSpacing: 0.5,
                        ),
                      ),
                      Container(
                        width: 24,
                        height: 24,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFEF3C7),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.calendar_month_outlined,
                          size: 13,
                          color: Color(0xFFD97706),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '$_anniversaryCount',
                    style: portalText(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isAnnivSelected ? 'filtering ✓' : 'tap to filter ›',
                    style: portalText(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFD97706),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
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
          const Icon(
            Icons.search_rounded,
            size: 20,
            color: Color(0xFF94A3B8),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (val) {
                setState(() => _searchQuery = val);
              },
              style: portalText(
                fontSize: 13,
                color: const Color(0xFF0F172A),
              ),
              decoration: InputDecoration(
                hintText: 'Search by name, ID or department...',
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
              child: const Icon(
                Icons.close_rounded,
                size: 18,
                color: Color(0xFF94A3B8),
              ),
            ),
        ],
      ),
    );
  }

  void _showMonthPickerSheet() {
    HapticFeedback.lightImpact();
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Select Month',
                        style: portalText(
                          fontSize: 16.5,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Filter celebrations by month',
                        style: portalText(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(ctx),
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF1F5F9),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        size: 16,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              InkWell(
                onTap: () {
                  setState(() => _selectedMonthIndex = null);
                  Navigator.pop(ctx);
                  _load();
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: _selectedMonthIndex == null
                        ? PortalColors.brandTint
                        : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _selectedMonthIndex == null
                          ? PortalColors.brand
                          : const Color(0xFFE2E8F0),
                      width: _selectedMonthIndex == null ? 1.5 : 1.0,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.all_inclusive_rounded,
                        size: 16,
                        color: _selectedMonthIndex == null
                            ? PortalColors.brand
                            : const Color(0xFF64748B),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'All Months',
                        style: portalText(
                          fontSize: 13,
                          fontWeight: _selectedMonthIndex == null
                              ? FontWeight.w700
                              : FontWeight.w600,
                          color: _selectedMonthIndex == null
                              ? PortalColors.brand
                              : const Color(0xFF1E293B),
                        ),
                      ),
                      const Spacer(),
                      if (_selectedMonthIndex == null)
                        const Icon(
                          Icons.check_circle_rounded,
                          size: 17,
                          color: PortalColors.brand,
                        ),
                    ],
                  ),
                ),
              ),

              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 2.3,
                ),
                itemCount: 12,
                itemBuilder: (ctx, i) {
                  final monthNum = i + 1;
                  final name = _monthNames[i];
                  final isSelected = _selectedMonthIndex == monthNum;

                  return InkWell(
                    onTap: () {
                      setState(() => _selectedMonthIndex = monthNum);
                      Navigator.pop(ctx);
                      _load();
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? PortalColors.brandTint
                            : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? PortalColors.brand
                              : const Color(0xFFE2E8F0),
                          width: isSelected ? 1.5 : 1.0,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.calendar_today_rounded,
                            size: 12,
                            color: isSelected
                                ? PortalColors.brand
                                : const Color(0xFF64748B),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            name,
                            style: portalText(
                              fontSize: 12.5,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w600,
                              color: isSelected
                                  ? PortalColors.brand
                                  : const Color(0xFF1E293B),
                            ),
                          ),
                          if (isSelected) ...[
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.check_circle_rounded,
                              size: 14,
                              color: PortalColors.brand,
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 1. Month Calendar | 2. All | 3. Birthday | 4. Anniversary
  Widget _buildFilterPillsRow() {
    final isAllSelected = _selectedTypeFilter == null;
    final isBdaySelected = _selectedTypeFilter == CelebrationType.birthday;
    final isAnnivSelected = _selectedTypeFilter == CelebrationType.anniversary;

    final monthLabel = _selectedMonthIndex == null
        ? 'All'
        : '${_monthNames[_selectedMonthIndex! - 1]} \'${_selectedYear.toString().substring(2)}';

    return Row(
      children: [
        Expanded(
          flex: 11,
          child: GestureDetector(
            onTap: _showMonthPickerSheet,
            child: Container(
              height: 34,
              padding: const EdgeInsets.symmetric(horizontal: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: _selectedMonthIndex != null
                      ? PortalColors.brand
                      : const Color(0xFFCBD5E1),
                  width: _selectedMonthIndex != null ? 1.3 : 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.calendar_month_rounded,
                    size: 13,
                    color: PortalColors.brand,
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      monthLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: portalText(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.arrow_drop_down_rounded,
                    size: 16,
                    color: Color(0xFF64748B),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 6),

        Expanded(
          flex: 7,
          child: GestureDetector(
            onTap: () => setState(() => _selectedTypeFilter = null),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              height: 34,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: isAllSelected
                    ? const Color(0xFF1E143E)
                    : Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isAllSelected
                      ? const Color(0xFF1E143E)
                      : const Color(0xFFCBD5E1),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'All',
                    style: portalText(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: isAllSelected ? Colors.white : const Color(0xFF334155),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: isAllSelected
                          ? Colors.white.withValues(alpha: 0.22)
                          : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '$_totalCount',
                      style: portalText(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        color: isAllSelected
                            ? Colors.white
                            : const Color(0xFF64748B),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 6),

        Expanded(
          flex: 9,
          child: GestureDetector(
            onTap: () {
              setState(() {
                _selectedTypeFilter =
                    isBdaySelected ? null : CelebrationType.birthday;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              height: 34,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: isBdaySelected
                    ? const Color(0xFFE11D48)
                    : const Color(0xFFFFF1F2),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isBdaySelected
                      ? const Color(0xFFE11D48)
                      : const Color(0xFFFFE4E6),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('🎂', style: TextStyle(fontSize: 10)),
                  const SizedBox(width: 3),
                  Text(
                    'Bday',
                    style: portalText(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: isBdaySelected ? Colors.white : const Color(0xFFE11D48),
                    ),
                  ),
                  const SizedBox(width: 3),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: isBdaySelected
                          ? Colors.white.withValues(alpha: 0.24)
                          : const Color(0xFFFFE4E6),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '$_birthdayCount',
                      style: portalText(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        color: isBdaySelected
                            ? Colors.white
                            : const Color(0xFFE11D48),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 6),

        Expanded(
          flex: 9,
          child: GestureDetector(
            onTap: () {
              setState(() {
                _selectedTypeFilter =
                    isAnnivSelected ? null : CelebrationType.anniversary;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              height: 34,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: isAnnivSelected
                    ? const Color(0xFFD97706)
                    : const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isAnnivSelected
                      ? const Color(0xFFD97706)
                      : const Color(0xFFFDE68A),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('🎗️', style: TextStyle(fontSize: 10)),
                  const SizedBox(width: 3),
                  Text(
                    'Anniv',
                    style: portalText(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: isAnnivSelected ? Colors.white : const Color(0xFFB45309),
                    ),
                  ),
                  const SizedBox(width: 3),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: isAnnivSelected
                          ? Colors.white.withValues(alpha: 0.24)
                          : const Color(0xFFFDE68A),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '$_anniversaryCount',
                      style: portalText(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        color: isAnnivSelected
                            ? Colors.white
                            : const Color(0xFFB45309),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUpcomingCelebrationsSectionHeader() {
    return Row(
      children: [
        const Icon(
          Icons.celebration_outlined,
          size: 16,
          color: Color(0xFF64748B),
        ),
        const SizedBox(width: 6),
        Text(
          'UPCOMING CELEBRATIONS',
          style: portalText(
            fontSize: 11.5,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF64748B),
            letterSpacing: 0.6,
          ),
        ),
      ],
    );
  }

  Widget _buildCelebrationCard(CelebrationEvent event) {
    final isBday = event.type == CelebrationType.birthday;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: event.avatarBg,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            event.initials,
                            style: portalText(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: event.avatarTextColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      event.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: portalText(
                                        fontSize: 14.5,
                                        fontWeight: FontWeight.w800,
                                        color: const Color(0xFF0F172A),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF1F5F9),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      event.employeeCode,
                                      style: portalText(
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF64748B),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 3),
                              Row(
                                children: [
                                  Icon(
                                    event.role.toLowerCase().contains('developer')
                                        ? Icons.code_rounded
                                        : Icons.business_center_outlined,
                                    size: 13,
                                    color: const Color(0xFF94A3B8),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    event.role,
                                    style: portalText(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 3.5,
                          ),
                          decoration: BoxDecoration(
                            color: isBday
                                ? const Color(0xFFEDE9FE)
                                : const Color(0xFFD1FAE5),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isBday
                                  ? const Color(0xFFC4B5FD)
                                  : const Color(0xFF6EE7B7),
                              width: 0.8,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 5,
                                height: 5,
                                decoration: BoxDecoration(
                                  color: isBday
                                      ? const Color(0xFF7C3AED)
                                      : const Color(0xFF047857),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 4.5),
                              Text(
                                isBday
                                    ? 'BIRTHDAY'
                                    : '${event.anniversaryYears ?? 1} ${event.anniversaryYears == 1 ? "YR" : "YRS"} ANNIV',
                                style: portalText(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: isBday
                                      ? const Color(0xFF7C3AED)
                                      : const Color(0xFF047857),
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_outlined,
                          size: 13,
                          color: Color(0xFF64748B),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          event.formattedDate,
                          style: portalText(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF334155),
                          ),
                        ),
                        const SizedBox(width: 10),

                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: isBday
                                ? const Color(0xFFF1F5F9)
                                : const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.access_time_rounded,
                                size: 11,
                                color: isBday
                                    ? const Color(0xFF64748B)
                                    : const Color(0xFFB45309),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                event.relativeDaysText,
                                style: portalText(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                  color: isBday
                                      ? const Color(0xFF475569)
                                      : const Color(0xFFB45309),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const Spacer(),

                        Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: isBday
                                  ? const Color(0xFFE11D48)
                                  : const Color(0xFFF59E0B),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: (isBday
                                          ? const Color(0xFFE11D48)
                                          : const Color(0xFFF59E0B))
                                      .withValues(alpha: 0.35),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: Icon(
                              isBday
                                  ? Icons.cake_rounded
                                  : Icons.auto_awesome_rounded,
                              size: 18,
                              color: Colors.white,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            );
  }

  Widget _buildErrorState(String message) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      alignment: Alignment.center,
      child: Column(
        children: [
          const Icon(Icons.cloud_off_rounded, size: 36, color: Color(0xFFE11D48)),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: portalText(fontSize: 12.5, color: const Color(0xFF64748B)),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _load,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Retry'),
            style: OutlinedButton.styleFrom(
              foregroundColor: PortalColors.brand,
              side: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      alignment: Alignment.center,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: const BoxDecoration(
              color: Color(0xFFF1F5F9),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.event_busy_rounded,
              size: 28,
              color: Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'No upcoming celebrations found',
            style: portalText(
              fontSize: 14.5,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF334155),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Try adjusting your search or filter options',
            style: portalText(
              fontSize: 12,
              color: const Color(0xFF94A3B8),
            ),
          ),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.onMenuTap});

  final VoidCallback onMenuTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: PortalColors.brand,
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 14),
      child: Row(
        children: [
          GestureDetector(
            onTap: onMenuTap,
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: 34,
              height: 34,
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
                  'Upcoming Events',
                  style: portalText(
                    fontSize: 16.5,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Celebrating birthdays & work anniversaries',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: portalText(
                    fontSize: 11.5,
                    color: Colors.white.withValues(alpha: 0.72),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const TopNotificationButton(),
        ],
      ),
    );
  }
}
