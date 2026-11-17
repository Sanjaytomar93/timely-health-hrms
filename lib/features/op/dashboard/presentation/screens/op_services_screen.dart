import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:timelay_health/core/theme/portal_text.dart';
import 'package:timelay_health/features/op/dashboard/presentation/models/op_services_ui.dart';
import 'package:timelay_health/features/op/dashboard/presentation/theme/op_colors.dart';
import 'package:timelay_health/features/op/dashboard/presentation/widgets/op_top_bar.dart';

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
  bool _refreshing = false;

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
    setState(() => _refreshing = true);
    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    setState(() {
      _services = List.of(OpServicesUi.demo.services);
      _refreshing = false;
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
                      padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _HeroBanner(count: _services.length),
                          const SizedBox(height: 12),
                          _SearchField(controller: _search),
                          const SizedBox(height: 10),
                          _ActionRow(
                            sort: _sort,
                            refreshing: _refreshing,
                            onSort: (v) => setState(() => _sort = v),
                            onRefresh: _refresh,
                            onExport: _exportCsv,
                            onAdd: () => _openForm(),
                          ),
                          const SizedBox(height: 12),
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
                                height: 18,
                                decoration: BoxDecoration(
                                  color: OpColors.blue,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Clinical Services',
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
                                  color: OpColors.blueTint,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '${filtered.length}',
                                  style: portalText(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: OpColors.blue,
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
                      padding: const EdgeInsets.fromLTRB(14, 0, 14, 28),
                      sliver: SliverList.separated(
                        itemCount: filtered.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (context, i) {
                          final service = filtered[i];
                          return _ServiceCard(
                            sno: i + 1,
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
            child: const Icon(Icons.search_rounded, size: 18, color: OpColors.blue),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Search service name, price, description...',
                hintStyle: portalText(fontSize: 13, color: OpColors.muted),
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
    required this.refreshing,
    required this.onSort,
    required this.onRefresh,
    required this.onExport,
    required this.onAdd,
  });

  final String sort;
  final bool refreshing;
  final ValueChanged<String> onSort;
  final VoidCallback onRefresh;
  final VoidCallback onExport;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 42,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: OpColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: OpColors.border),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: sort,
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
                          e,
                          style: portalText(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
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
        ),
        const SizedBox(width: 8),
        _IconBtn(
          icon: Icons.refresh_rounded,
          spinning: refreshing,
          onTap: onRefresh,
        ),
        const SizedBox(width: 8),
        _Pill(
          label: 'CSV',
          icon: Icons.file_download_outlined,
          fg: OpColors.green,
          bg: OpColors.greenTint,
          onTap: onExport,
        ),
        const SizedBox(width: 8),
        _Pill(
          label: 'Add',
          icon: Icons.add_rounded,
          fg: Colors.white,
          bg: OpColors.blue,
          onTap: onAdd,
        ),
      ],
    );
  }
}

class _IconBtn extends StatelessWidget {
  const _IconBtn({
    required this.icon,
    required this.onTap,
    this.spinning = false,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool spinning;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: OpColors.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: OpColors.border),
          ),
          alignment: Alignment.center,
          child: spinning
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(icon, size: 18, color: OpColors.secondary),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.label,
    required this.icon,
    required this.fg,
    required this.bg,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color fg;
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
          height: 42,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              Icon(icon, size: 15, color: fg),
              const SizedBox(width: 4),
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
    required this.sno,
    required this.service,
    required this.onView,
    required this.onEdit,
    required this.onDelete,
  });

  final int sno;
  final OpServiceUi service;
  final VoidCallback onView;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: OpColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onView,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: OpColors.border),
            boxShadow: const [
              BoxShadow(
                color: Color(0x08000000),
                blurRadius: 8,
                offset: Offset(0, 3),
              ),
            ],
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
                    width: 42,
                    height: 42,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          service.avatarColor,
                          service.avatarColor.withValues(alpha: 0.7),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: service.avatarColor.withValues(alpha: 0.28),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Text(
                      service.initial,
                      style: portalText(
                        fontSize: 16,
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
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: OpColors.heading,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          service.category,
                          style: portalText(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: OpColors.blue,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: OpColors.greenTint,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      service.priceLabel,
                      style: portalText(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        color: OpColors.green,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                service.descriptionLabel,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: portalText(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: OpColors.muted,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(
                    Icons.event_outlined,
                    size: 14,
                    color: OpColors.muted,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    service.createdAt,
                    style: portalText(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: OpColors.secondary,
                    ),
                  ),
                  const Spacer(),
                  _RoundAction(
                    icon: Icons.visibility_rounded,
                    color: OpColors.blue,
                    bg: OpColors.blueTint,
                    onTap: onView,
                  ),
                  const SizedBox(width: 6),
                  _RoundAction(
                    icon: Icons.edit_rounded,
                    color: OpColors.primary,
                    bg: OpColors.primaryTint,
                    onTap: onEdit,
                  ),
                  const SizedBox(width: 6),
                  _RoundAction(
                    icon: Icons.delete_outline_rounded,
                    color: OpColors.red,
                    bg: OpColors.redTint,
                    onTap: onDelete,
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

class _RoundAction extends StatelessWidget {
  const _RoundAction({
    required this.icon,
    required this.color,
    required this.bg,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final Color bg;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(
          width: 34,
          height: 34,
          child: Icon(icon, size: 16, color: color),
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
