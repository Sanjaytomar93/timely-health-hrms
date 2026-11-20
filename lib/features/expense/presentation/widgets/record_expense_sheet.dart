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
        insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
        child: Container(
          width: dialogWidth,
          constraints: BoxConstraints(maxHeight: maxHeight),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 12, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Record Expense',
                            style: portalText(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w800,
                              color: PortalColors.heading,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Add purpose, stops, and distance.',
                            style: portalText(
                              fontSize: 10,
                              color: PortalColors.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: submitting
                          ? null
                          : () => Navigator.of(context).pop(false),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: PortalColors.background,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: PortalColors.border),
                        ),
                        child: const Icon(Icons.close, size: 16),
                      ),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _Label('Purpose of Travel'),
                      const SizedBox(height: 5),
                      _InputField(
                        controller: _purposeController,
                        hint: 'e.g. Client meeting or sample collection',
                        enabled: !submitting,
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const _Label('Travel Date'),
                                const SizedBox(height: 5),
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
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const _Label('Total KM'),
                                const SizedBox(height: 5),
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
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const _Label('Estimated'),
                                const SizedBox(height: 5),
                                _ReadOnlyBox(
                                  text:
                                      '₹ ${_estimatedAmount.toStringAsFixed(0)}',
                                  bold: true,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const _Label('Rate'),
                                const SizedBox(height: 5),
                                const _ReadOnlyBox(
                                  text: '₹ 4 / KM',
                                  bold: true,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(11, 10, 10, 11),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: PortalColors.border),
                          color: PortalColors.background.withValues(alpha: 0.45),
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
                                      fontWeight: FontWeight.w800,
                                      color: PortalColors.heading,
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: submitting ? null : _addStop,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 7,
                                    ),
                                    decoration: BoxDecoration(
                                      color: PortalColors.purple,
                                      borderRadius: BorderRadius.circular(9),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.add,
                                          size: 13,
                                          color: Colors.white,
                                        ),
                                        const SizedBox(width: 3),
                                        Text(
                                          'Add Stop',
                                          style: portalText(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Add each visit to match your travel route',
                              style: portalText(
                                fontSize: 9.5,
                                color: PortalColors.muted,
                              ),
                            ),
                            for (var i = 0; i < _stops.length; i++) ...[
                              const SizedBox(height: 8),
                              _StopCard(
                                index: i,
                                controllers: _stops[i],
                                canRemove: _stops.length > 1 && !submitting,
                                enabled: !submitting,
                                onRemove: () => _removeStop(i),
                              ),
                            ],
                            const SizedBox(height: 10),
                            const _StopLabel('Remark'),
                            const SizedBox(height: 5),
                            _GrowingRemarkField(
                              controller: _remarkController,
                              enabled: !submitting,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: submitting
                            ? null
                            : () => Navigator.of(context).pop(false),
                        child: Container(
                          height: 36,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: PortalColors.border),
                          ),
                          child: Text(
                            'Cancel',
                            style: portalText(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: PortalColors.heading,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: GestureDetector(
                        onTap: submitting ? null : _submit,
                        child: Container(
                          height: 36,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: PortalColors.brand,
                            borderRadius: BorderRadius.circular(10),
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
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
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
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
      decoration: BoxDecoration(
        color: PortalColors.surface,
        borderRadius: BorderRadius.circular(9),
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
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
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
                      color: PortalColors.red,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 7),
          const _StopLabel('Location / Sample Name'),
          const SizedBox(height: 4),
          _InputField(controller: controllers.location, enabled: enabled),
          const SizedBox(height: 8),
          const _StopLabel('Meeting Outcome'),
          const SizedBox(height: 4),
          _InputField(controller: controllers.outcome, enabled: enabled),
          const SizedBox(height: 8),
          const _StopLabel('Distance (KM)'),
          const SizedBox(height: 4),
          _InputField(
            controller: controllers.km,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
            ],
            enabled: enabled,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _StopLabel('Order (₹)'),
                    const SizedBox(height: 4),
                    _InputField(
                      controller: controllers.orderValue,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                      ],
                      enabled: enabled,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _StopLabel('Upsell (₹)'),
                    const SizedBox(height: 4),
                    _InputField(
                      controller: controllers.upsellValue,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                      ],
                      enabled: enabled,
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

class _GrowingRemarkField extends StatelessWidget {
  const _GrowingRemarkField({
    required this.controller,
    this.enabled = true,
  });

  final TextEditingController controller;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
      decoration: BoxDecoration(
        color: PortalColors.surface,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: PortalColors.border),
      ),
      child: TextField(
        controller: controller,
        enabled: enabled,
        minLines: 2,
        maxLines: null,
        keyboardType: TextInputType.multiline,
        textInputAction: TextInputAction.newline,
        style: portalText(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: PortalColors.heading,
          height: 1.35,
        ),
        decoration: InputDecoration(
          isDense: true,
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
          hintText: 'Add any extra notes…',
          hintStyle: portalText(
            fontSize: 10.5,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF7E7E7E),
          ),
        ),
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  const _InputField({
    required this.controller,
    this.hint,
    this.keyboardType,
    this.inputFormatters,
    this.enabled = true,
  });

  final TextEditingController controller;
  final String? hint;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 11),
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        color: PortalColors.surface,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: PortalColors.border),
      ),
      child: TextField(
        controller: controller,
        enabled: enabled,
        maxLines: 1,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        style: portalText(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: PortalColors.heading,
        ),
        decoration: InputDecoration(
          isDense: true,
          border: InputBorder.none,
          hintText: hint,
          hintStyle: portalText(
            fontSize: 10,
            fontWeight: FontWeight.w400,
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
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 11),
      alignment: centered ? Alignment.center : Alignment.centerLeft,
      decoration: BoxDecoration(
        color: PortalColors.surface,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: PortalColors.border),
      ),
      child: Text(
        text,
        style: portalText(
          fontSize: isHint ? 10 : (bold ? 11.5 : 11),
          fontWeight: isHint
              ? FontWeight.w400
              : (bold ? FontWeight.w700 : FontWeight.w500),
          color: isHint ? const Color(0xFF7E7E7E) : PortalColors.heading,
        ),
      ),
    );
  }
}
