class PayslipModel {
  const PayslipModel({
    required this.salaryPerMonth,
    required this.basicPay,
    required this.hra,
    required this.conveyanceAllowance,
    required this.medicalAllowance,
    required this.performanceAllowance,
    required this.specialAllowance,
    required this.ctc,
    required this.employeeId,
    required this.name,
    this.effectiveFrom,
  });

  final double salaryPerMonth;
  final double basicPay;
  final double hra;
  final double conveyanceAllowance;
  final double medicalAllowance;
  final double performanceAllowance;
  final double specialAllowance;
  final double ctc;
  final DateTime? effectiveFrom;
  final String employeeId;
  final String name;

  factory PayslipModel.fromJson(Map<String, dynamic> json) {
    return PayslipModel(
      salaryPerMonth: (json['salaryPerMonth'] as num?)?.toDouble() ?? 0,
      basicPay: (json['basicPay'] as num?)?.toDouble() ?? 0,
      hra: (json['hra'] as num?)?.toDouble() ?? 0,
      conveyanceAllowance:
          (json['conveyanceAllowance'] as num?)?.toDouble() ?? 0,
      medicalAllowance: (json['medicalAllowance'] as num?)?.toDouble() ?? 0,
      performanceAllowance:
          (json['performanceAllowance'] as num?)?.toDouble() ?? 0,
      specialAllowance: (json['specialAllowance'] as num?)?.toDouble() ?? 0,
      ctc: (json['ctc'] as num?)?.toDouble() ?? 0,
      effectiveFrom: json['effectiveFrom'] is String
          ? DateTime.tryParse(json['effectiveFrom'] as String)
          : null,
      employeeId: json['employeeId']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
    );
  }
}
