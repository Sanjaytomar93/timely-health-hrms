import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:timelay_health/core/theme/portal_text.dart';
import 'package:timelay_health/features/op/dashboard/presentation/models/op_walkin_ui.dart';
import 'package:timelay_health/features/op/dashboard/presentation/theme/op_colors.dart';

enum OpAmountItemKind { clinic, lab, pharmacy }

Future<void> showOpAmountItemsSheet({
  required BuildContext context,
  required OpWalkinPatientUi patient,
  required OpAmountItemKind kind,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => OpAmountItemsSheet(patient: patient, kind: kind),
  );
}

class _ItemRow {
  _ItemRow({
    required this.name,
    required this.amount,
    String? payment,
  })  : discount = '0',
        discType = '₹',
        payment = payment ?? amount,
        payType = 'Online',
        status = 'Paid',
        txnId = '';

  String name;
  String amount;
  String discount;
  String discType;
  String payment;
  String payType;
  String status;
  String txnId;

  double get amountNum => double.tryParse(amount) ?? 0;
  double get discountNum => double.tryParse(discount) ?? 0;
  double get paymentNum => double.tryParse(payment) ?? 0;
  double get dueNum {
    final d = discType == '%'
        ? amountNum * discountNum / 100
        : discountNum;
    return (amountNum - d - paymentNum).clamp(0, double.infinity);
  }
}

class OpAmountItemsSheet extends StatefulWidget {
  const OpAmountItemsSheet({
    super.key,
    required this.patient,
    required this.kind,
  });

  final OpWalkinPatientUi patient;
  final OpAmountItemKind kind;

  @override
  State<OpAmountItemsSheet> createState() => _OpAmountItemsSheetState();
}

class _OpAmountItemsSheetState extends State<OpAmountItemsSheet> {
  final _addAmount = TextEditingController();
  late final List<_ItemRow> _items;

  String get _title => switch (widget.kind) {
        OpAmountItemKind.clinic => 'Clinic Items',
        OpAmountItemKind.lab => 'Lab Items',
        OpAmountItemKind.pharmacy => 'Pharmacy Items',
      };

  String get _addLabel => switch (widget.kind) {
        OpAmountItemKind.clinic => '+ ADD NEW CLINIC AMOUNT:',
        OpAmountItemKind.lab => '+ ADD NEW LAB AMOUNT:',
        OpAmountItemKind.pharmacy => '+ ADD NEW PHARMACY AMOUNT:',
      };

  String get _saveLabel => switch (widget.kind) {
        OpAmountItemKind.clinic => 'Save Clinic',
        OpAmountItemKind.lab => 'Save Lab',
        OpAmountItemKind.pharmacy => 'Save Pharmacy',
      };

  IconData get _icon => switch (widget.kind) {
        OpAmountItemKind.clinic => Icons.local_hospital_outlined,
        OpAmountItemKind.lab => Icons.science_outlined,
        OpAmountItemKind.pharmacy => Icons.medication_outlined,
      };

  Color get _accent => switch (widget.kind) {
        OpAmountItemKind.clinic => OpColors.blue,
        OpAmountItemKind.lab => OpColors.purple,
        OpAmountItemKind.pharmacy => OpColors.green,
      };

  String get _seedAmount {
    final raw = switch (widget.kind) {
      OpAmountItemKind.clinic => widget.patient.clinic,
      OpAmountItemKind.lab => widget.patient.lab,
      OpAmountItemKind.pharmacy => widget.patient.pharmacy,
    };
    return raw.replaceAll(RegExp(r'[^\d.]'), '');
  }

  String get _defaultName => switch (widget.kind) {
        OpAmountItemKind.clinic => 'Clinic Fee 1',
        OpAmountItemKind.lab => 'Lab Test 1',
        OpAmountItemKind.pharmacy => 'Medicine 1',
      };

  @override
  void initState() {
    super.initState();
    final seed = _seedAmount;
    _items = [
      if (seed.isNotEmpty && seed != '0')
        _ItemRow(name: _defaultName, amount: seed, payment: seed),
    ];
  }

  @override
  void dispose() {
    _addAmount.dispose();
    super.dispose();
  }

  void _addItem() {
    final v = _addAmount.text.trim();
    if (v.isEmpty) return;
    final n = double.tryParse(v);
    if (n == null || n < 0) return;
    setState(() {
      _items.add(
        _ItemRow(
          name: switch (widget.kind) {
            OpAmountItemKind.clinic => 'Clinic Fee ${_items.length + 1}',
            OpAmountItemKind.lab => 'Lab Test ${_items.length + 1}',
            OpAmountItemKind.pharmacy => 'Medicine ${_items.length + 1}',
          },
          amount: v,
          payment: v,
        ),
      );
      _addAmount.clear();
    });
  }

  double get _totalAmount =>
      _items.fold(0, (s, e) => s + e.amountNum);
  double get _totalDiscount => _items.fold(0, (s, e) {
        if (e.discType == '%') return s + e.amountNum * e.discountNum / 100;
        return s + e.discountNum;
      });
  double get _totalPaid =>
      _items.fold(0, (s, e) => s + e.paymentNum);
  double get _totalDue =>
      (_totalAmount - _totalDiscount - _totalPaid).clamp(0, double.infinity);

  String _rupee(double v) => '₹${v.toStringAsFixed(v.truncateToDouble() == v ? 0 : 2)}';

  @override
  Widget build(BuildContext context) {
    final p = widget.patient;
    final bottom = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.92,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE0DEE8),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 8, 0),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: _accent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(_icon, size: 18, color: _accent),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _title,
                      style: portalText(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: OpColors.heading,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                    color: OpColors.muted,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  _InfoChip(text: p.name),
                  _InfoChip(
                    text: p.phone,
                    icon: Icons.phone_rounded,
                  ),
                  _InfoChip(text: '${p.age} Yrs / ${p.gender}'),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _addLabel,
                    style: portalText(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: OpColors.muted,
                      letterSpacing: 0.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _addAmount,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'[\d.]'),
                            ),
                          ],
                          decoration: InputDecoration(
                            hintText: 'Enter amount (₹)',
                            hintStyle: portalText(
                              fontSize: 13,
                              color: OpColors.muted,
                            ),
                            filled: true,
                            fillColor: const Color(0xFFF7F6FC),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: OpColors.border),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: OpColors.border),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: _accent, width: 1.4),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Material(
                        color: OpColors.primaryTint,
                        borderRadius: BorderRadius.circular(12),
                        child: InkWell(
                          onTap: _addItem,
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 13,
                            ),
                            child: Text(
                              '+ Add',
                              style: portalText(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: OpColors.primary,
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
            const SizedBox(height: 10),
            Expanded(
              child: _items.isEmpty
                  ? Center(
                      child: Text(
                        'No items yet. Add an amount above.',
                        style: portalText(
                          fontSize: 13,
                          color: OpColors.muted,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                      itemCount: _items.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, i) => _ItemCard(
                        index: i + 1,
                        item: _items[i],
                        accent: _accent,
                        onChanged: () => setState(() {}),
                        onRemove: () => setState(() => _items.removeAt(i)),
                      ),
                    ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
              decoration: const BoxDecoration(
                color: Color(0xFFF7F6FC),
                border: Border(top: BorderSide(color: OpColors.border)),
              ),
              child: Wrap(
                spacing: 14,
                runSpacing: 6,
                children: [
                  _TotalText(
                    label: 'Amount',
                    value: _rupee(_totalAmount),
                    color: OpColors.primary,
                  ),
                  _TotalText(
                    label: 'Discount',
                    value: _rupee(_totalDiscount),
                    color: OpColors.red,
                  ),
                  _TotalText(
                    label: 'Paid',
                    value: _rupee(_totalPaid),
                    color: OpColors.green,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: OpColors.redTint,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: _TotalText(
                      label: 'Due',
                      value: _rupee(_totalDue),
                      color: OpColors.red,
                    ),
                  ),
                ],
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: OpColors.secondary,
                          side: const BorderSide(color: OpColors.border),
                          minimumSize: const Size.fromHeight(46),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: portalText(
                            fontSize: 13,
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
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: OpColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          minimumSize: const Size.fromHeight(46),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.check_rounded, size: 18),
                        label: Text(
                          '$_saveLabel (${_items.length})',
                          style: portalText(
                            fontSize: 13,
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
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.text, this.icon});

  final String text;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: OpColors.primaryTint,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: OpColors.primary),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: portalText(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: OpColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _TotalText extends StatelessWidget {
  const _TotalText({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: '$label: ',
            style: portalText(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: OpColors.muted,
            ),
          ),
          TextSpan(
            text: value,
            style: portalText(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _ItemCard extends StatelessWidget {
  const _ItemCard({
    required this.index,
    required this.item,
    required this.accent,
    required this.onChanged,
    required this.onRemove,
  });

  final int index;
  final _ItemRow item;
  final Color accent;
  final VoidCallback onChanged;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: OpColors.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 26,
                height: 26,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$index',
                  style: portalText(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: accent,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _Field(
                  value: item.name,
                  onChanged: (v) {
                    item.name = v;
                    onChanged();
                  },
                ),
              ),
              const SizedBox(width: 6),
              Material(
                color: OpColors.redTint,
                borderRadius: BorderRadius.circular(10),
                child: InkWell(
                  onTap: onRemove,
                  borderRadius: BorderRadius.circular(10),
                  child: const SizedBox(
                    width: 34,
                    height: 34,
                    child: Icon(
                      Icons.remove_rounded,
                      size: 18,
                      color: OpColors.red,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _LabeledField(
                  label: 'AMOUNT',
                  child: _Field(
                    value: item.amount,
                    keyboard: TextInputType.number,
                    onChanged: (v) {
                      item.amount = v;
                      onChanged();
                    },
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _LabeledField(
                  label: 'DISC',
                  child: _Field(
                    value: item.discount,
                    keyboard: TextInputType.number,
                    onChanged: (v) {
                      item.discount = v;
                      onChanged();
                    },
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _LabeledField(
                  label: 'DISC TYPE',
                  child: _Dropdown(
                    value: item.discType,
                    items: const ['₹', '%'],
                    onChanged: (v) {
                      item.discType = v;
                      onChanged();
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _LabeledField(
                  label: 'PAYMENT',
                  child: _Field(
                    value: item.payment,
                    keyboard: TextInputType.number,
                    onChanged: (v) {
                      item.payment = v;
                      onChanged();
                    },
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _LabeledField(
                  label: 'P TYPE',
                  child: _Dropdown(
                    value: item.payType,
                    items: const ['Online', 'Cash', 'Card'],
                    onChanged: (v) {
                      item.payType = v;
                      onChanged();
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: OpColors.greenTint,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  item.status,
                  style: portalText(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: OpColors.green,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _Field(
                  value: item.txnId,
                  hint: 'Txn ID',
                  onChanged: (v) {
                    item.txnId = v;
                    onChanged();
                  },
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: OpColors.redTint,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Due ₹${item.dueNum.toStringAsFixed(0)}',
                  style: portalText(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: OpColors.red,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LabeledField extends StatelessWidget {
  const _LabeledField({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: portalText(
            fontSize: 9,
            fontWeight: FontWeight.w800,
            color: OpColors.muted,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 4),
        child,
      ],
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.value,
    required this.onChanged,
    this.hint,
    this.keyboard,
  });

  final String value;
  final ValueChanged<String> onChanged;
  final String? hint;
  final TextInputType? keyboard;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: value,
      keyboardType: keyboard,
      onChanged: onChanged,
      style: portalText(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: OpColors.heading,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: portalText(fontSize: 12, color: OpColors.muted),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        filled: true,
        fillColor: const Color(0xFFF7F6FC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: OpColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: OpColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: OpColors.primary, width: 1.2),
        ),
      ),
    );
  }
}

class _Dropdown extends StatelessWidget {
  const _Dropdown({
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String value;
  final List<String> items;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F6FC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: OpColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18),
          style: portalText(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: OpColors.heading,
          ),
          items: [
            for (final i in items)
              DropdownMenuItem(value: i, child: Text(i)),
          ],
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ),
    );
  }
}
