import 'package:flutter/material.dart';

class AdminShiftEmployeeItem {
  final String id;
  final String name;
  final String initials;
  final String designation;
  final String shiftCode; // e.g. 'Shift O'
  final String shiftName; // e.g. 'O', 'Brake Shift', 'Morning Shift'
  final String timeRange; // e.g. '05:00 PM - 11:00 PM'
  final Color avatarColor;
  final Color shiftBadgeBg;
  final Color shiftBadgeText;
  final String department;
  final bool isLive;

  const AdminShiftEmployeeItem({
    required this.id,
    required this.name,
    required this.initials,
    required this.designation,
    required this.shiftCode,
    required this.shiftName,
    required this.timeRange,
    required this.avatarColor,
    required this.shiftBadgeBg,
    required this.shiftBadgeText,
    required this.department,
    this.isLive = true,
  });

  static List<AdminShiftEmployeeItem> sampleList() {
    return const [
      AdminShiftEmployeeItem(
        id: 'shift_1',
        name: 'G NARESH KUMAR',
        initials: 'GK',
        designation: 'Phlebotomist',
        shiftCode: 'Shift O',
        shiftName: 'O',
        timeRange: '05:00 PM - 11:00 PM',
        avatarColor: Color(0xFF1E1B4B),
        shiftBadgeBg: Color(0xFFEFF6FF),
        shiftBadgeText: Color(0xFF4F46E5),
        department: 'Laboratory Medicine',
      ),
      AdminShiftEmployeeItem(
        id: 'shift_2',
        name: 'Dara Gowthami',
        initials: 'DG',
        designation: 'Phlebotomist',
        shiftCode: 'Shift E',
        shiftName: 'Brake Shift',
        timeRange: '07:00 AM - 01:30 PM',
        avatarColor: Color(0xFFF59E0B),
        shiftBadgeBg: Color(0xFFFAF5FF),
        shiftBadgeText: Color(0xFF9333EA),
        department: 'Nursing',
      ),
      AdminShiftEmployeeItem(
        id: 'shift_3',
        name: 'K Akhil Kumar',
        initials: 'KK',
        designation: 'Phlebotomist',
        shiftCode: 'Shift A',
        shiftName: 'Morning Shift',
        timeRange: '07:00 AM - 05:00 PM',
        avatarColor: Color(0xFF0D9488),
        shiftBadgeBg: Color(0xFFEFF6FF),
        shiftBadgeText: Color(0xFF2563EB),
        department: 'Laboratory Medicine',
      ),
      AdminShiftEmployeeItem(
        id: 'shift_4',
        name: 'GANESH SINGULURI',
        initials: 'GS',
        designation: 'Graphic Designer',
        shiftCode: 'Shift C',
        shiftName: 'General Day shift -II',
        timeRange: '11:00 AM - 08:00 PM',
        avatarColor: Color(0xFFEA580C),
        shiftBadgeBg: Color(0xFFFEF3C7),
        shiftBadgeText: Color(0xFFD97706),
        department: 'Digital Marketing',
      ),
      AdminShiftEmployeeItem(
        id: 'shift_5',
        name: 'SAQUIBA WASI',
        initials: 'SW',
        designation: 'MERN Stack Developer',
        shiftCode: 'Shift B',
        shiftName: 'General Day Shift',
        timeRange: '10:00 AM - 07:00 PM',
        avatarColor: Color(0xFF7C3AED),
        shiftBadgeBg: Color(0xFFEFF6FF),
        shiftBadgeText: Color(0xFF4F46E5),
        department: 'Developer',
      ),
      AdminShiftEmployeeItem(
        id: 'shift_6',
        name: 'KARDAM KUMAR',
        initials: 'KK',
        designation: 'Web Developer',
        shiftCode: 'Shift B',
        shiftName: 'General Day Shift',
        timeRange: '10:00 AM - 07:00 PM',
        avatarColor: Color(0xFF0D9488),
        shiftBadgeBg: Color(0xFFEFF6FF),
        shiftBadgeText: Color(0xFF4F46E5),
        department: 'Developer',
      ),
      AdminShiftEmployeeItem(
        id: 'shift_7',
        name: 'kejiyapari pari',
        initials: 'KP',
        designation: 'Clinical Dietician Trainee',
        shiftCode: 'Shift N',
        shiftName: 'NN',
        timeRange: '06:00 PM - 11:00 PM',
        avatarColor: Color(0xFFE11D48),
        shiftBadgeBg: Color(0xFFFAF5FF),
        shiftBadgeText: Color(0xFF9333EA),
        department: 'Medical',
      ),
      AdminShiftEmployeeItem(
        id: 'shift_8',
        name: 'Dr Abhigna jupaka',
        initials: 'DJ',
        designation: 'Manager',
        shiftCode: 'Shift O',
        shiftName: 'O',
        timeRange: '05:00 PM - 11:00 PM',
        avatarColor: Color(0xFF1E1B4B),
        shiftBadgeBg: Color(0xFFEFF6FF),
        shiftBadgeText: Color(0xFF4F46E5),
        department: 'Consultant',
      ),
      AdminShiftEmployeeItem(
        id: 'shift_9',
        name: 'Julee Parween',
        initials: 'JP',
        designation: 'MERN Stack Developer',
        shiftCode: 'Shift B',
        shiftName: 'General Day Shift',
        timeRange: '10:00 AM - 07:00 PM',
        avatarColor: Color(0xFF059669),
        shiftBadgeBg: Color(0xFFEFF6FF),
        shiftBadgeText: Color(0xFF4F46E5),
        department: 'Developer',
      ),
      AdminShiftEmployeeItem(
        id: 'shift_10',
        name: 'JATTOTH ANIL',
        initials: 'JA',
        designation: 'Senior Marketing Executive',
        shiftCode: 'Shift B',
        shiftName: 'General Day Shift',
        timeRange: '10:00 AM - 07:00 PM',
        avatarColor: Color(0xFFF59E0B),
        shiftBadgeBg: Color(0xFFEFF6FF),
        shiftBadgeText: Color(0xFF4F46E5),
        department: 'Marketing',
      ),
    ];
  }
}
