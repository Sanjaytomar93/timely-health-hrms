import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:timelay_health/core/routes/app_routes.dart';
import 'package:timelay_health/core/theme/portal_colors.dart';
import 'package:timelay_health/core/theme/portal_text.dart';
import 'package:timelay_health/core/theme/portal_system_ui.dart';
import 'package:timelay_health/core/widgets/portal_safe_area.dart';
import 'package:timelay_health/features/admin/shift/presentation/models/admin_shift_model.dart';
import 'package:timelay_health/features/dashboard/presentation/screens/employee_home_shell.dart';
import 'package:timelay_health/features/dashboard/presentation/widgets/employee_bottom_nav.dart';
import 'package:timelay_health/features/dashboard/presentation/widgets/home_side_drawer.dart';
import 'package:timelay_health/features/notifications/presentation/widgets/top_notification_button.dart';

class AdminShiftManagementScreen extends StatefulWidget {
  const AdminShiftManagementScreen({super.key});

  @override
  State<AdminShiftManagementScreen> createState() =>
      _AdminShiftManagementScreenState();
}

class _AdminShiftManagementScreenState
    extends State<AdminShiftManagementScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchCtrl = TextEditingController();

  String _deptFilter = 'All Departments';
  String _desigFilter = 'All Designations';
  String _shiftFilter = 'All Shifts';

  static const List<String> departments = [
    'All Departments',
    'Laboratory Medicine',
    'Nursing',
    'Digital Marketing',
    'Developer',
    'Medical',
    'Marketing',
    'Sales',
    'Consultant',
  ];

  static const List<String> designations = [
    'All Designations',
    'Ai Intern',
    'Clinical Dietician Trainee',
    'Consultant',
    'Digital Marketing Executive',
    'Doctor',
    'Employee',
    'Flutter Developer',
    'General Manager',
    'Graphic Designer',
    'HR Intern',
    'HR Manager',
    'MERN Stack Developer',
    'Manager',
    'Manger',
    'Marketing',
    'Pharmacist',
    'Phlebotomist',
    'SMM & SEO Executive',
    'Sales Executive',
    'Senior Marketing Executive',
    'Staff Nurse',
    'Team Lead',
    'Web Developer',
  ];

  static const List<String> shifts = [
    'All Shifts',
    'Shift A',
    'Shift B',
    'Shift C',
    'Shift D',
    'Shift E',
    'Shift F',
    'Shift G',
    'Shift H',
    'Shift I',
    'Shift J',
    'Shift K',
    'Shift L',
    'Shift M',
    'Shift N',
    'Shift O',
    'Shift P',
    'Shift Q',
    'Shift R',
    'Shift S',
    'Shift T',
  ];

  final List<AdminShiftEmployeeItem> _allRecords =
      AdminShiftEmployeeItem.sampleList();

  List<AdminShiftEmployeeItem> get _filteredRecords {
    final query = _searchCtrl.text.trim().toLowerCase();
    return _allRecords.where((item) {
      if (query.isNotEmpty) {
        final matchesName = item.name.toLowerCase().contains(query);
        final matchesDesig = item.designation.toLowerCase().contains(query);
        final matchesShift = item.shiftCode.toLowerCase().contains(query) ||
            item.shiftName.toLowerCase().contains(query);
        if (!matchesName && !matchesDesig && !matchesShift) return false;
      }
      if (_deptFilter != 'All Departments' && item.department != _deptFilter) {
        return false;
      }
      if (_desigFilter != 'All Designations' &&
          item.designation != _desigFilter) {
        return false;
      }
      if (_shiftFilter != 'All Shifts' && item.shiftCode != _shiftFilter) {
        return false;
      }
      return true;
    }).toList();
  }

  void _pickFromSheet({
    required String title,
    required List<String> items,
    required String selected,
    required ValueChanged<String> onPick,
  }) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 10, bottom: 6),
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                child: Row(
                  children: [
                    Text(
                      title,
                      style: portalText(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: PortalColors.heading,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 20),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: Color(0xFFF1F5F9)),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: items.length,
                  itemBuilder: (_, index) {
                    final it = items[index];
                    final isSel = it == selected;
                    return ListTile(
                      dense: true,
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
                      title: Text(
                        it,
                        style: portalText(
                          fontSize: 13.5,
                          fontWeight:
                              isSel ? FontWeight.w800 : FontWeight.w500,
                          color: isSel
                              ? const Color(0xFF4F46E5)
                              : PortalColors.heading,
                        ),
                      ),
                      trailing: isSel
                          ? const Icon(
                              Icons.check_circle_rounded,
                              size: 18,
                              color: Color(0xFF4F46E5),
                            )
                          : null,
                      onTap: () {
                        Navigator.pop(ctx);
                        onPick(it);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final list = _filteredRecords;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: PortalSystemUi.darkStatusBar,
      child: Scaffold(
        key: _scaffoldKey,
        drawer: const HomeSideDrawer(),
        drawerScrimColor: PortalColors.brand.withValues(alpha: 0.28),
        backgroundColor: const Color(0xFFF8FAFC),
        body: PortalSafeArea(
          bottom: false,
          statusBarColor: PortalColors.brand,
          child: Column(
            children: [
              // 1. Top Navbar matching exact style
              _TopBar(
                onMenuTap: () => _scaffoldKey.currentState?.openDrawer(),
              ),

              // 2. Scrollable Body
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                  children: [
                    // Search Bar
                    _SearchField(
                      controller: _searchCtrl,
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 12),

                    // Filter Row: [All Departments ▾] [All Designations ▾] [All Shifts ▾]
                    _FilterRow(
                      deptLabel: _deptFilter,
                      desigLabel: _desigFilter,
                      shiftLabel: _shiftFilter,
                      departments: departments,
                      designations: designations,
                      shifts: shifts,
                      onDeptSelected: (v) => setState(() => _deptFilter = v),
                      onDesigSelected: (v) => setState(() => _desigFilter = v),
                      onShiftSelected: (v) => setState(() => _shiftFilter = v),
                    ),
                    const SizedBox(height: 18),

                    // Section: OVERVIEW METRICS
                    Row(
                      children: [
                        Text(
                          'OVERVIEW METRICS',
                          style: portalText(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF64748B),
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // 4 Overview Metric Cards (2x2 Grid)
                    Row(
                      children: [
                        Expanded(
                          child: _MetricCard(
                            title: 'TOTAL EMPLOYEES',
                            value: '25',
                            subtitle: 'Employees',
                            icon: Icons.groups_outlined,
                            iconColor: const Color(0xFF059669),
                            iconBg: const Color(0xFFECFDF5),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _MetricCard(
                            title: 'ACTIVE SHIFTS',
                            value: '20',
                            subtitle: 'Shifts Live',
                            icon: Icons.calendar_view_day_rounded,
                            iconColor: const Color(0xFF4F46E5),
                            iconBg: const Color(0xFFEEF2FF),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _MetricCard(
                            title: 'ASSIGNED SHIFTS',
                            value: '25',
                            subtitle: 'Shift Slots',
                            icon: Icons.access_time_rounded,
                            iconColor: const Color(0xFF7C3AED),
                            iconBg: const Color(0xFFFAF5FF),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _MetricCard(
                            title: 'ON SHIFT TODAY',
                            value: '25',
                            valueSuffix: ' / 65',
                            subtitle: 'Active Today',
                            subtitleColor: const Color(0xFF059669),
                            icon: Icons.verified_user_outlined,
                            iconColor: const Color(0xFFD97706),
                            iconBg: const Color(0xFFFEF3C7),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Section Header: Shift Schedule
                    Row(
                      children: [
                        Container(
                          width: 4,
                          height: 16,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E1B4B),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Shift Schedule',
                          style: portalText(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: PortalColors.heading,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${list.length} Shown',
                            style: portalText(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: Color(0xFF10B981),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              'Live Monitoring',
                              style: portalText(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF0D9488),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // 10 Employee Shift Cards
                    for (final item in list) ...[
                      _ShiftEmployeeCard(item: item),
                      const SizedBox(height: 12),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: EmployeeBottomNav(
          currentIndex: 2,
          onTap: (i) => EmployeeHomeShell.goToTab(context, i),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 1. Top Navbar (Identical to Payroll & Expense)
// ---------------------------------------------------------------------------
class _TopBar extends StatelessWidget {
  const _TopBar({required this.onMenuTap});

  final VoidCallback onMenuTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: PortalColors.brand,
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 14),
      child: Row(
        children: [
          GestureDetector(
            onTap: onMenuTap,
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: PortalColors.brandTint,
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: SvgPicture.asset(
                'assets/icons/top_bar/ic_top_menu.svg',
                width: 18,
                height: 18,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Shift Management',
                  style: portalText(
                    fontSize: 16.5,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Monitoring & Schedules',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: portalText(
                    fontSize: 11.5,
                    color: Colors.white.withValues(alpha: 0.72),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const TopNotificationButton(),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 2. Search Field
// ---------------------------------------------------------------------------
class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.onChanged,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: PortalColors.border),
      ),
      child: Row(
        children: [
          const Icon(Icons.search_rounded, size: 20, color: PortalColors.muted),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              textAlign: TextAlign.start,
              style: portalText(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: PortalColors.heading,
              ),
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                hintText: 'Search employee, shift, designation...',
                hintStyle: portalText(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                  color: PortalColors.muted,
                ),
              ),
            ),
          ),
          if (controller.text.isNotEmpty)
            GestureDetector(
              onTap: () {
                controller.clear();
                onChanged('');
              },
              behavior: HitTestBehavior.opaque,
              child: const Icon(
                Icons.close_rounded,
                size: 18,
                color: PortalColors.muted,
              ),
            )
          else
            const Icon(
              Icons.filter_alt_outlined,
              size: 18,
              color: PortalColors.muted,
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 3. Filter Row (3 Chips in single row)
// ---------------------------------------------------------------------------
class _FilterRow extends StatelessWidget {
  const _FilterRow({
    required this.deptLabel,
    required this.desigLabel,
    required this.shiftLabel,
    required this.departments,
    required this.designations,
    required this.shifts,
    required this.onDeptSelected,
    required this.onDesigSelected,
    required this.onShiftSelected,
  });

  final String deptLabel;
  final String desigLabel;
  final String shiftLabel;
  final List<String> departments;
  final List<String> designations;
  final List<String> shifts;
  final ValueChanged<String> onDeptSelected;
  final ValueChanged<String> onDesigSelected;
  final ValueChanged<String> onShiftSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 4,
          child: _FilterChipDropdown(
            selected: deptLabel,
            items: departments,
            onSelected: onDeptSelected,
            minWidth: 170,
            maxWidth: 220,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          flex: 4,
          child: _FilterChipDropdown(
            selected: desigLabel,
            items: designations,
            onSelected: onDesigSelected,
            minWidth: 200,
            maxWidth: 260,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          flex: 3,
          child: _FilterChipDropdown(
            selected: shiftLabel,
            items: shifts,
            onSelected: onShiftSelected,
            minWidth: 140,
            maxWidth: 180,
          ),
        ),
      ],
    );
  }
}

class _FilterChipDropdown extends StatelessWidget {
  const _FilterChipDropdown({
    required this.selected,
    required this.items,
    required this.onSelected,
    this.minWidth = 160,
    this.maxWidth = 240,
  });

  final String selected;
  final List<String> items;
  final ValueChanged<String> onSelected;
  final double minWidth;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        popupMenuTheme: PopupMenuThemeData(
          color: const Color(0xFF6B7280).withValues(alpha: 0.96),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          elevation: 12,
        ),
      ),
      child: PopupMenuButton<String>(
        tooltip: selected,
        padding: EdgeInsets.zero,
        offset: const Offset(0, 42),
        constraints: BoxConstraints(
          maxHeight: 380,
          minWidth: minWidth,
          maxWidth: maxWidth,
        ),
        onSelected: onSelected,
        itemBuilder: (ctx) {
          return items.map((item) {
            final isCurrent = item == selected;
            return PopupMenuItem<String>(
              value: item,
              height: 36,
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color:
                      isCurrent ? const Color(0xFF007AFF) : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    if (isCurrent) ...[
                      const Icon(
                        Icons.check_rounded,
                        size: 15,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 6),
                    ],
                    Expanded(
                      child: Text(
                        item,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: portalText(
                          fontSize: 12.5,
                          fontWeight:
                              isCurrent ? FontWeight.w700 : FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList();
        },
        child: Container(
          height: 38,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: PortalColors.border),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  selected,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: portalText(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: PortalColors.heading,
                  ),
                ),
              ),
              const SizedBox(width: 2),
              const Icon(
                Icons.arrow_drop_down_rounded,
                size: 18,
                color: PortalColors.muted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 4. Metric Card (2x2 Grid) - Compact & Impressive
// ---------------------------------------------------------------------------
class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.title,
    required this.value,
    this.valueSuffix,
    required this.subtitle,
    this.subtitleColor,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
  });

  final String title;
  final String value;
  final String? valueSuffix;
  final String subtitle;
  final Color? subtitleColor;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: PortalColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 1.5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: portalText(
                    fontSize: 8.5,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF64748B),
                    letterSpacing: 0.1,
                  ),
                ),
              ),
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(7),
                ),
                alignment: Alignment.center,
                child: Icon(icon, size: 13, color: iconColor),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: portalText(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: PortalColors.heading,
                  letterSpacing: -0.4,
                ),
              ),
              if (valueSuffix != null) ...[
                const SizedBox(width: 3),
                Text(
                  valueSuffix!,
                  style: portalText(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: PortalColors.muted,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: portalText(
              fontSize: 9.5,
              fontWeight: FontWeight.w600,
              color: subtitleColor ?? PortalColors.muted,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 5. Employee Shift Card
// ---------------------------------------------------------------------------
class _ShiftEmployeeCard extends StatelessWidget {
  const _ShiftEmployeeCard({required this.item});

  final AdminShiftEmployeeItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 1.5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top Row: Avatar with live dot, Name, Designation, Shift Badge
          Row(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: item.avatarColor,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      item.initials,
                      style: portalText(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.8),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: portalText(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: PortalColors.heading,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.designation,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: portalText(
                        fontSize: 11,
                        color: PortalColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: item.shiftBadgeBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  item.shiftCode,
                  style: portalText(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    color: item.shiftBadgeText,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Bottom Info Box: [ NAME: <shiftName> ] [ 🕒 <timeRange> ]
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFF1F5F9)),
            ),
            child: Row(
              children: [
                RichText(
                  text: TextSpan(
                    style: portalText(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                    ),
                    children: [
                      const TextSpan(
                        text: 'NAME: ',
                        style: TextStyle(color: Color(0xFF94A3B8)),
                      ),
                      TextSpan(
                        text: item.shiftName,
                        style: const TextStyle(color: Color(0xFF334155)),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    const Icon(
                      Icons.access_time_rounded,
                      size: 13,
                      color: Color(0xFF64748B),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      item.timeRange,
                      style: portalText(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF334155),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
