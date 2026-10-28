import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:timelay_health/core/theme/portal_colors.dart';
import 'package:timelay_health/core/theme/portal_text.dart';
import 'package:timelay_health/features/expense/data/repositories_impl/expense_repository_impl.dart';
import 'package:timelay_health/features/expense/domain/entities/update_expense_params.dart';
import 'package:timelay_health/features/expense/domain/failures/expense_failure.dart';
import 'package:timelay_health/features/expense/domain/usecases/update_expense_usecase.dart';
import 'package:timelay_health/features/expense/presentation/models/expense_claim_ui_model.dart';

Future<bool?> showEditExpenseSheet(
  BuildContext context, {
  required ExpenseClaimUiModel claim,
}) {
  return showDialog<bool>(
    context: context,
    barrierColor: const Color(0x70000000),
    builder: (_) => EditExpenseSheet(claim: claim),
  );
}

class EditExpenseSheet extends StatefulWidget {
  const EditExpenseSheet({super.key, required this.claim});

  final ExpenseClaimUiModel claim;

  @override
  State<EditExpenseSheet> createState() => _EditExpenseSheetState();
}

class _StopControllers {
  _StopControllers({
    String location = '',
    String outcome = '',
    String km = '',
    String orderValue = '',
    String upsellValue = '',
  }) : location = TextEditingController(text: location),
       outcome = TextEditingController(text: outcome),
       km = TextEditingController(text: km),
       orderValue = TextEditingController(text: orderValue),
       upsellValue = TextEditingController(text: upsellValue);

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

class _EditExpenseSheetState extends State<EditExpenseSheet> {
  late final TextEditingController _purposeController;
  late final TextEditingController _remarkController;
  late final List<_StopControllers> _stops;
  DateTime? _travelDate;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    final claim = widget.claim;
    _purposeController = TextEditingController(text: claim.purpose);
    _remarkController = TextEditingController(text: claim.remark);
    final d = claim.date;
    _travelDate = d == null ? null : DateTime(d.year, d.month, d.day);
    _stops = claim.stops.isEmpty
        ? [_StopControllers()]
        : claim.stops
              .map(
                (s) => _StopControllers(
                  location: s.locationName == 'Stop' ? '' : s.locationName,
                  outcome: s.outcome,
                  km: _numText(s.km),
                  orderValue: _numText(s.orderValue),
                  upsellValue: _numText(s.upsellValue),
                ),
              )
              .toList();
    for (final stop in _stops) {
      stop.km.addListener(_onKmChanged);
    }
  }

  String _numText(double value) {
    if (value <= 0) return '';
    return value % 1 == 0
        ? value.toStringAsFixed(0)
        : value.toStringAsFixed(1);
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

  double get _rate =>
      widget.claim.rateApplied > 0 ? widget.claim.rateApplied : 4;

  double get _totalKm {
    var total = 0.0;
    for (final stop in _stops) {
      total += double.tryParse(stop.km.text.trim()) ?? 0;
    }
    return total;
  }

  double get _estimatedAmount => _totalKm * _rate;

  String get _dateLabel {
    final d = _travelDate;
    if (d == null) return '';
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    return '$dd/$mm/${d.year}';
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _travelDate ?? now,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 1),
    );
    if (picked != null) setState(() => _travelDate = picked);
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

  Future<void> _submit() async {
    final purpose = _purposeController.text.trim();
    if (purpose.isEmpty) {
      _toast('Please enter purpose of travel.');
      return;
    }
    if (_travelDate == null) {
      _toast('Please select travel date.');
      return;
    }
    for (var i = 0; i < _stops.length; i++) {
      if (_stops[i].location.text.trim().isEmpty) {
        _toast('Please enter location for stop ${i + 1}.');
        return;
      }
      if ((double.tryParse(_stops[i].km.text.trim()) ?? 0) <= 0) {
        _toast('Please enter distance (KM) for stop ${i + 1}.');
        return;
      }
    }

    final stops = [
      for (final s in _stops)
        UpdateExpenseStopInput(
          locationName: s.location.text.trim(),
          outcome: s.outcome.text.trim(),
          km: double.tryParse(s.km.text.trim()) ?? 0,
          orderValue: double.tryParse(s.orderValue.text.trim()) ?? 0,
          upsellValue: double.tryParse(s.upsellValue.text.trim()) ?? 0,
        ),
    ];
    final totalKm = stops.fold<double>(0, (sum, s) => sum + s.km);
    final totalOrder = stops.fold<double>(0, (sum, s) => sum + s.orderValue);
    final totalUpsell = stops.fold<double>(0, (sum, s) => sum + s.upsellValue);
    final outcome = stops
        .map((s) => s.outcome.trim())
        .where((o) => o.isNotEmpty)
        .join(', ');

    final expenseId = widget.claim.id.trim();
    if (expenseId.isEmpty) {
      _toast('Expense ID missing. Please refresh and try again.');
      return;
    }

    setState(() => _submitting = true);
    try {
      await UpdateExpenseUseCase(ExpenseRepositoryImpl()).call(
        UpdateExpenseParams(
          id: expenseId,
          purpose: purpose,
          date: _travelDate!,
          km: totalKm,
          outcome: outcome.isEmpty ? purpose : outcome,
          orderValue: totalOrder,
          upsellValue: totalUpsell,
          remark: _remarkController.text.trim(),
          stops: stops,
        ),
      );
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      Navigator.of(context).pop(true);
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Expense updated successfully'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } on ExpenseFailure catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      _toast(e.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _submitting = false);
      _toast('Failed to update expense. Please try again.');
    }
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final dialogWidth = (size.width - 35).clamp(300.0, 420.0);
    final maxHeight = size.height * 0.9;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
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
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Edit Expense',
                                style: portalText(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: PortalColors.heading,
                                  height: 1.2,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Update your travel expense details',
                                style: portalText(
                                  fontSize: 11.5,
                                  color: PortalColors.muted,
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                        InkWell(
                          onTap: _submitting
                              ? null
                              : () => Navigator.of(context).pop(false),
                          borderRadius: BorderRadius.circular(20),
                          child: const Padding(
                            padding: EdgeInsets.all(4),
                            child: Icon(
                              Icons.close,
                              size: 22,
                              color: PortalColors.muted,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    const _FieldLabel('Purpose of Travel', required: true),
                    const SizedBox(height: 8),
                    _InputBox(
                      controller: _purposeController,
                      enabled: !_submitting,
                    ),
                    const SizedBox(height: 14),
                    const _FieldLabel('Travel Date', required: true),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: _submitting ? null : _pickDate,
                      child: _DateBox(
                        text: _dateLabel.isEmpty ? 'Select date' : _dateLabel,
                        isHint: _dateLabel.isEmpty,
                      ),
                    ),
                    const SizedBox(height: 14),
                    const _FieldLabel('Total Distance'),
                    const SizedBox(height: 8),
                    _TotalDistanceBox(
                      text: '${_totalKm.toStringAsFixed(1)} KM',
                    ),
                    const SizedBox(height: 14),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAF1FD),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFD6E4FB)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Estimated Reimbursement',
                              style: portalText(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF3B6FE0),
                              ),
                            ),
                          ),
                          Text(
                            '₹${_estimatedAmount.toStringAsFixed(0)}',
                            style: portalText(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF3B6FE0),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Route Stops & Samples (${_stops.length})',
                            style: portalText(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: PortalColors.heading,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: _submitting ? null : _addStop,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: PortalColors.brand,
                              borderRadius: BorderRadius.circular(10),
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
                                    fontSize: 11.5,
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
                    const SizedBox(height: 12),
                    for (var i = 0; i < _stops.length; i++) ...[
                      if (i > 0) const SizedBox(height: 10),
                      _StopCard(
                        index: i,
                        controllers: _stops[i],
                        canRemove: _stops.length > 1 && !_submitting,
                        enabled: !_submitting,
                        onRemove: () => _removeStop(i),
                      ),
                    ],
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: _submitting ? null : _addStop,
                      child: CustomPaint(
                        painter: _DashedBorderPainter(
                          color: PortalColors.muted.withValues(alpha: 0.45),
                          radius: 12,
                        ),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.add,
                                size: 16,
                                color: PortalColors.muted,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Add Another Stop',
                                style: portalText(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: PortalColors.muted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const _FieldLabel('Additional Remark (Optional)'),
                    const SizedBox(height: 8),
                    _InputBox(
                      controller: _remarkController,
                      height: 88,
                      maxLines: 4,
                      enabled: !_submitting,
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 18),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: _submitting
                          ? null
                          : () => Navigator.of(context).pop(false),
                      child: Container(
                        height: 44,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: PortalColors.background,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: PortalColors.border),
                        ),
                        child: Text(
                          'Cancel',
                          style: portalText(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: PortalColors.heading,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: GestureDetector(
                      onTap: _submitting ? null : _submit,
                      child: Container(
                        height: 44,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: PortalColors.brand,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: _submitting
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                'Update Expense',
                                style: portalText(
                                  fontSize: 13,
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
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: PortalColors.border),
        color: PortalColors.surface,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Stop #${index + 1}',
                  style: portalText(
                    fontSize: 12,
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
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: PortalColors.red,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          const _FieldLabel('Location / Sample Name', required: true),
          const SizedBox(height: 6),
          _InputBox(controller: controllers.location, enabled: enabled),
          const SizedBox(height: 10),
          const _FieldLabel('Meeting Outcome (Optional)'),
          const SizedBox(height: 6),
          _InputBox(controller: controllers.outcome, enabled: enabled),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _FieldLabel('Distance (KM)'),
                    const SizedBox(height: 6),
                    _InputBox(
                      controller: controllers.km,
                      enabled: enabled,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _FieldLabel('Order Value (₹)'),
                    const SizedBox(height: 6),
                    _InputBox(
                      controller: controllers.orderValue,
                      enabled: enabled,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _FieldLabel('Upsell Value (₹)'),
                    const SizedBox(height: 6),
                    _InputBox(
                      controller: controllers.upsellValue,
                      enabled: enabled,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                      ],
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

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text, {this.required = false});

  final String text;
  final bool required;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: text,
            style: portalText(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: PortalColors.secondaryText,
            ),
          ),
          if (required)
            TextSpan(
              text: ' *',
              style: portalText(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: PortalColors.red,
              ),
            ),
        ],
      ),
    );
  }
}

class _InputBox extends StatelessWidget {
  const _InputBox({
    required this.controller,
    this.height = 42,
    this.maxLines = 1,
    this.keyboardType,
    this.inputFormatters,
    this.enabled = true,
  });

  final TextEditingController controller;
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
      padding: const EdgeInsets.symmetric(horizontal: 12),
      alignment: maxLines > 1 ? Alignment.topLeft : Alignment.centerLeft,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: PortalColors.border),
        color: PortalColors.surface,
      ),
      child: TextField(
        controller: controller,
        enabled: enabled,
        maxLines: maxLines,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        style: portalText(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: PortalColors.heading,
        ),
        decoration: const InputDecoration(
          isDense: true,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 10),
        ),
      ),
    );
  }
}

class _DateBox extends StatelessWidget {
  const _DateBox({required this.text, required this.isHint});

  final String text;
  final bool isHint;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: PortalColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              text,
              style: portalText(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isHint ? PortalColors.muted : PortalColors.heading,
              ),
            ),
          ),
          const Icon(
            Icons.calendar_today_outlined,
            size: 16,
            color: PortalColors.muted,
          ),
        ],
      ),
    );
  }
}

class _TotalDistanceBox extends StatelessWidget {
  const _TotalDistanceBox({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: PortalColors.border),
        color: PortalColors.background,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              text,
              style: portalText(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: PortalColors.heading,
              ),
            ),
          ),
          Text(
            'Sum of stops',
            style: portalText(
              fontSize: 10.5,
              fontWeight: FontWeight.w500,
              color: PortalColors.muted,
            ),
          ),
        ],
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  _DashedBorderPainter({required this.color, required this.radius});

  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height),
          Radius.circular(radius),
        ),
      );
    final metrics = path.computeMetrics();
    const dash = 5.0;
    const gap = 4.0;
    for (final metric in metrics) {
      var distance = 0.0;
      while (distance < metric.length) {
        final next = distance + dash;
        canvas.drawPath(metric.extractPath(distance, next), paint);
        distance = next + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.radius != radius;
}
