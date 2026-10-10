class SalaryWeek {
  const SalaryWeek({
    required this.weekNumber,
    required this.presentDays,
    required this.halfDays,
    required this.leaves,
    required this.effectiveWorkingDays,
    required this.isEligibleForWeekoff,
  });

  final int weekNumber;
  final double presentDays;
  final double halfDays;
  final double leaves;
  final double effectiveWorkingDays;
  final bool isEligibleForWeekoff;
}

class SalaryMonth {
  const SalaryMonth({
    required this.monthLabel,
    required this.monthKey,
    required this.monthDays,
    required this.weekOffs,
    required this.presentDays,
    required this.halfDays,
    required this.workingDays,
    required this.earnedWeekOffs,
    required this.defaultWeekOffs,
    required this.totalLeaves,
    required this.expectedWorkingDays,
    required this.payablePresentDays,
    required this.carryForwardDays,
    required this.salaryPerMonth,
    required this.dailyRateLabel,
    required this.calculatedSalary,
    required this.baseCalculatedSalary,
    required this.finalPay,
    required this.otAmount,
    required this.compOffEarned,
    required this.compOffUsed,
    required this.compOffBalance,
    required this.isCurrentMonth,
    required this.canDownload,
    required this.joiningDate,
    required this.bankName,
    required this.bankAccount,
    required this.panNo,
    required this.location,
    required this.holidayCount,
    required this.fullWorkingDays,
    required this.otherDeductions,
    required this.employeeCode,
    required this.name,
    required this.department,
    required this.designation,
    required this.approvedLeavesLabel,
    required this.weeks,
  });

  final String monthLabel;
  final String monthKey;
  final int monthDays;
  final int weekOffs;
  final double presentDays;
  final double halfDays;
  final double workingDays;
  final double earnedWeekOffs;
  final double defaultWeekOffs;
  final int totalLeaves;
  final int expectedWorkingDays;
  final double payablePresentDays;
  final double carryForwardDays;
  final double salaryPerMonth;
  final String dailyRateLabel;
  final double calculatedSalary;
  final double baseCalculatedSalary;
  final double finalPay;
  final double otAmount;
  final double compOffEarned;
  final double compOffUsed;
  final double compOffBalance;
  final bool isCurrentMonth;
  final bool canDownload;
  final String joiningDate;
  final String bankName;
  final String bankAccount;
  final String panNo;
  final String location;
  final int holidayCount;
  final double fullWorkingDays;
  final double otherDeductions;
  final String employeeCode;
  final String name;
  final String department;
  final String designation;
  final String approvedLeavesLabel;
  final List<SalaryWeek> weeks;
}

class SalarySummary {
  const SalarySummary({
    required this.totalRecords,
    required this.totalNetPay,
    required this.payslipsAvailable,
    required this.avgSalary,
    required this.months,
  });

  final int totalRecords;
  final double totalNetPay;
  final int payslipsAvailable;
  final double avgSalary;
  final List<SalaryMonth> months;

  static const empty = SalarySummary(
    totalRecords: 0,
    totalNetPay: 0,
    payslipsAvailable: 0,
    avgSalary: 0,
    months: [],
  );
}
