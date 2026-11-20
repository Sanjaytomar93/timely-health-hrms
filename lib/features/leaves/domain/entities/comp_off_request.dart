class ExtraWorkedDay {
  const ExtraWorkedDay({
    required this.date,
    required this.dayLabel,
    required this.workType,
    required this.totalHours,
    required this.requestStatus,
    required this.isExpired,
    this.validTillFormatted,
  });

  final DateTime date;
  final String dayLabel;
  final String workType;
  final double totalHours;
  final String requestStatus;
  final bool isExpired;
  final String? validTillFormatted;

  bool get isAvailable =>
      !isExpired && requestStatus.toLowerCase() == 'available';
}

class AddCompOffParams {
  const AddCompOffParams({
    required this.employeeId,
    required this.employeeName,
    required this.workDate,
    required this.leaveDate,
    required this.days,
    required this.reason,
    this.workType,
    this.totalHours,
  });

  final String employeeId;
  final String employeeName;
  final DateTime workDate;
  final DateTime leaveDate;
  final int days;
  final String reason;
  final String? workType;
  final double? totalHours;
}

class CompOffRequest {
  const CompOffRequest({
    required this.id,
    required this.reason,
    required this.days,
    required this.status,
    this.workDate,
    this.leaveDate,
    this.workType,
    this.totalHours,
    this.approvedBy,
    this.requestedOn,
  });

  final String id;
  final DateTime? workDate;
  final DateTime? leaveDate;
  final String? workType;
  final double? totalHours;
  final double days;
  final String reason;
  final String status;
  final String? approvedBy;
  final DateTime? requestedOn;
}

class CompOffRequests {
  const CompOffRequests({
    required this.totalCompOff,
    required this.usedCompOffCount,
    required this.remainingCompOffCount,
    required this.status,
    required this.records,
  });

  static const empty = CompOffRequests(
    totalCompOff: 0,
    usedCompOffCount: 0,
    remainingCompOffCount: 0,
    status: '',
    records: [],
  );

  final int totalCompOff;
  final int usedCompOffCount;
  final int remainingCompOffCount;
  final String status;
  final List<CompOffRequest> records;
}
