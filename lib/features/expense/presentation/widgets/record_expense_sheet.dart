import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timelay_health/core/theme/portal_colors.dart';
import 'package:timelay_health/core/theme/portal_text.dart';
import 'package:timelay_health/features/expense/domain/entities/add_expense_params.dart';
import 'package:timelay_health/features/expense/presentation/bloc/record_expense_cubit.dart';

Future<bool?> showRecordExpenseSheet(BuildContext context) {
  return showDialog<bool>(
    context: context,
    barrierColor: const Color(0x70000000),
    builder: (context) => BlocProvider(
      create: (_) => RecordExpenseCubit(),
      child: const RecordExpenseSheet(),
    ),
  );
}

class RecordExpenseSheet extends StatefulWidget {
  const RecordExpenseSheet({super.key});

  @override
  State<RecordExpenseSheet> createState() => _RecordExpenseSheetState();
}

class _StopControllers {
  _StopControllers()
    : location = TextEditingController(),
      outcome = TextEditingController(),
      km = TextEditingController(),
      orderValue = TextEditingController(),
      upsellValue = TextEditingController();

  final TextEditingController location;
  final TextEditingController outcome;
  final TextEditingController km;
  final TextEditingController orderValue;
  final TextEditingController upsellValue;

  void dispose() {
    location.dispose();
    outcome.dispose();
    km.dispose();
    orderValue.dispose();
    upsellValue.dispose();
  }
}

class _RecordExpenseSheetState extends State<RecordExpenseSheet> {
  final _purposeController = TextEditingController();
  final _remarkController = TextEditingController();
  final _stops = <_StopControllers>[_StopControllers()];
  DateTime? _travelDate;

  @override
  void initState() {
    super.initState();
    for (final stop in _stops) {
      stop.km.addListener(_onKmChanged);
    }
  }

  @override
  void dispose() {
    _purposeController.dispose();
    _remarkController.dispose();
    for (final stop in _stops) {
      stop.km.removeListener(_onKmChanged);
      stop.dispose();
    }
    super.dispose();
  }

  void _onKmChanged() => setState(() {});

  double get _totalKm {
    var total = 0.0;
    for (final stop in _stops) {
      total += double.tryParse(stop.km.text.trim()) ?? 0;
    }
    return total;
  }

  double get _estimatedAmount => _totalKm * RecordExpenseCubit.ratePerKm;

  String get _dateLabel {
    final d = _travelDate;
    if (d == null) return '';
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
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _travelDate ?? now,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 1),
    );
    if (picked != null) {
      setState(() => _travelDate = picked);
    }
  }

  void _addStop() {
    final stop = _StopControllers();
    stop.km.addListener(_onKmChanged);
    setState(() => _stops.add(stop));
  }

  void _removeStop(int index) {
    if (_stops.length <= 1) return;
    final stop = _stops.removeAt(index);
    stop.km.removeListener(_onKmChanged);
    stop.dispose();
    setState(() {});
  }

  void _submit() {
    final stops = _stops
        .map(
          (s) => AddExpenseStopInput(
            locationName: s.location.text.trim(),
            outcome: s.outcome.text.trim(),
            orderValue: double.tryParse(s.orderValue.text.trim()) ?? 0,
            upsellValue: double.tryParse(s.upsellValue.text.trim()) ?? 0,
            km: double.tryParse(s.km.text.trim()) ?? 0,
          ),
        )
        .toList();

    context.read<RecordExpenseCubit>().submit(
      purpose: _purposeController.text,
      date: _travelDate,
      remark: _remarkController.text,
      stops: stops,
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final dialogWidth = (size.width - 35).clamp(300.0, 405.0);
    final maxHeight = size.height * 0.88;
    final submitting =
        context.watch<RecordExpenseCubit>().state is RecordExpenseSubmitting;

    return BlocListener<RecordExpenseCubit, RecordExpenseState>(
      listener: (context, state) {
        if (state is RecordExpenseSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              behavior: SnackBarBehavior.floating,
            ),
          );
          Navigator.of(context).pop(true);
        } else if (state is RecordExpenseFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 28),
        child: Container(
          width: dialogWidth,
          constraints: BoxConstraints(maxHeight: maxHeight),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(22, 20, 18, 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Record Expense',
                            style: portalText(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: PortalColors.heading,
                              height: 16 / 13.5,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Add trip purpose, stops, and reimbursable distance.',
                            style: portalText(
                              fontSize: 10.5,
                              color: PortalColors.muted,
                              height: 13 / 10.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: submitting
                          ? null
                          : () => Navigator.of(context).pop(false),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        width: 45,
                        height: 42,
                        decoration: BoxDecoration(
                          color: PortalColors.border,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.close, size: 20),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const _Label('Purpose of Travel'),
                const SizedBox(height: 8),
                _InputField(
                  controller: _purposeController,
                  hint: 'e.g. Client meeting or sample collection',
                  enabled: !submitting,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _Label('Travel Date'),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: submitting ? null : _pickDate,
                            child: _ReadOnlyBox(
                              text: _dateLabel.isEmpty
                                  ? 'Select Date'
                                  : _dateLabel,
                              isHint: _dateLabel.isEmpty,
                              centered: true,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _Label('Total KM Traveled'),
                          const SizedBox(height: 8),
                          _ReadOnlyBox(
                            text:
                                '${_totalKm.toStringAsFixed(_totalKm % 1 == 0 ? 0 : 1)} KM',
                            bold: true,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const _Label('Estimated reimbursement'),
                const SizedBox(height: 8),
                _ReadOnlyBox(
                  text: '₹ ${_estimatedAmount.toStringAsFixed(0)}',
                  bold: true,
                ),
                const SizedBox(height: 16),
                const _Label('Rate applied'),
                const SizedBox(height: 8),
                const _ReadOnlyBox(text: '₹ 4 / KM', bold: true),
                const SizedBox(height: 18),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(14, 12, 12, 14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: PortalColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Stops / Samples',
                              style: portalText(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: PortalColors.heading,
                                height: 13 / 11,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: submitting ? null : _addStop,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: PortalColors.purple,
                                borderRadius: BorderRadius.circular(11),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.add,
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Add Stop',
                                    style: portalText(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                      height: 1.2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Add each visit so the record matches your travel route',
                        style: portalText(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: PortalColors.muted,
                          height: 1.2,
                        ),
                      ),
                      for (var i = 0; i < _stops.length; i++) ...[
                        const SizedBox(height: 12),
                        _StopCard(
                          index: i,
                          controllers: _stops[i],
                          canRemove: _stops.length > 1 && !submitting,
                          enabled: !submitting,
                          onRemove: () => _removeStop(i),
                        ),
                      ],
                      const SizedBox(height: 14),
                      const _StopLabel('Remark'),
                      const SizedBox(height: 8),
                      _InputField(
                        controller: _remarkController,
                        height: 105,
                        maxLines: 4,
                        enabled: !submitting,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      flex: 5,
                      child: GestureDetector(
                        onTap: submitting
                            ? null
                            : () => Navigator.of(context).pop(false),
                        child: Container(
                          height: 32,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: PortalColors.muted,
                              width: 0.5,
                            ),
                          ),
                          child: Text(
                            'Cancel',
                            style: portalText(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: PortalColors.heading,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 25),
                    Expanded(
                      flex: 6,
                      child: GestureDetector(
                        onTap: submitting ? null : _submit,
                        child: Container(
                          height: 32,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: PortalColors.brand,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: PortalColors.brand,
                              width: 0.5,
                            ),
                          ),
                          child: submitting
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  'Submit Record',
                                  style: portalText(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
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
      ),
    );
  }
}

class _StopCard extends StatelessWidget {
  const _StopCard({
    required this.index,
    required this.controllers,
    required this.canRemove,
    required this.enabled,
    required this.onRemove,
  });

  final int index;
  final _StopControllers controllers;
  final bool canRemove;
  final bool enabled;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: PortalColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Stop ${index + 1}',
                  style: portalText(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: PortalColors.heading,
                  ),
                ),
              ),
              if (canRemove)
                GestureDetector(
                  onTap: onRemove,
                  child: Text(
                    'Remove',
                    style: portalText(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: PortalColors.purple,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          const _StopLabel('Location / Sample Name'),
          const SizedBox(height: 8),
          _InputField(controller: controllers.location, enabled: enabled),
          const SizedBox(height: 14),
          const _StopLabel('Meeting Outcome'),
          const SizedBox(height: 8),
          _InputField(controller: controllers.outcome, enabled: enabled),
          const SizedBox(height: 14),
          const _StopLabel('Distance (KM)'),
          const SizedBox(height: 8),
          _InputField(
            controller: controllers.km,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
            ],
            enabled: enabled,
          ),
          const SizedBox(height: 14),
          const _StopLabel('Order Value (₹)'),
          const SizedBox(height: 8),
          _InputField(
            controller: controllers.orderValue,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
            ],
            enabled: enabled,
          ),
          const SizedBox(height: 14),
          const _StopLabel('Upsell Value (₹)'),
          const SizedBox(height: 8),
          _InputField(
            controller: controllers.upsellValue,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
            ],
            enabled: enabled,
          ),
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
    return Text(
      text,
      style: portalText(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: PortalColors.muted,
        height: 12 / 10,
      ),
    );
  }
}

class _StopLabel extends StatelessWidget {
  const _StopLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: portalText(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        color: PortalColors.muted,
        height: 12 / 10,
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  const _InputField({
    required this.controller,
    this.hint,
    this.height = 40,
    this.maxLines = 1,
    this.keyboardType,
    this.inputFormatters,
    this.enabled = true,
  });

  final TextEditingController controller;
  final String? hint;
  final double height;
  final int maxLines;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: maxLines > 1 ? height : height,
      padding: const EdgeInsets.symmetric(horizontal: 15),
      alignment: maxLines > 1 ? Alignment.topLeft : Alignment.centerLeft,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: PortalColors.border),
      ),
      child: TextField(
        controller: controller,
        enabled: enabled,
        maxLines: maxLines,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        style: portalText(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: PortalColors.heading,
        ),
        decoration: InputDecoration(
          isDense: true,
          border: InputBorder.none,
          hintText: hint,
          hintStyle: portalText(
            fontSize: 8,
            fontWeight: FontWeight.w300,
            color: const Color(0xFF7E7E7E),
          ),
        ),
      ),
    );
  }
}

class _ReadOnlyBox extends StatelessWidget {
  const _ReadOnlyBox({
    required this.text,
    this.bold = false,
    this.isHint = false,
    this.centered = false,
  });

  final String text;
  final bool bold;
  final bool isHint;
  final bool centered;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 15),
      alignment: centered ? Alignment.center : Alignment.centerLeft,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: PortalColors.border),
      ),
      child: Text(
        text,
        style: portalText(
          fontSize: isHint ? 8 : (bold ? 11 : 10),
          fontWeight: isHint
              ? FontWeight.w300
              : (bold ? FontWeight.w700 : FontWeight.w500),
          color: isHint ? const Color(0xFF7E7E7E) : PortalColors.heading,
        ),
      ),
    );
  }
}
