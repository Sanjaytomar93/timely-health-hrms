class EmployeePayrollStats {
  const EmployeePayrollStats({
    required this.totalEmployees,
    required this.activeEmployees,
    required this.inactiveEmployees,
    required this.totalAssignedSalary,
    required this.totalNetPay,
  });

  final int totalEmployees;
  final int activeEmployees;
  final int inactiveEmployees;
  final String totalAssignedSalary;
  final String totalNetPay;

  static const empty = EmployeePayrollStats(
    totalEmployees: 0,
    activeEmployees: 0,
    inactiveEmployees: 0,
    totalAssignedSalary: '₹0',
    totalNetPay: '₹0',
  );
}

class EmployeePayrollUi {
  const EmployeePayrollUi({
    required this.records,
    required this.stats,
    required this.departments,
    required this.designations,
    this.month = '',
  });

  final List<EmployeePayrollItem> records;
  final EmployeePayrollStats stats;
  final List<String> departments;
  final List<String> designations;
  final String month;

  static const empty = EmployeePayrollUi(
    records: [],
    stats: EmployeePayrollStats.empty,
    departments: ['All Departments'],
    designations: ['All Designations'],
  );

  factory EmployeePayrollUi.fromBulkPayrollJson(Map<String, dynamic> json) {
    final data = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : const <String, dynamic>{};

    final employees = data['employees'] is List
        ? data['employees'] as List
        : const [];
    final summaryMap = data['summaryMap'] is Map
        ? Map<String, dynamic>.from(data['summaryMap'] as Map)
        : const <String, dynamic>{};
    final weekOffMap = data['weekOffDatesMap'] is Map
        ? Map<String, dynamic>.from(data['weekOffDatesMap'] as Map)
        : const <String, dynamic>{};
    final compOffsMap = data['compOffsByEmployee'] is Map
        ? Map<String, dynamic>.from(data['compOffsByEmployee'] as Map)
        : const <String, dynamic>{};

    final cards = json['cards'] is Map<String, dynamic>
        ? json['cards'] as Map<String, dynamic>
        : const <String, dynamic>{};
    final payrollPage = cards['payrollPage'] is Map<String, dynamic>
        ? cards['payrollPage'] as Map<String, dynamic>
        : const <String, dynamic>{};

    final records = <EmployeePayrollItem>[];
    final deptSet = <String>{};
    final desigSet = <String>{};

    for (final raw in employees) {
      if (raw is! Map) continue;
      final emp = Map<String, dynamic>.from(raw);
      final code = (emp['employeeId'] ?? '').toString().trim();
      if (code.isEmpty) continue;

      final summary = summaryMap[code] is Map
          ? Map<String, dynamic>.from(summaryMap[code] as Map)
          : const <String, dynamic>{};

      final weekOffs = weekOffMap[code] is List
          ? (weekOffMap[code] as List)
              .map((e) => e.toString())
              .where((e) => e.isNotEmpty)
              .toList()
          : const <String>[];

      final compOffs = compOffsMap[code] is List
          ? (compOffsMap[code] as List)
              .whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e))
              .toList()
          : const <Map<String, dynamic>>[];

      final item = EmployeePayrollItem.fromApi(
        employee: emp,
        summary: summary,
        weekOffDates: weekOffs,
        compOffs: compOffs,
      );
      records.add(item);

      if (item.department.isNotEmpty) deptSet.add(item.department);
      if (item.designation.isNotEmpty) desigSet.add(item.designation);
    }

    final depts = deptSet.toList()..sort();
    final desigs = desigSet.toList()..sort();

    final totalEmployees =
        (payrollPage['totalEmployees'] as num?)?.toInt() ?? records.length;
    final activeEmployees = (payrollPage['activeEmployees'] as num?)?.toInt() ??
        records.where((e) => e.isActive).length;
    final inactiveEmployees =
        (payrollPage['inactiveEmployees'] as num?)?.toInt() ??
            records.where((e) => !e.isActive).length;

    return EmployeePayrollUi(
      records: records,
      stats: EmployeePayrollStats(
        totalEmployees: totalEmployees,
        activeEmployees: activeEmployees,
        inactiveEmployees: inactiveEmployees,
        totalAssignedSalary: EmployeePayrollItem.formatInr(
          (payrollPage['totalAssignedSalary'] as num?)?.toDouble() ?? 0,
        ),
        totalNetPay: EmployeePayrollItem.formatInr(
          (payrollPage['totalNetPay'] as num?)?.toDouble() ?? 0,
        ),
      ),
      departments: ['All Departments', ...depts],
      designations: ['All Designations', ...desigs],
      month: (json['month'] ?? '').toString(),
    );
  }
}

class EmployeePayrollItem {
  const EmployeePayrollItem({
    required this.id,
    required this.name,
    required this.code,
    required this.designation,
    required this.department,
    required this.initials,
    required this.status,
    required this.presentDays,
    required this.halfDays,
    required this.otHours,
    required this.paidDays,
    this.compOffs = '',
    required this.woDates,
    required this.actSal,
    required this.calcSal,
    required this.holdText,
    required this.netPay,
    this.hasAmberAccent = false,
  });

  final String id;
  final String name;
  final String code;
  final String designation;
  final String department;
  final String initials;
  final String status;
  final int presentDays;
  final double halfDays;
  final String otHours;
  final int paidDays;
  final String compOffs;
  final String woDates;
  final String actSal;
  final String calcSal;
  final String holdText;
  final String netPay;
  final bool hasAmberAccent;

  bool get isActive => status.toUpperCase() == 'ACTIVE';

  factory EmployeePayrollItem.fromApi({
    required Map<String, dynamic> employee,
    required Map<String, dynamic> summary,
    required List<String> weekOffDates,
    required List<Map<String, dynamic>> compOffs,
  }) {
    final code = (employee['employeeId'] ?? '').toString().trim();
    final name = (employee['name'] ?? '').toString().trim();
    final designation =
        (employee['designation'] ?? employee['role'] ?? '').toString().trim();
    final department = (employee['department'] ?? '').toString().trim();
    final statusRaw = (employee['status'] ?? 'inactive').toString().trim();
    final status =
        statusRaw.toLowerCase() == 'active' ? 'ACTIVE' : 'INACTIVE';

    final presentDays = (summary['presentDays'] as num?)?.toInt() ?? 0;
    final halfDays =
        (summary['halfDayWorking'] as num?)?.toDouble() ?? 0;
    final ot = (summary['overTimeHours'] as num?)?.toDouble() ?? 0;
    final paidDays = ((summary['totalWorkingDays'] as num?)?.toDouble() ?? 0)
        .round();

    final salary = (summary['salaryPerMonthSnapshot'] as num?)?.toDouble() ??
        (employee['salaryPerMonth'] as num?)?.toDouble() ??
        0;
    final calc = (summary['calculatedSalary'] as num?)?.toDouble() ?? 0;

    final paymentStatus =
        (summary['paymentStatus'] ?? employee['paymentStatus'] ?? 'Pending')
            .toString()
            .trim();
    final holdText = paymentStatus.toLowerCase() == 'pending'
        ? (calc > 0 ? '+Add' : '-')
        : paymentStatus;

    final compLabel = compOffs
        .map((e) {
          final leaveDate = (e['leaveDate'] ?? '').toString();
          if (leaveDate.length >= 10) {
            return leaveDate.substring(8, 10).replaceFirst(RegExp(r'^0'), '');
          }
          return '';
        })
        .where((e) => e.isNotEmpty)
        .join(', ');

    return EmployeePayrollItem(
      id: (employee['_id'] ?? code).toString(),
      name: name.isEmpty ? 'Unnamed' : name,
      code: code,
      designation: designation.isEmpty ? '-' : designation,
      department: department.isEmpty ? '-' : department,
      initials: _initials(name),
      status: status,
      presentDays: presentDays,
      halfDays: halfDays,
      otHours: _otLabel(ot),
      paidDays: paidDays,
      compOffs: compLabel,
      woDates: _weekOffLabel(weekOffDates),
      actSal: formatInr(salary),
      calcSal: formatInr(calc),
      holdText: holdText,
      netPay: formatInr(calc),
      hasAmberAccent: status == 'INACTIVE' || calc <= 0,
    );
  }

  static String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) {
      final s = parts.first;
      return (s.length >= 2 ? s.substring(0, 2) : s).toUpperCase();
    }
    return ('${parts.first[0]}${parts.last[0]}').toUpperCase();
  }

  static String _otLabel(double hours) {
    if (hours <= 0) return '-';
    final whole = hours.truncate();
    final mins = ((hours - whole) * 60).round();
    if (mins == 0) return '+$whole h';
    return '+$whole h ${mins}m';
  }

  static String _weekOffLabel(List<String> dates) {
    if (dates.isEmpty) return '-';
    final days = dates.map((d) {
      if (d.length >= 10) {
        return d.substring(8, 10).replaceFirst(RegExp(r'^0'), '');
      }
      return d;
    }).where((e) => e.isNotEmpty);
    final joined = days.join(', ');
    return joined.isEmpty ? '-' : joined;
  }

  static String formatInr(double value) {
    final n = value.round();
    final western = _westernComma(n.abs());
    return n < 0 ? '-₹$western' : '₹$western';
  }

  static String _westernComma(int n) {
    final s = n.toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }
}
