import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timelay_health/core/theme/portal_colors.dart';
import 'package:timelay_health/core/theme/portal_text.dart';
import 'package:timelay_health/features/leaves/domain/failures/leave_failure.dart';
import 'package:timelay_health/features/leaves/presentation/bloc/leaves_cubit.dart';
import 'package:timelay_health/features/leaves/presentation/widgets/apply_comp_off_sheet.dart';

Future<bool?> showApplyLeaveSheet(BuildContext context) async {
  final cubit = context.read<LeavesCubit>();
  final result = await showDialog<Object?>(
    context: context,
    barrierColor: const Color(0x70000000),
    builder: (context) =>
        BlocProvider.value(value: cubit, child: const ApplyLeaveSheet()),
  );
  if (result == 'comp-off') {
    if (!context.mounted) return null;
    return showApplyCompOffSheet(context);
  }
  return result is bool ? result : null;
}

class ApplyLeaveSheet extends StatefulWidget {
  const ApplyLeaveSheet({super.key});

  @override
  State<ApplyLeaveSheet> createState() => _ApplyLeaveSheetState();
}

class _ApplyLeaveSheetState extends State<ApplyLeaveSheet> {
  static const _leaveTypes = [
    'Casual Leave',
    'Sick Leave',
    'Earned Leave',
    'Comp Off (Compensatory Off)',
  ];
  static const _compOffType = 'Comp Off (Compensatory Off)';

  late final TextEditingController _reason;
  String _leaveType = 'Sick Leave';
  DateTime? _startDate;
  DateTime? _endDate;
  bool _submitting = false;

  void _onLeaveTypeSelected(String value) {
    if (value == _compOffType) {
      Navigator.of(context).pop('comp-off');
      return;
    }
    setState(() => _leaveType = value);
  }

  @override
  void initState() {
    super.initState();
    _reason = TextEditingController();
  }

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  int get _days {
    if (_startDate == null || _endDate == null) return 0;
    final start = DateTime(
      _startDate!.year,
      _startDate!.month,
      _startDate!.day,
    );
    final end = DateTime(_endDate!.year, _endDate!.month, _endDate!.day);
    if (end.isBefore(start)) return 0;
    return end.difference(start).inDays + 1;
  }

  Future<void> _pickDate({required bool isStart}) async {
    final now = DateTime.now();
    final initial = isStart
        ? (_startDate ?? now)
        : (_endDate ?? _startDate ?? now);
    final firstDate = isStart
        ? DateTime(now.year - 1)
        : (_startDate ?? DateTime(now.year - 1));
    final picked = await showDatePicker(
      context: context,
      initialDate: initial.isBefore(firstDate) ? firstDate : initial,
      firstDate: firstDate,
      lastDate: DateTime(now.year + 2),
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _startDate = picked;
        if (_endDate != null && _endDate!.isBefore(picked)) {
          _endDate = picked;
        }
      } else {
        _endDate = picked;
      }
    });
  }

  Future<void> _submit() async {
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select start and end date.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      await context.read<LeavesCubit>().applyLeave(
        leaveType: _leaveType,
        startDate: _startDate!,
        endDate: _endDate!,
        reason: _reason.text,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Leave added successfully'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e is LeaveFailure ? e.message : 'Failed to apply leave.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  String _dateLabel(DateTime? date) {
    if (date == null) return 'Select Date';
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    return '$d/$m/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final dialogWidth = (width - 35).clamp(300.0, 405.0);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
      child: Container(
        width: dialogWidth,
        constraints: const BoxConstraints(maxHeight: 645),
        padding: const EdgeInsets.fromLTRB(22, 20, 18, 22),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Text(
                    'Apply Leave',
                    style: portalText(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: PortalColors.heading,
                    ),
                  ),
                  const Spacer(),
                  InkWell(
                    onTap: _submitting
                        ? null
                        : () => Navigator.of(context).pop(false),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      width: 45,
                      height: 42,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE9E7F2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.close, size: 20),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              const _FieldLabel('Leave Type'),
              const SizedBox(height: 8),
              PopupMenuButton<String>(
                enabled: !_submitting,
                onSelected: _onLeaveTypeSelected,
                offset: const Offset(0, 42),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                itemBuilder: (_) => [
                  for (final t in _leaveTypes)
                    PopupMenuItem(
                      value: t,
                      child: Text(
                        t,
                        style: portalText(
                          fontSize: 12,
                          color: PortalColors.heading,
                        ),
                      ),
                    ),
                ],
                child: _InputBox(
                  height: 40,
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _leaveType,
                          style: portalText(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: PortalColors.heading,
                          ),
                        ),
                      ),
                      const Icon(Icons.keyboard_arrow_down, size: 18),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _FieldLabel('Start Date'),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: _submitting
                              ? null
                              : () => _pickDate(isStart: true),
                          child: _InputBox(
                            height: 40,
                            child: Text(
                              _dateLabel(_startDate),
                              style: portalText(
                                fontSize: 11,
                                fontWeight: _startDate == null
                                    ? FontWeight.w300
                                    : FontWeight.w500,
                                color: _startDate == null
                                    ? const Color(0xFF7E7E7E)
                                    : PortalColors.heading,
                              ),
                            ),
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
                        const _FieldLabel('End Date'),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: _submitting
                              ? null
                              : () => _pickDate(isStart: false),
                          child: _InputBox(
                            height: 40,
                            child: Text(
                              _dateLabel(_endDate),
                              style: portalText(
                                fontSize: 11,
                                fontWeight: _endDate == null
                                    ? FontWeight.w300
                                    : FontWeight.w500,
                                color: _endDate == null
                                    ? const Color(0xFF7E7E7E)
                                    : PortalColors.heading,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const _FieldLabel('Total Days'),
              const SizedBox(height: 8),
              _InputBox(
                height: 40,
                child: Text(
                  '$_days',
                  style: portalText(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF000000),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const _FieldLabel('Reason'),
              const SizedBox(height: 8),
              SizedBox(
                height: 124,
                child: TextField(
                  controller: _reason,
                  enabled: !_submitting,
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  style: portalText(fontSize: 12, color: PortalColors.heading),
                  decoration: InputDecoration(
                    hintText: 'Enter Reason',
                    hintStyle: portalText(
                      fontSize: 10,
                      fontWeight: FontWeight.w300,
                      color: const Color(0xFF000000),
                    ),
                    contentPadding: const EdgeInsets.all(15),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: PortalColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: PortalColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: PortalColors.purple),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _ActionButton(
                    label: 'Cancel',
                    width: 125,
                    background: const Color(0xFFF3F4F6),
                    foreground: const Color(0xFF000000),
                    onTap: _submitting
                        ? null
                        : () => Navigator.of(context).pop(false),
                  ),
                  const SizedBox(width: 25),
                  _ActionButton(
                    label: 'Apply Leave',
                    width: 150,
                    background: PortalColors.brand,
                    foreground: Colors.white,
                    loading: _submitting,
                    onTap: _submitting ? null : _submit,
                  ),
                ],
              ),
            ],
          ),
        ),
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
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: PortalColors.muted,
      ),
    );
  }
}

class _InputBox extends StatelessWidget {
  const _InputBox({required this.height, required this.child});

  final double height;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: PortalColors.border),
      ),
      child: child,
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.width,
    required this.background,
    required this.foreground,
    required this.onTap,
    this.loading = false,
  });

  final String label;
  final double width;
  final Color background;
  final Color foreground;
  final VoidCallback? onTap;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: width,
          height: 32,
          child: Center(
            child: loading
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: foreground,
                    ),
                  )
                : Text(
                    label,
                    style: portalText(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: foreground,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
