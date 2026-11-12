import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:timelay_health/core/theme/portal_text.dart';
import 'package:timelay_health/features/op/dashboard/presentation/theme/op_colors.dart';
import 'package:timelay_health/features/op/dashboard/presentation/widgets/op_top_bar.dart';

class OpRegisterScreen extends StatefulWidget {
  const OpRegisterScreen({super.key, this.onMenuTap});

  final VoidCallback? onMenuTap;

  @override
  State<OpRegisterScreen> createState() => _OpRegisterScreenState();
}

class _OpRegisterScreenState extends State<OpRegisterScreen> {
  final _phone = TextEditingController();
  final _name = TextEditingController();
  final _age = TextEditingController();
  final _address = TextEditingController();
  final _pincode = TextEditingController();
  final _city = TextEditingController();
  final _service = TextEditingController();
  final _price = TextEditingController();
  final _reason = TextEditingController();
  final _amountReceived = TextEditingController();
  final _discount = TextEditingController();

  String _title = 'Mr.';
  String _gender = 'Select';
  String? _doctor;
  String? _slot;
  String? _customer;
  String? _refDoctor;
  String _paymentMode = 'Select Mode';
  String _discountType = '₹ (Rupees)';
  DateTime? _dob;
  DateTime _appointmentDate = DateTime.now();
  final List<({String name, String price})> _services = [];

  static const _titles = [
    'Mr.',
    'Mrs.',
    'Ms.',
    'Miss.',
    'Master',
    'Baby',
    'Baby Of',
    'Dr.',
  ];
  static const _genders = ['Male', 'Female', 'Other'];
  static const _doctors = [
    'Dr. Mehta — General OP',
    'Dr. Khan — Cardiology',
    'Dr. Singh — Ortho',
    'Dr. Rao — Lab Consult',
  ];
  static const _slots = [
    '10:00 AM',
    '10:30 AM',
    '11:00 AM',
    '11:30 AM',
    '12:00 PM',
    '04:00 PM',
    '04:30 PM',
    '05:00 PM',
  ];
  static const _customers = ['Walk-in', 'Corporate A', 'Insurance Partner'];
  static const _refDoctors = ['Self', 'Dr. Sharma', 'Dr. Patel'];
  static const _modes = ['Cash', 'Online', 'Insurance', 'Card', 'Due'];
  static const _discountTypes = ['₹ (Rupees)', '% (Percent)'];

  @override
  void dispose() {
    _phone.dispose();
    _name.dispose();
    _age.dispose();
    _address.dispose();
    _pincode.dispose();
    _city.dispose();
    _service.dispose();
    _price.dispose();
    _reason.dispose();
    _amountReceived.dispose();
    _discount.dispose();
    super.dispose();
  }

  double get _subtotal => _services.fold<double>(
        0,
        (sum, e) => sum + (double.tryParse(e.price) ?? 0),
      );

  double get _discountValue {
    final raw = double.tryParse(_discount.text.trim()) ?? 0;
    if (_discountType.startsWith('%')) {
      return _subtotal * (raw / 100);
    }
    return raw;
  }

  double get _payable {
    final v = _subtotal - _discountValue;
    return v < 0 ? 0 : v;
  }

  double get _received => double.tryParse(_amountReceived.text.trim()) ?? 0;

  double get _due {
    final v = _payable - _received;
    return v < 0 ? 0 : v;
  }

  bool get _fullyPaid => _payable > 0 && _due <= 0.009;

  Future<void> _pickDate({required bool dob}) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: dob ? (_dob ?? DateTime(1995, 1, 1)) : _appointmentDate,
      firstDate: dob ? DateTime(1920) : now,
      lastDate: dob ? now : now.add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: OpColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: OpColors.heading,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked == null) return;
    setState(() {
      if (dob) {
        _dob = picked;
        final years = now.year - picked.year;
        final beforeBirthday = now.month < picked.month ||
            (now.month == picked.month && now.day < picked.day);
        _age.text = '${beforeBirthday ? years - 1 : years}';
      } else {
        _appointmentDate = picked;
        _slot = null;
      }
    });
  }

  Future<void> _pickOption({
    required String label,
    required List<String> options,
    required String? current,
    required ValueChanged<String> onSelect,
  }) async {
    final result = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return _OpPickerSheet(
          label: label,
          options: options,
          selected: current,
        );
      },
    );
    if (result != null) onSelect(result);
  }

  void _addService() {
    final name = _service.text.trim();
    final price = _price.text.trim();
    if (name.isEmpty || price.isEmpty) return;
    setState(() {
      _services.add((name: name, price: price));
      _service.clear();
      _price.clear();
    });
  }

  void _confirm() {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: OpColors.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Text(
          'Booking confirmed for ${_name.text.trim().isEmpty ? 'patient' : _name.text.trim()}',
          style: portalText(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: OpColors.background,
      child: Column(
        children: [
          OpTopBar(
            title: 'Register OPD',
            showBack: true,
            onMenuTap: widget.onMenuTap ?? () => Navigator.of(context).maybePop(),
          ),
          Expanded(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 20),
              children: [
                _HeroHeader(),
                const SizedBox(height: 14),
                _SectionCard(
                  children: [
                    _FieldLabel(icon: Icons.phone_rounded, text: 'Phone Number'),
                    _InputShell(
                      child: Row(
                        children: [
                          Text(
                            '+91',
                            style: portalText(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: OpColors.heading,
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 22,
                            margin: const EdgeInsets.symmetric(horizontal: 10),
                            color: OpColors.border,
                          ),
                          Expanded(
                            child: TextField(
                              controller: _phone,
                              keyboardType: TextInputType.phone,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(10),
                              ],
                              style: portalText(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: OpColors.heading,
                              ),
                              decoration: _hint('Enter phone number'),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 92,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const _FieldLabel(text: 'Title'),
                              _SelectShell(
                                value: _title,
                                onTap: () => _pickOption(
                                  label: 'Title',
                                  options: _titles,
                                  current: _title,
                                  onSelect: (v) => setState(() => _title = v),
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
                              const _FieldLabel(text: 'Patient Name'),
                              _InputShell(
                                child: TextField(
                                  controller: _name,
                                  textCapitalization: TextCapitalization.words,
                                  style: portalText(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: OpColors.heading,
                                  ),
                                  decoration: _hint('Full name'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const _FieldLabel(
                                icon: Icons.calendar_today_rounded,
                                text: 'DOB',
                              ),
                              _SelectShell(
                                value: _dob == null ? 'Select' : _fmtDate(_dob!),
                                muted: _dob == null,
                                onTap: () => _pickDate(dob: true),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 72,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const _FieldLabel(text: 'Age'),
                              _InputShell(
                                child: TextField(
                                  controller: _age,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(3),
                                  ],
                                  style: portalText(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: OpColors.heading,
                                  ),
                                  decoration: _hint('Yrs'),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const _FieldLabel(text: 'Gender'),
                              _SelectShell(
                                value: _gender,
                                muted: _gender == 'Select',
                                onTap: () => _pickOption(
                                  label: 'Gender',
                                  options: _genders,
                                  current: _gender == 'Select' ? null : _gender,
                                  onSelect: (v) => setState(() => _gender = v),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _SectionCard(
                  children: [
                    const _FieldLabel(
                      icon: Icons.location_on_outlined,
                      text: 'Address',
                    ),
                    _InputShell(
                      minHeight: 84,
                      child: TextField(
                        controller: _address,
                        maxLines: 3,
                        style: portalText(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: OpColors.heading,
                        ),
                        decoration: _hint('Patient street address'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const _FieldLabel(text: 'Pincode'),
                              _InputShell(
                                child: TextField(
                                  controller: _pincode,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(6),
                                  ],
                                  onChanged: (v) {
                                    if (v.length == 6) {
                                      setState(() => _city.text = 'Auto City');
                                    }
                                  },
                                  style: portalText(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: OpColors.heading,
                                  ),
                                  decoration: _hint('6 digits'),
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
                              const _FieldLabel(text: 'City'),
                              _InputShell(
                                child: TextField(
                                  controller: _city,
                                  readOnly: true,
                                  style: portalText(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: OpColors.muted,
                                  ),
                                  decoration: _hint('Auto-filled'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _SectionCard(
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: _FieldLabel(
                            icon: Icons.medical_services_outlined,
                            text: 'Select Doctor',
                          ),
                        ),
                        _LinkChip(label: '+ Add', onTap: () {}),
                      ],
                    ),
                    _SelectShell(
                      value: _doctor ?? 'Choose doctor',
                      muted: _doctor == null,
                      onTap: () => _pickOption(
                        label: 'Doctor',
                        options: _doctors,
                        current: _doctor,
                        onSelect: (v) => setState(() {
                          _doctor = v;
                          _slot = null;
                        }),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const _FieldLabel(
                      icon: Icons.event_rounded,
                      text: 'Appointment Date',
                    ),
                    _SelectShell(
                      value: _fmtDate(_appointmentDate),
                      onTap: () => _pickDate(dob: false),
                    ),
                    const SizedBox(height: 12),
                    const _FieldLabel(
                      icon: Icons.schedule_rounded,
                      text: 'Slot',
                    ),
                    _SelectShell(
                      value: _doctor == null
                          ? 'Select doctor & date first'
                          : (_slot ?? 'Select slot'),
                      muted: _slot == null,
                      onTap: _doctor == null
                          ? null
                          : () => _pickOption(
                                label: 'Slot',
                                options: _slots,
                                current: _slot,
                                onSelect: (v) => setState(() => _slot = v),
                              ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _SectionCard(
                  tint: const Color(0xFFF3F4F8),
                  children: [
                    Text(
                      'REFERRAL',
                      style: portalText(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: OpColors.muted,
                        letterSpacing: 0.6,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Expanded(child: _FieldLabel(text: 'Customer')),
                                  _LinkChip(label: '+ Add', onTap: () {}),
                                ],
                              ),
                              _SelectShell(
                                value: _customer ?? 'Select',
                                muted: _customer == null,
                                onTap: () => _pickOption(
                                  label: 'Customer',
                                  options: _customers,
                                  current: _customer,
                                  onSelect: (v) =>
                                      setState(() => _customer = v),
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
                              Row(
                                children: [
                                  const Expanded(child: _FieldLabel(text: 'Doctor')),
                                  _LinkChip(label: '+ Add', onTap: () {}),
                                ],
                              ),
                              _SelectShell(
                                value: _refDoctor ?? 'Select',
                                muted: _refDoctor == null,
                                onTap: () => _pickOption(
                                  label: 'Referral Doctor',
                                  options: _refDoctors,
                                  current: _refDoctor,
                                  onSelect: (v) =>
                                      setState(() => _refDoctor = v),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _SectionCard(
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: _FieldLabel(
                            icon: Icons.miscellaneous_services_rounded,
                            text: 'Services',
                          ),
                        ),
                        Text(
                          '${_services.length} added',
                          style: portalText(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: OpColors.muted,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: _InputShell(
                            child: TextField(
                              controller: _service,
                              style: portalText(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: OpColors.heading,
                              ),
                              decoration: _hint('Service name'),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 2,
                          child: _InputShell(
                            child: TextField(
                              controller: _price,
                              keyboardType: TextInputType.number,
                              style: portalText(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: OpColors.heading,
                              ),
                              decoration: _hint('Price'),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Material(
                          color: OpColors.green,
                          borderRadius: BorderRadius.circular(12),
                          child: InkWell(
                            onTap: _addService,
                            borderRadius: BorderRadius.circular(12),
                            child: const SizedBox(
                              width: 46,
                              height: 46,
                              child: Icon(Icons.add_rounded, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (_services.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      ..._services.asMap().entries.map((e) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: OpColors.primaryTint,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    e.value.name,
                                    style: portalText(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: OpColors.heading,
                                    ),
                                  ),
                                ),
                                Text(
                                  '₹${e.value.price}',
                                  style: portalText(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: OpColors.primary,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                GestureDetector(
                                  onTap: () => setState(
                                    () => _services.removeAt(e.key),
                                  ),
                                  child: const Icon(
                                    Icons.close_rounded,
                                    size: 18,
                                    color: OpColors.muted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ],
                  ],
                ),
                const SizedBox(height: 12),
                _SectionCard(
                  children: [
                    const _FieldLabel(
                      icon: Icons.notes_rounded,
                      text: 'Reason / Symptoms',
                    ),
                    _InputShell(
                      minHeight: 96,
                      child: TextField(
                        controller: _reason,
                        maxLines: 4,
                        style: portalText(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: OpColors.heading,
                        ),
                        decoration: _hint('Describe symptoms or reason'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _SectionCard(
                  children: [
                    Text(
                      'PAYMENT DETAILS',
                      style: portalText(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: OpColors.heading,
                        letterSpacing: 0.4,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF26204A), Color(0xFF4B4285)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: _PayStat(
                              label: 'SUBTOTAL',
                              value: '₹${_subtotal.toStringAsFixed(0)}',
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 36,
                            color: Colors.white24,
                          ),
                          Expanded(
                            child: _PayStat(
                              label: 'PAYABLE',
                              value: '₹${_payable.toStringAsFixed(0)}',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const _FieldLabel(text: 'Amount Received'),
                              _InputShell(
                                child: TextField(
                                  controller: _amountReceived,
                                  keyboardType: TextInputType.number,
                                  onChanged: (_) => setState(() {}),
                                  style: portalText(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: OpColors.heading,
                                  ),
                                  decoration: _hint('0'),
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
                              const _FieldLabel(text: 'Payment Mode'),
                              _SelectShell(
                                value: _paymentMode,
                                muted: _paymentMode == 'Select Mode',
                                onTap: () => _pickOption(
                                  label: 'Payment Mode',
                                  options: _modes,
                                  current: _paymentMode == 'Select Mode'
                                      ? null
                                      : _paymentMode,
                                  onSelect: (v) =>
                                      setState(() => _paymentMode = v),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const _FieldLabel(text: 'Due Amount'),
                              _InputShell(
                                fill: OpColors.redTint,
                                child: Text(
                                  '₹${_due.toStringAsFixed(0)}',
                                  style: portalText(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: OpColors.red,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const _FieldLabel(text: 'Discount'),
                              _InputShell(
                                child: TextField(
                                  controller: _discount,
                                  keyboardType: TextInputType.number,
                                  onChanged: (_) => setState(() {}),
                                  style: portalText(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: OpColors.heading,
                                  ),
                                  decoration: _hint('0'),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const _FieldLabel(text: 'Type'),
                              _SelectShell(
                                value: _discountType.startsWith('₹')
                                    ? '₹'
                                    : '%',
                                onTap: () => _pickOption(
                                  label: 'Discount Type',
                                  options: _discountTypes,
                                  current: _discountType,
                                  onSelect: (v) =>
                                      setState(() => _discountType = v),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF8E8),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFF5E2B8)),
                      ),
                      child: Column(
                        children: [
                          _SummaryRow(
                            label: 'Total Payable',
                            value: '₹${_payable.toStringAsFixed(0)}',
                          ),
                          const SizedBox(height: 8),
                          _SummaryRow(
                            label: 'Amount Receiving',
                            value: '₹${_received.toStringAsFixed(0)}',
                          ),
                          const SizedBox(height: 8),
                          _SummaryRow(
                            label: 'Status',
                            value: _fullyPaid ? 'Fully Paid' : 'Pending',
                            valueColor:
                                _fullyPaid ? OpColors.green : OpColors.orange,
                            leading: Icon(
                              _fullyPaid
                                  ? Icons.check_circle_rounded
                                  : Icons.schedule_rounded,
                              size: 16,
                              color: _fullyPaid
                                  ? OpColors.green
                                  : OpColors.orange,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _SummaryRow(
                            label: 'Payment Status',
                            value: _due > 0 ? 'DUE' : 'PAID',
                            valueColor:
                                _due > 0 ? OpColors.red : OpColors.green,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
              decoration: BoxDecoration(
                color: OpColors.surface,
                boxShadow: [
                  BoxShadow(
                    color: OpColors.primary.withValues(alpha: 0.08),
                    blurRadius: 18,
                    offset: const Offset(0, -6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => setState(() {
                        _phone.clear();
                        _name.clear();
                        _age.clear();
                        _address.clear();
                        _pincode.clear();
                        _city.clear();
                        _service.clear();
                        _price.clear();
                        _reason.clear();
                        _amountReceived.clear();
                        _discount.clear();
                        _title = 'Mr.';
                        _gender = 'Select';
                        _doctor = null;
                        _slot = null;
                        _customer = null;
                        _refDoctor = null;
                        _paymentMode = 'Select Mode';
                        _discountType = '₹ (Rupees)';
                        _dob = null;
                        _services.clear();
                      }),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                        side: const BorderSide(color: OpColors.border),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: portalText(
                          fontWeight: FontWeight.w700,
                          color: OpColors.secondary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: _confirm,
                      icon: const Icon(Icons.event_available_rounded, size: 20),
                      label: Text(
                        'Confirm & Book',
                        style: portalText(
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: OpColors.green,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
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

  InputDecoration _hint(String text) => InputDecoration(
        isDense: true,
        border: InputBorder.none,
        hintText: text,
        hintStyle: portalText(fontSize: 13, color: OpColors.muted),
      );
}

class _HeroHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: OpColors.card(radius: 18),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF18AC96), Color(0xFF2DD4BF)],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.person_add_alt_1_rounded,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Register OPD Patient',
                  style: portalText(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: OpColors.heading,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Fill patient & consultation details',
                  style: portalText(fontSize: 12, color: OpColors.muted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.children, this.tint});

  final List<Widget> children;
  final Color? tint;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: tint ?? OpColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: OpColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A2A2456),
            blurRadius: 14,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({this.icon, required this.text});

  final IconData? icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: OpColors.muted),
            const SizedBox(width: 4),
          ],
          Flexible(
            child: Text(
              text.toUpperCase(),
              style: portalText(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: OpColors.secondary,
                letterSpacing: 0.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InputShell extends StatelessWidget {
  const _InputShell({
    required this.child,
    this.minHeight = 46,
    this.fill,
  });

  final Widget child;
  final double minHeight;
  final Color? fill;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minHeight: minHeight),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        color: fill ?? Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: OpColors.border),
      ),
      child: child,
    );
  }
}

class _SelectShell extends StatelessWidget {
  const _SelectShell({
    required this.value,
    this.onTap,
    this.muted = false,
  });

  final String value;
  final VoidCallback? onTap;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 46,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: OpColors.border),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: portalText(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: muted ? OpColors.muted : OpColors.heading,
                  ),
                ),
              ),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                color: onTap == null ? OpColors.border : OpColors.muted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LinkChip extends StatelessWidget {
  const _LinkChip({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        label,
        style: portalText(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: OpColors.blue,
        ),
      ),
    );
  }
}

class _PayStat extends StatelessWidget {
  const _PayStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: portalText(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: Colors.white70,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: portalText(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.leading,
  });

  final String label;
  final String value;
  final Color? valueColor;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: portalText(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: OpColors.secondary,
            ),
          ),
        ),
        if (leading != null) ...[leading!, const SizedBox(width: 4)],
        Text(
          value,
          style: portalText(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: valueColor ?? OpColors.heading,
          ),
        ),
      ],
    );
  }
}

class _OpPickerSheet extends StatelessWidget {
  const _OpPickerSheet({
    required this.label,
    required this.options,
    required this.selected,
  });

  final String label;
  final List<String> options;
  final String? selected;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white54,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.sizeOf(context).height * 0.55,
              ),
              decoration: BoxDecoration(
                color: const Color(0xE6454548),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white24),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x66000000),
                    blurRadius: 24,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        label.toUpperCase(),
                        style: portalText(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: Colors.white70,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      padding: const EdgeInsets.fromLTRB(8, 0, 8, 10),
                      itemCount: options.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 4),
                      itemBuilder: (context, index) {
                        final option = options[index];
                        final isSelected = option == selected;
                        return Material(
                          color: isSelected
                              ? const Color(0xFF007AFF)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          child: InkWell(
                            onTap: () => Navigator.pop(context, option),
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 13,
                              ),
                              child: Row(
                                children: [
                                  if (isSelected)
                                    const Padding(
                                      padding: EdgeInsets.only(right: 8),
                                      child: Icon(
                                        Icons.check_rounded,
                                        size: 18,
                                        color: Colors.white,
                                      ),
                                    ),
                                  Expanded(
                                    child: Text(
                                      option,
                                      style: portalText(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
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
}
