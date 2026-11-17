import 'package:flutter/material.dart';
import 'package:timelay_health/core/theme/portal_colors.dart';
import 'package:timelay_health/core/theme/portal_text.dart';
import 'package:timelay_health/core/widgets/portal_back_button.dart';
import 'package:timelay_health/core/widgets/portal_safe_area.dart';
import 'package:timelay_health/features/op/referral/presentation/models/op_referral_ui.dart';

class OpReferralManagementScreen extends StatefulWidget {
  const OpReferralManagementScreen({super.key});

  @override
  State<OpReferralManagementScreen> createState() =>
      _OpReferralManagementScreenState();
}

class _OpReferralManagementScreenState
    extends State<OpReferralManagementScreen> {
  int _selectedTab = 0; // 0: Customer Referrals, 1: Doctor Referrals
  final TextEditingController _searchController = TextEditingController();
  String _statusFilter = 'All'; // All, Active, Inactive
  late List<OpCustomerReferralUi> _customers;
  late List<OpDoctorReferralUi> _doctors;

  @override
  void initState() {
    super.initState();
    _customers = List.of(OpReferralData.demoCustomers);
    _doctors = List.of(OpReferralData.demoDoctors);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<OpCustomerReferralUi> get _filteredCustomers {
    final query = _searchController.text.trim().toLowerCase();
    return _customers.where((c) {
      if (_statusFilter == 'Active' && !c.isActive) return false;
      if (_statusFilter == 'Inactive' && c.isActive) return false;
      if (query.isNotEmpty) {
        final matchesName = c.name.toLowerCase().contains(query);
        final matchesPhone = c.phone.toLowerCase().contains(query);
        final matchesOrg = c.organization.toLowerCase().contains(query);
        return matchesName || matchesPhone || matchesOrg;
      }
      return true;
    }).toList();
  }

  List<OpDoctorReferralUi> get _filteredDoctors {
    final query = _searchController.text.trim().toLowerCase();
    return _doctors.where((d) {
      if (_statusFilter == 'Active' && !d.isActive) return false;
      if (_statusFilter == 'Inactive' && d.isActive) return false;
      if (query.isNotEmpty) {
        final matchesName = d.name.toLowerCase().contains(query);
        final matchesPhone = d.phone.toLowerCase().contains(query);
        final matchesClinic = d.clinic.toLowerCase().contains(query);
        return matchesName || matchesPhone || matchesClinic;
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

  void _showAddCustomerSheet() {
    final nameCtrl = TextEditingController();
    final orgCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final locCtrl = TextEditingController();
    final serviceCtrl = TextEditingController(text: '10%');
    final pharmacyCtrl = TextEditingController(text: '10%');
    final labCtrl = TextEditingController(text: '20%');
    final feesCtrl = TextEditingController(text: '₹150');

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 16),
        padding: EdgeInsets.only(
          left: 18,
          right: 18,
          top: 14,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 18,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A000000),
              blurRadius: 20,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: SingleChildScrollView(
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
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Add New Customer Referral',
                    style: portalText(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(ctx),
                    icon: const Icon(Icons.close_rounded, size: 20),
                    color: const Color(0xFF64748B),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildInput('Customer Name', nameCtrl, 'Enter full name'),
              _buildInput('Organization / College', orgCtrl, 'e.g. Narayana, Sri Chaitanya'),
              _buildInput('Phone Number', phoneCtrl, '10-digit mobile number', keyboard: TextInputType.phone),
              _buildInput('Location', locCtrl, 'e.g. Madhapur'),
              const SizedBox(height: 8),
              Text(
                'Rates & Commission',
                style: portalText(fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFF475569)),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: _buildInput('Service %', serviceCtrl, '10%')),
                  const SizedBox(width: 8),
                  Expanded(child: _buildInput('Pharmacy %', pharmacyCtrl, '10%')),
                  const SizedBox(width: 8),
                  Expanded(child: _buildInput('Lab %', labCtrl, '20%')),
                  const SizedBox(width: 8),
                  Expanded(child: _buildInput('Fees', feesCtrl, '₹150')),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final name = nameCtrl.text.trim();
                    if (name.isEmpty) return;
                    setState(() {
                      _customers.insert(
                        0,
                        OpCustomerReferralUi(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          name: name,
                          organization: orgCtrl.text.trim().isEmpty ? 'N/A' : orgCtrl.text.trim(),
                          phone: phoneCtrl.text.trim().isEmpty ? '9876543210' : phoneCtrl.text.trim(),
                          location: locCtrl.text.trim().isEmpty ? 'MADHAPUR' : locCtrl.text.trim(),
                          isActive: true,
                          serviceRate: serviceCtrl.text.trim(),
                          pharmacyRate: pharmacyCtrl.text.trim(),
                          labRate: labCtrl.text.trim(),
                          fees: feesCtrl.text.trim(),
                          onboardDate: 'Today',
                          avatarColor: const Color(0xFF7C3AED),
                        ),
                      );
                    });
                    Navigator.pop(ctx);
                    _snack('Customer "$name" added successfully');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF26204A),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Save Customer',
                    style: portalText(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInput(
    String label,
    TextEditingController controller,
    String hint, {
    TextInputType keyboard = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: portalText(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 4),
          Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: TextField(
              controller: controller,
              keyboardType: keyboard,
              style: portalText(fontSize: 12, color: const Color(0xFF0F172A)),
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: hint,
                hintStyle: portalText(fontSize: 11, color: const Color(0xFF94A3B8)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showStatusFilterSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Select Status Filter',
                  style: portalText(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 10),
                for (final s in ['All', 'Active', 'Inactive'])
                  ListTile(
                    title: Text(
                      s,
                      style: portalText(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _statusFilter == s
                            ? const Color(0xFF26204A)
                            : const Color(0xFF475569),
                      ),
                    ),
                    trailing: _statusFilter == s
                        ? const Icon(Icons.check_rounded, color: Color(0xFF26204A))
                        : null,
                    onTap: () {
                      setState(() => _statusFilter = s);
                      Navigator.pop(ctx);
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showCustomerDetail(OpCustomerReferralUi customer) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 16),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A000000),
              blurRadius: 20,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: customer.avatarColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    customer.name.isNotEmpty ? customer.name[0].toUpperCase() : 'C',
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
                        customer.name,
                        style: portalText(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      Text(
                        customer.organization,
                        style: portalText(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFD1FAE5)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Color(0xFF10B981),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'ACTIVE',
                        style: portalText(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF059669),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  _detailRow('Phone Number', customer.phone),
                  const Divider(height: 16),
                  _detailRow('Location', customer.location),
                  const Divider(height: 16),
                  _detailRow('Onboard Date', customer.onboardDate),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Rates & Commission',
              style: portalText(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF334155),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _ratePill('Service', customer.serviceRate, const Color(0xFFEFF6FF), const Color(0xFF2563EB))),
                const SizedBox(width: 6),
                Expanded(child: _ratePill('Pharmacy', customer.pharmacyRate, const Color(0xFFECFDF5), const Color(0xFF059669))),
                const SizedBox(width: 6),
                Expanded(child: _ratePill('Lab', customer.labRate, const Color(0xFFF5F3FF), const Color(0xFF7C3AED))),
                const SizedBox(width: 6),
                Expanded(child: _ratePill('Fees', customer.fees, const Color(0xFFFFF7ED), const Color(0xFFEA580C))),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(ctx),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text('Close', style: portalText(fontSize: 13, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String title, String val) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: portalText(fontSize: 11, color: const Color(0xFF64748B))),
        Text(val, style: portalText(fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFF0F172A))),
      ],
    );
  }

  Widget _ratePill(String title, String val, Color bg, Color textCol) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(title, style: portalText(fontSize: 9.5, color: textCol.withValues(alpha: 0.8))),
          Text(val, style: portalText(fontSize: 11, fontWeight: FontWeight.w800, color: textCol)),
        ],
      ),
    );
  }

  void _deleteCustomer(OpCustomerReferralUi customer) {
    setState(() {
      _customers.removeWhere((c) => c.id == customer.id);
    });
    _snack('Customer "${customer.name}" removed');
  }

  @override
  Widget build(BuildContext context) {
    final filteredCustomers = _filteredCustomers;
    final filteredDoctors = _filteredDoctors;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      body: PortalSafeArea(
        bottom: false,
        statusBarColor: Colors.white,
        child: Column(
          children: [
            // Top App Bar
            _buildTopAppBar(),
            // Main Scrollable Content
            Expanded(
              child: RefreshIndicator(
                color: const Color(0xFF26204A),
                onRefresh: () async {
                  await Future<void>.delayed(const Duration(milliseconds: 400));
                  setState(() {
                    _customers = List.of(OpReferralData.demoCustomers);
                    _doctors = List.of(OpReferralData.demoDoctors);
                  });
                  _snack('Referrals refreshed');
                },
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(14, 10, 14, 32),
                  children: [
                    // Segmented Tabs: Customer Referrals (15) / Doctor Referrals (3)
                    _buildSegmentedTabs(),
                    const SizedBox(height: 12),
                    // Action Buttons: Referred OP / + Add Customer
                    _buildActionButtons(),
                    const SizedBox(height: 14),
                    // KPI / Stats Grid (Row of 4)
                    _buildKpiRow(),
                    const SizedBox(height: 14),
                    // Search Bar
                    _buildSearchBar(),
                    const SizedBox(height: 10),
                    // Filter Pills Row
                    _buildFilterPillsRow(filteredCustomers.length),
                    const SizedBox(height: 14),
                    // Records Header with Export CSV
                    _buildRecordsHeader(filteredCustomers.length),
                    const SizedBox(height: 10),
                    // List of Cards
                    if (_selectedTab == 0) ...[
                      for (final customer in filteredCustomers) ...[
                        _buildCustomerCard(customer),
                        const SizedBox(height: 10),
                      ],
                      if (filteredCustomers.isEmpty) _buildEmptyState('No customer referrals found'),
                    ] else ...[
                      for (final doc in filteredDoctors) ...[
                        _buildDoctorCard(doc),
                        const SizedBox(height: 10),
                      ],
                      if (filteredDoctors.isEmpty) _buildEmptyState('No doctor referrals found'),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Top App Bar
  Widget _buildTopAppBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.98),
        border: const Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
      ),
      child: Row(
        children: [
          // App standard back button
          const PortalBackButton(),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _selectedTab == 0 ? 'Customer Referrals' : 'Doctor Referrals',
                  style: portalText(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1E1B4B),
                    height: 1.15,
                  ),
                ),
                Text(
                  'Healthcare Partner Portal',
                  style: portalText(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                _customers = List.of(OpReferralData.demoCustomers);
                _doctors = List.of(OpReferralData.demoDoctors);
              });
              _snack('Refreshed data');
            },
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.sync_rounded,
                size: 21,
                color: Color(0xFF64748B),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Segmented Tabs: Customer Referrals 15 / Doctor Referrals 3
  Widget _buildSegmentedTabs() {
    return Container(
      height: 42,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTab = 0),
              child: Container(
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
                      size: 15,
                      color: _selectedTab == 0
                          ? const Color(0xFF1E1B4B)
                          : const Color(0xFF64748B),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Customer Referrals',
                      style: portalText(
                        fontSize: 11.5,
                        fontWeight: _selectedTab == 0 ? FontWeight.w800 : FontWeight.w600,
                        color: _selectedTab == 0
                            ? const Color(0xFF1E1B4B)
                            : const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(width: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: _selectedTab == 0 ? const Color(0xFFF1F5F9) : const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${_customers.length}',
                        style: portalText(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          color: _selectedTab == 0 ? const Color(0xFF1E1B4B) : const Color(0xFF64748B),
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
              child: Container(
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
                      size: 15,
                      color: _selectedTab == 1
                          ? const Color(0xFF1E1B4B)
                          : const Color(0xFF64748B),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Doctor Referrals',
                      style: portalText(
                        fontSize: 11.5,
                        fontWeight: _selectedTab == 1 ? FontWeight.w800 : FontWeight.w600,
                        color: _selectedTab == 1
                            ? const Color(0xFF1E1B4B)
                            : const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(width: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: _selectedTab == 1 ? const Color(0xFFF1F5F9) : const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${_doctors.length}',
                        style: portalText(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          color: _selectedTab == 1 ? const Color(0xFF1E1B4B) : const Color(0xFF64748B),
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

  // Action Buttons: Referred OP / + Add Customer
  Widget _buildActionButtons() {
    return Row(
      children: [
        // Left Button: Referred OP
        Expanded(
          child: GestureDetector(
            onTap: () {
              _snack('Opened Referred OPs');
            },
            child: Container(
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F3FF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFDDD6FE)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.local_hospital_outlined,
                    size: 17,
                    color: Color(0xFF4F46E5),
                  ),
                  const SizedBox(width: 7),
                  Text(
                    'Referred OP',
                    style: portalText(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF312E81),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        // Right Button: + Add Customer
        Expanded(
          child: GestureDetector(
            onTap: _showAddCustomerSheet,
            child: Container(
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFF26204A),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF26204A).withValues(alpha: 0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.add_rounded,
                    size: 18,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Add Customer',
                    style: portalText(
                      fontSize: 12.5,
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
    );
  }

  // KPI Row of 4 cards: TOTAL, ACTIVE, INACTI..., OPS
  Widget _buildKpiRow() {
    return Row(
      children: [
        Expanded(
          child: _kpiCard(
            title: 'TOTAL',
            value: '15',
            sub: 'All referrals',
            icon: Icons.groups_2_outlined,
            iconBg: const Color(0xFFF1F5F9),
            iconColor: const Color(0xFF4F46E5),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _kpiCard(
            title: 'ACTIVE',
            value: '15',
            sub: 'Active',
            subColor: const Color(0xFF10B981),
            icon: Icons.person_outline_rounded,
            iconBg: const Color(0xFFECFDF5),
            iconColor: const Color(0xFF10B981),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _kpiCard(
            title: 'INACTI...',
            value: '0',
            sub: 'Inactive',
            icon: Icons.block_flipped,
            iconBg: const Color(0xFFFFF7ED),
            iconColor: const Color(0xFFF97316),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _kpiCard(
            title: 'OPS',
            value: '55',
            sub: 'Visits',
            icon: Icons.domain_rounded,
            iconBg: const Color(0xFFF5F3FF),
            iconColor: const Color(0xFF8B5CF6),
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
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
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
              Text(
                title,
                style: portalText(
                  fontSize: 8.5,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF64748B),
                ),
              ),
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
            style: portalText(
              fontSize: 9,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w500,
              color: subColor ?? const Color(0xFF94A3B8),
            ),
          ),
        ],
      ),
    );
  }

  // Search Bar
  Widget _buildSearchBar() {
    return Container(
      height: 42,
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
            size: 18,
            color: Color(0xFF94A3B8),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              style: portalText(
                fontSize: 12.5,
                color: const Color(0xFF0F172A),
              ),
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: 'Search Name, Phone...',
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

  // Filter Pills: 15 Customers / Date / Status
  Widget _buildFilterPillsRow(int count) {
    return Row(
      children: [
        // Pill 1: 15 Customers
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.groups_outlined,
                size: 14,
                color: Color(0xFF475569),
              ),
              const SizedBox(width: 5),
              Text(
                '$count Customers',
                style: portalText(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF334155),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 6),
        // Pill 2: Calendar date
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                size: 12,
                color: Color(0xFF64748B),
              ),
              const SizedBox(width: 5),
              Text(
                '----------- ----',
                style: portalText(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF94A3B8),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 6),
        // Pill 3: Status
        GestureDetector(
          onTap: _showStatusFilterSheet,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _statusFilter == 'All' ? 'Status' : _statusFilter,
                  style: portalText(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF475569),
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 14,
                  color: Color(0xFF64748B),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Header: CUSTOMER RECORDS (5 of 15) & Export CSV
  Widget _buildRecordsHeader(int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          _selectedTab == 0
              ? 'CUSTOMER RECORDS ($count of ${_customers.length})'
              : 'DOCTOR RECORDS ($count of ${_doctors.length})',
          style: portalText(
            fontSize: 10.5,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF64748B),
            letterSpacing: 0.3,
          ),
        ),
        GestureDetector(
          onTap: () => _snack('Exported Referral Records to CSV'),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFECFDF5),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFA7F3D0)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.description_outlined,
                  size: 13,
                  color: Color(0xFF059669),
                ),
                const SizedBox(width: 4),
                Text(
                  'Export CSV',
                  style: portalText(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF059669),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Customer Card
  Widget _buildCustomerCard(OpCustomerReferralUi customer) {
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
          // Row 1: Avatar + Name & Organization + Active Status Badge
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(
                  customer.name.isNotEmpty ? customer.name[0].toUpperCase() : 'C',
                  style: portalText(
                    fontSize: 17,
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
                      customer.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: portalText(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(
                          Icons.account_balance_rounded,
                          size: 12,
                          color: Color(0xFFB45309),
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            customer.organization,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: portalText(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: customer.organization == 'N/A'
                                  ? const Color(0xFF94A3B8)
                                  : const Color(0xFF64748B),
                              fontStyle: customer.organization == 'N/A'
                                  ? FontStyle.italic
                                  : FontStyle.normal,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFD1FAE5), width: 0.8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 5.5,
                      height: 5.5,
                      decoration: const BoxDecoration(
                        color: Color(0xFF10B981),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'ACTIVE',
                      style: portalText(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF059669),
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Row 2: Phone & Location in rounded pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.phone_outlined,
                  size: 14,
                  color: Color(0xFF64748B),
                ),
                const SizedBox(width: 6),
                Text(
                  customer.phone,
                  style: portalText(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF334155),
                  ),
                ),
                const Spacer(),
                const Icon(
                  Icons.location_on_outlined,
                  size: 14,
                  color: Color(0xFF94A3B8),
                ),
                const SizedBox(width: 4),
                Text(
                  customer.location,
                  style: portalText(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: customer.location == 'N/A'
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF475569),
                    fontStyle: customer.location == 'N/A'
                        ? FontStyle.italic
                        : FontStyle.normal,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Row 3: Rates & Commission
          Text(
            'RATES & COMMISSION',
            style: portalText(
              fontSize: 9.5,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF94A3B8),
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 5,
            runSpacing: 4,
            children: [
              _buildTag('Service: ${customer.serviceRate}', const Color(0xFFEFF6FF), const Color(0xFFBFDBFE), const Color(0xFF2563EB)),
              _buildTag('Pharmacy: ${customer.pharmacyRate}', const Color(0xFFECFDF5), const Color(0xFFA7F3D0), const Color(0xFF059669)),
              _buildTag('Lab: ${customer.labRate}', const Color(0xFFF5F3FF), const Color(0xFFDDD6FE), const Color(0xFF7C3AED)),
              _buildTag('Fees: ${customer.fees}', const Color(0xFFFFF7ED), const Color(0xFFFED7AA), const Color(0xFFEA580C)),
            ],
          ),
          const SizedBox(height: 10),

          // Row 4: Onboard Date & Action Icons (View, Edit, Delete)
          Row(
            children: [
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'Onboard: ',
                      style: portalText(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF94A3B8),
                      ),
                    ),
                    TextSpan(
                      text: customer.onboardDate,
                      style: portalText(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF334155),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              // View Icon
              GestureDetector(
                onTap: () => _showCustomerDetail(customer),
                behavior: HitTestBehavior.opaque,
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  child: Icon(
                    Icons.visibility_outlined,
                    size: 18,
                    color: Color(0xFF3B82F6),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Edit Icon
              GestureDetector(
                onTap: () => _snack('Edit customer "${customer.name}"'),
                behavior: HitTestBehavior.opaque,
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  child: Icon(
                    Icons.edit_outlined,
                    size: 18,
                    color: Color(0xFFF59E0B),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Delete Icon
              GestureDetector(
                onTap: () => _deleteCustomer(customer),
                behavior: HitTestBehavior.opaque,
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  child: Icon(
                    Icons.delete_outline_rounded,
                    size: 18,
                    color: Color(0xFFEF4444),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Doctor Card
  Widget _buildDoctorCard(OpDoctorReferralUi doc) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEEF2F6)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x080F172A),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: doc.avatarColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(
                  doc.name.isNotEmpty ? doc.name[0].toUpperCase() : 'D',
                  style: portalText(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
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
                      doc.name,
                      style: portalText(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      '${doc.clinic} • ${doc.specialization}',
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFD1FAE5)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 5,
                      height: 5,
                      decoration: const BoxDecoration(
                        color: Color(0xFF10B981),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'ACTIVE',
                      style: portalText(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF059669),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Row(
              children: [
                const Icon(Icons.phone_outlined, size: 13, color: Color(0xFF64748B)),
                const SizedBox(width: 5),
                Text(
                  doc.phone,
                  style: portalText(fontSize: 11.5, fontWeight: FontWeight.w600, color: const Color(0xFF334155)),
                ),
                const Spacer(),
                const Icon(Icons.location_on_outlined, size: 13, color: Color(0xFF64748B)),
                const SizedBox(width: 4),
                Text(
                  doc.location,
                  style: portalText(fontSize: 11.5, fontWeight: FontWeight.w600, color: const Color(0xFF334155)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildTag('Commission: ${doc.commission}', const Color(0xFFECFDF5), const Color(0xFFD1FAE5), const Color(0xFF059669)),
              const SizedBox(width: 6),
              _buildTag('Referred: ${doc.totalReferred} Patients', const Color(0xFFEFF6FF), const Color(0xFFDBEAFE), const Color(0xFF2563EB)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text('Onboard: ${doc.onboardDate}', style: portalText(fontSize: 10.5, color: const Color(0xFF64748B))),
              const Spacer(),
              GestureDetector(
                onTap: () => _snack('Doctor "${doc.name}" details'),
                child: const Icon(Icons.visibility_outlined, size: 17, color: Color(0xFF3B82F6)),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => _snack('Edit doctor "${doc.name}"'),
                child: const Icon(Icons.edit_outlined, size: 17, color: Color(0xFFF59E0B)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String label, Color bg, Color border, Color textCol) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: border),
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

  Widget _buildEmptyState(String msg) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Column(
          children: [
            const Icon(Icons.folder_open_rounded, size: 36, color: Color(0xFFCBD5E1)),
            const SizedBox(height: 8),
            Text(
              msg,
              style: portalText(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF94A3B8)),
            ),
          ],
        ),
      ),
    );
  }
}
