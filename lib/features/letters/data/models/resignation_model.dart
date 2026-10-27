class ResignationModel {
  const ResignationModel({
    required this.status,
    required this.reasonCategory,
    required this.reason,
    required this.comments,
    required this.noticePeriodDays,
    required this.isShortNotice,
    required this.shortNoticeDays,
    required this.approvedBy,
    required this.rejectedReason,
    required this.adminRemark,
    this.resignationDate,
    this.lastWorkingDate,
    this.approvedAt,
  });

  final String status;
  final String reasonCategory;
  final String reason;
  final String comments;
  final int noticePeriodDays;
  final bool isShortNotice;
  final int shortNoticeDays;
  final String approvedBy;
  final String rejectedReason;
  final String adminRemark;
  final DateTime? resignationDate;
  final DateTime? lastWorkingDate;
  final DateTime? approvedAt;

  factory ResignationModel.fromJson(Map<String, dynamic> json) {
    String s(String key) => (json[key] ?? '').toString().trim();
    int i(String key) => int.tryParse('${json[key] ?? 0}') ?? 0;
    DateTime? d(String key) =>
        DateTime.tryParse('${json[key] ?? ''}')?.toLocal();

    return ResignationModel(
      status: s('status').toLowerCase(),
      reasonCategory: s('reasonCategory'),
      reason: s('reason'),
      comments: s('comments'),
      noticePeriodDays: i('noticePeriodDays'),
      isShortNotice: json['isShortNotice'] == true,
      shortNoticeDays: i('shortNoticeDays'),
      approvedBy: s('approvedBy'),
      rejectedReason: s('rejectedReason'),
      adminRemark: s('adminRemark'),
      resignationDate: d('resignationDate'),
      lastWorkingDate: d('lastWorkingDate'),
      approvedAt: d('approvedAt'),
    );
  }
}
