class EmployeeLocationModel {
  const EmployeeLocationModel({
    required this.latitude,
    required this.longitude,
    this.timestamp,
    this.address,
  });

  final double latitude;
  final double longitude;
  final DateTime? timestamp;
  final String? address;

  factory EmployeeLocationModel.fromJson(Map<String, dynamic> json) {
    return EmployeeLocationModel(
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0,
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp'] as String)
          : null,
      address: json['address'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      if (timestamp != null) 'timestamp': timestamp!.toIso8601String(),
      if (address != null) 'address': address,
    };
  }
}

class SalaryIncrementModel {
  const SalaryIncrementModel({
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

  factory SalaryIncrementModel.fromJson(Map<String, dynamic> json) {
    return SalaryIncrementModel(
      incrementType: json['incrementType']?.toString() ?? 'amount',
      incrementValue: (json['incrementValue'] as num?)?.toDouble() ?? 0,
      oldSalaryPerMonth: (json['oldSalaryPerMonth'] as num?)?.toDouble() ?? 0,
      newSalaryPerMonth: (json['newSalaryPerMonth'] as num?)?.toDouble() ?? 0,
      effectiveFrom: json['effectiveFrom'] != null
          ? DateTime.tryParse(json['effectiveFrom'].toString())
          : null,
      reason: json['reason']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'incrementType': incrementType,
      'incrementValue': incrementValue,
      'oldSalaryPerMonth': oldSalaryPerMonth,
      'newSalaryPerMonth': newSalaryPerMonth,
      if (effectiveFrom != null)
        'effectiveFrom': effectiveFrom!.toIso8601String(),
      'reason': reason,
    };
  }
}

class EmployeeProfileInfoModel {
  const EmployeeProfileInfoModel({
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

  factory EmployeeProfileInfoModel.fromJson(Map<String, dynamic> json) {
    String str(String key) => _text(json[key]);
    num? number(String key) {
      final v = json[key];
      if (v is num) return v;
      if (v is String) return num.tryParse(v.trim());
      return null;
    }

    final dobRaw = json['dob'] ?? json['dateOfBirth'];
    final weekOff = json['weekOffDay'] ?? json['weekOffDays'];
    return EmployeeProfileInfoModel(
      alternateNumber: str('alternateNumber'),
      parentsName: str('parentsName'),
      gender: str('gender'),
      dob: dobRaw == null ? null : DateTime.tryParse(dobRaw.toString()),
      addressLine1: str('addressLine1'),
      addressLine2: str('addressLine2'),
      city: str('city'),
      state: str('state'),
      pinCode: str('pinCode'),
      country: str('country'),
      workLocation: _text(json['workLocation'] ?? json['location']),
      employmentType: str('employmentType'),
      reportingManager: _text(json['reportingManager']),
      bankName: str('bankName'),
      bankAccountNo: str('bankAccountNo'),
      ifscCode: str('ifscCode'),
      panNumber: str('panNumber'),
      aadharNumber: str('aadharNumber'),
      uanNumber: str('uanNumber'),
      pfNumber: str('pfNumber'),
      esicNumber: str('esicNumber'),
      ctc: number('ctc')?.toDouble() ?? 0,
      shiftType: str('shiftType'),
      shiftHours: number('shiftHours'),
      weekOffDay: weekOff is List
          ? weekOff.map(_text).where((e) => e.isNotEmpty).join(', ')
          : _text(weekOff),
      weekOffPerMonth: number('weekOffPerMonth'),
      maxCL: number('maxCL'),
      maxSL: number('maxSL'),
      maxEL: number('maxEL'),
      maxCompOff: number('maxCompOff'),
    );
  }

  static String _text(dynamic value) {
    if (value == null) return '';
    if (value is Map) {
      return (value['name'] ?? value['title'] ?? value['_id'] ?? '')
          .toString()
          .trim();
    }
    return value.toString().trim();
  }

  Map<String, dynamic> toJson() {
    return {
      'alternateNumber': alternateNumber,
      'parentsName': parentsName,
      'gender': gender,
      if (dob != null) 'dob': dob!.toIso8601String(),
      'addressLine1': addressLine1,
      'addressLine2': addressLine2,
      'city': city,
      'state': state,
      'pinCode': pinCode,
      'country': country,
      'workLocation': workLocation,
      'employmentType': employmentType,
      'reportingManager': reportingManager,
      'bankName': bankName,
      'bankAccountNo': bankAccountNo,
      'ifscCode': ifscCode,
      'panNumber': panNumber,
      'aadharNumber': aadharNumber,
      'uanNumber': uanNumber,
      'pfNumber': pfNumber,
      'esicNumber': esicNumber,
      'ctc': ctc,
      'shiftType': shiftType,
      'shiftHours': ?shiftHours,
      'weekOffDay': weekOffDay,
      'weekOffPerMonth': ?weekOffPerMonth,
      'maxCL': ?maxCL,
      'maxSL': ?maxSL,
      'maxEL': ?maxEL,
      'maxCompOff': ?maxCompOff,
    };
  }
}

class EmployeeModel {
  const EmployeeModel({
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
    this.info = const EmployeeProfileInfoModel(),
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
  final List<SalaryIncrementModel> salaryIncrements;
  final DateTime? joinDate;
  final List<String> permissions;
  final double? latitude;
  final double? longitude;
  final String? address;
  final EmployeeLocationModel? lastLoginLocation;
  final EmployeeLocationModel? lastCheckInLocation;
  final EmployeeLocationModel? lastCheckOutLocation;
  final bool isAllowedImageCapturedAttendance;
  final EmployeeProfileInfoModel info;

  factory EmployeeModel.fromJson(Map<String, dynamic> json) {
    EmployeeLocationModel? loc(String key) {
      final raw = json[key];
      if (raw is Map<String, dynamic>) {
        return EmployeeLocationModel.fromJson(raw);
      }
      return null;
    }

    return EmployeeModel(
      id: (json['id'] ?? json['_id'])?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      firstName: json['firstName']?.toString(),
      lastName: json['lastName']?.toString(),
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString(),
      role: json['role']?.toString() ?? '',
      department: json['department']?.toString() ?? '',
      employeeId: json['employeeId']?.toString() ?? '',
      designation: EmployeeProfileInfoModel._text(json['designation']),
      employeeCode:
          json['employeeCode']?.toString() ?? json['empCode']?.toString(),
      status: json['status']?.toString(),
      salaryPerMonth: (json['salaryPerMonth'] as num?)?.toDouble(),
      basicPay: (json['basicPay'] as num?)?.toDouble() ?? 0,
      hra: (json['hra'] as num?)?.toDouble() ?? 0,
      conveyanceAllowance:
          (json['conveyanceAllowance'] as num?)?.toDouble() ?? 0,
      medicalAllowance: (json['medicalAllowance'] as num?)?.toDouble() ?? 0,
      performanceAllowance:
          (json['performanceAllowance'] as num?)?.toDouble() ?? 0,
      specialAllowance: (json['specialAllowance'] as num?)?.toDouble() ?? 0,
      otherDeductions: (json['otherDeductions'] as num?)?.toDouble() ?? 0,
      salaryIncrements:
          (json['salaryIncrements'] as List<dynamic>?)
              ?.whereType<Map>()
              .map(
                (item) => SalaryIncrementModel.fromJson(
                  Map<String, dynamic>.from(item),
                ),
              )
              .toList() ??
          const [],
      joinDate: json['joinDate'] != null
          ? DateTime.tryParse(json['joinDate'].toString())
          : null,
      permissions:
          (json['permissions'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      address: json['address']?.toString(),
      lastLoginLocation: loc('lastLoginLocation'),
      lastCheckInLocation: loc('lastCheckInLocation'),
      lastCheckOutLocation: loc('lastCheckOutLocation'),
      isAllowedImageCapturedAttendance: _asBool(
        json['isAllowedImageCapturedAttendance'],
      ),
      info: EmployeeProfileInfoModel.fromJson(json),
    );
  }

  static bool _asBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final v = value.trim().toLowerCase();
      return v == 'true' || v == '1' || v == 'yes';
    }
    return false;
  }

  Map<String, dynamic> toJson() {
    return {
      ...info.toJson(),
      'id': id,
      '_id': id,
      'name': name,
      if (firstName != null) 'firstName': firstName,
      if (lastName != null) 'lastName': lastName,
      'email': email,
      if (phone != null) 'phone': phone,
      'role': role,
      'department': department,
      'employeeId': employeeId,
      if (designation.isNotEmpty) 'designation': designation,
      if (employeeCode != null) 'employeeCode': employeeCode,
      if (status != null) 'status': status,
      if (salaryPerMonth != null) 'salaryPerMonth': salaryPerMonth,
      'basicPay': basicPay,
      'hra': hra,
      'conveyanceAllowance': conveyanceAllowance,
      'medicalAllowance': medicalAllowance,
      'performanceAllowance': performanceAllowance,
      'specialAllowance': specialAllowance,
      'otherDeductions': otherDeductions,
      'salaryIncrements': salaryIncrements
          .map((item) => item.toJson())
          .toList(),
      if (joinDate != null) 'joinDate': joinDate!.toIso8601String(),
      'permissions': permissions,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (address != null) 'address': address,
      if (lastLoginLocation != null)
        'lastLoginLocation': lastLoginLocation!.toJson(),
      if (lastCheckInLocation != null)
        'lastCheckInLocation': lastCheckInLocation!.toJson(),
      if (lastCheckOutLocation != null)
        'lastCheckOutLocation': lastCheckOutLocation!.toJson(),
      'isAllowedImageCapturedAttendance': isAllowedImageCapturedAttendance,
    };
  }
}

class LoginResponseModel {
  const LoginResponseModel({
    required this.success,
    required this.message,
    this.employee,
  });

  final bool success;
  final String message;
  final EmployeeModel? employee;

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    final employeeJson = json['employee'];
    return LoginResponseModel(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      employee: employeeJson is Map<String, dynamic>
          ? EmployeeModel.fromJson(employeeJson)
          : null,
    );
  }
}

class EmployeeDetailResponseModel {
  const EmployeeDetailResponseModel({
    required this.success,
    required this.employee,
  });

  final bool success;
  final EmployeeModel employee;

  factory EmployeeDetailResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    if (data is! Map<String, dynamic>) {
      throw const FormatException('Missing employee data');
    }
    return EmployeeDetailResponseModel(
      success: json['success'] as bool? ?? false,
      employee: EmployeeModel.fromJson(data),
    );
  }
}
