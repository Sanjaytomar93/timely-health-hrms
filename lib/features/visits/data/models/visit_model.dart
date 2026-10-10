class VisitEmployeeLocationModel {
  const VisitEmployeeLocationModel({
    required this.latitude,
    required this.longitude,
    this.accuracy,
    this.capturedAt,
    this.mapsLink,
  });

  final double latitude;
  final double longitude;
  final double? accuracy;
  final DateTime? capturedAt;
  final String? mapsLink;

  factory VisitEmployeeLocationModel.fromJson(Map<String, dynamic> json) {
    return VisitEmployeeLocationModel(
      latitude: _asDouble(json['latitude']),
      longitude: _asDouble(json['longitude']),
      accuracy: json['accuracy'] == null ? null : _asDouble(json['accuracy']),
      capturedAt: _parseDate(json['capturedAt']),
      mapsLink: json['mapsLink'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'latitude': latitude,
    'longitude': longitude,
    if (accuracy != null) 'accuracy': accuracy,
  };
}

class VisitModel {
  const VisitModel({
    required this.id,
    required this.employeeId,
    required this.centerName,
    required this.clientName,
    required this.contact,
    required this.address,
    required this.addressLink,
    required this.status,
    required this.remarks,
    this.employeeLocation,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String employeeId;
  final String centerName;
  final String clientName;
  final String contact;
  final String address;
  final String addressLink;
  final String status;
  final String remarks;
  final VisitEmployeeLocationModel? employeeLocation;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory VisitModel.fromJson(Map<String, dynamic> json) {
    final loc = json['employeeLocation'];
    return VisitModel(
      id: (json['_id'] ?? json['id'])?.toString() ?? '',
      employeeId: json['employeeId'] as String? ?? '',
      centerName: json['centerName'] as String? ?? '',
      clientName: json['clientName'] as String? ?? '',
      contact: json['contact'] as String? ?? '',
      address: json['address'] as String? ?? '',
      addressLink: json['addressLink'] as String? ?? '',
      status: json['status'] as String? ?? '',
      remarks: json['remarks'] as String? ?? '',
      employeeLocation: loc is Map<String, dynamic>
          ? VisitEmployeeLocationModel.fromJson(loc)
          : null,
      createdAt: _parseDate(json['createdAt']),
      updatedAt: _parseDate(json['updatedAt']),
    );
  }
}

class MyVisitsResponseModel {
  const MyVisitsResponseModel({required this.success, required this.data});

  final bool success;
  final List<VisitModel> data;

  factory MyVisitsResponseModel.fromJson(Map<String, dynamic> json) {
    final raw = json['data'];
    final list = raw is List
        ? raw
              .whereType<Map<String, dynamic>>()
              .map(VisitModel.fromJson)
              .toList()
        : <VisitModel>[];
    return MyVisitsResponseModel(
      success: json['success'] as bool? ?? false,
      data: list,
    );
  }
}

class AddVisitRequestModel {
  const AddVisitRequestModel({
    required this.centerName,
    required this.clientName,
    required this.contact,
    required this.address,
    required this.addressLink,
    required this.employeeId,
    required this.employeeLocation,
    required this.remarks,
    required this.status,
  });

  final String centerName;
  final String clientName;
  final String contact;
  final String address;
  final String addressLink;
  final String employeeId;
  final VisitEmployeeLocationModel employeeLocation;
  final String remarks;
  final String status;

  Map<String, dynamic> toJson() => {
    'centerName': centerName,
    'clientName': clientName,
    'contact': contact,
    'address': address,
    'addressLink': addressLink,
    'employeeId': employeeId,
    'employeeLocation': employeeLocation.toJson(),
    'remarks': remarks,
    'status': status,
  };
}

class AddVisitResponseModel {
  const AddVisitResponseModel({
    required this.success,
    required this.message,
    required this.callData,
  });

  final bool success;
  final String message;
  final VisitModel callData;

  factory AddVisitResponseModel.fromJson(Map<String, dynamic> json) {
    final raw = json['callData'] ?? json['data'];
    if (raw is! Map<String, dynamic>) {
      throw const FormatException('Missing callData');
    }
    return AddVisitResponseModel(
      success: json['success'] as bool? ?? false,
      message: json['message']?.toString() ?? '',
      callData: VisitModel.fromJson(raw),
    );
  }
}

DateTime? _parseDate(dynamic value) {
  if (value is! String || value.isEmpty) return null;
  return DateTime.tryParse(value);
}

double _asDouble(dynamic value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0;
  return 0;
}
