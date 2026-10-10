import 'package:flutter/material.dart';
import 'package:timelay_health/core/theme/portal_colors.dart';
import 'package:timelay_health/core/theme/portal_text.dart';
import 'package:timelay_health/features/auth/domain/entities/employee.dart';

class ResignationDraft {
  const ResignationDraft({required this.lastWorkingDay, required this.letter});

  final DateTime lastWorkingDay;
  final String letter;
}

Future<ResignationDraft?> showResignationDialog(
  BuildContext context, {
  required Employee employee,
}) {
  return showDialog<ResignationDraft>(
    context: context,
    barrierColor: const Color(0x70000000),
    builder: (_) => ResignationDialog(employee: employee),
  );
}

class ResignationDialog extends StatefulWidget {
  const ResignationDialog({super.key, required this.employee});

  final Employee employee;

  @override
  State<ResignationDialog> createState() => _ResignationDialogState();
}

class _ResignationDialogState extends State<ResignationDialog> {
  static const _redGradient = [Color(0xFFEF4444), Color(0xFFE11D48)];

  late final TextEditingController _letter;
  DateTime? _lastDay;
  bool _letterEdited = false;
  bool _settingTemplate = false;
  String? _dateError;
  String? _letterError;

  @override
  void initState() {
    super.initState();
    _letter = TextEditingController(text: _template());
    _letter.addListener(() {
      if (_settingTemplate) return;
      _letterEdited = true;
      if (_letterError != null) setState(() => _letterError = null);
    });
  }

  @override
  void dispose() {
    _letter.dispose();
    super.dispose();
  }

  String _template() {
    final e = widget.employee;
    final role = e.role.trim();
    final position = [
      if (role.isNotEmpty) role,
    ].join(' ');

    return 'Dear Manager,\n\n'
        'I am writing to formally resign from my position as $position '
        'at Timely Health Tech Pvt Ltd.\n\n'
        'I appreciate the opportunities for professional and personal '
        'development that I have had during my time here. Thank you for your '
        'support and guidance.\n\n'
        'I will do my best to ensure a smooth transition of my '
        'responsibilities before my departure.\n\n'
        'Best regards,\n'
        '${e.displayName}';
  }

  Future<void> _pickDate() async {
    final today = DateUtils.dateOnly(DateTime.now());
    final picked = await showDatePicker(
      context: context,
      initialDate: _lastDay ?? today.add(const Duration(days: 30)),
      firstDate: today,
      lastDate: today.add(const Duration(days: 365)),
      helpText: 'Last working day',
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(
            context,
          ).colorScheme.copyWith(primary: PortalColors.purple),
        ),
        child: child!,
      ),
    );
    if (picked == null || !mounted) return;
    setState(() {
      _lastDay = picked;
      _dateError = null;
      if (!_letterEdited) {
        _settingTemplate = true;
        _letter.text = _template();
        _settingTemplate = false;
      }
    });
  }

  void _submit() {
    final letter = _letter.text.trim();
    setState(() {
      _dateError = _lastDay == null ? 'Select your last working day.' : null;
      _letterError = letter.length < 20
          ? 'Write a short resignation letter.'
          : null;
    });
    if (_dateError != null || _letterError != null) return;
    Navigator.of(
      context,
    ).pop(ResignationDraft(lastWorkingDay: _lastDay!, letter: letter));
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
      backgroundColor: Colors.transparent,
      child: Container(
        width: (width - 36).clamp(300.0, 430.0),
        padding: const EdgeInsets.fromLTRB(22, 20, 22, 20),
        decoration: BoxDecoration(
          color: PortalColors.surface,
          borderRadius: BorderRadius.circular(22),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _header(context),
              const SizedBox(height: 20),
              _label('Last Working Day'),
              const SizedBox(height: 7),
              _dateField(),
              if (_dateError != null) _error(_dateError!),
              if (_lastDay != null && _dateError == null) _noticeChip(),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _label('Resignation Letter')),
                  if (_letterEdited)
                    GestureDetector(
                      onTap: () {
                        _settingTemplate = true;
                        _letter.text = _template();
                        _settingTemplate = false;
                        setState(() => _letterEdited = false);
                      },
                      child: Row(
                        children: [
                          const Icon(
                            Icons.refresh_rounded,
                            size: 13,
                            color: PortalColors.purple,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            'Reset',
                            style: portalText(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: PortalColors.purple,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 7),
              _letterField(),
              if (_letterError != null) _error(_letterError!),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _Button(
                      label: 'Cancel',
                      onTap: () => Navigator.of(context).pop(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _Button(
                      label: 'Submit Resignation',
                      gradient: _redGradient,
                      onTap: _submit,
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

  Widget _header(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: PortalColors.redTint,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.logout_rounded,
            size: 19,
            color: PortalColors.red,
          ),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Submit Resignation',
                style: portalText(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: PortalColors.heading,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Your request will be sent to HR for review.',
                style: portalText(fontSize: 11, color: PortalColors.muted),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          visualDensity: VisualDensity.compact,
          icon: const Icon(Icons.close_rounded),
          color: PortalColors.muted,
        ),
      ],
    );
  }

  Widget _label(String text) {
    return Text.rich(
      TextSpan(
        text: text,
        style: portalText(
          fontSize: 12.5,
          fontWeight: FontWeight.w700,
          color: PortalColors.secondaryText,
        ),
        children: [
          TextSpan(
            text: ' *',
            style: portalText(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: PortalColors.red,
            ),
          ),
        ],
      ),
    );
  }

  Widget _dateField() {
    final hasValue = _lastDay != null;
    return Material(
      color: PortalColors.background,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: _pickDate,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 46,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _dateError != null
                  ? PortalColors.red
                  : PortalColors.border,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: PortalColors.purpleTint,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.calendar_month_rounded,
                  size: 15,
                  color: PortalColors.purple,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  hasValue ? _formatLong(_lastDay!) : 'dd/mm/yyyy',
                  style: portalText(
                    fontSize: 13,
                    fontWeight: hasValue ? FontWeight.w600 : FontWeight.w400,
                    color: hasValue ? PortalColors.heading : PortalColors.muted,
                  ),
                ),
              ),
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: PortalColors.muted,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _noticeChip() {
    final today = DateUtils.dateOnly(DateTime.now());
    final days = _lastDay!.difference(today).inDays;
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: PortalColors.purpleTint,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.hourglass_bottom_rounded,
              size: 12,
              color: PortalColors.purple,
            ),
            const SizedBox(width: 5),
            Text(
              days == 0
                  ? 'Last working day is today'
                  : '$days day${days == 1 ? '' : 's'} from today',
              style: portalText(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                color: PortalColors.purple,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _letterField() {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: _letterError != null ? PortalColors.red : PortalColors.border,
      ),
    );
    return TextField(
      controller: _letter,
      minLines: 8,
      maxLines: 11,
      textCapitalization: TextCapitalization.sentences,
      style: portalText(
        fontSize: 13,
        color: PortalColors.heading,
        height: 1.55,
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: PortalColors.background,
        contentPadding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        border: border,
        enabledBorder: border,
        focusedBorder: border.copyWith(
          borderSide: const BorderSide(color: PortalColors.purple, width: 1.3),
        ),
      ),
    );
  }

  Widget _error(String message) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Text(
        message,
        style: portalText(fontSize: 11, color: PortalColors.red),
      ),
    );
  }

  static String _formatLong(DateTime date) {
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
    final d = date.day.toString().padLeft(2, '0');
    return '$d ${months[date.month - 1]} ${date.year}';
  }
}

class _Button extends StatelessWidget {
  const _Button({required this.label, required this.onTap, this.gradient});

  final String label;
  final VoidCallback onTap;
  final List<Color>? gradient;

  @override
  Widget build(BuildContext context) {
    final filled = gradient != null;
    return Material(
      color: Colors.transparent,
      child: Ink(
        height: 46,
        decoration: BoxDecoration(
          color: filled ? null : const Color(0xFFF1F0F6),
          gradient: filled ? LinearGradient(colors: gradient!) : null,
          borderRadius: BorderRadius.circular(12),
          boxShadow: filled
              ? [
                  BoxShadow(
                    color: gradient!.last.withValues(alpha: 0.28),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  ),
                ]
              : null,
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: portalText(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: filled ? Colors.white : PortalColors.secondaryText,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
