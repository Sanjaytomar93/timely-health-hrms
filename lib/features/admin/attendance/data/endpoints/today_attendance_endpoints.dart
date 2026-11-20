class TodayAttendanceEndpoints {
  const TodayAttendanceEndpoints._();

  static const String _base = 'https://api.timelyhealth.in/api';

  static String today() => '$_base/attendance/today';
}
