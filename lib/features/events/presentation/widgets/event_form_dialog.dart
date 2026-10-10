import 'package:flutter/material.dart';
import 'package:timelay_health/core/theme/portal_colors.dart';
import 'package:timelay_health/core/theme/portal_text.dart';
import 'package:timelay_health/features/events/data/models/my_event.dart';

Future<bool?> showEventFormDialog(
  BuildContext context, {
  MyEvent? initial,
  required Future<void> Function(EventInput input) onSubmit,
}) {
  return showDialog<bool>(
    context: context,
    barrierColor: PortalColors.brand.withValues(alpha: 0.45),
    builder: (_) => _EventFormDialog(initial: initial, onSubmit: onSubmit),
  );
}

class _EventFormDialog extends StatefulWidget {
  const _EventFormDialog({this.initial, required this.onSubmit});

  final MyEvent? initial;
  final Future<void> Function(EventInput input) onSubmit;

  @override
  State<_EventFormDialog> createState() => _EventFormDialogState();
}

class _EventFormDialogState extends State<_EventFormDialog> {
  static const _reminderOptions = [0, 1, 2, 3, 7];

  late final TextEditingController _title;
  late final TextEditingController _notes;
  late EventType _type;
  DateTime? _date;
  late int _reminder;
  late EventRepeat _repeat;
  bool _busy = false;
  String? _error;

  bool get _isEdit => widget.initial != null;

  @override
  void initState() {
    super.initState();
    final e = widget.initial;
    _title = TextEditingController(text: e?.title ?? '');
    _notes = TextEditingController(text: e?.notes ?? '');
    _type = e?.type ?? EventType.birthday;
    _date = e?.date;
    _reminder = e?.reminderBefore ?? 1;
    if (!_reminderOptions.contains(_reminder)) _reminder = 1;
    _repeat = e?.repeat ?? EventRepeat.none;
  }

  @override
  void dispose() {
    _title.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? now,
      firstDate: DateTime(1950),
      lastDate: DateTime(now.year + 10),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme.copyWith(
            primary: PortalColors.brand,
            onPrimary: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _submit() async {
    if (_title.text.trim().isEmpty) {
      setState(() => _error = 'Please enter an event title.');
      return;
    }
    if (_date == null) {
      setState(() => _error = 'Please pick the event date.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await widget.onSubmit(
        EventInput(
          title: _title.text,
          type: _type,
          date: _date!,
          reminderBefore: _reminder,
          repeat: _repeat,
          notes: _notes.text,
        ),
      );
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: PortalColors.surface,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _DialogHeader(isEdit: _isEdit),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _Label('Event Title', required: true),
                  _TextInput(
                    controller: _title,
                    hint: 'e.g., Annual Team Meet, Mom\'s Birthday…',
                  ),
                  const SizedBox(height: 14),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const _Label('Category', required: true),
                            _Dropdown<EventType>(
                              value: _type,
                              items: {
                                for (final t in EventType.values)
                                  t: '${t.emoji}  ${t.label}',
                              },
                              onChanged: (t) => setState(() => _type = t),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const _Label('Event Date', required: true),
                            _DateInput(date: _date, onTap: _pickDate),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const _Label('⏰ Reminder'),
                            _Dropdown<int>(
                              value: _reminder,
                              items: {
                                for (final d in _reminderOptions)
                                  d: d == 0
                                      ? 'Same Day'
                                      : '$d Day${d == 1 ? '' : 's'} Before',
                              },
                              onChanged: (d) => setState(() => _reminder = d),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const _Label('🔄 Recurrence'),
                            _Dropdown<EventRepeat>(
                              value: _repeat,
                              items: const {
                                EventRepeat.none: 'No Repeat',
                                EventRepeat.yearly: 'Yearly',
                              },
                              onChanged: (r) => setState(() => _repeat = r),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const _Label('📝 Notes / Description'),
                  _TextInput(
                    controller: _notes,
                    hint: 'Add any reminders, venue, or details…',
                    maxLines: 4,
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: PortalColors.redTint,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.error_outline_rounded,
                            size: 16,
                            color: PortalColors.red,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _error!,
                              style: portalText(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: PortalColors.red,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 18),
                ],
              ),
            ),
          ),
          const Divider(height: 1, color: PortalColors.border),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: _busy ? null : () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: PortalColors.secondaryText,
                    side: const BorderSide(color: PortalColors.border),
                    minimumSize: const Size(96, 44),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Cancel',
                    style: portalText(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: PortalColors.secondaryText,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                _SaveButton(
                  busy: _busy,
                  label: _isEdit ? 'Save Changes' : 'Save Event',
                  onTap: _submit,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DialogHeader extends StatelessWidget {
  const _DialogHeader({required this.isEdit});

  final bool isEdit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 8, 16),
      decoration: const BoxDecoration(
        color: PortalColors.background,
        border: Border(bottom: BorderSide(color: PortalColors.border)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEdit ? '✏️ Edit Event' : '✨ Add New Event',
                  style: portalText(fontSize: 17, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  isEdit
                      ? 'Update the details of your event'
                      : 'Create an event with reminders and recurrence',
                  style: portalText(fontSize: 11.5, color: PortalColors.muted),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close_rounded, color: PortalColors.muted),
          ),
        ],
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text, {this.required = false});

  final String text;
  final bool required;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Text.rich(
        TextSpan(
          text: text,
          style: portalText(
            fontSize: 12,
            fontWeight: FontWeight.w600,
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
    );
  }
}

OutlineInputBorder _inputBorder([Color color = PortalColors.border]) =>
    OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: color, width: 1.2),
    );

InputDecoration _decoration({String? hint}) => InputDecoration(
  hintText: hint,
  hintStyle: portalText(fontSize: 12.5, color: PortalColors.muted),
  isDense: true,
  filled: true,
  fillColor: PortalColors.surface,
  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
  border: _inputBorder(),
  enabledBorder: _inputBorder(),
  focusedBorder: _inputBorder(PortalColors.brandLight),
);

class _TextInput extends StatelessWidget {
  const _TextInput({
    required this.controller,
    required this.hint,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String hint;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      textCapitalization: TextCapitalization.sentences,
      style: portalText(fontSize: 13, fontWeight: FontWeight.w500),
      decoration: _decoration(hint: hint),
    );
  }
}

class _Dropdown<T> extends StatelessWidget {
  const _Dropdown({
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final T value;
  final Map<T, String> items;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      isExpanded: true,
      icon: const Icon(Icons.keyboard_arrow_down_rounded),
      iconEnabledColor: PortalColors.secondaryText,
      dropdownColor: PortalColors.surface,
      borderRadius: BorderRadius.circular(12),
      style: portalText(fontSize: 13, fontWeight: FontWeight.w500),
      decoration: _decoration(),
      items: [
        for (final entry in items.entries)
          DropdownMenuItem<T>(
            value: entry.key,
            child: Text(
              entry.value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
      ],
      onChanged: (v) {
        if (v != null) onChanged(v);
      },
    );
  }
}

class _DateInput extends StatelessWidget {
  const _DateInput({required this.date, required this.onTap});

  final DateTime? date;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    String two(int v) => v.toString().padLeft(2, '0');
    final d = date;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: InputDecorator(
        decoration: _decoration(),
        child: Row(
          children: [
            Expanded(
              child: Text(
                d == null
                    ? 'dd/mm/yyyy'
                    : '${two(d.day)}/${two(d.month)}/${d.year}',
                maxLines: 1,
                style: portalText(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: d == null ? PortalColors.muted : PortalColors.heading,
                ),
              ),
            ),
            const Icon(
              Icons.calendar_today_outlined,
              size: 16,
              color: PortalColors.secondaryText,
            ),
          ],
        ),
      ),
    );
  }
}

class _SaveButton extends StatelessWidget {
  const _SaveButton({
    required this.busy,
    required this.label,
    required this.onTap,
  });

  final bool busy;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(colors: PortalColors.brandGradient),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: busy ? null : onTap,
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            height: 44,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (busy)
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  else
                    const Icon(
                      Icons.add_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  const SizedBox(width: 6),
                  Text(
                    label,
                    style: portalText(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
