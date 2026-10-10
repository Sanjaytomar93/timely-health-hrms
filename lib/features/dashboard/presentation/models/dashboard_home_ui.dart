import 'package:equatable/equatable.dart';
import 'package:timelay_health/features/dashboard/presentation/widgets/stat_cards_row.dart';

class DashboardGreetingUi extends Equatable {
  const DashboardGreetingUi({
    required this.greeting,
    required this.firstName,
    required this.dateLabel,
  });

  final String greeting;
  final String firstName;
  final String dateLabel;

  @override
  List<Object?> get props => [greeting, firstName, dateLabel];
}

class DashboardProfileUi extends Equatable {
  const DashboardProfileUi({
    required this.initials,
    required this.name,
    required this.department,
    required this.employeeId,
    required this.statusLabel,
    required this.locationLabel,
    required this.shiftLabel,
  });

  final String initials;
  final String name;
  final String department;
  final String employeeId;
  final String statusLabel;
  final String locationLabel;
  final String shiftLabel;

  @override
  List<Object?> get props => [
    initials,
    name,
    department,
    employeeId,
    statusLabel,
    locationLabel,
    shiftLabel,
  ];
}

class DashboardAttendanceBannerUi extends Equatable {
  const DashboardAttendanceBannerUi({
    required this.statusLabel,
    required this.isCheckedIn,
    required this.checkIn,
    required this.checkOut,
    required this.shift,
  });

  final String statusLabel;
  final bool isCheckedIn;
  final String checkIn;
  final String checkOut;
  final String shift;

  @override
  List<Object?> get props => [
    statusLabel,
    isCheckedIn,
    checkIn,
    checkOut,
    shift,
  ];
}

class DashboardActivityUi extends Equatable {
  const DashboardActivityUi({
    required this.date,
    required this.time,
    required this.isIn,
  });

  final String date;
  final String time;
  final bool isIn;

  @override
  List<Object?> get props => [date, time, isIn];
}

class DashboardUpdateItemUi extends Equatable {
  const DashboardUpdateItemUi({
    required this.title,
    required this.subtitle,
    required this.kind,
  });

  final String title;
  final String subtitle;
  final String kind;

  @override
  List<Object?> get props => [title, subtitle, kind];
}

class DashboardAbsentWeekUi extends Equatable {
  const DashboardAbsentWeekUi({
    required this.label,
    required this.dateRange,
    required this.workingDays,
    required this.absentDays,
  });

  final String label;
  final String dateRange;
  final int workingDays;
  final int absentDays;

  @override
  List<Object?> get props => [label, dateRange, workingDays, absentDays];
}

class DashboardAbsentUi extends Equatable {
  const DashboardAbsentUi({
    required this.periodLabel,
    required this.totalAbsent,
    required this.totalWorkingDays,
    required this.weeks,
  });

  final String periodLabel;
  final int totalAbsent;
  final int totalWorkingDays;
  final List<DashboardAbsentWeekUi> weeks;

  static const empty = DashboardAbsentUi(
    periodLabel: '',
    totalAbsent: 0,
    totalWorkingDays: 0,
    weeks: [],
  );

  @override
  List<Object?> get props => [
    periodLabel,
    totalAbsent,
    totalWorkingDays,
    weeks,
  ];
}

class DashboardHomeUi extends Equatable {
  const DashboardHomeUi({
    required this.greeting,
    required this.profile,
    required this.attendanceBanner,
    required this.statCards,
    required this.lateMinutes,
    required this.absentDays,
    required this.recentActivity,
    required this.updates,
    required this.updatesMonthLabel,
  });

  final DashboardGreetingUi greeting;
  final DashboardProfileUi profile;
  final DashboardAttendanceBannerUi attendanceBanner;
  final List<StatCardData> statCards;
  final List<double> lateMinutes;
  final DashboardAbsentUi absentDays;
  final List<DashboardActivityUi> recentActivity;
  final List<DashboardUpdateItemUi> updates;
  final String updatesMonthLabel;

  static DashboardHomeUi get empty {
    final now = DateTime.now();
    return DashboardHomeUi(
      greeting: DashboardGreetingUi(
        greeting: _greetingForHour(now.hour),
        firstName: 'there',
        dateLabel: _fullDate(now),
      ),
      profile: const DashboardProfileUi(
        initials: '?',
        name: '—',
        department: '—',
        employeeId: '—',
        statusLabel: '—',
        locationLabel: '📍 —',
        shiftLabel: '🕒 —',
      ),
      attendanceBanner: const DashboardAttendanceBannerUi(
        statusLabel: 'Not checked in yet',
        isCheckedIn: false,
        checkIn: '—',
        checkOut: '—',
        shift: '—',
      ),
      statCards: const [
        StatCardData(
          title: 'Present',
          value: '0',
          subtitle: 'days this month',
          iconAsset: 'assets/icons/stat_cards/ic_stat_present.svg',
        ),
        StatCardData(
          title: 'Absent',
          value: '0',
          subtitle: 'days this month',
          iconAsset: 'assets/icons/stat_cards/ic_stat_absent.svg',
        ),
        StatCardData(
          title: 'Late',
          value: '0',
          subtitle: 'instances',
          iconAsset: 'assets/icons/stat_cards/ic_stat_late.svg',
        ),
        StatCardData(
          title: 'Attendance',
          value: '0',
          subtitle: 'of 0 days',
          iconAsset: 'assets/icons/stat_cards/ic_stat_attendance.svg',
        ),
      ],
      lateMinutes: const [0, 0, 0, 0, 0],
      absentDays: DashboardAbsentUi.empty,
      recentActivity: const [],
      updates: const [],
      updatesMonthLabel: _monthYear(now),
    );
  }

  @override
  List<Object?> get props => [
    greeting,
    profile,
    attendanceBanner,
    statCards,
    lateMinutes,
    absentDays,
    recentActivity,
    updates,
    updatesMonthLabel,
  ];
}

String _greetingForHour(int hour) {
  if (hour < 12) return 'Good morning';
  if (hour < 17) return 'Good afternoon';
  return 'Good evening';
}

String _fullDate(DateTime date) {
  const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  final local = date.toLocal();
  return '${weekdays[local.weekday - 1]}, ${months[local.month - 1]} ${local.day}, ${local.year}';
}

String _monthYear(DateTime date) {
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
  final local = date.toLocal();
  return '${months[local.month - 1]} ${local.year}';
}
