class EmployeeLocation {
  const EmployeeLocation({
    required this.latitude,
    required this.longitude,
    this.timestamp,
    this.address,
  });

  final double latitude;
  final double longitude;
  final DateTime? timestamp;
  final String? address;
}

class SalaryIncrement {
  const SalaryIncrement({
    required this.incrementType,
    required this.incrementValue,
    required this.oldSalaryPerMonth,
    required this.newSalaryPerMonth,
    this.effectiveFrom,
    this.reason = '',
  });

  final String incrementType;
  final double incrementValue;
  final double oldSalaryPerMonth;
  final double newSalaryPerMonth;
  final DateTime? effectiveFrom;
  final String reason;
}

class EmployeeProfileInfo {
  const EmployeeProfileInfo({
    this.alternateNumber = '',
    this.parentsName = '',
    this.gender = '',
    this.dob,
    this.addressLine1 = '',
    this.addressLine2 = '',
    this.city = '',
    this.state = '',
    this.pinCode = '',
    this.country = '',
    this.workLocation = '',
    this.employmentType = '',
    this.reportingManager = '',
    this.bankName = '',
    this.bankAccountNo = '',
    this.ifscCode = '',
    this.panNumber = '',
    this.aadharNumber = '',
    this.uanNumber = '',
    this.pfNumber = '',
    this.esicNumber = '',
    this.ctc = 0,
    this.shiftType = '',
    this.shiftHours,
    this.weekOffDay = '',
    this.weekOffPerMonth,
    this.maxCL,
    this.maxSL,
    this.maxEL,
    this.maxCompOff,
  });

  final String alternateNumber;
  final String parentsName;
  final String gender;
  final DateTime? dob;
  final String addressLine1;
  final String addressLine2;
  final String city;
  final String state;
  final String pinCode;
  final String country;
  final String workLocation;
  final String employmentType;
  final String reportingManager;
  final String bankName;
  final String bankAccountNo;
  final String ifscCode;
  final String panNumber;
  final String aadharNumber;
  final String uanNumber;
  final String pfNumber;
  final String esicNumber;
  final double ctc;
  final String shiftType;
  final num? shiftHours;
  final String weekOffDay;
  final num? weekOffPerMonth;
  final num? maxCL;
  final num? maxSL;
  final num? maxEL;
  final num? maxCompOff;
}

class Employee {
  const Employee({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.department,
    required this.employeeId,
    this.designation = '',
    this.employeeCode,
    this.firstName,
    this.lastName,
    this.phone,
    this.status,
    this.salaryPerMonth,
    this.basicPay = 0,
    this.hra = 0,
    this.conveyanceAllowance = 0,
    this.medicalAllowance = 0,
    this.performanceAllowance = 0,
    this.specialAllowance = 0,
    this.otherDeductions = 0,
    this.salaryIncrements = const [],
    this.joinDate,
    this.permissions = const [],
    this.latitude,
    this.longitude,
    this.address,
    this.lastLoginLocation,
    this.lastCheckInLocation,
    this.lastCheckOutLocation,
    this.isAllowedImageCapturedAttendance = false,
    this.info = const EmployeeProfileInfo(),
  });

  final String id;
  final String name;
  final String email;
  final String role;
  final String department;
  final String employeeId;
  final String designation;
  final String? employeeCode;
  final String? firstName;
  final String? lastName;
  final String? phone;
  final String? status;
  final double? salaryPerMonth;
  final double basicPay;
  final double hra;
  final double conveyanceAllowance;
  final double medicalAllowance;
  final double performanceAllowance;
  final double specialAllowance;
  final double otherDeductions;
  final List<SalaryIncrement> salaryIncrements;
  final DateTime? joinDate;
  final List<String> permissions;
  final double? latitude;
  final double? longitude;
  final String? address;
  final EmployeeLocation? lastLoginLocation;
  final EmployeeLocation? lastCheckInLocation;
  final EmployeeLocation? lastCheckOutLocation;
  final bool isAllowedImageCapturedAttendance;
  final EmployeeProfileInfo info;

  String get performanceCode {
    final code = employeeCode?.trim() ?? '';
    if (code.isNotEmpty) return code;
    return employeeId.trim();
  }

  String get displayName {
    final n = name.trim();
    if (n.isNotEmpty) return n;
    final parts = [firstName, lastName]
        .whereType<String>()
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    if (parts.isNotEmpty) return parts.join(' ');
    return email;
  }

  String get initials {
    final parts = displayName
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  String get avatarLetter {
    final n = displayName.trim();
    if (n.isEmpty) return '?';
    return n[0].toUpperCase();
  }

  String get joinDateShort {
    if (joinDate == null) return '—';
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
    final d = joinDate!;
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }

  String get joinDateLong {
    if (joinDate == null) return '—';
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
    final d = joinDate!;
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }

  String get salaryLabel {
    if (salaryPerMonth == null) return '—';
    final amount = salaryPerMonth!.round();
    final formatted = amount.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
    return '₹$formatted/mo';
  }

  String get statusLabel {
    final s = (status ?? 'active').trim();
    if (s.isEmpty) return 'ACTIVE';
    return s.toUpperCase();
  }

  bool get isActive => (status ?? 'active').toLowerCase() == 'active';
}
