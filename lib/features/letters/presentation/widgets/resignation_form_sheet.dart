import 'package:flutter/material.dart';
import 'package:timelay_health/core/theme/portal_colors.dart';
import 'package:timelay_health/core/theme/portal_text.dart';
import 'package:timelay_health/features/letters/data/datasources/letter_remote_datasource.dart';
import 'package:timelay_health/features/letters/domain/failures/letter_failure.dart';

const resignationAccent = PortalColors.brand;

/// Returns `true` when the resignation was submitted.
Future<bool> showResignationFormSheet(
  BuildContext context, {
  required String employeeId,
}) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _ResignationFormSheet(employeeId: employeeId),
  );
  return result ?? false;
}

class _ResignationFormSheet extends StatefulWidget {
  const _ResignationFormSheet({required this.employeeId});

  final String employeeId;

  @override
  State<_ResignationFormSheet> createState() => _ResignationFormSheetState();
}

class _ResignationFormSheetState extends State<_ResignationFormSheet> {
  static const _noticeOptions = [0, 15, 30, 45, 60, 90];
  static const _categories = [
    'Better Opportunity',
    'Personal Reasons',
    'Higher Studies',
    'Health Issues',
    'Relocation',
    'Work Environment',
    'Compensation',
    'Other',
  ];

  final _reason = TextEditingController();
  final _comments = TextEditingController();
  late DateTime _resignationDate = DateUtils.dateOnly(DateTime.now());
  late DateTime _lastWorkingDate = _resignationDate.add(
    const Duration(days: 30),
  );
  int _noticeDays = 30;
  String _category = _categories.first;
  String? _reasonError;
  bool _submitting = false;

  @override
  void dispose() {
    _reason.dispose();
    _comments.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool lastDay}) async {
    final initial = lastDay ? _lastWorkingDate : _resignationDate;
    final first = lastDay
        ? _resignationDate
        : DateUtils.dateOnly(DateTime.now()).subtract(const Duration(days: 30));
    final picked = await showDatePicker(
      context: context,
      initialDate: initial.isBefore(first) ? first : initial,
      firstDate: first,
      lastDate: DateTime.now().add(const Duration(days: 400)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(
            context,
          ).colorScheme.copyWith(primary: resignationAccent),
        ),
        child: child!,
      ),
    );
    if (picked == null || !mounted) return;
    setState(() {
      if (lastDay) {
        _lastWorkingDate = picked;
      } else {
        _resignationDate = picked;
        _lastWorkingDate = picked.add(Duration(days: _noticeDays));
      }
    });
  }

  void _setNotice(int days) {
    setState(() {
      _noticeDays = days;
      _lastWorkingDate = _resignationDate.add(Duration(days: days));
    });
  }

  Future<void> _submit() async {
    final reason = _reason.text.trim();
    if (reason.isEmpty) {
      setState(() => _reasonError = 'Please explain why you are resigning.');
      return;
    }
    setState(() {
      _reasonError = null;
      _submitting = true;
    });
    try {
      await LetterRemoteDataSource().submitResignation({
        'employeeId': widget.employeeId,
        'resignationDate': _apiDate(_resignationDate),
        'lastWorkingDate': _apiDate(_lastWorkingDate),
        'noticePeriodDays': _noticeDays,
        'reasonCategory': _category,
        'reason': reason,
        'comments': _comments.text.trim(),
      });
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } on LetterFailure catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), behavior: SnackBarBehavior.floating),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.92,
        ),
        decoration: const BoxDecoration(
          color: PortalColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: PortalColors.border,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              _header(),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _field(
                              'Resignation Date',
                              required: true,
                              child: _dateBox(
                                _resignationDate,
                                () => _pickDate(lastDay: false),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _field(
                              'Last Working Date',
                              required: true,
                              child: _dateBox(
                                _lastWorkingDate,
                                () => _pickDate(lastDay: true),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _field(
                        'Notice Period',
                        child: _dropdown<int>(
                          value: _noticeDays,
                          icon: Icons.timelapse_rounded,
                          items: {
                            for (final d in _noticeOptions)
                              d: d == 0 ? 'Immediate' : '$d Days',
                          },
                          onChanged: _setNotice,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _field(
                        'Reason Category',
                        child: _dropdown<String>(
                          value: _category,
                          icon: Icons.local_offer_outlined,
                          items: {for (final c in _categories) c: c},
                          onChanged: (c) => setState(() => _category = c),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _field(
                        'Reason',
                        required: true,
                        child: _textBox(
                          _reason,
                          hint: 'Explain why you are resigning...',
                          minLines: 3,
                          error: _reasonError,
                          onChanged: (_) {
                            if (_reasonError != null) {
                              setState(() => _reasonError = null);
                            }
                          },
                        ),
                      ),
                      if (_reasonError != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            _reasonError!,
                            style: portalText(
                              fontSize: 11,
                              color: PortalColors.red,
                            ),
                          ),
                        ),
                      const SizedBox(height: 16),
                      _field(
                        'Additional Comments',
                        child: _textBox(
                          _comments,
                          hint: 'Optional...',
                          minLines: 2,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _notice(),
                    ],
                  ),
                ),
              ),
              _actions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 12, 12),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [PortalColors.brandLight, resignationAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: resignationAccent.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: const Icon(
              Icons.send_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Submit Resignation',
                  style: portalText(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: PortalColors.heading,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Fill in the details for HR review',
                  style: portalText(fontSize: 11, color: PortalColors.muted),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _submitting ? null : () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close_rounded),
            color: PortalColors.muted,
          ),
        ],
      ),
    );
  }

  Widget _field(String label, {required Widget child, bool required = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            text: label,
            style: portalText(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: PortalColors.secondaryText,
            ),
            children: [
              if (required)
                TextSpan(
                  text: ' *',
                  style: portalText(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: PortalColors.red,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  Widget _dateBox(DateTime date, VoidCallback onTap) {
    return Material(
      color: PortalColors.background,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: PortalColors.border),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.calendar_month_rounded,
                size: 17,
                color: resignationAccent,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _displayDate(date),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: portalText(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: PortalColors.heading,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dropdown<T>({
    required T value,
    required IconData icon,
    required Map<T, String> items,
    required ValueChanged<T> onChanged,
  }) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: PortalColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: PortalColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, size: 17, color: resignationAccent),
          const SizedBox(width: 8),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<T>(
                value: value,
                isExpanded: true,
                borderRadius: BorderRadius.circular(12),
                dropdownColor: PortalColors.surface,
                icon: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: PortalColors.muted,
                ),
                style: portalText(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: PortalColors.heading,
                ),
                items: [
                  for (final e in items.entries)
                    DropdownMenuItem<T>(value: e.key, child: Text(e.value)),
                ],
                onChanged: (v) {
                  if (v != null) onChanged(v);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _textBox(
    TextEditingController controller, {
    required String hint,
    required int minLines,
    String? error,
    ValueChanged<String>? onChanged,
  }) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: error != null ? PortalColors.red : PortalColors.border,
      ),
    );
    return TextField(
      controller: controller,
      minLines: minLines,
      maxLines: minLines + 3,
      onChanged: onChanged,
      textCapitalization: TextCapitalization.sentences,
      style: portalText(fontSize: 13, color: PortalColors.heading, height: 1.5),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: portalText(fontSize: 12.5, color: PortalColors.muted),
        filled: true,
        fillColor: PortalColors.background,
        contentPadding: const EdgeInsets.all(14),
        border: border,
        enabledBorder: border,
        focusedBorder: border.copyWith(
          borderSide: const BorderSide(color: resignationAccent, width: 1.4),
        ),
      ),
    );
  }

  Widget _notice() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF5DFA6)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            size: 18,
            color: PortalColors.orange,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text.rich(
              TextSpan(
                style: portalText(
                  fontSize: 11.5,
                  color: const Color(0xFFB45309),
                  height: 1.45,
                ),
                children: [
                  const TextSpan(
                    text:
                        'Once submitted, HR/Admin will review. You can withdraw while it is ',
                  ),
                  TextSpan(
                    text: 'pending',
                    style: portalText(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFFB45309),
                    ),
                  ),
                  const TextSpan(text: '.'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actions() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: PortalColors.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _submitting ? null : () => Navigator.of(context).pop(),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                side: const BorderSide(color: PortalColors.border),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Cancel',
                style: portalText(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: PortalColors.secondaryText,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: FilledButton.icon(
              onPressed: _submitting ? null : _submit,
              style: FilledButton.styleFrom(
                backgroundColor: resignationAccent,
                disabledBackgroundColor: resignationAccent.withValues(
                  alpha: 0.6,
                ),
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: _submitting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.send_rounded, size: 17),
              label: Text(
                _submitting ? 'Submitting...' : 'Submit',
                style: portalText(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _apiDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  static String _displayDate(DateTime d) {
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
    return '${d.day.toString().padLeft(2, '0')} ${months[d.month - 1]} ${d.year}';
  }
}
