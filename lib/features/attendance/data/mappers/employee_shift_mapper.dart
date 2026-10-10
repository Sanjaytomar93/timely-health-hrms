import 'package:timelay_health/features/attendance/data/models/employee_shift_model.dart';
import 'package:timelay_health/features/attendance/domain/entities/employee_shift.dart';

class EmployeeShiftMapper {
  const EmployeeShiftMapper._();

  static EmployeeShift toEntity(EmployeeShiftModel model) {
    final change = model.scheduledChange;
    return EmployeeShift(
      id: model.id,
      shiftType: model.shiftType,
      shiftName: model.shiftName,
      shiftCategory: model.shiftCategory,
      isBrakeShift: model.isBrakeShift,
      isAssigned: model.isAssigned,
      startTime: model.startTime,
      endTime: model.endTime,
      timeRange: model.timeRange,
      description: model.description,
      assignedDate: model.assignedDate,
      effectiveFrom: model.effectiveFrom,
      scheduledChange: change == null
          ? null
          : ScheduledShiftChange(
              shiftType: change.shiftType,
              shiftName: change.shiftName,
              timeRange: change.timeRange,
              effectiveFrom: change.effectiveFrom,
            ),
    );
  }
}
