import 'package:flutter/material.dart';
import 'package:timelay_health/core/theme/portal_colors.dart';
import 'package:timelay_health/core/theme/portal_text.dart';
import 'package:timelay_health/core/widgets/shimmer.dart';
import 'package:timelay_health/features/auth/data/auth_session.dart';
import 'package:timelay_health/features/holidays/presentation/widgets/top_calendar_button.dart';
import 'package:timelay_health/features/notifications/presentation/widgets/top_notification_button.dart';
import 'package:timelay_health/features/permissions/data/datasources/permission_remote_datasource.dart';
import 'package:timelay_health/features/permissions/presentation/widgets/request_permission_dialog.dart';
import 'package:timelay_health/core/widgets/portal_back_button.dart';
import 'package:timelay_health/core/widgets/portal_safe_area.dart';

class PermissionsScreen extends StatefulWidget {
  const PermissionsScreen({super.key});

  @override
  State<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends State<PermissionsScreen> {
  final _search = TextEditingController();
  DateTime? _selectedDate;
  final _dataSource = PermissionRemoteDataSource();
  List<_PermissionRecord> _records = const [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPermissions();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<_PermissionRecord> get _visibleRecords {
    final query = _search.text.trim().toLowerCase();
    return _records.where((record) {
      final matchesSearch =
          query.isEmpty ||
          record.reason.toLowerCase().contains(query) ||
          record.status.label.toLowerCase().contains(query);
      final matchesDate =
          _selectedDate == null || _sameDay(record.date, _selectedDate!);
      return matchesSearch && matchesDate;
    }).toList();
  }

  int get _approved => _records
      .where((record) => record.status == _PermissionStatus.approved)
      .length;
  int get _pending => _records
      .where((record) => record.status == _PermissionStatus.pending)
      .length;

  @override
  Widget build(BuildContext context) {
    final records = _visibleRecords;
    return Scaffold(
      backgroundColor: PortalColors.background,
      body: PortalSafeArea(
        bottom: false,
        child: Column(
          children: [
            const _PermissionsAppBar(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 32),
                children: [
                  _HeroCard(onRequest: _showRequestDialog),
                  const SizedBox(height: 18),
                  _StatsRow(
                    total: _records.length,
                    approved: _approved,
                    pending: _pending,
                  ),
                  const SizedBox(height: 18),
                  _FilterCard(
                    searchController: _search,
                    selectedDate: _selectedDate,
                    onChanged: () => setState(() {}),
                    onPickDate: _pickDate,
                    onClearDate: () => setState(() => _selectedDate = null),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Text(
                        'Permission history',
                        style: portalText(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: PortalColors.heading,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${records.length} ${records.length == 1 ? 'record' : 'records'}',
                        style: portalText(
                          fontSize: 11,
                          color: PortalColors.muted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (_loading)
                    const ShimmerCardList(
                      itemCount: 4,
                      padding: EdgeInsets.symmetric(vertical: 8),
                    )
                  else if (_error != null)
                    _LoadError(message: _error!, onRetry: _loadPermissions)
                  else if (records.isEmpty)
                    const _EmptyState()
                  else
                    ...records.map(
                      (record) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _PermissionCard(record: record),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 1),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _showRequestSheet() async {
    final submitted = await showRequestPermissionDialog(context);
    if (submitted == true && mounted) await _loadPermissions();
  }

  Future<void> _showRequestDialog() => _showRequestSheet();

  Future<void> _loadPermissions() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final employee = AuthSession.currentEmployee ?? await AuthSession.load();
      final employeeId = employee?.employeeId ?? '';
      if (employeeId.trim().isEmpty) {
        throw const PermissionRequestException(
          'Employee ID missing. Please login again.',
        );
      }
      final records = await _dataSource.getMyPermissions(
        employeeId: employeeId,
      );
      if (!mounted) return;
      setState(() {
        _records = records
            .map(
              (record) => _PermissionRecord(
                date: record.createdAt?.toLocal() ?? DateTime.now(),
                duration: '${record.duration} min',
                reason: record.reason.trim().isEmpty ? '—' : record.reason,
                status: _PermissionStatus.fromApi(record.status),
              ),
            )
            .toList();
      });
    } on PermissionRequestException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (_) {
      if (mounted) {
        setState(
          () => _error = 'Failed to load permissions. Please try again.',
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}

class _PermissionsAppBar extends StatelessWidget {
  const _PermissionsAppBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: PortalColors.surface,
        border: Border(bottom: BorderSide(color: PortalColors.border)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 10, 18, 10),
      child: Row(
        children: [
          const PortalBackButton(),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Permissions',
                  style: portalText(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: PortalColors.heading,
                    letterSpacing: 0.1,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Manage your short-time requests',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: portalText(
                    fontSize: 11,
                    color: PortalColors.muted,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const TopNotificationButton(),
          const SizedBox(width: 14),
          const TopCalendarButton(),
        ],
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.onRequest});
  final VoidCallback onRequest;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [PortalColors.purpleDeep, PortalColors.purpleLight],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: PortalColors.purple.withValues(alpha: 0.25),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.17),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.schedule_rounded, color: Colors.white),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Need a little time?',
                  style: portalText(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Send a short-time permission request.',
                  style: portalText(
                    fontSize: 11,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          IconButton.filled(
            onPressed: onRequest,
            style: IconButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: PortalColors.purple,
            ),
            icon: const Icon(Icons.add_rounded),
          ),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({
    required this.total,
    required this.approved,
    required this.pending,
  });
  final int total;
  final int approved;
  final int pending;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            label: 'Total',
            value: total,
            icon: Icons.list_alt_rounded,
            color: PortalColors.purple,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            label: 'Approved',
            value: approved,
            icon: Icons.verified_rounded,
            color: PortalColors.green,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            label: 'Pending',
            value: pending,
            icon: Icons.hourglass_top_rounded,
            color: PortalColors.orange,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });
  final String label;
  final int value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: PortalColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: PortalColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 19),
          const SizedBox(height: 12),
          Text(
            '$value',
            style: portalText(
              fontSize: 19,
              fontWeight: FontWeight.w800,
              color: PortalColors.green,
            ),
          ),
          Text(
            label,
            style: portalText(fontSize: 10.5, color: PortalColors.muted),
          ),
        ],
      ),
    );
  }
}

class _FilterCard extends StatelessWidget {
  const _FilterCard({
    required this.searchController,
    required this.selectedDate,
    required this.onChanged,
    required this.onPickDate,
    required this.onClearDate,
  });
  final TextEditingController searchController;
  final DateTime? selectedDate;
  final VoidCallback onChanged;
  final VoidCallback onPickDate;
  final VoidCallback onClearDate;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: PortalColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: PortalColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: searchController,
              onChanged: (_) => onChanged(),
              decoration: InputDecoration(
                hintText: 'Search reason or status',
                prefixIcon: const Icon(Icons.search_rounded, size: 19),
                filled: true,
                fillColor: PortalColors.background,
                isDense: true,
                border: _border(),
                enabledBorder: _border(),
                focusedBorder: _border(PortalColors.purple),
              ),
            ),
          ),
          const SizedBox(width: 9),
          InkWell(
            onTap: selectedDate == null ? onPickDate : onClearDate,
            borderRadius: BorderRadius.circular(11),
            child: Container(
              height: 44,
              width: 46,
              decoration: BoxDecoration(
                color: selectedDate == null
                    ? PortalColors.background
                    : PortalColors.purpleTint,
                borderRadius: BorderRadius.circular(11),
                border: Border.all(
                  color: selectedDate == null
                      ? PortalColors.border
                      : PortalColors.purple,
                ),
              ),
              child: Icon(
                selectedDate == null
                    ? Icons.calendar_today_outlined
                    : Icons.close_rounded,
                size: 18,
                color: PortalColors.purple,
              ),
            ),
          ),
        ],
      ),
    );
  }

  OutlineInputBorder _border([Color? color]) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(11),
    borderSide: BorderSide(color: color ?? PortalColors.border),
  );
}

class _PermissionCard extends StatelessWidget {
  const _PermissionCard({required this.record});
  final _PermissionRecord record;

  @override
  Widget build(BuildContext context) {
    final approved = record.status == _PermissionStatus.approved;
    final color = approved ? PortalColors.green : PortalColors.orange;
    final tint = approved ? PortalColors.greenTint : PortalColors.orangeTint;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: PortalColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: PortalColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: tint,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(Icons.schedule_rounded, color: color, size: 21),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.reason,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: portalText(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: PortalColors.heading,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_dateLabel(record.date)}  •  ${record.duration}',
                  style: portalText(fontSize: 11, color: PortalColors.muted),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
            decoration: BoxDecoration(
              color: tint,
              borderRadius: BorderRadius.circular(99),
            ),
            child: Text(
              record.status.label,
              style: portalText(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(28),
    decoration: BoxDecoration(
      color: PortalColors.surface,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: PortalColors.border),
    ),
    child: Column(
      children: [
        const Icon(
          Icons.search_off_rounded,
          color: PortalColors.muted,
          size: 32,
        ),
        const SizedBox(height: 8),
        Text(
          'No matching permissions',
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

class _LoadError extends StatelessWidget {
  const _LoadError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: PortalColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: PortalColors.border),
      ),
      child: Column(
        children: [
          const Icon(Icons.cloud_off_rounded, color: PortalColors.muted),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: portalText(fontSize: 12, color: PortalColors.muted),
          ),
          const SizedBox(height: 10),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded, size: 17),
            label: const Text('Try again'),
          ),
        ],
      ),
    );
  }
}

class _RequestPermissionSheet extends StatefulWidget {
  const _RequestPermissionSheet();
  @override
  State<_RequestPermissionSheet> createState() =>
      _RequestPermissionSheetState();
}

class _RequestPermissionSheetState extends State<_RequestPermissionSheet> {
  final _reason = TextEditingController();
  DateTime _date = DateTime.now();
  int _minutes = 30;
  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        decoration: const BoxDecoration(
          color: PortalColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: PortalColors.border,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Request permission',
              style: portalText(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: PortalColors.heading,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              'Tell your manager why you need a short break.',
              style: portalText(fontSize: 11.5, color: PortalColors.muted),
            ),
            const SizedBox(height: 18),
            TextField(
              controller: _reason,
              autofocus: true,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: 'Reason',
                hintText: 'e.g. Medical appointment',
                filled: true,
                fillColor: PortalColors.background,
                border: _sheetBorder(),
                enabledBorder: _sheetBorder(),
                focusedBorder: _sheetBorder(PortalColors.purple),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickDate,
                    icon: const Icon(Icons.calendar_today_outlined, size: 16),
                    label: Text(_dateLabel(_date)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: PortalColors.secondaryText,
                      side: const BorderSide(color: PortalColors.border),
                      minimumSize: const Size.fromHeight(46),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    initialValue: _minutes,
                    decoration: InputDecoration(
                      labelText: 'Duration',
                      filled: true,
                      fillColor: PortalColors.background,
                      border: _sheetBorder(),
                    ),
                    items: const [15, 30, 45, 60, 90, 120]
                        .map(
                          (minutes) => DropdownMenuItem(
                            value: minutes,
                            child: Text('$minutes min'),
                          ),
                        )
                        .toList(),
                    onChanged: (value) => setState(() => _minutes = value!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _submit,
                icon: const Icon(Icons.send_rounded, size: 18),
                label: const Text('Send request'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: PortalColors.purple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(13),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  void _submit() {
    final reason = _reason.text.trim();
    if (reason.isEmpty) return;
    Navigator.pop(
      context,
      _PermissionRecord(
        date: _date,
        duration: '$_minutes min',
        reason: reason,
        status: _PermissionStatus.pending,
      ),
    );
  }

  OutlineInputBorder _sheetBorder([Color? color]) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide(color: color ?? PortalColors.border),
  );
}

class _PermissionRecord {
  const _PermissionRecord({
    required this.date,
    required this.duration,
    required this.reason,
    required this.status,
  });
  final DateTime date;
  final String duration;
  final String reason;
  final _PermissionStatus status;
}

enum _PermissionStatus {
  approved('Approved'),
  pending('Pending');

  const _PermissionStatus(this.label);

  final String label;

  static _PermissionStatus fromApi(String value) {
    return value.trim().toUpperCase() == 'APPROVED'
        ? _PermissionStatus.approved
        : _PermissionStatus.pending;
  }
}

bool _sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;
String _dateLabel(DateTime date) {
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
    'Dec',
  ];
  return '${date.day} ${months[date.month - 1]} ${date.year}';
}
