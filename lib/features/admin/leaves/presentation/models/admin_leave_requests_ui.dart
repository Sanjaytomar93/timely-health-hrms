class AdminLeaveItem {
  const AdminLeaveItem({
    required this.id,
    required this.name,
    required this.employeeCode,
    required this.designation,
    required this.department,
    required this.initials,
    required this.status,
    required this.fromDate,
    required this.toDate,
    required this.durationText,
    required this.reason,
    this.approver = '',
    this.timestamp = '',
    this.appliedText = 'Applied: Awaiting Manager Review',
    this.leaveType = '',
    this.isConvertedToCompOff = false,
  });

  final String id;
  final String name;
  final String employeeCode;
  final String designation;
  final String department;
  final String initials;
  final String status;
  final String fromDate;
  final String toDate;
  final String durationText;
  final String reason;
  final String approver;
  final String timestamp;
  final String appliedText;
  final String leaveType;
  final bool isConvertedToCompOff;

  bool get isPending => status.toLowerCase().contains('pending');
  bool get isApproved => status.toLowerCase().contains('approv');
  bool get isRejected => status.toLowerCase().contains('reject');

  AdminLeaveItem copyWith({
    String? status,
    String? approver,
    String? timestamp,
    String? leaveType,
    bool? isConvertedToCompOff,
  }) {
    return AdminLeaveItem(
      id: id,
      name: name,
      employeeCode: employeeCode,
      designation: designation,
      department: department,
      initials: initials,
      status: status ?? this.status,
      fromDate: fromDate,
      toDate: toDate,
      durationText: durationText,
      reason: reason,
      approver: approver ?? this.approver,
      timestamp: timestamp ?? this.timestamp,
      appliedText: appliedText,
      leaveType: leaveType ?? this.leaveType,
      isConvertedToCompOff: isConvertedToCompOff ?? this.isConvertedToCompOff,
    );
  }
}

class AdminLeaveRequestsUi {
  const AdminLeaveRequestsUi({
    required this.totalLeaves,
    required this.pendingLeaves,
    required this.approvedLeaves,
    required this.rejectedLeaves,
    required this.records,
    this.departments = const [],
    this.designations = const [],
  });

  final int totalLeaves;
  final int pendingLeaves;
  final int approvedLeaves;
  final int rejectedLeaves;
  final List<AdminLeaveItem> records;
  final List<String> departments;
  final List<String> designations;

  static AdminLeaveRequestsUi sample() {
    return const AdminLeaveRequestsUi(
      totalLeaves: 49,
      pendingLeaves: 2,
      approvedLeaves: 40,
      rejectedLeaves: 6,
      records: [
        AdminLeaveItem(
          id: 'lv_1',
          name: 'Jules Paraveen',
          employeeCode: 'TH045',
          designation: 'MERN Stack Developer',
          department: 'Developer',
          initials: 'JP',
          status: 'Pending',
          fromDate: '12/11/2026',
          toDate: '12/11/2026',
          durationText: '1 Day',
          reason: 'I have had fever and cold so...',
        ),
        AdminLeaveItem(
          id: 'lv_2',
          name: 'Saquiba Wasi',
          employeeCode: 'TH011',
          designation: 'MERN Stack Developer',
          department: 'Developer',
          initials: 'SW',
          status: 'Approved',
          fromDate: '02/11/2026',
          toDate: '07/11/2026',
          durationText: '6 Days',
          reason: 'Going home',
          approver: 'sailukireddy',
          timestamp: '14 Nov 2026, 05:16 pm',
        ),
        AdminLeaveItem(
          id: 'lv_3',
          name: 'Saquiba Wasi',
          employeeCode: 'TH011',
          designation: 'MERN Stack Developer',
          department: 'Developer',
          initials: 'SW',
          status: 'Approved',
          fromDate: '05/11/2026',
          toDate: '05/11/2026',
          durationText: '1 Day',
          reason: 'I was on the train so the 2h...',
          approver: 'sailukireddy',
          timestamp: '14 Nov 2026, 05:16 pm',
        ),
        AdminLeaveItem(
          id: 'lv_4',
          name: 'Sanjay Tomar',
          employeeCode: 'TH083',
          designation: 'Flutter Developer',
          department: 'Developer',
          initials: 'ST',
          status: 'Approved',
          fromDate: '11/11/2026',
          toDate: '11/11/2026',
          durationText: '1 Day',
          reason: 'Will come back from home',
          approver: 'sailukireddy',
          timestamp: '24 Nov 2026, 07:11 am',
        ),
        AdminLeaveItem(
          id: 'lv_5',
          name: 'Sanjay Tomar',
          employeeCode: 'TH083',
          designation: 'Flutter Developer',
          department: 'Developer',
          initials: 'ST',
          status: 'Approved',
          fromDate: '06/11/2026',
          toDate: '06/11/2026',
          durationText: '1 Day',
          reason: 'Going home',
          approver: 'sailukireddy',
          timestamp: '24 Nov 2026, 07:11 am',
        ),
        AdminLeaveItem(
          id: 'lv_6',
          name: 'SYKAM NANDEEP REDDY',
          employeeCode: 'TH053',
          designation: 'Ai Intern',
          department: 'Developer',
          initials: 'SN',
          status: 'Approved',
          fromDate: '10/11/2026',
          toDate: '10/11/2026',
          durationText: '1 Day',
          reason: 'Urgent work',
          approver: 'Admin',
          timestamp: '22 Nov 2026, 11:00 am',
        ),
        AdminLeaveItem(
          id: 'lv_7',
          name: 'SYKAM NANDEEP REDDY',
          employeeCode: 'TH053',
          designation: 'Ai Intern',
          department: 'Developer',
          initials: 'SN',
          status: 'Approved',
          fromDate: '03/11/2026',
          toDate: '03/11/2026',
          durationText: '1 Day',
          reason: 'Personal issue',
          approver: 'Admin',
          timestamp: '22 Nov 2026, 11:00 am',
        ),
        AdminLeaveItem(
          id: 'lv_8',
          name: 'Aarif',
          employeeCode: 'TH019',
          designation: 'Phlebotomist',
          department: 'Medical',
          initials: 'A',
          status: 'Approved',
          fromDate: '20/11/2026',
          toDate: '21/11/2026',
          durationText: '2 Days',
          reason: 'Test',
          approver: 'sailukireddy',
          timestamp: '20 Nov 2026, 04:02 pm',
        ),
        AdminLeaveItem(
          id: 'lv_9',
          name: 'KARDAM KUMAR',
          employeeCode: 'TH012',
          designation: 'Web Developer',
          department: 'Developer',
          initials: 'KK',
          status: 'Approved',
          fromDate: '12/11/2026',
          toDate: '12/11/2026',
          durationText: '1 Day',
          reason: 'Casual Leave',
          approver: 'sailukireddy',
          timestamp: '20 Oct 2026, 04:01 pm',
        ),
        AdminLeaveItem(
          id: 'lv_10',
          name: 'Pooja Verma',
          employeeCode: 'TH064',
          designation: 'Graphic Designer',
          department: 'Digital Marketing',
          initials: 'PV',
          status: 'Pending',
          fromDate: '18/11/2026',
          toDate: '19/11/2026',
          durationText: '2 Days',
          reason: 'Family function in hometown',
        ),
        AdminLeaveItem(
          id: 'lv_11',
          name: 'Rohan Sharma',
          employeeCode: 'TH027',
          designation: 'Marketing Executive',
          department: 'Marketing',
          initials: 'RS',
          status: 'Rejected',
          fromDate: '08/11/2026',
          toDate: '09/11/2026',
          durationText: '2 Days',
          reason: 'Critical campaign launch',
          approver: 'Manager',
          timestamp: '07 Nov 2026, 06:10 pm',
        ),
      ],
    );
  }
}
