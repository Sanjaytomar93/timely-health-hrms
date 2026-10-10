class AttendanceEndpoints {
  const AttendanceEndpoints._();

  static const String _base = 'https://api.timelyhealth.in/api';

  static String myAttendance(String employeeId) =>
      '$_base/attendance/myattendanceforapp/${Uri.encodeComponent(employeeId)}';

  static String myShift(String employeeId) =>
      '$_base/shifts/employee/${Uri.encodeComponent(employeeId)}';

  static String myLocation(String employeeId) =>
      '$_base/employees/mylocation/${Uri.encodeComponent(employeeId)}';

  static const String checkIn = '$_base/attendance/checkin';
  static const String checkOut = '$_base/attendance/checkout';
  static const String claimOt = '$_base/employees/claimot';
}
