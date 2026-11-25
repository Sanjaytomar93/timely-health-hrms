import 'package:flutter/material.dart';
import 'package:timelay_health/core/theme/portal_colors.dart';

enum LeadStatus {
  newLead('New', Color(0xFFFEF3C7), Color(0xFFD97706), Color(0xFFFDE68A)),
  contacted('Contacted', PortalColors.brandTint, PortalColors.brand, PortalColors.border),
  converted('Converted', Color(0xFFECFDF5), Color(0xFF059669), Color(0xFFA7F3D0)),
  rejected('Rejected', Color(0xFFFEF2F2), Color(0xFFDC2626), Color(0xFFFECACA));

  const LeadStatus(this.label, this.bgColor, this.textColor, this.borderColor);

  final String label;
  final Color bgColor;
  final Color textColor;
  final Color borderColor;
}

class LeadCounts {
  final int totalLeads;
  final int newLeads;
  final int contacted;
  final int converted;
  final int rejected;

  const LeadCounts({
    this.totalLeads = 0,
    this.newLeads = 0,
    this.contacted = 0,
    this.converted = 0,
    this.rejected = 0,
  });

  factory LeadCounts.fromJson(Map<String, dynamic> json) {
    return LeadCounts(
      totalLeads: (json['totalLeads'] as num?)?.toInt() ?? 0,
      newLeads: (json['new'] as num?)?.toInt() ?? 0,
      contacted: (json['contacted'] as num?)?.toInt() ?? 0,
      converted: (json['converted'] as num?)?.toInt() ?? 0,
      rejected: (json['rejected'] as num?)?.toInt() ?? 0,
    );
  }
}

class DigitalLead {
  final String id;
  final String leadNumber;
  final String name;
  final String source;
  final String businessType;
  final String lookingFor;
  final String phone;
  final String email;
  final String date;
  final DateTime? createdAtDate;
  final LeadStatus status;
  final String state;
  final String city;
  final String pinCode;
  final Color avatarBgColor;

  const DigitalLead({
    required this.id,
    required this.leadNumber,
    required this.name,
    required this.source,
    required this.businessType,
    required this.lookingFor,
    required this.phone,
    required this.email,
    required this.date,
    this.createdAtDate,
    required this.status,
    required this.state,
    required this.city,
    required this.pinCode,
    required this.avatarBgColor,
  });

  DigitalLead copyWith({
    String? id,
    String? leadNumber,
    String? name,
    String? source,
    String? businessType,
    String? lookingFor,
    String? phone,
    String? email,
    String? date,
    DateTime? createdAtDate,
    LeadStatus? status,
    String? state,
    String? city,
    String? pinCode,
    Color? avatarBgColor,
  }) {
    return DigitalLead(
      id: id ?? this.id,
      leadNumber: leadNumber ?? this.leadNumber,
      name: name ?? this.name,
      source: source ?? this.source,
      businessType: businessType ?? this.businessType,
      lookingFor: lookingFor ?? this.lookingFor,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      date: date ?? this.date,
      createdAtDate: createdAtDate ?? this.createdAtDate,
      status: status ?? this.status,
      state: state ?? this.state,
      city: city ?? this.city,
      pinCode: pinCode ?? this.pinCode,
      avatarBgColor: avatarBgColor ?? this.avatarBgColor,
    );
  }

  factory DigitalLead.fromJson(Map<String, dynamic> json, [int index = 0]) {
    final id = (json['_id'] ?? json['id'] ?? '').toString();
    final name = (json['name'] ?? '').toString().trim();
    final businessName =
        (json['businessName'] ?? json['source'] ?? '').toString().trim();
    final source = businessName.isNotEmpty ? businessName : 'Web Lead';
    final businessType = (json['businessType'] ?? '').toString().trim();
    final lookingFor = (json['lookingFor'] ?? '').toString().trim();
    final phone = (json['phone'] ?? '').toString().trim();
    final email = (json['email'] ?? '').toString().trim();
    final rawStatus = (json['status'] ?? '').toString().trim().toLowerCase();

    LeadStatus status;
    if (rawStatus == 'contacted' || rawStatus.contains('contact')) {
      status = LeadStatus.contacted;
    } else if (rawStatus == 'converted' || rawStatus.contains('convert')) {
      status = LeadStatus.converted;
    } else if (rawStatus == 'rejected' ||
        rawStatus == 'deleted' ||
        rawStatus.contains('reject')) {
      status = LeadStatus.rejected;
    } else {
      status = LeadStatus.newLead;
    }

    final createdAtStr = (json['createdAt'] ?? '').toString();
    final createdAtDate = DateTime.tryParse(createdAtStr)?.toLocal();
    final date = _formatDate(createdAtDate, createdAtStr);

    const palette = [
      PortalColors.brand,
      PortalColors.brandLight,
      Color(0xFF0D9488),
      Color(0xFF7C3AED),
      Color(0xFF0284C7),
      Color(0xFFD97706),
      Color(0xFF059669),
    ];
    final color =
        palette[(index >= 0 ? index : id.hashCode.abs()) % palette.length];

    return DigitalLead(
      id: id,
      leadNumber: '#${index + 1}',
      name: name.isNotEmpty ? name : 'Lead',
      source: source,
      businessType: businessType.isNotEmpty ? businessType : 'General',
      lookingFor: lookingFor.isNotEmpty ? lookingFor : 'Consultation',
      phone: phone,
      email: email,
      date: date,
      createdAtDate: createdAtDate,
      status: status,
      state: 'Telangana',
      city: 'Hyderabad',
      pinCode: '500081',
      avatarBgColor: color,
    );
  }

  static String _formatDate(DateTime? dt, String fallback) {
    if (dt == null) return fallback.isNotEmpty ? fallback : 'Recent';
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    final day = dt.day.toString().padLeft(2, '0');
    final month = months[dt.month - 1];
    final year = dt.year;
    final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final min = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour >= 12 ? 'pm' : 'am';
    return '$day $month $year — $hour:$min $ampm';
  }

  static List<DigitalLead> sampleLeads() {
    return [
      const DigitalLead(
        id: '6ae2f15d2aeedd13271d5177',
        leadNumber: '#1',
        name: 'Manideep',
        source: 'Meta',
        businessType: 'Other',
        lookingFor: 'Social Media Marketing',
        phone: '9879879876',
        email: 'mani@meta.in',
        date: '29 Oct 2026 — 12:40 pm',
        status: LeadStatus.contacted,
        state: 'Telangana',
        city: 'Hyderabad',
        pinCode: '500081',
        avatarBgColor: PortalColors.brand,
      ),
      DigitalLead(
        id: '6ae2e52e2aeedd1327192181',
        leadNumber: '#2',
        name: 'Manideep',
        source: 'TIMELY HEALTH',
        businessType: 'Doctor / Specialist',
        lookingFor: 'Meta Ads',
        phone: '7896321235',
        email: 'test@gmail.com',
        date: '29 Oct 2026 — 11:48 am',
        status: LeadStatus.converted,
        state: 'Telangana',
        city: 'Hyderabad',
        pinCode: '500073',
        avatarBgColor: PortalColors.brandLight,
      ),
      const DigitalLead(
        id: '6ae1be05d618285da4fc0b0f',
        leadNumber: '#3',
        name: 'test',
        source: 'test',
        businessType: 'Clinic',
        lookingFor: 'Google Ads',
        phone: '7896333456',
        email: 'test@gmail.com',
        date: '28 Oct 2026 — 02:49 pm',
        status: LeadStatus.newLead,
        state: 'AP.',
        city: 'Vijayawada',
        pinCode: '520001',
        avatarBgColor: Color(0xFF0D9488),
      ),
      DigitalLead(
        id: '6ae07281ceb1632a4e73c660',
        leadNumber: '#4',
        name: 'krishna',
        source: 'fahh',
        businessType: 'Hospital',
        lookingFor: 'Lead Generation',
        phone: '+917386003329',
        email: 'thiruvallurirohitkumar@gmail.com',
        date: '27 Oct 2026 — 03:14 pm',
        status: LeadStatus.newLead,
        state: 'Telangana',
        city: 'Secunderabad',
        pinCode: '500003',
        avatarBgColor: PortalColors.brandLight,
      ),
      DigitalLead(
        id: '6adb56b7583aca783fb44ec2',
        leadNumber: '#5',
        name: 'Virat',
        source: 'one 8',
        businessType: 'Other',
        lookingFor: 'Full Digital Marketing',
        phone: '9848855763',
        email: 'kardamkumar13@gmail.com',
        date: '23 Oct 2026 — 06:14 pm',
        status: LeadStatus.converted,
        state: 'Telangana',
        city: 'Warangal',
        pinCode: '506001',
        avatarBgColor: PortalColors.brand,
      ),
      DigitalLead(
        id: '6ad1d6b1d5c6f89640a52a25',
        leadNumber: '#6',
        name: 'Bharath',
        source: 'Bharath Origin',
        businessType: 'Other',
        lookingFor: 'Social Media Marketing',
        phone: '8106873678',
        email: 'bharathorigin@gmail.com',
        date: '16 Oct 2026 — 01:18 pm',
        status: LeadStatus.contacted,
        state: 'AP.',
        city: 'Visakhapatnam',
        pinCode: '530001',
        avatarBgColor: PortalColors.brandLight,
      ),
      const DigitalLead(
        id: '6abf3309a952b4a2aa3c9247',
        leadNumber: '#7',
        name: 'Saquiba Wasi',
        source: 'Timely Health Clinic',
        businessType: 'Clinic',
        lookingFor: 'Full Digital Marketing',
        phone: '9876543210',
        email: 'saquiba.test@gmail.com',
        date: '02 Oct 2026 — 09:58 am',
        status: LeadStatus.converted,
        state: 'Telangana',
        city: 'Hyderabad',
        pinCode: '500081',
        avatarBgColor: Color(0xFF059669),
      ),
      DigitalLead(
        id: '6abe66601259727d3132a9b7',
        leadNumber: '#8',
        name: 'kumar',
        source: 'Iryax',
        businessType: 'Other',
        lookingFor: 'Full Digital Marketing',
        phone: '8688860223',
        email: 'kardamkumar13@gmail.com',
        date: '01 Oct 2026 — 07:25 pm',
        status: LeadStatus.converted,
        state: 'Telangana',
        city: 'Hyderabad',
        pinCode: '500073',
        avatarBgColor: PortalColors.brandLight,
      ),
    ];
  }
}
