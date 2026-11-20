import 'package:timelay_health/features/admin/employees/data/datasources/employee_list_remote_datasource.dart';
import 'package:timelay_health/features/admin/leaves/data/datasources/admin_leave_remote_datasource.dart';
import 'package:timelay_health/features/admin/leaves/data/models/admin_leave_model.dart';
import 'package:timelay_health/features/admin/leaves/domain/repositories/admin_leave_repository.dart';
import 'package:timelay_health/features/admin/leaves/presentation/models/admin_leave_requests_ui.dart';

class AdminLeaveRepositoryImpl implements AdminLeaveRepository {
  AdminLeaveRepositoryImpl({
    AdminLeaveRemoteDataSource? remote,
    EmployeeListRemoteDataSource? employeeRemote,
  })  : _remote = remote ?? AdminLeaveRemoteDataSource(),
        _employeeRemote = employeeRemote ?? EmployeeListRemoteDataSource();

  final AdminLeaveRemoteDataSource _remote;
  final EmployeeListRemoteDataSource _employeeRemote;

  static const List<String> _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  static String _extractInitials(String name) {
    final clean = name.trim();
    if (clean.isEmpty) return 'NA';
    final parts = clean
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    if (clean.length >= 2) {
      return clean.substring(0, 2).toUpperCase();
    }
    return clean[0].toUpperCase();
  }

  static String _formatDmy(String? raw) {
    if (raw == null || raw.trim().isEmpty) return '-';
    final str = raw.trim();
    final dt = DateTime.tryParse(str)?.toLocal();
    if (dt != null) {
      final d = dt.day.toString().padLeft(2, '0');
      final m = dt.month.toString().padLeft(2, '0');
      return '$d/$m/${dt.year}';
    }
    final parts = str.split('-');
    if (parts.length == 3) {
      final y = parts[0];
      final m = parts[1].padLeft(2, '0');
      final d = parts[2].split('T')[0].padLeft(2, '0');
      return '$d/$m/$y';
    }
    return str;
  }

  static String _formatTimestamp(String? raw) {
    if (raw == null || raw.trim().isEmpty) return '';
    final dt = DateTime.tryParse(raw.trim())?.toLocal();
    if (dt == null) return '';
    final d = dt.day.toString().padLeft(2, '0');
    final mStr = _months[dt.month - 1];
    final y = dt.year;
    final hour = dt.hour;
    final minute = dt.minute.toString().padLeft(2, '0');
    final ampm = hour >= 12 ? 'pm' : 'am';
    final h12 = hour % 12 == 0 ? 12 : hour % 12;
    final hStr = h12.toString().padLeft(2, '0');
    return '$d $mStr $y, $hStr:$minute $ampm';
  }

  static String _formatAppliedText(String? raw) {
    if (raw == null || raw.trim().isEmpty) {
      return 'Applied: Awaiting Manager Review';
    }
    final dt = DateTime.tryParse(raw.trim())?.toLocal();
    if (dt == null) return 'Applied: Awaiting Manager Review';
    final d = dt.day.toString().padLeft(2, '0');
    final mStr = _months[dt.month - 1];
    final y = dt.year;
    return 'Applied on $d $mStr $y';
  }

  static String _formatStatus(String status) {
    final lower = status.trim().toLowerCase().replaceAll('_', ' ').trim();
    if (lower.isEmpty) return 'Pending';
    if (lower.contains('approv')) return 'Approved';
    if (lower.contains('reject')) return 'Rejected';
    if (lower.contains('pending') || lower.contains('await')) {
      return 'Pending';
    }
    return lower[0].toUpperCase() + lower.substring(1);
  }

  static String _formatLeaveType(String type) {
    final clean = type.trim();
    if (clean.isEmpty) return 'Leave';
    if (clean.toLowerCase() == 'sick') return 'Sick Leave';
    if (clean.toLowerCase() == 'casual' || clean.toLowerCase() == 'casual leave') {
      return 'Casual Leave';
    }
    if (clean.toLowerCase() == 'comp off' || clean.toLowerCase() == 'compoff') {
      return 'Comp Off';
    }
    if (clean.toLowerCase() == 'earned') return 'Earned Leave';
    return clean[0].toUpperCase() + clean.substring(1);
  }

  Future<Map<String, Map<String, dynamic>>> _getEmployeeMap() async {
    try {
      final list = await _employeeRemote.getEmployees();
      final map = <String, Map<String, dynamic>>{};
      for (final e in list) {
        final id = (e['employeeId'] ?? e['id'] ?? '').toString().trim();
        if (id.isNotEmpty) {
          map[id.toLowerCase()] = e;
        }
      }
      return map;
    } catch (_) {
      return const {};
    }
  }

  @override
  Future<AdminLeaveRequestsUi> getLeaveRequests() async {
    final models = await _remote.getLeaves();
    final empMap = await _getEmployeeMap();

    final records = <AdminLeaveItem>[];
    final deptSet = <String>{};
    final desigSet = <String>{};

    for (final m in models) {
      final empInfo = empMap[m.employeeId.toLowerCase()];

      final name = m.employeeName.isNotEmpty
          ? m.employeeName
          : (empInfo?['name'] ?? empInfo?['employeeName'] ?? 'Employee').toString();

      final dept = (m.department != null && m.department!.isNotEmpty)
          ? m.department!
          : (empInfo?['department'] ?? 'Operations').toString();

      final desig = (m.designation != null && m.designation!.isNotEmpty)
          ? m.designation!
          : (empInfo?['designation'] ?? 'Staff').toString();

      if (dept.isNotEmpty) deptSet.add(dept);
      if (desig.isNotEmpty) desigSet.add(desig);

      final daysVal = m.days <= 0 ? 1.0 : m.days;
      final daysDisplay = daysVal.toInt() == daysVal
          ? daysVal.toInt().toString()
          : daysVal.toStringAsFixed(1);
      final durationText = daysVal <= 1 ? '$daysDisplay Day' : '$daysDisplay Days';

      final status = _formatStatus(m.status);
      final fromDate = _formatDmy(m.startDate);
      final toDate = _formatDmy(m.endDate);

      final timestamp = _formatTimestamp(m.approvedDate ?? m.updatedAt);
      final appliedText = _formatAppliedText(m.appliedDate ?? m.createdAt);

      records.add(
        AdminLeaveItem(
          id: m.id,
          name: name,
          employeeCode: m.employeeId.isNotEmpty ? m.employeeId : 'EMP',
          designation: desig,
          department: dept,
          initials: _extractInitials(name),
          status: status,
          fromDate: fromDate,
          toDate: toDate,
          durationText: durationText,
          reason: m.reason.isNotEmpty ? m.reason : 'Personal reason',
          approver: m.approvedBy?.isNotEmpty == true
              ? m.approvedBy!
              : (status == 'Approved' ? 'Admin' : ''),
          timestamp: timestamp,
          appliedText: appliedText,
          leaveType: _formatLeaveType(m.leaveType),
          isConvertedToCompOff: m.isConvertedToCompOff,
        ),
      );
    }

    final totalCount = records.length;
    final pendingCount = records.where((r) => r.isPending).length;
    final approvedCount = records.where((r) => r.isApproved).length;
    final rejectedCount = records.where((r) => r.isRejected).length;

    return AdminLeaveRequestsUi(
      totalLeaves: totalCount,
      pendingLeaves: pendingCount,
      approvedLeaves: approvedCount,
      rejectedLeaves: rejectedCount,
      records: records,
      departments: deptSet.toList()..sort(),
      designations: desigSet.toList()..sort(),
    );
  }

  @override
  Future<void> updateLeaveStatus({
    required String id,
    required String status,
    required String adminName,
    required String adminEmail,
    required String adminRole,
    required String actionAt,
  }) {
    return _remote.updateLeave(
      id: id,
      status: status,
      adminName: adminName,
      adminEmail: adminEmail,
      adminRole: adminRole,
      actionAt: actionAt,
    );
  }
}
