import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:timelay_health/core/theme/portal_text.dart';
import 'package:timelay_health/features/op/dashboard/presentation/models/op_doctors_ui.dart';
import 'package:timelay_health/features/op/dashboard/presentation/theme/op_colors.dart';
import 'package:timelay_health/features/op/dashboard/presentation/widgets/op_top_bar.dart';

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
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
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

  InputDecoration _hint(String text) => InputDecoration(
        isDense: true,
        border: InputBorder.none,
        hintText: text,
        hintStyle: portalText(fontSize: 13, color: OpColors.muted),
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
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 20),
              children: [
                _HeroHeader(isEdit: _isEdit),
                const SizedBox(height: 12),
                _SectionCard(
                  children: [
                    const _FieldLabel(
                      icon: Icons.person_outline,
                      text: 'Doctor Name *',
                    ),
                    _InputShell(
                      child: TextField(
                        controller: _name,
                        textCapitalization: TextCapitalization.words,
                        style: portalText(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: OpColors.heading,
                        ),
                        decoration: _hint('Dr. John Doe'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const _FieldLabel(
                      icon: Icons.mail_outline,
                      text: 'Email',
                    ),
                    _InputShell(
                      child: TextField(
                        controller: _email,
                        keyboardType: TextInputType.emailAddress,
                        style: portalText(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: OpColors.heading,
                        ),
                        decoration: _hint('doctor@email.com'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const _FieldLabel(
                      icon: Icons.phone_outlined,
                      text: 'Phone Number *',
                    ),
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
                              decoration: _hint('9876543210'),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    const _FieldLabel(
                      icon: Icons.workspace_premium_outlined,
                      text: 'Specialization *',
                    ),
                    _SelectShell(
                      value: _specialization ?? 'Select Specialization',
                      muted: _specialization == null,
                      onTap: () => _pickOption(
                        label: 'Specialization',
                        options: widget.specializations,
                        current: _specialization,
                        onSelect: (v) => setState(() => _specialization = v),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _FieldLabel(
                      icon: Icons.lock_outline,
                      text: _isEdit ? 'Password' : 'Password *',
                    ),
                    _InputShell(
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _password,
                              obscureText: _obscure,
                              style: portalText(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: OpColors.heading,
                              ),
                              decoration: _hint(
                                _isEdit
                                    ? 'Leave blank to keep current'
                                    : 'Min 6 characters',
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () =>
                                setState(() => _obscure = !_obscure),
                            icon: Icon(
                              _obscure
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              size: 18,
                              color: OpColors.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Password must be at least 6 characters long',
                      style: portalText(
                        fontSize: 11.5,
                        color: OpColors.muted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _SectionCard(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const _FieldLabel(
                                icon: Icons.school_outlined,
                                text: 'Qualification',
                              ),
                              _InputShell(
                                child: TextField(
                                  controller: _qualification,
                                  style: portalText(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: OpColors.heading,
                                  ),
                                  decoration: _hint('MBBS, MD...'),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        SizedBox(
                          width: 110,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const _FieldLabel(
                                icon: Icons.work_outline,
                                text: 'Exp (Yrs)',
                              ),
                              _InputShell(
                                child: TextField(
                                  controller: _experience,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(2),
                                  ],
                                  style: portalText(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: OpColors.heading,
                                  ),
                                  decoration: _hint('5'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const _FieldLabel(
                                icon: Icons.currency_rupee_rounded,
                                text: 'Fee (₹)',
                              ),
                              _InputShell(
                                child: TextField(
                                  controller: _fee,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  style: portalText(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: OpColors.heading,
                                  ),
                                  decoration: _hint('500'),
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
                              const _FieldLabel(text: 'Status'),
                              Row(
                                children: [
                                  Expanded(
                                    child: _StatusChip(
                                      label: 'Active',
                                      selected: _active,
                                      color: OpColors.green,
                                      tint: OpColors.greenTint,
                                      icon: Icons.check_circle_rounded,
                                      onTap: () =>
                                          setState(() => _active = true),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: _StatusChip(
                                      label: 'Off',
                                      selected: !_active,
                                      color: OpColors.red,
                                      tint: OpColors.redTint,
                                      icon: Icons.cancel_rounded,
                                      onTap: () =>
                                          setState(() => _active = false),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const _FieldLabel(
                      icon: Icons.location_on_outlined,
                      text: 'Clinic / Hospital Address',
                    ),
                    _InputShell(
                      minHeight: 78,
                      child: TextField(
                        controller: _address,
                        maxLines: 3,
                        style: portalText(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: OpColors.heading,
                        ),
                        decoration: _hint('Clinic address or Hospital room #'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _SectionCard(
                  children: [
                    const _FieldLabel(
                      icon: Icons.calendar_month_outlined,
                      text: 'Available Days',
                    ),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
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
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 160),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: selected ? OpColors.blue : OpColors.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color:
                                    selected ? OpColors.blue : OpColors.border,
                              ),
                            ),
                            child: Text(
                              d,
                              style: portalText(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w800,
                                color: selected
                                    ? Colors.white
                                    : OpColors.secondary,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 14),
                    const _FieldLabel(
                      icon: Icons.schedule_rounded,
                      text: 'Available Time Schedule',
                    ),
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
                                  fontWeight: FontWeight.w800,
                                  color: OpColors.muted,
                                  letterSpacing: 0.4,
                                ),
                              ),
                              const SizedBox(height: 6),
                              _SelectShell(
                                value: _startTime ?? 'Start Time',
                                muted: _startTime == null,
                                onTap: () => _pickOption(
                                  label: 'Start Time',
                                  options: OpDoctorsUi.timeSlots,
                                  current: _startTime,
                                  onSelect: (v) =>
                                      setState(() => _startTime = v),
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
                                'END',
                                style: portalText(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: OpColors.muted,
                                  letterSpacing: 0.4,
                                ),
                              ),
                              const SizedBox(height: 6),
                              _SelectShell(
                                value: _endTime ?? 'End Time',
                                muted: _endTime == null,
                                onTap: () => _pickOption(
                                  label: 'End Time',
                                  options: OpDoctorsUi.timeSlots,
                                  current: _endTime,
                                  onSelect: (v) =>
                                      setState(() => _endTime = v),
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
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: OpColors.redTint,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: OpColors.red.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Text(
                      _error!,
                      style: portalText(
                        fontSize: 12.5,
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
                      onPressed: () => Navigator.of(context).maybePop(),
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
                      onPressed: _submit,
                      icon: Icon(
                        _isEdit ? Icons.check_rounded : Icons.add_rounded,
                        size: 20,
                      ),
                      label: Text(
                        _isEdit ? 'Update Doctor' : 'Add Doctor',
                        style: portalText(
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: OpColors.blue,
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
}

class _HeroHeader extends StatelessWidget {
  const _HeroHeader({required this.isEdit});

  final bool isEdit;

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
                colors: [Color(0xFF3B82F6), Color(0xFF60A5FA)],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              isEdit
                  ? Icons.edit_rounded
                  : Icons.medical_services_rounded,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEdit ? 'Edit Doctor Profile' : 'Add New Doctor',
                  style: portalText(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: OpColors.heading,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Fill in the doctor profile information',
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
  const _SectionCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: OpColors.surface,
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
  const _InputShell({required this.child, this.minHeight = 46});

  final Widget child;
  final double minHeight;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minHeight: minHeight),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: OpColors.border),
      ),
      alignment: Alignment.centerLeft,
      child: child,
    );
  }
}

class _SelectShell extends StatelessWidget {
  const _SelectShell({
    required this.value,
    required this.onTap,
    this.muted = false,
  });

  final String value;
  final VoidCallback onTap;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF8FAFC),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: 46,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
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
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: muted ? OpColors.muted : OpColors.heading,
                  ),
                ),
              ),
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: OpColors.muted,
              ),
            ],
          ),
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
    required this.tint,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Color color;
  final Color tint;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? tint : OpColors.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: 46,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? color : OpColors.border,
              width: selected ? 1.4 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 15, color: selected ? color : OpColors.muted),
              const SizedBox(width: 4),
              Text(
                label,
                style: portalText(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: selected ? color : OpColors.secondary,
                ),
              ),
            ],
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
          maxHeight: MediaQuery.sizeOf(context).height * 0.55,
        ),
        decoration: const BoxDecoration(
          color: OpColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                color: OpColors.border,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 8, 8),
              child: Row(
                children: [
                  Text(
                    label,
                    style: portalText(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
                itemCount: options.length,
                separatorBuilder: (_, _) => const SizedBox(height: 6),
                itemBuilder: (context, i) {
                  final item = options[i];
                  final active = item == selected;
                  return Material(
                    color: active ? OpColors.blueTint : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(14),
                    child: InkWell(
                      onTap: () => Navigator.pop(context, item),
                      borderRadius: BorderRadius.circular(14),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 14,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                item,
                                style: portalText(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: active
                                      ? OpColors.blue
                                      : OpColors.heading,
                                ),
                              ),
                            ),
                            if (active)
                              const Icon(
                                Icons.check_circle_rounded,
                                size: 18,
                                color: OpColors.blue,
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
    );
  }
}
