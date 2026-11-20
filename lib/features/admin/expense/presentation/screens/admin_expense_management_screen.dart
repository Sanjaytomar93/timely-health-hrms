import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:timelay_health/core/routes/app_routes.dart';
import 'package:timelay_health/core/theme/portal_colors.dart';
import 'package:timelay_health/core/theme/portal_text.dart';
import 'package:timelay_health/core/theme/portal_system_ui.dart';
import 'package:timelay_health/core/widgets/portal_safe_area.dart';
import 'package:timelay_health/features/admin/expense/presentation/models/admin_expense_model.dart';
import 'package:timelay_health/features/dashboard/presentation/screens/employee_home_shell.dart';
import 'package:timelay_health/features/dashboard/presentation/widgets/employee_bottom_nav.dart';
import 'package:timelay_health/features/dashboard/presentation/widgets/home_side_drawer.dart';
import 'package:timelay_health/features/notifications/presentation/widgets/top_notification_button.dart';

class AdminExpenseManagementScreen extends StatefulWidget {
  const AdminExpenseManagementScreen({super.key});

  @override
  State<AdminExpenseManagementScreen> createState() =>
      _AdminExpenseManagementScreenState();
}

class _AdminExpenseManagementScreenState
    extends State<AdminExpenseManagementScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchCtrl = TextEditingController();

  late List<AdminExpenseItem> _records;

  DateTime? _selectedDate;
  String _monthFilter = 'Nov 2026';
  String _statusFilter = 'All'; // All, Pending, Paid
  String _activeSummaryFilter = 'ALL';

  static const months = <String>[
    'Nov 2026',
    'Oct 2026',
    'Sep 2026',
    'Aug 2026',
    'Jul 2026',
    'Jun 2026',
  ];

  static const statusOptions = <String>[
    'All',
    'Pending',
    'Paid',
  ];

  @override
  void initState() {
    super.initState();
    _records = AdminExpenseItem.sampleList();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<AdminExpenseItem> get _filteredRecords {
    final query = _searchCtrl.text.trim().toLowerCase();

    return _records.where((item) {
      if (_statusFilter == 'Pending' && item.isPaid) return false;
      if (_statusFilter == 'Paid' && !item.isPaid) return false;

      if (_activeSummaryFilter == 'PENDING' && item.isPaid) return false;
      if (_activeSummaryFilter == 'PAID' && !item.isPaid) return false;

      if (query.isNotEmpty) {
        final matchName = item.name.toLowerCase().contains(query);
        final matchCode = item.code.toLowerCase().contains(query);
        final matchDesig = item.designation.toLowerCase().contains(query);
        if (!matchName && !matchCode && !matchDesig) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2030),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: PortalColors.brand,
            onPrimary: Colors.white,
            surface: Colors.white,
            onSurface: PortalColors.heading,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickFromSheet({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color accent,
    required Color accentTint,
    required List<String> items,
    required String selected,
    required ValueChanged<String> onPick,
  }) async {
    final picked = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: PortalColors.border,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: accentTint,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: Icon(icon, size: 20, color: accent),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: portalText(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: PortalColors.heading,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            subtitle,
                            style: portalText(
                              fontSize: 12,
                              color: PortalColors.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: Color(0xFFE2E8F0)),
              for (final item in items) ...[
                ListTile(
                  title: Text(
                    item,
                    style: portalText(
                      fontSize: 14,
                      fontWeight:
                          item == selected ? FontWeight.w700 : FontWeight.w500,
                      color: item == selected ? accent : PortalColors.heading,
                    ),
                  ),
                  trailing: item == selected
                      ? Icon(Icons.check_rounded, color: accent, size: 20)
                      : null,
                  onTap: () => Navigator.of(ctx).pop(item),
                ),
              ],
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
    if (picked != null) onPick(picked);
  }

  void _showExpenseDetails(AdminExpenseItem item) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: PortalColors.border,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        color: Color(0xFF1E1B4B),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        item.initial,
                        style: portalText(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            style: portalText(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: PortalColors.heading,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${item.code} • ${item.designation}',
                            style: portalText(
                              fontSize: 12,
                              color: PortalColors.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: item.isPaid
                            ? const Color(0xFFECFDF5)
                            : const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: item.isPaid
                              ? const Color(0xFFA7F3D0)
                              : const Color(0xFFFDE68A),
                        ),
                      ),
                      child: Text(
                        item.isPaid ? '✔ Paid' : 'Pending',
                        style: portalText(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          color: item.isPaid
                              ? const Color(0xFF059669)
                              : const Color(0xFFD97706),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(height: 1, color: Color(0xFFE2E8F0)),
                const SizedBox(height: 14),
                _modalRow('Total Visits Logged', item.visits),
                _modalRow('Total Distance Traveled', item.distance),
                _modalRow('Reimbursement Rate', '₹4.0 / KM'),
                _modalRow('Reimbursement Amount', item.reimbursement),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: item.isPaid
                        ? const Color(0xFFECFDF5)
                        : const Color(0xFFFAF5FF),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: item.isPaid
                          ? const Color(0xFFA7F3D0)
                          : const Color(0xFFE9D5FF),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'TOTAL CLAIM',
                        style: portalText(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: item.isPaid
                              ? const Color(0xFF065F46)
                              : const Color(0xFF6B21A8),
                        ),
                      ),
                      Text(
                        item.reimbursement,
                        style: portalText(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: item.isPaid
                              ? const Color(0xFF059669)
                              : const Color(0xFF1E1B4B),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _modalRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: portalText(
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF64748B),
            ),
          ),
          Text(
            value,
            style: portalText(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: PortalColors.heading,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final list = _filteredRecords;

    final dateChipLabel = _selectedDate != null
        ? '${_selectedDate!.day}/${_selectedDate!.month}'
        : 'dd/mm/yyyy';

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
              // --- 1. Top Navbar ---
              _TopBar(
                onMenuTap: () => _scaffoldKey.currentState?.openDrawer(),
              ),

              // --- 2. Main Scrollable Content ---
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

                    // Filter Row (Single line, no scroll)
                    _FilterRow(
                      dateLabel: dateChipLabel,
                      monthLabel: _monthFilter,
                      statusLabel: _statusFilter,
                      dateActive: _selectedDate != null,
                      monthActive: true,
                      statusActive: _statusFilter != 'All',
                      onDateTap: _pickDate,
                      onMonthTap: () => _pickFromSheet(
                        title: 'Select Month',
                        subtitle: 'Expense tracking cycle',
                        icon: Icons.event_note_rounded,
                        accent: const Color(0xFF2563EB),
                        accentTint: const Color(0xFFEFF6FF),
                        items: months,
                        selected: _monthFilter,
                        onPick: (val) => setState(() => _monthFilter = val),
                      ),
                      onStatusTap: () => _pickFromSheet(
                        title: 'Filter Status',
                        subtitle: 'Filter claims by payment status',
                        icon: Icons.tune_rounded,
                        accent: const Color(0xFF7C3AED),
                        accentTint: const Color(0xFFF5F3FF),
                        items: statusOptions,
                        selected: _statusFilter,
                        onPick: (val) => setState(() => _statusFilter = val),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Section: SUMMARY OVERVIEW
                    Row(
                      children: [
                        const Icon(
                          Icons.insert_chart_outlined_rounded,
                          size: 16,
                          color: Color(0xFF64748B),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'SUMMARY OVERVIEW',
                          style: portalText(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF64748B),
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // 5 Stat Cards (3 in view, 4 & 5 on scroll)
                    _StatCardsRow(
                      activeFilter: _activeSummaryFilter,
                      onSelect: (val) => setState(() {
                        if (_activeSummaryFilter == val) {
                          _activeSummaryFilter = 'ALL';
                        } else {
                          _activeSummaryFilter = val;
                        }
                      }),
                    ),
                    const SizedBox(height: 20),

                    // Section: Employee Expenses Header
                    Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEEF2FF),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.receipt_long_outlined,
                            size: 17,
                            color: Color(0xFF4F46E5),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Employee Expenses',
                                style: portalText(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: PortalColors.heading,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Showing ${list.length} employees with expenses',
                                style: portalText(
                                  fontSize: 11,
                                  color: PortalColors.muted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // 9 Employee Expense Cards List
                    for (final item in list) ...[
                      _EmployeeExpenseCard(
                        item: item,
                        onViewDetails: () => _showExpenseDetails(item),
                      ),
                      const SizedBox(height: 14),
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
// 1. Top Bar
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
                  'Expense Management',
                  style: portalText(
                    fontSize: 16.5,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Monitoring & Audit',
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
                hintText: 'Search employee by name, ID, designation...',
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
// 3. Filter Row (Single line, responsive)
// ---------------------------------------------------------------------------
class _FilterRow extends StatelessWidget {
  const _FilterRow({
    required this.dateLabel,
    required this.monthLabel,
    required this.statusLabel,
    required this.dateActive,
    required this.monthActive,
    required this.statusActive,
    required this.onDateTap,
    required this.onMonthTap,
    required this.onStatusTap,
  });

  final String dateLabel;
  final String monthLabel;
  final String statusLabel;
  final bool dateActive;
  final bool monthActive;
  final bool statusActive;
  final VoidCallback onDateTap;
  final VoidCallback onMonthTap;
  final VoidCallback onStatusTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 4,
          child: _Chip(
            icon: Icons.calendar_today_outlined,
            label: dateLabel,
            active: dateActive,
            onTap: onDateTap,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          flex: 4,
          child: _Chip(
            icon: Icons.event_note_rounded,
            label: monthLabel,
            active: monthActive,
            onTap: onMonthTap,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          flex: 3,
          child: _Chip(
            icon: Icons.tune_rounded,
            label: statusLabel,
            active: statusActive,
            onTap: onStatusTap,
          ),
        ),
        const SizedBox(width: 6),
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFDBEAFE)),
          ),
          alignment: Alignment.center,
          child: const Icon(
            Icons.tune_rounded,
            size: 16,
            color: Color(0xFF2563EB),
          ),
        ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: active ? PortalColors.brandTint : Colors.white,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 7),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: active
                  ? PortalColors.brand.withValues(alpha: 0.28)
                  : PortalColors.border,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 12,
                color: active ? PortalColors.brand : PortalColors.muted,
              ),
              const SizedBox(width: 3),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: portalText(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: active ? PortalColors.brand : PortalColors.heading,
                  ),
                ),
              ),
              const SizedBox(width: 1),
              Icon(
                Icons.arrow_drop_down_rounded,
                size: 15,
                color: active ? PortalColors.brand : PortalColors.muted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 4. 5 Stat Cards (3 in view, 4 & 5 on scroll)
// ---------------------------------------------------------------------------
class _StatCardsRow extends StatelessWidget {
  const _StatCardsRow({
    required this.activeFilter,
    required this.onSelect,
  });

  final String activeFilter;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 10.0;
        final cardWidth = (constraints.maxWidth - (spacing * 2)) / 3;

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              _StatCard(
                width: cardWidth,
                title: 'TOTAL EMPLOYEES',
                value: '9',
                subtitle: 'with expenses',
                icon: Icons.trending_up_rounded,
                iconColor: const Color(0xFF475569),
                iconBg: const Color(0xFFF1F5F9),
                titleColor: const Color(0xFF64748B),
                isSelected: activeFilter == 'ALL',
                onTap: () => onSelect('ALL'),
              ),
              const SizedBox(width: spacing),
              _StatCard(
                width: cardWidth,
                title: 'TOTAL EXPENSES',
                value: '₹3,763.6',
                subtitle: 'total claimed',
                icon: Icons.account_balance_wallet_outlined,
                iconColor: const Color(0xFF475569),
                iconBg: const Color(0xFFF1F5F9),
                titleColor: const Color(0xFF64748B),
                isSelected: activeFilter == 'EXPENSES',
                onTap: () => onSelect('EXPENSES'),
              ),
              const SizedBox(width: spacing),
              _StatCard(
                width: cardWidth,
                title: 'TOTAL VISITS',
                value: '78',
                subtitle: 'completed visits',
                icon: Icons.location_on_outlined,
                iconColor: const Color(0xFF475569),
                iconBg: const Color(0xFFF1F5F9),
                titleColor: const Color(0xFF64748B),
                isSelected: activeFilter == 'VISITS',
                onTap: () => onSelect('VISITS'),
              ),
              const SizedBox(width: spacing),
              _StatCard(
                width: cardWidth,
                title: 'TOTAL DISTANCE',
                value: '1,084.1 KM',
                subtitle: 'traveled distance',
                icon: Icons.route_outlined,
                iconColor: const Color(0xFF475569),
                iconBg: const Color(0xFFF1F5F9),
                titleColor: const Color(0xFF64748B),
                isSelected: activeFilter == 'DISTANCE',
                onTap: () => onSelect('DISTANCE'),
              ),
              const SizedBox(width: spacing),
              _StatCard(
                width: cardWidth,
                title: 'PENDING CLAIMS',
                value: '8',
                subtitle: '₹3,615.6 pending',
                icon: Icons.access_time_rounded,
                iconColor: const Color(0xFF475569),
                iconBg: const Color(0xFFF1F5F9),
                titleColor: const Color(0xFF64748B),
                isSelected: activeFilter == 'PENDING',
                onTap: () => onSelect('PENDING'),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.width,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.titleColor,
    required this.isSelected,
    required this.onTap,
  });

  final double width;
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final Color titleColor;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: width,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? const Color(0xFF4F46E5) : PortalColors.border,
              width: isSelected ? 1.5 : 1,
            ),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: portalText(
                        fontSize: 8.5,
                        fontWeight: FontWeight.w800,
                        color: titleColor,
                        letterSpacing: 0.1,
                        height: 1.15,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: iconBg,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    alignment: Alignment.center,
                    child: Icon(icon, size: 12, color: iconColor),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  value,
                  style: portalText(
                    fontSize: value.startsWith('₹') ? 14 : 18,
                    fontWeight: FontWeight.w800,
                    color: PortalColors.heading,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: portalText(
                  fontSize: 8.5,
                  fontWeight: FontWeight.w500,
                  color: PortalColors.muted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 5. Employee Expense Card
// ---------------------------------------------------------------------------
class _EmployeeExpenseCard extends StatelessWidget {
  const _EmployeeExpenseCard({
    required this.item,
    required this.onViewDetails,
  });

  final AdminExpenseItem item;
  final VoidCallback onViewDetails;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Row 1: Avatar, Name, Code, Designation Badge, Status Pill, Eye Icon
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Color(0xFF1E1B4B),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    item.initial,
                    style: portalText(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
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
                        'ID: ${item.code}',
                        style: portalText(
                          fontSize: 10.5,
                          color: PortalColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: const Color(0xFFE2E8F0),
                      width: 0.8,
                    ),
                  ),
                  child: Text(
                    item.designation,
                    style: portalText(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF475569),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: item.isPaid
                        ? const Color(0xFFECFDF5)
                        : const Color(0xFFFFFBEB),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: item.isPaid
                          ? const Color(0xFFA7F3D0)
                          : const Color(0xFFFDE68A),
                      width: 0.8,
                    ),
                  ),
                  child: Text(
                    item.isPaid ? '✔ Paid' : 'Pending',
                    style: portalText(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                      color: item.isPaid
                          ? const Color(0xFF059669)
                          : const Color(0xFFB45309),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: onViewDetails,
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(7),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.remove_red_eye_outlined,
                      size: 16,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Row 2: 3 Metric Pills (Visits, Distance, Reimbursement)
            Row(
              children: [
                Expanded(
                  child: _metricBox(
                    title: 'Visits',
                    value: item.visits,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _metricBox(
                    title: 'Distance',
                    value: item.distance,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _metricBox(
                    title: 'Reimbursement',
                    value: item.reimbursement,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _metricBox({
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 9),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: portalText(
              fontSize: 9.5,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 3),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: portalText(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: PortalColors.heading,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
