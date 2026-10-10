import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:timelay_health/core/theme/portal_colors.dart';
import 'package:timelay_health/features/payslips/domain/entities/payslip.dart';
import 'package:timelay_health/features/payslips/domain/entities/salary_summary.dart';

class PayslipStatsUiModel extends Equatable {
  const PayslipStatsUiModel({
    required this.totalRecords,
    required this.totalSalaryLabel,
    required this.payslipsCount,
    required this.avgSalaryLabel,
  });

  final String totalRecords;
  final String totalSalaryLabel;
  final String payslipsCount;
  final String avgSalaryLabel;

  static const empty = PayslipStatsUiModel(
    totalRecords: '0',
    totalSalaryLabel: '₹0',
    payslipsCount: '0',
    avgSalaryLabel: '₹0',
  );

  @override
  List<Object?> get props => [
    totalRecords,
    totalSalaryLabel,
    payslipsCount,
    avgSalaryLabel,
  ];
}

class PayslipDetailRowUiModel extends Equatable {
  const PayslipDetailRowUiModel({
    required this.label,
    required this.value,
    required this.valueColor,
    this.topBorder = false,
  });

  final String label;
  final String value;
  final Color valueColor;
  final bool topBorder;

  @override
  List<Object?> get props => [label, value, valueColor, topBorder];
}

class PayslipUiModel extends Equatable {
  const PayslipUiModel({
    required this.monthLabel,
    required this.daysMeta,
    required this.salaryLabel,
    required this.dailyRateLabel,
    required this.name,
    required this.employeeCode,
    required this.initials,
    required this.role,
    required this.monthMeta,
    required this.headerDateLabel,
    required this.monthFilterLabel,
    required this.detailRows,
    this.metrics = const [],
    this.calculatedLabel = '₹0',
    this.finalPayLabel = '₹0',
    this.statusLabel = '—',
    this.statusColor = PortalColors.muted,
    this.statusBackground = PortalColors.background,
    this.canDownload = false,
    this.department = '—',
    this.designation = '—',
    this.approvedLeaves = 'No Leaves',
    this.weeks = const [],
    this.compOffTaken = '0',
    this.compOffUsed = '0',
    this.compOffBalance = '0',
    this.pairs = const [],
    this.joiningDate = '-',
    this.bankName = '-',
    this.bankAccount = '-',
    this.panNo = '-',
    this.location = '-',
    this.lopLabel = '0',
    this.holidayCountLabel = '0',
    this.fullDaysLabel = '0',
    this.halfDaysLabel = '0',
    this.weekOffLabel = '0',
    this.baseSalaryLabel = '₹0.00',
    this.holidayPayLabel = '₹0.00',
    this.totalEarningsLabel = '₹0.00',
    this.lopAmountLabel = '₹0.00',
    this.otherDeductionsLabel = '₹0.00',
    this.totalDeductionsLabel = '₹0.00',
    this.netPayLabel = '₹0.00',
    this.netPayWords = '',
  });

  final String monthLabel;
  final String daysMeta;
  final String salaryLabel;
  final String dailyRateLabel;
  final String name;
  final String employeeCode;
  final String initials;
  final String role;
  final String monthMeta;
  final String headerDateLabel;
  final String monthFilterLabel;
  final List<PayslipDetailRowUiModel> detailRows;
  final List<SalaryMetricUi> metrics;
  final String calculatedLabel;
  final String finalPayLabel;
  final String statusLabel;
  final Color statusColor;
  final Color statusBackground;
  final bool canDownload;
  final String department;
  final String designation;
  final String approvedLeaves;
  final List<SalaryWeekUi> weeks;
  final String compOffTaken;
  final String compOffUsed;
  final String compOffBalance;
  final List<SalaryPairUi> pairs;
  final String joiningDate;
  final String bankName;
  final String bankAccount;
  final String panNo;
  final String location;
  final String lopLabel;
  final String holidayCountLabel;
  final String fullDaysLabel;
  final String halfDaysLabel;
  final String weekOffLabel;
  final String baseSalaryLabel;
  final String holidayPayLabel;
  final String totalEarningsLabel;
  final String lopAmountLabel;
  final String otherDeductionsLabel;
  final String totalDeductionsLabel;
  final String netPayLabel;
  final String netPayWords;

  static PayslipUiModel emptyFor(DateTime date) {
    return PayslipUiMapper.empty(date);
  }

  @override
  List<Object?> get props => [
    monthLabel,
    daysMeta,
    salaryLabel,
    dailyRateLabel,
    name,
    employeeCode,
    initials,
    role,
    monthMeta,
    headerDateLabel,
    monthFilterLabel,
    detailRows,
    metrics,
    calculatedLabel,
    finalPayLabel,
    statusLabel,
    canDownload,
    department,
    designation,
    approvedLeaves,
    weeks,
    compOffTaken,
    compOffUsed,
    compOffBalance,
    pairs,
  ];
}

class SalaryMetricUi extends Equatable {
  const SalaryMetricUi({required this.value, required this.label});

  final String value;
  final String label;

  @override
  List<Object?> get props => [value, label];
}

class SalaryWeekUi extends Equatable {
  const SalaryWeekUi({
    required this.title,
    required this.detail,
    required this.total,
    required this.weekOffLabel,
    required this.eligible,
  });

  final String title;
  final String detail;
  final String total;
  final String weekOffLabel;
  final bool eligible;

  @override
  List<Object?> get props => [title, detail, total, weekOffLabel, eligible];
}

class SalaryPairUi extends Equatable {
  const SalaryPairUi({
    required this.leftLabel,
    required this.leftValue,
    required this.rightLabel,
    required this.rightValue,
    this.leftColor = PortalColors.heading,
    this.rightColor = PortalColors.heading,
    this.highlight = false,
  });

  final String leftLabel;
  final String leftValue;
  final String rightLabel;
  final String rightValue;
  final Color leftColor;
  final Color rightColor;
  final bool highlight;

  @override
  List<Object?> get props => [
    leftLabel,
    leftValue,
    rightLabel,
    rightValue,
    highlight,
  ];
}

class PayslipUiMapper {
  const PayslipUiMapper._();

  static const _months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  static const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  static PayslipUiModel toUi(Payslip payslip, DateTime date, {String? role}) {
    final daysInMonth = DateTime(date.year, date.month + 1, 0).day;
    final salary = payslip.salaryPerMonth;
    final daily = daysInMonth == 0 ? 0.0 : salary / daysInMonth;
    final name = payslip.name.trim().isEmpty ? '—' : payslip.name.trim();
    final code = payslip.employeeId.trim().isEmpty
        ? '—'
        : payslip.employeeId.trim();
    final resolvedRole = (role ?? '').trim().isEmpty
        ? 'Employee'
        : role!.trim();

    return PayslipUiModel(
      monthLabel: '${_months[date.month - 1]} ${date.year}',
      daysMeta: '$daysInMonth days',
      salaryLabel: _money(salary),
      dailyRateLabel: '${_money(daily)}/day',
      name: name,
      employeeCode: code,
      initials: _initials(name),
      role: resolvedRole,
      monthMeta:
          'Month: ${date.year}-${date.month.toString().padLeft(2, '0')} ($daysInMonth days)',
      headerDateLabel: _headerDate(date),
      monthFilterLabel: '${_months[date.month - 1]} ${date.year}',
      detailRows: [
        PayslipDetailRowUiModel(
          label: 'Monthly Salary',
          value: _money(salary),
          valueColor: const Color(0xFF26204A),
        ),
        PayslipDetailRowUiModel(
          label: 'Basic Pay',
          value: _money(payslip.basicPay),
          valueColor: PortalColors.heading,
        ),
        PayslipDetailRowUiModel(
          label: 'HRA',
          value: _money(payslip.hra),
          valueColor: PortalColors.heading,
        ),
        PayslipDetailRowUiModel(
          label: 'Conveyance',
          value: _money(payslip.conveyanceAllowance),
          valueColor: PortalColors.heading,
        ),
        PayslipDetailRowUiModel(
          label: 'Medical',
          value: _money(payslip.medicalAllowance),
          valueColor: PortalColors.heading,
        ),
        PayslipDetailRowUiModel(
          label: 'Performance',
          value: _money(payslip.performanceAllowance),
          valueColor: PortalColors.heading,
        ),
        PayslipDetailRowUiModel(
          label: 'Special Allowance',
          value: _money(payslip.specialAllowance),
          valueColor: PortalColors.heading,
        ),
        PayslipDetailRowUiModel(
          label: 'CTC',
          value: _money(payslip.ctc),
          valueColor: PortalColors.heading,
        ),
        PayslipDetailRowUiModel(
          label: 'Daily Rate',
          value: '${_money(daily)}/day',
          valueColor: PortalColors.heading,
        ),
        PayslipDetailRowUiModel(
          label: 'Calculated Salary',
          value: _money(salary),
          valueColor: const Color(0xFF26204A),
          topBorder: true,
        ),
      ],
    );
  }

  static PayslipUiModel empty(DateTime date) {
    final daysInMonth = DateTime(date.year, date.month + 1, 0).day;
    return PayslipUiModel(
      monthLabel: '${_months[date.month - 1]} ${date.year}',
      daysMeta: '$daysInMonth days',
      salaryLabel: '₹0',
      dailyRateLabel: '₹0/day',
      name: '—',
      employeeCode: '—',
      initials: '?',
      role: 'Employee',
      monthMeta:
          'Month: ${date.year}-${date.month.toString().padLeft(2, '0')} ($daysInMonth days)',
      headerDateLabel: _headerDate(date),
      monthFilterLabel: '${_months[date.month - 1]} ${date.year}',
      detailRows: const [],
    );
  }

  static PayslipUiModel fromMonth(SalaryMonth month, DateTime selected) {
    final name = month.name.trim().isEmpty ? '—' : month.name.trim();
    final code = month.employeeCode.trim().isEmpty
        ? '—'
        : month.employeeCode.trim();
    final isZeroFinal = month.finalPay <= 0;
    return PayslipUiModel(
      monthLabel: month.monthLabel.isEmpty
          ? '${_months[selected.month - 1]} ${selected.year}'
          : month.monthLabel,
      daysMeta: '${month.monthDays} days | WO: ${month.weekOffs}',
      salaryLabel: _money(month.salaryPerMonth),
      dailyRateLabel: month.dailyRateLabel,
      name: name,
      employeeCode: code,
      initials: _initials(name),
      role: month.designation.trim().isEmpty ? '—' : month.designation.trim(),
      monthMeta: 'Month Days: ${month.monthDays} | WO: ${month.weekOffs}',
      headerDateLabel: _headerDate(selected),
      monthFilterLabel: month.monthLabel.isEmpty
          ? '${_months[selected.month - 1]} ${selected.year}'
          : month.monthLabel,
      calculatedLabel: _money(month.calculatedSalary),
      finalPayLabel: _money(month.finalPay),
      statusLabel: month.isCurrentMonth ? 'From Last Day' : 'Closed',
      statusColor: month.isCurrentMonth
          ? const Color(0xFFE07A1F)
          : PortalColors.green,
      statusBackground: month.isCurrentMonth
          ? const Color(0xFFFFF4E8)
          : PortalColors.greenTint,
      canDownload: _canDownload(selected),
      joiningDate: month.joiningDate,
      bankName: month.bankName,
      bankAccount: month.bankAccount,
      panNo: month.panNo,
      location: month.location,
      lopLabel: _qty(_lopDays(month)),
      holidayCountLabel: '${month.holidayCount}',
      fullDaysLabel: _qty(month.fullWorkingDays),
      halfDaysLabel: _qty(month.halfDays),
      weekOffLabel: '${month.weekOffs}',
      baseSalaryLabel: _moneyFixed(month.baseCalculatedSalary),
      holidayPayLabel: _moneyFixed(_daily(month) * month.holidayCount),
      totalEarningsLabel: _moneyFixed(month.salaryPerMonth),
      lopAmountLabel: _moneyFixed(_lopAmount(month)),
      otherDeductionsLabel: _moneyFixed(month.otherDeductions),
      totalDeductionsLabel: _moneyFixed(_deductions(month)),
      netPayLabel: _moneyFixed(month.finalPay),
      netPayWords: _rupeesInWords(month.finalPay.round()),
      department: month.department.trim().isEmpty
          ? '—'
          : month.department.trim(),
      designation: month.designation.trim().isEmpty
          ? '—'
          : month.designation.trim(),
      approvedLeaves: month.approvedLeavesLabel,
      compOffTaken: _qty(month.compOffEarned),
      compOffUsed: _qty(month.compOffUsed),
      compOffBalance: _qty(month.compOffBalance),
      metrics: [
        SalaryMetricUi(value: _qty(month.presentDays), label: 'Present'),
        SalaryMetricUi(value: _qty(month.workingDays), label: 'Working'),
        SalaryMetricUi(value: _qty(month.halfDays), label: 'Half'),
        SalaryMetricUi(value: _qty(month.earnedWeekOffs), label: 'Earned WO'),
        SalaryMetricUi(value: '${month.totalLeaves}', label: 'Leaves'),
        SalaryMetricUi(
          value: '${_qty(month.compOffEarned)}/${_qty(month.compOffUsed)}',
          label: 'Comp-off',
        ),
      ],
      weeks: [
        for (final week in month.weeks)
          SalaryWeekUi(
            title: 'Week ${week.weekNumber}',
            detail:
                'P:${_qty(week.presentDays)}  H:${_qty(week.halfDays)}  L:${_qty(week.leaves)}',
            total: 'Total: ${_qty(week.effectiveWorkingDays)}d',
            weekOffLabel: week.isEligibleForWeekoff ? 'WO' : 'No WO',
            eligible: week.isEligibleForWeekoff,
          ),
      ],
      pairs: [
        SalaryPairUi(
          leftLabel: 'Present Days',
          leftValue: _qty(month.presentDays),
          rightLabel: 'Working Days',
          rightValue: _qty(month.workingDays),
          leftColor: PortalColors.green,
          rightColor: PortalColors.green,
        ),
        SalaryPairUi(
          leftLabel: 'Half Days',
          leftValue: _qty(month.halfDays),
          rightLabel: 'Earned Weekoffs',
          rightValue: _qty(month.earnedWeekOffs),
          leftColor: const Color(0xFFE07A1F),
          rightColor: PortalColors.green,
        ),
        SalaryPairUi(
          leftLabel: 'Default Weekoffs',
          leftValue: _qty(month.defaultWeekOffs),
          rightLabel: 'WeekOff Days Paid',
          rightValue: _qty(month.earnedWeekOffs),
        ),
        SalaryPairUi(
          leftLabel: 'Expected Working Days',
          leftValue: '${month.expectedWorkingDays}',
          rightLabel: 'Payable Present Days',
          rightValue: _qty(month.payablePresentDays),
        ),
        SalaryPairUi(
          leftLabel: 'Monthly Assigned Salary',
          leftValue: _money(month.salaryPerMonth),
          rightLabel: 'Daily Rate',
          rightValue: month.dailyRateLabel,
          leftColor: PortalColors.heading,
        ),
        SalaryPairUi(
          leftLabel: 'OT Amount',
          leftValue: _money(month.otAmount),
          rightLabel: 'Calculated Base Salary',
          rightValue: _money(month.baseCalculatedSalary),
          leftColor: PortalColors.green,
          rightColor: const Color(0xFF3D7AFE),
        ),
        SalaryPairUi(
          leftLabel: 'Final Net Payout',
          leftValue: _money(month.finalPay),
          rightLabel: '',
          rightValue: '',
          leftColor: isZeroFinal ? PortalColors.red : PortalColors.green,
          highlight: true,
        ),
      ],
      detailRows: const [],
    );
  }

  static PayslipStatsUiModel statsFrom(SalarySummary summary) {
    return PayslipStatsUiModel(
      totalRecords: '${summary.totalRecords}',
      totalSalaryLabel: _money(summary.totalNetPay),
      payslipsCount: '${summary.payslipsAvailable}',
      avgSalaryLabel: _money(summary.avgSalary),
    );
  }

  static PayslipStatsUiModel toStats(Payslip? payslip) {
    if (payslip == null) return PayslipStatsUiModel.empty;
    final salary = _money(payslip.salaryPerMonth);
    return PayslipStatsUiModel(
      totalRecords: '1',
      totalSalaryLabel: salary,
      payslipsCount: '1',
      avgSalaryLabel: salary,
    );
  }

  static String _headerDate(DateTime date) {
    final local = date.toLocal();
    return '${_weekdays[local.weekday - 1]}, '
        '${_months[local.month - 1].substring(0, 3)} ${local.day}, ${local.year}';
  }

  static String _qty(double value) {
    if (value == value.roundToDouble()) return value.round().toString();
    return value.toStringAsFixed(1);
  }

  static String _money(double value) {
    final rounded = value.round();
    final raw = rounded.toString();
    final buf = StringBuffer();
    for (var i = 0; i < raw.length; i++) {
      final fromEnd = raw.length - i;
      if (i > 0 && fromEnd % 3 == 0) buf.write(',');
      buf.write(raw[i]);
    }
    return '₹$buf';
  }

  static bool _canDownload(DateTime selected) {
    final now = DateTime.now();
    final selectedMonth = DateTime(selected.year, selected.month);
    final thisMonth = DateTime(now.year, now.month);
    if (selectedMonth.isBefore(thisMonth)) return true;
    if (selectedMonth.isAtSameMomentAs(thisMonth)) return now.day > 26;
    return false;
  }

  static double _daily(SalaryMonth month) {
    final raw = month.dailyRateLabel.replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(raw) ?? 0;
  }

  static double _lopDays(SalaryMonth month) {
    final days =
        month.monthDays -
        month.presentDays -
        month.weekOffs -
        month.holidayCount -
        month.totalLeaves;
    return days < 0 ? 0 : days;
  }

  static double _deductions(SalaryMonth month) {
    final gap = month.salaryPerMonth - month.finalPay;
    return gap < 0 ? month.otherDeductions : gap;
  }

  static double _lopAmount(SalaryMonth month) {
    final rest = _deductions(month) - month.otherDeductions;
    return rest < 0 ? 0 : rest;
  }

  static String _moneyFixed(double value) {
    return '₹${value.toStringAsFixed(2)}';
  }

  static String _rupeesInWords(int amount) {
    if (amount <= 0) return '(Zero Rupees Only)';
    return '(${_words(amount)} Rupees Only)';
  }

  static String _words(int n) {
    const ones = [
      '',
      'One',
      'Two',
      'Three',
      'Four',
      'Five',
      'Six',
      'Seven',
      'Eight',
      'Nine',
      'Ten',
      'Eleven',
      'Twelve',
      'Thirteen',
      'Fourteen',
      'Fifteen',
      'Sixteen',
      'Seventeen',
      'Eighteen',
      'Nineteen',
    ];
    const tens = [
      '',
      '',
      'Twenty',
      'Thirty',
      'Forty',
      'Fifty',
      'Sixty',
      'Seventy',
      'Eighty',
      'Ninety',
    ];
    if (n < 20) return ones[n];
    if (n < 100) {
      final rest = n % 10;
      return '${tens[n ~/ 10]}${rest == 0 ? '' : ' ${ones[rest]}'}';
    }
    if (n < 1000) {
      final rest = n % 100;
      final join = rest == 0
          ? ''
          : rest < 100
          ? ' And ${_words(rest)}'
          : ' ${_words(rest)}';
      return '${ones[n ~/ 100]} Hundred$join';
    }
    if (n < 100000) {
      final rest = n % 1000;
      return '${_words(n ~/ 1000)} Thousand${rest == 0 ? '' : ' ${_words(rest)}'}';
    }
    final rest = n % 100000;
    return '${_words(n ~/ 100000)} Lakh${rest == 0 ? '' : ' ${_words(rest)}'}';
  }

  static String _initials(String name) {
    final parts = name
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }
}
