class AbsentEmployeeItem {
  const AbsentEmployeeItem({
    required this.id,
    required this.name,
    required this.employeeId,
    required this.avatarLetter,
    required this.designation,
    required this.department,
    required this.dateLabel,
    this.leaveType = 'Full Day',
    this.status = 'ABSENT',
    this.photoUrl,
  });

  final String id;
  final String name;
  final String employeeId;
  final String avatarLetter;
  final String designation;
  final String department;
  final String dateLabel;
  final String leaveType;
  final String status;
  final String? photoUrl;

  static String? _resolveImageUrl(dynamic raw) {
    if (raw == null) return null;
    final str = raw.toString().trim();
    if (str.isEmpty || str == 'null') return null;
    if (str.startsWith('http://') || str.startsWith('https://')) {
      return str;
    }
    const baseUrl = 'https://api.timelyhealth.in';
    if (str.startsWith('/')) {
      return '$baseUrl$str';
    }
    return '$baseUrl/$str';
  }

  static String _formatCurrentDate() {
    final now = DateTime.now();
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${now.day} ${months[now.month - 1]} ${now.year}';
  }

  factory AbsentEmployeeItem.fromJson(
    Map<String, dynamic> json, {
    String? defaultDate,
  }) {
    final id = (json['_id'] ?? json['id'] ?? '').toString();
    final name = (json['name'] ?? json['employeeName'] ?? '').toString().trim();
    final employeeId = (json['employeeId'] ?? '').toString().trim();
    final department = (json['department'] ?? 'General').toString().trim();
    final designation =
        (json['role'] ?? json['designation'] ?? 'Staff').toString().trim();
    final leaveType = (json['leaveType'] ?? 'Full Day').toString().trim();
    final status = (json['status'] ?? 'ABSENT').toString().trim();
    final letter = name.isNotEmpty ? name[0].toUpperCase() : '?';

    final dateLabel = defaultDate ?? _formatCurrentDate();
    final photo = _resolveImageUrl(
      json['profilePicture'] ??
          json['employeeProfilePicture'] ??
          json['photo'] ??
          json['image'],
    );

    return AbsentEmployeeItem(
      id: id.isEmpty ? 'abs_${DateTime.now().microsecondsSinceEpoch}' : id,
      name: name.isEmpty ? 'Unknown Employee' : name,
      employeeId: employeeId.isEmpty ? 'N/A' : employeeId,
      avatarLetter: letter,
      designation: designation.isEmpty ? 'Staff' : designation,
      department: department.isEmpty ? 'General' : department,
      dateLabel: dateLabel,
      leaveType: leaveType.isEmpty ? 'Full Day' : leaveType,
      status: status.isEmpty ? 'ABSENT' : status,
      photoUrl: photo,
    );
  }
}

class AbsentTodayUi {
  const AbsentTodayUi({
    required this.totalAbsences,
    required this.filteredAbsences,
    required this.activeEmployees,
    required this.avgAbsentRate,
    this.onLeave = 0,
    required this.records,
    this.departments = const [],
    this.designations = const [],
  });

  final int totalAbsences;
  final int filteredAbsences;
  final int activeEmployees;
  final String avgAbsentRate;
  final int onLeave;
  final List<AbsentEmployeeItem> records;
  final List<String> departments;
  final List<String> designations;

  static const AbsentTodayUi empty = AbsentTodayUi(
    totalAbsences: 0,
    filteredAbsences: 0,
    activeEmployees: 0,
    avgAbsentRate: '0.0%',
    onLeave: 0,
    records: [],
  );

  AbsentTodayUi copyWith({
    int? totalAbsences,
    int? filteredAbsences,
    int? activeEmployees,
    String? avgAbsentRate,
    int? onLeave,
    List<AbsentEmployeeItem>? records,
    List<String>? departments,
    List<String>? designations,
  }) {
    return AbsentTodayUi(
      totalAbsences: totalAbsences ?? this.totalAbsences,
      filteredAbsences: filteredAbsences ?? this.filteredAbsences,
      activeEmployees: activeEmployees ?? this.activeEmployees,
      avgAbsentRate: avgAbsentRate ?? this.avgAbsentRate,
      onLeave: onLeave ?? this.onLeave,
      records: records ?? this.records,
      departments: departments ?? this.departments,
      designations: designations ?? this.designations,
    );
  }

  factory AbsentTodayUi.fromJson(
    Map<String, dynamic> json, {
    String? selectedDateString,
    int? totalStaffCount,
  }) {
    final rawRecords = json['records'];
    final List<AbsentEmployeeItem> items = [];
    final deptSet = <String>{};
    final designSet = <String>{};

    String dateLabel = '';
    if (selectedDateString != null && selectedDateString.isNotEmpty) {
      final parsed = DateTime.tryParse(selectedDateString)?.toLocal();
      if (parsed != null) {
        const months = [
          'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
          'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
        ];
        dateLabel = '${parsed.day} ${months[parsed.month - 1]} ${parsed.year}';
      }
    }

    if (rawRecords is List) {
      for (final r in rawRecords) {
        if (r is Map<String, dynamic>) {
          final item = AbsentEmployeeItem.fromJson(
            r,
            defaultDate: dateLabel.isNotEmpty ? dateLabel : null,
          );
          items.add(item);
          if (item.department.isNotEmpty && item.department != 'General') {
            deptSet.add(item.department);
          }
          if (item.designation.isNotEmpty && item.designation != 'Staff') {
            designSet.add(item.designation);
          }
        }
      }
    }

    final stats = json['stats'] is Map<String, dynamic>
        ? json['stats'] as Map<String, dynamic>
        : null;

    final total = stats != null && stats['totalAbsences'] != null
        ? (int.tryParse(stats['totalAbsences'].toString()) ?? items.length)
        : items.length;

    final filtered = stats != null && stats['filteredAbsences'] != null
        ? (int.tryParse(stats['filteredAbsences'].toString()) ?? items.length)
        : items.length;

    final active = stats != null && stats['activeEmployees'] != null
        ? (int.tryParse(stats['activeEmployees'].toString()) ??
            ((totalStaffCount ?? 26) - total).clamp(0, 9999))
        : ((totalStaffCount ?? 26) - total).clamp(0, 9999);

    final avgRate = stats != null && stats['avgAbsentRate'] != null
        ? stats['avgAbsentRate'].toString()
        : (active + total > 0
            ? '${((total / (active + total)) * 100).toStringAsFixed(1)}%'
            : '0.0%');

    final onLeaveCount = items
        .where((i) => i.leaveType.toLowerCase().contains('leave'))
        .length;

    final depts = deptSet.toList()..sort();
    final designs = designSet.toList()..sort();

    return AbsentTodayUi(
      totalAbsences: total,
      filteredAbsences: filtered,
      activeEmployees: active,
      avgAbsentRate: avgRate,
      onLeave: onLeaveCount,
      records: items,
      departments: depts,
      designations: designs,
    );
  }
}
