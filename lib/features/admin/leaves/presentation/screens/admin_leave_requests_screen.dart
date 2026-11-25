import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:timelay_health/core/theme/portal_colors.dart';
import 'package:timelay_health/core/theme/portal_system_ui.dart';
import 'package:timelay_health/core/theme/portal_text.dart';
import 'package:timelay_health/core/widgets/portal_safe_area.dart';
import 'package:timelay_health/features/admin/leaves/presentation/bloc/admin_leave_cubit.dart';
import 'package:timelay_health/features/admin/leaves/presentation/bloc/admin_leave_state.dart';
import 'package:timelay_health/features/admin/leaves/presentation/models/admin_leave_requests_ui.dart';
import 'package:timelay_health/features/dashboard/presentation/screens/employee_home_shell.dart';
import 'package:timelay_health/features/dashboard/presentation/widgets/employee_bottom_nav.dart';
import 'package:timelay_health/features/dashboard/presentation/widgets/home_side_drawer.dart';
import 'package:timelay_health/features/notifications/presentation/widgets/top_notification_button.dart';

class AdminLeaveRequestsScreen extends StatefulWidget {
  const AdminLeaveRequestsScreen({super.key});

  @override
  State<AdminLeaveRequestsScreen> createState() =>
      _AdminLeaveRequestsScreenState();
}

class _AdminLeaveRequestsScreenState extends State<AdminLeaveRequestsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchCtrl = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  late final AdminLeaveCubit _cubit;

  String _statusFilter = 'ALL';
  String _deptFilter = 'All Departments';
  String _designationFilter = 'All Designations';
  String _monthFilter = 'All Months';
  DateTime? _startDate;
  DateTime? _endDate;

  int _displayedCount = 15;
  bool _isLoadingMore = false;

  static const defaultDepartments = <String>[
    'All Departments',
    'Developer',
    'Medical',
    'Digital Marketing',
    'Marketing',
    'Nursing',
    'Management',
    'Operations',
  ];

  static const defaultDesignations = <String>[
    'All Designations',
    'MERN Stack Developer',
    'Flutter Developer',
    'Web Developer',
    'Ai Intern',
    'Phlebotomist',
    'Graphic Designer',
    'Marketing Executive',
    'Staff',
  ];

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

  static const _monthMap = <String, int>{
    'january': 1,
    'jan': 1,
    'february': 2,
    'feb': 2,
    'march': 3,
    'mar': 3,
    'april': 4,
    'apr': 4,
    'may': 5,
    'june': 6,
    'jun': 6,
    'july': 7,
    'jul': 7,
    'august': 8,
    'aug': 8,
    'september': 9,
    'sep': 9,
    'october': 10,
    'oct': 10,
    'november': 11,
    'nov': 11,
    'december': 12,
    'dec': 12,
  };

  static DateTime? _parseDmy(String text) {
    try {
      final parts = text.split('/');
      if (parts.length == 3) {
        final d = int.parse(parts[0]);
        final m = int.parse(parts[1]);
        final y = int.parse(parts[2]);
        return DateTime(y, m, d);
      }
    } catch (_) {}
    return null;
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _cubit = AdminLeaveCubit()..load();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchCtrl.dispose();
    _cubit.close();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients || _isLoadingMore) return;
    if (_scrollController.position.pixels <
        _scrollController.position.maxScrollExtent - 200) {
      return;
    }
    final filteredLen =
        _filterRecords(_cubit.state.ui.records).length;
    if (_displayedCount >= filteredLen) return;

    setState(() => _isLoadingMore = true);
    Future.delayed(const Duration(milliseconds: 280), () {
      if (!mounted) return;
      setState(() {
        _displayedCount += 15;
        _isLoadingMore = false;
      });
    });
  }

  void _resetPaging() => _displayedCount = 15;

  List<AdminLeaveItem> _filterRecords(
    List<AdminLeaveItem> records, {
    bool applyStatus = true,
  }) {
    final query = _searchCtrl.text.trim().toLowerCase();

    return records.where((item) {
      if (applyStatus) {
        if (_statusFilter == 'PENDING' && !item.isPending) return false;
        if (_statusFilter == 'APPROVED' && !item.isApproved) return false;
        if (_statusFilter == 'REJECTED' && !item.isRejected) return false;
      }

      if (_deptFilter != 'All Departments' &&
          item.department.toLowerCase() != _deptFilter.toLowerCase()) {
        return false;
      }

      if (_designationFilter != 'All Designations' &&
          item.designation.toLowerCase() != _designationFilter.toLowerCase()) {
        return false;
      }

      if (_monthFilter != 'All Months') {
        final targetMonth = _monthMap[_monthFilter.toLowerCase()];
        if (targetMonth != null) {
          final fromDt = _parseDmy(item.fromDate);
          final toDt = _parseDmy(item.toDate);
          final matchMonth = (fromDt != null && fromDt.month == targetMonth) ||
              (toDt != null && toDt.month == targetMonth);
          if (!matchMonth) {
            final parts = item.fromDate.split('/');
            if (parts.length >= 2) {
              final m = int.tryParse(parts[1]);
              if (m != targetMonth) return false;
            } else {
              return false;
            }
          }
        }
      }

      if (_startDate != null && _endDate != null) {
        final rangeStart = DateTime(
          _startDate!.year,
          _startDate!.month,
          _startDate!.day,
        );
        final rangeEnd = DateTime(
          _endDate!.year,
          _endDate!.month,
          _endDate!.day,
        );
        final fromDt = _parseDmy(item.fromDate);
        final toDt = _parseDmy(item.toDate);
        if (fromDt != null && toDt != null) {
          final fromOnly = DateTime(fromDt.year, fromDt.month, fromDt.day);
          final toOnly = DateTime(toDt.year, toDt.month, toDt.day);
          if (toOnly.isBefore(rangeStart) || fromOnly.isAfter(rangeEnd)) {
            return false;
          }
        } else {
          return false;
        }
      }

      if (query.isNotEmpty) {
        final matchName = item.name.toLowerCase().contains(query);
        final matchCode = item.employeeCode.toLowerCase().contains(query);
        final matchReason = item.reason.toLowerCase().contains(query);
        final matchDesign = item.designation.toLowerCase().contains(query);
        final matchDept = item.department.toLowerCase().contains(query);
        final matchType = item.leaveType.toLowerCase().contains(query);
        if (!matchName &&
            !matchCode &&
            !matchReason &&
            !matchDesign &&
            !matchDept &&
            !matchType) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  Future<void> _onApprove(AdminLeaveItem item) async {
    try {
      await _cubit.approveLeave(id: item.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(
                Icons.check_circle_rounded,
                color: Colors.white,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Leave request approved for ${item.name}',
                  style: portalText(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF059669),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst('Exception: ', ''),
            style: portalText(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFFDC2626),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  Future<void> _onReject(AdminLeaveItem item) async {
    try {
      await _cubit.rejectLeave(id: item.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(
                Icons.cancel_rounded,
                color: Colors.white,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Leave request rejected for ${item.name}',
                  style: portalText(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFFDC2626),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst('Exception: ', ''),
            style: portalText(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFFDC2626),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  String _fmtChipDate(DateTime d) => '${d.day}/${d.month}';

  Future<void> _pickDate() async {
    final picked = await showModalBottomSheet<DateTimeRange>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) => _DateRangePickerSheet(
        initialStart: _startDate,
        initialEnd: _endDate,
      ),
    );
    if (picked == null || !mounted) return;
    setState(() {
      _startDate = picked.start;
      _endDate = picked.end;
      _resetPaging();
    });
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
      _resetPaging();
    });
  }

  Future<void> _pickDept(List<String> dynamicDepts) async {
    final items = <String>{
      ...defaultDepartments.where((e) => e != 'All Departments'),
      ...dynamicDepts,
    }.toList()
      ..sort();

    final picked = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) => _FilterGridPickerSheet(
        title: 'Select Department',
        subtitle: 'Choose a department to filter leave requests',
        icon: Icons.apartment_rounded,
        allLabel: 'All Departments',
        items: items,
        selected: _deptFilter,
      ),
    );
    if (picked == null || !mounted) return;
    setState(() {
      _deptFilter = picked;
      _resetPaging();
    });
  }

  Future<void> _pickDesignation(List<String> dynamicDesignations) async {
    final items = <String>{
      ...defaultDesignations.where((e) => e != 'All Designations'),
      ...dynamicDesignations,
    }.toList()
      ..sort();

    final picked = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) => _FilterGridPickerSheet(
        title: 'Select Designation',
        subtitle: 'Choose a designation to filter leave requests',
        icon: Icons.badge_outlined,
        allLabel: 'All Designations',
        items: items,
        selected: _designationFilter,
      ),
    );
    if (picked == null || !mounted) return;
    setState(() {
      _designationFilter = picked;
      _resetPaging();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: PortalSystemUi.lightStatusBar,
      child: Scaffold(
        key: _scaffoldKey,
        drawer: const HomeSideDrawer(),
        drawerScrimColor: PortalColors.brand.withValues(alpha: 0.28),
        backgroundColor: const Color(0xFFF8FAFC),
        body: PortalSafeArea(
          bottom: false,
          statusBarColor: PortalColors.surface,
          child: BlocBuilder<AdminLeaveCubit, AdminLeaveState>(
            bloc: _cubit,
            builder: (context, state) {
              final ui = state.ui;
              final allRecords = ui.records;
              final statsBase =
                  _filterRecords(allRecords, applyStatus: false);
              final list = _filterRecords(allRecords);
              final totalCount = statsBase.length;
              final pendingCount =
                  statsBase.where((r) => r.isPending).length;
              final approvedCount =
                  statsBase.where((r) => r.isApproved).length;
              final rejectedCount =
                  statsBase.where((r) => r.isRejected).length;
              final displayedList = list.take(_displayedCount).toList();

              final isLoading = state is AdminLeaveLoading && allRecords.isEmpty;
              final isFailure = state is AdminLeaveFailureState && allRecords.isEmpty;

              return Column(
                children: [
                  _TopBar(
                    onMenuTap: () => _scaffoldKey.currentState?.openDrawer(),
                  ),

                  Expanded(
                    child: RefreshIndicator(
                      color: PortalColors.brand,
                      onRefresh: () => _cubit.load(isRefresh: true),
                      child: isLoading
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: PortalColors.brand,
                              ),
                            )
                          : isFailure
                              ? Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(24),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          width: 56,
                                          height: 56,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFFEE2E2),
                                            borderRadius:
                                                BorderRadius.circular(28),
                                          ),
                                          child: const Icon(
                                            Icons.wifi_off_rounded,
                                            size: 28,
                                            color: Color(0xFFDC2626),
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          'Failed to Load Leaves',
                                          style: portalText(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                            color: PortalColors.heading,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          (state as AdminLeaveFailureState).message,
                                          textAlign: TextAlign.center,
                                          style: portalText(
                                            fontSize: 12.5,
                                            color: PortalColors.muted,
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: PortalColors.brand,
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 20,
                                              vertical: 10,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                          ),
                                          onPressed: () => _cubit.load(),
                                          child: Text(
                                            'Retry',
                                            style: portalText(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : ListView(
                                  controller: _scrollController,
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  padding: const EdgeInsets.fromLTRB(
                                      14, 12, 14, 24),
                                  children: [
                                    _SearchInput(
                                      controller: _searchCtrl,
                                      onChanged: (_) => setState(() {
                                        _resetPaging();
                                      }),
                                    ),
                                    const SizedBox(height: 10),
                                    _FilterChipsRow(
                                      dateLabel: _startDate != null &&
                                              _endDate != null
                                          ? '${_fmtChipDate(_startDate!)}-${_fmtChipDate(_endDate!)}'
                                          : 'Date',
                                      monthLabel:
                                          _monthFilter != 'All Months'
                                              ? _monthFilter
                                              : 'Month',
                                      deptLabel:
                                          _deptFilter != 'All Departments'
                                              ? _deptFilter
                                              : 'Department',
                                      designLabel: _designationFilter !=
                                              'All Designations'
                                          ? _designationFilter
                                          : 'Designation',
                                      dateActive: _startDate != null &&
                                          _endDate != null,
                                      monthActive:
                                          _monthFilter != 'All Months',
                                      deptActive:
                                          _deptFilter != 'All Departments',
                                      designActive: _designationFilter !=
                                          'All Designations',
                                      onDateTap: _pickDate,
                                      onMonthTap: _pickMonth,
                                      onDeptTap: () =>
                                          _pickDept(ui.departments),
                                      onDesignTap: () =>
                                          _pickDesignation(ui.designations),
                                      onDateClear: () => setState(() {
                                        _startDate = null;
                                        _endDate = null;
                                        _resetPaging();
                                      }),
                                      onMonthClear: () => setState(() {
                                        _monthFilter = 'All Months';
                                        _resetPaging();
                                      }),
                                      onDeptClear: () => setState(() {
                                        _deptFilter = 'All Departments';
                                        _resetPaging();
                                      }),
                                      onDesignClear: () => setState(() {
                                        _designationFilter =
                                            'All Designations';
                                        _resetPaging();
                                      }),
                                    ),
                                    const SizedBox(height: 14),
                                    _StatCardsRow(
                                      totalCount: totalCount,
                                      pendingCount: pendingCount,
                                      approvedCount: approvedCount,
                                      rejectedCount: rejectedCount,
                                      activeStatus: _statusFilter,
                                      onSelectStatus: (s) => setState(() {
                                        _statusFilter = s;
                                        _resetPaging();
                                      }),
                                    ),
                                    const SizedBox(height: 14),
                                    if (list.isEmpty)
                                      _EmptyState(onReset: () {
                                        setState(() {
                                          _searchCtrl.clear();
                                          _statusFilter = 'ALL';
                                          _deptFilter = 'All Departments';
                                          _designationFilter =
                                              'All Designations';
                                          _monthFilter = 'All Months';
                                          _startDate = null;
                                          _endDate = null;
                                          _resetPaging();
                                        });
                                      })
                                    else ...[
                                      for (final item in displayedList) ...[
                                        _LeaveRequestCard(
                                          item: item,
                                          onApprove: () => _onApprove(item),
                                          onReject: () => _onReject(item),
                                        ),
                                        const SizedBox(height: 12),
                                      ],
                                      if (_isLoadingMore)
                                        const Padding(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 12),
                                          child: Center(
                                            child: SizedBox(
                                              width: 22,
                                              height: 22,
                                              child:
                                                  CircularProgressIndicator(
                                                strokeWidth: 2.2,
                                                color: PortalColors.brand,
                                              ),
                                            ),
                                          ),
                                        ),
                                      const SizedBox(height: 10),
                                      Center(
                                        child: Text(
                                          'Showing ${displayedList.length} of ${list.length} leave requests',
                                          style: portalText(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: const Color(0xFF94A3B8),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Center(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              'Syncing automatically with HR System',
                                              style: portalText(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                                color:
                                                    const Color(0xFF64748B),
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            Container(
                                              width: 6,
                                              height: 6,
                                              decoration: const BoxDecoration(
                                                color: Color(0xFF10B981),
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                    ],
                                  ],
                                ),
                    ),
                  ),
                ],
              );
            },
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

class _TopBar extends StatelessWidget {
  const _TopBar({required this.onMenuTap});

  final VoidCallback onMenuTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: PortalColors.surface,
        border: const Border(bottom: BorderSide(color: PortalColors.border)),
        boxShadow: [
          BoxShadow(
            color: PortalColors.brand.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: onMenuTap,
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: 36,
              height: 36,
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
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Leave Requests',
                  style: portalText(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: PortalColors.heading,
                    letterSpacing: 0.1,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Leave & Comp-off Monitoring',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: portalText(
                    fontSize: 11.5,
                    color: PortalColors.muted,
                    height: 1.3,
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

class _SearchInput extends StatelessWidget {
  const _SearchInput({
    required this.controller,
    required this.onChanged,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: PortalColors.border),
      ),
      child: Row(
        children: [
          const Icon(Icons.search_rounded, size: 20, color: PortalColors.muted),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              textAlign: TextAlign.start,
              style: portalText(
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
                color: PortalColors.heading,
              ),
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                hintText: 'Search by employee, id, reason...',
                hintStyle: portalText(
                  fontSize: 13,
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
            ),
        ],
      ),
    );
  }
}

class _FilterChipsRow extends StatelessWidget {
  const _FilterChipsRow({
    required this.dateLabel,
    required this.monthLabel,
    required this.deptLabel,
    required this.designLabel,
    required this.dateActive,
    required this.monthActive,
    required this.deptActive,
    required this.designActive,
    required this.onDateTap,
    required this.onMonthTap,
    required this.onDeptTap,
    required this.onDesignTap,
    this.onDateClear,
    this.onMonthClear,
    this.onDeptClear,
    this.onDesignClear,
  });

  final String dateLabel;
  final String monthLabel;
  final String deptLabel;
  final String designLabel;
  final bool dateActive;
  final bool monthActive;
  final bool deptActive;
  final bool designActive;
  final VoidCallback onDateTap;
  final VoidCallback onMonthTap;
  final VoidCallback onDeptTap;
  final VoidCallback onDesignTap;
  final VoidCallback? onDateClear;
  final VoidCallback? onMonthClear;
  final VoidCallback? onDeptClear;
  final VoidCallback? onDesignClear;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _Chip(
            icon: Icons.calendar_today_outlined,
            label: dateLabel,
            active: dateActive,
            onTap: onDateTap,
            onClear: onDateClear,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _Chip(
            icon: Icons.event_note_rounded,
            label: monthLabel,
            active: monthActive,
            onTap: onMonthTap,
            onClear: onMonthClear,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _Chip(
            icon: Icons.apartment_rounded,
            label: deptLabel,
            active: deptActive,
            onTap: onDeptTap,
            onClear: onDeptClear,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _Chip(
            icon: Icons.badge_outlined,
            label: designLabel,
            active: designActive,
            onTap: onDesignTap,
            onClear: onDesignClear,
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
  const _StatCardsRow({
    required this.totalCount,
    required this.pendingCount,
    required this.approvedCount,
    required this.rejectedCount,
    required this.activeStatus,
    required this.onSelectStatus,
  });

  final int totalCount;
  final int pendingCount;
  final int approvedCount;
  final int rejectedCount;
  final String activeStatus;
  final ValueChanged<String> onSelectStatus;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            title: 'TOTAL',
            count: '$totalCount',
            subtitle: 'all leaves',
            indicatorColor: PortalColors.brand,
            indicatorIcon: Icons.apps_rounded,
            isSelected: activeStatus == 'ALL',
            onTap: () => onSelectStatus('ALL'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatCard(
            title: 'PENDING',
            count: '$pendingCount',
            subtitle: 'awaiting',
            indicatorColor: const Color(0xFFD97706),
            indicatorIcon: Icons.hourglass_top_rounded,
            isSelected: activeStatus == 'PENDING',
            onTap: () => onSelectStatus('PENDING'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatCard(
            title: 'APPROVED',
            count: '$approvedCount',
            subtitle: 'approved',
            indicatorColor: const Color(0xFF059669),
            indicatorIcon: Icons.check_circle_rounded,
            isSelected: activeStatus == 'APPROVED',
            onTap: () => onSelectStatus('APPROVED'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatCard(
            title: 'REJECTED',
            count: '$rejectedCount',
            subtitle: 'rejected',
            indicatorColor: const Color(0xFFDC2626),
            indicatorIcon: Icons.cancel_rounded,
            isSelected: activeStatus == 'REJECTED',
            onTap: () => onSelectStatus('REJECTED'),
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.count,
    required this.subtitle,
    required this.indicatorColor,
    required this.indicatorIcon,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final String count;
  final String subtitle;
  final Color indicatorColor;
  final IconData indicatorIcon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 9),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected
                  ? indicatorColor
                  : const Color(0xFFF1F5F9),
              width: isSelected ? 1.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: portalText(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: indicatorColor,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                  Icon(indicatorIcon, size: 12, color: indicatorColor),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                count,
                style: portalText(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: isSelected ? indicatorColor : PortalColors.heading,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: portalText(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF94A3B8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LeaveRequestCard extends StatelessWidget {
  const _LeaveRequestCard({
    required this.item,
    required this.onApprove,
    required this.onReject,
  });

  final AdminLeaveItem item;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    final statusColor = item.isPending
        ? const Color(0xFFD97706)
        : item.isApproved
            ? const Color(0xFF059669)
            : const Color(0xFFDC2626);

    final statusBg = item.isPending
        ? const Color(0xFFFEF3C7)
        : item.isApproved
            ? const Color(0xFFECFDF5)
            : const Color(0xFFFEE2E2);

    final statusBorder = item.isPending
        ? const Color(0xFFFDE68A)
        : item.isApproved
            ? const Color(0xFFA7F3D0)
            : const Color(0xFFFECACA);

    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: PortalColors.brand,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  item.initials,
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
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            item.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: portalText(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            item.employeeCode,
                            style: portalText(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${item.department} - ${item.designation}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: portalText(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF8C95A6),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: statusBorder, width: 0.8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      item.isPending
                          ? Icons.hourglass_top_rounded
                          : item.isApproved
                              ? Icons.check_circle_rounded
                              : Icons.cancel_rounded,
                      size: 11,
                      color: statusColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      item.status,
                      style: portalText(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFF1F5F9)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 13,
                  color: Color(0xFF64748B),
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    '${item.fromDate} to ${item.toDate}',
                    style: portalText(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF334155),
                    ),
                  ),
                ),
                if (item.leaveType.isNotEmpty) ...[
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: PortalColors.brand.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      item.leaveType,
                      style: portalText(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        color: PortalColors.brand,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                ],
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Text(
                    item.durationText,
                    style: portalText(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 9),

          Material(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(8),
            child: InkWell(
              onTap: () => _showFullReason(context, item),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border(
                    left: BorderSide(
                      color: statusColor,
                      width: 3.5,
                    ),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        '"${item.reason}"',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: portalText(
                          fontSize: 11.5,
                          fontStyle: FontStyle.italic,
                          color: const Color(0xFF475569),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(
                      Icons.open_in_full_rounded,
                      size: 13,
                      color: statusColor.withValues(alpha: 0.7),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),

          Row(
            children: [
              Icon(
                item.isPending
                    ? Icons.schedule_rounded
                    : item.isApproved
                        ? Icons.check_circle_outline_rounded
                        : Icons.highlight_off_rounded,
                size: 13,
                color: statusColor,
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  item.isPending
                      ? item.appliedText
                      : item.isApproved
                          ? 'Approved by : ${item.approver}'
                          : 'Rejected by : ${item.approver}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: portalText(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ),
              if (!item.isPending)
                Text(
                  item.timestamp,
                  style: portalText(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF94A3B8),
                  ),
                ),
            ],
          ),

          if (item.isPending) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.only(top: 10),
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: Color(0xFFF1F5F9),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Material(
                      color: const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(10),
                      child: InkWell(
                        onTap: onReject,
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: const Color(0xFFFECACA),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.close_rounded,
                                size: 15,
                                color: Color(0xFFDC2626),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Reject',
                                style: portalText(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFFDC2626),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Material(
                      color: const Color(0xFF059669),
                      borderRadius: BorderRadius.circular(10),
                      child: InkWell(
                        onTap: onApprove,
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF059669)
                                    .withValues(alpha: 0.25),
                                blurRadius: 4,
                                offset: const Offset(0, 1.5),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.check_rounded,
                                size: 16,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Approve',
                                style: portalText(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showFullReason(BuildContext context, AdminLeaveItem item) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
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
                      child: const Icon(
                        Icons.message_rounded,
                        size: 18,
                        color: PortalColors.brand,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Leave Message',
                            style: portalText(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: PortalColors.heading,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item.name,
                            style: portalText(
                              fontSize: 12,
                              color: PortalColors.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      icon: const Icon(Icons.close_rounded, size: 20),
                      color: PortalColors.muted,
                      splashRadius: 18,
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.sizeOf(ctx).height * 0.45,
                  ),
                  child: SingleChildScrollView(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: PortalColors.border),
                      ),
                      child: Text(
                        item.reason,
                        style: portalText(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w500,
                          color: PortalColors.heading,
                          height: 1.45,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onReset});

  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                color: Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.assignment_outlined,
                size: 28,
                color: Color(0xFF94A3B8),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'No Leave Requests Found',
              style: portalText(
                fontSize: 14.5,
                fontWeight: FontWeight.w700,
                color: PortalColors.heading,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Try adjusting your search or filters',
              style: portalText(
                fontSize: 12,
                color: PortalColors.muted,
              ),
            ),
            const SizedBox(height: 14),
            TextButton(
              onPressed: onReset,
              child: Text(
                'Reset Filters',
                style: portalText(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: PortalColors.brand,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DateRangePickerSheet extends StatefulWidget {
  const _DateRangePickerSheet({
    this.initialStart,
    this.initialEnd,
  });

  final DateTime? initialStart;
  final DateTime? initialEnd;

  @override
  State<_DateRangePickerSheet> createState() => _DateRangePickerSheetState();
}

class _DateRangePickerSheetState extends State<_DateRangePickerSheet> {
  late DateTime _viewMonth;
  DateTime? _start;
  DateTime? _end;
  bool _pickingEnd = false;

  static const _weekDays = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
  static const _monthNames = _AdminLeaveRequestsScreenState.months;

  @override
  void initState() {
    super.initState();
    _start = widget.initialStart;
    _end = widget.initialEnd;
    _viewMonth = DateTime(
      (_start ?? DateTime.now()).year,
      (_start ?? DateTime.now()).month,
    );
    _pickingEnd = _start != null && _end == null;
  }

  DateTime _only(DateTime d) => DateTime(d.year, d.month, d.day);

  String _label(DateTime? d) {
    if (d == null) return 'Select date';
    return '${d.day.toString().padLeft(2, '0')} ${_monthNames[d.month - 1].substring(0, 3)} ${d.year}';
  }

  void _onDayTap(DateTime day) {
    final d = _only(day);
    setState(() {
      if (!_pickingEnd || _start == null) {
        _start = d;
        _end = null;
        _pickingEnd = true;
      } else {
        if (d.isBefore(_start!)) {
          _end = _start;
          _start = d;
        } else {
          _end = d;
        }
        _pickingEnd = false;
      }
    });
  }

  bool _inRange(DateTime day) {
    if (_start == null || _end == null) return false;
    final d = _only(day);
    return !d.isBefore(_start!) && !d.isAfter(_end!);
  }

  bool _isStart(DateTime day) =>
      _start != null && _only(day) == _only(_start!);

  bool _isEnd(DateTime day) =>
      _end != null && _only(day) == _only(_end!);

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

    final canApply = _start != null && _end != null;

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
                    Icons.date_range_rounded,
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
                        'Select Date Range',
                        style: portalText(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: PortalColors.heading,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        'Pick start and end date',
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
            Row(
              children: [
                Expanded(
                  child: _DateFieldCard(
                    label: 'Start Date',
                    value: _label(_start),
                    active: !_pickingEnd,
                    filled: _start != null,
                    onTap: () => setState(() => _pickingEnd = false),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    size: 18,
                    color: PortalColors.brand.withValues(alpha: 0.45),
                  ),
                ),
                Expanded(
                  child: _DateFieldCard(
                    label: 'End Date',
                    value: _label(_end),
                    active: _pickingEnd,
                    filled: _end != null,
                    onTap: () {
                      if (_start != null) {
                        setState(() => _pickingEnd = true);
                      }
                    },
                  ),
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

                      final isStart = _isStart(day);
                      final isEnd = _isEnd(day);
                      final inRange = _inRange(day);
                      final isEdge = isStart || isEnd;
                      final isToday = _only(day) == _only(DateTime.now());

                      return GestureDetector(
                        onTap: () => _onDayTap(day),
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          decoration: BoxDecoration(
                            color: isEdge
                                ? PortalColors.brand
                                : (inRange
                                    ? PortalColors.brandTint
                                    : Colors.transparent),
                            shape: isEdge ? BoxShape.circle : BoxShape.rectangle,
                            borderRadius: isEdge
                                ? null
                                : (inRange
                                    ? BorderRadius.circular(8)
                                    : null),
                            border: isToday && !isEdge && !inRange
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
                              color: isEdge
                                  ? Colors.white
                                  : (inRange
                                      ? PortalColors.brand
                                      : PortalColors.heading),
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
                      setState(() {
                        _start = null;
                        _end = null;
                        _pickingEnd = false;
                      });
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
                    onPressed: canApply
                        ? () => Navigator.of(context).pop(
                              DateTimeRange(start: _start!, end: _end!),
                            )
                        : null,
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
                      'Apply Range',
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

class _DateFieldCard extends StatelessWidget {
  const _DateFieldCard({
    required this.label,
    required this.value,
    required this.active,
    required this.filled,
    required this.onTap,
  });

  final String label;
  final String value;
  final bool active;
  final bool filled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: active ? PortalColors.brandTint : Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.fromLTRB(10, 9, 10, 9),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: active
                  ? PortalColors.brand
                  : PortalColors.border,
              width: active ? 1.4 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: portalText(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  color: active ? PortalColors.brand : PortalColors.muted,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: portalText(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: filled
                      ? PortalColors.heading
                      : PortalColors.muted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MonthOnlyPickerSheet extends StatelessWidget {
  const _MonthOnlyPickerSheet({required this.selected});

  final String selected;

  static const _months = _AdminLeaveRequestsScreenState.months;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final availableMonths = _months.sublist(0, now.month);

    return _FilterGridPickerSheet(
      title: 'Select Month',
      subtitle: 'Choose a month to filter leave requests',
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
                        horizontal: 12, vertical: 12),
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
