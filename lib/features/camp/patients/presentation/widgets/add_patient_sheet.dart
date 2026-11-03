import 'package:flutter/material.dart';
import 'package:timelay_health/features/auth/data/auth_session.dart';
import 'package:timelay_health/features/camp/camps/data/repositories_impl/camp_repository_impl.dart';
import 'package:timelay_health/features/camp/camps/domain/entities/camp.dart';
import 'package:timelay_health/features/camp/camps/domain/failures/camp_failure.dart';
import 'package:timelay_health/features/camp/camps/domain/usecases/get_assigned_camps_usecase.dart';
import 'package:timelay_health/features/camp/patients/data/repositories_impl/patient_repository_impl.dart';
import 'package:timelay_health/features/camp/patients/domain/failures/patient_failure.dart';
import 'package:timelay_health/features/camp/patients/domain/usecases/create_patient_usecase.dart';
import 'package:timelay_health/features/camp/patients/presentation/widgets/patient_tokens.dart';

class AddPatientResult {
  const AddPatientResult({
    required this.patientId,
    required this.campId,
    required this.campName,
    required this.campLocation,
    required this.patientName,
    required this.age,
    required this.gender,
    required this.phone,
    required this.address,
  });

  final String patientId;
  final String campId;
  final String campName;
  final String campLocation;
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
  final _createPatient = CreatePatientUseCase(PatientRepositoryImpl());
  final _getCamps = GetAssignedCampsUseCase(CampRepositoryImpl());

  List<Camp> _camps = const [];
  String? _campId;
  String? _gender;
  bool _loadingCamps = true;
  bool _submitting = false;
  String? _campsError;

  static const _genders = ['Male', 'Female', 'Other'];

  @override
  void initState() {
    super.initState();
    _loadCamps();
  }

  @override
  void dispose() {
    _name.dispose();
    _age.dispose();
    _whatsapp.dispose();
    _address.dispose();
    super.dispose();
  }

  Future<void> _loadCamps() async {
    setState(() {
      _loadingCamps = true;
      _campsError = null;
    });

    final employee =
        AuthSession.currentEmployee ?? await AuthSession.load();
    final employeeName = employee?.displayName.trim() ?? '';

    if (!mounted) return;

    if (employeeName.isEmpty) {
      setState(() {
        _loadingCamps = false;
        _campsError = 'Employee name missing. Please login again.';
      });
      return;
    }

    try {
      final camps = await _getCamps(employeeName);
      if (!mounted) return;
      final valid = camps
          .where((c) => c.id.trim().isNotEmpty)
          .toList(growable: false);
      setState(() {
        _camps = valid;
        _loadingCamps = false;
        if (valid.isEmpty) {
          _campsError = 'No assigned camps found.';
        }
      });
    } on CampFailure catch (e) {
      if (!mounted) return;
      setState(() {
        _loadingCamps = false;
        _campsError = e.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loadingCamps = false;
        _campsError = 'Failed to load camps. Please try again.';
      });
    }
  }

  bool _isActiveCamp(Camp camp) =>
      camp.status == CampStatus.today || camp.status == CampStatus.live;

  String _campStatusLabel(Camp camp) => switch (camp.status) {
        CampStatus.today => 'Today',
        CampStatus.live => 'Live',
        CampStatus.upcoming => 'Upcoming',
        CampStatus.completed => 'Completed',
      };

  String _campLabel(Camp camp) {
    final name = camp.name.trim();
    final location = camp.location.trim();
    final base = name.isNotEmpty && location.isNotEmpty
        ? '$name · $location'
        : name.isNotEmpty
            ? name
            : location.isNotEmpty
                ? location
                : camp.id;
    return '$base · ${_campStatusLabel(camp)}';
  }

  String _salutationFor(String gender) {
    switch (gender.toLowerCase()) {
      case 'female':
        return 'Ms.';
      case 'male':
        return 'Mr.';
      default:
        return 'Mr.';
    }
  }

  Future<void> _submit() async {
    if (_submitting) return;

    final campId = _campId;
    final gender = _gender;
    if (campId == null ||
        _name.text.trim().isEmpty ||
        _age.text.trim().isEmpty ||
        gender == null ||
        _whatsapp.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required fields'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    Camp? camp;
    for (final c in _camps) {
      if (c.id == campId) {
        camp = c;
        break;
      }
    }
    if (camp == null || !_isActiveCamp(camp)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an active camp (Today / Live).'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _submitting = true);

    try {
      final created = await _createPatient(
        CreatePatientParams(
          salutation: _salutationFor(gender),
          name: _name.text.trim(),
          age: _age.text.trim(),
          gender: gender.toLowerCase(),
          contact: _whatsapp.text.trim(),
          address: _address.text.trim(),
          campId: campId,
        ),
      );
      if (!mounted) return;
      Navigator.of(context).pop(
        AddPatientResult(
          patientId: created.id,
          campId: created.campId.isNotEmpty ? created.campId : campId,
          campName: created.campName.trim().isNotEmpty
              ? created.campName.trim()
              : camp.name,
          campLocation: created.campLocation.trim().isNotEmpty
              ? created.campLocation.trim()
              : camp.location,
          patientName: created.name.trim().isNotEmpty
              ? created.displayName
              : _name.text.trim(),
          age: '${created.age > 0 ? created.age : _age.text.trim()}',
          gender: gender,
          phone: created.contact.trim().isNotEmpty
              ? created.contact.trim()
              : _whatsapp.text.trim(),
          address: created.address.trim().isNotEmpty
              ? created.address.trim()
              : _address.text.trim(),
        ),
      );
    } on PatientFailure catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to create patient. Please try again.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final campOptions = [
      for (final c in _camps)
        (
          id: c.id,
          label: _campLabel(c),
          enabled: _isActiveCamp(c),
        ),
    ];

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
      backgroundColor: Colors.transparent,
      child: Container(
        width: (width - 36).clamp(300.0, 420.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: kPatientPrimary.withValues(alpha: 0.18)),
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
                        color: kPatientHeading,
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: InkWell(
                      onTap: _submitting
                          ? null
                          : () => Navigator.of(context).pop(),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: kPatientPrimary.withValues(alpha: 0.08),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          size: 18,
                          color: kPatientHeading,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const _Label('Select Camp'),
              const SizedBox(height: 6),
              if (_loadingCamps)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Center(
                    child: SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                )
              else if (_campsError != null && _camps.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _campsError!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFFE0483E),
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: _loadCamps,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              else
                _CampDropdown(
                  value: _campId,
                  camps: campOptions,
                  onChanged: _submitting
                      ? null
                      : (v) => setState(() => _campId = v),
                ),
              const SizedBox(height: 14),
              const _Label('Patient Name'),
              const SizedBox(height: 6),
              _InputField(
                controller: _name,
                hint: 'Enter Patient Name',
                textCapitalization: TextCapitalization.words,
                enabled: !_submitting,
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
                        const _Label('Gender'),
                        const SizedBox(height: 6),
                        _DropdownField(
                          value: _gender,
                          hint: 'Select Gender',
                          items: _genders,
                          onChanged: _submitting
                              ? null
                              : (v) => setState(() => _gender = v),
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
                enabled: !_submitting,
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
                enabled: !_submitting,
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  TextButton(
                    onPressed: _submitting
                        ? null
                        : () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      foregroundColor: kPatientHeading,
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
                    color: kPatientPrimary,
                    borderRadius: BorderRadius.circular(24),
                    child: InkWell(
                      onTap: _submitting ? null : _submit,
                      borderRadius: BorderRadius.circular(24),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 22,
                          vertical: 12,
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
                            : const Text(
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
        color: kPatientHeading,
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
    this.enabled = true,
  });

  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final int minLines;
  final int maxLines;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      minLines: minLines,
      maxLines: maxLines,
      style: const TextStyle(
        fontFamily: 'Inter',
        fontSize: 13.5,
        color: kPatientHeading,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          fontFamily: 'Inter',
          fontSize: 13.5,
          color: kPatientMuted.withValues(alpha: 0.85),
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
          borderSide: const BorderSide(color: kPatientPrimary, width: 1.2),
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
  final ValueChanged<String?>? onChanged;

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
              color: kPatientMuted.withValues(alpha: 0.85),
            ),
          ),
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: kPatientMuted,
          ),
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 13.5,
            color: kPatientHeading,
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

class _CampDropdown extends StatelessWidget {
  const _CampDropdown({
    required this.value,
    required this.camps,
    required this.onChanged,
  });

  final String? value;
  final List<({String id, String label, bool enabled})> camps;
  final ValueChanged<String?>? onChanged;

  @override
  Widget build(BuildContext context) {
    final selectedValid =
        value != null && camps.any((c) => c.id == value && c.enabled);

    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F6F8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedValid ? value : null,
          isExpanded: true,
          hint: Text(
            'Select Camp',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13.5,
              color: kPatientMuted.withValues(alpha: 0.85),
            ),
          ),
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: kPatientMuted,
          ),
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 13.5,
            color: kPatientHeading,
          ),
          items: camps
              .map(
                (c) => DropdownMenuItem<String>(
                  value: c.id,
                  enabled: c.enabled,
                  child: Row(
                    children: [
                      Icon(
                        c.enabled
                            ? Icons.lock_open_rounded
                            : Icons.lock_outline_rounded,
                        size: 14,
                        color: c.enabled
                            ? const Color(0xFF1FA971)
                            : kPatientMuted.withValues(alpha: 0.7),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          c.label,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 13.5,
                            color: c.enabled
                                ? kPatientHeading
                                : kPatientMuted.withValues(alpha: 0.75),
                            fontWeight:
                                c.enabled ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
