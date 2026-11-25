import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:timelay_health/core/theme/portal_text.dart';
import 'package:timelay_health/features/op/services/presentation/models/op_services_ui.dart';
import 'package:timelay_health/features/op/dashboard/presentation/theme/op_colors.dart';
import 'package:timelay_health/features/op/shared/widgets/op_top_bar.dart';

class OpServicesScreen extends StatefulWidget {
  const OpServicesScreen({super.key, this.onMenuTap});

  final VoidCallback? onMenuTap;

  @override
  State<OpServicesScreen> createState() => _OpServicesScreenState();
}

class _OpServicesScreenState extends State<OpServicesScreen> {
  final _search = TextEditingController();
  late List<OpServiceUi> _services;
  String _query = '';
  String _sort = 'Default';

  @override
  void initState() {
    super.initState();
    _services = List.of(OpServicesUi.demo.services);
    _search.addListener(() => setState(() => _query = _search.text.trim()));
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<OpServiceUi> get _filtered {
    var list = _services.where((s) {
      if (_query.isEmpty) return true;
      final q = _query.toLowerCase();
      return s.name.toLowerCase().contains(q) ||
          s.price.toString().contains(q) ||
          s.description.toLowerCase().contains(q) ||
          s.category.toLowerCase().contains(q);
    }).toList();

    switch (_sort) {
      case 'Name A-Z':
        list.sort((a, b) => a.name.compareTo(b.name));
      case 'Name Z-A':
        list.sort((a, b) => b.name.compareTo(a.name));
      case 'Price Low-High':
        list.sort((a, b) => a.price.compareTo(b.price));
      case 'Price High-Low':
        list.sort((a, b) => b.price.compareTo(a.price));
      default:
        break;
    }
    return list;
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
    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    setState(() {
      _services = List.of(OpServicesUi.demo.services);
    });
    _snack('Services refreshed');
  }

  void _exportCsv() {
    final rows = _filtered;
    if (rows.isEmpty) {
      _snack('No records to export');
      return;
    }
    final buf = StringBuffer('S.No,Service,Price,Description,Created\n');
    for (var i = 0; i < rows.length; i++) {
      final s = rows[i];
      buf.writeln(
        '${i + 1},"${s.name}",${s.price},"${s.descriptionLabel}","${s.createdAt}"',
      );
    }
    Clipboard.setData(ClipboardData(text: buf.toString()));
    _snack('CSV copied (${rows.length} records)');
  }

  Future<void> _openForm([OpServiceUi? existing]) async {
    final result = await showModalBottomSheet<OpServiceUi>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ServiceFormSheet(existing: existing),
    );
    if (result == null) return;
    setState(() {
      final i = _services.indexWhere((e) => e.id == result.id);
      if (i >= 0) {
        _services[i] = result;
      } else {
        _services.insert(0, result);
      }
    });
    _snack(existing == null ? 'Service added' : 'Service updated');
  }

  Future<void> _view(OpServiceUi service) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _ServiceDetailSheet(
        service: service,
        onEdit: () {
          Navigator.pop(context);
          _openForm(service);
        },
      ),
    );
  }

  Future<void> _delete(OpServiceUi service) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          'Delete Service',
          style: portalText(fontSize: 17, fontWeight: FontWeight.w800),
        ),
        content: Text(
          'Remove ${service.name}?',
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
    setState(() => _services.removeWhere((e) => e.id == service.id));
    _snack('Service deleted');
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    final prices = _services.map((e) => e.price).toList();
    final avg = prices.isEmpty
        ? 0
        : (prices.reduce((a, b) => a + b) / prices.length).round();
    final min = prices.isEmpty ? 0 : prices.reduce((a, b) => a < b ? a : b);
    final max = prices.isEmpty ? 0 : prices.reduce((a, b) => a > b ? a : b);

    return ColoredBox(
      color: OpColors.background,
      child: Column(
        children: [
          OpTopBar(title: 'Service Management', onMenuTap: widget.onMenuTap),
          Expanded(
            child: RefreshIndicator(
              color: OpColors.primary,
              onRefresh: _refresh,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _HeroBanner(count: _services.length),
                          const SizedBox(height: 14),
                          _SearchField(controller: _search),
                          const SizedBox(height: 12),
                          _ActionRow(
                            sort: _sort,
                            onSort: (v) => setState(() => _sort = v),
                            onExport: _exportCsv,
                            onAdd: () => _openForm(),
                          ),
                          const SizedBox(height: 14),
                          _StatsGrid(
                            total: _services.length,
                            avg: avg,
                            min: min,
                            max: max,
                            filtered: filtered.length,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Container(
                                width: 4,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF26204A),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Clinical Services',
                                style: portalText(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF0F172A),
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEEEDF0),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${filtered.length}',
                                  style: portalText(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF26204A),
                                  ),
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
                      child: Center(
                        child: Text(
                          'No services found',
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
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                      sliver: SliverList.separated(
                        itemCount: filtered.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (context, i) {
                          final service = filtered[i];
                          return _ServiceCard(
                            service: service,
                            onView: () => _view(service),
                            onEdit: () => _openForm(service),
                            onDelete: () => _delete(service),
                          );
                        },
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

class _HeroBanner extends StatelessWidget {
  const _HeroBanner({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment(-0.8, -1),
          end: Alignment(1, 1),
          colors: OpColors.heroGradient,
        ),
        boxShadow: [
          BoxShadow(
            color: OpColors.primary.withValues(alpha: 0.22),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SERVICE CATALOG',
                  style: portalText(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Colors.white.withValues(alpha: 0.85),
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Clinical Services',
                  style: portalText(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Manage pricing & service items',
                  style: portalText(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
            ),
            child: Row(
              children: [
                const Icon(Icons.work_outline_rounded,
                    size: 16, color: Colors.white),
                const SizedBox(width: 6),
                Text(
                  '$count Services',
                  style: portalText(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
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
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          const Icon(
            Icons.search_rounded,
            size: 18,
            color: Color(0xFF94A3B8),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              style: portalText(
                fontSize: 12.5,
                color: const Color(0xFF0F172A),
              ),
              decoration: InputDecoration(
                hintText: 'Search service name, price, description...',
                hintStyle: portalText(
                  fontSize: 12.5,
                  color: const Color(0xFF94A3B8),
                ),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.sort,
    required this.onSort,
    required this.onExport,
    required this.onAdd,
  });

  final String sort;
  final ValueChanged<String> onSort;
  final VoidCallback onExport;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x06000000),
                  blurRadius: 4,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.swap_vert_rounded,
                  size: 16,
                  color: Color(0xFF64748B),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: sort,
                      icon: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 17,
                        color: Color(0xFF64748B),
                      ),
                      style: portalText(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF0F172A),
                      ),
                      items: const [
                        'Default',
                        'Name A-Z',
                        'Name Z-A',
                        'Price Low-High',
                        'Price High-Low',
                      ]
                          .map(
                            (e) => DropdownMenuItem(
                              value: e,
                              child: Text(
                                e == 'Default' ? 'Sort: Default' : e,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (v) {
                        if (v != null) onSort(v);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        _Pill(
          label: 'CSV',
          icon: Icons.file_download_outlined,
          fg: const Color(0xFF059669),
          bg: const Color(0xFFECFDF5),
          borderColor: const Color(0xFFA7F3D0),
          onTap: onExport,
        ),
        const SizedBox(width: 8),
        _Pill(
          label: 'Add Service',
          icon: Icons.add_rounded,
          fg: Colors.white,
          bg: const Color(0xFF26204A),
          hasShadow: true,
          onTap: onAdd,
        ),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.label,
    required this.icon,
    required this.fg,
    required this.bg,
    this.borderColor,
    this.hasShadow = false,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color fg;
  final Color bg;
  final Color? borderColor;
  final bool hasShadow;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(10),
          border: borderColor != null ? Border.all(color: borderColor!) : null,
          boxShadow: hasShadow
              ? const [
                  BoxShadow(
                    color: Color(0x3326204A),
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: fg),
            const SizedBox(width: 5),
            Text(
              label,
              style: portalText(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: fg,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({
    required this.total,
    required this.avg,
    required this.min,
    required this.max,
    required this.filtered,
  });

  final int total;
  final int avg;
  final int min;
  final int max;
  final int filtered;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final cardWidth = ((width - 36 - 16) / 3).clamp(100.0, 140.0);

    final items = [
      _StatCard(
        width: cardWidth,
        title: 'Total',
        value: '$total',
        subtitle: 'services',
        valueColor: OpColors.heading,
        icon: Icons.layers_rounded,
        iconColor: OpColors.blue,
        iconBg: OpColors.blueTint,
      ),
      _StatCard(
        width: cardWidth,
        title: 'Avg Fee',
        value: '₹$avg',
        subtitle: 'average',
        valueColor: OpColors.green,
        icon: Icons.currency_rupee_rounded,
        iconColor: OpColors.green,
        iconBg: OpColors.greenTint,
      ),
      _StatCard(
        width: cardWidth,
        title: 'Min Fee',
        value: '₹$min',
        subtitle: 'lowest',
        valueColor: OpColors.cyan,
        icon: Icons.trending_down_rounded,
        iconColor: OpColors.cyan,
        iconBg: const Color(0xFFE0F7FA),
      ),
      _StatCard(
        width: cardWidth,
        title: 'Max Fee',
        value: '₹$max',
        subtitle: 'highest',
        valueColor: OpColors.orange,
        icon: Icons.trending_up_rounded,
        iconColor: OpColors.orange,
        iconBg: OpColors.orangeTint,
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
        physics: const BouncingScrollPhysics(),
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

class _ServiceCard extends StatelessWidget {
  const _ServiceCard({
    required this.service,
    required this.onView,
    required this.onEdit,
    required this.onDelete,
  });

  final OpServiceUi service;
  final VoidCallback onView;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onView,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF1F5F9)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 10,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0xFF26204A),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    service.initial,
                    style: portalText(
                      fontSize: 17,
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
                        service.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: portalText(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(
                            Icons.category_outlined,
                            size: 12,
                            color: Color(0xFFB45309),
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              service.category,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: portalText(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF64748B),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4.5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFFD1FAE5),
                      width: 0.8,
                    ),
                  ),
                  child: Text(
                    service.priceLabel,
                    style: portalText(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF059669),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFF1F5F9)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.description_outlined,
                    size: 14,
                    color: Color(0xFF94A3B8),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      service.descriptionLabel,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: portalText(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF64748B),
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            const Divider(
              height: 1,
              thickness: 1,
              color: Color(0xFFF1F5F9),
            ),
            const SizedBox(height: 10),

            Row(
              children: [
                Flexible(
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: 'Created: ',
                          style: portalText(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF94A3B8),
                          ),
                        ),
                        TextSpan(
                          text: service.createdAt,
                          style: portalText(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF334155),
                          ),
                        ),
                      ],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                const Spacer(),
                GestureDetector(
                  onTap: onView,
                  behavior: HitTestBehavior.opaque,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    child: Icon(
                      Icons.visibility_outlined,
                      size: 18,
                      color: Color(0xFF3B82F6),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: onEdit,
                  behavior: HitTestBehavior.opaque,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    child: Icon(
                      Icons.edit_outlined,
                      size: 18,
                      color: Color(0xFFF59E0B),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: onDelete,
                  behavior: HitTestBehavior.opaque,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    child: Icon(
                      Icons.delete_outline_rounded,
                      size: 18,
                      color: Color(0xFFEF4444),
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

class _ServiceFormSheet extends StatefulWidget {
  const _ServiceFormSheet({this.existing});

  final OpServiceUi? existing;

  @override
  State<_ServiceFormSheet> createState() => _ServiceFormSheetState();
}

class _ServiceFormSheetState extends State<_ServiceFormSheet> {
  late final TextEditingController _name;
  late final TextEditingController _price;
  late final TextEditingController _description;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _name = TextEditingController(text: e?.name ?? '');
    _price = TextEditingController(text: e == null ? '' : '${e.price}');
    _description = TextEditingController(text: e?.description ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    _price.dispose();
    _description.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _name.text.trim();
    if (name.isEmpty) return;
    final service = OpServiceUi(
      id: widget.existing?.id ?? 's${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      price: int.tryParse(_price.text.trim()) ?? 0,
      description: _description.text.trim(),
      createdAt: widget.existing?.createdAt ?? '10 Nov 2026',
      avatarColor: widget.existing?.avatarColor ?? OpColors.blue,
    );
    Navigator.pop(context, service);
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: OpColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                color: OpColors.border,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Text(
                  widget.existing == null ? 'Add Service' : 'Edit Service',
                  style: portalText(fontSize: 17, fontWeight: FontWeight.w800),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            _field('Service Name', _name, Icons.medical_services_outlined),
            _field(
              'Price (₹)',
              _price,
              Icons.currency_rupee_rounded,
              keyboard: TextInputType.number,
            ),
            _field(
              'Description',
              _description,
              Icons.notes_rounded,
              maxLines: 3,
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: OpColors.blue,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  widget.existing == null ? 'Save Service' : 'Update Service',
                  style: portalText(
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(
    String label,
    TextEditingController controller,
    IconData icon, {
    TextInputType? keyboard,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: portalText(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: OpColors.muted,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            keyboardType: keyboard,
            maxLines: maxLines,
            decoration: InputDecoration(
              prefixIcon: Icon(icon, size: 18, color: OpColors.muted),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: OpColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: OpColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: OpColors.blue, width: 1.4),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ServiceDetailSheet extends StatelessWidget {
  const _ServiceDetailSheet({
    required this.service,
    required this.onEdit,
  });

  final OpServiceUi service;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 80),
      decoration: const BoxDecoration(
        color: OpColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 42,
            height: 4,
            decoration: BoxDecoration(
              color: OpColors.border,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 18),
          Container(
            width: 64,
            height: 64,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  service.avatarColor,
                  service.avatarColor.withValues(alpha: 0.7),
                ],
              ),
            ),
            child: Text(
              service.initial,
              style: portalText(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            service.name,
            textAlign: TextAlign.center,
            style: portalText(fontSize: 17, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            service.category,
            style: portalText(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: OpColors.blue,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: OpColors.greenTint,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              service.priceLabel,
              style: portalText(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: OpColors.green,
              ),
            ),
          ),
          const SizedBox(height: 16),
          _row('Description', service.descriptionLabel),
          _row('Created', service.createdAt),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton(
              onPressed: onEdit,
              style: ElevatedButton.styleFrom(
                backgroundColor: OpColors.blue,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                'Edit Service',
                style: portalText(
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
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
