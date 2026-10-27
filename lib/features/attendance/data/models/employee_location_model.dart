class EmployeeLocationAssignmentModel {
  const EmployeeLocationAssignmentModel({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.isActive,
    required this.fullAddress,
    required this.assignedEmployeesCount,
  });

  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final bool isActive;
  final String fullAddress;
  final int assignedEmployeesCount;

  factory EmployeeLocationAssignmentModel.fromJson(Map<String, dynamic> json) {
    final assigned = json['assignedEmployees'];
    return EmployeeLocationAssignmentModel(
      id: (json['_id'] ?? json['id'])?.toString() ?? '',
      name: json['name'] as String? ?? '',
      latitude: _asDouble(json['latitude']),
      longitude: _asDouble(json['longitude']),
      isActive: json['isActive'] as bool? ?? false,
      fullAddress: json['fullAddress'] as String? ?? '',
      assignedEmployeesCount: assigned is List ? assigned.length : 0,
    );
  }
}

class MyLocationResponseModel {
  const MyLocationResponseModel({
    required this.success,
    required this.location,
  });

  final bool success;
  final EmployeeLocationAssignmentModel? location;

  factory MyLocationResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    Map<String, dynamic>? locationJson;
    if (data is Map<String, dynamic>) {
      final nested = data['location'];
      if (nested is Map<String, dynamic>) {
        locationJson = nested;
      }
    }
    return MyLocationResponseModel(
      success: json['success'] as bool? ?? false,
      location: locationJson == null
          ? null
          : EmployeeLocationAssignmentModel.fromJson(locationJson),
    );
  }
}

class AllLocationsResponseModel {
  const AllLocationsResponseModel({required this.locations});

  final List<EmployeeLocationAssignmentModel> locations;

  factory AllLocationsResponseModel.fromJson(Map<String, dynamic> json) {
    final raw = json['locations'];
    return AllLocationsResponseModel(
      locations: raw is List
          ? [
              for (final item in raw)
                if (item is Map)
                  EmployeeLocationAssignmentModel.fromJson(
                    Map<String, dynamic>.from(item),
                  ),
            ]
          : const [],
    );
  }
}

double _asDouble(dynamic value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0;
  return 0;
}
