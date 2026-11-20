import 'package:timelay_health/features/leaves/data/models/leave_record_model.dart';
import 'package:timelay_health/features/leaves/domain/entities/employee_leaves.dart';
import 'package:timelay_health/features/leaves/domain/entities/leave_record.dart';
import 'package:timelay_health/features/leaves/domain/entities/comp_off_request.dart';

class LeaveMapper {
  const LeaveMapper._();

  static LeaveRecord toEntity(LeaveRecordModel model) {
    return LeaveRecord(
      id: model.id,
      employeeId: model.employeeId,
      employeeName: model.employeeName,
      leaveType: model.leaveType,
      startDate: model.startDate,
      endDate: model.endDate,
      days: model.days,
      reason: model.reason,
      status: model.status,
      isConvertedToCompOff: model.isConvertedToCompOff,
      appliedDate: model.appliedDate,
      approvedBy: model.approvedBy,
      approvedByRole: model.approvedByRole,
      approvedDate: model.approvedDate,
    );
  }

  static EmployeeLeaves employeeLeavesToEntity(
    EmployeeLeavesResponseModel model,
  ) {
    final s = model.stats;
    return EmployeeLeaves(
      stats: LeaveStats(
        totalLeaves: s.totalLeaves,
        approvedLeaves: s.approvedLeaves,
        pendingLeaves: s.pendingLeaves,
        rejectedLeaves: s.rejectedLeaves,
        casualLeaves: s.casualLeaves,
        sickLeaves: s.sickLeaves,
        earnedLeaves: s.earnedLeaves,
        compOffLeaves: s.compOffLeaves,
        weekOffPerMonth: s.weekOffPerMonth,
        totalAssignedDays: s.totalAssignedDays,
        presentDays: s.presentDays,
        absentDays: s.absentDays,
        extraDaysWorked: s.extraDaysWorked,
      ),
      records: model.records.map(toEntity).toList(),
    );
  }

  static AddLeaveRequestModel toAddRequest(AddLeaveParams params) {
    return AddLeaveRequestModel(
      employeeId: params.employeeId,
      employeeName: params.employeeName,
      leaveType: params.leaveType,
      startDate: _apiDate(params.startDate),
      endDate: _apiDate(params.endDate),
      days: params.days,
      reason: params.reason,
    );
  }

  static List<ExtraWorkedDay> extraWorkedDaysToEntity(
    ExtraWorkedDaysResponseModel model,
  ) {
    return model.extraDays
        .where((d) => d.date != null)
        .map(
          (d) => ExtraWorkedDay(
            date: d.date!,
            dayLabel: d.dayLabel,
            workType: d.workType,
            totalHours: d.totalHours,
            requestStatus: d.requestStatus,
            isExpired: d.isExpired,
            validTillFormatted: d.validTillFormatted,
          ),
        )
        .toList();
  }

  static AddCompOffRequestModel toAddCompOffRequest(AddCompOffParams params) {
    return AddCompOffRequestModel(
      employeeId: params.employeeId,
      employeeName: params.employeeName,
      workDate: _apiDate(params.workDate),
      leaveDate: _apiDate(params.leaveDate),
      count: params.days,
      reason: params.reason,
      workType: params.workType,
      totalHours: params.totalHours,
    );
  }

  static CompOffRequests compOffRequestsToEntity(
    CompOffRequestsResponseModel model,
  ) {
    return CompOffRequests(
      totalCompOff: model.totalCompOff,
      usedCompOffCount: model.usedCompOffCount,
      remainingCompOffCount: model.remainingCompOffCount,
      status: model.status,
      records: model.records
          .map(
            (record) => CompOffRequest(
              id: record.id,
              workDate: record.workDate,
              leaveDate: record.leaveDate,
              workType: record.workType,
              totalHours: record.totalHours,
              days: record.count,
              reason: record.reason,
              status: record.status,
              approvedBy: record.approvedBy,
              requestedOn: record.createdAt,
            ),
          )
          .toList(),
    );
  }

  static String _apiDate(DateTime date) {
    final local = date.toLocal();
    final y = local.year.toString().padLeft(4, '0');
    final m = local.month.toString().padLeft(2, '0');
    final d = local.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}
