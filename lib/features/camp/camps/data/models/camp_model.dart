class CampPersonModel {
  const CampPersonModel({
    required this.name,
    this.id,
    this.role,
    this.clinicName,
    this.status,
  });

  final String? id;
  final String name;
  final String? role;
  final String? clinicName;
  final String? status;

  factory CampPersonModel.fromJson(Map<String, dynamic> json) {
    return CampPersonModel(
      id: json['_id']?.toString(),
      name: json['name']?.toString() ?? 'Unknown',
      role: json['role']?.toString(),
      clinicName: json['clinicName']?.toString(),
      status: json['status']?.toString(),
    );
  }
}

class CampPatientVitalsModel {
  const CampPatientVitalsModel({
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

  factory CampPatientVitalsModel.fromJson(Map<String, dynamic> json) {
    return CampPatientVitalsModel(
      weight: _asDouble(json['weight']),
      height: _asDouble(json['height']),
      bpSys: _asDouble(json['bpSys']),
      bpDia: _asDouble(json['bpDia']),
      sugar: _asDouble(json['sugar']),
      sugarType: json['sugarType']?.toString(),
      bmi: _asDouble(json['bmi']),
      bmiCategory: json['bmiCategory']?.toString(),
      updatedAt: _asDate(json['updatedAt']),
    );
  }
}

class CampPatientTestModel {
  const CampPatientTestModel({
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

  factory CampPatientTestModel.fromJson(Map<String, dynamic> json) {
    final verification = json['doctorVerification'];
    return CampPatientTestModel(
      id: (json['_id'] ?? json['id'])?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      value: _asDouble(json['value']) ?? 0,
      value2: _asDouble(json['value2']),
      unit: json['unit']?.toString() ?? '',
      sugarType: json['sugarType']?.toString(),
      date: _asDate(json['date']),
      verificationStatus: verification is Map<String, dynamic>
          ? verification['status']?.toString()
          : null,
      bmi: _asDouble(json['bmi']),
    );
  }
}

class CampPatientModel {
  const CampPatientModel({
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
  final String gender;
  final String contact;
  final String address;
  final String campId;
  final String campName;
  final String campLocation;
  final int testCount;
  final String? reportPdfUrl;
  final CampPatientVitalsModel? vitals;
  final DateTime? createdAt;
  final List<CampPatientTestModel> tests;

  factory CampPatientModel.fromJson(
    Map<String, dynamic> json, {
    String fallbackCampId = '',
    String fallbackCampName = '',
    String fallbackCampLocation = '',
  }) {
    final campRaw = json['campId'];
    String campId = fallbackCampId;
    String campName = fallbackCampName;
    String campLocation = fallbackCampLocation;

    if (campRaw is Map<String, dynamic>) {
      campId = (campRaw['_id'] ?? campRaw['id'])?.toString() ?? campId;
      campName = campRaw['name']?.toString() ?? campName;
      campLocation = campRaw['location']?.toString() ?? campLocation;
    } else if (campRaw != null) {
      campId = campRaw.toString();
    }

    final testsRaw = json['tests'];
    final tests = testsRaw is List
        ? testsRaw
            .whereType<Map<String, dynamic>>()
            .map(CampPatientTestModel.fromJson)
            .toList(growable: false)
        : const <CampPatientTestModel>[];
    final vitalsRaw = json['vitals'];

    return CampPatientModel(
      id: (json['_id'] ?? json['id'])?.toString() ?? '',
      salutation: json['salutation']?.toString(),
      name: json['name']?.toString() ?? '',
      age: _asInt(json['age']),
      gender: json['gender']?.toString() ?? '',
      contact: (json['contact'] ?? json['phone'] ?? json['mobile'])
              ?.toString() ??
          '',
      address: json['address']?.toString() ?? '',
      campId: campId,
      campName: campName,
      campLocation: campLocation,
      testCount: tests.length,
      reportPdfUrl: json['reportPdfUrl']?.toString(),
      vitals: vitalsRaw is Map<String, dynamic>
          ? CampPatientVitalsModel.fromJson(vitalsRaw)
          : null,
      createdAt: _asDate(json['createdAt']),
      tests: tests,
    );
  }
}

class CampModel {
  const CampModel({
    required this.id,
    required this.name,
    required this.location,
    required this.address,
    required this.date,
    required this.time,
    required this.apiStatus,
    required this.volunteers,
    required this.partners,
    required this.patients,
    required this.createdBy,
    required this.assignedPartner,
    required this.partnerRequestStatus,
  });

  final String id;
  final String name;
  final String location;
  final String address;
  final String date;
  final String time;
  final String apiStatus;
  final List<CampPersonModel> volunteers;
  final List<CampPersonModel> partners;
  final List<CampPatientModel> patients;
  final String createdBy;
  final String assignedPartner;
  final String partnerRequestStatus;

  int get patientCount => patients.length;

  factory CampModel.fromJson(Map<String, dynamic> json) {
    final id = (json['_id'] ?? json['id'])?.toString() ?? '';
    final name = json['name']?.toString() ?? '';
    final location = json['location']?.toString() ?? '';
    final createdByRaw = json['createdBy'];
    final assignedPartnerRaw = json['assignedPartner'];
    final partnerRequest = json['partnerRequest'];

    return CampModel(
      id: id,
      name: name,
      location: location,
      address: json['address']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
      time: json['time']?.toString().trim() ?? '',
      apiStatus: json['status']?.toString() ?? '',
      volunteers: _people(json['volunteers']),
      partners: _people(json['partners']),
      patients: _patients(
        json['patients'],
        campId: id,
        campName: name,
        campLocation: location,
      ),
      createdBy: createdByRaw is Map<String, dynamic>
          ? (createdByRaw['name']?.toString() ?? 'Unknown')
          : 'Unknown',
      assignedPartner: assignedPartnerRaw is Map<String, dynamic>
          ? (assignedPartnerRaw['name']?.toString() ?? '—')
          : '—',
      partnerRequestStatus: partnerRequest is Map<String, dynamic>
          ? (partnerRequest['status']?.toString() ?? 'pending')
          : 'pending',
    );
  }

  static List<CampPersonModel> _people(dynamic raw) {
    if (raw is! List) return const [];
    return raw
        .whereType<Map<String, dynamic>>()
        .map(CampPersonModel.fromJson)
        .toList(growable: false);
  }

  static List<CampPatientModel> _patients(
    dynamic raw, {
    required String campId,
    required String campName,
    required String campLocation,
  }) {
    if (raw is! List) return const [];
    return raw
        .whereType<Map<String, dynamic>>()
        .map(
          (json) => CampPatientModel.fromJson(
            json,
            fallbackCampId: campId,
            fallbackCampName: campName,
            fallbackCampLocation: campLocation,
          ),
        )
        .where((p) => p.id.isNotEmpty || p.name.trim().isNotEmpty)
        .toList(growable: false);
  }
}

int _asInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

double? _asDouble(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
}

DateTime? _asDate(dynamic value) {
  if (value is! String || value.isEmpty) return null;
  return DateTime.tryParse(value);
}
