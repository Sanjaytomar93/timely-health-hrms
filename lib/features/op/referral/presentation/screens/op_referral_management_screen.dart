import 'package:flutter/material.dart';
import 'package:timelay_health/core/theme/portal_text.dart';
import 'package:timelay_health/core/widgets/portal_back_button.dart';
import 'package:timelay_health/core/widgets/portal_safe_area.dart';
import 'package:timelay_health/features/op/referral/presentation/models/op_referral_ui.dart';
import 'package:timelay_health/features/op/referral/presentation/screens/op_referral_booking_screen.dart';

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
  String _monthFilter = 'All Months';
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

  bool _matchesMonth(String onboardDate) {
    if (_monthFilter == 'All Months') return true;
    final parts = _monthFilter.split(' ');
    if (parts.length < 2) return true;
    final month = parts[0].toLowerCase();
    final year = parts[1];
    final d = onboardDate.toLowerCase();
    final mKey = (month == 'sep' || month == 'sept') ? 'sep' : month;
    return d.contains(mKey) && d.contains(year);
  }

  List<OpCustomerReferralUi> get _filteredCustomers {
    final query = _searchController.text.trim().toLowerCase();
    return _customers.where((c) {
      if (_statusFilter == 'Active' && !c.isActive) return false;
      if (_statusFilter == 'Inactive' && c.isActive) return false;
      if (!_matchesMonth(c.onboardDate)) return false;
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
      if (!_matchesMonth(d.onboardDate)) return false;
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
    // Special offers (discount)
    final specFeesCtrl = TextEditingController();
    final specLabCtrl = TextEditingController();
    final specPharmCtrl = TextEditingController();
    // Consultant fee (numeric string)
    final serviceCtrl = TextEditingController();
    final pharmacyCtrl = TextEditingController();
    final labCtrl = TextEditingController();
    final feesCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    String onboardDateStr = 'dd/mm/yyyy';
    String statusValue = 'active';

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Container(
          margin: EdgeInsets.only(
            left: 12,
            right: 12,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
            top: 24,
          ),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(ctx).size.height * 0.9,
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 12, 12),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: const Color(0xFF26204A),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.person_add_alt_1_rounded,
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
                            'Add Customer Referral',
                            style: portalText(
                              fontSize: 15.5,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Fill in the customer referral details below',
                            style: portalText(
                              fontSize: 11,
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

              // Scrollable Body
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // BASIC INFORMATION
                      Text(
                        'BASIC INFORMATION',
                        style: portalText(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF94A3B8),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _buildFormField(
                        label: 'CUSTOMER NAME *',
                        controller: nameCtrl,
                        icon: Icons.person_outline_rounded,
                        hint: 'John Doe',
                      ),
                      const SizedBox(height: 10),
                      _buildFormField(
                        label: 'ORGANISATION NAME',
                        controller: orgCtrl,
                        icon: Icons.apartment_rounded,
                        hint: 'Organisation',
                      ),
                      const SizedBox(height: 10),
                      _buildFormField(
                        label: 'PHONE NUMBER *',
                        controller: phoneCtrl,
                        icon: Icons.phone_outlined,
                        hint: '+91 9876543210',
                        keyboard: TextInputType.phone,
                      ),
                      const SizedBox(height: 10),
                      _buildFormField(
                        label: 'ADDRESS',
                        controller: locCtrl,
                        icon: Icons.location_on_outlined,
                        hint: "Customer's address",
                      ),
                      const SizedBox(height: 14),

                      // SPECIAL OFFERS (DISCOUNT) Box
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFBEB),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFFDE68A)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.card_giftcard_rounded,
                                  size: 16,
                                  color: Color(0xFFD97706),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'SPECIAL OFFERS (DISCOUNT)',
                                  style: portalText(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFFB45309),
                                    letterSpacing: 0.4,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildSuffixPillInput(
                                    label: 'FEES',
                                    controller: specFeesCtrl,
                                    icon: Icons.confirmation_number_outlined,
                                    iconColor: const Color(0xFFEA580C),
                                    hint: '0',
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _buildSuffixPillInput(
                                    label: 'LAB',
                                    controller: specLabCtrl,
                                    icon: Icons.science_outlined,
                                    iconColor: const Color(0xFF7C3AED),
                                    hint: '0',
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _buildSuffixPillInput(
                                    label: 'PHARMACY',
                                    controller: specPharmCtrl,
                                    icon: Icons.local_pharmacy_outlined,
                                    iconColor: const Color(0xFF059669),
                                    hint: '0',
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      // CONSULTANT FEE
                      Text(
                        'CONSULTANT FEE',
                        style: portalText(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF94A3B8),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _buildSuffixPillInput(
                              label: 'SERVICE',
                              controller: serviceCtrl,
                              icon: Icons.design_services_outlined,
                              iconColor: const Color(0xFF2563EB),
                              hint: '0',
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: _buildSuffixPillInput(
                              label: 'PHARMACY',
                              controller: pharmacyCtrl,
                              icon: Icons.local_pharmacy_outlined,
                              iconColor: const Color(0xFF059669),
                              hint: '0',
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: _buildSuffixPillInput(
                              label: 'LAB',
                              controller: labCtrl,
                              icon: Icons.science_outlined,
                              iconColor: const Color(0xFF7C3AED),
                              hint: '0',
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: _buildSuffixPillInput(
                              label: 'FEES',
                              controller: feesCtrl,
                              icon: Icons.confirmation_number_outlined,
                              iconColor: const Color(0xFFEA580C),
                              hint: '0',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // ADDITIONAL DETAILS
                      Text(
                        'ADDITIONAL DETAILS',
                        style: portalText(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF94A3B8),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          // ONBOARD DATE
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'ONBOARD DATE',
                                  style: portalText(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF475569),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                GestureDetector(
                                  onTap: () async {
                                    final picked = await showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime(2020),
                                      lastDate: DateTime(2030),
                                    );
                                    if (picked != null) {
                                      final months = [
                                        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                                        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
                                      ];
                                      setModalState(() {
                                        onboardDateStr =
                                            '${picked.day.toString().padLeft(2, '0')} ${months[picked.month - 1]} ${picked.year}';
                                      });
                                    }
                                  },
                                  child: Container(
                                    height: 42,
                                    padding: const EdgeInsets.symmetric(horizontal: 10),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: const Color(0xFFE2E8F0)),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            onboardDateStr,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: portalText(
                                              fontSize: 11.5,
                                              fontWeight: FontWeight.w600,
                                              color: onboardDateStr == 'dd/mm/yyyy'
                                                  ? const Color(0xFF94A3B8)
                                                  : const Color(0xFF0F172A),
                                            ),
                                          ),
                                        ),
                                        const Icon(
                                          Icons.calendar_today_outlined,
                                          size: 14,
                                          color: Color(0xFF64748B),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          // STATUS
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'STATUS',
                                  style: portalText(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF475569),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  height: 42,
                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: const Color(0xFFE2E8F0)),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: statusValue,
                                      isExpanded: true,
                                      icon: const Icon(
                                        Icons.keyboard_arrow_down_rounded,
                                        size: 18,
                                        color: Color(0xFF64748B),
                                      ),
                                      style: portalText(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF0F172A),
                                      ),
                                      items: const [
                                        DropdownMenuItem(
                                          value: 'active',
                                          child: Text('active'),
                                        ),
                                        DropdownMenuItem(
                                          value: 'inactive',
                                          child: Text('inactive'),
                                        ),
                                      ],
                                      onChanged: (val) {
                                        if (val != null) {
                                          setModalState(() => statusValue = val);
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

                      // NOTES
                      Text(
                        'NOTES',
                        style: portalText(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF94A3B8),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: TextField(
                          controller: notesCtrl,
                          maxLines: 3,
                          style: portalText(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF0F172A),
                          ),
                          decoration: InputDecoration(
                            isDense: true,
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.all(10),
                            hintText: 'Add any additional notes...',
                            hintStyle: portalText(
                              fontSize: 11.5,
                              color: const Color(0xFF94A3B8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom Action Buttons: Cancel and Add Customer
              const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                child: Row(
                  children: [
                    const Spacer(),
                    OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
                        side: const BorderSide(color: Color(0xFFCBD5E1)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: portalText(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF475569),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton.icon(
                      onPressed: () {
                        final name = nameCtrl.text.trim();
                        if (name.isEmpty) {
                          _snack('Please enter Customer Name');
                          return;
                        }
                        final phone = phoneCtrl.text.trim().isEmpty ? '9876543210' : phoneCtrl.text.trim();
                        final org = orgCtrl.text.trim().isEmpty ? 'N/A' : orgCtrl.text.trim();
                        final address = locCtrl.text.trim().isEmpty ? 'MADHAPUR' : locCtrl.text.trim();
                        final sRate = serviceCtrl.text.trim().isEmpty ? '0%' : (serviceCtrl.text.trim().contains('%') ? serviceCtrl.text.trim() : '${serviceCtrl.text.trim()}%');
                        final pRate = pharmacyCtrl.text.trim().isEmpty ? '0%' : (pharmacyCtrl.text.trim().contains('%') ? pharmacyCtrl.text.trim() : '${pharmacyCtrl.text.trim()}%');
                        final lRate = labCtrl.text.trim().isEmpty ? '0%' : (labCtrl.text.trim().contains('%') ? labCtrl.text.trim() : '${labCtrl.text.trim()}%');
                        final fee = feesCtrl.text.trim().isEmpty ? '₹0' : (feesCtrl.text.trim().startsWith('₹') || feesCtrl.text.trim().contains('%') ? feesCtrl.text.trim() : '₹${feesCtrl.text.trim()}');

                        setState(() {
                          _customers.insert(
                            0,
                            OpCustomerReferralUi(
                              id: 'cust_${DateTime.now().millisecondsSinceEpoch}',
                              name: name,
                              organization: org,
                              phone: phone,
                              location: address,
                              isActive: statusValue == 'active',
                              serviceRate: sRate,
                              pharmacyRate: pRate,
                              labRate: lRate,
                              fees: fee,
                              onboardDate: onboardDateStr == 'dd/mm/yyyy' ? 'Today' : onboardDateStr,
                              specialFees: specFeesCtrl.text.trim().isEmpty ? '0' : specFeesCtrl.text.trim(),
                              specialLab: specLabCtrl.text.trim().isEmpty ? '0' : specLabCtrl.text.trim(),
                              specialPharmacy: specPharmCtrl.text.trim().isEmpty ? '0' : specPharmCtrl.text.trim(),
                              notes: notesCtrl.text.trim(),
                              avatarColor: const Color(0xFF26204A),
                            ),
                          );
                        });
                        Navigator.pop(ctx);
                        _snack('Customer "$name" added successfully');
                      },
                      icon: const Icon(Icons.person_add_alt_1_rounded, size: 16),
                      label: Text(
                        'Add Customer',
                        style: portalText(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF26204A),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
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

  // Customer Referral Details Modal (Matching Reference View Image)
  void _showCustomerDetail(OpCustomerReferralUi customer) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
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
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with Blue Share/Referral Icon, Title, and ID
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 12, 12),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2563EB),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.share_rounded,
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
                            'Customer Referral Details',
                            style: portalText(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'ID: ${customer.id.length > 8 ? customer.id : '6af7e2220983f737bb8bf4bd'}',
                            style: portalText(
                              fontSize: 11,
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

              // Inner Box Container
              Padding(
                padding: const EdgeInsets.all(16),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Avatar & Name + Phone
                      Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: customer.avatarColor,
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              customer.name.isNotEmpty
                                  ? customer.name[0].toUpperCase()
                                  : 'C',
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
                                const SizedBox(height: 2),
                                Text(
                                  customer.phone,
                                  style: portalText(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),
                      const SizedBox(height: 12),

                      // ADDRESS
                      Text(
                        'ADDRESS',
                        style: portalText(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF94A3B8),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        customer.location,
                        style: portalText(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),
                      const SizedBox(height: 12),

                      // CONSULTANT FEE
                      Text(
                        'CONSULTANT FEE',
                        style: portalText(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF94A3B8),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _detailFeeBox(
                              'Service',
                              customer.serviceRate,
                              const Color(0xFFEFF6FF),
                              const Color(0xFFBFDBFE),
                              const Color(0xFF2563EB),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: _detailFeeBox(
                              'Pharmacy',
                              customer.pharmacyRate,
                              const Color(0xFFECFDF5),
                              const Color(0xFFA7F3D0),
                              const Color(0xFF059669),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: _detailFeeBox(
                              'Lab',
                              customer.labRate,
                              const Color(0xFFF5F3FF),
                              const Color(0xFFDDD6FE),
                              const Color(0xFF7C3AED),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: _detailFeeBox(
                              'Fees',
                              customer.fees,
                              const Color(0xFFFFF7ED),
                              const Color(0xFFFED7AA),
                              const Color(0xFFEA580C),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),
                      const SizedBox(height: 12),

                      // OP METRICS
                      Text(
                        'OP METRICS',
                        style: portalText(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF94A3B8),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEEF2FF),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: const Color(0xFFE0E7FF)),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    'OP Count',
                                    style: portalText(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF4F46E5),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${customer.opCount}',
                                    style: portalText(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFF312E81),
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
                                color: const Color(0xFFECFDF5),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: const Color(0xFFD1FAE5)),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    'Revenue',
                                    style: portalText(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF059669),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    customer.revenue,
                                    style: portalText(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFF065F46),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),
                      const SizedBox(height: 12),

                      // ONBOARD DATE
                      Text(
                        'ONBOARD DATE',
                        style: portalText(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF94A3B8),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        customer.onboardDate,
                        style: portalText(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom Action Buttons: Print, Edit, Close
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Print
                    GestureDetector(
                      onTap: () {
                        _snack('Printing details for ${customer.name}...');
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.print_outlined,
                              size: 16,
                              color: Color(0xFF334155),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Print',
                              style: portalText(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF334155),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Edit
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(ctx);
                        _showEditCustomerSheet(customer);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEEF2FF),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFC7D2FE)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.edit_outlined,
                              size: 16,
                              color: Color(0xFF4F46E5),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Edit',
                              style: portalText(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF4F46E5),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Close
                    GestureDetector(
                      onTap: () => Navigator.pop(ctx),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2563EB),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'Close',
                          style: portalText(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
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
      ),
    );
  }

  Widget _detailFeeBox(String title, String val, Color bg, Color border, Color textCol) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: border),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: portalText(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: textCol,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            val,
            style: portalText(
              fontSize: 13.5,
              fontWeight: FontWeight.w800,
              color: textCol,
            ),
          ),
        ],
      ),
    );
  }

  // Edit Customer Referral Modal (Matching Reference Edit Image)
  void _showEditCustomerSheet(OpCustomerReferralUi customer) {
    final nameCtrl = TextEditingController(text: customer.name);
    final orgCtrl = TextEditingController(
      text: customer.organization == 'N/A' ? '' : customer.organization,
    );
    final phoneCtrl = TextEditingController(text: customer.phone);
    final locCtrl = TextEditingController(
      text: customer.location == 'N/A' ? '' : customer.location,
    );
    // Special offers (discount)
    final specFeesCtrl = TextEditingController(text: customer.specialFees);
    final specLabCtrl = TextEditingController(text: customer.specialLab);
    final specPharmCtrl = TextEditingController(text: customer.specialPharmacy);
    final notesCtrl = TextEditingController(text: customer.notes);
    // Consultant fee (numeric string)
    final serviceCtrl = TextEditingController(
      text: customer.serviceRate.replaceAll('%', '').trim(),
    );
    final pharmacyCtrl = TextEditingController(
      text: customer.pharmacyRate.replaceAll('%', '').trim(),
    );
    final labCtrl = TextEditingController(
      text: customer.labRate.replaceAll('%', '').trim(),
    );
    final feesCtrl = TextEditingController(
      text: customer.fees.replaceAll('%', '').replaceAll('₹', '').trim(),
    );
    String editDate = customer.onboardDate;
    bool editIsActive = customer.isActive;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Container(
          margin: EdgeInsets.only(
            left: 12,
            right: 12,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
            top: 24,
          ),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(ctx).size.height * 0.9,
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 12, 12),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: const Color(0xFF26204A),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.person_add_alt_1_rounded,
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
                            'Edit Customer Referral',
                            style: portalText(
                              fontSize: 15.5,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Fill in the customer referral details below',
                            style: portalText(
                              fontSize: 11,
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

              // Scrollable Body
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // BASIC INFORMATION
                      Text(
                        'BASIC INFORMATION',
                        style: portalText(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF94A3B8),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _buildFormField(
                        label: 'CUSTOMER NAME *',
                        controller: nameCtrl,
                        icon: Icons.person_outline_rounded,
                        hint: 'Enter full name',
                      ),
                      const SizedBox(height: 10),
                      _buildFormField(
                        label: 'ORGANISATION NAME',
                        controller: orgCtrl,
                        icon: Icons.account_balance_rounded,
                        hint: 'Enter organization',
                      ),
                      const SizedBox(height: 10),
                      _buildFormField(
                        label: 'PHONE NUMBER *',
                        controller: phoneCtrl,
                        icon: Icons.phone_outlined,
                        hint: '10-digit mobile number',
                        keyboard: TextInputType.phone,
                      ),
                      const SizedBox(height: 10),
                      _buildFormField(
                        label: 'ADDRESS',
                        controller: locCtrl,
                        icon: Icons.location_on_outlined,
                        hint: 'Enter address',
                      ),
                      const SizedBox(height: 14),

                      // SPECIAL OFFERS (DISCOUNT) Box
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFBEB),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFFDE68A)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.card_giftcard_rounded,
                                  size: 16,
                                  color: Color(0xFFD97706),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'SPECIAL OFFERS (DISCOUNT)',
                                  style: portalText(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFFB45309),
                                    letterSpacing: 0.4,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildSuffixPillInput(
                                    label: 'FEES',
                                    controller: specFeesCtrl,
                                    icon: Icons.confirmation_number_outlined,
                                    iconColor: const Color(0xFFEA580C),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _buildSuffixPillInput(
                                    label: 'LAB',
                                    controller: specLabCtrl,
                                    icon: Icons.science_outlined,
                                    iconColor: const Color(0xFF7C3AED),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _buildSuffixPillInput(
                                    label: 'PHARMACY',
                                    controller: specPharmCtrl,
                                    icon: Icons.local_pharmacy_outlined,
                                    iconColor: const Color(0xFF059669),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      // CONSULTANT FEE
                      Text(
                        'CONSULTANT FEE',
                        style: portalText(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF94A3B8),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _buildSuffixPillInput(
                              label: 'SERVICE',
                              controller: serviceCtrl,
                              icon: Icons.design_services_outlined,
                              iconColor: const Color(0xFF2563EB),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: _buildSuffixPillInput(
                              label: 'PHARMACY',
                              controller: pharmacyCtrl,
                              icon: Icons.local_pharmacy_outlined,
                              iconColor: const Color(0xFF059669),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: _buildSuffixPillInput(
                              label: 'LAB',
                              controller: labCtrl,
                              icon: Icons.science_outlined,
                              iconColor: const Color(0xFF7C3AED),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: _buildSuffixPillInput(
                              label: 'FEES',
                              controller: feesCtrl,
                              icon: Icons.confirmation_number_outlined,
                              iconColor: const Color(0xFFEA580C),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // ADDITIONAL DETAILS
                      Text(
                        'ADDITIONAL DETAILS',
                        style: portalText(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF94A3B8),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          // ONBOARD DATE
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'ONBOARD DATE',
                                  style: portalText(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF475569),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                GestureDetector(
                                  onTap: () async {
                                    final picked = await showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime(2020),
                                      lastDate: DateTime(2030),
                                    );
                                    if (picked != null) {
                                      final months = [
                                        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                                        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
                                      ];
                                      setModalState(() {
                                        editDate =
                                            '${picked.day.toString().padLeft(2, '0')} ${months[picked.month - 1]} ${picked.year}';
                                      });
                                    }
                                  },
                                  child: Container(
                                    height: 42,
                                    padding: const EdgeInsets.symmetric(horizontal: 10),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: const Color(0xFFE2E8F0)),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.calendar_today_outlined,
                                          size: 14,
                                          color: Color(0xFF64748B),
                                        ),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            editDate,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: portalText(
                                              fontSize: 11.5,
                                              fontWeight: FontWeight.w600,
                                              color: const Color(0xFF0F172A),
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
                          const SizedBox(width: 10),
                          // STATUS
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'STATUS',
                                  style: portalText(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF475569),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                GestureDetector(
                                  onTap: () {
                                    setModalState(() {
                                      editIsActive = !editIsActive;
                                    });
                                  },
                                  child: Container(
                                    height: 42,
                                    padding: const EdgeInsets.symmetric(horizontal: 10),
                                    decoration: BoxDecoration(
                                      color: editIsActive
                                          ? const Color(0xFFECFDF5)
                                          : const Color(0xFFFEF2F2),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: editIsActive
                                            ? const Color(0xFFD1FAE5)
                                            : const Color(0xFFFECACA),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 7,
                                          height: 7,
                                          decoration: BoxDecoration(
                                            color: editIsActive
                                                ? const Color(0xFF10B981)
                                                : const Color(0xFFEF4444),
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            editIsActive ? 'Active' : 'Inactive',
                                            style: portalText(
                                              fontSize: 11.5,
                                              fontWeight: FontWeight.w700,
                                              color: editIsActive
                                                  ? const Color(0xFF059669)
                                                  : const Color(0xFFDC2626),
                                            ),
                                          ),
                                        ),
                                        const Icon(
                                          Icons.swap_horiz_rounded,
                                          size: 16,
                                          color: Color(0xFF94A3B8),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // NOTES
                      Text(
                        'NOTES',
                        style: portalText(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF94A3B8),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: TextField(
                          controller: notesCtrl,
                          maxLines: 3,
                          style: portalText(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF0F172A),
                          ),
                          decoration: InputDecoration(
                            hintText: 'Add any additional notes...',
                            hintStyle: portalText(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF94A3B8),
                            ),
                            contentPadding: const EdgeInsets.all(12),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom Actions: Cancel & Update Customer
              const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(ctx),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: const BorderSide(color: Color(0xFFE2E8F0)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: portalText(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: () {
                          final updatedName = nameCtrl.text.trim();
                          if (updatedName.isEmpty) return;
                          final idx = _customers.indexWhere((c) => c.id == customer.id);
                          if (idx != -1) {
                            setState(() {
                              _customers[idx] = customer.copyWith(
                                name: updatedName,
                                organization: orgCtrl.text.trim().isEmpty ? 'N/A' : orgCtrl.text.trim(),
                                phone: phoneCtrl.text.trim().isEmpty ? customer.phone : phoneCtrl.text.trim(),
                                location: locCtrl.text.trim().isEmpty ? 'N/A' : locCtrl.text.trim(),
                                specialFees: specFeesCtrl.text.trim().isEmpty ? '0' : specFeesCtrl.text.trim(),
                                specialLab: specLabCtrl.text.trim().isEmpty ? '0' : specLabCtrl.text.trim(),
                                specialPharmacy: specPharmCtrl.text.trim().isEmpty ? '0' : specPharmCtrl.text.trim(),
                                serviceRate: serviceCtrl.text.trim().contains('%')
                                    ? serviceCtrl.text.trim()
                                    : '${serviceCtrl.text.trim()}%',
                                pharmacyRate: pharmacyCtrl.text.trim().contains('%')
                                    ? pharmacyCtrl.text.trim()
                                    : '${pharmacyCtrl.text.trim()}%',
                                labRate: labCtrl.text.trim().contains('%')
                                    ? labCtrl.text.trim()
                                    : '${labCtrl.text.trim()}%',
                                fees: feesCtrl.text.trim().contains('%') || feesCtrl.text.trim().contains('₹')
                                    ? feesCtrl.text.trim()
                                    : '${feesCtrl.text.trim()}%',
                                onboardDate: editDate,
                                isActive: editIsActive,
                                notes: notesCtrl.text.trim(),
                              );
                            });
                          }
                          Navigator.pop(ctx);
                          _snack('Customer "$updatedName" updated successfully');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4F46E5),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.check_circle_outline_rounded,
                              size: 16,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Update Customer',
                              style: portalText(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    TextInputType keyboard = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: portalText(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF475569),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          height: 42,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 10, right: 8),
                child: Icon(icon, size: 16, color: const Color(0xFF94A3B8)),
              ),
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: keyboard,
                  style: portalText(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF0F172A),
                  ),
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: portalText(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF94A3B8),
                    ),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 11),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSuffixPillInput({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required Color iconColor,
    String hint = '0',
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: iconColor),
            const SizedBox(width: 3),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: portalText(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w800,
                  color: iconColor,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Container(
          height: 38,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: TextField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                    style: portalText(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0F172A),
                    ),
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 9),
                      border: InputBorder.none,
                      hintText: hint,
                      hintStyle: portalText(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF94A3B8),
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                width: 28,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(7),
                    bottomRight: Radius.circular(7),
                  ),
                  border: Border(
                    left: BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                ),
                child: Text(
                  '%',
                  style: portalText(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _deleteCustomer(OpCustomerReferralUi customer) {
    setState(() {
      _customers.removeWhere((c) => c.id == customer.id);
    });
    _snack('Customer "${customer.name}" removed');
  }

  void _deleteDoctor(OpDoctorReferralUi doc) {
    setState(() {
      _doctors.removeWhere((d) => d.id == doc.id);
    });
    _snack('Doctor "${doc.name}" removed');
  }

  // Doctor Referral Details Modal (Matching Reference Image 2)
  void _showDoctorDetail(OpDoctorReferralUi doc) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
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
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with Blue Share/Referral Icon, Title, and ID
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 12, 12),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2563EB),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.share_rounded,
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
                            'Doctor Referral Details',
                            style: portalText(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'ID: ${doc.id}',
                            style: portalText(
                              fontSize: 11,
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

              // Inner Card Container
              Padding(
                padding: const EdgeInsets.all(16),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Avatar & Doctor Name + Clinic/Phone
                      Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: doc.avatarColor,
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              doc.name.isNotEmpty
                                  ? doc.name[0].toUpperCase()
                                  : 'D',
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
                                  doc.name,
                                  style: portalText(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF0F172A),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${doc.clinic} • ${doc.phone}',
                                  style: portalText(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),
                      const SizedBox(height: 12),

                      // ADDRESS
                      Text(
                        'ADDRESS',
                        style: portalText(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF94A3B8),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        doc.address,
                        style: portalText(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),
                      const SizedBox(height: 12),

                      // SPECIALIZATION
                      Text(
                        'SPECIALIZATION',
                        style: portalText(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF94A3B8),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        doc.specialization,
                        style: portalText(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),
                      const SizedBox(height: 12),

                      // CONSULTANT FEE
                      Text(
                        'CONSULTANT FEE',
                        style: portalText(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF94A3B8),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _detailFeeBox(
                              'Service',
                              doc.serviceRate,
                              const Color(0xFFEFF6FF),
                              const Color(0xFFBFDBFE),
                              const Color(0xFF2563EB),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: _detailFeeBox(
                              'Pharmacy',
                              doc.pharmacyRate,
                              const Color(0xFFECFDF5),
                              const Color(0xFFA7F3D0),
                              const Color(0xFF059669),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: _detailFeeBox(
                              'Lab',
                              doc.labRate,
                              const Color(0xFFF5F3FF),
                              const Color(0xFFDDD6FE),
                              const Color(0xFF7C3AED),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: _detailFeeBox(
                              'Fees',
                              doc.fees,
                              const Color(0xFFFFF7ED),
                              const Color(0xFFFED7AA),
                              const Color(0xFFEA580C),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),
                      const SizedBox(height: 12),

                      // OP METRICS
                      Text(
                        'OP METRICS',
                        style: portalText(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF94A3B8),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEEF2FF),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: const Color(0xFFE0E7FF)),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    'OP Count',
                                    style: portalText(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF4F46E5),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${doc.opCount}',
                                    style: portalText(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFF312E81),
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
                                color: const Color(0xFFECFDF5),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: const Color(0xFFD1FAE5)),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    'Revenue',
                                    style: portalText(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF059669),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    doc.revenue,
                                    style: portalText(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFF065F46),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),
                      const SizedBox(height: 12),

                      // ONBOARD DATE
                      Text(
                        'ONBOARD DATE',
                        style: portalText(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF94A3B8),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        doc.onboardDate,
                        style: portalText(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom Action Buttons: Print, Edit, Close
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Print
                    GestureDetector(
                      onTap: () {
                        _snack('Printing details for ${doc.name}...');
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.print_outlined,
                              size: 16,
                              color: Color(0xFF334155),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Print',
                              style: portalText(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF334155),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Edit
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(ctx);
                        _showEditDoctorSheet(doc);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEEF2FF),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFC7D2FE)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.edit_outlined,
                              size: 16,
                              color: Color(0xFF4F46E5),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Edit',
                              style: portalText(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF4F46E5),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Close
                    GestureDetector(
                      onTap: () => Navigator.pop(ctx),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2563EB),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'Close',
                          style: portalText(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
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
      ),
    );
  }

  // Edit Doctor Referral Modal (Matching Reference Edit Image)
  void _showEditDoctorSheet(OpDoctorReferralUi doc) {
    final nameCtrl = TextEditingController(text: doc.name);
    final clinicCtrl = TextEditingController(text: doc.clinic);
    final phoneCtrl = TextEditingController(text: doc.phone == 'N/A' ? '' : doc.phone);
    final locCtrl = TextEditingController(text: doc.location);
    final addrCtrl = TextEditingController(text: doc.address);
    final specCtrl = TextEditingController(text: doc.specialization);
    // Special offers (discount)
    final specFeesCtrl = TextEditingController(text: doc.specialFees);
    final specLabCtrl = TextEditingController(text: doc.specialLab);
    final specPharmCtrl = TextEditingController(text: doc.specialPharmacy);
    // Consultant fee (numeric string)
    final serviceCtrl = TextEditingController(text: doc.serviceRate.replaceAll('%', '').trim());
    final pharmacyCtrl = TextEditingController(text: doc.pharmacyRate.replaceAll('%', '').trim());
    final labCtrl = TextEditingController(text: doc.labRate.replaceAll('%', '').trim());
    final feesCtrl = TextEditingController(text: doc.fees.replaceAll('%', '').replaceAll('₹', '').trim());
    final notesCtrl = TextEditingController(text: doc.notes);
    String editDate = doc.onboardDate;
    bool editIsActive = doc.isActive;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Container(
          margin: EdgeInsets.only(
            left: 12,
            right: 12,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
            top: 24,
          ),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(ctx).size.height * 0.9,
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 12, 12),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: const Color(0xFF26204A),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.medical_services_outlined,
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
                            'Edit Doctor Referral',
                            style: portalText(
                              fontSize: 15.5,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Fill in the doctor referral details below',
                            style: portalText(
                              fontSize: 11,
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

              // Scrollable Body
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // BASIC INFORMATION
                      Text(
                        'BASIC INFORMATION',
                        style: portalText(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF94A3B8),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _buildFormField(
                        label: 'DOCTOR NAME *',
                        controller: nameCtrl,
                        icon: Icons.person_outline_rounded,
                        hint: 'Enter doctor name',
                      ),
                      const SizedBox(height: 10),
                      _buildFormField(
                        label: 'ORGANISATION NAME *',
                        controller: clinicCtrl,
                        icon: Icons.account_balance_rounded,
                        hint: 'Enter clinic name',
                      ),
                      const SizedBox(height: 10),
                      _buildFormField(
                        label: 'PHONE NUMBER',
                        controller: phoneCtrl,
                        icon: Icons.phone_outlined,
                        hint: '10-digit mobile number or N/A',
                        keyboard: TextInputType.phone,
                      ),
                      const SizedBox(height: 10),
                      _buildFormField(
                        label: 'SPECIALIZATION',
                        controller: specCtrl,
                        icon: Icons.health_and_safety_outlined,
                        hint: 'e.g. FAMILY PHYSICIAN',
                      ),
                      const SizedBox(height: 10),
                      _buildFormField(
                        label: 'ADDRESS',
                        controller: addrCtrl,
                        icon: Icons.location_on_outlined,
                        hint: 'Enter clinic address',
                      ),
                      const SizedBox(height: 14),

                      // SPECIAL OFFERS (DISCOUNT) Box
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFBEB),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFFDE68A)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.card_giftcard_rounded,
                                  size: 16,
                                  color: Color(0xFFD97706),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'SPECIAL OFFERS (DISCOUNT)',
                                  style: portalText(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFFB45309),
                                    letterSpacing: 0.4,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildSuffixPillInput(
                                    label: 'FEES',
                                    controller: specFeesCtrl,
                                    icon: Icons.confirmation_number_outlined,
                                    iconColor: const Color(0xFFEA580C),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _buildSuffixPillInput(
                                    label: 'LAB',
                                    controller: specLabCtrl,
                                    icon: Icons.science_outlined,
                                    iconColor: const Color(0xFF7C3AED),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _buildSuffixPillInput(
                                    label: 'PHARMACY',
                                    controller: specPharmCtrl,
                                    icon: Icons.local_pharmacy_outlined,
                                    iconColor: const Color(0xFF059669),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      // CONSULTANT FEE
                      Text(
                        'CONSULTANT FEE',
                        style: portalText(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF94A3B8),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _buildSuffixPillInput(
                              label: 'SERVICE',
                              controller: serviceCtrl,
                              icon: Icons.design_services_outlined,
                              iconColor: const Color(0xFF2563EB),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: _buildSuffixPillInput(
                              label: 'PHARMACY',
                              controller: pharmacyCtrl,
                              icon: Icons.local_pharmacy_outlined,
                              iconColor: const Color(0xFF059669),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: _buildSuffixPillInput(
                              label: 'LAB',
                              controller: labCtrl,
                              icon: Icons.science_outlined,
                              iconColor: const Color(0xFF7C3AED),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: _buildSuffixPillInput(
                              label: 'FEES',
                              controller: feesCtrl,
                              icon: Icons.confirmation_number_outlined,
                              iconColor: const Color(0xFFEA580C),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // ADDITIONAL DETAILS
                      Text(
                        'ADDITIONAL DETAILS',
                        style: portalText(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF94A3B8),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          // ONBOARD DATE
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'ONBOARD DATE',
                                  style: portalText(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF475569),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                GestureDetector(
                                  onTap: () async {
                                    final picked = await showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime(2020),
                                      lastDate: DateTime(2030),
                                    );
                                    if (picked != null) {
                                      final months = [
                                        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                                        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
                                      ];
                                      setModalState(() {
                                        editDate =
                                            '${picked.day.toString().padLeft(2, '0')} ${months[picked.month - 1]} ${picked.year}';
                                      });
                                    }
                                  },
                                  child: Container(
                                    height: 42,
                                    padding: const EdgeInsets.symmetric(horizontal: 10),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: const Color(0xFFE2E8F0)),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.calendar_today_outlined, size: 14, color: Color(0xFF64748B)),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            editDate,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: portalText(
                                              fontSize: 11.5,
                                              fontWeight: FontWeight.w600,
                                              color: const Color(0xFF0F172A),
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
                          const SizedBox(width: 10),
                          // STATUS
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'STATUS',
                                  style: portalText(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF475569),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                GestureDetector(
                                  onTap: () {
                                    setModalState(() {
                                      editIsActive = !editIsActive;
                                    });
                                  },
                                  child: Container(
                                    height: 42,
                                    padding: const EdgeInsets.symmetric(horizontal: 10),
                                    decoration: BoxDecoration(
                                      color: editIsActive ? const Color(0xFFECFDF5) : const Color(0xFFFEF2F2),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: editIsActive ? const Color(0xFFD1FAE5) : const Color(0xFFFECACA),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 7,
                                          height: 7,
                                          decoration: BoxDecoration(
                                            color: editIsActive ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            editIsActive ? 'active' : 'inactive',
                                            style: portalText(
                                              fontSize: 11.5,
                                              fontWeight: FontWeight.w700,
                                              color: editIsActive ? const Color(0xFF059669) : const Color(0xFFDC2626),
                                            ),
                                          ),
                                        ),
                                        const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: Color(0xFF94A3B8)),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // NOTES
                      Text(
                        'NOTES',
                        style: portalText(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF94A3B8),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: TextField(
                          controller: notesCtrl,
                          maxLines: 3,
                          style: portalText(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF0F172A),
                          ),
                          decoration: InputDecoration(
                            hintText: 'Add any additional notes...',
                            hintStyle: portalText(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF94A3B8),
                            ),
                            contentPadding: const EdgeInsets.all(12),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom Actions: Cancel & Update Doctor
              const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(ctx),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: const BorderSide(color: Color(0xFFE2E8F0)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: portalText(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: () {
                          final updatedName = nameCtrl.text.trim();
                          if (updatedName.isEmpty) return;
                          final idx = _doctors.indexWhere((d) => d.id == doc.id);
                          if (idx != -1) {
                            setState(() {
                              _doctors[idx] = doc.copyWith(
                                name: updatedName,
                                clinic: clinicCtrl.text.trim().isEmpty ? 'N/A' : clinicCtrl.text.trim(),
                                phone: phoneCtrl.text.trim().isEmpty ? 'N/A' : phoneCtrl.text.trim(),
                                location: locCtrl.text.trim().isEmpty ? doc.location : locCtrl.text.trim(),
                                address: addrCtrl.text.trim().isEmpty ? doc.address : addrCtrl.text.trim(),
                                specialization: specCtrl.text.trim().isEmpty ? doc.specialization : specCtrl.text.trim(),
                                specialFees: specFeesCtrl.text.trim().isEmpty ? '0' : specFeesCtrl.text.trim(),
                                specialLab: specLabCtrl.text.trim().isEmpty ? '0' : specLabCtrl.text.trim(),
                                specialPharmacy: specPharmCtrl.text.trim().isEmpty ? '0' : specPharmCtrl.text.trim(),
                                serviceRate: serviceCtrl.text.trim().contains('%')
                                    ? serviceCtrl.text.trim()
                                    : '${serviceCtrl.text.trim()}%',
                                pharmacyRate: pharmacyCtrl.text.trim().contains('%')
                                    ? pharmacyCtrl.text.trim()
                                    : '${pharmacyCtrl.text.trim()}%',
                                labRate: labCtrl.text.trim().contains('%')
                                    ? labCtrl.text.trim()
                                    : '${labCtrl.text.trim()}%',
                                fees: feesCtrl.text.trim().contains('%') || feesCtrl.text.trim().contains('₹')
                                    ? feesCtrl.text.trim()
                                    : '${feesCtrl.text.trim()}%',
                                onboardDate: editDate,
                                isActive: editIsActive,
                                notes: notesCtrl.text.trim(),
                              );
                            });
                          }
                          Navigator.pop(ctx);
                          _snack('Doctor "$updatedName" updated successfully');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF9333EA),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.check_circle_outline_rounded, size: 16, color: Colors.white),
                            const SizedBox(width: 6),
                            Text(
                              'Update Doctor',
                              style: portalText(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddDoctorSheet() {
    final nameCtrl = TextEditingController();
    final clinicCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final specCtrl = TextEditingController();
    final locCtrl = TextEditingController();
    // Special offers (discount)
    final specFeesCtrl = TextEditingController();
    final specLabCtrl = TextEditingController();
    final specPharmCtrl = TextEditingController();
    // Consultant fee (numeric string)
    final serviceCtrl = TextEditingController();
    final pharmacyCtrl = TextEditingController();
    final labCtrl = TextEditingController();
    final feesCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    String onboardDateStr = 'dd/mm/yyyy';
    String statusValue = 'active';

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Container(
          margin: EdgeInsets.only(
            left: 12,
            right: 12,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
            top: 24,
          ),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(ctx).size.height * 0.9,
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 12, 12),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: const Color(0xFF26204A),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.medical_services_outlined,
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
                            'Add Doctor Referral',
                            style: portalText(
                              fontSize: 15.5,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Fill in the doctor referral details below',
                            style: portalText(
                              fontSize: 11,
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

              // Scrollable Body
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // BASIC INFORMATION
                      Text(
                        'BASIC INFORMATION',
                        style: portalText(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF94A3B8),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _buildFormField(
                        label: 'DOCTOR NAME *',
                        controller: nameCtrl,
                        icon: Icons.badge_outlined,
                        hint: 'Dr. Jane Smith',
                      ),
                      const SizedBox(height: 10),
                      _buildFormField(
                        label: 'ORGANISATION NAME *',
                        controller: clinicCtrl,
                        icon: Icons.apartment_rounded,
                        hint: 'City Hospital',
                      ),
                      const SizedBox(height: 10),
                      _buildFormField(
                        label: 'PHONE NUMBER',
                        controller: phoneCtrl,
                        icon: Icons.phone_outlined,
                        hint: '+91 9876543210',
                        keyboard: TextInputType.phone,
                      ),
                      const SizedBox(height: 10),
                      _buildFormField(
                        label: 'SPECIALIZATION',
                        controller: specCtrl,
                        icon: Icons.person_search_outlined,
                        hint: 'Cardiologist',
                      ),
                      const SizedBox(height: 10),
                      _buildFormField(
                        label: 'ADDRESS',
                        controller: locCtrl,
                        icon: Icons.location_on_outlined,
                        hint: 'Clinic/Hospital full address',
                      ),
                      const SizedBox(height: 14),

                      // SPECIAL OFFERS (DISCOUNT) Box
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFBEB),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFFDE68A)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.card_giftcard_rounded,
                                  size: 16,
                                  color: Color(0xFFD97706),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'SPECIAL OFFERS (DISCOUNT)',
                                  style: portalText(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFFB45309),
                                    letterSpacing: 0.4,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildSuffixPillInput(
                                    label: 'FEES',
                                    controller: specFeesCtrl,
                                    icon: Icons.confirmation_number_outlined,
                                    iconColor: const Color(0xFFEA580C),
                                    hint: '0',
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _buildSuffixPillInput(
                                    label: 'LAB',
                                    controller: specLabCtrl,
                                    icon: Icons.science_outlined,
                                    iconColor: const Color(0xFF7C3AED),
                                    hint: '0',
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _buildSuffixPillInput(
                                    label: 'PHARMACY',
                                    controller: specPharmCtrl,
                                    icon: Icons.local_pharmacy_outlined,
                                    iconColor: const Color(0xFF059669),
                                    hint: '0',
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      // CONSULTANT FEE
                      Text(
                        'CONSULTANT FEE',
                        style: portalText(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF94A3B8),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _buildSuffixPillInput(
                              label: 'SERVICE',
                              controller: serviceCtrl,
                              icon: Icons.design_services_outlined,
                              iconColor: const Color(0xFF2563EB),
                              hint: '0',
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: _buildSuffixPillInput(
                              label: 'PHARMACY',
                              controller: pharmacyCtrl,
                              icon: Icons.local_pharmacy_outlined,
                              iconColor: const Color(0xFF059669),
                              hint: '0',
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: _buildSuffixPillInput(
                              label: 'LAB',
                              controller: labCtrl,
                              icon: Icons.science_outlined,
                              iconColor: const Color(0xFF7C3AED),
                              hint: '0',
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: _buildSuffixPillInput(
                              label: 'FEES',
                              controller: feesCtrl,
                              icon: Icons.confirmation_number_outlined,
                              iconColor: const Color(0xFFEA580C),
                              hint: '0',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // ADDITIONAL DETAILS
                      Text(
                        'ADDITIONAL DETAILS',
                        style: portalText(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF94A3B8),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          // ONBOARD DATE
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'ONBOARD DATE',
                                  style: portalText(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF475569),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                GestureDetector(
                                  onTap: () async {
                                    final picked = await showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime(2020),
                                      lastDate: DateTime(2030),
                                    );
                                    if (picked != null) {
                                      final months = [
                                        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                                        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
                                      ];
                                      setModalState(() {
                                        onboardDateStr =
                                            '${picked.day.toString().padLeft(2, '0')} ${months[picked.month - 1]} ${picked.year}';
                                      });
                                    }
                                  },
                                  child: Container(
                                    height: 42,
                                    padding: const EdgeInsets.symmetric(horizontal: 10),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: const Color(0xFFE2E8F0)),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            onboardDateStr,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: portalText(
                                              fontSize: 11.5,
                                              fontWeight: FontWeight.w600,
                                              color: onboardDateStr == 'dd/mm/yyyy'
                                                  ? const Color(0xFF94A3B8)
                                                  : const Color(0xFF0F172A),
                                            ),
                                          ),
                                        ),
                                        const Icon(
                                          Icons.calendar_today_outlined,
                                          size: 14,
                                          color: Color(0xFF64748B),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          // STATUS
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'STATUS',
                                  style: portalText(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF475569),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  height: 42,
                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: const Color(0xFFE2E8F0)),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: statusValue,
                                      isExpanded: true,
                                      icon: const Icon(
                                        Icons.keyboard_arrow_down_rounded,
                                        size: 18,
                                        color: Color(0xFF64748B),
                                      ),
                                      style: portalText(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF0F172A),
                                      ),
                                      items: const [
                                        DropdownMenuItem(
                                          value: 'active',
                                          child: Text('active'),
                                        ),
                                        DropdownMenuItem(
                                          value: 'inactive',
                                          child: Text('inactive'),
                                        ),
                                      ],
                                      onChanged: (val) {
                                        if (val != null) {
                                          setModalState(() => statusValue = val);
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

                      // NOTES
                      Text(
                        'NOTES',
                        style: portalText(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF94A3B8),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: TextField(
                          controller: notesCtrl,
                          maxLines: 3,
                          style: portalText(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF0F172A),
                          ),
                          decoration: InputDecoration(
                            isDense: true,
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.all(10),
                            hintText: 'Add any additional notes...',
                            hintStyle: portalText(
                              fontSize: 11.5,
                              color: const Color(0xFF94A3B8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom Action Buttons: Cancel and Add Doctor
              const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                child: Row(
                  children: [
                    const Spacer(),
                    OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
                        side: const BorderSide(color: Color(0xFFCBD5E1)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: portalText(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF475569),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton.icon(
                      onPressed: () {
                        final name = nameCtrl.text.trim();
                        if (name.isEmpty) {
                          _snack('Please enter Doctor Name');
                          return;
                        }
                        final clinic = clinicCtrl.text.trim().isEmpty ? 'N/A' : clinicCtrl.text.trim();
                        final phone = phoneCtrl.text.trim().isEmpty ? 'N/A' : phoneCtrl.text.trim();
                        final spec = specCtrl.text.trim().isEmpty ? 'GENERAL PHYSICIAN' : specCtrl.text.trim();
                        final address = locCtrl.text.trim().isEmpty ? 'HYDERABAD' : locCtrl.text.trim();
                        final sRate = serviceCtrl.text.trim().isEmpty ? '0%' : (serviceCtrl.text.trim().contains('%') ? serviceCtrl.text.trim() : '${serviceCtrl.text.trim()}%');
                        final pRate = pharmacyCtrl.text.trim().isEmpty ? '0%' : (pharmacyCtrl.text.trim().contains('%') ? pharmacyCtrl.text.trim() : '${pharmacyCtrl.text.trim()}%');
                        final lRate = labCtrl.text.trim().isEmpty ? '0%' : (labCtrl.text.trim().contains('%') ? labCtrl.text.trim() : '${labCtrl.text.trim()}%');
                        final fee = feesCtrl.text.trim().isEmpty ? '0%' : (feesCtrl.text.trim().contains('%') ? feesCtrl.text.trim() : '${feesCtrl.text.trim()}%');

                        setState(() {
                          _doctors.insert(
                            0,
                            OpDoctorReferralUi(
                              id: 'doc_${DateTime.now().millisecondsSinceEpoch}',
                              name: name,
                              clinic: clinic,
                              phone: phone,
                              location: address,
                              address: address,
                              specialization: spec,
                              isActive: statusValue == 'active',
                              serviceRate: sRate,
                              pharmacyRate: pRate,
                              labRate: lRate,
                              fees: fee,
                              onboardDate: onboardDateStr == 'dd/mm/yyyy' ? 'Today' : onboardDateStr,
                              specialFees: specFeesCtrl.text.trim().isEmpty ? '0' : specFeesCtrl.text.trim(),
                              specialLab: specLabCtrl.text.trim().isEmpty ? '0' : specLabCtrl.text.trim(),
                              specialPharmacy: specPharmCtrl.text.trim().isEmpty ? '0' : specPharmCtrl.text.trim(),
                              notes: notesCtrl.text.trim(),
                              avatarColor: const Color(0xFF26204A),
                            ),
                          );
                        });
                        Navigator.pop(ctx);
                        _snack('Doctor "$name" added successfully');
                      },
                      icon: const Icon(Icons.person_add_alt_1_rounded, size: 16),
                      label: Text(
                        'Add Doctor',
                        style: portalText(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF26204A),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                  children: [
                    // Segmented Tabs: Customer Referrals (15) / Doctor Referrals (3)
                    _buildSegmentedTabs(),
                    const SizedBox(height: 14),
                    // Action Buttons: Referred OP / + Add Customer
                    _buildActionButtons(),
                    const SizedBox(height: 14),
                    // KPI / Stats Grid (Row of 4)
                    _buildKpiRow(),
                    const SizedBox(height: 14),
                    // Search Bar
                    _buildSearchBar(),
                    const SizedBox(height: 10),
                    // Filter Row: Date / Status / Export CSV
                    _buildFilterPillsRow(),
                    const SizedBox(height: 14),
                    // Records Header
                    _buildRecordsHeader(
                      _selectedTab == 0
                          ? filteredCustomers.length
                          : filteredDoctors.length,
                    ),
                    const SizedBox(height: 12),
                    // List of Cards
                    if (_selectedTab == 0) ...[
                      for (final customer in filteredCustomers) ...[
                        _buildCustomerCard(customer),
                        const SizedBox(height: 12),
                      ],
                      if (filteredCustomers.isEmpty) _buildEmptyState('No customer referrals found'),
                    ] else ...[
                      for (final doc in filteredDoctors) ...[
                        _buildDoctorCard(doc),
                        const SizedBox(height: 12),
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

  // Segmented Tabs: Customer Referrals / Doctor Referrals (Exact original style, slightly bigger height: 48)
  Widget _buildSegmentedTabs() {
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
                      'Customer Referrals',
                      style: portalText(
                        fontSize: 12,
                        fontWeight: _selectedTab == 0 ? FontWeight.w800 : FontWeight.w600,
                        color: _selectedTab == 0
                            ? const Color(0xFF1E1B4B)
                            : const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(width: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6.5, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: _selectedTab == 0 ? const Color(0xFFF1F5F9) : const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${_customers.length}',
                        style: portalText(
                          fontSize: 10,
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
                      'Doctor Referrals',
                      style: portalText(
                        fontSize: 12,
                        fontWeight: _selectedTab == 1 ? FontWeight.w800 : FontWeight.w600,
                        color: _selectedTab == 1
                            ? const Color(0xFF1E1B4B)
                            : const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(width: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6.5, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: _selectedTab == 1 ? const Color(0xFFF1F5F9) : const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${_doctors.length}',
                        style: portalText(
                          fontSize: 10,
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

  // Action Buttons: Referred OP / + Add Customer (or Doctor Referred OP / + Add Doctor)
  Widget _buildActionButtons() {
    final isCustomerTab = _selectedTab == 0;
    return Row(
      children: [
        // Left Button: Referred OP / Doctor Referred OP
        Expanded(
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => OpReferralBookingScreen(
                    initialTab: isCustomerTab ? 0 : 1,
                  ),
                ),
              );
            },
            child: Container(
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFFEEEDF0),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFD5D2DC),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.local_hospital_outlined,
                    size: 17,
                    color: Color(0xFF26204A),
                  ),
                  const SizedBox(width: 7),
                  Flexible(
                    child: Text(
                      isCustomerTab ? 'Referred OP' : 'Doctor Referred OP',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: portalText(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF26204A),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        // Right Button: + Add Customer / + Add Doctor
        Expanded(
          child: GestureDetector(
            onTap: isCustomerTab ? _showAddCustomerSheet : _showAddDoctorSheet,
            child: Container(
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFF26204A),
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x3326204A),
                    blurRadius: 10,
                    offset: Offset(0, 4),
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
                  Flexible(
                    child: Text(
                      isCustomerTab ? 'Add Customer' : 'Add Doctor',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: portalText(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
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

  // KPI Row of 4 cards: TOTAL, ACTIVE, INACTI..., OPS
  Widget _buildKpiRow() {
    final isCustomerTab = _selectedTab == 0;
    final totalCount = isCustomerTab ? _customers.length : _doctors.length;
    final activeCount = isCustomerTab
        ? _customers.where((c) => c.isActive).length
        : _doctors.where((d) => d.isActive).length;
    final inactiveCount = isCustomerTab
        ? _customers.where((c) => !c.isActive).length
        : _doctors.where((d) => !d.isActive).length;
    final totalOps = isCustomerTab ? '55' : '16';

    return Row(
      children: [
        Expanded(
          child: _kpiCard(
            title: 'TOTAL',
            value: '$totalCount',
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
            value: '$activeCount',
            sub: 'Active referrals',
            subColor: const Color(0xFF10B981),
            icon: Icons.person_outline_rounded,
            iconBg: const Color(0xFFECFDF5),
            iconColor: const Color(0xFF10B981),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _kpiCard(
            title: 'INACTIVE',
            value: '$inactiveCount',
            sub: 'Inactive referrals',
            icon: Icons.block_flipped,
            iconBg: const Color(0xFFFFF7ED),
            iconColor: const Color(0xFFF97316),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _kpiCard(
            title: 'OPS',
            value: totalOps,
            sub: isCustomerTab ? 'Visits' : 'total OP visits',
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

  void _showMonthFilterSheet() {
    final monthsList = [
      'All Months',
      'Jan 2026',
      'Feb 2026',
      'Mar 2026',
      'Apr 2026',
      'May 2026',
      'Jun 2026',
      'Jul 2026',
      'Aug 2026',
      'Sep 2026',
      'Oct 2026',
      'Nov 2026',
      'Dec 2026',
      'Jan 2025',
    ];

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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Select Month',
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
                ),
                const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(ctx).size.height * 0.45,
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: monthsList.length,
                    itemBuilder: (context, idx) {
                      final m = monthsList[idx];
                      final isSelected = _monthFilter == m;
                      return ListTile(
                        dense: true,
                        title: Text(
                          m,
                          style: portalText(
                            fontSize: 13,
                            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                            color: isSelected
                                ? const Color(0xFF4F46E5)
                                : const Color(0xFF334155),
                          ),
                        ),
                        trailing: isSelected
                            ? const Icon(Icons.check_circle_rounded, color: Color(0xFF4F46E5), size: 18)
                            : null,
                        onTap: () {
                          setState(() => _monthFilter = m);
                          Navigator.pop(ctx);
                          if (m != 'All Months') {
                            _snack('Filtered by $m');
                          } else {
                            _snack('Showing all months');
                          }
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Filter Row: 1. Month Filter | 2. Status | 3. Export CSV (All in 1 line)
  Widget _buildFilterPillsRow() {
    final isMonthFiltered = _monthFilter != 'All Months';
    return Row(
      children: [
        // 1st: Month Filter
        Expanded(
          flex: 4,
          child: GestureDetector(
            onTap: _showMonthFilterSheet,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              decoration: BoxDecoration(
                color: isMonthFiltered ? const Color(0xFFF5F3FF) : Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isMonthFiltered
                      ? const Color(0xFF6366F1)
                      : const Color(0xFFE2E8F0),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_month_outlined,
                    size: 13,
                    color: isMonthFiltered
                        ? const Color(0xFF6366F1)
                        : const Color(0xFF64748B),
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      _monthFilter == 'All Months' ? 'Month' : _monthFilter,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: portalText(
                        fontSize: 11,
                        fontWeight: isMonthFiltered
                            ? FontWeight.w700
                            : FontWeight.w600,
                        color: isMonthFiltered
                            ? const Color(0xFF4F46E5)
                            : const Color(0xFF475569),
                      ),
                    ),
                  ),
                  if (isMonthFiltered)
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _monthFilter = 'All Months';
                        });
                      },
                      child: const Icon(
                        Icons.close_rounded,
                        size: 13,
                        color: Color(0xFF94A3B8),
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
          ),
        ),
        const SizedBox(width: 6),
        // 2nd: Status Filter
        Expanded(
          flex: 3,
          child: GestureDetector(
            onTap: _showStatusFilterSheet,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _statusFilter != 'All'
                      ? const Color(0xFF6366F1)
                      : const Color(0xFFE2E8F0),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      _statusFilter == 'All' ? 'Status' : _statusFilter,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: portalText(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: _statusFilter != 'All'
                            ? const Color(0xFF6366F1)
                            : const Color(0xFF475569),
                      ),
                    ),
                  ),
                  const SizedBox(width: 2),
                  const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 15,
                    color: Color(0xFF64748B),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 6),
        // 3rd: Export CSV
        Expanded(
          flex: 3,
          child: GestureDetector(
            onTap: () => _snack('Exported Referral Records to CSV'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFECFDF5),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFA7F3D0)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.file_download_outlined,
                    size: 14,
                    color: Color(0xFF059669),
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      'Export CSV',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: portalText(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF059669),
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

  // Header: CUSTOMER RECORDS (5 of 15)
  Widget _buildRecordsHeader(int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            _selectedTab == 0
                ? 'CUSTOMER RECORDS ($count of ${_customers.length})'
                : 'DOCTOR RECORDS ($count of ${_doctors.length})',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: portalText(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF64748B),
              letterSpacing: 0.3,
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
                  color: const Color(0xFF26204A),
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
                Flexible(
                  child: Text(
                    customer.phone,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: portalText(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF334155),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                const Icon(
                  Icons.location_on_outlined,
                  size: 14,
                  color: Color(0xFF94A3B8),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    customer.location,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.end,
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
          Row(
            children: [
              Expanded(
                child: _buildTag(
                  'Service: ${customer.serviceRate}',
                  const Color(0xFFEFF6FF),
                  const Color(0xFFBFDBFE),
                  const Color(0xFF2563EB),
                ),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: _buildTag(
                  'Pharmacy: ${customer.pharmacyRate}',
                  const Color(0xFFECFDF5),
                  const Color(0xFFA7F3D0),
                  const Color(0xFF059669),
                ),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: _buildTag(
                  'Lab: ${customer.labRate}',
                  const Color(0xFFF5F3FF),
                  const Color(0xFFDDD6FE),
                  const Color(0xFF7C3AED),
                ),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: _buildTag(
                  'Fees: ${customer.fees}',
                  const Color(0xFFFFF7ED),
                  const Color(0xFFFED7AA),
                  const Color(0xFFEA580C),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(
            height: 1,
            thickness: 1,
            color: Color(0xFFF1F5F9),
          ),
          const SizedBox(height: 10),

          // Row 4: Onboard Date & Action Icons (View, Edit, Delete)
          Row(
            children: [
              Flexible(
                child: Text.rich(
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
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
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
                onTap: () => _showEditCustomerSheet(customer),
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

  // Doctor Card (Matching Customer Card style with Doctor Data)
  Widget _buildDoctorCard(OpDoctorReferralUi doc) {
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
          // Row 1: Avatar + Name & Clinic/Specialization + Active Status Badge
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFF26204A),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(
                  doc.name.isNotEmpty ? doc.name[0].toUpperCase() : 'D',
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
                      doc.name,
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
                            '${doc.clinic} • ${doc.specialization}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: portalText(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF64748B),
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
                Flexible(
                  child: Text(
                    doc.phone,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: portalText(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: doc.phone == 'N/A'
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF334155),
                      fontStyle: doc.phone == 'N/A'
                          ? FontStyle.italic
                          : FontStyle.normal,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                const Icon(
                  Icons.location_on_outlined,
                  size: 14,
                  color: Color(0xFF94A3B8),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    doc.location,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.end,
                    style: portalText(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: doc.location == 'N/A'
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF475569),
                      fontStyle: doc.location == 'N/A'
                          ? FontStyle.italic
                          : FontStyle.normal,
                    ),
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
          Row(
            children: [
              Expanded(
                child: _buildTag(
                  'Service: ${doc.serviceRate}',
                  const Color(0xFFEFF6FF),
                  const Color(0xFFBFDBFE),
                  const Color(0xFF2563EB),
                ),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: _buildTag(
                  'Pharmacy: ${doc.pharmacyRate}',
                  const Color(0xFFECFDF5),
                  const Color(0xFFA7F3D0),
                  const Color(0xFF059669),
                ),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: _buildTag(
                  'Lab: ${doc.labRate}',
                  const Color(0xFFF5F3FF),
                  const Color(0xFFDDD6FE),
                  const Color(0xFF7C3AED),
                ),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: _buildTag(
                  'Fees: ${doc.fees}',
                  const Color(0xFFFFF7ED),
                  const Color(0xFFFED7AA),
                  const Color(0xFFEA580C),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(
            height: 1,
            thickness: 1,
            color: Color(0xFFF1F5F9),
          ),
          const SizedBox(height: 10),

          // Row 4: Onboard Date & Action Icons (View, Edit, Delete)
          Row(
            children: [
              Flexible(
                child: Text.rich(
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
                        text: doc.onboardDate,
                        style: portalText(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF334155),
                        ),
                      ),
                    ],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              const Spacer(),
              // View Icon
              GestureDetector(
                onTap: () => _showDoctorDetail(doc),
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
                onTap: () => _showEditDoctorSheet(doc),
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
                onTap: () => _deleteDoctor(doc),
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

  Widget _buildTag(String label, Color bg, Color border, Color textCol) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: border, width: 0.8),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          label,
          maxLines: 1,
          style: portalText(
            fontSize: 9.5,
            fontWeight: FontWeight.w700,
            color: textCol,
          ),
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
