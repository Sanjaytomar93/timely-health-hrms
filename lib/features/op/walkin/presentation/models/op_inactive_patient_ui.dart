class OpInactivePatientUi {
  const OpInactivePatientUi({
    required this.id,
    required this.name,
    required this.age,
    required this.gender,
    required this.phone,
    required this.doctor,
    required this.lastVisitDate,
    this.lastVisitTime,
    required this.deactivatedSince,
    required this.paymentStatus,
    this.city = 'N/A',
    this.amount = 0,
  });

  final String id;
  final String name;
  final int age;
  final String gender;
  final String phone;
  final String doctor;
  final String lastVisitDate;
  final String? lastVisitTime;
  final String deactivatedSince;
  final String paymentStatus; // 'Due', 'Paid', 'Partial', 'Pending'
  final String city;
  final int amount;

  String get initial {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '#';
    final parts = trimmed.split(RegExp(r'\s+'));
    for (final p in parts.reversed) {
      if (p.isEmpty) continue;
      final c = p[0].toUpperCase();
      if (RegExp(r'[A-Z]').hasMatch(c)) return c;
    }
    return trimmed[0].toUpperCase();
  }

  bool get isDue => paymentStatus.toUpperCase() == 'DUE';
  bool get isPaid => paymentStatus.toUpperCase() == 'PAID';
  bool get isPartial => paymentStatus.toUpperCase() == 'PARTIAL';
  bool get isPending => paymentStatus.toUpperCase() == 'PENDING';

  factory OpInactivePatientUi.fromJson(Map<String, dynamic> json) {
    final title = (json['patientTitle']?.toString() ?? '').trim();
    final pName = (json['patientName']?.toString() ?? '').trim();
    final displayName = title.isNotEmpty
        ? (pName.toLowerCase().startsWith(title.toLowerCase())
            ? pName
            : '$title $pName')
        : (pName.isNotEmpty ? pName : 'Unknown Patient');

    final slot = json['slotDetails'] is Map<String, dynamic>
        ? json['slotDetails'] as Map<String, dynamic>
        : null;

    final docName = slot?['doctorName']?.toString().trim();
    final doctor = (docName != null && docName.isNotEmpty) ? docName : 'N/A';

    final apptDateRaw = json['appointmentDate']?.toString().trim() ??
        slot?['date']?.toString().trim();
    final lastVisitDate = _formatDate(apptDateRaw);

    final startTime = slot?['startTime']?.toString().trim() ?? '';
    final endTime = slot?['endTime']?.toString().trim() ?? '';
    String? lastVisitTime;
    if (startTime.isNotEmpty && endTime.isNotEmpty) {
      lastVisitTime = '$startTime - $endTime';
    } else if (startTime.isNotEmpty) {
      lastVisitTime = startTime;
    }

    final dateDeactivatedRaw = json['updatedAt']?.toString().trim() ??
        json['bookedAt']?.toString().trim() ??
        json['createdAt']?.toString().trim();
    final deactivatedSince = _formatDateTime(dateDeactivatedRaw);

    final paymentStatus = (json['paymentStatus']?.toString() ?? 'Due').trim();

    final cityRaw = json['patientCity']?.toString().trim();
    final city = (cityRaw != null && cityRaw.isNotEmpty) ? cityRaw : 'N/A';

    int amount = 0;
    final val = json['finalPayable'] ??
        json['finalPayableAmount'] ??
        json['balanceAmount'] ??
        json['totalAmount'] ??
        json['totalFee'] ??
        json['servicesTotal'];
    if (val is num) {
      amount = val.round();
    } else if (val is String) {
      amount = double.tryParse(val)?.round() ?? 0;
    }

    return OpInactivePatientUi(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      name: displayName,
      age: int.tryParse(json['patientAge']?.toString() ?? '') ?? 0,
      gender: (json['patientGender']?.toString().trim().isNotEmpty == true)
          ? json['patientGender'].toString().trim()
          : 'N/A',
      phone: json['patientPhone']?.toString().trim() ?? '',
      doctor: doctor,
      lastVisitDate: lastVisitDate,
      lastVisitTime: lastVisitTime,
      deactivatedSince: deactivatedSince,
      paymentStatus: paymentStatus,
      city: city,
      amount: amount,
    );
  }

  static String _formatDate(String? raw) {
    if (raw == null || raw.trim().isEmpty) return 'N/A';
    try {
      final dt = DateTime.tryParse(raw.trim());
      if (dt != null) {
        return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
      }
    } catch (_) {}
    return raw;
  }

  static String _formatDateTime(String? raw) {
    if (raw == null || raw.trim().isEmpty) return 'N/A';
    try {
      final dt = DateTime.tryParse(raw.trim())?.toLocal();
      if (dt != null) {
        final d =
            '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
        final t =
            '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
        return '$d $t';
      }
    } catch (_) {}
    return raw;
  }

  static const List<OpInactivePatientUi> demoPatients = [
    OpInactivePatientUi(
      id: '6af9624b0983f737bbf71e6b',
      name: 'Mr. SHAMEEK',
      age: 25,
      gender: 'Male',
      phone: '7781999831',
      doctor: 'DR VAMSHI KRISHNA',
      lastVisitDate: '15/11/2026',
      lastVisitTime: '01:35 PM - 01:55 PM',
      deactivatedSince: '15/11/2026 13:19',
      paymentStatus: 'Due',
      city: 'N/A',
      amount: 300,
    ),
    OpInactivePatientUi(
      id: '6aedd311e6e9cd07dbbeeb7b',
      name: 'Ms. LAKSHMI',
      age: 26,
      gender: 'Female',
      phone: '8074693193',
      doctor: 'N/A',
      lastVisitDate: '06/11/2026',
      deactivatedSince: '06/11/2026 18:46',
      paymentStatus: 'Paid',
      city: 'N/A',
      amount: 1086,
    ),
    OpInactivePatientUi(
      id: '6ae7421de6e9cd07dbbe123a',
      name: 'Mr. NARESH',
      age: 24,
      gender: 'Male',
      phone: '9381372575',
      doctor: 'N/A',
      lastVisitDate: '01/11/2026',
      deactivatedSince: '01/11/2026 19:11',
      paymentStatus: 'Due',
      city: 'N/A',
      amount: 300,
    ),
    OpInactivePatientUi(
      id: '6a65421de6e9cd07dbbe456b',
      name: 'Miss SWETHA',
      age: 21,
      gender: 'Female',
      phone: '9392600089',
      doctor: 'DR VAMSHI KRISHNA',
      lastVisitDate: '09/10/2026',
      lastVisitTime: '07:50 PM - 08:10 PM',
      deactivatedSince: '09/10/2026 19:42',
      paymentStatus: 'Due',
      city: 'N/A',
      amount: 300,
    ),
    OpInactivePatientUi(
      id: '6a421de6e9cd07dbbe456c',
      name: 'Mr. Saidulu Konch...',
      age: 30,
      gender: 'Male',
      phone: '9014424455',
      doctor: 'Dr Abhigna jupaka',
      lastVisitDate: '25/09/2026',
      lastVisitTime: '10:25 AM - 10:45 AM',
      deactivatedSince: '22/09/2026 16:25',
      paymentStatus: 'Paid',
      city: 'N/A',
      amount: 0,
    ),
    OpInactivePatientUi(
      id: '6a321de6e9cd07dbbe456d',
      name: 'Mr. RAMESH REDDY',
      age: 34,
      gender: 'Male',
      phone: '9848012345',
      doctor: 'Dr Abhigna jupaka',
      lastVisitDate: '18/09/2026',
      deactivatedSince: '18/09/2026 11:20',
      paymentStatus: 'Due',
      city: 'N/A',
      amount: 0,
    ),
    OpInactivePatientUi(
      id: '6a221de6e9cd07dbbe456e',
      name: 'Mrs. ANITHA',
      age: 29,
      gender: 'Female',
      phone: '9700123456',
      doctor: 'DR VAMSHI KRISHNA',
      lastVisitDate: '10/09/2026',
      deactivatedSince: '10/09/2026 15:40',
      paymentStatus: 'Due',
      city: 'N/A',
      amount: 0,
    ),
  ];
}
