class PunchRecordItem {
  const PunchRecordItem({
    required this.employeeId,
    required this.name,
    required this.department,
    required this.designation,
    required this.status,
    required this.isRemote,
    this.hasPhotoBadge = true,
    required this.inTime,
    this.outTime,
    required this.dateLabel,
    required this.totalHours,
    required this.breakHours,
    required this.distance,
    required this.mode,
    required this.avatarLetter,
    this.checkInImage,
    this.checkOutImage,
    this.officeName = 'TH, Corporate.',
    this.reason = '',
    this.checkInDateTime,
    this.breakMinutes = 0,
    this.photoUrl,
    this.dateString = '',
  });

  final String employeeId;
  final String name;
  final String department;
  final String designation;

  final String status;
  final bool isRemote;
  final bool hasPhotoBadge;
  final String inTime;
  final String? outTime;
  final String dateLabel;
  final String totalHours;
  final String breakHours;
  final int breakMinutes;
  final String distance;

  final String mode;
  final String avatarLetter;
  final String? checkInImage;
  final String? checkOutImage;
  final String? photoUrl;
  final String dateString;
  final String officeName;
  final String reason;
  final DateTime? checkInDateTime;

  bool get isActive =>
      status.toLowerCase().contains('active') ||
      status.toLowerCase().contains('check');

  bool get isAvatarRed =>
      status.toLowerCase().contains('logged') ||
      status.toLowerCase().contains('out') ||
      avatarLetter == 'S';

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
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final w = weekdays[dt.weekday - 1];
    final m = months[dt.month - 1];
    return '$w • ${dt.day} $m';
  }

  static String _formatHours(num? hours) {
    if (hours == null || hours <= 0) return '0h 0m';
    final h = hours.floor();
    final m = ((hours - h) * 60).round();
    return '${h}h ${m}m';
  }

  factory PunchRecordItem.fromJson(Map<String, dynamic> json) {
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
    final bool isOnsite = json['onsite'] == true;
    final bool isRemote = !isOnsite;

    final inTimeRaw = json['checkInTime'] ?? json['createdAt'];
    final outTimeRaw = json['checkOutTime'] ??
        (rawStatus.contains('out') ? json['updatedAt'] : null);

    final inTime = _formatTime(inTimeRaw);
    final outTime = outTimeRaw != null ? _formatTime(outTimeRaw) : null;

    final String status = (rawStatus.contains('check') ||
            rawStatus.contains('in') ||
            rawStatus == 'active' ||
            outTime == null)
        ? 'Active'
        : 'Logged Out';

    final checkInDt = inTimeRaw != null
        ? DateTime.tryParse(inTimeRaw.toString())?.toLocal()
        : null;

    final dateLabel = _formatDateLabel(inTimeRaw);

    final num? hrs = (json['totalHours'] ?? json['hours'] ?? json['workingHours'])
        as num?;
    final totalHours = _formatHours(hrs);

    final breakMins = json['totalBreakMinutes'];
    final int breakMinutesInt = (breakMins is num && breakMins > 0) ? breakMins.toInt() : 0;
    final breakHours =
        breakMinutesInt > 0 ? '${breakMinutesInt}m' : '-';

    final dist = json['distance'];
    final distance = (dist != null) ? '${dist}m' : '-';

    final reason = (json['reason'] ?? '').toString().trim();
    final mode = reason.isNotEmpty
        ? (reason.toLowerCase() == 'onsite'
            ? 'WFO'
            : (reason.toLowerCase().contains('home')
                ? 'WFH'
                : reason))
        : (isOnsite ? 'WFO' : 'WFH');

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

    final rawDateVal = json['date'] ?? inTimeRaw;
    final dt = checkInDt ??
        (rawDateVal != null
            ? DateTime.tryParse(rawDateVal.toString())?.toLocal()
            : null);
    final dateString = dt != null
        ? '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}'
        : '';

    return PunchRecordItem(
      employeeId: employeeId.isEmpty ? 'N/A' : employeeId,
      name: name.isEmpty ? 'Unknown Employee' : name,
      department: department.isEmpty ? 'General' : department,
      designation: designation.isEmpty ? 'Staff' : designation,
      status: status,
      isRemote: isRemote,
      hasPhotoBadge: hasPhoto,
      inTime: inTime,
      outTime: outTime,
      dateLabel: dateLabel,
      totalHours: totalHours,
      breakHours: breakHours,
      breakMinutes: breakMinutesInt,
      distance: distance,
      mode: mode,
      avatarLetter: letter,
      checkInImage: checkInImg,
      checkOutImage: checkOutImg,
      photoUrl: photoUrl,
      dateString: dateString,
      officeName: (json['officeName'] ?? 'TH, Corporate.').toString(),
      reason: reason,
      checkInDateTime: checkInDt,
    );
  }
}

class AttendanceRecordsUi {
  const AttendanceRecordsUi({
    required this.totalRecords,
    required this.onsiteEntries,
    required this.activeEntries,
    required this.remoteEntries,
    required this.loggedOutEntries,
    required this.records,
    this.departments = const [],
    this.designations = const [],
    this.totalPages = 1,
    this.currentPage = 1,
    this.totalEmployees = 0,
    this.limit = 15,
  });

  final int totalRecords;
  final int onsiteEntries;
  final int activeEntries;
  final int remoteEntries;
  final int loggedOutEntries;
  final List<PunchRecordItem> records;
  final List<String> departments;
  final List<String> designations;
  final int totalPages;
  final int currentPage;
  final int totalEmployees;
  final int limit;

  String get formattedTotalBreakTime {
    int totalMins = 0;
    for (final r in records) {
      totalMins += r.breakMinutes;
    }
    if (totalMins <= 0) return '-';
    final h = totalMins ~/ 60;
    final m = totalMins % 60;
    if (h > 0) {
      return m > 0 ? '${h}h ${m}m' : '${h}h';
    }
    return '${m}m';
  }

  AttendanceRecordsUi copyWith({
    int? totalRecords,
    int? onsiteEntries,
    int? activeEntries,
    int? remoteEntries,
    int? loggedOutEntries,
    List<PunchRecordItem>? records,
    List<String>? departments,
    List<String>? designations,
    int? totalPages,
    int? currentPage,
    int? totalEmployees,
    int? limit,
  }) {
    return AttendanceRecordsUi(
      totalRecords: totalRecords ?? this.totalRecords,
      onsiteEntries: onsiteEntries ?? this.onsiteEntries,
      activeEntries: activeEntries ?? this.activeEntries,
      remoteEntries: remoteEntries ?? this.remoteEntries,
      loggedOutEntries: loggedOutEntries ?? this.loggedOutEntries,
      records: records ?? this.records,
      departments: departments ?? this.departments,
      designations: designations ?? this.designations,
      totalPages: totalPages ?? this.totalPages,
      currentPage: currentPage ?? this.currentPage,
      totalEmployees: totalEmployees ?? this.totalEmployees,
      limit: limit ?? this.limit,
    );
  }

  static const empty = AttendanceRecordsUi(
    totalRecords: 0,
    onsiteEntries: 0,
    activeEntries: 0,
    remoteEntries: 0,
    loggedOutEntries: 0,
    records: [],
  );

  factory AttendanceRecordsUi.fromJson(Map<String, dynamic> json) {
    final meta = json['meta'] is Map<String, dynamic>
        ? json['meta'] as Map<String, dynamic>
        : const <String, dynamic>{};
    final stats = json['stats'] is Map<String, dynamic>
        ? json['stats'] as Map<String, dynamic>
        : const <String, dynamic>{};

    final rawRecords = json['records'];
    final recordsList = <PunchRecordItem>[];
    if (rawRecords is List) {
      for (final r in rawRecords) {
        if (r is Map<String, dynamic>) {
          recordsList.add(PunchRecordItem.fromJson(r));
        }
      }
    }

    final total = (stats['totalRecords'] ??
            meta['totalRecords'] ??
            recordsList.length) as int? ??
        recordsList.length;
    final onsite = (stats['onsiteEntries'] as num?)?.toInt() ?? 0;
    final active = (stats['activeCheckedIn'] as num?)?.toInt() ?? 0;
    final remote = (total - onsite).clamp(0, total);
    final loggedOut = (total - active).clamp(0, total);

    final depts = <String>[];
    if (meta['departments'] is List) {
      for (final d in meta['departments']) {
        if (d != null) depts.add(d.toString());
      }
    }

    final desigs = <String>[];
    if (meta['designations'] is List) {
      for (final d in meta['designations']) {
        if (d != null) desigs.add(d.toString());
      }
    }

    return AttendanceRecordsUi(
      totalRecords: total,
      onsiteEntries: onsite,
      activeEntries: active,
      remoteEntries: remote,
      loggedOutEntries: loggedOut,
      records: recordsList,
      departments: depts,
      designations: desigs,
      totalPages: (meta['totalPages'] as num?)?.toInt() ?? 1,
      currentPage: (meta['currentPage'] as num?)?.toInt() ?? 1,
      totalEmployees: (meta['totalEmployees'] as num?)?.toInt() ?? 0,
      limit: (meta['limit'] as num?)?.toInt() ?? 15,
    );
  }

  static AttendanceRecordsUi sample() {
    return const AttendanceRecordsUi(
      totalRecords: 275,
      onsiteEntries: 215,
      activeEntries: 25,
      remoteEntries: 60,
      loggedOutEntries: 250,
      records: [],
    );
  }
}
