import 'package:timelay_health/features/camp/camps/data/models/camp_model.dart';
import 'package:timelay_health/features/camp/camps/domain/entities/camp.dart';

class CampMapper {
  const CampMapper._();

  static Camp toEntity(CampModel model) {
    final partnerStatus = model.partnerRequestStatus.trim().isEmpty
        ? 'PENDING'
        : model.partnerRequestStatus.trim().toUpperCase();

    return Camp(
      id: model.id,
      name: model.name,
      location: model.location.isNotEmpty ? model.location : model.address,
      address: model.address,
      date: model.date,
      time: model.time,
      status: statusFromDate(model.date),
      volunteers: [
        for (final v in model.volunteers)
          CampPerson(id: v.id, name: v.name),
      ],
      partners: [
        for (final p in model.partners)
          CampPerson(
            id: p.id,
            name: p.name,
            role: (p.clinicName?.trim().isNotEmpty ?? false)
                ? p.clinicName!.trim()
                : 'CLINICAL PARTNER',
            status: partnerStatus,
          ),
      ],
      patients: [
        for (final patient in model.patients) toPatientEntity(patient),
      ],
      createdBy: model.createdBy.trim().isEmpty ? 'Unknown' : model.createdBy,
      assignedPartner:
          model.assignedPartner.trim().isEmpty ? '—' : model.assignedPartner,
    );
  }

  static CampPatient toPatientEntity(CampPatientModel model) {
    final vitals = model.vitals;
    return CampPatient(
      id: model.id,
      salutation: model.salutation,
      name: model.name,
      age: model.age,
      gender: _gender(model.gender),
      contact: model.contact,
      address: model.address,
      campId: model.campId,
      campName: model.campName,
      campLocation: model.campLocation,
      testCount: model.testCount,
      reportPdfUrl: model.reportPdfUrl,
      vitals: vitals == null
          ? null
          : CampPatientVitals(
              weight: vitals.weight,
              height: vitals.height,
              bpSys: vitals.bpSys,
              bpDia: vitals.bpDia,
              sugar: vitals.sugar,
              sugarType: vitals.sugarType,
              bmi: vitals.bmi,
              bmiCategory: vitals.bmiCategory,
              updatedAt: vitals.updatedAt,
            ),
      createdAt: model.createdAt,
      tests: [
        for (final t in model.tests)
          CampPatientTest(
            id: t.id,
            type: t.type,
            value: t.value,
            value2: t.value2,
            unit: t.unit,
            sugarType: t.sugarType,
            date: t.date,
            verificationStatus: t.verificationStatus,
            bmi: t.bmi,
          ),
      ],
    );
  }

  static CampStatus statusFromDate(String raw) {
    final parsed = DateTime.tryParse(raw.trim());
    if (parsed == null) return CampStatus.upcoming;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final campDay = DateTime(parsed.year, parsed.month, parsed.day);

    if (campDay.isAtSameMomentAs(today)) return CampStatus.today;
    if (campDay.isAfter(today)) return CampStatus.upcoming;
    return CampStatus.completed;
  }

  static CampPatientGender _gender(String raw) {
    switch (raw.trim().toLowerCase()) {
      case 'female':
      case 'f':
        return CampPatientGender.female;
      case 'male':
      case 'm':
        return CampPatientGender.male;
      default:
        return CampPatientGender.other;
    }
  }
}
