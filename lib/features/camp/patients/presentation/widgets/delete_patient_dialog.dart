import 'package:flutter/material.dart';
import 'package:timelay_health/features/camp/dashboard/presentation/theme/camp_colors.dart';
import 'package:timelay_health/features/camp/patients/data/repositories_impl/patient_repository_impl.dart';
import 'package:timelay_health/features/camp/patients/domain/failures/patient_failure.dart';
import 'package:timelay_health/features/camp/patients/domain/usecases/delete_patient_usecase.dart';
import 'package:timelay_health/features/camp/patients/presentation/models/patient_list_ui.dart';

Future<bool> showDeletePatientDialog(
  BuildContext context, {
  required PatientUi patient,
}) async {
  final deleted = await showDialog<bool>(
    context: context,
    barrierColor: const Color(0x99000000),
    builder: (_) => DeletePatientDialog(patient: patient),
  );
  return deleted == true;
}

class DeletePatientDialog extends StatefulWidget {
  const DeletePatientDialog({super.key, required this.patient});

  final PatientUi patient;

  @override
  State<DeletePatientDialog> createState() => _DeletePatientDialogState();
}

class _DeletePatientDialogState extends State<DeletePatientDialog> {
  final _deletePatient = DeletePatientUseCase(PatientRepositoryImpl());
  bool _deleting = false;

  Future<void> _confirm() async {
    if (_deleting) return;
    final id = widget.patient.id.trim();
    if (id.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Patient id missing.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _deleting = true);
    try {
      await _deletePatient(id);
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } on PatientFailure catch (e) {
      if (!mounted) return;
      setState(() => _deleting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _deleting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to delete patient. Please try again.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.patient;
    final width = MediaQuery.sizeOf(context).width;
    final camp = p.campTag?.trim().isNotEmpty == true
        ? p.campTag!.trim()
        : (p.campName.trim().isEmpty ? '—' : p.campName.trim());

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      backgroundColor: Colors.transparent,
      child: Container(
        width: (width - 40).clamp(300.0, 420.0),
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.16),
              blurRadius: 28,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: CampColors.redTint,
                    borderRadius: BorderRadius.circular(21),
                  ),
                  child: const Icon(
                    Icons.warning_amber_rounded,
                    color: CampColors.red,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Delete Patient',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: CampColors.heading,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text.rich(
                        TextSpan(
                          style: const TextStyle(
                            fontSize: 13,
                            height: 1.35,
                            color: CampColors.muted,
                            fontWeight: FontWeight.w500,
                          ),
                          children: [
                            const TextSpan(
                              text: 'Are you sure you want to delete ',
                            ),
                            TextSpan(
                              text: p.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                color: CampColors.heading,
                              ),
                            ),
                            const TextSpan(
                              text:
                                  '? This action cannot be undone and will remove all associated test data.',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(12, 11, 12, 11),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F6FB),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: CampColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text.rich(
                    TextSpan(
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: CampColors.heading,
                        fontWeight: FontWeight.w500,
                      ),
                      children: [
                        const TextSpan(text: 'Contact: '),
                        TextSpan(
                          text: p.phone,
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                        const TextSpan(text: '  |  Camp: '),
                        TextSpan(
                          text: camp,
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${p.testCount} test record${p.testCount == 1 ? '' : 's'} will be deleted',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: CampColors.muted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: OutlinedButton(
                      onPressed:
                          _deleting ? null : () => Navigator.of(context).pop(false),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: CampColors.heading,
                        side: const BorderSide(color: CampColors.border),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: CampColors.red,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: CampColors.red.withValues(alpha: 0.28),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _deleting ? null : _confirm,
                          borderRadius: BorderRadius.circular(12),
                          child: Center(
                            child: _deleting
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.delete_outline_rounded,
                                        size: 17,
                                        color: Colors.white,
                                      ),
                                      SizedBox(width: 6),
                                      Text(
                                        'Delete Patient',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
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
    );
  }
}
