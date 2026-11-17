import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:timelay_health/core/theme/portal_text.dart';
import 'package:timelay_health/features/op/online_booking/presentation/models/op_online_booking_ui.dart';
import 'package:timelay_health/features/op/dashboard/presentation/theme/op_colors.dart';

class OpOnlineBookingScreen extends StatefulWidget {
  const OpOnlineBookingScreen({super.key, this.onMenuTap});

  final VoidCallback? onMenuTap;

  @override
  State<OpOnlineBookingScreen> createState() => _OpOnlineBookingScreenState();
}

class _OpOnlineBookingScreenState extends State<OpOnlineBookingScreen> {
  final _search = TextEditingController();
  late final OpOnlineBookingsUi _data;
  late List<OpOnlineBookingUi> _bookings;

  String _query = '';
  String _doctor = 'All Doctors';
  String _status = 'All Status';
  String _payStatus = 'All Payment Status';
  DateTime _date = DateTime.now();
  bool _showInactive = false;

  @override
  void initState() {
    super.initState();
    _data = OpOnlineBookingsUi.demo;
    _bookings = List.of(_data.bookings);
    _search.addListener(() => setState(() => _query = _search.text.trim()));
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  List<OpOnlineBookingUi> get _filtered {
    return _bookings.where((b) {
      if (!_showInactive && !b.active) return false;
      if (_showInactive && b.active) return false;
      if (_doctor != 'All Doctors' && b.doctor != _doctor) return false;
      if (_status != 'All Status' &&
          b.status.toLowerCase() != _status.toLowerCase()) {
        return false;
      }
      if (_payStatus != 'All Payment Status' &&
          b.payStatus.toLowerCase() != _payStatus.toLowerCase()) {
        return false;
      }
      if (_query.isNotEmpty) {
        final q = _query.toLowerCase();
        final hit = b.name.toLowerCase().contains(q) ||
            b.pid.toLowerCase().contains(q) ||
            b.phone.contains(q) ||
            b.doctor.toLowerCase().contains(q) ||
            b.txnId.toLowerCase().contains(q);
        if (!hit) return false;
      }
      return true;
    }).toList();
  }

  List<OpOnlineBookingMetricUi> _metricsFor(List<OpOnlineBookingUi> bookings) {
    final paid = bookings.where((b) => b.payStatus.toLowerCase() == 'paid').length;
    final pending =
        bookings.where((b) => b.payStatus.toLowerCase() == 'pending').length;
    final revenue = bookings.fold<int>(0, (sum, b) => sum + b.total);
    return [
      OpOnlineBookingMetricUi(
        title: 'Total Online',
        value: '${bookings.length}',
        subtitle: 'online appointments',
        accent: OpColors.blue,
        icon: Icons.groups_rounded,
        tint: OpColors.blueTint,
      ),
      OpOnlineBookingMetricUi(
        title: 'Paid',
        value: '$paid',
        subtitle: 'completed payments',
        accent: OpColors.green,
        icon: Icons.person_rounded,
        tint: OpColors.greenTint,
      ),
      OpOnlineBookingMetricUi(
        title: 'Pending',
        value: '$pending',
        subtitle: 'awaiting payment',
        accent: OpColors.orange,
        icon: Icons.schedule_rounded,
        tint: OpColors.orangeTint,
      ),
      OpOnlineBookingMetricUi(
        title: 'Total Revenue',
        value: '₹$revenue',
        subtitle: 'collected revenue',
        accent: OpColors.green,
        icon: Icons.currency_rupee_rounded,
        tint: OpColors.greenTint,
      ),
      OpOnlineBookingMetricUi(
        title: 'Filtered',
        value: '${bookings.length}',
        subtitle: 'matching filters',
        accent: OpColors.blue,
        icon: Icons.filter_alt_rounded,
        tint: OpColors.blueTint,
      ),
    ];
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2024),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme.copyWith(
                primary: OpColors.primary,
              ),
        ),
        child: child!,
      ),
    );
    if (picked == null) return;
    setState(() => _date = picked);
  }

  void _toggleActive(OpOnlineBookingUi booking, bool value) {
    setState(() {
      final i = _bookings.indexWhere((e) => e.id == booking.id);
      if (i < 0) return;
      _bookings[i] = _bookings[i].copyWith(active: value);
    });
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

  @override
  Widget build(BuildContext context) {
    final bookings = _filtered;
    final metrics = _metricsFor(bookings);

    return ColoredBox(
      color: const Color(0xFFF6F8FC),
      child: Column(
        children: [
          _OnlineBookingTopBar(onMenuTap: widget.onMenuTap),
          Expanded(
            child: RefreshIndicator(
              color: OpColors.primary,
              onRefresh: () async => _snack('Refreshed bookings'),
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 14),
                        _OnlineBookingSearchFiltersBar(
                          controller: _search,
                          doctors: _data.doctors,
                          selectedDoctor: _doctor,
                          onDoctor: (v) => setState(() => _doctor = v),
                          statuses: _data.statuses,
                          selectedStatus: _status,
                          onStatus: (v) => setState(() => _status = v),
                          paymentStatuses: _data.paymentStatuses,
                          selectedPayStatus: _payStatus,
                          onPayStatus: (v) => setState(() => _payStatus = v),
                          dateLabel: _fmtDate(_date),
                          onPickDate: _pickDate,
                        ),
                        const SizedBox(height: 12),
                        _ActionButtonsRow(
                          showInactive: _showInactive,
                          onRefresh: () => _snack('Refreshed bookings'),
                          onExport: () => _snack('Export CSV started'),
                          onInactive: () =>
                              setState(() => _showInactive = !_showInactive),
                        ),
                        const SizedBox(height: 14),
                        _OnlineBookingStatsGrid(metrics: metrics),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(14, 18, 14, 8),
                          child: Row(
                            children: [
                              Text(
                                'Online Bookings',
                                style: portalText(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: OpColors.heading,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: OpColors.primaryTint,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.calendar_month_rounded,
                                      size: 12,
                                      color: OpColors.primary,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${bookings.length} Online',
                                      style: portalText(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                        color: OpColors.primary,
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
                  if (bookings.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Text(
                          _showInactive
                              ? 'No inactive bookings'
                              : 'No online bookings found',
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
                      padding: const EdgeInsets.fromLTRB(14, 0, 14, 28),
                      sliver: SliverList.separated(
                        itemCount: bookings.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (context, i) => _BookingCard(
                          booking: bookings[i],
                          onActiveChanged: (v) =>
                              _toggleActive(bookings[i], v),
                          onSnack: _snack,
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


class _OnlineBookingTopBar extends StatelessWidget {
  const _OnlineBookingTopBar({this.onMenuTap});
  final VoidCallback? onMenuTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
        boxShadow: [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onMenuTap,
            child: Container(
              width: 34,
              height: 34,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(11),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
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
              children: [
                Text(
                  'Online Booking',
                  style: portalText(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F172A),
                    height: 1.15,
                  ),
                ),
                Text(
                  'City Health Care Clinic',
                  style: portalText(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),
          const _HeaderIconBox(icon: Icons.notifications_none_rounded, dot: true),
        ],
      ),
    );
  }
}

class _HeaderIconBox extends StatelessWidget {
  const _HeaderIconBox({required this.icon, this.dot = false});
  final IconData icon;
  final bool dot;

  @override
  Widget build(BuildContext context) => Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(11),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Icon(icon, size: 17, color: const Color(0xFF64748B)),
          ),
          if (dot)
            Positioned(
              right: 7,
              top: 7,
              child: Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: const Color(0xFFF43F5E),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.2),
                ),
              ),
            ),
        ],
      );
}


class _OnlineBookingSearchFiltersBar extends StatelessWidget {
  const _OnlineBookingSearchFiltersBar({
    required this.controller,
    required this.doctors,
    required this.selectedDoctor,
    required this.onDoctor,
    required this.statuses,
    required this.selectedStatus,
    required this.onStatus,
    required this.paymentStatuses,
    required this.selectedPayStatus,
    required this.onPayStatus,
    required this.dateLabel,
    required this.onPickDate,
  });

  final TextEditingController controller;
  final List<String> doctors;
  final String selectedDoctor;
  final ValueChanged<String> onDoctor;
  final List<String> statuses;
  final String selectedStatus;
  final ValueChanged<String> onStatus;
  final List<String> paymentStatuses;
  final String selectedPayStatus;
  final ValueChanged<String> onPayStatus;
  final String dateLabel;
  final VoidCallback onPickDate;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                const Icon(
                  Icons.search_rounded,
                  size: 16,
                  color: Color(0xFF94A3B8),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: controller,
                    style: portalText(fontSize: 12, color: OpColors.heading),
                    textAlignVertical: TextAlignVertical.center,
                    decoration: InputDecoration(
                      hintText: 'Search patient, Txn ID, doctor...',
                      hintStyle: portalText(
                        fontSize: 12,
                        color: const Color(0xFF94A3B8),
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(
                  Icons.tune_rounded,
                  size: 18,
                  color: Color(0xFF94A3B8),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 34,
            child: Row(
              children: [
                Expanded(
                  child: _FilterChipDropdown(
                    label: selectedPayStatus,
                    items: paymentStatuses,
                    onSelected: onPayStatus,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _FilterChipDropdown(
                    label: selectedDoctor,
                    items: doctors,
                    onSelected: onDoctor,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _FilterChipDropdown(
                    label: selectedStatus,
                    items: statuses,
                    onSelected: onStatus,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: GestureDetector(
                    onTap: onPickDate,
                    child: Container(
                      height: 34,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              dateLabel,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: portalText(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF475569),
                              ),
                            ),
                          ),
                          const SizedBox(width: 2),
                          const Icon(
                            Icons.calendar_today_outlined,
                            size: 13,
                            color: Color(0xFF64748B),
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

class _FilterChipDropdown extends StatelessWidget {
  const _FilterChipDropdown({
    required this.label,
    required this.items,
    required this.onSelected,
  });

  final String label;
  final List<String> items;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: onSelected,
      offset: const Offset(0, 36),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      itemBuilder: (_) => [
        for (final item in items)
          PopupMenuItem(
            value: item,
            child: Text(
              item,
              style: portalText(
                fontSize: 13,
                fontWeight: item == label ? FontWeight.w700 : FontWeight.w500,
                color: OpColors.heading,
              ),
            ),
          ),
      ],
      child: Container(
        height: 34,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: portalText(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF475569),
                ),
              ),
            ),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 16,
              color: Color(0xFF64748B),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButtonsRow extends StatelessWidget {
  const _ActionButtonsRow({
    required this.showInactive,
    required this.onRefresh,
    required this.onExport,
    required this.onInactive,
  });

  final bool showInactive;
  final VoidCallback onRefresh;
  final VoidCallback onExport;
  final VoidCallback onInactive;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          Expanded(
            child: _ActionBtn(
              icon: Icons.refresh_rounded,
              label: 'Refresh',
              color: const Color(0xFF334155),
              bg: Colors.white,
              border: const Color(0xFFE2E8F0),
              onTap: onRefresh,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _ActionBtn(
              icon: Icons.download_rounded,
              label: 'Export CSV',
              color: const Color(0xFF047857),
              bg: const Color(0xFFECFDF5),
              border: const Color(0xFFBBF7D0),
              onTap: onExport,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _ActionBtn(
              icon: Icons.person_off_outlined,
              label: 'Inactive',
              color: showInactive
                  ? Colors.white
                  : const Color(0xFFDC2626),
              bg: showInactive
                  ? const Color(0xFFDC2626)
                  : const Color(0xFFFEF2F2),
              border: const Color(0xFFFECACA),
              onTap: onInactive,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  const _ActionBtn({
    required this.icon,
    required this.label,
    required this.color,
    required this.bg,
    required this.border,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final Color bg;
  final Color border;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          height: 34,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 5),
              Text(
                label,
                style: portalText(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class _OnlineBookingStatsGrid extends StatelessWidget {
  const _OnlineBookingStatsGrid({required this.metrics});

  final List<OpOnlineBookingMetricUi> metrics;

  @override
  Widget build(BuildContext context) {
    if (metrics.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: LayoutBuilder(
        builder: (context, constraints) {
          const gap = 8.0;
          final cardWidth = (constraints.maxWidth - gap * 2) / 3;
          return SizedBox(
            height: 78,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: metrics.length,
              separatorBuilder: (_, _) => const SizedBox(width: gap),
              itemBuilder: (_, i) {
                final m = metrics[i];
                return _DoctorStyleStatCard(
                  width: cardWidth,
                  title: m.title,
                  value: m.value,
                  subtitle: m.subtitle,
                  valueColor: m.accent,
                  icon: m.icon,
                  iconColor: m.accent,
                  iconBg: m.tint,
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _DoctorStyleStatCard extends StatelessWidget {
  const _DoctorStyleStatCard({
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
                  style: portalText(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: OpColors.muted,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: portalText(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: valueColor,
                    height: 1.05,
                  ),
                ),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: portalText(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w500,
                    color: OpColors.muted,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 15, color: iconColor),
          ),
        ],
      ),
    );
  }
}


class _BookingCard extends StatelessWidget {
  const _BookingCard({
    required this.booking,
    required this.onActiveChanged,
    required this.onSnack,
  });

  final OpOnlineBookingUi booking;
  final ValueChanged<bool> onActiveChanged;
  final ValueChanged<String> onSnack;

  void _copy(BuildContext context, String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$label copied',
          style: portalText(
            fontSize: 13,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final b = booking;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: OpColors.border),
        boxShadow: [
          BoxShadow(
            color: OpColors.primary.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: OpColors.primaryTint,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  b.initials,
                  style: portalText(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: OpColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      b.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: portalText(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: OpColors.heading,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${b.age}y ${b.gender}  •  ${b.phone}',
                      style: portalText(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => _copy(context, b.phone, 'Phone'),
                child: Container(
                  width: 32,
                  height: 32,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: OpColors.blueTint,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: const Icon(
                    Icons.phone_rounded,
                    size: 15,
                    color: OpColors.blue,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          const Divider(height: 1, color: Color(0xFFEEF0F7)),
          const SizedBox(height: 9),
          Row(
            children: [
              const Icon(
                Icons.medical_services_outlined,
                size: 14,
                color: Color(0xFF64748B),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  b.doctorLine,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: portalText(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF334155),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 5,
            runSpacing: 5,
            children: [
              for (final s in b.services)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF2FF),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    s.label,
                    style: portalText(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF4338CA),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(
                Icons.access_time_rounded,
                size: 13,
                color: Color(0xFF475569),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  b.timeRange,
                  style: portalText(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: OpColors.heading,
                  ),
                ),
              ),
              _StatusPill(
                text: b.status.toUpperCase(),
                color: const Color(0xFF059669),
                bg: const Color(0xFFECFDF5),
                border: const Color(0xFFA7F3D0),
              ),
              const SizedBox(width: 5),
              _StatusPill(
                text: b.payStatus.toUpperCase(),
                color: const Color(0xFF0D9488),
                bg: const Color(0xFFCCFBF1),
                border: const Color(0xFF99F6E4),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Appt ${b.apptDate}  •  Booked ${b.bookedOn}',
            style: portalText(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.check_circle_rounded,
                size: 14,
                color: Color(0xFF10B981),
              ),
              const SizedBox(width: 4),
              Text(
                b.payType,
                style: portalText(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF059669),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: GestureDetector(
                  onTap: () => _copy(context, b.txnId, 'Txn ID'),
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          b.txnId,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: portalText(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF94A3B8),
                          ),
                        ),
                      ),
                      const SizedBox(width: 3),
                      const Icon(
                        Icons.copy_rounded,
                        size: 11,
                        color: Color(0xFF94A3B8),
                      ),
                    ],
                  ),
                ),
              ),
              Text(
                'Total: ₹${b.total}',
                textAlign: TextAlign.right,
                style: portalText(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: OpColors.heading,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                'Reschedule: ${b.reschedule ? 'Yes' : 'No'}',
                style: portalText(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF64748B),
                ),
              ),
              const Spacer(),
              _CountBadge(
                icon: Icons.description_outlined,
                count: b.reportsCount,
                color: OpColors.blue,
              ),
              const SizedBox(width: 6),
              _CountBadge(
                icon: Icons.medication_outlined,
                count: b.prescriptionsCount,
                color: OpColors.purple,
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 1, color: Color(0xFFEEF0F7)),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                b.active ? 'ACTIVE' : 'INACTIVE',
                style: portalText(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: b.active
                      ? const Color(0xFF059669)
                      : const Color(0xFF94A3B8),
                ),
              ),
              Transform.scale(
                scale: 0.7,
                child: Switch.adaptive(
                  value: b.active,
                  activeThumbColor: Colors.white,
                  activeTrackColor: const Color(0xFF10B981),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  onChanged: onActiveChanged,
                ),
              ),
              const Spacer(),
              _IconAction(
                icon: Icons.visibility_outlined,
                color: const Color(0xFF3B82F6),
                onTap: () => onSnack('View booking'),
              ),
              const SizedBox(width: 5),
              _IconAction(
                icon: Icons.edit_outlined,
                color: const Color(0xFFEA580C),
                onTap: () => onSnack('Edit booking'),
              ),
              const SizedBox(width: 5),
              _IconAction(
                icon: Icons.videocam_rounded,
                color: const Color(0xFF22C55E),
                onTap: () => onSnack('Starting consult for ${b.name}'),
              ),
              const SizedBox(width: 5),
              _RxIconAction(onTap: () => onSnack('Prescription')),
              const SizedBox(width: 5),
              _IconAction(
                icon: Icons.monitor_heart_outlined,
                color: const Color(0xFFEC4899),
                onTap: () => onSnack('Vitals'),
              ),
              const SizedBox(width: 5),
              _IconAction(
                icon: Icons.request_quote_outlined,
                color: const Color(0xFF15803D),
                onTap: () => onSnack('Billing'),
              ),
              const SizedBox(width: 5),
              _IconAction(
                icon: Icons.star_rounded,
                color: const Color(0xFFCBD5E1),
                bg: const Color(0xFFF8FAFC),
                onTap: () => onSnack('Favorite'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CountBadge extends StatelessWidget {
  const _CountBadge({
    required this.icon,
    required this.count,
    required this.color,
  });

  final IconData icon;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 26,
          height: 26,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(7),
          ),
          child: Icon(icon, size: 13, color: color),
        ),
        if (count > 0)
          Positioned(
            right: -3,
            top: -3,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(7),
              ),
              child: Text(
                '$count',
                style: portalText(
                  fontSize: 8,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.text,
    required this.color,
    required this.bg,
    required this.border,
  });

  final String text;
  final Color color;
  final Color bg;
  final Color border;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border),
      ),
      child: Text(
        text,
        style: portalText(
          fontSize: 9,
          fontWeight: FontWeight.w800,
          color: color,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

class _IconAction extends StatelessWidget {
  const _IconAction({
    required this.icon,
    required this.onTap,
    this.color = const Color(0xFF475569),
    this.bg = Colors.white,
  });

  final IconData icon;
  final VoidCallback onTap;
  final Color color;
  final Color bg;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 30,
          height: 30,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Icon(icon, size: 15, color: color),
        ),
      ),
    );
  }
}

class _RxIconAction extends StatelessWidget {
  const _RxIconAction({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 30,
          height: 30,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Text(
            'Rx',
            style: portalText(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF14B8A6),
              height: 1,
            ),
          ),
        ),
      ),
    );
  }
}
