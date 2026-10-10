import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timelay_health/core/theme/portal_colors.dart';
import 'package:timelay_health/core/theme/portal_text.dart';
import 'package:timelay_health/features/visits/domain/failures/visit_failure.dart';
import 'package:timelay_health/features/visits/presentation/bloc/visits_cubit.dart';
import 'package:timelay_health/features/visits/presentation/models/visit_ui_model.dart';

Future<bool?> showAddVisitSheet(BuildContext context, {VisitUiModel? visit}) {
  final cubit = context.read<VisitsCubit>();
  return showDialog<bool>(
    context: context,
    barrierColor: const Color(0x70000000),
    builder: (context) => BlocProvider.value(
      value: cubit,
      child: AddVisitSheet(visit: visit),
    ),
  );
}

class AddVisitSheet extends StatefulWidget {
  const AddVisitSheet({super.key, this.visit});

  final VisitUiModel? visit;

  @override
  State<AddVisitSheet> createState() => _AddVisitSheetState();
}

class _AddVisitSheetState extends State<AddVisitSheet> {
  late final TextEditingController _center;
  late final TextEditingController _client;
  late final TextEditingController _contact;
  late final TextEditingController _address;
  late final TextEditingController _mapsLink;
  late final TextEditingController _remarks;
  late String _status;
  bool _submitting = false;

  static const _statuses = ['Pending', 'Lead', 'Rejected'];

  bool get _isEdit => widget.visit != null;

  @override
  void initState() {
    super.initState();
    final visit = widget.visit;
    _center = TextEditingController(
      text: visit == null || visit.center == '—' ? '' : visit.center,
    );
    _client = TextEditingController(
      text: visit == null || visit.contact == '—' ? '' : visit.contact,
    );
    _contact = TextEditingController(
      text: visit == null || visit.phone == '—' ? '' : visit.phone,
    );
    _address = TextEditingController(
      text: visit == null || visit.address == '—' ? '' : visit.address,
    );
    _mapsLink = TextEditingController(text: visit?.addressLink ?? '');
    _remarks = TextEditingController(text: visit?.remarksValue ?? '');
    _status = visit?.status ?? 'Pending';
    if (!_statuses.contains(_status)) {
      _status = 'Pending';
    }
  }

  @override
  void dispose() {
    _center.dispose();
    _client.dispose();
    _contact.dispose();
    _address.dispose();
    _mapsLink.dispose();
    _remarks.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _submitting = true);
    try {
      final cubit = context.read<VisitsCubit>();
      if (_isEdit) {
        await cubit.updateVisit(
          id: widget.visit!.id,
          centerName: _center.text,
          clientName: _client.text,
          contact: _contact.text,
          address: _address.text,
          addressLink: _mapsLink.text,
          status: _status,
          remarks: _remarks.text,
        );
      } else {
        await cubit.addVisit(
          centerName: _center.text,
          clientName: _client.text,
          contact: _contact.text,
          address: _address.text,
          addressLink: _mapsLink.text,
          status: _status,
          remarks: _remarks.text,
        );
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEdit
                ? 'Visit updated successfully'
                : 'Visit recorded successfully',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e is VisitFailure
                ? e.message
                : (_isEdit
                      ? 'Failed to update visit.'
                      : 'Failed to add visit.'),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final dialogWidth = (size.width - 35).clamp(300.0, 405.0);
    final maxHeight = size.height * 0.88;

    return Dialog(
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
          padding: const EdgeInsets.fromLTRB(20, 22, 18, 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _isEdit ? 'Edit Visit Record' : 'Add New Visit Record',
                      style: portalText(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: PortalColors.heading,
                        height: 16 / 13.5,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: _submitting
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
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F6FF),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 2),
                      child: Icon(
                        Icons.location_on_outlined,
                        size: 17,
                        color: Color(0xFF1E4ED8),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Your current location will be captured automatically when you submit this visit record.',
                        style: portalText(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF1E4ED8),
                          height: 15 / 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              const _Label('Center Name *'),
              const SizedBox(height: 6),
              _Field(
                controller: _center,
                hint: 'e.g. City Diagnostic Center',
                enabled: !_submitting,
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _Label('Client Name *'),
                        const SizedBox(height: 6),
                        _Field(
                          controller: _client,
                          hint: 'Client / Doctor name',
                          enabled: !_submitting,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _Label('Contact *'),
                        const SizedBox(height: 6),
                        _Field(
                          controller: _contact,
                          hint: 'Phone number',
                          enabled: !_submitting,
                          keyboardType: TextInputType.phone,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const _Label('Address *'),
              const SizedBox(height: 6),
              _Field(
                controller: _address,
                hint: 'Full address',
                height: 86,
                alignTop: true,
                enabled: !_submitting,
              ),
              const SizedBox(height: 14),
              const _Label('Google Maps Link'),
              const SizedBox(height: 6),
              _Field(
                controller: _mapsLink,
                hint: 'https://maps.google.com/...',
                enabled: !_submitting,
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 14),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _Label('Status'),
                        const SizedBox(height: 6),
                        _StatusDropdown(
                          value: _status,
                          options: _statuses,
                          enabled: !_submitting,
                          onChanged: (v) => setState(() => _status = v),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _Label('Remarks'),
                        const SizedBox(height: 6),
                        _Field(
                          controller: _remarks,
                          hint: 'Optional notes',
                          enabled: !_submitting,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: _submitting
                          ? null
                          : () => Navigator.of(context).pop(false),
                      child: Container(
                        height: 32,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.white,
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
                            color: Colors.black,
                            height: 12 / 10,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: GestureDetector(
                      onTap: _submitting ? null : _submit,
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
                        child: _submitting
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                _isEdit ? 'Update Visit' : 'Add Visit',
                                style: portalText(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  height: 12 / 10,
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
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: PortalColors.muted,
        height: 15 / 12,
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.hint,
    this.height = 40,
    this.alignTop = false,
    this.enabled = true,
    this.keyboardType,
  });

  final TextEditingController controller;
  final String hint;
  final double height;
  final bool alignTop;
  final bool enabled;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: TextField(
        controller: controller,
        enabled: enabled,
        keyboardType: keyboardType,
        maxLines: alignTop ? null : 1,
        expands: alignTop,
        textAlignVertical: alignTop
            ? TextAlignVertical.top
            : TextAlignVertical.center,
        style: portalText(
          fontSize: 10,
          fontWeight: FontWeight.w400,
          color: PortalColors.heading,
          height: 11 / 10,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: portalText(
            fontSize: 10,
            fontWeight: FontWeight.w400,
            color: const Color(0x751E1C1C),
            height: 11 / 10,
          ),
          isDense: true,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 14,
            vertical: alignTop ? 14 : 12,
          ),
          border: _border(),
          enabledBorder: _border(),
          focusedBorder: _border(PortalColors.purple),
          disabledBorder: _border(),
        ),
      ),
    );
  }

  OutlineInputBorder _border([Color? color]) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: color ?? PortalColors.border),
    );
  }
}

class _StatusDropdown extends StatelessWidget {
  const _StatusDropdown({
    required this.value,
    required this.options,
    required this.onChanged,
    this.enabled = true,
  });

  final String value;
  final List<String> options;
  final ValueChanged<String> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      enabled: enabled,
      onSelected: onChanged,
      offset: const Offset(0, 42),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      itemBuilder: (_) => [
        for (final o in options)
          PopupMenuItem(
            value: o,
            child: Text(
              o,
              style: portalText(fontSize: 12, color: PortalColors.heading),
            ),
          ),
      ],
      child: Container(
        width: double.infinity,
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: PortalColors.border),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                value,
                style: portalText(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF1E1C1C),
                  height: 11 / 10,
                ),
              ),
            ),
            const Icon(Icons.keyboard_arrow_down, size: 16),
          ],
        ),
      ),
    );
  }
}
