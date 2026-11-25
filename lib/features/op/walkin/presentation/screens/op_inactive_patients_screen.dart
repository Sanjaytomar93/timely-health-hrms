import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:timelay_health/core/theme/portal_colors.dart';
import 'package:timelay_health/core/theme/portal_text.dart';
import 'package:timelay_health/core/widgets/portal_back_button.dart';
import 'package:timelay_health/core/widgets/portal_safe_area.dart';
import 'package:timelay_health/features/dashboard/presentation/widgets/home_side_drawer.dart';
import 'package:timelay_health/features/notifications/presentation/widgets/top_notification_button.dart';
import 'package:timelay_health/features/dashboard/presentation/screens/employee_home_shell.dart';
import 'package:timelay_health/features/dashboard/presentation/widgets/employee_bottom_nav.dart';
import 'package:timelay_health/features/op/dashboard/presentation/theme/op_colors.dart';
import 'package:timelay_health/features/op/walkin/data/datasources/op_walkin_remote_datasource.dart';
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
  final OpWalkinRemoteDataSource _dataSource = OpWalkinRemoteDataSource();

  late List<OpInactivePatientUi> _allPatients;
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';
  DateTime? _selectedDate;
  String _selectedPayment = 'All Payment';
  String _selectedDoctor = 'All Doctors';
  String _selectedGender = 'All Genders';

  static const Color _brandNavy = Color(0xFF1E1938);
  static const Color _brandDark = Color(0xFF26204A);
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
    _fetchInactiveBookings();
  }

  Future<void> _fetchInactiveBookings({bool isRefresh = false}) async {
    if (!isRefresh) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }
    try {
      final list = await _dataSource.getInactiveBookings();
      if (mounted) {
        setState(() {
          _allPatients = list;
          _isLoading = false;
          _errorMessage = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          if (_allPatients.isEmpty) {
            _allPatients = List.of(OpInactivePatientUi.demoPatients);
          }
          _isLoading = false;
        });
      }
    }
  }

  List<String> get _doctorOptions {
    final docs = _allPatients
        .map((p) => p.doctor.trim())
        .where((d) => d.isNotEmpty && d != 'N/A')
        .toSet()
        .toList();
    docs.sort();
    return ['All Doctors', ...docs, 'N/A'];
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
      if (_selectedDate != null) {
        final dStr =
            '${_selectedDate!.day.toString().padLeft(2, '0')}/${_selectedDate!.month.toString().padLeft(2, '0')}/${_selectedDate!.year}';
        final matchesDate = p.lastVisitDate.contains(dStr) ||
            p.deactivatedSince.contains(dStr);
        if (!matchesDate) return false;
      }
      if (_selectedPayment == 'Paid' && !p.isPaid) return false;
      if (_selectedPayment == 'Due' && !p.isDue) return false;
      if (_selectedPayment == 'Partial' && !p.isPartial) return false;
      if (_selectedPayment == 'Pending' && !p.isPending) return false;

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
  int get _pendingCount => _allPatients.where((p) => p.isPending).length;
  int get _dueCount => _allPatients.where((p) => p.isDue).length;
  int get _totalInactive => _allPatients.length;
  int get _totalValue =>
      _allPatients.fold<int>(0, (sum, p) => sum + p.amount);

  String _formatCurrency(int val) {
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
                    _StatusBadge(
                      status: patient.paymentStatus,
                      amount: patient.amount,
                    ),
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

  void _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
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
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredPatients;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: const Color(0xFFF8FAFC),
        drawer: const HomeSideDrawer(),
        drawerScrimColor: PortalColors.brand.withValues(alpha: 0.28),
        body: PortalSafeArea(
          bottom: false,
          statusBarColor: Colors.white,
          child: Column(
            children: [
              _buildTopBar(),
              if (_isLoading)
                const LinearProgressIndicator(
                  minHeight: 2.5,
                  color: _brandNavy,
                  backgroundColor: Color(0xFFE2E8F0),
                ),
              Expanded(
                child: RefreshIndicator(
                  color: _brandNavy,
                  onRefresh: () async {
                    _searchController.clear();
                    _searchQuery = '';
                    _selectedDate = null;
                    _selectedPayment = 'All Payment';
                    _selectedDoctor = 'All Doctors';
                    _selectedGender = 'All Genders';
                    await _fetchInactiveBookings(isRefresh: true);
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
                            _buildSearchRow(),
                            const SizedBox(height: 8),
                            _buildFilterChipsRow(),
                            const SizedBox(height: 14),
                            _buildSectionHeader(),
                            const SizedBox(height: 8),
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
          const PortalBackButton(),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Inactive Patients',
                  style: portalText(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F172A),
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  'Manage deactivated patient accounts',
                  style: portalText(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),
          const TopNotificationButton(),
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
    final screenWidth = MediaQuery.sizeOf(context).width;
    final cardWidth = ((screenWidth - 44) / 3).clamp(108.0, 160.0);

    return SizedBox(
      height: 96,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        children: [
          _StatCard(
            width: cardWidth,
            title: 'TOTAL INACTIVE',
            icon: Icons.person_off_rounded,
            iconBg: const Color(0xFFFEF3C7),
            iconColor: const Color(0xFFD97706),
            value: '$_totalInactive',
            subtitle: 'deactivated patients',
          ),
          const SizedBox(width: 8),
          _StatCard(
            width: cardWidth,
            title: 'PAID',
            icon: Icons.check_circle_rounded,
            iconBg: const Color(0xFFD1FAE5),
            iconColor: const Color(0xFF059669),
            value: '$_paidCount',
            subtitle: 'completed payments',
          ),
          const SizedBox(width: 8),
          _StatCard(
            width: cardWidth,
            title: 'PARTIAL',
            icon: Icons.group_rounded,
            iconBg: const Color(0xFFE0E7FF),
            iconColor: const Color(0xFF4F46E5),
            value: '$_partialCount',
            subtitle: 'partially paid',
          ),
          const SizedBox(width: 8),
          _StatCard(
            width: cardWidth,
            title: 'PENDING',
            icon: Icons.access_time_rounded,
            iconBg: const Color(0xFFFEF3C7),
            iconColor: const Color(0xFFD97706),
            value: '$_pendingCount',
            subtitle: 'awaiting payment',
          ),
          const SizedBox(width: 8),
          _StatCard(
            width: cardWidth,
            title: 'DUE',
            icon: Icons.cancel_rounded,
            iconBg: const Color(0xFFFFEDD5),
            iconColor: const Color(0xFFEA580C),
            value: '$_dueCount',
            subtitle: 'overdue',
          ),
          const SizedBox(width: 8),
          _StatCard(
            width: cardWidth,
            title: 'TOTAL VALUE',
            icon: Icons.currency_rupee_rounded,
            iconBg: const Color(0xFFD1FAE5),
            iconColor: const Color(0xFF059669),
            value: '₹${_formatCurrency(_totalValue)}',
            subtitle: 'total inactive value',
          ),
        ],
      ),
    );
  }

  Widget _buildSearchRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
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
    );
  }

  bool get _hasActiveFilters =>
      _selectedDate != null ||
      _selectedPayment != 'All Payment' ||
      _selectedDoctor != 'All Doctors' ||
      _selectedGender != 'All Genders';

  void _clearAllFilters() {
    setState(() {
      _selectedDate = null;
      _selectedPayment = 'All Payment';
      _selectedDoctor = 'All Doctors';
      _selectedGender = 'All Genders';
    });
  }

  Widget _buildFilterChipsRow() {
    final paymentDisplay = _selectedPayment == 'All Payment'
        ? 'Payment'
        : _selectedPayment;

    final doctorDisplay = _selectedDoctor == 'All Doctors'
        ? 'Doctor'
        : (_selectedDoctor.startsWith('DR ') || _selectedDoctor.startsWith('Dr ')
            ? _selectedDoctor.substring(3).trim().split(' ').first
            : _selectedDoctor);

    final genderDisplay = _selectedGender == 'All Genders'
        ? 'Gender'
        : _selectedGender;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          Expanded(
            child: _DateFilterChip(
              selectedDate: _selectedDate,
              onTap: _pickDate,
              onClear: () => setState(() => _selectedDate = null),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: _DropdownChip(
              label: _selectedPayment,
              displayLabel: paymentDisplay,
              defaultLabel: 'All Payment',
              options: const [
                'All Payment',
                'Paid',
                'Due',
                'Partial',
                'Pending',
              ],
              onSelected: (val) => setState(() => _selectedPayment = val),
              onClear: () => setState(() => _selectedPayment = 'All Payment'),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: _DropdownChip(
              label: _selectedDoctor,
              displayLabel: doctorDisplay,
              defaultLabel: 'All Doctors',
              options: _doctorOptions,
              onSelected: (val) => setState(() => _selectedDoctor = val),
              onClear: () => setState(() => _selectedDoctor = 'All Doctors'),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: _DropdownChip(
              label: _selectedGender,
              displayLabel: genderDisplay,
              defaultLabel: 'All Genders',
              options: const ['All Genders', 'Male', 'Female'],
              onSelected: (val) => setState(() => _selectedGender = val),
              onClear: () => setState(() => _selectedGender = 'All Genders'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(
              Icons.people_alt_rounded,
              size: 14,
              color: Color(0xFF2563EB),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Patient List',
            style: portalText(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1E293B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return EmployeeBottomNav(
      currentIndex: 0,
      onTap: (i) {
        if (i == 0) {
          EmployeeHomeShell.goToDashboard(context);
          return;
        }
        EmployeeHomeShell.goToTab(context, i);
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.width,
    required this.title,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.value,
    required this.subtitle,
  });

  final double width;
  final String title;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String value;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.fromLTRB(10, 10, 8, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: portalText(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF64748B),
                    letterSpacing: 0.2,
                    height: 1.15,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Container(
                width: 22,
                height: 22,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  icon,
                  size: 13,
                  color: iconColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: portalText(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0F172A),
              height: 1.1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: portalText(
              fontSize: 9,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF94A3B8),
            ),
          ),
        ],
      ),
    );
  }
}

class _DateFilterChip extends StatelessWidget {
  const _DateFilterChip({
    required this.selectedDate,
    required this.onTap,
    required this.onClear,
  });

  final DateTime? selectedDate;
  final VoidCallback onTap;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final hasDate = selectedDate != null;
    final label = hasDate
        ? '${selectedDate!.day}/${selectedDate!.month}'
        : 'Date';

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 34,
        padding: const EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
          color: hasDate ? const Color(0xFFF5F3FF) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: hasDate ? OpColors.primary : const Color(0xFFE2E8F0),
            width: hasDate ? 1.3 : 1.0,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 11,
              color: hasDate ? OpColors.primary : const Color(0xFF64748B),
            ),
            const SizedBox(width: 3),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: portalText(
                  fontSize: 10.5,
                  fontWeight: hasDate ? FontWeight.w700 : FontWeight.w600,
                  color: hasDate ? OpColors.primary : const Color(0xFF334155),
                ),
              ),
            ),
            const SizedBox(width: 2),
            if (hasDate)
              GestureDetector(
                onTap: onClear,
                behavior: HitTestBehavior.opaque,
                child: const Padding(
                  padding: EdgeInsets.all(2),
                  child: Icon(
                    Icons.close_rounded,
                    size: 12,
                    color: OpColors.primary,
                  ),
                ),
              )
            else
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 14,
                color: Color(0xFF64748B),
              ),
          ],
        ),
      ),
    );
  }
}

class _DropdownChip extends StatelessWidget {
  const _DropdownChip({
    required this.label,
    required this.displayLabel,
    required this.options,
    required this.onSelected,
    this.defaultLabel,
    this.onClear,
  });

  final String label;
  final String displayLabel;
  final List<String> options;
  final ValueChanged<String> onSelected;
  final String? defaultLabel;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final isFiltered = defaultLabel != null && label != defaultLabel;

    return PopupMenuButton<String>(
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
      onSelected: onSelected,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      itemBuilder: (ctx) => options.map((opt) {
        final isSelected = opt == label;
        return PopupMenuItem<String>(
          value: opt,
          height: 38,
          child: Row(
            children: [
              Text(
                opt,
                style: portalText(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                      ? OpColors.primary
                      : const Color(0xFF0F172A),
                ),
              ),
              if (isSelected) ...[
                const Spacer(),
                const Icon(
                  Icons.check_rounded,
                  size: 15,
                  color: OpColors.primary,
                ),
              ],
            ],
          ),
        );
      }).toList(),
      child: Container(
        height: 34,
        padding: const EdgeInsets.symmetric(horizontal: 5),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isFiltered ? const Color(0xFFF5F3FF) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isFiltered ? OpColors.primary : const Color(0xFFE2E8F0),
            width: isFiltered ? 1.3 : 1.0,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                displayLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: portalText(
                  fontSize: 10.5,
                  fontWeight: isFiltered ? FontWeight.w700 : FontWeight.w600,
                  color: isFiltered ? OpColors.primary : const Color(0xFF334155),
                ),
              ),
            ),
            const SizedBox(width: 2),
            if (isFiltered && onClear != null)
              GestureDetector(
                onTap: onClear,
                behavior: HitTestBehavior.opaque,
                child: const Padding(
                  padding: EdgeInsets.all(2),
                  child: Icon(
                    Icons.close_rounded,
                    size: 12,
                    color: OpColors.primary,
                  ),
                ),
              )
            else
              Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 14,
                color: isFiltered ? OpColors.primary : const Color(0xFF64748B),
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

  @override
  Widget build(BuildContext context) {
    final p = patient;
    final isFemale = p.gender.toLowerCase() == 'female';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEDF2F7), width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x081E293B),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isFemale
                        ? [const Color(0xFFF472B6), const Color(0xFFDB2777)]
                        : [const Color(0xFF60A5FA), const Color(0xFF2563EB)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: (isFemale
                              ? const Color(0xFFF472B6)
                              : const Color(0xFF60A5FA))
                          .withValues(alpha: 0.35),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Text(
                  p.initial,
                  style: portalText(
                    fontSize: 17,
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
                      p.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: portalText(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0F172A),
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${p.age} yrs • ${p.gender}',
                            style: portalText(
                              fontSize: 10.5,
                              color: const Color(0xFF475569),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              _StatusBadge(status: p.paymentStatus, amount: p.amount),
            ],
          ),

          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFF1F5F9)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            width: 26,
                            height: 26,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Icon(
                              Icons.call_rounded,
                              size: 13,
                              color: Color(0xFF2563EB),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'PHONE',
                                  style: portalText(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF94A3B8),
                                    letterSpacing: 0.3,
                                  ),
                                ),
                                const SizedBox(height: 1),
                                Text(
                                  p.phone,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: portalText(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF0F172A),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            width: 26,
                            height: 26,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F3FF),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Icon(
                              Icons.medical_services_rounded,
                              size: 13,
                              color: _doctorPurple,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'DOCTOR',
                                  style: portalText(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF94A3B8),
                                    letterSpacing: 0.3,
                                  ),
                                ),
                                const SizedBox(height: 1),
                                Text(
                                  p.doctor,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: portalText(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF0F172A),
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
                const SizedBox(height: 10),
                const Divider(height: 1, color: Color(0xFFE2E8F0)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            width: 26,
                            height: 26,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0FDF4),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Icon(
                              Icons.calendar_today_rounded,
                              size: 12,
                              color: Color(0xFF059669),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'LAST VISIT',
                                  style: portalText(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF94A3B8),
                                    letterSpacing: 0.3,
                                  ),
                                ),
                                const SizedBox(height: 1),
                                Text(
                                  p.lastVisitDate,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: portalText(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF0F172A),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            width: 26,
                            height: 26,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF1F2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Icon(
                              Icons.history_rounded,
                              size: 13,
                              color: Color(0xFFE11D48),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'DEACTIVATED',
                                  style: portalText(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF94A3B8),
                                    letterSpacing: 0.3,
                                  ),
                                ),
                                const SizedBox(height: 1),
                                Text(
                                  p.deactivatedSince,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
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
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    size: 14,
                    color: Color(0xFF94A3B8),
                  ),
                  const SizedBox(width: 3),
                  Text(
                    p.city,
                    style: portalText(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onView,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.visibility_outlined,
                          size: 14,
                          color: Color(0xFF475569),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'View',
                          style: portalText(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF475569),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onActivate,
                behavior: HitTestBehavior.opaque,
                child: Container(
                  height: 26,
                  padding: const EdgeInsets.only(left: 8, right: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFA7F3D0),
                      width: 1.0,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 5,
                        height: 5,
                        decoration: const BoxDecoration(
                          color: _activateGreen,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'Activate',
                        style: portalText(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF065F46),
                        ),
                      ),
                      const SizedBox(width: 2),
                      Transform.scale(
                        scale: 0.52,
                        child: CupertinoSwitch(
                          value: false,
                          activeColor: _activateGreen,
                          onChanged: (_) => onActivate(),
                        ),
                      ),
                    ],
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
  const _StatusBadge({required this.status, this.amount = 0});

  final String status;
  final int amount;

  @override
  Widget build(BuildContext context) {
    final upper = status.toUpperCase();
    final isDue = upper == 'DUE';
    final isPaid = upper == 'PAID';
    final isPartial = upper == 'PARTIAL';

    final Color bgColor = isDue
        ? const Color(0xFFFEF2F2)
        : isPaid
            ? const Color(0xFFECFDF5)
            : isPartial
                ? const Color(0xFFEFF6FF)
                : const Color(0xFFFFFBEB);

    final Color borderColor = isDue
        ? const Color(0xFFFECACA)
        : isPaid
            ? const Color(0xFFA7F3D0)
            : isPartial
                ? const Color(0xFFBFDBFE)
                : const Color(0xFFFDE68A);

    final Color textColor = isDue
        ? const Color(0xFFEF4444)
        : isPaid
            ? const Color(0xFF059669)
            : isPartial
                ? const Color(0xFF2563EB)
                : const Color(0xFFD97706);

    final IconData icon = isDue
        ? Icons.cancel_outlined
        : isPaid
            ? Icons.check_circle_outline_rounded
            : isPartial
                ? Icons.pie_chart_outline_rounded
                : Icons.schedule_rounded;

    final displayText = upper;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: textColor),
          const SizedBox(width: 4),
          Text(
            displayText,
            style: portalText(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: textColor,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

