import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:timelay_health/core/theme/portal_colors.dart';
import 'package:timelay_health/core/theme/portal_text.dart';
import 'package:timelay_health/features/auth/domain/entities/employee.dart';
import 'package:timelay_health/core/widgets/portal_back_button.dart';
import 'package:timelay_health/core/widgets/portal_safe_area.dart';

class EmployeeDetailsScreen extends StatelessWidget {
  const EmployeeDetailsScreen({super.key, required this.employee});

  final Employee employee;

  static Future<void> open(BuildContext context, Employee employee) {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => EmployeeDetailsScreen(employee: employee),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final e = employee;
    final i = e.info;
    return Scaffold(
      backgroundColor: PortalColors.background,
      body: PortalSafeArea(
        bottom: false,
        child: Column(
          children: [
            const _AppBar(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
                children: [
                  _HeaderCard(employee: e),
                  const SizedBox(height: 14),
                  _Section(
                    icon: Icons.person_rounded,
                    color: const Color(0xFF3B6FE0),
                    tint: const Color(0xFFEAF0FD),
                    title: 'Basic Details',
                    fields: [
                      _Field('Full Name', e.displayName),
                      _Field('Email', e.email, full: true),
                      _Field('Phone', e.phone ?? ''),
                      _Field('Alternate Number', i.alternateNumber),
                      _Field('Parents Name', i.parentsName),
                      _Field('Gender', _capitalize(i.gender)),
                      _Field('Date of Birth', _date(i.dob)),
                      _Field('Employee ID', e.employeeId),
                      _Field('Join Date', _date(e.joinDate)),
                    ],
                  ),
                  _Section(
                    icon: Icons.location_on_rounded,
                    color: PortalColors.green,
                    tint: PortalColors.greenTint,
                    title: 'Address Details',
                    fields: [
                      _Field('Address Line 1', i.addressLine1, full: true),
                      _Field('Address Line 2', i.addressLine2, full: true),
                      _Field('City', i.city),
                      _Field('State', i.state),
                      _Field('Pin Code', i.pinCode),
                      _Field('Country', i.country),
                      _Field('Full Address', e.address ?? '', full: true),
                    ],
                  ),
                  _Section(
                    icon: Icons.apartment_rounded,
                    color: PortalColors.purple,
                    tint: PortalColors.purpleTint,
                    title: 'Office Details',
                    fields: [
                      _Field('Department', e.department),
                      _Field('Role / Designation', e.role),
                      _Field('Employment Type', _employmentType(i)),
                      _Field('Reporting Manager', i.reportingManager),
                      _Field('Status', _capitalize(e.status ?? '')),
                      _Field('Work Location', i.workLocation, full: true),
                    ],
                  ),
                  _Section(
                    icon: Icons.account_balance_rounded,
                    color: const Color(0xFF4F46E5),
                    tint: const Color(0xFFEEEDFD),
                    title: 'Bank & Documents',
                    fields: [
                      _Field('Bank Name', i.bankName),
                      _Field('IFSC Code', i.ifscCode),
                      _Field(
                        'Bank Account No',
                        i.bankAccountNo,
                        full: true,
                        sensitive: true,
                      ),
                      _Field('PAN Card Number', i.panNumber, sensitive: true),
                      _Field(
                        'Aadhaar Card Number',
                        i.aadharNumber,
                        sensitive: true,
                      ),
                      _Field('UAN Number', i.uanNumber),
                      _Field('PF Number', i.pfNumber),
                      _Field('ESIC Number', i.esicNumber),
                    ],
                  ),
                  _Section(
                    icon: Icons.payments_rounded,
                    color: PortalColors.green,
                    tint: PortalColors.greenTint,
                    title: 'Salary Details',
                    fields: [
                      _Field('Basic Pay', _money(e.basicPay)),
                      _Field('HRA', _money(e.hra)),
                      _Field('Conveyance', _money(e.conveyanceAllowance)),
                      _Field('Medical', _money(e.medicalAllowance)),
                      _Field('Performance', _money(e.performanceAllowance)),
                      _Field('Special Allowance', _money(e.specialAllowance)),
                      _Field(
                        'Net Salary',
                        _money(e.salaryPerMonth ?? 0),
                        highlight: true,
                      ),
                      _Field('Yearly CTC', _money(i.ctc), highlight: true),
                    ],
                  ),
                  _Section(
                    icon: Icons.event_note_rounded,
                    color: PortalColors.orange,
                    tint: PortalColors.orangeTint,
                    title: 'HR & Leave Policy',
                    fields: [
                      _Field('Shift Type', i.shiftType),
                      _Field(
                        'Shift Hours',
                        i.shiftHours == null ? '' : '${_num(i.shiftHours)} hrs',
                      ),
                      _Field('Week Off Day', i.weekOffDay),
                      _Field('Week Offs / Month', _num(i.weekOffPerMonth)),
                      _Field('Max CL', _num(i.maxCL)),
                      _Field('Max SL', _num(i.maxSL)),
                      _Field('Max EL', _num(i.maxEL)),
                      _Field('Max Comp Off', _num(i.maxCompOff)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static const _months = [
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

  static String _date(DateTime? d) {
    if (d == null) return '';
    final local = d.toLocal();
    return '${local.day.toString().padLeft(2, '0')} '
        '${_months[local.month - 1]} ${local.year}';
  }

  static String _money(double value) {
    final amount = value.round().toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
    return '₹$amount';
  }

  static String _num(num? value) {
    if (value == null) return '';
    return value % 1 == 0 ? value.toInt().toString() : value.toString();
  }

  static String _capitalize(String value) {
    final v = value.trim();
    if (v.isEmpty) return '';
    return v[0].toUpperCase() + v.substring(1);
  }

  static String _employmentType(EmployeeProfileInfo i) {
    return switch (i.employmentType.trim().toLowerCase()) {
      'fulltime' || 'full-time' || 'full time' => 'Full Time',
      'parttime' || 'part-time' || 'part time' => 'Part Time',
      final other => _capitalize(other),
    };
  }
}

class _AppBar extends StatelessWidget {
  const _AppBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: PortalColors.surface,
        border: Border(bottom: BorderSide(color: PortalColors.border)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 10, 18, 10),
      child: Row(
        children: [
          const PortalBackButton(),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Employee Details',
                  style: portalText(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: PortalColors.heading,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Complete profile information',
                  style: portalText(
                    fontSize: 11,
                    color: PortalColors.muted,
                    height: 1.3,
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

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.employee});

  final Employee employee;

  @override
  Widget build(BuildContext context) {
    final e = employee;
    final role = e.role.trim();
    final shift = e.info.shiftType.trim();
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: PortalColors.attendanceGradient,
        ),
        boxShadow: [
          BoxShadow(
            color: PortalColors.purple.withValues(alpha: 0.25),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(right: -30, top: -40, child: _bubble(130)),
          Positioned(right: 50, bottom: -50, child: _bubble(90)),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.35),
                        ),
                      ),
                      child: Text(
                        e.avatarLetter,
                        style: portalText(
                          fontSize: 22,
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
                            e.displayName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: portalText(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text.rich(
                            TextSpan(
                              children: [
                                const TextSpan(text: 'ID: '),
                                TextSpan(
                                  text: e.employeeId,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                if (role.isNotEmpty)
                                  TextSpan(text: '  •  $role'),
                              ],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: portalText(
                              fontSize: 11.5,
                              color: Colors.white.withValues(alpha: 0.88),
                            ),
                          ),
                        ],
                      ),
                    ),
                    _StatusPill(active: e.isActive, label: e.statusLabel),
                  ],
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      _HeaderStat(label: 'Joined', value: e.joinDateShort),
                      _divider(),
                      _HeaderStat(
                        label: 'Department',
                        value: e.department.trim().isEmpty ? '—' : e.department,
                      ),
                      _divider(),
                      _HeaderStat(
                        label: 'Shift',
                        value: shift.isEmpty ? '—' : 'Shift $shift',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _bubble(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.08),
      ),
    );
  }

  Widget _divider() {
    return Container(
      width: 1,
      height: 26,
      color: Colors.white.withValues(alpha: 0.25),
    );
  }
}

class _HeaderStat extends StatelessWidget {
  const _HeaderStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Column(
          children: [
            Text(
              label.toUpperCase(),
              style: portalText(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.6,
                color: Colors.white.withValues(alpha: 0.75),
              ),
            ),
            const SizedBox(height: 3),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: portalText(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.active, required this.label});

  final bool active;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: active ? PortalColors.green : PortalColors.red,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: portalText(
              fontSize: 9.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.4,
              color: active ? PortalColors.green : PortalColors.red,
            ),
          ),
        ],
      ),
    );
  }
}

class _Field {
  const _Field(
    this.label,
    this.value, {
    this.full = false,
    this.highlight = false,
    this.sensitive = false,
  });

  final String label;
  final String value;
  final bool full;
  final bool highlight;
  final bool sensitive;

  bool get isEmpty => value.trim().isEmpty;
}

class _Section extends StatelessWidget {
  const _Section({
    required this.icon,
    required this.color,
    required this.tint,
    required this.title,
    required this.fields,
  });

  final IconData icon;
  final Color color;
  final Color tint;
  final String title;
  final List<_Field> fields;

  @override
  Widget build(BuildContext context) {
    final filled = fields.where((f) => !f.isEmpty).length;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: PortalColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: PortalColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            child: Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: tint,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Icon(icon, size: 16, color: color),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: portalText(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: PortalColors.heading,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: tint,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '$filled/${fields.length}',
                    style: portalText(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1, color: PortalColors.border),
          Padding(
            padding: const EdgeInsets.all(12),
            child: LayoutBuilder(
              builder: (context, constraints) {
                const gap = 8.0;
                final half = (constraints.maxWidth - gap) / 2;
                return Wrap(
                  spacing: gap,
                  runSpacing: gap,
                  children: [
                    for (final f in fields)
                      SizedBox(
                        width: f.full ? constraints.maxWidth : half,
                        child: _FieldTile(field: f),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FieldTile extends StatefulWidget {
  const _FieldTile({required this.field});

  final _Field field;

  @override
  State<_FieldTile> createState() => _FieldTileState();
}

class _FieldTileState extends State<_FieldTile> {
  bool _revealed = false;

  String get _display {
    final f = widget.field;
    if (f.isEmpty) return 'N/A';
    final v = f.value.trim();
    if (!f.sensitive || _revealed || v.length <= 4) return v;
    return '•••• ${v.substring(v.length - 4)}';
  }

  void _copy() {
    final f = widget.field;
    if (f.isEmpty) return;
    Clipboard.setData(ClipboardData(text: f.value.trim()));
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('${f.label} copied'),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 1),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final f = widget.field;
    final canReveal = f.sensitive && !f.isEmpty && f.value.trim().length > 4;
    return Material(
      color: const Color(0xFFFAF9FD),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onLongPress: f.isEmpty ? null : _copy,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          constraints: const BoxConstraints(minHeight: 58),
          padding: const EdgeInsets.fromLTRB(11, 9, 8, 9),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: PortalColors.border),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      f.label.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: portalText(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                        color: PortalColors.muted,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _display,
                      style: portalText(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        height: 1.35,
                        color: f.isEmpty
                            ? PortalColors.muted.withValues(alpha: 0.7)
                            : f.highlight
                            ? PortalColors.green
                            : PortalColors.heading,
                      ),
                    ),
                  ],
                ),
              ),
              if (canReveal)
                GestureDetector(
                  onTap: () => setState(() => _revealed = !_revealed),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      _revealed
                          ? Icons.visibility_off_rounded
                          : Icons.visibility_rounded,
                      size: 16,
                      color: PortalColors.muted,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
