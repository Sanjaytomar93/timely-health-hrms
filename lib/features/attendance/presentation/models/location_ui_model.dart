import 'package:equatable/equatable.dart';
import 'package:timelay_health/features/attendance/domain/entities/employee_location_assignment.dart';

class LocationUiModel extends Equatable {
  const LocationUiModel({
    required this.id,
    required this.name,
    required this.fullAddress,
    required this.latitudeLabel,
    required this.longitudeLabel,
    required this.coordinatesLabel,
    required this.isActive,
    required this.locationsAssignedLabel,
    required this.employeeName,
    required this.employeeId,
  });

  final String id;
  final String name;
  final String fullAddress;
  final String latitudeLabel;
  final String longitudeLabel;
  final String coordinatesLabel;
  final bool isActive;
  final String locationsAssignedLabel;
  final String employeeName;
  final String employeeId;

  @override
  List<Object?> get props => [
    id,
    name,
    fullAddress,
    latitudeLabel,
    longitudeLabel,
    coordinatesLabel,
    isActive,
    locationsAssignedLabel,
    employeeName,
    employeeId,
  ];
}

class LocationUiMapper {
  const LocationUiMapper._();

  static LocationUiModel toUi({
    required EmployeeLocationAssignment location,
    required String employeeName,
    required String employeeId,
  }) {
    final lat = location.latitude.toStringAsFixed(6);
    final lng = location.longitude.toStringAsFixed(6);
    return LocationUiModel(
      id: location.id,
      name: location.name.isEmpty ? 'Assigned location' : location.name,
      fullAddress: location.fullAddress.isEmpty
          ? 'Address not available'
          : location.fullAddress,
      latitudeLabel: lat,
      longitudeLabel: lng,
      coordinatesLabel: '$lat, $lng',
      isActive: location.isActive,
      locationsAssignedLabel: '1',
      employeeName: employeeName.isEmpty ? 'Employee' : employeeName,
      employeeId: employeeId,
    );
  }

  static String headerDateLabel([DateTime? date]) {
    final d = (date ?? DateTime.now()).toLocal();
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${weekdays[d.weekday - 1]}, ${months[d.month - 1]} ${d.day}, ${d.year}';
  }
}
