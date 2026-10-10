class VisitEmployeeLocation {
  const VisitEmployeeLocation({
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
}

class Visit {
  const Visit({
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
  final VisitEmployeeLocation? employeeLocation;
  final DateTime? createdAt;
  final DateTime? updatedAt;
}

class AddVisitParams {
  const AddVisitParams({
    required this.employeeId,
    required this.centerName,
    required this.clientName,
    required this.contact,
    required this.address,
    required this.addressLink,
    required this.status,
    required this.remarks,
    required this.latitude,
    required this.longitude,
    required this.accuracy,
  });

  final String employeeId;
  final String centerName;
  final String clientName;
  final String contact;
  final String address;
  final String addressLink;
  final String status;
  final String remarks;
  final double latitude;
  final double longitude;
  final double accuracy;
}

class UpdateVisitParams {
  const UpdateVisitParams({
    required this.id,
    required this.employeeId,
    required this.centerName,
    required this.clientName,
    required this.contact,
    required this.address,
    required this.addressLink,
    required this.status,
    required this.remarks,
    required this.latitude,
    required this.longitude,
    required this.accuracy,
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
  final double latitude;
  final double longitude;
  final double accuracy;
}
