class PayrollStatCardData {
  const PayrollStatCardData({
    required this.totalPayroll,
    required this.totalPayrollSubtitle,
    required this.pendingAmount,
    required this.pendingSubtitle,
    required this.paidAmount,
    required this.paidSubtitle,
    required this.totalEmployees,
    required this.employeesSubtitle,
  });

  final String totalPayroll;
  final String totalPayrollSubtitle;
  final String pendingAmount;
  final String pendingSubtitle;
  final String paidAmount;
  final String paidSubtitle;
  final int totalEmployees;
  final String employeesSubtitle;
}

class PayrollTrendBar {
  const PayrollTrendBar({
    required this.month,
    required this.grossMillion,
    required this.netMillion,
    this.isHighlighted = false,
  });

  final String month;
  final double grossMillion;
  final double netMillion;
  final bool isHighlighted;
}

class PayrollLineItem {
  const PayrollLineItem({
    required this.title,
    required this.amount,
    this.isHighlight = false,
    this.isDeduction = false,
  });

  final String title;
  final String amount;
  final bool isHighlight;
  final bool isDeduction;
}

class AttendanceImpactSummary {
  const AttendanceImpactSummary({
    required this.presentDays,
    required this.halfDays,
    required this.weekoffs,
    required this.compOffs,
    required this.overtimeHours,
    required this.activeStaff,
  });

  final String presentDays;
  final String halfDays;
  final String weekoffs;
  final String compOffs;
  final String overtimeHours;
  final String activeStaff;
}

class EmployeePayrollRecord {
  const EmployeePayrollRecord({
    required this.id,
    required this.name,
    required this.code,
    required this.role,
    required this.department,
    required this.initials,
    required this.status, // PENDING, NA, PAID
    required this.presentDays,
    required this.halfDays,
    required this.otHours,
    required this.basicText,
    required this.lopDedText,
    required this.netSalary,
  });

  final String id;
  final String name;
  final String code;
  final String role;
  final String department;
  final String initials;
  final String status;
  final String presentDays;
  final String halfDays;
  final String otHours;
  final String basicText;
  final String lopDedText;
  final String netSalary;
}

class PayrollOverviewUi {
  const PayrollOverviewUi({
    required this.stats,
    required this.trendBars,
    required this.earnings,
    required this.grossSalaryTotal,
    required this.deductions,
    required this.totalDeductions,
    required this.impact,
    required this.records,
  });

  final PayrollStatCardData stats;
  final List<PayrollTrendBar> trendBars;
  final List<PayrollLineItem> earnings;
  final String grossSalaryTotal;
  final List<PayrollLineItem> deductions;
  final String totalDeductions;
  final AttendanceImpactSummary impact;
  final List<EmployeePayrollRecord> records;

  static PayrollOverviewUi sample() {
    return const PayrollOverviewUi(
      stats: PayrollStatCardData(
        totalPayroll: '₹218,066',
        totalPayrollSubtitle: 'paid + pending net payroll',
        pendingAmount: '₹218,066',
        pendingSubtitle: '100% of total payroll',
        paidAmount: '₹0',
        paidSubtitle: '0% of total payroll',
        totalEmployees: 65,
        employeesSubtitle: '0 Paid • 65 Pending',
      ),
      trendBars: [
        PayrollTrendBar(month: 'Apr', grossMillion: 11.2, netMillion: 9.8),
        PayrollTrendBar(month: 'May', grossMillion: 12.0, netMillion: 10.6),
        PayrollTrendBar(month: 'Jun', grossMillion: 13.5, netMillion: 11.9),
        PayrollTrendBar(month: 'Jul', grossMillion: 14.1, netMillion: 12.3),
        PayrollTrendBar(month: 'Aug', grossMillion: 15.0, netMillion: 13.2),
        PayrollTrendBar(
          month: 'Sep',
          grossMillion: 16.5,
          netMillion: 14.8,
          isHighlighted: true,
        ),
      ],
      earnings: [
        PayrollLineItem(title: 'Basic Salary', amount: '₹1,20,000'),
        PayrollLineItem(title: 'HRA', amount: '₹68,587.19'),
        PayrollLineItem(title: 'Conveyance', amount: '₹20,832.37'),
        PayrollLineItem(title: 'Medical', amount: '₹11,394.78'),
        PayrollLineItem(title: 'Performance', amount: '₹55,000'),
        PayrollLineItem(title: 'Special Allowance', amount: '₹19,254.74'),
        PayrollLineItem(title: 'Public Holiday', amount: '₹0'),
        PayrollLineItem(
          title: 'Comp-off (1 days)',
          amount: '₹2,100',
          isHighlight: true,
        ),
        PayrollLineItem(title: 'Overtime', amount: '₹0'),
      ],
      grossSalaryTotal: '₹1,01,100.59',
      deductions: [
        PayrollLineItem(
          title: 'LOP / Absent',
          amount: '-₹1,222.78',
          isDeduction: true,
        ),
        PayrollLineItem(
          title: 'Half Day Deduction',
          amount: '-₹14,500',
          isDeduction: true,
        ),
        PayrollLineItem(title: 'ESI', amount: '-₹0'),
        PayrollLineItem(
          title: 'Professional Tax',
          amount: '-₹200',
          isDeduction: true,
        ),
        PayrollLineItem(title: 'Other Deductions', amount: '-₹0'),
        PayrollLineItem(title: 'Manual Deduction', amount: '-₹0'),
      ],
      totalDeductions: '-₹1,227.78',
      impact: AttendanceImpactSummary(
        presentDays: '249 days',
        halfDays: '0.5 days',
        weekoffs: '26 days',
        compOffs: '1 days',
        overtimeHours: '58.5 hrs',
        activeStaff: '60 Staff',
      ),
      records: [
        EmployeePayrollRecord(
          id: 'pay_1',
          name: 'G NARESH KUMAR',
          code: 'TH031',
          role: 'Consultant',
          department: 'Consultant',
          initials: 'NK',
          status: 'PENDING',
          presentDays: '14 d',
          halfDays: '0',
          otHours: '0.1 hrs',
          basicText: '₹15,000',
          lopDedText: '-₹7,000',
          netSalary: '₹8,000',
        ),
        EmployeePayrollRecord(
          id: 'pay_2',
          name: 'CHAKALI PRAVALLIKA',
          code: 'TH032',
          role: 'Nursing',
          department: 'Nursing',
          initials: 'CP',
          status: 'NA',
          presentDays: '0 d',
          halfDays: '0',
          otHours: '0.0 hrs',
          basicText: '-',
          lopDedText: '-₹15,000',
          netSalary: '₹0',
        ),
        EmployeePayrollRecord(
          id: 'pay_3',
          name: 'T Naga Vardhan babu',
          code: 'TH033',
          role: 'Digital Marketing',
          department: 'Digital Marketing',
          initials: 'NV',
          status: 'NA',
          presentDays: '0 d',
          halfDays: '0',
          otHours: '0.0 hrs',
          basicText: '-',
          lopDedText: '-₹35,000',
          netSalary: '₹0',
        ),
        EmployeePayrollRecord(
          id: 'pay_4',
          name: 'Manasa Ghanta',
          code: 'TH034',
          role: 'Medical',
          department: 'Medical',
          initials: 'MG',
          status: 'NA',
          presentDays: '0 d',
          halfDays: '0',
          otHours: '0.0 hrs',
          basicText: '-',
          lopDedText: '-₹40,000',
          netSalary: '₹0',
        ),
        EmployeePayrollRecord(
          id: 'pay_5',
          name: 'Dara Gowthami',
          code: 'TH035',
          role: 'Nursing',
          department: 'Nursing',
          initials: 'DG',
          status: 'NA',
          presentDays: '0 d',
          halfDays: '0',
          otHours: '0.0 hrs',
          basicText: '₹23,000',
          lopDedText: '-₹23,000',
          netSalary: '₹0',
        ),
        EmployeePayrollRecord(
          id: 'pay_6',
          name: 'K Akhil Kumar',
          code: 'TH036',
          role: 'Laboratory Medicine',
          department: 'Laboratory Medicine',
          initials: 'KK',
          status: 'PENDING',
          presentDays: '15 d',
          halfDays: '0',
          otHours: '2.1 hrs',
          basicText: '₹18,000',
          lopDedText: '-₹7,200',
          netSalary: '₹10,800',
        ),
        EmployeePayrollRecord(
          id: 'pay_7',
          name: 'M.venu',
          code: 'TH038',
          role: 'Digital Marketing',
          department: 'Digital Marketing',
          initials: 'MV',
          status: 'NA',
          presentDays: '0 d',
          halfDays: '0',
          otHours: '0.0 hrs',
          basicText: '-',
          lopDedText: '-₹10,000',
          netSalary: '₹0',
        ),
        EmployeePayrollRecord(
          id: 'pay_8',
          name: 'Arun kumar',
          code: 'TH039',
          role: 'Laboratory Medicine',
          department: 'Laboratory Medicine',
          initials: 'AK',
          status: 'NA',
          presentDays: '0 d',
          halfDays: '0',
          otHours: '0.0 hrs',
          basicText: '-',
          lopDedText: '-₹22,000',
          netSalary: '₹0',
        ),
        EmployeePayrollRecord(
          id: 'pay_9',
          name: 'P.Srujana',
          code: 'TH010',
          role: 'Marketing',
          department: 'Marketing',
          initials: 'PS',
          status: 'NA',
          presentDays: '0 d',
          halfDays: '0',
          otHours: '0.0 hrs',
          basicText: '-',
          lopDedText: '-₹35,000',
          netSalary: '₹0',
        ),
        EmployeePayrollRecord(
          id: 'pay_10',
          name: 'KARDAM KUMAR',
          code: 'TH012',
          role: 'Developer',
          department: 'Developer',
          initials: 'KK',
          status: 'PENDING',
          presentDays: '14 d',
          halfDays: '0.5',
          otHours: '1.9 hrs',
          basicText: '₹23,000',
          lopDedText: '-₹10,542',
          netSalary: '₹12,458',
        ),
        EmployeePayrollRecord(
          id: 'pay_11',
          name: 'Dr R HARITHA',
          code: 'TH013',
          role: 'Medical',
          department: 'Medical',
          initials: 'RH',
          status: 'NA',
          presentDays: '0 d',
          halfDays: '0',
          otHours: '0.0 hrs',
          basicText: '-',
          lopDedText: '-₹35,000',
          netSalary: '₹0',
        ),
        EmployeePayrollRecord(
          id: 'pay_12',
          name: 'YEDLA SRAVANTHI',
          code: 'TH014',
          role: 'Nursing',
          department: 'Nursing',
          initials: 'YS',
          status: 'NA',
          presentDays: '0 d',
          halfDays: '0',
          otHours: '0.0 hrs',
          basicText: '-',
          lopDedText: '-₹17,000',
          netSalary: '₹0',
        ),
        EmployeePayrollRecord(
          id: 'pay_13',
          name: 'GANESH SINGULURI',
          code: 'TH037',
          role: 'Digital Marketing',
          department: 'Digital Marketing',
          initials: 'GS',
          status: 'PENDING',
          presentDays: '13 d',
          halfDays: '0',
          otHours: '3.3 hrs',
          basicText: '₹15,000',
          lopDedText: '-₹7,500',
          netSalary: '₹7,500',
        ),
        EmployeePayrollRecord(
          id: 'pay_14',
          name: 'Saquiba Wasi',
          code: 'TH011',
          role: 'Developer',
          department: 'Developer',
          initials: 'SW',
          status: 'PENDING',
          presentDays: '8 d',
          halfDays: '0',
          otHours: '1.9 hrs',
          basicText: '₹19,000',
          lopDedText: '-₹13,300',
          netSalary: '₹5,700',
        ),
        EmployeePayrollRecord(
          id: 'pay_15',
          name: 'Poorna Teja',
          code: 'TH0315',
          role: 'Laboratory Medicine',
          department: 'Laboratory Medicine',
          initials: 'PT',
          status: 'NA',
          presentDays: '0 d',
          halfDays: '0',
          otHours: '0.0 hrs',
          basicText: '-',
          lopDedText: '-₹23,000',
          netSalary: '₹0',
        ),
        EmployeePayrollRecord(
          id: 'pay_16',
          name: 'M Nikitha',
          code: 'TH0316',
          role: 'Medical',
          department: 'Medical',
          initials: 'MN',
          status: 'NA',
          presentDays: '0 d',
          halfDays: '0',
          otHours: '0.0 hrs',
          basicText: '-',
          lopDedText: '-₹18,000',
          netSalary: '₹0',
        ),
        EmployeePayrollRecord(
          id: 'pay_17',
          name: 'KARANJA PRIYANKA',
          code: 'TH017',
          role: 'Sales',
          department: 'Sales',
          initials: 'KP',
          status: 'NA',
          presentDays: '0 d',
          halfDays: '0',
          otHours: '0.0 hrs',
          basicText: '-',
          lopDedText: '-₹8,000',
          netSalary: '₹0',
        ),
        EmployeePayrollRecord(
          id: 'pay_18',
          name: 'Chinthapally Sandeep',
          code: 'TH018',
          role: 'Medical',
          department: 'Medical',
          initials: 'CS',
          status: 'NA',
          presentDays: '0 d',
          halfDays: '0',
          otHours: '0.0 hrs',
          basicText: '-',
          lopDedText: '-₹25,000',
          netSalary: '₹0',
        ),
      ],
    );
  }
}
