import 'package:flutter/material.dart';
import 'package:timelay_health/core/theme/portal_colors.dart';
import 'package:timelay_health/core/theme/portal_text.dart';
import 'package:timelay_health/core/widgets/month_picker.dart';

class LeaveFiltersCard extends StatelessWidget {
  const LeaveFiltersCard({
    super.key,
    required this.searchController,
    required this.onSearchChanged,
    required this.selectedDate,
    required this.selectedMonth,
    required this.onDateChanged,
    required this.onMonthChanged,
  });

  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final DateTime? selectedDate;
  final DateTime? selectedMonth;
  final ValueChanged<DateTime?> onDateChanged;
  final ValueChanged<DateTime?> onMonthChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(18, 16, 18, 0),
      padding: const EdgeInsets.fromLTRB(17, 17, 17, 18),
      decoration: BoxDecoration(
        color: PortalColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: PortalColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🔍  Filters',
            style: portalText(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: PortalColors.heading,
              height: 16 / 13.5,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'SEARCH',
            style: portalText(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: PortalColors.muted,
              letterSpacing: 0.3,
              height: 13 / 10.5,
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            height: 38,
            child: TextField(
              controller: searchController,
              onChanged: onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search leaves...',
                hintStyle: portalText(
                  fontSize: 12.1,
                  color: const Color(0xFF757575),
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  size: 16,
                  color: PortalColors.muted,
                ),
                prefixIconConstraints: const BoxConstraints(
                  minWidth: 40,
                  minHeight: 38,
                ),
                filled: true,
                fillColor: PortalColors.background,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                border: _fieldBorder(),
                enabledBorder: _fieldBorder(),
                focusedBorder: _fieldBorder(PortalColors.purple),
              ),
              style: portalText(fontSize: 12.5, color: PortalColors.heading),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _FilterField(
                  label: 'DATE',
                  value: _dateLabel(selectedDate),
                  hint: 'dd/mm/yyyy',
                  onTap: () => _pickDate(context),
                  onClear: selectedDate == null
                      ? null
                      : () => onDateChanged(null),
                ),
              ),
              SizedBox(width: 11),
              Expanded(
                child: _FilterField(
                  label: 'MONTH',
                  value: _monthLabel(selectedMonth),
                  hint: 'Select month',
                  onTap: () => _pickMonth(context),
                  onClear: selectedMonth == null
                      ? null
                      : () => onMonthChanged(null),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static OutlineInputBorder _fieldBorder([Color? color]) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(11),
      borderSide: BorderSide(color: color ?? PortalColors.border),
    );
  }

  Future<void> _pickDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? now,
      firstDate: DateTime(now.year - 10),
      lastDate: DateTime(now.year + 2),
    );
    if (picked != null) onDateChanged(picked);
  }

  Future<void> _pickMonth(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showMonthPicker(
      context,
      initial: selectedMonth ?? now,
    );
    if (picked != null) onMonthChanged(picked);
  }

  static String? _dateLabel(DateTime? date) {
    if (date == null) return null;
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  static String? _monthLabel(DateTime? date) {
    if (date == null) return null;
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
    return '${months[date.month - 1]} ${date.year}';
  }
}

class _FilterField extends StatelessWidget {
  const _FilterField({
    required this.label,
    required this.hint,
    required this.value,
    required this.onTap,
    this.onClear,
  });

  final String label;
  final String hint;
  final String? value;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: portalText(
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
            color: PortalColors.muted,
            letterSpacing: 0.3,
            height: 13 / 10.5,
          ),
        ),
        const SizedBox(height: 6),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(11),
          child: Container(
            height: 36,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 13),
            alignment: Alignment.centerLeft,
            decoration: BoxDecoration(
              color: PortalColors.background,
              borderRadius: BorderRadius.circular(11),
              border: Border.all(color: PortalColors.border),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value ?? hint,
                    overflow: TextOverflow.ellipsis,
                    style: portalText(
                      fontSize: 12.5,
                      color: value == null
                          ? PortalColors.muted
                          : PortalColors.heading,
                      height: 15 / 12.5,
                    ),
                  ),
                ),
                if (onClear != null)
                  InkWell(
                    onTap: onClear,
                    child: const Icon(
                      Icons.close,
                      size: 15,
                      color: PortalColors.muted,
                    ),
                  )
                else
                  const Icon(
                    Icons.calendar_today_outlined,
                    size: 14,
                    color: PortalColors.muted,
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
