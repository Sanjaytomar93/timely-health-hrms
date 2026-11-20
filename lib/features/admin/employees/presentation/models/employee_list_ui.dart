import 'package:flutter/material.dart';

class EmployeeListStats {
  const EmployeeListStats({
    required this.total,
    required this.active,
    required this.inactive,
    required this.departments,
    required this.workLocations,
  });

  final int total;
  final int active;
  final int inactive;
  final int departments;
  final int workLocations;

  static const empty = EmployeeListStats(
    total: 0,
    active: 0,
    inactive: 0,
    departments: 0,
    workLocations: 0,
  );

  factory EmployeeListStats.fromApi({
    Map<String, dynamic>? statsJson,
    required int fallbackTotal,
    required int fallbackActive,
    required int fallbackInactive,
    required int fallbackDepts,
    required int fallbackLocations,
  }) {
    if (statsJson != null) {
      return EmployeeListStats(
        total: (statsJson['totalEmployees'] as num?)?.toInt() ?? fallbackTotal,
        active:
            (statsJson['activeEmployees'] as num?)?.toInt() ?? fallbackActive,
        inactive: (statsJson['inactiveEmployees'] as num?)?.toInt() ??
            fallbackInactive,
        departments: (statsJson['totalDepartments'] as num?)?.toInt() ??
            fallbackDepts,
        workLocations: (statsJson['totalWorkLocations'] as num?)?.toInt() ??
            fallbackLocations,
      );
    }
    return EmployeeListStats(
      total: fallbackTotal,
      active: fallbackActive,
      inactive: fallbackInactive,
      departments: fallbackDepts,
      workLocations: fallbackLocations,
    );
  }
}

class EmployeeListItem {
  const EmployeeListItem({
    required this.name,
    required this.employeeId,
    required this.status,
    required this.role,
    required this.department,
    required this.phone,
    required this.salary,
    required this.shiftOff,
    required this.joiningDate,
    required this.location,
    required this.trackingId,
    required this.avatarColor,
    this.email = '',
    this.profileImageUrl = '',
    this.employmentType = '',
    this.gender = '',
    this.dob = '',
    this.address = '',
    this.lastCheckInAddress = '',
    this.lastCheckInTime = '',
    this.lastCheckOutAddress = '',
    this.lastCheckOutTime = '',
  });

  final String name;
  final String employeeId;
  final String status;
  final String role;
  final String department;
  final String phone;
  final String salary;
  final String shiftOff;
  final String joiningDate;
  final String location;
  final String trackingId;
  final Color avatarColor;
  final String email;
  final String profileImageUrl;
  final String employmentType;
  final String gender;
  final String dob;
  final String address;
  final String lastCheckInAddress;
  final String lastCheckInTime;
  final String lastCheckOutAddress;
  final String lastCheckOutTime;

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      final s = parts.first;
      return (s.length >= 2 ? s.substring(0, 2) : s).toUpperCase();
    }
    return ('${parts.first[0]}${parts.last[0]}').toUpperCase();
  }

  static Color colorFor(String seed) {
    const palette = <Color>[
      Color(0xFF7C6FD6),
      Color(0xFFE07A9A),
      Color(0xFF4DB6A0),
      Color(0xFF5B8DEF),
      Color(0xFFD4A017),
      Color(0xFF9B6B9E),
      Color(0xFF3D8B8B),
      Color(0xFF6C7AE0),
      Color(0xFFE67E22),
      Color(0xFF2E7D32),
      Color(0xFF8E44AD),
      Color(0xFF16A085),
    ];
    if (seed.isEmpty) return palette.first;
    return palette[seed.hashCode.abs() % palette.length];
  }

  static String formatCurrency(num? value) {
    if (value == null || value <= 0) return '₹0';
    final rounded = value.round();
    final s = rounded.toString();
    if (s.length <= 3) return '₹$s';
    final last3 = s.substring(s.length - 3);
    var remaining = s.substring(0, s.length - 3);
    final parts = <String>[];
    while (remaining.length > 2) {
      parts.insert(0, remaining.substring(remaining.length - 2));
      remaining = remaining.substring(0, remaining.length - 2);
    }
    if (remaining.isNotEmpty) {
      parts.insert(0, remaining);
    }
    return '₹${parts.join(',')},$last3';
  }

  static String formatJoinDate(dynamic raw) {
    if (raw == null) return 'N/A';
    final dt = DateTime.tryParse(raw.toString());
    if (dt == null) return 'N/A';
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final day = dt.day.toString().padLeft(2, '0');
    final mon = months[dt.month - 1];
    return '$day $mon ${dt.year}';
  }

  factory EmployeeListItem.fromJson(Map<String, dynamic> json) {
    final name = (json['name'] ?? '').toString().trim();
    final employeeId = (json['employeeId'] ?? '').toString().trim();
    final rawStatus = (json['status'] ?? '').toString().trim().toUpperCase();
    final status = rawStatus == 'ACTIVE' ? 'ACTIVE' : 'INACTIVE';

    final role = (json['role'] ?? json['designation'] ?? 'Staff')
        .toString()
        .trim();
    final department = (json['department'] ?? 'General').toString().trim();
    final phone = (json['phone'] ?? '').toString().trim();

    num? salNum = json['salaryPerMonth'] as num?;
    if (salNum == null || salNum == 0) {
      salNum = json['basicPay'] as num?;
    }
    final salary = formatCurrency(salNum);

    final shiftType = (json['shiftType'] ?? '').toString().trim();
    final shiftHours = json['shiftHours'] as num?;
    final weekOff = (json['weekOffPerMonth'] ?? json['weekOffCount']) as num?;

    final shiftParts = <String>[];
    if (shiftType.isNotEmpty) {
      var s = 'Shift $shiftType';
      if (shiftHours != null && shiftHours > 0) {
        final h = shiftHours == shiftHours.roundToDouble()
            ? '${shiftHours.toInt()}h'
            : '${shiftHours}h';
        s += ' ($h)';
      }
      shiftParts.add(s);
    } else if (shiftHours != null && shiftHours > 0) {
      final h = shiftHours == shiftHours.roundToDouble()
          ? '${shiftHours.toInt()}h'
          : '${shiftHours}h';
      shiftParts.add('Shift ($h)');
    }
    if (weekOff != null && weekOff > 0) {
      shiftParts.add('${weekOff.toInt()} Off');
    }
    final shiftOff =
        shiftParts.isEmpty ? 'Not assigned' : shiftParts.join(' • ');

    final joiningDate = formatJoinDate(json['joinDate']);

    final city = (json['city'] ?? '').toString().trim();
    final addressLine1 = (json['addressLine1'] ?? '').toString().trim();
    final branch = (json['branch'] ?? '').toString().trim();
    final address = (json['address'] ?? '').toString().trim();

    String locName = 'TH, Corporate';
    if (branch.isNotEmpty) {
      locName = branch;
    } else if (city.isNotEmpty) {
      locName = city;
    } else if (addressLine1.isNotEmpty) {
      locName = addressLine1;
    } else if (address.isNotEmpty) {
      locName = address.length > 30 ? address.substring(0, 30) : address;
    }

    final id = (json['_id'] ?? json['id'] ?? '').toString().trim();
    final explicitTracking = (json['trackingId'] ?? '').toString().trim();
    final trackingId = explicitTracking.isNotEmpty
        ? explicitTracking
        : (id.length >= 4
            ? 'T-${id.substring(id.length - 4).toUpperCase()}'
            : (employeeId.isNotEmpty ? 'T-$employeeId' : 'T-0000'));

    final avatarColor = colorFor(id.isNotEmpty ? id : name);

    final rawProfile = (json['profileImage'] ?? '').toString().trim();
    String profileImageUrl = '';
    if (rawProfile.isNotEmpty && rawProfile != 'null') {
      if (rawProfile.startsWith('http')) {
        profileImageUrl = rawProfile;
      } else {
        final clean =
            rawProfile.startsWith('/') ? rawProfile.substring(1) : rawProfile;
        profileImageUrl = 'https://api.timelyhealth.in/$clean';
      }
    }

    final email = (json['email'] ?? '').toString().trim();
    final employmentType = (json['employmentType'] ?? '').toString().trim();
    final gender = (json['gender'] ?? '').toString().trim();
    final dob = formatJoinDate(json['dob']);

    String checkInAddr = '';
    String checkInTime = '';
    if (json['lastCheckInLocation'] is Map) {
      final loc = json['lastCheckInLocation'] as Map;
      checkInAddr = (loc['address'] ?? '').toString().trim();
      checkInTime = (loc['timestamp'] ?? '').toString().trim();
    }

    String checkOutAddr = '';
    String checkOutTime = '';
    if (json['lastCheckOutLocation'] is Map) {
      final loc = json['lastCheckOutLocation'] as Map;
      checkOutAddr = (loc['address'] ?? '').toString().trim();
      checkOutTime = (loc['timestamp'] ?? '').toString().trim();
    }

    return EmployeeListItem(
      name: name.isEmpty ? 'Unnamed Employee' : name,
      employeeId: employeeId.isEmpty ? 'N/A' : employeeId,
      status: status,
      role: role.isEmpty ? 'Staff' : role,
      department: department.isEmpty ? 'General' : department,
      phone: phone.isEmpty ? 'N/A' : phone,
      salary: salary,
      shiftOff: shiftOff,
      joiningDate: joiningDate,
      location: locName,
      trackingId: trackingId,
      avatarColor: avatarColor,
      email: email,
      profileImageUrl: profileImageUrl,
      employmentType: employmentType,
      gender: gender,
      dob: dob,
      address: address,
      lastCheckInAddress: checkInAddr,
      lastCheckInTime: checkInTime,
      lastCheckOutAddress: checkOutAddr,
      lastCheckOutTime: checkOutTime,
    );
  }
}

class EmployeeListUi {
  const EmployeeListUi({
    required this.stats,
    required this.employees,
  });

  final EmployeeListStats stats;
  final List<EmployeeListItem> employees;

  static const empty = EmployeeListUi(
    stats: EmployeeListStats.empty,
    employees: [],
  );

  factory EmployeeListUi.fromApiList(
    List<Map<String, dynamic>> rawList, {
    Map<String, dynamic>? statsJson,
  }) {
    final items = <EmployeeListItem>[];
    int active = 0;
    int inactive = 0;
    final departments = <String>{};
    final locations = <String>{};

    for (final raw in rawList) {
      final item = EmployeeListItem.fromJson(raw);
      items.add(item);

      if (item.status == 'ACTIVE') {
        active++;
      } else {
        inactive++;
      }

      if (item.department.isNotEmpty && item.department != 'General') {
        departments.add(item.department);
      }
      if (item.location.isNotEmpty) {
        locations.add(item.location);
      }
    }

    final stats = EmployeeListStats.fromApi(
      statsJson: statsJson,
      fallbackTotal: items.length,
      fallbackActive: active,
      fallbackInactive: inactive,
      fallbackDepts: departments.length,
      fallbackLocations: locations.length,
    );

    return EmployeeListUi(
      stats: stats,
      employees: items,
    );
  }

  static EmployeeListUi sample() {
    return const EmployeeListUi(
      stats: EmployeeListStats(
        total: 65,
        active: 25,
        inactive: 40,
        departments: 9,
        workLocations: 5,
      ),
      employees: [
        EmployeeListItem(
          name: 'Aarif',
          employeeId: 'T1158',
          status: 'ACTIVE',
          role: 'Pharmacist',
          department: 'Medical',
          phone: '7505057505',
          salary: '₹35,000',
          shiftOff: 'Shift H (6h) • 4 Off',
          joiningDate: '18 Aug 2023',
          location: 'TII, Corporate',
          trackingId: 'T-1120',
          avatarColor: Color(0xFF7C6FD6),
        ),
        EmployeeListItem(
          name: 'Chitikela Swathi',
          employeeId: 'T1189',
          status: 'ACTIVE',
          role: 'Pharmacist',
          department: 'Medical',
          phone: '8522949491',
          salary: '₹35,000',
          shiftOff: 'Shift A (8.5h) • 4 Off',
          joiningDate: '26 Dec 2023',
          location: 'TII, Corporate',
          trackingId: 'T-1151',
          avatarColor: Color(0xFFE07A9A),
        ),
        EmployeeListItem(
          name: 'Dharmendra Goyal',
          employeeId: 'T1122',
          status: 'ACTIVE',
          role: 'Pharmacist',
          department: 'Medical',
          phone: '9876543210',
          salary: '₹42,000',
          shiftOff: 'Shift B (8h) • 2 Off',
          joiningDate: '10 Jan 2022',
          location: 'TII, Corporate',
          trackingId: 'T-1088',
          avatarColor: Color(0xFF4DB6A0),
        ),
        EmployeeListItem(
          name: 'Farheen Khan',
          employeeId: 'T1201',
          status: 'INACTIVE',
          role: 'Staff Nurse',
          department: 'Nursing',
          phone: '9811122233',
          salary: '₹28,000',
          shiftOff: 'Shift C (9h) • 4 Off',
          joiningDate: '05 Mar 2024',
          location: 'TII, Clinic',
          trackingId: 'T-1190',
          avatarColor: Color(0xFF5B8DEF),
        ),
        EmployeeListItem(
          name: 'Imran Sheikh',
          employeeId: 'T1098',
          status: 'INACTIVE',
          role: 'HR Manager',
          department: 'Management',
          phone: '9998887776',
          salary: '₹45,000',
          shiftOff: 'Shift A (8.5h) • 2 Off',
          joiningDate: '14 Jul 2021',
          location: 'TII, Corporate',
          trackingId: 'T-1012',
          avatarColor: Color(0xFFD4A017),
        ),
        EmployeeListItem(
          name: 'Neha Verma',
          employeeId: 'T1215',
          status: 'INACTIVE',
          role: 'Sales Executive',
          department: 'Sales',
          phone: '9700011223',
          salary: '₹32,000',
          shiftOff: 'Shift H (6h) • 4 Off',
          joiningDate: '22 Sep 2024',
          location: 'TII, Field',
          trackingId: 'T-1204',
          avatarColor: Color(0xFF9B6B9E),
        ),
        EmployeeListItem(
          name: 'Rahul Mehta',
          employeeId: 'T1140',
          status: 'ACTIVE',
          role: 'Doctor',
          department: 'Medical',
          phone: '9123456780',
          salary: '₹85,000',
          shiftOff: 'Shift B (8h) • 4 Off',
          joiningDate: '01 Feb 2020',
          location: 'TII, Clinic',
          trackingId: 'T-1055',
          avatarColor: Color(0xFF3D8B8B),
        ),
        EmployeeListItem(
          name: 'Sana Parveen',
          employeeId: 'T1177',
          status: 'ACTIVE',
          role: 'Marketing',
          department: 'Marketing',
          phone: '9345678901',
          salary: '₹22,000',
          shiftOff: 'Shift A (8.5h) • 4 Off',
          joiningDate: '11 Nov 2023',
          location: 'TII, Corporate',
          trackingId: 'T-1133',
          avatarColor: Color(0xFF6C7AE0),
        ),
      ],
    );
  }
}
