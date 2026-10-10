import 'package:timelay_health/features/auth/data/models/employee_model.dart';
import 'package:timelay_health/features/auth/domain/entities/employee.dart';

class EmployeeMapper {
  const EmployeeMapper._();

  static Employee toEntity(EmployeeModel model) {
    return Employee(
      id: model.id,
      name: model.name,
      email: model.email,
      role: model.role,
      department: model.department,
      employeeId: model.employeeId,
      designation: model.designation,
      employeeCode: model.employeeCode,
      firstName: model.firstName,
      lastName: model.lastName,
      phone: model.phone,
      status: model.status,
      salaryPerMonth: model.salaryPerMonth,
      basicPay: model.basicPay,
      hra: model.hra,
      conveyanceAllowance: model.conveyanceAllowance,
      medicalAllowance: model.medicalAllowance,
      performanceAllowance: model.performanceAllowance,
      specialAllowance: model.specialAllowance,
      otherDeductions: model.otherDeductions,
      salaryIncrements: model.salaryIncrements
          .map(
            (item) => SalaryIncrement(
              incrementType: item.incrementType,
              incrementValue: item.incrementValue,
              oldSalaryPerMonth: item.oldSalaryPerMonth,
              newSalaryPerMonth: item.newSalaryPerMonth,
              effectiveFrom: item.effectiveFrom,
              reason: item.reason,
            ),
          )
          .toList(),
      joinDate: model.joinDate,
      permissions: model.permissions,
      latitude: model.latitude,
      longitude: model.longitude,
      address: model.address,
      lastLoginLocation: _locToEntity(model.lastLoginLocation),
      lastCheckInLocation: _locToEntity(model.lastCheckInLocation),
      lastCheckOutLocation: _locToEntity(model.lastCheckOutLocation),
      isAllowedImageCapturedAttendance: model.isAllowedImageCapturedAttendance,
      info: _infoToEntity(model.info),
    );
  }

  static EmployeeProfileInfo _infoToEntity(EmployeeProfileInfoModel m) {
    return EmployeeProfileInfo(
      alternateNumber: m.alternateNumber,
      parentsName: m.parentsName,
      gender: m.gender,
      dob: m.dob,
      addressLine1: m.addressLine1,
      addressLine2: m.addressLine2,
      city: m.city,
      state: m.state,
      pinCode: m.pinCode,
      country: m.country,
      workLocation: m.workLocation,
      employmentType: m.employmentType,
      reportingManager: m.reportingManager,
      bankName: m.bankName,
      bankAccountNo: m.bankAccountNo,
      ifscCode: m.ifscCode,
      panNumber: m.panNumber,
      aadharNumber: m.aadharNumber,
      uanNumber: m.uanNumber,
      pfNumber: m.pfNumber,
      esicNumber: m.esicNumber,
      ctc: m.ctc,
      shiftType: m.shiftType,
      shiftHours: m.shiftHours,
      weekOffDay: m.weekOffDay,
      weekOffPerMonth: m.weekOffPerMonth,
      maxCL: m.maxCL,
      maxSL: m.maxSL,
      maxEL: m.maxEL,
      maxCompOff: m.maxCompOff,
    );
  }

  static EmployeeProfileInfoModel _infoToModel(EmployeeProfileInfo e) {
    return EmployeeProfileInfoModel(
      alternateNumber: e.alternateNumber,
      parentsName: e.parentsName,
      gender: e.gender,
      dob: e.dob,
      addressLine1: e.addressLine1,
      addressLine2: e.addressLine2,
      city: e.city,
      state: e.state,
      pinCode: e.pinCode,
      country: e.country,
      workLocation: e.workLocation,
      employmentType: e.employmentType,
      reportingManager: e.reportingManager,
      bankName: e.bankName,
      bankAccountNo: e.bankAccountNo,
      ifscCode: e.ifscCode,
      panNumber: e.panNumber,
      aadharNumber: e.aadharNumber,
      uanNumber: e.uanNumber,
      pfNumber: e.pfNumber,
      esicNumber: e.esicNumber,
      ctc: e.ctc,
      shiftType: e.shiftType,
      shiftHours: e.shiftHours,
      weekOffDay: e.weekOffDay,
      weekOffPerMonth: e.weekOffPerMonth,
      maxCL: e.maxCL,
      maxSL: e.maxSL,
      maxEL: e.maxEL,
      maxCompOff: e.maxCompOff,
    );
  }

  static EmployeeModel toModel(Employee entity) {
    return EmployeeModel(
      id: entity.id,
      name: entity.name,
      email: entity.email,
      role: entity.role,
      department: entity.department,
      employeeId: entity.employeeId,
      designation: entity.designation,
      employeeCode: entity.employeeCode,
      firstName: entity.firstName,
      lastName: entity.lastName,
      phone: entity.phone,
      status: entity.status,
      salaryPerMonth: entity.salaryPerMonth,
      basicPay: entity.basicPay,
      hra: entity.hra,
      conveyanceAllowance: entity.conveyanceAllowance,
      medicalAllowance: entity.medicalAllowance,
      performanceAllowance: entity.performanceAllowance,
      specialAllowance: entity.specialAllowance,
      otherDeductions: entity.otherDeductions,
      salaryIncrements: entity.salaryIncrements
          .map(
            (item) => SalaryIncrementModel(
              incrementType: item.incrementType,
              incrementValue: item.incrementValue,
              oldSalaryPerMonth: item.oldSalaryPerMonth,
              newSalaryPerMonth: item.newSalaryPerMonth,
              effectiveFrom: item.effectiveFrom,
              reason: item.reason,
            ),
          )
          .toList(),
      joinDate: entity.joinDate,
      permissions: entity.permissions,
      latitude: entity.latitude,
      longitude: entity.longitude,
      address: entity.address,
      lastLoginLocation: _locToModel(entity.lastLoginLocation),
      lastCheckInLocation: _locToModel(entity.lastCheckInLocation),
      lastCheckOutLocation: _locToModel(entity.lastCheckOutLocation),
      isAllowedImageCapturedAttendance: entity.isAllowedImageCapturedAttendance,
      info: _infoToModel(entity.info),
    );
  }

  static EmployeeLocation? _locToEntity(EmployeeLocationModel? model) {
    if (model == null) return null;
    return EmployeeLocation(
      latitude: model.latitude,
      longitude: model.longitude,
      timestamp: model.timestamp,
      address: model.address,
    );
  }

  static EmployeeLocationModel? _locToModel(EmployeeLocation? entity) {
    if (entity == null) return null;
    return EmployeeLocationModel(
      latitude: entity.latitude,
      longitude: entity.longitude,
      timestamp: entity.timestamp,
      address: entity.address,
    );
  }
}
