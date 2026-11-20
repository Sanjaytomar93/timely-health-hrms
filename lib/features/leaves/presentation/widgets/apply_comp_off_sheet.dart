import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timelay_health/core/theme/portal_colors.dart';
import 'package:timelay_health/core/theme/portal_text.dart';
import 'package:timelay_health/features/leaves/domain/entities/comp_off_request.dart';
import 'package:timelay_health/features/leaves/domain/failures/leave_failure.dart';
import 'package:timelay_health/features/leaves/presentation/bloc/leaves_cubit.dart';

const _compOffType = 'Comp Off (Compensatory Off)';

Future<bool?> showApplyCompOffSheet(BuildContext context) {
  final cubit = context.read<LeavesCubit>();
  return showDialog<bool>(
    context: context,
    barrierColor: const Color(0x80000000),
    builder: (context) =>
        BlocProvider.value(value: cubit, child: const ApplyCompOffSheet()),
  );
}

class ApplyCompOffSheet extends StatefulWidget {
  const ApplyCompOffSheet({super.key});

  @override
  State<ApplyCompOffSheet> createState() => _ApplyCompOffSheetState();
}

class _ApplyCompOffSheetState extends State<ApplyCompOffSheet> {
  late final TextEditingController _reason;
  late final TextEditingController _days;
  DateTime? _workDate;
  DateTime? _leaveDate;
  ExtraWorkedDay? _selectedDay;
  List<ExtraWorkedDay> _availableDays = const [];
  bool _loadingDays = true;
  bool _submitting = false;
  String? _daysError;
  String? _formMessage;
  bool _formMessageSuccess = false;

  @override
  void initState() {
    super.initState();
    _reason = TextEditingController();
    _days = TextEditingController(text: '1');
    _loadDays();
  }

  @override
  void dispose() {
    _reason.dispose();
    _days.dispose();
    super.dispose();
  }

  Future<void> _loadDays() async {
    setState(() {
      _loadingDays = true;
      _daysError = null;
    });
    try {
      final days = await context.read<LeavesCubit>().loadExtraWorkedDays();
      if (!mounted) return;
      final available = days.where((d) => d.isAvailable).toList();
      setState(() {
        _availableDays = available;
        _loadingDays = false;
        if (_selectedDay != null &&
            !available.any((d) => _sameDay(d.date, _selectedDay!.date))) {
          _selectedDay = null;
          _workDate = null;
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _availableDays = const [];
        _loadingDays = false;
        _daysError = e is LeaveFailure
            ? e.message
            : 'Failed to load extra worked days.';
      });
    }
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  Future<void> _pickDate({required bool isWork}) async {
    final now = DateTime.now();
    final initial = isWork ? (_workDate ?? now) : (_leaveDate ?? now);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 2),
    );
    if (picked == null) return;
    setState(() {
      if (isWork) {
        _workDate = picked;
        _selectedDay = null;
      } else {
        _leaveDate = picked;
      }
    });
  }

  String _dateLabel(DateTime? date) {
    if (date == null) return 'dd/mm/yyyy';
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    return '$d/$m/${date.year}';
  }

  Future<void> _submit() async {
    final work = _workDate;
    final leave = _leaveDate;
    if (work == null) {
      _showMessage('Please select extra work date.');
      return;
    }
    if (leave == null) {
      _showMessage('Please select date to take leave.');
      return;
    }
    final days = int.tryParse(_days.text.trim()) ?? 0;
    if (days <= 0) {
      _showMessage('Please enter valid total days.');
      return;
    }
    if (_reason.text.trim().isEmpty) {
      _showMessage('Please enter reason.');
      return;
    }

    setState(() {
      _submitting = true;
      _formMessage = null;
    });
    try {
      await context.read<LeavesCubit>().applyCompOff(
        workDate: work,
        leaveDate: leave,
        days: days,
        reason: _reason.text,
        workType: _selectedDay?.workType,
        totalHours: _selectedDay?.totalHours,
      );
      if (!mounted) return;
      _showMessage('Comp-off submitted successfully', success: true);
      await Future<void>.delayed(const Duration(milliseconds: 700));
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      _showMessage(
        e is LeaveFailure ? e.message : 'Failed to submit comp-off.',
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _showMessage(String message, {bool success = false}) {
    setState(() {
      _formMessage = message;
      _formMessageSuccess = success;
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final dialogWidth = (width - 28).clamp(320.0, 430.0);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Container(
        width: dialogWidth,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.92,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: const [
            BoxShadow(
              color: Color(0x33000000),
              blurRadius: 28,
              offset: Offset(0, 14),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _Header(
              onClose: _submitting
                  ? null
                  : () => Navigator.of(context).pop(false),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _FieldLabel('Leave Type'),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 11,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [PortalColors.background, PortalColors.brandTint],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: PortalColors.border),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.swap_horiz_rounded,
                              size: 16,
                              color: PortalColors.brand,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _compOffType,
                              style: portalText(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
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
                              color: PortalColors.brand,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Selected',
                              style: portalText(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    const _InfoBanner(),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Container(
                          width: 3,
                          height: 14,
                          decoration: BoxDecoration(
                            color: PortalColors.brand,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'SELECT EXTRA WORKED DAY',
                          style: portalText(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            color: PortalColors.brand,
                            letterSpacing: 0.4,
                          ),
                        ),
                        const Spacer(),
                        InkWell(
                          onTap: _submitting || _loadingDays ? null : _loadDays,
                          borderRadius: BorderRadius.circular(8),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 4,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.refresh_rounded,
                                  size: 15,
                                  color: _loadingDays
                                      ? PortalColors.muted
                                      : PortalColors.brand,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Refresh',
                                  style: portalText(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: _loadingDays
                                        ? PortalColors.muted
                                        : PortalColors.brand,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    if (_loadingDays)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 18),
                        child: Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.4,
                              color: PortalColors.brand,
                            ),
                          ),
                        ),
                      )
                    else if (_daysError != null)
                      _NoticeBox(
                        background: PortalColors.redTint,
                        border: const Color(0xFFF3C4C1),
                        textColor: PortalColors.red,
                        icon: Icons.error_outline_rounded,
                        text: _daysError!,
                      )
                    else if (_availableDays.isEmpty)
                      const _NoticeBox(
                        background: PortalColors.orangeTint,
                        border: Color(0xFFF5D9A8),
                        textColor: PortalColors.orange,
                        icon: Icons.warning_amber_rounded,
                        text:
                            'No automated week-off or holiday work detected in recent attendance. You can manually enter the extra day worked below:',
                      )
                    else
                      Column(
                        children: [
                          for (final day in _availableDays) ...[
                            _ExtraDayTile(
                              day: day,
                              selected: _selectedDay != null &&
                                  _sameDay(_selectedDay!.date, day.date),
                              onTap: _submitting
                                  ? null
                                  : () => setState(() {
                                        _selectedDay = day;
                                        _workDate = day.date;
                                      }),
                            ),
                            const SizedBox(height: 8),
                          ],
                        ],
                      ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: _DateField(
                            label: 'Extra Work Date',
                            value: _dateLabel(_workDate),
                            filled: _workDate != null,
                            onTap: _submitting
                                ? null
                                : () => _pickDate(isWork: true),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _DateField(
                            label: 'Date to take Leave',
                            value: _dateLabel(_leaveDate),
                            filled: _leaveDate != null,
                            onTap: _submitting
                                ? null
                                : () => _pickDate(isWork: false),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    const _FieldLabel('Total Days'),
                    const SizedBox(height: 8),
                    _InputBox(
                      child: TextField(
                        controller: _days,
                        enabled: !_submitting,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        style: portalText(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: PortalColors.heading,
                        ),
                        decoration: const InputDecoration(
                          isDense: true,
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    const _FieldLabel('Reason'),
                    const SizedBox(height: 8),
                    Container(
                      height: 96,
                      decoration: BoxDecoration(
                        color: PortalColors.background,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: PortalColors.border),
                      ),
                      child: TextField(
                        controller: _reason,
                        enabled: !_submitting,
                        maxLines: null,
                        expands: true,
                        textAlignVertical: TextAlignVertical.top,
                        style: portalText(
                          fontSize: 12,
                          color: PortalColors.heading,
                        ),
                        decoration: InputDecoration(
                          hintText:
                              'Reason for comp-off (e.g. Worked extra on Sunday)...',
                          hintStyle: portalText(
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                            color: PortalColors.muted,
                          ),
                          contentPadding: const EdgeInsets.all(12),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    if (_formMessage != null) ...[
                      const SizedBox(height: 12),
                      _NoticeBox(
                        background: _formMessageSuccess
                            ? PortalColors.greenTint
                            : PortalColors.redTint,
                        border: _formMessageSuccess
                            ? const Color(0xFFB8E6D4)
                            : const Color(0xFFF3C4C1),
                        textColor: _formMessageSuccess
                            ? PortalColors.green
                            : PortalColors.red,
                        icon: _formMessageSuccess
                            ? Icons.check_circle_outline_rounded
                            : Icons.error_outline_rounded,
                        text: _formMessage!,
                      ),
                    ],
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 16),
              decoration: const BoxDecoration(
                color: PortalColors.background,
                border: Border(
                  top: BorderSide(color: PortalColors.border),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _ActionButton(
                      label: 'Cancel',
                      filled: false,
                      onTap: _submitting
                          ? null
                          : () => Navigator.of(context).pop(false),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 1,
                    child: _ActionButton(
                      label: 'Submit Comp-Off',
                      filled: true,
                      loading: _submitting,
                      onTap: _submitting ? null : _submit,
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

class _Header extends StatelessWidget {
  const _Header({required this.onClose});

  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 16, 14, 16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: PortalColors.brandGradient,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
            ),
            child: const Icon(
              Icons.event_available_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Apply for Comp-Off',
                  style: portalText(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Claim leave for week-off or holiday work',
                  style: portalText(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.86),
                  ),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: onClose,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.16),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close_rounded, size: 18, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  const _InfoBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 11, 12, 11),
      decoration: BoxDecoration(
        color: PortalColors.brandTint,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: PortalColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(7),
            ),
            child: const Icon(
              Icons.info_rounded,
              size: 14,
              color: PortalColors.brand,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text.rich(
              TextSpan(
                style: portalText(
                  fontSize: 10.5,
                  height: 1.35,
                  color: PortalColors.secondaryText,
                ),
                children: const [
                  TextSpan(
                    text: 'Validity Rule: ',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  TextSpan(
                    text:
                        'Extra work in any month is valid until the ',
                  ),
                  TextSpan(
                    text: '15th of next month',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  TextSpan(
                    text: ' (e.g. Sep work till ',
                  ),
                  TextSpan(
                    text: '15 Oct',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  TextSpan(text: '). Expired days cannot be claimed.'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExtraDayTile extends StatelessWidget {
  const _ExtraDayTile({
    required this.day,
    required this.selected,
    required this.onTap,
  });

  final ExtraWorkedDay day;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? PortalColors.brandTint : PortalColors.background,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(12, 11, 12, 11),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? PortalColors.brand : PortalColors.border,
              width: selected ? 1.4 : 1,
            ),
            boxShadow: selected
                ? const [
                    BoxShadow(
                      color: Color(0x2226204A),
                      blurRadius: 10,
                      offset: Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: selected ? PortalColors.brand : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: selected ? PortalColors.brand : PortalColors.border,
                  ),
                ),
                child: Icon(
                  selected
                      ? Icons.check_rounded
                      : Icons.calendar_month_rounded,
                  size: 17,
                  color: selected ? Colors.white : PortalColors.muted,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      day.dayLabel.isEmpty
                          ? '${day.date.day}/${day.date.month}/${day.date.year}'
                          : day.dayLabel,
                      style: portalText(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: PortalColors.heading,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      [
                        day.workType,
                        if (day.validTillFormatted != null)
                          'Valid till ${day.validTillFormatted}',
                      ].where((e) => e.trim().isNotEmpty).join(' · '),
                      style: portalText(
                        fontSize: 10,
                        color: PortalColors.muted,
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
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.value,
    required this.filled,
    required this.onTap,
  });

  final String label;
  final String value;
  final bool filled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel(label),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: _InputBox(
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: portalText(
                      fontSize: 11.5,
                      fontWeight: filled ? FontWeight.w600 : FontWeight.w400,
                      color: filled
                          ? PortalColors.heading
                          : PortalColors.muted,
                    ),
                  ),
                ),
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 15,
                  color: PortalColors.brand,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _NoticeBox extends StatelessWidget {
  const _NoticeBox({
    required this.background,
    required this.border,
    required this.textColor,
    required this.text,
    this.icon,
  });

  final Color background;
  final Color border;
  final Color textColor;
  final String text;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: textColor),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Text(
              text,
              style: portalText(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                height: 1.35,
                color: textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: portalText(
        fontSize: 10.5,
        fontWeight: FontWeight.w600,
        color: PortalColors.secondaryText,
      ),
    );
  }
}

class _InputBox extends StatelessWidget {
  const _InputBox({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        color: PortalColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: PortalColors.border),
      ),
      child: child,
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.filled,
    required this.onTap,
    this.loading = false,
  });

  final String label;
  final bool filled;
  final VoidCallback? onTap;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          height: 44,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: filled
                ? const LinearGradient(
                    colors: PortalColors.brandGradient,
                  )
                : null,
            color: filled ? null : PortalColors.brandTint,
            boxShadow: filled
                ? const [
                    BoxShadow(
                      color: Color(0x3326204A),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: loading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    label,
                    style: portalText(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: filled ? Colors.white : PortalColors.heading,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
