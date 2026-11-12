import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:timelay_health/core/theme/portal_text.dart';
import 'package:timelay_health/core/widgets/portal_safe_area.dart';
import 'package:timelay_health/features/op/dashboard/presentation/models/op_doctors_ui.dart';
import 'package:timelay_health/features/op/dashboard/presentation/screens/op_add_doctor_screen.dart';
import 'package:timelay_health/features/op/dashboard/presentation/screens/op_appointment_slots_screen.dart';
import 'package:timelay_health/features/op/dashboard/presentation/theme/op_colors.dart';
import 'package:timelay_health/features/op/dashboard/presentation/widgets/op_top_bar.dart';

class OpDoctorsScreen extends StatefulWidget {
  const OpDoctorsScreen({super.key, this.onMenuTap});

  final VoidCallback? onMenuTap;

  @override
  State<OpDoctorsScreen> createState() => _OpDoctorsScreenState();
}

class _OpDoctorsScreenState extends State<OpDoctorsScreen> {
  final _search = TextEditingController();
  late List<OpDoctorUi> _doctors;
  late final List<String> _specializations;

  String _query = '';
  String? _specialization;
  String? _status; // Active / Inactive
  DateTime? _joinedDate;
  bool _refreshing = false;

  @override
  void initState() {
    super.initState();
    final demo = OpDoctorsUi.demo;
    _doctors = List.of(demo.doctors);
    _specializations = List.of(demo.specializations);
    _search.addListener(() => setState(() {
          _query = _search.text.trim();
        }));
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<OpDoctorUi> get _filtered {
    return _doctors.where((d) {
      if (_query.isNotEmpty) {
        final q = _query.toLowerCase();
        final hit = d.name.toLowerCase().contains(q) ||
            d.phone.contains(q) ||
            d.email.toLowerCase().contains(q) ||
            d.specialization.toLowerCase().contains(q);
        if (!hit) return false;
      }
      if (_specialization != null && d.specialization != _specialization) {
        return false;
      }
      if (_status == 'Active' && !d.active) return false;
      if (_status == 'Inactive' && d.active) return false;
      if (_joinedDate != null) {
        final label = _formatJoinedFilter(_joinedDate!);
        if (!d.joinedAt.toLowerCase().startsWith(label.toLowerCase())) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  String _formatJoinedFilter(DateTime d) {
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
    final dd = d.day.toString().padLeft(2, '0');
    return '$dd ${months[d.month - 1]} ${d.year}';
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _refresh() async {
    setState(() => _refreshing = true);
    await Future<void>.delayed(const Duration(milliseconds: 650));
    if (!mounted) return;
    setState(() {
      _refreshing = false;
      _doctors = List.of(OpDoctorsUi.demo.doctors);
    });
    _snack('Doctors list refreshed');
  }

  void _exportCsv() {
    final rows = _filtered;
    if (rows.isEmpty) {
      _snack('No records to export');
      return;
    }
    final buf = StringBuffer(
      'S.No,Doctor,Phone,Email,Specialization,Qualification,Experience,Fee,Schedule,Status,Joined\n',
    );
    for (var i = 0; i < rows.length; i++) {
      final d = rows[i];
      buf.writeln(
        '${i + 1},"${d.name}",${d.phone},${d.email},${d.specialization},'
        '${d.qualification},${d.experienceYrs},${d.fee},'
        '"${d.scheduleDays.join(' ')} ${d.scheduleTime}",${d.statusLabel},'
        '"${d.joinedAt}"',
      );
    }
    Clipboard.setData(ClipboardData(text: buf.toString()));
    _snack('CSV copied (${rows.length} records)');
  }

  Future<void> _pickJoinedDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _joinedDate ?? now,
      firstDate: DateTime(2020),
      lastDate: DateTime(now.year + 1),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: OpColors.primary,
                ),
          ),
          child: child!,
        );
      },
    );
    if (picked == null) return;
    setState(() {
      _joinedDate = picked;
    });
  }

  void _clearJoinedDate() {
    setState(() {
      _joinedDate = null;
    });
  }

  Future<void> _openAddOrEdit([OpDoctorUi? existing]) async {
    final result = await Navigator.of(context).push<OpDoctorUi>(
      MaterialPageRoute(
        builder: (ctx) => Scaffold(
          backgroundColor: OpColors.background,
          body: PortalSafeArea(
            bottom: false,
            statusBarColor: OpColors.primary,
            child: OpAddDoctorScreen(
              specializations: _specializations,
              existing: existing,
              onMenuTap: () => Navigator.of(ctx).pop(),
            ),
          ),
        ),
      ),
    );
    if (result == null) return;
    setState(() {
      final idx = _doctors.indexWhere((d) => d.id == result.id);
      if (idx >= 0) {
        _doctors[idx] = result;
      } else {
        _doctors.insert(0, result);
      }
    });
    _snack(existing == null ? 'Doctor added' : 'Doctor updated');
  }

  Future<void> _viewDoctor(OpDoctorUi doctor) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _DoctorDetailSheet(
        doctor: doctor,
        onEdit: () {
          Navigator.pop(context);
          _openAddOrEdit(doctor);
        },
        onToggleStatus: () {
          Navigator.pop(context);
          _toggleStatus(doctor);
        },
      ),
    );
  }

  void _toggleStatus(OpDoctorUi doctor) {
    setState(() {
      final idx = _doctors.indexWhere((d) => d.id == doctor.id);
      if (idx < 0) return;
      _doctors[idx] = doctor.copyWith(active: !doctor.active);
    });
    _snack(doctor.active ? 'Doctor set inactive' : 'Doctor set active');
  }

  Future<void> _deleteDoctor(OpDoctorUi doctor) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          'Delete Doctor',
          style: portalText(fontSize: 17, fontWeight: FontWeight.w800),
        ),
        content: Text(
          'Remove ${doctor.name} from the roster?',
          style: portalText(fontSize: 14, color: OpColors.secondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Cancel',
              style: portalText(
                fontWeight: FontWeight.w700,
                color: OpColors.muted,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'Delete',
              style: portalText(
                fontWeight: FontWeight.w800,
                color: OpColors.red,
              ),
            ),
          ),
        ],
      ),
    );
    if (ok != true) return;
    setState(() {
      _doctors.removeWhere((d) => d.id == doctor.id);
    });
    _snack('Doctor deleted');
  }

  void _openSlots() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (ctx) => Scaffold(
          backgroundColor: OpColors.background,
          body: PortalSafeArea(
            bottom: false,
            statusBarColor: OpColors.primary,
            child: OpAppointmentSlotsScreen(
              onMenuTap: () => Navigator.of(ctx).pop(),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    final total = _doctors.length;
    final active = _doctors.where((d) => d.active).length;
    final inactive = total - active;
    final specs = _doctors.map((d) => d.specialization).toSet().length;

    return ColoredBox(
      color: OpColors.background,
      child: Column(
        children: [
          OpTopBar(title: 'Doctor Management', onMenuTap: widget.onMenuTap),
          Expanded(
            child: RefreshIndicator(
              color: OpColors.primary,
              onRefresh: _refresh,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _DoctorsHeroBanner(onAdd: () => _openAddOrEdit()),
                          const SizedBox(height: 12),
                          _SearchField(controller: _search),
                          const SizedBox(height: 10),
                          _FilterRow(
                            joinedLabel: _joinedDate == null
                                ? null
                                : _formatJoinedFilter(_joinedDate!),
                            onPickDate: _pickJoinedDate,
                            onClearDate: _joinedDate == null
                                ? null
                                : _clearJoinedDate,
                            specialization: _specialization,
                            specializations: _specializations,
                            onSpecialization: (v) => setState(() {
                              _specialization = v;
                                                    }),
                            status: _status,
                            onStatus: (v) => setState(() {
                              _status = v;
                                                    }),
                          ),
                          const SizedBox(height: 10),
                          _ActionButtons(
                            refreshing: _refreshing,
                            onRefresh: _refresh,
                            onExport: _exportCsv,
                            onSlots: _openSlots,
                            onAdd: () => _openAddOrEdit(),
                          ),
                          const SizedBox(height: 14),
                          _StatsGrid(
                            total: total,
                            active: active,
                            inactive: inactive,
                            specializations: specs,
                            filtered: filtered.length,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Container(
                                width: 4,
                                height: 18,
                                decoration: BoxDecoration(
                                  color: OpColors.primary,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Doctors Directory',
                                style: portalText(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: OpColors.heading,
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: OpColors.primaryTint,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '${filtered.length}',
                                  style: portalText(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: OpColors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ),
                  if (filtered.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Text(
                          'No doctors match your filters',
                          style: portalText(
                            fontSize: 14,
                            color: OpColors.muted,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(14, 0, 14, 8),
                      sliver: SliverList.separated(
                        itemCount: filtered.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (context, i) {
                          final doctor = filtered[i];
                          final sno = i + 1;
                          return _DoctorCard(
                            sno: sno,
                            doctor: doctor,
                            onView: () => _viewDoctor(doctor),
                            onEdit: () => _openAddOrEdit(doctor),
                            onDelete: () => _deleteDoctor(doctor),
                            onToggleStatus: () => _toggleStatus(doctor),
                          );
                        },
                      ),
                    ),
                  const SliverToBoxAdapter(child: SizedBox(height: 24)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DoctorsHeroBanner extends StatelessWidget {
  const _DoctorsHeroBanner({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 148),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          begin: Alignment(-0.8, -1),
          end: Alignment(1, 1),
          colors: OpColors.heroGradient,
        ),
        boxShadow: [
          BoxShadow(
            color: OpColors.primary.withValues(alpha: 0.26),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            right: -36,
            top: -44,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          Positioned(
            right: 54,
            bottom: -40,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
          ),
          Positioned(
            left: -24,
            bottom: -20,
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
          Positioned(
            right: 14,
            top: 18,
            bottom: 18,
            child: AspectRatio(
              aspectRatio: 0.82,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withValues(alpha: 0.22),
                      Colors.white.withValues(alpha: 0.08),
                    ],
                  ),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.28),
                  ),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned(
                      top: 12,
                      child: Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.2),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.45),
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.person_rounded,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    ),
                    const Positioned(
                      bottom: 16,
                      child: Icon(
                        Icons.medical_services_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 108, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'DOCTOR MANAGEMENT',
                    style: portalText(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Colors.white.withValues(alpha: 0.9),
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Manage Your Doctors',
                  style: portalText(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Add, view and manage all doctors in one place.',
                  style: portalText(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.86),
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 12),
                Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    onTap: onAdd,
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.add_rounded,
                            size: 16,
                            color: OpColors.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Add Doctor',
                            style: portalText(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: OpColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: OpColors.card(radius: 16),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: OpColors.blueTint,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.search_rounded,
              size: 18,
              color: OpColors.blue,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Search Name, Phone, Email...',
                hintStyle: portalText(fontSize: 13, color: OpColors.muted),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
          if (controller.text.isNotEmpty)
            GestureDetector(
              onTap: controller.clear,
              child: const Icon(
                Icons.close_rounded,
                size: 18,
                color: OpColors.muted,
              ),
            ),
        ],
      ),
    );
  }
}

class _FilterRow extends StatelessWidget {
  const _FilterRow({
    required this.joinedLabel,
    required this.onPickDate,
    required this.onClearDate,
    required this.specialization,
    required this.specializations,
    required this.onSpecialization,
    required this.status,
    required this.onStatus,
  });

  final String? joinedLabel;
  final VoidCallback onPickDate;
  final VoidCallback? onClearDate;
  final String? specialization;
  final List<String> specializations;
  final ValueChanged<String?> onSpecialization;
  final String? status;
  final ValueChanged<String?> onStatus;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _FilterChipButton(
            icon: Icons.calendar_month_rounded,
            label: joinedLabel ?? 'Joined date',
            active: joinedLabel != null,
            onTap: onPickDate,
            onClear: onClearDate,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _DropdownFilter(
            icon: Icons.medical_services_outlined,
            hint: 'Specialization',
            value: specialization,
            items: specializations,
            onChanged: onSpecialization,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _DropdownFilter(
            icon: Icons.toggle_on_outlined,
            hint: 'Status',
            value: status,
            items: const ['Active', 'Inactive'],
            onChanged: onStatus,
          ),
        ),
      ],
    );
  }
}

class _FilterChipButton extends StatelessWidget {
  const _FilterChipButton({
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
    return Material(
      color: OpColors.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: active ? OpColors.blue : OpColors.border,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: active ? OpColors.blue : OpColors.muted,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: portalText(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: active ? OpColors.blue : OpColors.secondary,
                  ),
                ),
              ),
              if (onClear != null)
                GestureDetector(
                  onTap: onClear,
                  child: const Icon(
                    Icons.close_rounded,
                    size: 14,
                    color: OpColors.muted,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DropdownFilter extends StatelessWidget {
  const _DropdownFilter({
    required this.icon,
    required this.hint,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final IconData icon;
  final String hint;
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: OpColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: value != null ? OpColors.blue : OpColors.border,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String?>(
          isExpanded: true,
          value: value,
          hint: Row(
            children: [
              Icon(icon, size: 15, color: OpColors.muted),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  hint,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: portalText(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: OpColors.secondary,
                  ),
                ),
              ),
            ],
          ),
          icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18),
          style: portalText(
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            color: OpColors.heading,
          ),
          items: [
            DropdownMenuItem<String?>(
              value: null,
              child: Text(
                'All',
                style: portalText(fontSize: 12, color: OpColors.muted),
              ),
            ),
            ...items.map(
              (e) => DropdownMenuItem<String?>(
                value: e,
                child: Text(e, overflow: TextOverflow.ellipsis),
              ),
            ),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  const _ActionButtons({
    required this.refreshing,
    required this.onRefresh,
    required this.onExport,
    required this.onSlots,
    required this.onAdd,
  });

  final bool refreshing;
  final VoidCallback onRefresh;
  final VoidCallback onExport;
  final VoidCallback onSlots;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _IconAction(
          icon: Icons.refresh_rounded,
          color: OpColors.secondary,
          bg: OpColors.surface,
          border: OpColors.border,
          spinning: refreshing,
          onTap: onRefresh,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _PillAction(
            label: 'Export CSV',
            icon: Icons.file_download_outlined,
            fg: OpColors.green,
            bg: OpColors.greenTint,
            border: OpColors.green.withValues(alpha: 0.35),
            onTap: onExport,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _PillAction(
            label: 'Slots',
            icon: Icons.event_available_rounded,
            fg: OpColors.purple,
            bg: OpColors.purpleTint,
            border: OpColors.purple.withValues(alpha: 0.35),
            onTap: onSlots,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _PillAction(
            label: 'Add',
            icon: Icons.person_add_alt_1_rounded,
            fg: Colors.white,
            bg: OpColors.blue,
            border: OpColors.blue,
            onTap: onAdd,
          ),
        ),
      ],
    );
  }
}

class _IconAction extends StatelessWidget {
  const _IconAction({
    required this.icon,
    required this.color,
    required this.bg,
    required this.border,
    required this.onTap,
    this.spinning = false,
  });

  final IconData icon;
  final Color color;
  final Color bg;
  final Color border;
  final VoidCallback onTap;
  final bool spinning;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: border),
          ),
          alignment: Alignment.center,
          child: spinning
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(icon, size: 20, color: color),
        ),
      ),
    );
  }
}

class _PillAction extends StatelessWidget {
  const _PillAction({
    required this.label,
    required this.icon,
    required this.fg,
    required this.bg,
    required this.border,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color fg;
  final Color bg;
  final Color border;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: 44,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: border),
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 15, color: fg),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: portalText(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    color: fg,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({
    required this.total,
    required this.active,
    required this.inactive,
    required this.specializations,
    required this.filtered,
  });

  final int total;
  final int active;
  final int inactive;
  final int specializations;
  final int filtered;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _StatCard(
                title: 'Total',
                value: '$total',
                icon: Icons.groups_rounded,
                accent: OpColors.blue,
                tint: OpColors.blueTint,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _StatCard(
                title: 'Active',
                value: '$active',
                icon: Icons.verified_user_rounded,
                accent: OpColors.green,
                tint: OpColors.greenTint,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _StatCard(
                title: 'Inactive',
                value: '$inactive',
                icon: Icons.pause_circle_filled_rounded,
                accent: OpColors.orange,
                tint: OpColors.orangeTint,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                title: 'Specializations',
                value: '$specializations',
                icon: Icons.local_hospital_rounded,
                accent: OpColors.cyan,
                tint: const Color(0xFFE0F7FA),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _StatCard(
                title: 'Filtered',
                value: '$filtered',
                icon: Icons.filter_alt_rounded,
                accent: OpColors.primary,
                tint: OpColors.primaryTint,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.accent,
    required this.tint,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color accent;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: OpColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: OpColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: tint,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, size: 16, color: accent),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: portalText(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: OpColors.muted,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: portalText(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: accent,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DoctorCard extends StatelessWidget {
  const _DoctorCard({
    required this.sno,
    required this.doctor,
    required this.onView,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleStatus,
  });

  final int sno;
  final OpDoctorUi doctor;
  final VoidCallback onView;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggleStatus;

  @override
  Widget build(BuildContext context) {
    final specColor = OpDoctorUi.specializationColor(doctor.specialization);
    final specTint = OpDoctorUi.specializationTint(doctor.specialization);

    return Material(
      color: OpColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onView,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: OpColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    '#$sno',
                    style: portalText(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: OpColors.muted,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 40,
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: doctor.avatarColor.withValues(alpha: 0.14),
                      border: Border.all(
                        color: doctor.avatarColor.withValues(alpha: 0.35),
                      ),
                    ),
                    child: Text(
                      doctor.initials,
                      style: portalText(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: doctor.avatarColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          doctor.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: portalText(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: OpColors.heading,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${doctor.qualification} · ${doctor.experienceLabel} · ${doctor.feeLabel}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: portalText(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: OpColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: doctor.active
                          ? OpColors.greenTint
                          : OpColors.orangeTint,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      doctor.active ? 'Active' : 'Off',
                      style: portalText(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color:
                            doctor.active ? OpColors.green : OpColors.orange,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: specTint,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      doctor.specialization,
                      style: portalText(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: specColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${doctor.scheduleDays.take(3).join(', ')}${doctor.scheduleDays.length > 3 ? '…' : ''} · ${doctor.scheduleTime}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: portalText(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: OpColors.secondary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _IconBtn(
                    icon: Icons.visibility_outlined,
                    color: OpColors.blue,
                    onTap: onView,
                  ),
                  const SizedBox(width: 6),
                  _IconBtn(
                    icon: Icons.edit_outlined,
                    color: OpColors.primary,
                    onTap: onEdit,
                  ),
                  const SizedBox(width: 6),
                  _IconBtn(
                    icon: Icons.delete_outline_rounded,
                    color: OpColors.red,
                    onTap: onDelete,
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: onToggleStatus,
                    child: Text(
                      doctor.active ? 'Set Inactive' : 'Set Active',
                      style: portalText(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: doctor.active ? OpColors.red : OpColors.green,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  const _IconBtn({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(
          width: 32,
          height: 32,
          child: Icon(icon, size: 16, color: color),
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.label, required this.fg, required this.bg});

  final String label;
  final Color fg;
  final Color bg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: portalText(
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
          color: fg,
        ),
      ),
    );
  }
}

class _DoctorDetailSheet extends StatelessWidget {
  const _DoctorDetailSheet({
    required this.doctor,
    required this.onEdit,
    required this.onToggleStatus,
  });

  final OpDoctorUi doctor;
  final VoidCallback onEdit;
  final VoidCallback onToggleStatus;

  @override
  Widget build(BuildContext context) {
    final specColor = OpDoctorUi.specializationColor(doctor.specialization);
    return Container(
      margin: const EdgeInsets.only(top: 48),
      decoration: const BoxDecoration(
        color: OpColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
        children: [
          Center(
            child: Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                color: OpColors.border,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Center(
            child: Container(
              width: 72,
              height: 72,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    doctor.avatarColor,
                    doctor.avatarColor.withValues(alpha: 0.7),
                  ],
                ),
              ),
              child: Text(
                doctor.initials,
                style: portalText(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            doctor.name,
            textAlign: TextAlign.center,
            style: portalText(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Center(
            child: _Tag(
              label: doctor.specialization,
              fg: specColor,
              bg: OpDoctorUi.specializationTint(doctor.specialization),
            ),
          ),
          const SizedBox(height: 18),
          _detailRow('Phone', doctor.phone),
          _detailRow('Email', doctor.email),
          _detailRow('Qualification', doctor.qualification),
          _detailRow('Experience', doctor.experienceLabel),
          _detailRow('Fee', doctor.feeLabel),
          _detailRow('Schedule', doctor.scheduleDays.join(', ')),
          _detailRow('Timing', doctor.scheduleTime),
          _detailRow('Status', doctor.statusLabel),
          _detailRow('Joined', doctor.joinedAt),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onToggleStatus,
                  style: OutlinedButton.styleFrom(
                    foregroundColor:
                        doctor.active ? OpColors.red : OpColors.green,
                    side: BorderSide(
                      color: doctor.active ? OpColors.red : OpColors.green,
                    ),
                    minimumSize: const Size.fromHeight(46),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    doctor.active ? 'Set Inactive' : 'Set Active',
                    style: portalText(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: onEdit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: OpColors.purple,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    minimumSize: const Size.fromHeight(46),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    'Edit',
                    style: portalText(
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: portalText(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: OpColors.muted,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: portalText(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: OpColors.heading,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
