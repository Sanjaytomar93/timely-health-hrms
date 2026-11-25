import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:timelay_health/core/theme/portal_colors.dart';
import 'package:timelay_health/core/theme/portal_text.dart';
import 'package:timelay_health/core/theme/portal_system_ui.dart';
import 'package:timelay_health/core/widgets/portal_safe_area.dart';
import 'package:timelay_health/core/widgets/shimmer.dart';
import 'package:timelay_health/features/admin/expense/data/datasources/admin_expense_remote_datasource.dart';
import 'package:timelay_health/features/admin/expense/domain/failures/admin_expense_failure.dart';
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
  final AdminExpenseRemoteDataSource _remote = AdminExpenseRemoteDataSource();

  static const periodOptions = <String>['All', 'Today', 'Month', 'Year'];

  static const months = <String>[
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  AdminExpenseUi _ui = AdminExpenseUi.empty;
  bool _ready = false;
  String? _error;

  DateTime? _selectedDate;
  String _periodFilter = 'All';
  String _monthKey = '';
  String _monthFilter = 'All Months';
  late String _yearFilter;
  late List<String> _years;

  static String _keyFor(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}';

  String _fmtChipDate(DateTime d) => '${d.day}/${d.month}';

  String? _monthKeyFromName(String name) {
    final idx = months.indexWhere((m) => m == name);
    if (idx < 0) return null;
    final now = DateTime.now();
    return _keyFor(DateTime(now.year, idx + 1, 1));
  }

  @override
  void initState() {
    super.initState();
    _yearFilter = '${DateTime.now().year}';
    _years = List.generate(5, (i) => '${DateTime.now().year - i}');
    _loadExpenses();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadExpenses() async {
    setState(() {
      _ready = false;
      _error = null;
    });
    try {
      String? month;
      String? year;
      DateTime? onlyDate;

      switch (_periodFilter) {
        case 'Today':
          final now = DateTime.now();
          month = _keyFor(now);
          onlyDate = DateTime(now.year, now.month, now.day);
        case 'Month':
          if (_monthFilter != 'All Months' && _monthKey.isNotEmpty) {
            month = _monthKey;
          }
        case 'Year':
          year = _yearFilter;
        case 'All':
        default:
          if (_monthFilter != 'All Months' && _monthKey.isNotEmpty) {
            month = _monthKey;
          }
          break;
      }

      if (_selectedDate != null && _periodFilter != 'Today') {
        onlyDate = DateTime(
          _selectedDate!.year,
          _selectedDate!.month,
          _selectedDate!.day,
        );
        month ??= _keyFor(_selectedDate!);
      }

      final json = await _remote.getAllExpenses(month: month, year: year);
      if (!mounted) return;
      setState(() {
        _ui = AdminExpenseUi.fromApiJson(json, onlyDate: onlyDate);
        _ready = true;
      });
    } on AdminExpenseFailure catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _ready = true;
        _ui = AdminExpenseUi.empty;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to load expenses.';
        _ready = true;
        _ui = AdminExpenseUi.empty;
      });
    }
  }

  List<AdminExpenseItem> get _filteredRecords {
    final query = _searchCtrl.text.trim().toLowerCase();

    return _ui.records.where((item) {
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
    final picked = await showModalBottomSheet<DateTime>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) => _SingleDatePickerSheet(initialDate: _selectedDate),
    );
    if (picked == null || !mounted) return;
    setState(() => _selectedDate = picked);
    _loadExpenses();
  }

  Future<void> _pickMonth() async {
    final picked = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) => _MonthOnlyPickerSheet(selected: _monthFilter),
    );
    if (picked == null || !mounted) return;
    setState(() {
      _monthFilter = picked;
      if (picked == 'All Months') {
        _monthKey = '';
        if (_periodFilter == 'Month') _periodFilter = 'All';
      } else {
        _monthKey = _monthKeyFromName(picked) ?? '';
        if (_periodFilter == 'All') _periodFilter = 'Month';
      }
    });
    _loadExpenses();
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
    final stats = _ui.stats;
    final dateChipLabel =
        _selectedDate != null ? _fmtChipDate(_selectedDate!) : 'Date';
    final monthChipLabel = _periodFilter == 'Year'
        ? _yearFilter
        : (_monthFilter != 'All Months' ? _monthFilter : 'Month');

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
              _TopBar(
                onMenuTap: () => _scaffoldKey.currentState?.openDrawer(),
              ),
              Expanded(
                child: !_ready
                    ? const AdminListShimmer(statCount: 3, cardCount: 5)
                    : RefreshIndicator(
                        color: PortalColors.brand,
                        onRefresh: _loadExpenses,
                        child: ListView(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                          children: [
                            _SearchField(
                              controller: _searchCtrl,
                              onChanged: (_) => setState(() {}),
                            ),
                            const SizedBox(height: 12),
                            _FilterRow(
                              dateLabel: dateChipLabel,
                              monthLabel: monthChipLabel,
                              periodLabel: _periodFilter,
                              dateActive: _selectedDate != null,
                              monthActive: _periodFilter == 'Year' ||
                                  _monthFilter != 'All Months',
                              periodActive: _periodFilter != 'All',
                              onDateTap: _pickDate,
                              onDateClear: () {
                                setState(() => _selectedDate = null);
                                _loadExpenses();
                              },
                              onMonthTap: () {
                                if (_periodFilter == 'Year') {
                                  _pickFromSheet(
                                    title: 'Select Year',
                                    subtitle: 'Expense year filter',
                                    icon: Icons.calendar_month_rounded,
                                    accent: const Color(0xFF2563EB),
                                    accentTint: const Color(0xFFEFF6FF),
                                    items: _years,
                                    selected: _yearFilter,
                                    onPick: (val) {
                                      setState(() {
                                        _yearFilter = val;
                                        _periodFilter = 'Year';
                                      });
                                      _loadExpenses();
                                    },
                                  );
                                  return;
                                }
                                _pickMonth();
                              },
                              onMonthClear: () {
                                setState(() {
                                  _monthFilter = 'All Months';
                                  _monthKey = '';
                                  if (_periodFilter == 'Month') {
                                    _periodFilter = 'All';
                                  }
                                });
                                _loadExpenses();
                              },
                              onPeriodTap: () => _pickFromSheet(
                                title: 'Select Period',
                                subtitle: 'All / Today / Month / Year',
                                icon: Icons.tune_rounded,
                                accent: const Color(0xFF7C3AED),
                                accentTint: const Color(0xFFF5F3FF),
                                items: periodOptions,
                                selected: _periodFilter,
                                onPick: (val) {
                                  setState(() {
                                    _periodFilter = val;
                                    if (val == 'All' || val == 'Year') {
                                      _selectedDate = null;
                                    } else if (val == 'Today') {
                                      _selectedDate = DateTime.now();
                                    }
                                  });
                                  _loadExpenses();
                                },
                              ),
                              onPeriodClear: () {
                                setState(() {
                                  _periodFilter = 'All';
                                  _selectedDate = null;
                                  _monthFilter = 'All Months';
                                  _monthKey = '';
                                });
                                _loadExpenses();
                              },
                            ),
                            const SizedBox(height: 18),
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
                            _StatCardsRow(stats: stats),
                            const SizedBox(height: 20),
                            if (_error != null) ...[
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFEF2F2),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: const Color(0xFFFECACA),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.error_outline_rounded,
                                      color: Color(0xFFDC2626),
                                      size: 18,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        _error!,
                                        style: portalText(
                                          fontSize: 12,
                                          color: const Color(0xFFB91C1C),
                                        ),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: _loadExpenses,
                                      child: Text(
                                        'Retry',
                                        style: portalText(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: PortalColors.brand,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 14),
                            ],
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                            if (list.isEmpty && _error == null)
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 40),
                                child: Center(
                                  child: Text(
                                    'No expenses found for this period',
                                    style: portalText(
                                      fontSize: 13,
                                      color: PortalColors.muted,
                                    ),
                                  ),
                                ),
                              ),
                            for (final item in list) ...[
                              _EmployeeExpenseCard(
                                item: item,
                                onViewDetails: () =>
                                    _showExpenseDetails(item),
                              ),
                              const SizedBox(height: 14),
                            ],
                          ],
                        ),
                      ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: EmployeeBottomNav(
          currentIndex: 3,
          onTap: (i) => EmployeeHomeShell.goToTab(context, i),
        ),
      ),
    );
  }
}

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

class _FilterRow extends StatelessWidget {
  const _FilterRow({
    required this.dateLabel,
    required this.monthLabel,
    required this.periodLabel,
    required this.dateActive,
    required this.monthActive,
    required this.periodActive,
    required this.onDateTap,
    required this.onMonthTap,
    required this.onPeriodTap,
    this.onDateClear,
    this.onMonthClear,
    this.onPeriodClear,
  });

  final String dateLabel;
  final String monthLabel;
  final String periodLabel;
  final bool dateActive;
  final bool monthActive;
  final bool periodActive;
  final VoidCallback onDateTap;
  final VoidCallback onMonthTap;
  final VoidCallback onPeriodTap;
  final VoidCallback? onDateClear;
  final VoidCallback? onMonthClear;
  final VoidCallback? onPeriodClear;

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
            onClear: onDateClear,
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
            onClear: onMonthClear,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          flex: 3,
          child: _Chip(
            icon: Icons.tune_rounded,
            label: periodLabel,
            active: periodActive,
            onTap: onPeriodTap,
            onClear: onPeriodClear,
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
    this.onClear,
  });

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final color = active ? PortalColors.brand : PortalColors.muted;
    return Material(
      color: active ? PortalColors.brandTint : Colors.white,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          height: 34,
          padding: const EdgeInsets.symmetric(horizontal: 6),
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
              Icon(icon, size: 12, color: color),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: portalText(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: active ? PortalColors.brand : PortalColors.heading,
                  ),
                ),
              ),
              if (active && onClear != null)
                GestureDetector(
                  onTap: onClear,
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    padding: const EdgeInsets.all(1.5),
                    decoration: BoxDecoration(
                      color: PortalColors.brand.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      size: 11,
                      color: PortalColors.brand,
                    ),
                  ),
                )
              else
                Icon(Icons.arrow_drop_down, size: 14, color: color),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCardsRow extends StatelessWidget {
  const _StatCardsRow({required this.stats});

  final AdminExpenseStats stats;

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
                value: stats.totalEmployeesLabel,
                subtitle: 'with expenses',
                icon: Icons.show_chart_rounded,
                iconColor: const Color(0xFF2563EB),
                iconBg: const Color(0xFFEFF6FF),
              ),
              const SizedBox(width: spacing),
              _StatCard(
                width: cardWidth,
                title: 'TOTAL VISITS',
                value: stats.totalVisitsLabel,
                subtitle: 'business visits',
                icon: Icons.add_location_alt_outlined,
                iconColor: const Color(0xFF16A34A),
                iconBg: const Color(0xFFF0FDF4),
              ),
              const SizedBox(width: spacing),
              _StatCard(
                width: cardWidth,
                title: 'TOTAL DISTANCE',
                value: stats.totalDistanceLabel,
                subtitle: 'kilometers traveled',
                icon: Icons.location_on_outlined,
                iconColor: const Color(0xFFEA580C),
                iconBg: const Color(0xFFFFF7ED),
              ),
              const SizedBox(width: spacing),
              _StatCard(
                width: cardWidth,
                title: 'TOTAL REIMBURSEMENT',
                value: stats.totalReimbursementLabel,
                subtitle: 'total amount',
                icon: Icons.payments_outlined,
                iconColor: const Color(0xFFDC2626),
                iconBg: const Color(0xFFFEF2F2),
              ),
              const SizedBox(width: spacing),
              _StatCard(
                width: cardWidth,
                title: "TODAY'S AMOUNT",
                value: stats.todayTotalLabel,
                subtitle: 'added today',
                icon: Icons.calendar_today_outlined,
                iconColor: const Color(0xFF16A34A),
                iconBg: const Color(0xFFF0FDF4),
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
  });

  final double width;
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
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
                    color: const Color(0xFF64748B),
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
    );
  }
}

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


class _SingleDatePickerSheet extends StatefulWidget {
  const _SingleDatePickerSheet({this.initialDate});

  final DateTime? initialDate;

  @override
  State<_SingleDatePickerSheet> createState() => _SingleDatePickerSheetState();
}

class _SingleDatePickerSheetState extends State<_SingleDatePickerSheet> {
  late DateTime _viewMonth;
  DateTime? _selected;

  static const _weekDays = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
  static const _monthNames = _AdminExpenseManagementScreenState.months;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialDate;
    final base = _selected ?? DateTime.now();
    _viewMonth = DateTime(base.year, base.month);
  }

  DateTime _only(DateTime d) => DateTime(d.year, d.month, d.day);

  String _label(DateTime? d) {
    if (d == null) return 'Select date';
    return '${d.day.toString().padLeft(2, '0')} ${_monthNames[d.month - 1].substring(0, 3)} ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final daysInMonth =
        DateTime(_viewMonth.year, _viewMonth.month + 1, 0).day;
    final firstWeekday =
        DateTime(_viewMonth.year, _viewMonth.month, 1).weekday % 7;
    final cells = <DateTime?>[
      ...List<DateTime?>.filled(firstWeekday, null),
      ...List.generate(
        daysInMonth,
        (i) => DateTime(_viewMonth.year, _viewMonth.month, i + 1),
      ),
    ];
    while (cells.length % 7 != 0) {
      cells.add(null);
    }

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
            const SizedBox(height: 14),
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: PortalColors.brandTint,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.calendar_today_outlined,
                    size: 19,
                    color: PortalColors.brand,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Select Date',
                        style: portalText(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: PortalColors.heading,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        _label(_selected),
                        style: portalText(
                          fontSize: 11.5,
                          color: PortalColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded, size: 20),
                  color: PortalColors.muted,
                  splashRadius: 18,
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: PortalColors.border),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => setState(() {
                          _viewMonth = DateTime(
                            _viewMonth.year,
                            _viewMonth.month - 1,
                          );
                        }),
                        icon: const Icon(Icons.chevron_left_rounded),
                        color: PortalColors.heading,
                        splashRadius: 18,
                      ),
                      Expanded(
                        child: Text(
                          '${_monthNames[_viewMonth.month - 1]} ${_viewMonth.year}',
                          textAlign: TextAlign.center,
                          style: portalText(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w800,
                            color: PortalColors.heading,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => setState(() {
                          _viewMonth = DateTime(
                            _viewMonth.year,
                            _viewMonth.month + 1,
                          );
                        }),
                        icon: const Icon(Icons.chevron_right_rounded),
                        color: PortalColors.heading,
                        splashRadius: 18,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      for (final d in _weekDays)
                        Expanded(
                          child: Center(
                            child: Text(
                              d,
                              style: portalText(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: PortalColors.muted,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: cells.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7,
                      mainAxisSpacing: 4,
                      crossAxisSpacing: 2,
                    ),
                    itemBuilder: (_, i) {
                      final day = cells[i];
                      if (day == null) return const SizedBox.shrink();

                      final isSelected = _selected != null &&
                          _only(day) == _only(_selected!);
                      final isToday = _only(day) == _only(DateTime.now());

                      return GestureDetector(
                        onTap: () => setState(() => _selected = _only(day)),
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected
                                ? PortalColors.brand
                                : Colors.transparent,
                            shape: BoxShape.circle,
                            border: isToday && !isSelected
                                ? Border.all(
                                    color: PortalColors.brand
                                        .withValues(alpha: 0.35),
                                  )
                                : null,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '${day.day}',
                            style: portalText(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: isSelected
                                  ? Colors.white
                                  : PortalColors.heading,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() => _selected = null);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: PortalColors.muted,
                      side: const BorderSide(color: PortalColors.border),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Clear',
                      style: portalText(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: PortalColors.muted,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _selected == null
                        ? null
                        : () => Navigator.of(context).pop(_selected),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: PortalColors.brand,
                      disabledBackgroundColor:
                          PortalColors.brand.withValues(alpha: 0.35),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Apply Date',
                      style: portalText(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MonthOnlyPickerSheet extends StatelessWidget {
  const _MonthOnlyPickerSheet({required this.selected});

  final String selected;

  static const _months = _AdminExpenseManagementScreenState.months;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final availableMonths = _months.sublist(0, now.month);

    return _FilterGridPickerSheet(
      title: 'Select Month',
      subtitle: 'Choose a month to filter expenses',
      icon: Icons.calendar_month_rounded,
      allLabel: 'All Months',
      items: availableMonths,
      selected: selected,
      highlightItem: availableMonths.last,
    );
  }
}

class _FilterGridPickerSheet extends StatelessWidget {
  const _FilterGridPickerSheet({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.allLabel,
    required this.items,
    required this.selected,
    this.highlightItem,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final String allLabel;
  final List<String> items;
  final String selected;
  final String? highlightItem;

  @override
  Widget build(BuildContext context) {
    final maxH = MediaQuery.sizeOf(context).height * 0.72;

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxH),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
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
              const SizedBox(height: 14),
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: PortalColors.brandTint,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: Icon(icon, size: 19, color: PortalColors.brand),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: portalText(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: PortalColors.heading,
                          ),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          subtitle,
                          style: portalText(
                            fontSize: 11.5,
                            color: PortalColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded, size: 20),
                    color: PortalColors.muted,
                    splashRadius: 18,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Material(
                color: selected == allLabel
                    ? PortalColors.brandTint
                    : Colors.white,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  onTap: () => Navigator.of(context).pop(allLabel),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: selected == allLabel
                            ? PortalColors.brand
                            : PortalColors.border,
                        width: selected == allLabel ? 1.4 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          selected == allLabel
                              ? Icons.check_circle_rounded
                              : Icons.all_inclusive_rounded,
                          size: 18,
                          color: selected == allLabel
                              ? PortalColors.brand
                              : PortalColors.muted,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          allLabel,
                          style: portalText(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: selected == allLabel
                                ? PortalColors.brand
                                : PortalColors.heading,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Flexible(
                child: GridView.builder(
                  shrinkWrap: true,
                  itemCount: items.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 2.2,
                  ),
                  itemBuilder: (ctx, index) {
                    final name = items[index];
                    final isSelected = selected == name;
                    final isHighlight = highlightItem == name;
                    return Material(
                      color: isSelected
                          ? PortalColors.brand
                          : (isHighlight
                              ? PortalColors.brandTint
                              : Colors.white),
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        onTap: () => Navigator.of(context).pop(name),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? PortalColors.brand
                                  : (isHighlight
                                      ? PortalColors.brand
                                          .withValues(alpha: 0.45)
                                      : PortalColors.border),
                              width: isSelected || isHighlight ? 1.3 : 1,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            name,
                            maxLines: 2,
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: portalText(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: isSelected
                                  ? Colors.white
                                  : (isHighlight
                                      ? PortalColors.brand
                                      : PortalColors.heading),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
