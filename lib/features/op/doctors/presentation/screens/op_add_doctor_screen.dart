import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:timelay_health/core/theme/portal_text.dart';
import 'package:timelay_health/features/op/doctors/presentation/models/op_doctors_ui.dart';
import 'package:timelay_health/features/op/dashboard/presentation/theme/op_colors.dart';
import 'package:timelay_health/features/op/shared/widgets/op_top_bar.dart';

class OpAddDoctorScreen extends StatefulWidget {
  const OpAddDoctorScreen({
    super.key,
    required this.specializations,
    this.existing,
    this.onMenuTap,
  });

  final List<String> specializations;
  final OpDoctorUi? existing;
  final VoidCallback? onMenuTap;

  @override
  State<OpAddDoctorScreen> createState() => _OpAddDoctorScreenState();
}

class _OpAddDoctorScreenState extends State<OpAddDoctorScreen> {
  late final TextEditingController _name;
  late final TextEditingController _email;
  late final TextEditingController _phone;
  late final TextEditingController _password;
  late final TextEditingController _qualification;
  late final TextEditingController _experience;
  late final TextEditingController _fee;
  late final TextEditingController _address;

  String? _specialization;
  String? _startTime;
  String? _endTime;
  final List<String> _days = [];
  bool _active = true;
  bool _obscure = true;
  String? _error;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _name = TextEditingController(text: e?.name ?? '');
    _email = TextEditingController(text: e?.email ?? '');
    _phone = TextEditingController(text: e?.phone ?? '');
    _password = TextEditingController();
    _qualification = TextEditingController(text: e?.qualification ?? '');
    _experience =
        TextEditingController(text: e == null ? '' : '${e.experienceYrs}');
    _fee = TextEditingController(text: e == null ? '' : '${e.fee}');
    _address = TextEditingController(text: e?.address ?? '');
    _specialization = e?.specialization;
    _startTime = e?.startTime;
    _endTime = e?.endTime;
    if (e != null) _days.addAll(e.scheduleDays);
    _active = e?.active ?? true;
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _password.dispose();
    _qualification.dispose();
    _experience.dispose();
    _fee.dispose();
    _address.dispose();
    super.dispose();
  }

  String _joinedNow() {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final now = DateTime.now();
    final dd = now.day.toString().padLeft(2, '0');
    return '$dd ${months[now.month - 1]} ${now.year} '
        '${TimeOfDay.now().format(context).toLowerCase()}';
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
      builder: (_) => _PickerSheet(
        label: label,
        options: options,
        selected: current,
      ),
    );
    if (result != null) onSelect(result);
  }

  void _submit() {
    setState(() => _error = null);
    final name = _name.text.trim();
    final phone = _phone.text.trim();
    final password = _password.text.trim();

    if (name.isEmpty) {
      setState(() => _error = 'Doctor name is required');
      return;
    }
    if (phone.isEmpty) {
      setState(() => _error = 'Phone number is required');
      return;
    }
    if (_specialization == null || _specialization!.isEmpty) {
      setState(() => _error = 'Specialization is required');
      return;
    }
    if (!_isEdit && password.length < 6) {
      setState(() => _error = 'Password must be at least 6 characters long');
      return;
    }
    if (_isEdit && password.isNotEmpty && password.length < 6) {
      setState(() => _error = 'Password must be at least 6 characters long');
      return;
    }

    final displayName = name.toUpperCase().startsWith('DR')
        ? name.toUpperCase()
        : 'DR ${name.toUpperCase()}';

    final doctor = OpDoctorUi(
      id: widget.existing?.id ?? 'd${DateTime.now().millisecondsSinceEpoch}',
      name: displayName,
      phone: phone,
      email: _email.text.trim(),
      specialization: _specialization!,
      qualification: _qualification.text.trim().isEmpty
          ? 'MBBS'
          : _qualification.text.trim(),
      experienceYrs: int.tryParse(_experience.text.trim()) ?? 0,
      fee: int.tryParse(_fee.text.trim()) ?? 0,
      scheduleDays: List.of(_days),
      startTime: _startTime ?? '09:00 AM',
      endTime: _endTime ?? '08:30 PM',
      active: _active,
      joinedAt: widget.existing?.joinedAt ?? _joinedNow(),
      avatarColor: widget.existing?.avatarColor ?? OpColors.blue,
      address: _address.text.trim(),
    );
    Navigator.of(context).pop(doctor);
  }

  TextStyle get _fieldStyle => portalText(
        fontSize: 13.5,
        fontWeight: FontWeight.w600,
        color: OpColors.heading,
      );

  InputDecoration _deco(String hint) => InputDecoration(
        isDense: true,
        border: InputBorder.none,
        hintText: hint,
        hintStyle: portalText(fontSize: 12.5, color: const Color(0xFF94A3B8)),
      );

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: OpColors.background,
      child: Column(
        children: [
          OpTopBar(
            title: _isEdit ? 'Edit Doctor' : 'Add Doctor',
            showBack: true,
            onMenuTap:
                widget.onMenuTap ?? () => Navigator.of(context).maybePop(),
          ),
          Expanded(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
              children: [
                _TopBanner(isEdit: _isEdit),
                const SizedBox(height: 10),
                _Section(
                  title: 'Basic Details',
                  children: [
                    _Label('Doctor Name *'),
                    _Box(
                      child: TextField(
                        controller: _name,
                        textCapitalization: TextCapitalization.words,
                        style: _fieldStyle,
                        decoration: _deco('Dr. John Doe'),
                      ),
                    ),
                    const SizedBox(height: 10),
                    _Label('Email'),
                    _Box(
                      child: TextField(
                        controller: _email,
                        keyboardType: TextInputType.emailAddress,
                        style: _fieldStyle,
                        decoration: _deco('doctor@email.com'),
                      ),
                    ),
                    const SizedBox(height: 10),
                    _Label('Phone Number *'),
                    _Box(
                      child: Row(
                        children: [
                          Text('+91', style: _fieldStyle.copyWith(fontWeight: FontWeight.w800)),
                          Container(
                            width: 1,
                            height: 18,
                            margin: const EdgeInsets.symmetric(horizontal: 8),
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
                              style: _fieldStyle,
                              decoration: _deco('9876543210'),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    _Label('Specialization *'),
                    _Box(
                      child: _SelectRow(
                        value: _specialization ?? 'Select Specialization',
                        muted: _specialization == null,
                        onTap: () => _pickOption(
                          label: 'Specialization',
                          options: widget.specializations,
                          current: _specialization,
                          onSelect: (v) => setState(() => _specialization = v),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    _Label(_isEdit ? 'Password' : 'Password *'),
                    _Box(
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _password,
                              obscureText: _obscure,
                              style: _fieldStyle,
                              decoration: _deco(
                                _isEdit
                                    ? 'Leave blank to keep current'
                                    : 'Min 6 characters',
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => setState(() => _obscure = !_obscure),
                            visualDensity: VisualDensity.compact,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                            icon: Icon(
                              _obscure
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              size: 17,
                              color: OpColors.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _Section(
                  title: 'Professional Info',
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _Label('Qualification'),
                              _Box(
                                child: TextField(
                                  controller: _qualification,
                                  style: _fieldStyle,
                                  decoration: _deco('MBBS, MD...'),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 96,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _Label('Exp (Yrs)'),
                              _Box(
                                child: TextField(
                                  controller: _experience,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(2),
                                  ],
                                  style: _fieldStyle,
                                  decoration: _deco('5'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _Label('Fee (₹)'),
                              _Box(
                                child: TextField(
                                  controller: _fee,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  style: _fieldStyle,
                                  decoration: _deco('500'),
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
                              _Label('Status'),
                              Row(
                                children: [
                                  Expanded(
                                    child: _StatusChip(
                                      label: 'Active',
                                      selected: _active,
                                      color: OpColors.green,
                                      onTap: () => setState(() => _active = true),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: _StatusChip(
                                      label: 'Inactive',
                                      selected: !_active,
                                      color: OpColors.orange,
                                      onTap: () => setState(() => _active = false),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _Label('Clinic / Hospital Address'),
                    _Box(
                      minHeight: 68,
                      child: TextField(
                        controller: _address,
                        maxLines: 3,
                        style: _fieldStyle,
                        decoration: _deco('Clinic address or Hospital room #'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _Section(
                  title: 'Availability',
                  children: [
                    _Label('Available Days'),
                    const SizedBox(height: 2),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: OpDoctorsUi.weekDays.map((d) {
                        final selected = _days.contains(d);
                        return GestureDetector(
                          onTap: () => setState(() {
                            if (selected) {
                              _days.remove(d);
                            } else {
                              _days.add(d);
                            }
                          }),
                          child: Container(
                            width: 40,
                            height: 34,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: selected ? OpColors.primary : Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: selected ? OpColors.primary : OpColors.border,
                              ),
                            ),
                            child: Text(
                              d,
                              style: portalText(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: selected ? Colors.white : OpColors.secondary,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 10),
                    _Label('Available Time'),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'START',
                                style: portalText(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: OpColors.muted,
                                ),
                              ),
                              const SizedBox(height: 4),
                              _Box(
                                child: _SelectRow(
                                  value: _startTime ?? 'Start Time',
                                  muted: _startTime == null,
                                  onTap: () => _pickOption(
                                    label: 'Start Time',
                                    options: OpDoctorsUi.timeSlots,
                                    current: _startTime,
                                    onSelect: (v) => setState(() => _startTime = v),
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
                              Text(
                                'END',
                                style: portalText(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: OpColors.muted,
                                ),
                              ),
                              const SizedBox(height: 4),
                              _Box(
                                child: _SelectRow(
                                  value: _endTime ?? 'End Time',
                                  muted: _endTime == null,
                                  onTap: () => _pickOption(
                                    label: 'End Time',
                                    options: OpDoctorsUi.timeSlots,
                                    current: _endTime,
                                    onSelect: (v) => setState(() => _endTime = v),
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
                if (_error != null) ...[
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: OpColors.redTint,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: OpColors.red.withValues(alpha: 0.2)),
                    ),
                    child: Text(
                      _error!,
                      style: portalText(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: OpColors.red,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              color: Colors.white,
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(36),
                        padding: EdgeInsets.zero,
                        side: const BorderSide(color: OpColors.border),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: portalText(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: OpColors.secondary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: OpColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        minimumSize: const Size.fromHeight(36),
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        _isEdit ? 'Update Doctor' : 'Add Doctor',
                        style: portalText(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
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
}

class _TopBanner extends StatelessWidget {
  const _TopBanner({required this.isEdit});

  final bool isEdit;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            OpColors.primary,
            OpColors.primary.withValues(alpha: 0.82),
            const Color(0xFF0EA5E9),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: OpColors.primary.withValues(alpha: 0.22),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
            ),
            alignment: Alignment.center,
            child: Icon(
              isEdit ? Icons.edit_outlined : Icons.person_add_alt_1_rounded,
              size: 20,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEdit ? 'Update Doctor Profile' : 'New Doctor Profile',
                  style: portalText(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isEdit
                      ? 'Edit details and keep the roster in sync'
                      : 'Add doctor details to manage OPD bookings',
                  style: portalText(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.88),
                    height: 1.25,
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

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE8ECF2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: portalText(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: OpColors.heading,
            ),
          ),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Text(
        text,
        style: portalText(
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
          color: OpColors.secondary,
        ),
      ),
    );
  }
}

class _Box extends StatelessWidget {
  const _Box({required this.child, this.minHeight = 42});

  final Widget child;
  final double minHeight;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minHeight: minHeight),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      alignment: Alignment.centerLeft,
      child: child,
    );
  }
}

class _SelectRow extends StatelessWidget {
  const _SelectRow({
    required this.value,
    required this.onTap,
    this.muted = false,
  });

  final String value;
  final VoidCallback onTap;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: portalText(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: muted ? const Color(0xFF94A3B8) : OpColors.heading,
                ),
              ),
            ),
            const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: Color(0xFF94A3B8)),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? color.withValues(alpha: 0.12) : Colors.white,
      borderRadius: BorderRadius.circular(11),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(11),
        child: Container(
          height: 42,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(11),
            border: Border.all(color: selected ? color : OpColors.border),
          ),
          child: Text(
            label,
            style: portalText(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: selected ? color : OpColors.secondary,
            ),
          ),
        ),
      ),
    );
  }
}

class _PickerSheet extends StatelessWidget {
  const _PickerSheet({
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
      top: false,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.5,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 8),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 8, 6),
              child: Row(
                children: [
                  Text(label, style: portalText(fontSize: 15, fontWeight: FontWeight.w800)),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded, size: 20),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.separated(
                itemCount: options.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, i) {
                  final opt = options[i];
                  final isSelected = opt == selected;
                  return ListTile(
                    dense: true,
                    onTap: () => Navigator.pop(context, opt),
                    title: Text(
                      opt,
                      style: portalText(
                        fontSize: 13.5,
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                        color: isSelected ? OpColors.primary : OpColors.heading,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check_rounded, color: OpColors.primary, size: 18)
                        : null,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
