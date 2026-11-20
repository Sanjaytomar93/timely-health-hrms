import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:timelay_health/core/theme/portal_colors.dart';
import 'package:timelay_health/core/theme/portal_text.dart';
import 'package:timelay_health/core/widgets/portal_safe_area.dart';
import 'package:timelay_health/features/dashboard/presentation/widgets/home_side_drawer.dart';
import 'package:timelay_health/features/notifications/presentation/widgets/top_notification_button.dart';
import 'package:timelay_health/features/op/dashboard/presentation/theme/op_colors.dart';
import 'package:timelay_health/features/op/walkin/presentation/models/op_inactive_patient_ui.dart';

class OpInactivePatientsScreen extends StatefulWidget {
  const OpInactivePatientsScreen({super.key, this.onMenuTap});

  final VoidCallback? onMenuTap;

  @override
  State<OpInactivePatientsScreen> createState() =>
      _OpInactivePatientsScreenState();
}

class _OpInactivePatientsScreenState extends State<OpInactivePatientsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();

  late List<OpInactivePatientUi> _allPatients;
  String _searchQuery = '';
  String _selectedPayment = 'All Payment';
  String _selectedDoctor = 'All Doctors';
  String _selectedGender = 'All Genders';
  int _navIndex = 0;

  static const Color _brandNavy = Color(0xFF1E1938);
  static const Color _brandDark = Color(0xFF26204A);
  static const Color _iconCircleBg = Color(0xFF2E295E);
  static const Color _badgePurple = Color(0xFF3B356D);
  static const Color _activateGreen = Color(0xFF10B981);
  static const Color _doctorPurple = Color(0xFF7C3AED);
  static const Color _timeBlue = Color(0xFF2563EB);

  @override
  void initState() {
    super.initState();
    _allPatients = List.of(OpInactivePatientUi.demoPatients);
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<OpInactivePatientUi> get _filteredPatients {
    return _allPatients.where((p) {
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final matches = p.name.toLowerCase().contains(q) ||
            p.phone.contains(q) ||
            p.doctor.toLowerCase().contains(q);
        if (!matches) return false;
      }
      if (_selectedPayment == 'Paid' && !p.isPaid) return false;
      if (_selectedPayment == 'Due' && !p.isDue) return false;

      if (_selectedDoctor != 'All Doctors') {
        if (_selectedDoctor == 'N/A' && p.doctor != 'N/A') return false;
        if (_selectedDoctor != 'N/A' &&
            !p.doctor.toLowerCase().contains(_selectedDoctor.toLowerCase())) {
          return false;
        }
      }

      if (_selectedGender != 'All Genders') {
        if (p.gender.toLowerCase() != _selectedGender.toLowerCase()) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  int get _paidCount => _allPatients.where((p) => p.isPaid).length;
  int get _partialCount => _allPatients.where((p) => p.isPartial).length;
  int get _totalInactive => _allPatients.length;

  void _activatePatient(OpInactivePatientUi patient) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Activate Patient',
          style: portalText(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF0F172A),
          ),
        ),
        content: Text(
          'Do you want to re-activate ${patient.name}\'s account and move them to active queue?',
          style: portalText(
            fontSize: 13,
            color: const Color(0xFF475569),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Cancel',
              style: portalText(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF64748B),
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _activateGreen,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              setState(() {
                _allPatients.removeWhere((p) => p.id == patient.id);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '${patient.name} has been re-activated successfully',
                    style: portalText(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  backgroundColor: _activateGreen,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            },
            child: Text(
              'Activate',
              style: portalText(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _viewPatientDetails(OpInactivePatientUi patient) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        margin: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Color(0x26000000),
              blurRadius: 20,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(20),
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
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: Color(0xFF334155),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        patient.initial,
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
                            patient.name,
                            style: portalText(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                          Text(
                            '${patient.age} yrs • ${patient.gender}',
                            style: portalText(
                              fontSize: 12,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    _StatusBadge(status: patient.paymentStatus),
                  ],
                ),
                const Divider(height: 28),
                _detailRow('Phone', patient.phone),
                _detailRow('Doctor', patient.doctor),
                _detailRow('Last Visit Date', patient.lastVisitDate),
                if (patient.lastVisitTime != null)
                  _detailRow('Last Visit Slot', patient.lastVisitTime!),
                _detailRow('Deactivated Since', patient.deactivatedSince),
                _detailRow('City', patient.city),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _activateGreen,
                      side: const BorderSide(color: _activateGreen, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                      _activatePatient(patient);
                    },
                    icon: Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: _activateGreen,
                        shape: BoxShape.circle,
                      ),
                    ),
                    label: Text(
                      'ACTIVATE PATIENT',
                      style: portalText(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: _activateGreen,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: portalText(
              fontSize: 12,
              color: const Color(0xFF94A3B8),
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            value,
            style: portalText(
              fontSize: 12,
              color: const Color(0xFF0F172A),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  void _exportCsv() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Exporting inactive patients CSV...',
          style: portalText(fontSize: 13, color: Colors.white),
        ),
        backgroundColor: _brandNavy,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _pickDate() async {
    final now = DateTime.now();
    await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: _brandDark,
              onPrimary: Colors.white,
              onSurface: Color(0xFF0F172A),
            ),
          ),
          child: child!,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredPatients;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: const Color(0xFFF8FAFC),
        drawer: const HomeSideDrawer(),
        drawerScrimColor: PortalColors.brand.withValues(alpha: 0.28),
        body: PortalSafeArea(
          bottom: false,
          statusBarColor: _brandNavy,
          child: Column(
            children: [
              _buildTopBar(),
              Expanded(
                child: RefreshIndicator(
                  color: _brandNavy,
                  onRefresh: () async {
                    setState(() {
                      _allPatients = List.of(OpInactivePatientUi.demoPatients);
                      _searchQuery = '';
                      _searchController.clear();
                      _selectedPayment = 'All Payment';
                      _selectedDoctor = 'All Doctors';
                      _selectedGender = 'All Genders';
                    });
                  },
                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      SliverToBoxAdapter(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSegmentedTab(),
                            _buildStatsRow(),
                            const SizedBox(height: 14),
                            _buildSearchAndExportRow(),
                            const SizedBox(height: 10),
                            _buildFilterChipsRow(),
                            const SizedBox(height: 14),
                            _buildSectionHeader(filtered.length),
                          ],
                        ),
                      ),
                      if (filtered.isEmpty)
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.person_off_outlined,
                                    size: 48,
                                    color: const Color(0xFF94A3B8),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'No inactive patients match the filters',
                                    textAlign: TextAlign.center,
                                    style: portalText(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      else
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(14, 0, 14, 24),
                          sliver: SliverList.separated(
                            itemCount: filtered.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, i) => _InactivePatientCard(
                              patient: filtered[i],
                              onActivate: () => _activatePatient(filtered[i]),
                              onView: () => _viewPatientDetails(filtered[i]),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: _buildBottomNav(),
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      color: _brandNavy,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
      child: Row(
        children: [
          // Menu button
          GestureDetector(
            onTap: () {
              if (widget.onMenuTap != null) {
                widget.onMenuTap!();
              } else {
                _scaffoldKey.currentState?.openDrawer();
              }
            },
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: 38,
              height: 38,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: _iconCircleBg,
                shape: BoxShape.circle,
              ),
              child: SvgPicture.asset(
                'assets/icons/top_bar/ic_top_menu.svg',
                width: 18,
                height: 18,
                colorFilter: const ColorFilter.mode(
                  Colors.white,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Title & subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      'Inactive Patients',
                      style: portalText(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 20,
                      height: 20,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: _badgePurple,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '$_totalInactive',
                        style: portalText(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'Manage deactivated patient accounts',
                  style: portalText(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFFA5B4FC),
                  ),
                ),
              ],
            ),
          ),
          // Bell notification button
          GestureDetector(
            onTap: () => openNotificationsScreen(context),
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: 38,
              height: 38,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: _iconCircleBg,
                shape: BoxShape.circle,
              ),
              child: SvgPicture.asset(
                'assets/icons/top_bar/ic_top_notification.svg',
                width: 19,
                height: 19,
                colorFilter: const ColorFilter.mode(
                  Colors.white,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentedTab() {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
              },
              behavior: HitTestBehavior.opaque,
              child: Container(
                height: 38,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Active Patients',
                  style: portalText(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF475569),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              height: 38,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: _brandNavy,
                borderRadius: BorderRadius.circular(10),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x1F000000),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Inactive Patients',
                    style: portalText(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: _badgePurple,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$_totalInactive',
                      style: portalText(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
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

  Widget _buildStatsRow() {
    return SizedBox(
      height: 94,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        children: [
          _StatCard(
            title: 'TOTAL INACTIVE',
            titleColor: const Color(0xFFF59E0B),
            icon: Icons.person_off_rounded,
            value: '$_totalInactive',
            subtitle: 'deactivated patients',
          ),
          const SizedBox(width: 10),
          _StatCard(
            title: 'PAID',
            titleColor: _activateGreen,
            icon: Icons.check_circle_outline_rounded,
            value: '$_paidCount',
            subtitle: 'completed payments',
          ),
          const SizedBox(width: 10),
          _StatCard(
            title: 'PARTIAL',
            titleColor: const Color(0xFF0EA5E9),
            icon: Icons.pie_chart_outline_rounded,
            value: '$_partialCount',
            subtitle: 'partially paid',
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndExportRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 42,
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
                    size: 18,
                    color: Color(0xFF94A3B8),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      style: portalText(
                        fontSize: 12,
                        color: const Color(0xFF0F172A),
                        fontWeight: FontWeight.w600,
                      ),
                      textAlignVertical: TextAlignVertical.center,
                      decoration: InputDecoration(
                        hintText: 'Search inactive patients...',
                        hintStyle: portalText(
                          fontSize: 12,
                          color: const Color(0xFF94A3B8),
                          fontWeight: FontWeight.w500,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  if (_searchQuery.isNotEmpty)
                    GestureDetector(
                      onTap: () => _searchController.clear(),
                      child: const Icon(
                        Icons.close_rounded,
                        size: 16,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          Material(
            color: _brandNavy,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              onTap: _exportCsv,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                height: 42,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                alignment: Alignment.center,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.file_download_outlined,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Export CSV',
                      style: portalText(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
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

  Widget _buildFilterChipsRow() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          // Refresh Button
          _FilterIconButton(
            icon: Icons.refresh_rounded,
            onTap: () {
              setState(() {
                _selectedPayment = 'All Payment';
                _selectedDoctor = 'All Doctors';
                _selectedGender = 'All Genders';
                _searchController.clear();
              });
            },
          ),
          const SizedBox(width: 8),
          // Payment Dropdown
          _DropdownChip(
            label: _selectedPayment,
            options: const ['All Payment', 'Paid', 'Due'],
            onSelected: (val) => setState(() => _selectedPayment = val),
          ),
          const SizedBox(width: 8),
          // Doctors Dropdown
          _DropdownChip(
            label: _selectedDoctor,
            options: const [
              'All Doctors',
              'DR VAMSHI KRISHNA',
              'Dr Abhigna jupaka',
              'N/A',
            ],
            onSelected: (val) => setState(() => _selectedDoctor = val),
          ),
          const SizedBox(width: 8),
          // Gender Dropdown
          _DropdownChip(
            label: _selectedGender,
            options: const ['All Genders', 'Male', 'Female'],
            onSelected: (val) => setState(() => _selectedGender = val),
          ),
          const SizedBox(width: 8),
          // Calendar Picker Button
          _FilterIconButton(
            icon: Icons.calendar_today_outlined,
            onTap: _pickDate,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          Text(
            'PATIENT LIST ($count)',
            style: portalText(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1E293B),
              letterSpacing: 0.2,
            ),
          ),
          const Spacer(),
          Text(
            'Sorted by recent visit',
            style: portalText(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF94A3B8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFF1F5F9))),
        boxShadow: [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              Expanded(
                child: _BottomNavItem(
                  icon: Icons.groups_outlined,
                  label: 'Patients',
                  badge: '$_totalInactive',
                  selected: _navIndex == 0,
                  activeColor: const Color(0xFFE11D48),
                  onTap: () => setState(() => _navIndex = 0),
                ),
              ),
              Expanded(
                child: _BottomNavItem(
                  icon: Icons.alt_route_rounded,
                  label: 'Referrals',
                  selected: _navIndex == 1,
                  onTap: () => setState(() => _navIndex = 1),
                ),
              ),
              Expanded(
                child: _BottomNavItem(
                  icon: Icons.healing_outlined,
                  label: 'Doctors',
                  selected: _navIndex == 2,
                  onTap: () => setState(() => _navIndex = 2),
                ),
              ),
              Expanded(
                child: _BottomNavItem(
                  icon: Icons.bar_chart_rounded,
                  label: 'Reports',
                  selected: _navIndex == 3,
                  onTap: () => setState(() => _navIndex = 3),
                ),
              ),
              Expanded(
                child: _BottomNavItem(
                  icon: Icons.settings_outlined,
                  label: 'Settings',
                  selected: _navIndex == 4,
                  onTap: () => setState(() => _navIndex = 4),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.titleColor,
    required this.icon,
    required this.value,
    required this.subtitle,
  });

  final String title;
  final Color titleColor;
  final IconData icon;
  final String value;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 135,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 8,
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
              Text(
                title,
                style: portalText(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: titleColor,
                  letterSpacing: 0.3,
                ),
              ),
              const Spacer(),
              Icon(icon, size: 15, color: titleColor),
            ],
          ),
          Text(
            value,
            style: portalText(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF0F172A),
              height: 1.1,
            ),
          ),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: portalText(
              fontSize: 10,
              color: const Color(0xFF94A3B8),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterIconButton extends StatelessWidget {
  const _FilterIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Icon(icon, size: 17, color: const Color(0xFF475569)),
        ),
      ),
    );
  }
}

class _DropdownChip extends StatelessWidget {
  const _DropdownChip({
    required this.label,
    required this.options,
    required this.onSelected,
  });

  final String label;
  final List<String> options;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: onSelected,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      itemBuilder: (ctx) => options.map((opt) {
        return PopupMenuItem<String>(
          value: opt,
          child: Text(
            opt,
            style: portalText(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: opt == label
                  ? OpColors.primary
                  : const Color(0xFF0F172A),
            ),
          ),
        );
      }).toList(),
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: portalText(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF334155),
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 16,
              color: Color(0xFF64748B),
            ),
          ],
        ),
      ),
    );
  }
}

class _InactivePatientCard extends StatelessWidget {
  const _InactivePatientCard({
    required this.patient,
    required this.onActivate,
    required this.onView,
  });

  final OpInactivePatientUi patient;
  final VoidCallback onActivate;
  final VoidCallback onView;

  static const Color _activateGreen = Color(0xFF10B981);
  static const Color _doctorPurple = Color(0xFF7C3AED);
  static const Color _timeBlue = Color(0xFF2563EB);

  @override
  Widget build(BuildContext context) {
    final p = patient;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Avatar, Name, Age/Gender, Payment Status Pill
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: Color(0xFF334155),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  p.initial,
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
                      p.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: portalText(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      '${p.age} yrs • ${p.gender}',
                      style: portalText(
                        fontSize: 11,
                        color: const Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              _StatusBadge(status: p.paymentStatus),
            ],
          ),
          const SizedBox(height: 14),

          // Two-column layout
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Column 1: PHONE & LAST VISIT
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PHONE',
                      style: portalText(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF94A3B8),
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        const Icon(
                          Icons.call_outlined,
                          size: 13,
                          color: Color(0xFF94A3B8),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          p.phone,
                          style: portalText(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'LAST VISIT',
                      style: portalText(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF94A3B8),
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      p.lastVisitDate,
                      style: portalText(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    if (p.lastVisitTime != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        p.lastVisitTime!,
                        style: portalText(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: _timeBlue,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(width: 14),

              // Column 2: DOCTOR & DEACTIVATED SINCE
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'DOCTOR',
                      style: portalText(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF94A3B8),
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      p.doctor,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: portalText(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: p.doctor == 'N/A'
                            ? const Color(0xFF7C3AED)
                            : _doctorPurple,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'DEACTIVATED SINCE',
                      style: portalText(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF94A3B8),
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      p.deactivatedSince,
                      style: portalText(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Bottom Row: City, View icon button, ACTIVATE button
          Row(
            children: [
              Text(
                'City: ${p.city}',
                style: portalText(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF94A3B8),
                ),
              ),
              const Spacer(),
              // View details icon
              Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                child: InkWell(
                  onTap: onView,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: 32,
                    height: 32,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: const Icon(
                      Icons.remove_red_eye_outlined,
                      size: 16,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Activate pill button
              Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                child: InkWell(
                  onTap: onActivate,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    height: 32,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _activateGreen,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: _activateGreen,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'ACTIVATE',
                          style: portalText(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            color: _activateGreen,
                            letterSpacing: 0.5,
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
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final isDue = status.toUpperCase() == 'DUE';
    final isPaid = status.toUpperCase() == 'PAID';

    final Color bgColor = isDue
        ? const Color(0xFFFEF2F2)
        : isPaid
            ? const Color(0xFFECFDF5)
            : const Color(0xFFEFF6FF);

    final Color borderColor = isDue
        ? const Color(0xFFFECACA)
        : isPaid
            ? const Color(0xFFA7F3D0)
            : const Color(0xFFBFDBFE);

    final Color textColor = isDue
        ? const Color(0xFFEF4444)
        : isPaid
            ? const Color(0xFF10B981)
            : const Color(0xFF3B82F6);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor),
      ),
      child: Text(
        status.toUpperCase(),
        style: portalText(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: textColor,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  const _BottomNavItem({
    required this.icon,
    required this.label,
    this.badge,
    required this.selected,
    this.activeColor,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String? badge;
  final bool selected;
  final Color? activeColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final effectiveColor =
        selected ? (activeColor ?? const Color(0xFFE11D48)) : const Color(0xFF94A3B8);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(
                icon,
                size: 24,
                color: effectiveColor,
              ),
              if (badge != null)
                Positioned(
                  top: -4,
                  right: -7,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE11D48),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      badge!,
                      style: portalText(
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        height: 1,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: portalText(
              fontSize: 10,
              fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
              color: effectiveColor,
            ),
          ),
        ],
      ),
    );
  }
}
