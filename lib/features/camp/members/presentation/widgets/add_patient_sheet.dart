import 'package:flutter/material.dart';
import 'package:timelay_health/features/camp/members/presentation/widgets/member_tokens.dart';

class AddPatientResult {
  const AddPatientResult({
    required this.campName,
    required this.patientName,
    required this.age,
    required this.gender,
    required this.phone,
    required this.address,
  });

  final String campName;
  final String patientName;
  final String age;
  final String gender;
  final String phone;
  final String address;
}

Future<AddPatientResult?> showAddPatientSheet(BuildContext context) {
  return showDialog<AddPatientResult>(
    context: context,
    barrierColor: const Color(0x70000000),
    builder: (_) => const AddPatientSheet(),
  );
}

class AddPatientSheet extends StatefulWidget {
  const AddPatientSheet({super.key});

  @override
  State<AddPatientSheet> createState() => _AddPatientSheetState();
}

class _AddPatientSheetState extends State<AddPatientSheet> {
  final _name = TextEditingController();
  final _age = TextEditingController();
  final _whatsapp = TextEditingController();
  final _address = TextEditingController();

  String? _camp;
  String? _gender;

  static const _camps = [
    'Camp-1',
    'Camp-2',
    'Camp-3',
    'Camp-6',
    'Camp-7',
    'Test Camp',
    'Mega Camp – 1',
  ];

  static const _genders = ['Male', 'Female', 'Other'];

  @override
  void dispose() {
    _name.dispose();
    _age.dispose();
    _whatsapp.dispose();
    _address.dispose();
    super.dispose();
  }

  void _submit() {
    if (_camp == null ||
        _name.text.trim().isEmpty ||
        _age.text.trim().isEmpty ||
        _gender == null ||
        _whatsapp.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required fields'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    Navigator.of(context).pop(
      AddPatientResult(
        campName: _camp!,
        patientName: _name.text.trim(),
        age: _age.text.trim(),
        gender: _gender!,
        phone: _whatsapp.text.trim(),
        address: _address.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
      backgroundColor: Colors.transparent,
      child: Container(
        width: (width - 36).clamp(300.0, 420.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: kMemberPrimary.withValues(alpha: 0.18)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.16),
              blurRadius: 28,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  const SizedBox(
                    width: double.infinity,
                    child: Text(
                      'Add New Patient',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: kMemberHeading,
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: kMemberPrimary.withValues(alpha: 0.08),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          size: 18,
                          color: kMemberHeading,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const _Label('Select Camp'),
              const SizedBox(height: 6),
              _DropdownField(
                value: _camp,
                hint: 'Select Camp',
                items: _camps,
                onChanged: (v) => setState(() => _camp = v),
              ),
              const SizedBox(height: 14),
              const _Label('Patient Name'),
              const SizedBox(height: 6),
              _InputField(
                controller: _name,
                hint: 'Enter Patient Name',
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 14),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _Label('Age'),
                        const SizedBox(height: 6),
                        _InputField(
                          controller: _age,
                          hint: 'Enter Age',
                          keyboardType: TextInputType.number,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _Label('Gender'),
                        const SizedBox(height: 6),
                        _DropdownField(
                          value: _gender,
                          hint: 'Select Gender',
                          items: _genders,
                          onChanged: (v) => setState(() => _gender = v),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const _Label('Whatsapp Number'),
              const SizedBox(height: 6),
              _InputField(
                controller: _whatsapp,
                hint: 'Enter Whatsapp Number',
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 14),
              const _Label('Address'),
              const SizedBox(height: 6),
              _InputField(
                controller: _address,
                hint: 'Enter Address',
                minLines: 3,
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      foregroundColor: kMemberHeading,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Material(
                    color: kMemberPrimary,
                    borderRadius: BorderRadius.circular(24),
                    child: InkWell(
                      onTap: _submit,
                      borderRadius: BorderRadius.circular(24),
                      child: const Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                        child: Text(
                          'Create Patient',
                          style: TextStyle(
                            fontFamily: 'Inter',
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
      style: const TextStyle(
        fontFamily: 'Inter',
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: kMemberHeading,
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  const _InputField({
    required this.controller,
    required this.hint,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.minLines = 1,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final int minLines;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      minLines: minLines,
      maxLines: maxLines,
      style: const TextStyle(
        fontFamily: 'Inter',
        fontSize: 13.5,
        color: kMemberHeading,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          fontFamily: 'Inter',
          fontSize: 13.5,
          color: kMemberMuted.withValues(alpha: 0.85),
        ),
        filled: true,
        fillColor: const Color(0xFFF5F6F8),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: kMemberPrimary, width: 1.2),
        ),
      ),
    );
  }
}

class _DropdownField extends StatelessWidget {
  const _DropdownField({
    required this.value,
    required this.hint,
    required this.items,
    required this.onChanged,
  });

  final String? value;
  final String hint;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F6F8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          hint: Text(
            hint,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13.5,
              color: kMemberMuted.withValues(alpha: 0.85),
            ),
          ),
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: kMemberMuted,
          ),
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 13.5,
            color: kMemberHeading,
          ),
          items: items
              .map(
                (e) => DropdownMenuItem(
                  value: e,
                  child: Text(e),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
