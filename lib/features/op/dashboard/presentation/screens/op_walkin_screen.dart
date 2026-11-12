import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:timelay_health/core/theme/portal_text.dart';
import 'package:timelay_health/core/widgets/portal_safe_area.dart';
import 'package:timelay_health/features/op/dashboard/presentation/models/op_walkin_ui.dart';
import 'package:timelay_health/features/op/dashboard/presentation/screens/op_register_screen.dart';
import 'package:timelay_health/features/op/dashboard/presentation/theme/op_colors.dart';
import 'package:timelay_health/features/op/dashboard/presentation/models/op_dashboard_ui.dart';
import 'package:timelay_health/features/op/dashboard/presentation/widgets/op_amount_items_sheet.dart';
import 'package:timelay_health/features/op/dashboard/presentation/widgets/op_patient_actions_sheet.dart';
import 'package:timelay_health/features/op/dashboard/presentation/widgets/op_top_bar.dart';

class OpWalkinScreen extends StatefulWidget {
  const OpWalkinScreen({super.key, this.onMenuTap});

  final VoidCallback? onMenuTap;

  @override
  State<OpWalkinScreen> createState() => _OpWalkinScreenState();
}

class _OpWalkinScreenState extends State<OpWalkinScreen> {
  final _search = TextEditingController();
  late String _period;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _period = OpWalkinUi.demo.selectedPeriod;
    _search.addListener(() => setState(() => _query = _search.text.trim()));
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _openRegister() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (ctx) => Scaffold(
          backgroundColor: OpColors.background,
          body: PortalSafeArea(
            bottom: false,
            statusBarColor: OpColors.primary,
            child: OpRegisterScreen(
              onMenuTap: () => Navigator.of(ctx).pop(),
            ),
          ),
        ),
      ),
    );
  }

  List<OpWalkinPatientUi> _filtered(OpWalkinUi data) {
    if (_query.isEmpty) return data.patients;
    final q = _query.toLowerCase();
    return data.patients
        .where(
          (p) =>
              p.name.toLowerCase().contains(q) ||
              p.pid.toLowerCase().contains(q) ||
              p.phone.contains(q) ||
              p.doctor.toLowerCase().contains(q),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final data = OpWalkinUi.demo;
    final patients = _filtered(data);

    return ColoredBox(
      color: OpColors.background,
      child: Column(
        children: [
          OpTopBar(title: 'Walkin OP', onMenuTap: widget.onMenuTap),
          Expanded(
            child: RefreshIndicator(
              color: OpColors.primary,
              onRefresh: () async {},
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
                        _SearchAndAdd(
                          controller: _search,
                          onAdd: _openRegister,
                        ),
                        const SizedBox(height: 12),
                        _PeriodChips(
                          filters: data.periodFilters,
                          selected: _period,
                          onSelected: (v) => setState(() => _period = v),
                        ),
                        const SizedBox(height: 12),
                        const _ActionRow(),
                        _WalkinStatsGrid(metrics: data.metrics),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
                          child: Row(
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
                                'Walkin Patients',
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
                                  '${patients.length}',
                                  style: portalText(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: OpColors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (patients.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Text(
                          'No walkin patients found',
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
                        itemCount: patients.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (context, i) =>
                            _WalkinPatientCard(patient: patients[i]),
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

/// Compact stats like home attendance cards; last card full width.
class _WalkinStatsGrid extends StatelessWidget {
  const _WalkinStatsGrid({required this.metrics});

  final List<OpMetricUi> metrics;

  @override
  Widget build(BuildContext context) {
    if (metrics.isEmpty) return const SizedBox.shrink();
    final leading = metrics.length > 1
        ? metrics.sublist(0, metrics.length - 1)
        : const <OpMetricUi>[];
    final last = metrics.last;

    final rows = <Widget>[];
    for (var i = 0; i < leading.length; i += 2) {
      if (i > 0) rows.add(const SizedBox(height: 10));
      final hasSecond = i + 1 < leading.length;
      rows.add(
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: _CompactStatCard(data: leading[i])),
              const SizedBox(width: 10),
              Expanded(
                child: hasSecond
                    ? _CompactStatCard(data: leading[i + 1])
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
      child: Column(
        children: [
          ...rows,
          if (leading.isNotEmpty) const SizedBox(height: 10),
          _CompactStatCard(data: last, wide: true),
        ],
      ),
    );
  }
}

class _CompactStatCard extends StatelessWidget {
  const _CompactStatCard({required this.data, this.wide = false});

  final OpMetricUi data;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: wide ? double.infinity : null,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: OpColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: OpColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: data.accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(data.icon, size: 22, color: data.accent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.title.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: portalText(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: OpColors.muted,
                    letterSpacing: 0.4,
                    height: 12 / 10,
                  ),
                ),
                const SizedBox(height: 4),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: data.value,
                        style: portalText(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: data.accent,
                          height: 24 / 20,
                        ),
                      ),
                      if (data.subtitle.isNotEmpty)
                        TextSpan(
                          text: ' ${data.subtitle}',
                          style: portalText(
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                            color: OpColors.muted,
                            height: 24 / 11,
                          ),
                        ),
                    ],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchAndAdd extends StatelessWidget {
  const _SearchAndAdd({
    required this.controller,
    required this.onAdd,
  });

  final TextEditingController controller;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          Expanded(
            child: Container(
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
                      color: OpColors.primaryTint,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.search_rounded,
                      size: 18,
                      color: OpColors.primary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: controller,
                      decoration: InputDecoration(
                        hintText: 'Search Name, Phone, PID...',
                        hintStyle:
                            portalText(fontSize: 13, color: OpColors.muted),
                        border: InputBorder.none,
                        isDense: true,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          Material(
            color: OpColors.primary,
            borderRadius: BorderRadius.circular(16),
            elevation: 0,
            child: InkWell(
              onTap: onAdd,
              borderRadius: BorderRadius.circular(16),
              child: const SizedBox(
                width: 48,
                height: 48,
                child: Icon(Icons.add_rounded, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PeriodChips extends StatelessWidget {
  const _PeriodChips({
    required this.filters,
    required this.selected,
    required this.onSelected,
  });

  final List<String> filters;
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final f = filters[i];
          final active = f == selected;
          return GestureDetector(
            onTap: () => onSelected(f),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: active ? OpColors.primary : OpColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: active ? OpColors.primary : OpColors.border,
                ),
                boxShadow: active
                    ? [
                        BoxShadow(
                          color: OpColors.primary.withValues(alpha: 0.22),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : null,
              ),
              child: Text(
                f,
                style: portalText(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: active ? Colors.white : OpColors.secondary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          Expanded(
            child: _PillButton(
              label: 'Export CSV',
              icon: Icons.file_download_outlined,
              fg: OpColors.green,
              bg: OpColors.greenTint,
              border: OpColors.green.withValues(alpha: 0.35),
              onTap: () {},
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _PillButton(
              label: 'Inactive',
              icon: Icons.person_off_outlined,
              fg: OpColors.orange,
              bg: OpColors.orangeTint,
              border: OpColors.orange.withValues(alpha: 0.35),
              onTap: () {},
            ),
          ),
        ],
      ),
    );
  }
}

class _PillButton extends StatelessWidget {
  const _PillButton({
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
          height: 42,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: border),
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: fg),
              const SizedBox(width: 6),
              Text(
                label,
                style: portalText(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: fg,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WalkinPatientCard extends StatelessWidget {
  const _WalkinPatientCard({required this.patient});

  final OpWalkinPatientUi patient;

  void _copyPhone(BuildContext context) {
    Clipboard.setData(ClipboardData(text: patient.phone));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Phone copied',
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
    final p = patient;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: OpColors.border),
        boxShadow: [
          BoxShadow(
            color: OpColors.primary.withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: OpColors.primaryTint,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  p.initial,
                  style: portalText(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: OpColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: portalText(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: OpColors.heading,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${p.age} yrs · ${p.gender}',
                      style: portalText(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: OpColors.muted,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.phone_rounded,
                          size: 13,
                          color: OpColors.muted,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          p.phone,
                          style: portalText(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: OpColors.secondary,
                          ),
                        ),
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: () => _copyPhone(context),
                          child: Text(
                            'Copy',
                            style: portalText(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: OpColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: p.payStatusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  p.payStatus,
                  style: portalText(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: p.payStatusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Meta chips
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _Chip(text: p.rType, color: OpColors.primary),
              _Chip(text: p.status, color: OpColors.blue),
              _Chip(text: p.payType, color: OpColors.purple),
            ],
          ),
          const SizedBox(height: 12),
          // Doctor + time
          Row(
            children: [
              const Icon(
                Icons.medical_services_outlined,
                size: 15,
                color: OpColors.muted,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  p.doctor,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: portalText(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: OpColors.heading,
                  ),
                ),
              ),
              Text(
                '${p.createdDate}  ${p.createdTime}',
                style: portalText(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: OpColors.muted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Payment summary — focus on paid amount
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F6FC),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Paid',
                            style: portalText(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: OpColors.muted,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            p.paid,
                            style: portalText(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: OpColors.green,
                              height: 1.1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _KV(label: 'Total', value: p.total),
                        const SizedBox(height: 4),
                        _KV(label: 'Due', value: p.due),
                        const SizedBox(height: 4),
                        _KV(label: 'Disc', value: p.discount),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Divider(height: 1, color: OpColors.border),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _Split(
                      label: 'Clinic',
                      value: p.clinic,
                      color: OpColors.blue,
                      onAdd: () => showOpAmountItemsSheet(
                        context: context,
                        patient: p,
                        kind: OpAmountItemKind.clinic,
                      ),
                    ),
                    _Split(
                      label: 'Lab',
                      value: p.lab,
                      color: OpColors.purple,
                      onAdd: () => showOpAmountItemsSheet(
                        context: context,
                        patient: p,
                        kind: OpAmountItemKind.lab,
                      ),
                    ),
                    _Split(
                      label: 'Pharmacy',
                      value: p.pharmacy,
                      color: OpColors.green,
                      onAdd: () => showOpAmountItemsSheet(
                        context: context,
                        patient: p,
                        kind: OpAmountItemKind.pharmacy,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          // Booked / referred
          Text(
            'Booked by ${p.bookedBy}  ·  ${p.referredCustomer}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: portalText(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: OpColors.muted,
            ),
          ),
          const SizedBox(height: 12),
          // Actions
          Row(
            children: [
              Expanded(
                child: _Btn(
                  icon: Icons.print_rounded,
                  label: 'Bill',
                  color: OpColors.green,
                  bg: OpColors.greenTint,
                  onTap: () {},
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _Btn(
                  icon: Icons.monitor_heart_outlined,
                  label: 'Vitals',
                  color: OpColors.pink,
                  bg: OpColors.pinkTint,
                  onTap: () {},
                ),
              ),
              const SizedBox(width: 8),
              Material(
                color: OpColors.primaryTint,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  onTap: () => showOpPatientActionsSheet(
                    context: context,
                    patient: p,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  child: const SizedBox(
                    width: 42,
                    height: 40,
                    child: Icon(
                      Icons.more_horiz_rounded,
                      color: OpColors.primary,
                      size: 20,
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
}

class _Chip extends StatelessWidget {
  const _Chip({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: portalText(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
    );
  }
}

class _KV extends StatelessWidget {
  const _KV({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$label  ',
          style: portalText(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: OpColors.muted,
          ),
        ),
        Text(
          value,
          style: portalText(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: OpColors.heading,
          ),
        ),
      ],
    );
  }
}

class _Split extends StatelessWidget {
  const _Split({
    required this.label,
    required this.value,
    required this.color,
    required this.onAdd,
  });

  final String label;
  final String value;
  final Color color;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: portalText(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: OpColors.muted,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: portalText(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              GestureDetector(
                onTap: onAdd,
                child: Container(
                  width: 20,
                  height: 20,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(Icons.add_rounded, size: 14, color: color),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Btn extends StatelessWidget {
  const _Btn({
    required this.icon,
    required this.label,
    required this.color,
    required this.bg,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
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
        child: SizedBox(
          height: 40,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: portalText(
                  fontSize: 12,
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
