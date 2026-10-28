import 'package:flutter/material.dart';
import 'package:timelay_health/features/camp/presentation/theme/camp_colors.dart';

// --------------------------------------------------------------------------
// Enums
// --------------------------------------------------------------------------

enum PatientGender { male, female, other }

enum PatientCampStatus { test, campLabel, na }

// --------------------------------------------------------------------------
// Patient UI model
// --------------------------------------------------------------------------

class PatientUi {
  const PatientUi({
    required this.initials,
    required this.name,
    required this.age,
    required this.gender,
    required this.phone,
    this.campTag,
    this.statusTag,
    this.avatarBg,
    this.avatarFg,
  });

  final String initials;
  final String name;
  final int age;
  final PatientGender gender;
  final String phone;

  /// e.g. 'Camp-7', 'Camp-3'. Null means no camp tag.
  final String? campTag;

  /// e.g. 'Test'. Null means no status tag.
  final String? statusTag;

  final Color? avatarBg;
  final Color? avatarFg;

  String get genderLabel => switch (gender) {
        PatientGender.male => 'Male',
        PatientGender.female => 'Female',
        PatientGender.other => 'Other',
      };

  String get ageGenderLine => '$age yrs · $genderLabel';

  Color get resolvedAvatarBg =>
      avatarBg ??
      switch (gender) {
        PatientGender.female => const Color(0xFFE1F5EE),
        PatientGender.male => const Color(0xFFE6F1FB),
        PatientGender.other => CampColors.primaryTint,
      };

  Color get resolvedAvatarFg =>
      avatarFg ??
      switch (gender) {
        PatientGender.female => const Color(0xFF0F6E56),
        PatientGender.male => const Color(0xFF185FA5),
        PatientGender.other => const Color(0xFF534AB7),
      };
}

// --------------------------------------------------------------------------
// Stats UI
// --------------------------------------------------------------------------

class PatientStatUi {
  const PatientStatUi({
    required this.value,
    required this.label,
    required this.iconBg,
    required this.iconFg,
    required this.icon,
  });

  final String value;
  final String label;
  final Color iconBg;
  final Color iconFg;
  final IconData icon;
}

// --------------------------------------------------------------------------
// Page-level model
// --------------------------------------------------------------------------

class PatientListUi {
  const PatientListUi({
    required this.totalPatients,
    required this.registeredCamps,
    required this.stats,
    required this.patients,
  });

  final int totalPatients;
  final int registeredCamps;
  final List<PatientStatUi> stats;
  final List<PatientUi> patients;

  String get subtitle => '$totalPatients registered across all camps';

  // -------------------------------------------------------------------------
  // Demo data matching the Figma spec
  // -------------------------------------------------------------------------
  static PatientListUi demo() {
    return PatientListUi(
      totalPatients: 9,
      registeredCamps: 6,
      stats: const [
        PatientStatUi(
          value: '9',
          label: 'Total patients',
          iconBg: CampColors.primaryTint,
          iconFg: CampColors.primary,
          icon: Icons.people_alt_outlined,
        ),
        PatientStatUi(
          value: '5',
          label: 'Female',
          iconBg: Color(0xFFE1F5EE),
          iconFg: Color(0xFF0F6E56),
          icon: Icons.female_rounded,
        ),
        PatientStatUi(
          value: '4',
          label: 'Male',
          iconBg: Color(0xFFE6F1FB),
          iconFg: Color(0xFF185FA5),
          icon: Icons.male_rounded,
        ),
        PatientStatUi(
          value: '6',
          label: 'Camps covered',
          iconBg: Color(0xFFFEF3E2),
          iconFg: Color(0xFFEF9F27),
          icon: Icons.location_on_outlined,
        ),
      ],
      patients: const [
        PatientUi(
          initials: 'EA',
          name: 'Eswari Alluri',
          age: 27,
          gender: PatientGender.female,
          phone: '6300596228',
          statusTag: 'Test',
          avatarBg: Color(0xFFF0EFFE),
          avatarFg: Color(0xFF534AB7),
        ),
        PatientUi(
          initials: 'JU',
          name: 'Julee',
          age: 1,
          gender: PatientGender.female,
          phone: '8051281283',
          avatarBg: Color(0xFFE1F5EE),
          avatarFg: Color(0xFF0F6E56),
        ),
        PatientUi(
          initials: 'RY',
          name: 'Ramu Yadav',
          age: 30,
          gender: PatientGender.male,
          phone: '0987564543',
          statusTag: 'Test',
          avatarBg: Color(0xFFFEF3E2),
          avatarFg: Color(0xFF854F0B),
        ),
        PatientUi(
          initials: 'XY',
          name: 'Xyx',
          age: 30,
          gender: PatientGender.male,
          phone: '7856343267',
          campTag: 'Camp-7',
          avatarBg: Color(0xFFE6F1FB),
          avatarFg: Color(0xFF185FA5),
        ),
        PatientUi(
          initials: 'PV',
          name: 'Pavan',
          age: 25,
          gender: PatientGender.male,
          phone: '8967543223',
          campTag: 'Camp-7',
          avatarBg: Color(0xFFFCEBEB),
          avatarFg: Color(0xFFA32D2D),
        ),
        PatientUi(
          initials: 'WS',
          name: 'Wasi',
          age: 23,
          gender: PatientGender.female,
          phone: '918521630432',
          campTag: 'Camp-3',
          avatarBg: Color(0xFFFBEAF0),
          avatarFg: Color(0xFF993556),
        ),
        PatientUi(
          initials: 'KU',
          name: 'Kumar',
          age: 23,
          gender: PatientGender.male,
          phone: '918688860223',
          campTag: 'Camp-3',
          avatarBg: Color(0xFFF0EFFE),
          avatarFg: Color(0xFF534AB7),
        ),
        PatientUi(
          initials: 'SN',
          name: 'Saniya',
          age: 15,
          gender: PatientGender.female,
          phone: '6898746532',
          campTag: 'Camp-2',
          avatarBg: Color(0xFFE1F5EE),
          avatarFg: Color(0xFF0F6E56),
        ),
        PatientUi(
          initials: 'SB',
          name: 'Saba',
          age: 20,
          gender: PatientGender.female,
          phone: '9865323265',
          campTag: 'Camp-2',
          avatarBg: Color(0xFFFEF3E2),
          avatarFg: Color(0xFF854F0B),
        ),
      ],
    );
  }
}
