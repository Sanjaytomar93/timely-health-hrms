class Payslip {
  const Payslip({
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
}
