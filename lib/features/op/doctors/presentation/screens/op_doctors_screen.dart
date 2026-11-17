import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:timelay_health/core/theme/portal_text.dart';
import 'package:timelay_health/core/widgets/portal_safe_area.dart';
import 'package:timelay_health/features/op/doctors/presentation/models/op_doctors_ui.dart';
import 'package:timelay_health/features/op/doctors/presentation/screens/op_add_doctor_screen.dart';
import 'package:timelay_health/features/op/appointments/presentation/screens/op_appointment_slots_screen.dart';
import 'package:timelay_health/features/op/dashboard/presentation/theme/op_colors.dart';
import 'package:timelay_health/features/op/shared/widgets/op_top_bar.dart';

class OpDoctorsScreen extends StatefulWidget {
  const OpDoctorsScreen({super.key, this.onMenuTap});

  final VoidCallback? onMenuTap;

  @override
  State<OpDoctorsScreen> createState() => _OpDoctorsScreenState();
}

class _OpDoctorsScreenState extends State<OpDoctorsScreen> {
  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  final _search = TextEditingController();
  late List<OpDoctorUi> _doctors;
  late final List<String> _specializations;

  String _query = '';
  String? _specialization;
  String? _status;
  String? _month;

  @override
  void initState() {
    super.initState();
    final demo = OpDoctorsUi.demo;
    _doctors = List.of(demo.doctors);
    _specializations = List.of(demo.specializations);
    _search.addListener(() => setState(() => _query = _search.text.trim()));
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
      if (_month != null &&
          !d.joinedAt.toLowerCase().contains(_month!.toLowerCase())) {
        return false;
      }
      return true;
    }).toList();
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
    await Future<void>.delayed(const Duration(milliseconds: 650));
    if (!mounted) return;
    setState(() => _doctors = List.of(OpDoctorsUi.demo.doctors));
    _snack('Doctors list refreshed');
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
              style: portalText(fontWeight: FontWeight.w700, color: OpColors.muted),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'Delete',
              style: portalText(fontWeight: FontWeight.w800, color: OpColors.red),
            ),
          ),
        ],
      ),
    );
    if (ok != true) return;
    setState(() => _doctors.removeWhere((d) => d.id == doctor.id));
    _snack('Doctor deleted');
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
          OpTopBar(
            title: 'Doctor Management',
            onMenuTap: widget.onMenuTap,
          ),
          Expanded(
            child: RefreshIndicator(
              color: OpColors.primary,
              onRefresh: _refresh,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(18, 14, 18, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _DoctorsBanner(
                            total: total,
                            active: active,
                          ),
                          const SizedBox(height: 8),
                          const _BannerDots(),
                          const SizedBox(height: 12),
                          _ContentSearchField(controller: _search),
                          const SizedBox(height: 10),
                          _ContentFilterRow(
                            specialization: _specialization,
                            specializations: _specializations,
                            onSpecialization: (v) =>
                                setState(() => _specialization = v),
                            status: _status,
                            onStatus: (v) => setState(() => _status = v),
                            month: _month,
                            months: _months,
                            onMonth: (v) => setState(() => _month = v),
                          ),
                          const SizedBox(height: 12),
                          _StatsRow(
                            total: total,
                            active: active,
                            inactive: inactive,
                            specializations: specs,
                            filtered: filtered.length,
                          ),
                          const SizedBox(height: 12),
                          _ActionButtons(
                            onExport: _exportCsv,
                            onSlots: _openSlots,
                            onAdd: () => _openAddOrEdit(),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Container(
                                width: 28,
                                height: 28,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: OpColors.primaryTint,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.badge_outlined,
                                  size: 15,
                                  color: OpColors.primary,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'REGISTERED DOCTORS',
                                style: portalText(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: OpColors.muted,
                                  letterSpacing: 0.6,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
                  ),
                  if (filtered.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: _EmptyDoctorsState(
                        hasFilters: _query.isNotEmpty ||
                            _specialization != null ||
                            _status != null ||
                            _month != null,
                        onAdd: () => _openAddOrEdit(),
                        onClearFilters: () => setState(() {
                          _search.clear();
                          _specialization = null;
                          _status = null;
                          _month = null;
                        }),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(18, 0, 18, 12),
                      sliver: SliverList.separated(
                        itemCount: filtered.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (context, i) {
                          final doctor = filtered[i];
                          return _DoctorCard(
                            doctor: doctor,
                            onView: () => _viewDoctor(doctor),
                            onEdit: () => _openAddOrEdit(doctor),
                            onDelete: () => _deleteDoctor(doctor),
                          );
                        },
                      ),
                    ),
                  const SliverToBoxAdapter(child: SizedBox(height: 28)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ContentSearchField extends StatelessWidget {
  const _ContentSearchField({required this.controller});
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      alignment: Alignment.center,
      child: Row(
        children: [
          const Icon(Icons.search_rounded, size: 18, color: Color(0xFF94A3B8)),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              style: portalText(fontSize: 13, color: OpColors.heading, fontWeight: FontWeight.w500),
              textAlignVertical: TextAlignVertical.center,
              decoration: InputDecoration(
                hintText: 'Search Name, Phone, Email...',
                hintStyle: portalText(fontSize: 13, color: const Color(0xFF94A3B8)),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          if (controller.text.isNotEmpty)
            GestureDetector(
              onTap: controller.clear,
              child: const Icon(Icons.close_rounded, size: 18, color: Color(0xFF94A3B8)),
            ),
        ],
      ),
    );
  }
}

class _ContentFilterRow extends StatelessWidget {
  const _ContentFilterRow({
    required this.specialization,
    required this.specializations,
    required this.onSpecialization,
    required this.status,
    required this.onStatus,
    required this.month,
    required this.months,
    required this.onMonth,
  });

  final String? specialization;
  final List<String> specializations;
  final ValueChanged<String?> onSpecialization;
  final String? status;
  final ValueChanged<String?> onStatus;
  final String? month;
  final List<String> months;
  final ValueChanged<String?> onMonth;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: _SpecFilterChip(
            value: specialization,
            items: specializations,
            onChanged: onSpecialization,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          flex: 2,
          child: _ContentDropdown(
            icon: Icons.filter_alt_outlined,
            hint: 'Status',
            value: status,
            items: const ['Active', 'Inactive'],
            onChanged: onStatus,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          flex: 2,
          child: _MonthFilterChip(
            month: month,
            months: months,
            onMonth: onMonth,
          ),
        ),
      ],
    );
  }
}

class _SpecFilterChip extends StatelessWidget {
  const _SpecFilterChip({
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  Future<void> _openPicker(BuildContext context) async {
    final picked = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => _SpecPickerSheet(
        items: items,
        selected: value,
      ),
    );
    if (picked == null) return;
    onChanged(picked.isEmpty ? null : picked);
  }

  @override
  Widget build(BuildContext context) {
    final active = value != null;
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () => _openPicker(context),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 42,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: active ? OpColors.primary : const Color(0xFFE2E8F0),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.medical_services_outlined,
                size: 14,
                color: active ? OpColors.primary : const Color(0xFF94A3B8),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  active ? value! : 'Specialization',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: portalText(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: active ? OpColors.primary : const Color(0xFF64748B),
                  ),
                ),
              ),
              if (active)
                GestureDetector(
                  onTap: () => onChanged(null),
                  child: const Icon(Icons.close_rounded, size: 14, color: OpColors.primary),
                )
              else
                const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: Color(0xFF94A3B8)),
            ],
          ),
        ),
      ),
    );
  }
}

class _SpecPickerSheet extends StatefulWidget {
  const _SpecPickerSheet({
    required this.items,
    required this.selected,
  });

  final List<String> items;
  final String? selected;

  @override
  State<_SpecPickerSheet> createState() => _SpecPickerSheetState();
}

class _SpecPickerSheetState extends State<_SpecPickerSheet> {
  final _search = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<String> get _filtered {
    if (_query.isEmpty) return widget.items;
    final q = _query.toLowerCase();
    return widget.items.where((e) => e.toLowerCase().contains(q)).toList();
  }

  IconData _iconFor(String name) {
    switch (name.toLowerCase()) {
      case 'cardiologist':
        return Icons.favorite_rounded;
      case 'dermatologist':
        return Icons.spa_rounded;
      case 'endocrinologist':
        return Icons.science_rounded;
      case 'gastroenterologist':
        return Icons.restaurant_rounded;
      case 'general medicine':
      case 'general physician':
        return Icons.medical_services_rounded;
      case 'gynecologist':
        return Icons.pregnant_woman_rounded;
      case 'neurologist':
        return Icons.psychology_rounded;
      case 'ophthalmologist':
        return Icons.visibility_rounded;
      case 'orthopedic':
        return Icons.accessibility_new_rounded;
      case 'pediatrician':
        return Icons.child_care_rounded;
      case 'psychiatrist':
        return Icons.self_improvement_rounded;
      case 'pulmonologist':
        return Icons.air_rounded;
      case 'radiologist':
        return Icons.radar_rounded;
      case 'surgeon':
        return Icons.content_cut_rounded;
      case 'urologist':
        return Icons.water_drop_rounded;
      default:
        return Icons.local_hospital_rounded;
    }
  }

  (Color, Color) _colorsFor(String name) {
    final c = OpDoctorUi.specializationColor(name);
    final t = OpDoctorUi.specializationTint(name);
    return (c, t);
  }

  @override
  Widget build(BuildContext context) {
    final list = _filtered;
    return SafeArea(
      top: false,
      child: Container(
        height: MediaQuery.sizeOf(context).height * 0.78,
        decoration: const BoxDecoration(
          color: Color(0xFFF7F8FC),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 10, 12, 16),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: OpColors.heroGradient,
                ),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.medical_services_rounded,
                          size: 20,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'All Specializations',
                              style: portalText(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              '${widget.items.length} specialties available',
                              style: portalText(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w500,
                                color: Colors.white.withValues(alpha: 0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (widget.selected != null)
                        TextButton(
                          onPressed: () => Navigator.pop(context, ''),
                          child: Text(
                            'Clear',
                            style: portalText(
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(
                          Icons.close_rounded,
                          color: Colors.white.withValues(alpha: 0.95),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    height: 42,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.search_rounded, size: 18, color: Color(0xFF94A3B8)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _search,
                            onChanged: (v) => setState(() => _query = v.trim()),
                            style: portalText(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                              color: OpColors.heading,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Search specialization...',
                              hintStyle: portalText(
                                fontSize: 13,
                                color: const Color(0xFF94A3B8),
                              ),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                        if (_query.isNotEmpty)
                          GestureDetector(
                            onTap: () {
                              _search.clear();
                              setState(() => _query = '');
                            },
                            child: const Icon(
                              Icons.close_rounded,
                              size: 18,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: list.isEmpty
                  ? Center(
                      child: Text(
                        'No specialization found',
                        style: portalText(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: OpColors.muted,
                        ),
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.fromLTRB(14, 14, 14, 20),
                      itemCount: list.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        childAspectRatio: 2.35,
                      ),
                      itemBuilder: (context, i) {
                        final item = list[i];
                        final selected = item == widget.selected;
                        final colors = _colorsFor(item);
                        return Material(
                          color: selected ? OpColors.primary : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          child: InkWell(
                            onTap: () => Navigator.pop(context, item),
                            borderRadius: BorderRadius.circular(14),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: selected
                                      ? OpColors.primary
                                      : const Color(0xFFE8ECF2),
                                ),
                                boxShadow: selected
                                    ? [
                                        BoxShadow(
                                          color: OpColors.primary.withValues(alpha: 0.2),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 34,
                                    height: 34,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: selected
                                          ? Colors.white.withValues(alpha: 0.18)
                                          : colors.$2,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      _iconFor(item),
                                      size: 17,
                                      color: selected ? Colors.white : colors.$1,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      item,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: portalText(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800,
                                        color: selected ? Colors.white : OpColors.heading,
                                        height: 1.15,
                                      ),
                                    ),
                                  ),
                                  if (selected)
                                    const Icon(
                                      Icons.check_circle_rounded,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                ],
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
    );
  }
}

class _MonthFilterChip extends StatelessWidget {
  const _MonthFilterChip({
    required this.month,
    required this.months,
    required this.onMonth,
  });

  final String? month;
  final List<String> months;
  final ValueChanged<String?> onMonth;

  Future<void> _openPicker(BuildContext context) async {
    final picked = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _MonthPickerSheet(
        months: months,
        selected: month,
      ),
    );
    // null = sheet dismissed, keep current filter
    if (picked == null) return;
    onMonth(picked.isEmpty ? null : picked);
  }

  @override
  Widget build(BuildContext context) {
    final active = month != null;
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () => _openPicker(context),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 42,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: active ? OpColors.primary : const Color(0xFFE2E8F0),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.calendar_month_rounded,
                size: 14,
                color: active ? OpColors.primary : const Color(0xFF94A3B8),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  active ? month! : 'Month',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: portalText(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: active ? OpColors.primary : const Color(0xFF64748B),
                  ),
                ),
              ),
              if (active)
                GestureDetector(
                  onTap: () => onMonth(null),
                  child: const Icon(Icons.close_rounded, size: 14, color: OpColors.primary),
                )
              else
                const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: Color(0xFF94A3B8)),
            ],
          ),
        ),
      ),
    );
  }
}

class _DoctorsBanner extends StatelessWidget {
  const _DoctorsBanner({required this.total, required this.active});

  final int total;
  final int active;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: OpColors.heroGradient,
        ),
        boxShadow: [
          BoxShadow(
            color: OpColors.primary.withValues(alpha: 0.22),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.health_and_safety_rounded,
              size: 24,
              color: OpColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Doctor Roster',
                  style: portalText(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Manage specialists, fees & availability',
                  style: portalText(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.9),
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
            ),
            child: Column(
              children: [
                Text(
                  '$active/$total',
                  style: portalText(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1.1,
                  ),
                ),
                Text(
                  'Active',
                  style: portalText(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.85),
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

class _BannerDots extends StatelessWidget {
  const _BannerDots();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (i) {
        final active = i == 0;
        return Container(
          width: active ? 16 : 6,
          height: 6,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(
            color: active
                ? OpColors.primary
                : OpColors.primary.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(8),
          ),
        );
      }),
    );
  }
}

class _MonthPickerSheet extends StatelessWidget {
  const _MonthPickerSheet({
    required this.months,
    required this.selected,
  });

  final List<String> months;
  final String? selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Text(
                'Select Month',
                style: portalText(fontSize: 16, fontWeight: FontWeight.w800, color: OpColors.heading),
              ),
              const Spacer(),
              if (selected != null)
                TextButton(
                  onPressed: () => Navigator.pop(context, ''),
                  child: Text(
                    'Clear',
                    style: portalText(fontWeight: FontWeight.w700, color: OpColors.primary),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: months.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 1.7,
            ),
            itemBuilder: (context, i) {
              final m = months[i];
              final isSelected = m == selected;
              return Material(
                color: isSelected ? OpColors.primary : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  onTap: () => Navigator.pop(context, m),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? OpColors.primary : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Text(
                      m,
                      style: portalText(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: isSelected ? Colors.white : OpColors.heading,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ContentDropdown extends StatelessWidget {
  const _ContentDropdown({
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

  static const _clear = '__clear__';

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: value,
          hint: Row(
            children: [
              Icon(icon, size: 14, color: const Color(0xFF94A3B8)),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  hint,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: portalText(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ),
            ],
          ),
          icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18),
          style: portalText(fontSize: 11, fontWeight: FontWeight.w700, color: OpColors.heading),
          items: [
            if (value != null)
              DropdownMenuItem(
                value: _clear,
                child: Text('Clear', style: portalText(fontSize: 12, color: const Color(0xFF94A3B8))),
              ),
            ...items.map(
              (e) => DropdownMenuItem(
                value: e,
                child: Text(e, overflow: TextOverflow.ellipsis),
              ),
            ),
          ],
          onChanged: (v) => onChanged(v == null || v == _clear ? null : v),
        ),
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  const _ActionButtons({required this.onExport, required this.onSlots, required this.onAdd});
  final VoidCallback onExport;
  final VoidCallback onSlots;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _PillAction(
            label: 'Export CSV',
            icon: Icons.file_download_outlined,
            bg: const Color(0xFF0F766E),
            onTap: onExport,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _PillAction(
            label: 'Appointment Slots',
            icon: Icons.calendar_month_rounded,
            bg: OpColors.purple,
            onTap: onSlots,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _PillAction(
            label: 'Add Doctor',
            icon: Icons.add_rounded,
            bg: OpColors.primary,
            onTap: onAdd,
          ),
        ),
      ],
    );
  }
}

class _PillAction extends StatelessWidget {
  const _PillAction({required this.label, required this.icon, required this.bg, required this.onTap});
  final String label;
  final IconData icon;
  final Color bg;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 6),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 15, color: Colors.white),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: portalText(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({
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
    final width = MediaQuery.sizeOf(context).width;
    // 3 cards visible: side padding 18*2 + gaps 8*2
    final cardWidth = ((width - 36 - 16) / 3).clamp(100.0, 140.0);

    final items = [
      _StatCard(
        width: cardWidth,
        title: 'Total',
        value: '$total',
        subtitle: 'doctors',
        valueColor: OpColors.heading,
        icon: Icons.person_outline_rounded,
        iconColor: OpColors.blue,
        iconBg: OpColors.blueTint,
      ),
      _StatCard(
        width: cardWidth,
        title: 'Active',
        value: '$active',
        subtitle: 'booking',
        valueColor: OpColors.green,
        icon: Icons.verified_user_outlined,
        iconColor: OpColors.green,
        iconBg: OpColors.greenTint,
      ),
      _StatCard(
        width: cardWidth,
        title: 'Inactive',
        value: '$inactive',
        subtitle: 'paused',
        valueColor: OpColors.orange,
        icon: Icons.person_off_outlined,
        iconColor: OpColors.orange,
        iconBg: OpColors.orangeTint,
      ),
      _StatCard(
        width: cardWidth,
        title: 'Specialties',
        value: '$specializations',
        subtitle: 'fields',
        valueColor: OpColors.purple,
        icon: Icons.workspace_premium_outlined,
        iconColor: OpColors.purple,
        iconBg: OpColors.purpleTint,
      ),
      _StatCard(
        width: cardWidth,
        title: 'Filtered',
        value: '$filtered',
        subtitle: 'matching',
        valueColor: OpColors.heading,
        icon: Icons.filter_alt_rounded,
        iconColor: OpColors.green,
        iconBg: OpColors.greenTint,
      ),
    ];

    return SizedBox(
      height: 78,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (_, i) => items[i],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.width,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.valueColor,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
  });

  final double width;
  final String title;
  final String value;
  final String subtitle;
  final Color valueColor;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.fromLTRB(10, 8, 8, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8ECF2)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: portalText(fontSize: 10, fontWeight: FontWeight.w600, color: OpColors.muted),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: portalText(fontSize: 18, fontWeight: FontWeight.w800, color: valueColor, height: 1.05),
                ),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: portalText(fontSize: 9.5, fontWeight: FontWeight.w500, color: OpColors.muted),
                ),
              ],
            ),
          ),
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, size: 15, color: iconColor),
          ),
        ],
      ),
    );
  }
}

class _EmptyDoctorsState extends StatelessWidget {
  const _EmptyDoctorsState({
    required this.hasFilters,
    required this.onAdd,
    required this.onClearFilters,
  });

  final bool hasFilters;
  final VoidCallback onAdd;
  final VoidCallback onClearFilters;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 12, 28, 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: OpColors.primaryTint,
              shape: BoxShape.circle,
              border: Border.all(color: OpColors.primary.withValues(alpha: 0.15)),
            ),
            child: Icon(
              hasFilters ? Icons.search_off_rounded : Icons.person_add_alt_1_rounded,
              size: 32,
              color: OpColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            hasFilters ? 'No doctors found' : 'No doctors yet',
            style: portalText(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: OpColors.heading,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            hasFilters
                ? 'Try changing search or filters to see results.'
                : 'Add your first doctor to start managing the roster.',
            textAlign: TextAlign.center,
            style: portalText(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: OpColors.muted,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 18),
          if (hasFilters)
            OutlinedButton(
              onPressed: onClearFilters,
              style: OutlinedButton.styleFrom(
                foregroundColor: OpColors.primary,
                side: const BorderSide(color: OpColors.primary),
                minimumSize: const Size(160, 42),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text('Clear Filters', style: portalText(fontWeight: FontWeight.w800, color: OpColors.primary)),
            )
          else
            ElevatedButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: Text('Add Doctor', style: portalText(fontWeight: FontWeight.w800, color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: OpColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                minimumSize: const Size(160, 42),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatefulWidget {
  const _StatusBadge({required this.active});

  final bool active;

  @override
  State<_StatusBadge> createState() => _StatusBadgeState();
}

class _StatusBadgeState extends State<_StatusBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _pulse = Tween<double>(begin: 0.35, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    if (widget.active) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant _StatusBadge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.active && _controller.isAnimating) {
      _controller.stop();
      _controller.value = 1;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.active) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFFFEDD5),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          'INACTIVE',
          style: portalText(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: const Color(0xFFC2410C),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFDCFCE7),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FadeTransition(
            opacity: _pulse,
            child: Container(
              width: 7,
              height: 7,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF16A34A),
              ),
            ),
          ),
          const SizedBox(width: 5),
          Text(
            'ACTIVE',
            style: portalText(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF15803D),
            ),
          ),
        ],
      ),
    );
  }
}

class _DoctorCard extends StatelessWidget {
  const _DoctorCard({
    required this.doctor,
    required this.onView,
    required this.onEdit,
    required this.onDelete,
  });

  final OpDoctorUi doctor;
  final VoidCallback onView;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final specColor = OpDoctorUi.specializationColor(doctor.specialization);
    final specTint = OpDoctorUi.specializationTint(doctor.specialization);
    final letter = doctor.name.trim().isEmpty ? 'D' : doctor.name.trim()[0].toUpperCase();

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onView,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(color: Color(0x142A2456), blurRadius: 16, offset: Offset(0, 6)),
              BoxShadow(color: Color(0x0A1C1B29), blurRadius: 4, offset: Offset(0, 1)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: doctor.avatarColor),
                    child: Text(
                      letter,
                      style: portalText(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          doctor.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: portalText(fontSize: 15, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A)),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: specTint, borderRadius: BorderRadius.circular(20)),
                          child: Text(
                            doctor.specialization,
                            style: portalText(fontSize: 11, fontWeight: FontWeight.w700, color: specColor),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  _StatusBadge(active: doctor.active),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(color: const Color(0xFFF8F9FC), borderRadius: BorderRadius.circular(12)),
                child: Row(
                  children: [
                    Expanded(child: _InfoCell(label: 'Qualification', value: doctor.qualification)),
                    Expanded(child: _InfoCell(label: 'Experience', value: doctor.experienceLabel)),
                    Expanded(child: _InfoCell(label: 'Consult Fee', value: doctor.feeLabel, valueColor: const Color(0xFF16A34A))),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  for (final day in OpDoctorsUi.weekDays) ...[
                    if (day != OpDoctorsUi.weekDays.first) const SizedBox(width: 5),
                    Expanded(
                      child: Container(
                        height: 30,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: doctor.scheduleDays.contains(day) ? const Color(0xFFF1F3F8) : Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: doctor.scheduleDays.contains(day) ? const Color(0xFFE6E9F0) : const Color(0xFFE5E7EB),
                          ),
                        ),
                        child: Text(
                          day,
                          style: portalText(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: doctor.scheduleDays.contains(day) ? const Color(0xFF334155) : const Color(0xFF94A3B8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.access_time_rounded, size: 15, color: Color(0xFF94A3B8)),
                  const SizedBox(width: 6),
                  Text(
                    doctor.scheduleTime,
                    style: portalText(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF64748B)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Joined: ${doctor.joinedAt}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: portalText(fontSize: 11, fontWeight: FontWeight.w500, color: const Color(0xFF94A3B8)),
                    ),
                  ),
                  SizedBox(
                    width: 96,
                    height: 19,
                    child: Stack(
                      children: [
                        SvgPicture.asset(
                          'assets/icons/issues/frame_36_actions.svg',
                          width: 96,
                          height: 19,
                        ),
                        Positioned(
                          left: 0,
                          top: 0,
                          bottom: 0,
                          width: 32,
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: onView,
                          ),
                        ),
                        Positioned(
                          left: 32,
                          top: 0,
                          bottom: 0,
                          width: 32,
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: onEdit,
                          ),
                        ),
                        Positioned(
                          right: 0,
                          top: 0,
                          bottom: 0,
                          width: 32,
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: onDelete,
                          ),
                        ),
                      ],
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

class _InfoCell extends StatelessWidget {
  const _InfoCell({required this.label, required this.value, this.valueColor});
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: portalText(fontSize: 10, fontWeight: FontWeight.w500, color: const Color(0xFF94A3B8))),
        const SizedBox(height: 3),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: portalText(fontSize: 13, fontWeight: FontWeight.w800, color: valueColor ?? const Color(0xFF0F172A)),
        ),
      ],
    );
  }
}

class _DoctorDetailSheet extends StatefulWidget {
  const _DoctorDetailSheet({
    required this.doctor,
    required this.onEdit,
    required this.onToggleStatus,
  });

  final OpDoctorUi doctor;
  final VoidCallback onEdit;
  final VoidCallback onToggleStatus;

  @override
  State<_DoctorDetailSheet> createState() => _DoctorDetailSheetState();
}

class _DoctorDetailSheetState extends State<_DoctorDetailSheet> {
  bool _obscurePassword = true;

  // Demo login password until API wires real credentials.
  String get _password => 'Doctor@${widget.doctor.id}';

  @override
  Widget build(BuildContext context) {
    final doctor = widget.doctor;
    final onEdit = widget.onEdit;
    final onToggleStatus = widget.onToggleStatus;
    final specColor = OpDoctorUi.specializationColor(doctor.specialization);
    final specTint = OpDoctorUi.specializationTint(doctor.specialization);
    final letter = doctor.name.trim().isEmpty ? 'D' : doctor.name.trim()[0].toUpperCase();
    final days = doctor.scheduleDays.isEmpty ? 'Not set' : doctor.scheduleDays.join(' · ');
    final address = doctor.address.trim().isEmpty ? 'Not set' : doctor.address.trim();
    final email = doctor.email.trim().isEmpty ? 'Not set' : doctor.email.trim();
    final qual = doctor.qualification.trim().isEmpty ? 'N/A' : doctor.qualification.trim();

    return Container(
      margin: const EdgeInsets.only(top: 40),
      decoration: const BoxDecoration(
        color: Color(0xFFF7F8FC),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(16, 10, 12, 22),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: OpColors.heroGradient,
                    ),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.16),
                              borderRadius: BorderRadius.circular(11),
                            ),
                            child: const Icon(
                              Icons.health_and_safety_rounded,
                              size: 18,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Doctor Profile',
                                  style: portalText(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    height: 1.15,
                                  ),
                                ),
                                Text(
                                  'ID: ${doctor.id}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: portalText(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white.withValues(alpha: 0.75),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            visualDensity: VisualDensity.compact,
                            icon: Icon(
                              Icons.close_rounded,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Container(
                            width: 58,
                            height: 58,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.18),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.35), width: 2),
                            ),
                            child: Text(
                              letter,
                              style: portalText(
                                fontSize: 22,
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
                                  doctor.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: portalText(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  doctor.specialization,
                                  style: portalText(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white.withValues(alpha: 0.85),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: doctor.active
                                        ? OpColors.green.withValues(alpha: 0.2)
                                        : OpColors.orange.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: doctor.active
                                          ? OpColors.green.withValues(alpha: 0.5)
                                          : OpColors.orange.withValues(alpha: 0.5),
                                    ),
                                  ),
                                  child: Text(
                                    doctor.statusLabel,
                                    style: portalText(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w800,
                                      color: doctor.active ? const Color(0xFFBBF7D0) : const Color(0xFFFED7AA),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _DetailTile(
                              icon: Icons.call_outlined,
                              label: 'Phone',
                              value: doctor.phone,
                              accent: OpColors.green,
                              tint: OpColors.greenTint,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _DetailTile(
                              icon: Icons.currency_rupee_rounded,
                              label: 'Consult Fee',
                              value: doctor.feeLabel,
                              accent: OpColors.blue,
                              tint: OpColors.blueTint,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _DetailTile(
                              icon: Icons.school_outlined,
                              label: 'Qualification',
                              value: qual,
                              accent: OpColors.purple,
                              tint: OpColors.purpleTint,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _DetailTile(
                              icon: Icons.workspace_premium_outlined,
                              label: 'Experience',
                              value: doctor.experienceLabel,
                              accent: OpColors.orange,
                              tint: OpColors.orangeTint,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _DetailTile(
                        icon: Icons.mail_outline_rounded,
                        label: 'Email',
                        value: email,
                        accent: OpColors.primary,
                        tint: OpColors.primaryTint,
                        full: true,
                      ),
                      const SizedBox(height: 8),
                      _DetailTile(
                        icon: Icons.location_on_outlined,
                        label: 'Address',
                        value: address,
                        accent: OpColors.cyan,
                        tint: const Color(0xFFE0F7FA),
                        full: true,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFE8ECF2)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 30,
                                  height: 30,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: specTint,
                                    borderRadius: BorderRadius.circular(9),
                                  ),
                                  child: Icon(Icons.calendar_month_rounded, size: 15, color: specColor),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Availability',
                                  style: portalText(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: OpColors.heading,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Available Days',
                              style: portalText(fontSize: 10.5, fontWeight: FontWeight.w600, color: OpColors.muted),
                            ),
                            const SizedBox(height: 6),
                            if (doctor.scheduleDays.isEmpty)
                              Text(
                                days,
                                style: portalText(fontSize: 13, fontWeight: FontWeight.w700, color: OpColors.heading),
                              )
                            else
                              Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: doctor.scheduleDays
                                    .map(
                                      (d) => Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                        decoration: BoxDecoration(
                                          color: OpColors.primaryTint,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          d,
                                          style: portalText(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w800,
                                            color: OpColors.primary,
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ),
                            const SizedBox(height: 10),
                            Text(
                              'Time Slot',
                              style: portalText(fontSize: 10.5, fontWeight: FontWeight.w600, color: OpColors.muted),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.access_time_rounded, size: 15, color: Color(0xFF94A3B8)),
                                const SizedBox(width: 6),
                                Text(
                                  doctor.scheduleTime,
                                  style: portalText(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: OpColors.heading,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Joined: ${doctor.joinedAt}',
                              style: portalText(fontSize: 11.5, fontWeight: FontWeight.w500, color: OpColors.muted),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEEF4FF),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFD6E4FF)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 30,
                                  height: 30,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(9),
                                  ),
                                  child: const Icon(
                                    Icons.key_rounded,
                                    size: 15,
                                    color: OpColors.blue,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'LOGIN PASSWORD',
                                  style: portalText(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: OpColors.blue,
                                    letterSpacing: 0.4,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(11),
                                border: Border.all(color: const Color(0xFFD6E4FF)),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      _obscurePassword
                                          ? '•' * _password.length.clamp(8, 14)
                                          : _password,
                                      style: portalText(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: OpColors.heading,
                                        letterSpacing: _obscurePassword ? 2 : 0,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () => setState(
                                      () => _obscurePassword = !_obscurePassword,
                                    ),
                                    visualDensity: VisualDensity.compact,
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(
                                      minWidth: 36,
                                      minHeight: 36,
                                    ),
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                      size: 18,
                                      color: OpColors.muted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Color(0xFFE8ECF2))),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onToggleStatus,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: doctor.active ? OpColors.orange : OpColors.green,
                        side: BorderSide(
                          color: doctor.active ? OpColors.orange : OpColors.green,
                        ),
                        minimumSize: const Size.fromHeight(42),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        doctor.active ? 'Set Inactive' : 'Set Active',
                        style: portalText(fontSize: 12.5, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onEdit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: OpColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        minimumSize: const Size.fromHeight(42),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Edit Doctor',
                        style: portalText(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailTile extends StatelessWidget {
  const _DetailTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.accent,
    required this.tint,
    this.full = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color accent;
  final Color tint;
  final bool full;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: full ? double.infinity : null,
      padding: const EdgeInsets.fromLTRB(11, 11, 11, 11),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE8ECF2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: tint,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, size: 15, color: accent),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: portalText(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: OpColors.muted,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: full ? 3 : 2,
                  overflow: TextOverflow.ellipsis,
                  style: portalText(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: OpColors.heading,
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
