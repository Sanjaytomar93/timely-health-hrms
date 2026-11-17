import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:timelay_health/core/theme/portal_text.dart';
import 'package:timelay_health/features/op/dashboard/presentation/theme/op_colors.dart';

class OpRegisterScreen extends StatefulWidget {
  const OpRegisterScreen({super.key, this.onMenuTap});

  final VoidCallback? onMenuTap;

  @override
  State<OpRegisterScreen> createState() => _OpRegisterScreenState();
}

class _OpRegisterScreenState extends State<OpRegisterScreen> {
  int _step = 0;

  final _phone = TextEditingController(text: '+919876543210');
  final _name = TextEditingController();
  final _age = TextEditingController();
  final _address = TextEditingController();
  final _pincode = TextEditingController();
  final _city = TextEditingController();
  final _service = TextEditingController();
  final _price = TextEditingController();
  final _reason = TextEditingController();
  final _amountReceived = TextEditingController(text: '0');
  final _discount = TextEditingController();

  String _title = 'Mr.';
  String _gender = 'Male';
  String? _customer;
  String? _refDoctor;
  String? _doctor;
  String? _slot;
  String _paymentMode = 'Select Mode';
  String _discountType = '₹ (Rupees)';
  String _serviceType = 'Doctor Consultation';
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
    'Dr.',
  ];
  static const _genders = ['Male', 'Female', 'Other'];
  static const _customers = ['Walk-in', 'Corporate A', 'Insurance Partner'];
  static const _refDoctors = ['Self', 'Dr. Sharma', 'Dr. Patel', 'Dr. Mehta'];
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
  static const _modes = ['Cash', 'Online', 'Insurance', 'Card', 'Due'];
  static const _discountTypes = ['₹ (Rupees)', '% (Percent)'];
  static const _serviceTypes = [
    (
      'Doctor Consultation',
      'Choose doctor, date & slot.',
      Icons.medical_services_outlined,
    ),
    ('Lab', 'Lab amounts with payment.', Icons.science_outlined),
    ('Pharmacy', 'Medicines with payment.', Icons.local_pharmacy_outlined),
  ];

  bool get _canPickSlot => _doctor != null;

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

  void _pop() {
    final fn = widget.onMenuTap;
    if (fn != null) {
      fn();
      return;
    }
    Navigator.of(context).maybePop();
  }

  double get _subtotal => _services.fold<double>(
        0,
        (sum, e) => sum + (double.tryParse(e.price) ?? 0),
      );

  double get _discountValue {
    final raw = double.tryParse(_discount.text.trim()) ?? 0;
    if (_discountType.startsWith('%')) return _subtotal * (raw / 100);
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
        final before = now.month < picked.month ||
            (now.month == picked.month && now.day < picked.day);
        _age.text = '${before ? years - 1 : years}';
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
      builder: (_) => _OpPickerSheet(
        label: label,
        options: options,
        selected: current,
      ),
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

  void _addAmountItem() {
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

  String _money(double v) => '₹${v.toStringAsFixed(v.truncateToDouble() == v ? 0 : 0)}';

  void _goStep(int i) {
    if (i < 0 || i > 1) return;
    setState(() => _step = i);
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFFF6F8FC),
      child: Column(
        children: [
          _Header(
            onBack: () {
              if (_step > 0) {
                _goStep(0);
              } else {
                _pop();
              }
            },
          ),
          _StepBar(step: _step, onTap: _goStep),
          Expanded(
            child: KeyedSubtree(
              key: ValueKey<int>(_step),
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 20),
                children: [
                  if (_step == 0) ..._step1() else ..._step2(),
                ],
              ),
            ),
          ),
          if (_step == 0)
            _BottomStep1(
              onCancel: _pop,
              onNext: () => _goStep(1),
            )
          else
            _BottomStep2(
              onCancel: _pop,
              onBack: () => _goStep(0),
              onConfirm: _confirm,
            ),
        ],
      ),
    );
  }

  List<Widget> _step1() {
    return [
      _Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SectionTitle(
              icon: Icons.person_outline_rounded,
              iconColor: Color(0xFF2563EB),
              title: 'Patient Information',
            ),
            const SizedBox(height: 14),
            const _Label(text: 'Phone Number', required: true),
            _Field(
              child: Row(
                children: [
                  const Icon(Icons.phone_outlined, size: 18, color: Color(0xFF64748B)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _phone,
                      keyboardType: TextInputType.phone,
                      style: _inputStyle,
                      decoration: _hint('+919876543210'),
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
                  width: 88,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _Label(text: 'Title', required: true),
                      _Select(
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
                      const _Label(text: 'Patient Name', required: true),
                      _Field(
                        child: TextField(
                          controller: _name,
                          textCapitalization: TextCapitalization.characters,
                          style: _inputStyle,
                          decoration: _hint('ENTER PATIENT FULL NAME'),
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
                      const _Label(text: 'DOB'),
                      _Select(
                        value: _dob == null ? 'dd/mm/yyyy' : _fmtDate(_dob!),
                        muted: _dob == null,
                        icon: Icons.calendar_today_outlined,
                        onTap: () => _pickDate(dob: true),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _Label(text: 'Age'),
                      _Field(
                        child: TextField(
                          controller: _age,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(3),
                          ],
                          style: _inputStyle,
                          decoration: _hint('Enter age'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const _Label(text: 'Gender', required: true),
            _Select(
              value: _gender,
              onTap: () => _pickOption(
                label: 'Gender',
                options: _genders,
                current: _gender,
                onSelect: (v) => setState(() => _gender = v),
              ),
            ),
            const SizedBox(height: 12),
            const _Label(text: 'Address'),
            _Field(
              minHeight: 78,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 2),
                    child: Icon(
                      Icons.location_on_outlined,
                      size: 18,
                      color: Color(0xFF2563EB),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _address,
                      maxLines: 3,
                      style: _inputStyle,
                      decoration: _hint('Patient street address'),
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
                      const _Label(text: 'Pincode'),
                      _Field(
                        child: TextField(
                          controller: _pincode,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(6),
                          ],
                          style: _inputStyle,
                          decoration: _hint('Enter 6-digit pincode'),
                          onChanged: (v) {
                            if (v.length == 6) {
                              setState(() => _city.text = 'Auto City');
                            }
                          },
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
                      const _Label(text: 'City'),
                      _Field(
                        filled: const Color(0xFFF8FAFC),
                        child: TextField(
                          controller: _city,
                          readOnly: true,
                          style: _inputStyle.copyWith(color: const Color(0xFF94A3B8)),
                          decoration: _hint('Auto-filled from pincode'),
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
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFBFDBFE)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline_rounded, size: 16, color: Color(0xFF2563EB)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'A valid mobile number is needed to send consultation updates and receipts.',
                      style: portalText(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF1E40AF),
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ];
  }

  List<Widget> _step2() {
    final isDoctor = _serviceType == 'Doctor Consultation';
    final isLab = _serviceType == 'Lab';
    final isPharmacy = _serviceType == 'Pharmacy';

    return [
      _servicesPickerCard(),
      const SizedBox(height: 12),
      if (isDoctor) ...[
        _doctorSlotCard(),
        const SizedBox(height: 12),
        _doctorServiceDetailsCard(),
        const SizedBox(height: 12),
        _referredCard(),
        const SizedBox(height: 12),
        _reasonCard(),
        const SizedBox(height: 12),
        _doctorPaymentCard(),
      ] else if (isLab) ...[
        _amountItemsCard(
          title: 'Lab Items',
          subtitle: 'Add amount, discount and payment for each lab test.',
          accent: const Color(0xFF7C3AED),
          icon: Icons.science_outlined,
          addLabel: '+ ADD NEW LAB AMOUNT:',
          emptyText:
              'No lab amounts added yet. Enter amount above and click Add.',
          nameHeader: 'LAB NAME',
          totalLabel: 'LAB TOTAL',
        ),
        const SizedBox(height: 12),
        _referredCard(),
        const SizedBox(height: 12),
        _reasonCard(),
        const SizedBox(height: 12),
        _simplePaymentSummary(
          subtitle: 'Calculated from the lab items above',
          totalLabel: 'LAB TOTAL',
          accent: const Color(0xFF7C3AED),
        ),
      ] else if (isPharmacy) ...[
        _amountItemsCard(
          title: 'Pharmacy Items',
          subtitle: 'Add amount, discount and payment for each medicine.',
          accent: const Color(0xFF059669),
          icon: Icons.local_pharmacy_outlined,
          addLabel: '+ ADD NEW MEDICINE AMOUNT:',
          emptyText:
              'No medicine amounts added yet. Enter amount above and click Add.',
          nameHeader: 'MEDICINE NAME',
          totalLabel: 'PHARMACY TOTAL',
        ),
        const SizedBox(height: 12),
        _referredCard(),
        const SizedBox(height: 12),
        _reasonCard(),
        const SizedBox(height: 12),
        _simplePaymentSummary(
          subtitle: 'Calculated from the pharmacy items above',
          totalLabel: 'PHARMACY TOTAL',
          accent: const Color(0xFF059669),
        ),
      ],
    ];
  }

  Widget _servicesPickerCard() {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(
            icon: Icons.medical_services_outlined,
            iconColor: Color(0xFF7C3AED),
            title: 'Services',
          ),
          const SizedBox(height: 2),
          Text(
            'Select the type of service.',
            style: portalText(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              for (var i = 0; i < _serviceTypes.length; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(
                  child: _ServiceChip(
                    title: _serviceTypes[i].$1,
                    subtitle: _serviceTypes[i].$2,
                    icon: _serviceTypes[i].$3,
                    selected: _serviceType == _serviceTypes[i].$1,
                    accent: _serviceTypes[i].$1 == 'Pharmacy'
                        ? const Color(0xFF059669)
                        : const Color(0xFF7C3AED),
                    onTap: () => setState(() {
                      _serviceType = _serviceTypes[i].$1;
                      _services.clear();
                      _price.clear();
                      _service.clear();
                      if (_serviceType != 'Doctor Consultation') {
                        _doctor = null;
                        _slot = null;
                      }
                    }),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _doctorSlotCard() {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(
            icon: Icons.event_available_rounded,
            iconColor: Color(0xFF7C3AED),
            title: 'Doctor & Appointment Slot',
          ),
          const SizedBox(height: 2),
          Text(
            'Select the doctor, date and available slot.',
            style: portalText(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  'SELECT DOCTOR',
                  style: portalText(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF64748B),
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              Text(
                '+ Add',
                style: portalText(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF2563EB),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          _Select(
            value: _doctor ?? 'Select Doctor',
            muted: _doctor == null,
            onTap: () => _pickOption(
              label: 'Select Doctor',
              options: _doctors,
              current: _doctor,
              onSelect: (v) => setState(() {
                _doctor = v;
                _slot = null;
              }),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _Label(text: 'Appointment Date'),
                    _Select(
                      value: _fmtDate(_appointmentDate),
                      icon: Icons.calendar_today_outlined,
                      onTap: () => _pickDate(dob: false),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _Label(text: 'Slot'),
                    _Select(
                      value: _slot ??
                          (_canPickSlot
                              ? 'Select slot'
                              : 'Select doctor & date first'),
                      muted: _slot == null,
                      enabled: _canPickSlot,
                      onTap: !_canPickSlot
                          ? () {}
                          : () => _pickOption(
                                label: 'Select Slot',
                                options: _slots,
                                current: _slot,
                                onSelect: (v) => setState(() => _slot = v),
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

  Widget _doctorServiceDetailsCard() {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: _SectionTitle(
                  icon: Icons.playlist_add_check_rounded,
                  iconColor: Color(0xFF059669),
                  title: 'Service Details',
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_services.length} added',
                  style: portalText(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF047857),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: _Field(
                  child: TextField(
                    controller: _service,
                    style: _inputStyle,
                    decoration: _hint('Service name'),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: _Field(
                  child: TextField(
                    controller: _price,
                    keyboardType: TextInputType.number,
                    style: _inputStyle,
                    decoration: _hint('₹ Price'),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _addService,
                child: Container(
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFF059669),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '+ Add',
                    style: portalText(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (_services.isNotEmpty) ...[
            const SizedBox(height: 10),
            for (final s in _services)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        s.name,
                        style: portalText(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF334155),
                        ),
                      ),
                    ),
                    Text(
                      '₹${s.price}',
                      style: portalText(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: OpColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _amountItemsCard({
    required String title,
    required String subtitle,
    required Color accent,
    required IconData icon,
    required String addLabel,
    required String emptyText,
    required String nameHeader,
    required String totalLabel,
  }) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionTitle(icon: icon, iconColor: accent, title: title),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: portalText(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_services.length} added',
                  style: portalText(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: accent,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            addLabel,
            style: portalText(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF64748B),
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 6),
          _Field(
            child: TextField(
              controller: _service,
              textCapitalization: TextCapitalization.words,
              style: _inputStyle,
              decoration: _hint(
                title.contains('Lab') ? 'Enter lab name' : 'Enter medicine name',
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _Field(
                  child: TextField(
                    controller: _price,
                    keyboardType: TextInputType.number,
                    style: _inputStyle,
                    decoration: _hint('Enter amount (₹)'),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _addAmountItem,
                child: Container(
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: accent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '+ Add',
                    style: portalText(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _AmountTable(
            nameHeader: nameHeader,
            emptyText: emptyText,
            rows: _services,
            onRemove: (i) => setState(() => _services.removeAt(i)),
          ),
        ],
      ),
    );
  }

  Widget _referredCard() {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(
            icon: Icons.share_outlined,
            iconColor: Color(0xFF2563EB),
            title: 'Referred By',
          ),
          const SizedBox(height: 2),
          Text(
            'Customer or doctor who referred this patient',
            style: portalText(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'CUSTOMER',
                            style: portalText(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ),
                        Text(
                          '+ Add',
                          style: portalText(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF2563EB),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    _Select(
                      value: _customer ?? '-- Select Customer --',
                      muted: _customer == null,
                      onTap: () => _pickOption(
                        label: 'Customer',
                        options: _customers,
                        current: _customer,
                        onSelect: (v) => setState(() => _customer = v),
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
                        Expanded(
                          child: Text(
                            'DOCTOR',
                            style: portalText(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ),
                        Text(
                          '+ Add',
                          style: portalText(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF2563EB),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    _Select(
                      value: _refDoctor ?? '-- Select Doctor --',
                      muted: _refDoctor == null,
                      onTap: () => _pickOption(
                        label: 'Doctor',
                        options: _refDoctors,
                        current: _refDoctor,
                        onSelect: (v) => setState(() => _refDoctor = v),
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

  Widget _reasonCard() {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(
            icon: Icons.edit_note_rounded,
            iconColor: Color(0xFFD97706),
            title: 'Reason / Symptoms',
          ),
          const SizedBox(height: 2),
          Text(
            'Chief complaint or purpose of visit',
            style: portalText(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 12),
          _Field(
            minHeight: 88,
            child: TextField(
              controller: _reason,
              maxLines: 4,
              style: _inputStyle,
              decoration: _hint('Enter reason or symptoms'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _simplePaymentSummary({
    required String subtitle,
    required String totalLabel,
    required Color accent,
  }) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(
            icon: Icons.payments_outlined,
            iconColor: accent,
            title: 'Payment Summary',
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: portalText(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _MiniStat(
                  label: totalLabel,
                  value: _money(_subtotal),
                  color: const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _MiniStat(
                  label: 'PAYABLE',
                  value: _money(_payable),
                  color: const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _MiniStat(
                  label: 'RECEIVED',
                  value: _money(_received),
                  color: const Color(0xFF059669),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _MiniStat(
                  label: 'STATUS',
                  value: _services.isEmpty
                      ? '—'
                      : (_fullyPaid ? 'Paid' : 'Due'),
                  color: _fullyPaid
                      ? const Color(0xFF059669)
                      : const Color(0xFFE11D48),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF1F2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFECACA)),
            ),
            child: Row(
              children: [
                Text(
                  'Payment Status',
                  style: portalText(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF9F1239),
                  ),
                ),
                const Spacer(),
                Text(
                  _fullyPaid && _services.isNotEmpty ? 'PAID' : 'DUE',
                  style: portalText(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFFE11D48),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _doctorPaymentCard() {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(
            icon: Icons.payments_outlined,
            iconColor: Color(0xFF7C3AED),
            title: 'Payment Details',
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFBFDBFE)),
            ),
            child: Row(
              children: [
                Text(
                  '${_services.length} items',
                  style: portalText(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1E40AF),
                  ),
                ),
                const Spacer(),
                Text(
                  'SUBTOTAL: ${_money(_subtotal)}',
                  style: portalText(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF1E3A8A),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF059669),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Text(
                  'Payable Amount',
                  style: portalText(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                Text(
                  _money(_payable),
                  style: portalText(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const _Label(text: 'Amount Received'),
          _Field(
            child: TextField(
              controller: _amountReceived,
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() {}),
              style: _inputStyle,
              decoration: _hint('0 for Due'),
            ),
          ),
          const SizedBox(height: 12),
          const _Label(text: 'Payment Mode'),
          _Select(
            value: _paymentMode,
            muted: _paymentMode == 'Select Mode',
            onTap: () => _pickOption(
              label: 'Payment Mode',
              options: _modes,
              current: _paymentMode == 'Select Mode' ? null : _paymentMode,
              onSelect: (v) => setState(() => _paymentMode = v),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _Label(text: 'Discount'),
                    _Field(
                      child: TextField(
                        controller: _discount,
                        keyboardType: TextInputType.number,
                        onChanged: (_) => setState(() {}),
                        style: _inputStyle,
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
                    const _Label(text: 'Discount Type'),
                    _Select(
                      value: _discountType,
                      onTap: () => _pickOption(
                        label: 'Discount Type',
                        options: _discountTypes,
                        current: _discountType,
                        onSelect: (v) => setState(() => _discountType = v),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const _Label(text: 'Due Amount'),
          _Field(
            filled: const Color(0xFFFFF1F2),
            borderColor: const Color(0xFFFECACA),
            child: Text(
              _money(_due),
              style: portalText(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: const Color(0xFFE11D48),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _MiniStat(
                  label: 'TOTAL PAYABLE',
                  value: _money(_payable),
                  color: const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _MiniStat(
                  label: 'RECEIVING',
                  value: _money(_received),
                  color: const Color(0xFF2563EB),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _MiniStat(
                  label: 'STATUS',
                  value: _fullyPaid ? 'Fully Paid' : 'Due',
                  color: _fullyPaid
                      ? const Color(0xFF059669)
                      : const Color(0xFFE11D48),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF1F2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFECACA)),
            ),
            child: Row(
              children: [
                Text(
                  'Payment Status',
                  style: portalText(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF9F1239),
                  ),
                ),
                const Spacer(),
                Text(
                  _fullyPaid ? 'PAID' : 'DUE',
                  style: portalText(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFFE11D48),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  TextStyle get _inputStyle => portalText(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF0F172A),
      );

  InputDecoration _hint(String text) => InputDecoration(
        isDense: true,
        border: InputBorder.none,
        hintText: text,
        hintStyle: portalText(fontSize: 12, color: const Color(0xFF94A3B8)),
      );
}

class _Header extends StatelessWidget {
  const _Header({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.97),
        border: const Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 12,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBack,
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(11),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 16,
                color: Color(0xFF334155),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Register OPD Patient & Book Slot',
                  style: portalText(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F172A),
                    height: 1.15,
                  ),
                ),
                Text(
                  'Fill in patient and consultation details',
                  style: portalText(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),
          Container(
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
        ],
      ),
    );
  }
}

class _StepBar extends StatelessWidget {
  const _StepBar({required this.step, required this.onTap});

  final int step;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        children: [
          Expanded(
            child: _StepItem(
              active: step == 0,
              done: step > 0,
              icon: Icons.person_add_alt_1_rounded,
              label: 'Patient Details',
              onTap: () => onTap(0),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _StepItem(
              active: step == 1,
              done: false,
              icon: Icons.medical_services_outlined,
              label: 'Booking & Payment',
              onTap: () => onTap(1),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepItem extends StatelessWidget {
  const _StepItem({
    required this.active,
    required this.done,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final bool active;
  final bool done;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = done
        ? const Color(0xFF059669)
        : active
            ? OpColors.primary
            : const Color(0xFF94A3B8);
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                done ? Icons.check_circle_rounded : icon,
                size: 16,
                color: color,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: portalText(
                    fontSize: 12,
                    fontWeight: active || done ? FontWeight.w800 : FontWeight.w600,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 3,
            decoration: BoxDecoration(
              color: active || done ? color : const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomStep1 extends StatelessWidget {
  const _BottomStep1({required this.onCancel, required this.onNext});

  final VoidCallback onCancel;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: onCancel,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  side: const BorderSide(color: Color(0xFFCBD5E1)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Cancel',
                  style: portalText(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF334155),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: onNext,
                style: ElevatedButton.styleFrom(
                  backgroundColor: OpColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  minimumSize: const Size.fromHeight(48),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        'Next: Booking & Payment',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: portalText(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 2),
                    const Icon(Icons.chevron_right_rounded, size: 18),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomStep2 extends StatelessWidget {
  const _BottomStep2({
    required this.onCancel,
    required this.onBack,
    required this.onConfirm,
  });

  final VoidCallback onCancel;
  final VoidCallback onBack;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 14),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: onCancel,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  side: const BorderSide(color: Color(0xFFCBD5E1)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Cancel',
                  style: portalText(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF334155),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onBack,
                icon: const Icon(Icons.arrow_back_rounded, size: 16),
                label: Text(
                  'Back',
                  style: portalText(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF334155),
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF334155),
                  minimumSize: const Size.fromHeight(48),
                  side: const BorderSide(color: Color(0xFFCBD5E1)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: onConfirm,
                icon: const Icon(Icons.calendar_month_rounded, size: 16),
                label: Text(
                  'Confirm & Book Slot',
                  style: portalText(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF059669),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A0F172A),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.icon,
    required this.iconColor,
    required this.title,
  });

  final IconData icon;
  final Color iconColor;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 15, color: iconColor),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: portalText(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0F172A),
            ),
          ),
        ),
      ],
    );
  }
}

class _Label extends StatelessWidget {
  const _Label({required this.text, this.required = false});

  final String text;
  final bool required;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: RichText(
        text: TextSpan(
          text: text.toUpperCase(),
          style: portalText(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF64748B),
            letterSpacing: 0.35,
          ),
          children: required
              ? [
                  TextSpan(
                    text: ' *',
                    style: portalText(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFFE11D48),
                    ),
                  ),
                ]
              : null,
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.child,
    this.minHeight = 44,
    this.filled,
    this.borderColor,
  });

  final Widget child;
  final double minHeight;
  final Color? filled;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: minHeight),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        color: filled ?? Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor ?? const Color(0xFFE2E8F0)),
      ),
      child: child,
    );
  }
}

class _Select extends StatelessWidget {
  const _Select({
    required this.value,
    required this.onTap,
    this.muted = false,
    this.enabled = true,
    this.icon,
  });

  final String value;
  final VoidCallback onTap;
  final bool muted;
  final bool enabled;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final isCal = icon == Icons.calendar_today_outlined;
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: _Field(
        filled: enabled ? null : const Color(0xFFF1F5F9),
        child: Row(
          children: [
            if (icon != null && !isCal) ...[
              Icon(icon, size: 16, color: const Color(0xFF64748B)),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: portalText(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: muted || !enabled
                      ? const Color(0xFF94A3B8)
                      : const Color(0xFF0F172A),
                ),
              ),
            ),
            Icon(
              isCal
                  ? Icons.calendar_today_outlined
                  : Icons.keyboard_arrow_down_rounded,
              size: 18,
              color: const Color(0xFF94A3B8),
            ),
          ],
        ),
      ),
    );
  }
}

class _ServiceChip extends StatelessWidget {
  const _ServiceChip({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.onTap,
    this.accent = const Color(0xFF7C3AED),
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(8, 10, 8, 10),
        decoration: BoxDecoration(
          color: selected ? accent.withValues(alpha: 0.08) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? accent : const Color(0xFFE2E8F0),
            width: selected ? 1.6 : 1,
          ),
        ),
        child: Stack(
          children: [
            Column(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: selected
                        ? accent.withValues(alpha: 0.12)
                        : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    size: 15,
                    color: selected ? accent : const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: portalText(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F172A),
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: portalText(
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF94A3B8),
                    height: 1.2,
                  ),
                ),
              ],
            ),
            if (selected)
              Positioned(
                top: 0,
                right: 0,
                child: Icon(
                  Icons.check_circle_rounded,
                  size: 14,
                  color: accent,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Text(
            label,
            textAlign: TextAlign.center,
            style: portalText(
              fontSize: 8,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF94A3B8),
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: portalText(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
        ],
      ),
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
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: portalText(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 10),
          for (final o in options)
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: Text(
                o,
                style: portalText(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF0F172A),
                ),
              ),
              trailing: selected == o
                  ? const Icon(Icons.check_rounded, color: OpColors.primary)
                  : null,
              onTap: () => Navigator.pop(context, o),
            ),
        ],
      ),
    );
  }
}

class _AmountTable extends StatelessWidget {
  const _AmountTable({
    required this.nameHeader,
    required this.emptyText,
    required this.rows,
    required this.onRemove,
  });

  final String nameHeader;
  final String emptyText;
  final List<({String name, String price})> rows;
  final ValueChanged<int> onRemove;

  static const _cols = <int, TableColumnWidth>{
    0: FixedColumnWidth(28),
    1: FixedColumnWidth(96),
    2: FixedColumnWidth(64),
    3: FixedColumnWidth(48),
    4: FixedColumnWidth(70),
    5: FixedColumnWidth(64),
    6: FixedColumnWidth(88),
    7: FixedColumnWidth(56),
    8: FixedColumnWidth(96),
    9: FixedColumnWidth(56),
    10: FixedColumnWidth(40),
  };

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Table(
            columnWidths: _cols,
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: [
              TableRow(
                decoration: const BoxDecoration(color: Color(0xFFF1F5F9)),
                children: [
                  _h('#'),
                  _h(nameHeader),
                  _h('AMOUNT'),
                  _h('DISC.'),
                  _h('DISC TYPE'),
                  _h('PAYMENT'),
                  _h('PAYMENT TYPE'),
                  _h('STATUS'),
                  _h('TRANSACTION ID'),
                  _h('DUE', highlight: true),
                  _h('ACT'),
                ],
              ),
              if (rows.isEmpty)
                TableRow(
                  children: [
                    const SizedBox.shrink(),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 24,
                      ),
                      child: Text(
                        emptyText,
                        style: portalText(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF94A3B8),
                        ).copyWith(fontStyle: FontStyle.italic),
                      ),
                    ),
                    for (var i = 0; i < 9; i++) const SizedBox.shrink(),
                  ],
                )
              else
                for (var i = 0; i < rows.length; i++)
                  TableRow(
                    children: [
                      _c('${i + 1}'),
                      _c(rows[i].name),
                      _c('₹${rows[i].price}'),
                      _c('0'),
                      _c('₹'),
                      _c('0'),
                      _c('—'),
                      _c('Due'),
                      _c('—'),
                      _c(
                        '₹${rows[i].price}',
                        color: const Color(0xFFE11D48),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Center(
                          child: GestureDetector(
                            onTap: () => onRemove(i),
                            child: const Icon(
                              Icons.delete_outline_rounded,
                              size: 18,
                              color: Color(0xFFE11D48),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _h(String text, {bool highlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
      child: highlight
          ? DecoratedBox(
              decoration: BoxDecoration(
                color: const Color(0xFFFFE4E6),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 2),
                child: Text(
                  text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: portalText(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFFE11D48),
                    letterSpacing: 0.1,
                  ),
                ),
              ),
            )
          : Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: portalText(
                fontSize: 9,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF64748B),
                letterSpacing: 0.1,
              ),
            ),
    );
  }

  Widget _c(String text, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
      child: Text(
        text,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: portalText(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color ?? const Color(0xFF334155),
        ),
      ),
    );
  }
}
