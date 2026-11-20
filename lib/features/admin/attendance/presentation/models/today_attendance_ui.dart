class TodayCheckInItem {
  const TodayCheckInItem({
    required this.employeeId,
    required this.name,
    required this.department,
    required this.designation,
    required this.status,
    required this.checkInTime,
    this.checkOutTime,
    required this.totalHours,
    required this.locationMode,
    this.photoVerified = false,
    required this.dateLabel,
    required this.avatarLetter,
    this.isAvatarRed = false,
    this.photoUrl,
    this.checkInImage,
    this.checkOutImage,
    this.dateString = '',
    this.distance = '-',
    this.officeName = 'TH, Corporate.',
    this.reason = '',
    this.checkInDateTime,
  });

  final String employeeId;
  final String name;
  final String department;
  final String designation;

  final String status;
  final String checkInTime;
  final String? checkOutTime;
  final String totalHours;

  final String locationMode;
  final bool photoVerified;
  final String dateLabel;
  final String avatarLetter;
  final bool isAvatarRed;
  final String? photoUrl;
  final String? checkInImage;
  final String? checkOutImage;
  final String dateString;
  final String distance;
  final String officeName;
  final String reason;
  final DateTime? checkInDateTime;

  bool get isActive => status.toLowerCase().contains('active');
  bool get isOnsite => locationMode.toLowerCase().contains('onsite');

  static String? _resolveImageUrl(dynamic raw) {
    if (raw == null) return null;
    final str = raw.toString().trim();
    if (str.isEmpty || str == 'null') return null;
    if (str.startsWith('http://') || str.startsWith('https://')) {
      return str;
    }
    const baseUrl = 'https://api.timelyhealth.in';
    if (str.startsWith('/')) {
      return '$baseUrl$str';
    }
    return '$baseUrl/$str';
  }

  static String _formatTime(dynamic raw) {
    if (raw == null) return '-';
    final dt = DateTime.tryParse(raw.toString())?.toLocal();
    if (dt == null) return '-';
    final hour = dt.hour;
    final minute = dt.minute.toString().padLeft(2, '0');
    final ampm = hour >= 12 ? 'pm' : 'am';
    final h12 = hour % 12 == 0 ? 12 : hour % 12;
    return '${h12.toString().padLeft(2, '0')}:$minute $ampm';
  }

  static String _formatDateLabel(dynamic raw) {
    if (raw == null) return '-';
    final dt = DateTime.tryParse(raw.toString())?.toLocal();
    if (dt == null) return '-';
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }

  static String _formatHours(dynamic raw) {
    if (raw == null) return '0.00h';
    if (raw is num) {
      return '${raw.toStringAsFixed(2)}h';
    }
    final parsed = double.tryParse(raw.toString());
    if (parsed != null) {
      return '${parsed.toStringAsFixed(2)}h';
    }
    return '0.00h';
  }

  factory TodayCheckInItem.fromJson(Map<String, dynamic> json) {
    final employeeId = (json['employeeId'] ?? '').toString().trim();
    final name = (json['name'] ?? json['employeeName'] ?? '').toString().trim();
    final department = (json['employeeDepartment'] ??
            json['department'] ??
            'General')
        .toString()
        .trim();
    final designation = (json['employeeDesignation'] ??
            json['designation'] ??
            'Staff')
        .toString()
        .trim();

    final rawStatus = (json['status'] ?? '').toString().toLowerCase();
    final inTimeRaw = json['checkInTime'] ?? json['createdAt'];
    final outTimeRaw = json['checkOutTime'];

    final inTime = _formatTime(inTimeRaw);
    final outTime = outTimeRaw != null ? _formatTime(outTimeRaw) : null;

    final String status = (rawStatus.contains('out') || outTimeRaw != null)
        ? 'Logged Out'
        : 'Active';

    final checkInDt = inTimeRaw != null
        ? DateTime.tryParse(inTimeRaw.toString())?.toLocal()
        : null;

    final dateLabel = _formatDateLabel(inTimeRaw);

    final rawDateVal = json['date'] ?? inTimeRaw;
    final dt = checkInDt ??
        (rawDateVal != null
            ? DateTime.tryParse(rawDateVal.toString())?.toLocal()
            : null);
    final dateString = dt != null
        ? '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}'
        : '';

    final hrs = json['workingHours'] ?? json['totalHours'] ?? json['hours'];
    final totalHours = _formatHours(hrs);

    final bool isOnsite = json['onsite'] == true;
    final reason = (json['reason'] ?? '').toString().trim();
    final locationMode = reason.isNotEmpty
        ? (reason.toLowerCase() == 'onsite'
            ? 'Onsite'
            : (reason.toLowerCase().contains('home')
                ? 'Work From Home'
                : reason))
        : (isOnsite ? 'Onsite' : 'Work From Home');

    final letter = name.isNotEmpty ? name[0].toUpperCase() : '?';

    final checkInImg = _resolveImageUrl(json['checkInImage']);
    final checkOutImg = _resolveImageUrl(json['checkOutImage']);
    final profileImg = _resolveImageUrl(json['employeeProfilePicture'] ??
        json['profilePicture'] ??
        json['profileImage'] ??
        json['photo'] ??
        json['image']);
    final photoUrl = checkInImg ?? profileImg ?? checkOutImg;
    final hasPhoto = photoUrl != null && photoUrl.isNotEmpty;

    final dist = json['distance'];
    final distance = (dist != null) ? '${dist}m' : '-';

    return TodayCheckInItem(
      employeeId: employeeId.isEmpty ? 'N/A' : employeeId,
      name: name.isEmpty ? 'Unknown Employee' : name,
      department: department.isEmpty ? 'General' : department,
      designation: designation.isEmpty ? 'Staff' : designation,
      status: status,
      checkInTime: inTime,
      checkOutTime: outTime,
      totalHours: totalHours,
      locationMode: locationMode,
      photoVerified: hasPhoto,
      dateLabel: dateLabel,
      avatarLetter: letter,
      isAvatarRed: status == 'Logged Out',
      photoUrl: photoUrl,
      checkInImage: checkInImg,
      checkOutImage: checkOutImg,
      dateString: dateString,
      distance: distance,
      officeName: (json['officeName'] ?? 'TH, Corporate.').toString(),
      reason: reason,
      checkInDateTime: checkInDt,
    );
  }
}

class TodayAttendanceUi {
  const TodayAttendanceUi({
    required this.totalCheckIn,
    required this.activeWorking,
    required this.onsiteCount,
    required this.remoteCount,
    required this.records,
    this.departments = const [],
    this.designations = const [],
    this.totalPages = 1,
    this.currentPage = 1,
    this.totalRecords = 0,
  });

  final int totalCheckIn;
  final int activeWorking;
  final int onsiteCount;
  final int remoteCount;
  final List<TodayCheckInItem> records;
  final List<String> departments;
  final List<String> designations;
  final int totalPages;
  final int currentPage;
  final int totalRecords;

  static const empty = TodayAttendanceUi(
    totalCheckIn: 0,
    activeWorking: 0,
    onsiteCount: 0,
    remoteCount: 0,
    records: [],
  );

  TodayAttendanceUi copyWith({
    int? totalCheckIn,
    int? activeWorking,
    int? onsiteCount,
    int? remoteCount,
    List<TodayCheckInItem>? records,
    List<String>? departments,
    List<String>? designations,
    int? totalPages,
    int? currentPage,
    int? totalRecords,
  }) {
    return TodayAttendanceUi(
      totalCheckIn: totalCheckIn ?? this.totalCheckIn,
      activeWorking: activeWorking ?? this.activeWorking,
      onsiteCount: onsiteCount ?? this.onsiteCount,
      remoteCount: remoteCount ?? this.remoteCount,
      records: records ?? this.records,
      departments: departments ?? this.departments,
      designations: designations ?? this.designations,
      totalPages: totalPages ?? this.totalPages,
      currentPage: currentPage ?? this.currentPage,
      totalRecords: totalRecords ?? this.totalRecords,
    );
  }

  factory TodayAttendanceUi.fromJson(Map<String, dynamic> json) {
    final rawRecords = json['records'];
    final list = <TodayCheckInItem>[];
    if (rawRecords is List) {
      for (final r in rawRecords) {
        if (r is Map<String, dynamic>) {
          list.add(TodayCheckInItem.fromJson(r));
        }
      }
    }

    final total = list.length;
    final active = list.where((r) => r.isActive).length;
    final onsite = list.where((r) => r.isOnsite).length;
    final remote = (total - onsite).clamp(0, total);

    final depts = <String>{};
    final desigs = <String>{};
    for (final r in list) {
      if (r.department.isNotEmpty && r.department != 'General') {
        depts.add(r.department);
      }
      if (r.designation.isNotEmpty && r.designation != 'Staff') {
        desigs.add(r.designation);
      }
    }

    return TodayAttendanceUi(
      totalCheckIn: total,
      activeWorking: active,
      onsiteCount: onsite,
      remoteCount: remote,
      records: list,
      departments: depts.toList(),
      designations: desigs.toList(),
      totalRecords: total,
    );
  }

  static TodayAttendanceUi sample() => empty;
}
