enum CampStatus { today, live, upcoming, completed }

enum CampPatientGender { male, female, other }

class CampPerson {
  const CampPerson({
    required this.name,
    this.id,
    this.role,
    this.status,
  });

  final String? id;
  final String name;
  final String? role;
  final String? status;
}

class CampPatientVitals {
  const CampPatientVitals({
    this.weight,
    this.height,
    this.bpSys,
    this.bpDia,
    this.sugar,
    this.sugarType,
    this.bmi,
    this.bmiCategory,
    this.updatedAt,
  });

  final double? weight;
  final double? height;
  final double? bpSys;
  final double? bpDia;
  final double? sugar;
  final String? sugarType;
  final double? bmi;
  final String? bmiCategory;
  final DateTime? updatedAt;

  bool get hasAny =>
      weight != null ||
      height != null ||
      bpSys != null ||
      bpDia != null ||
      sugar != null ||
      bmi != null;
}

class CampPatientTest {
  const CampPatientTest({
    required this.id,
    required this.type,
    required this.value,
    required this.unit,
    this.value2,
    this.sugarType,
    this.date,
    this.verificationStatus,
    this.bmi,
  });

  final String id;
  final String type;
  final double value;
  final double? value2;
  final String unit;
  final String? sugarType;
  final DateTime? date;
  final String? verificationStatus;
  final double? bmi;
}

class CampPatient {
  const CampPatient({
    required this.id,
    required this.name,
    required this.age,
    required this.gender,
    required this.contact,
    required this.address,
    required this.campId,
    required this.campName,
    required this.campLocation,
    required this.testCount,
    this.salutation,
    this.reportPdfUrl,
    this.vitals,
    this.createdAt,
    this.tests = const [],
  });

  final String id;
  final String? salutation;
  final String name;
  final int age;
  final CampPatientGender gender;
  final String contact;
  final String address;
  final String campId;
  final String campName;
  final String campLocation;
  final int testCount;
  final String? reportPdfUrl;
  final CampPatientVitals? vitals;
  final DateTime? createdAt;
  final List<CampPatientTest> tests;

  bool get isScreened =>
      tests.isNotEmpty || testCount > 0 || (vitals?.hasAny ?? false);

  String get displayName {
    final s = salutation?.trim() ?? '';
    final n = name.trim();
    if (s.isEmpty) return n;
    if (n.isEmpty) return s;
    return '$s $n';
  }
}

class Camp {
  const Camp({
    required this.id,
    required this.name,
    required this.location,
    required this.address,
    required this.date,
    required this.time,
    required this.status,
    required this.volunteers,
    required this.partners,
    required this.patients,
    required this.createdBy,
    required this.assignedPartner,
  });

  final String id;
  final String name;
  final String location;
  final String address;
  final String date;
  final String time;
  final CampStatus status;
  final List<CampPerson> volunteers;
  final List<CampPerson> partners;
  final List<CampPatient> patients;
  final String createdBy;
  final String assignedPartner;

  int get patientCount => patients.length;
}
