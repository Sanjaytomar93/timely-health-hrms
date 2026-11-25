import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:timelay_health/core/theme/portal_text.dart';
import 'package:timelay_health/features/op/dashboard/presentation/models/op_dashboard_ui.dart';
import 'package:timelay_health/features/op/dashboard/presentation/theme/op_colors.dart';

class OpStickyHeader extends StatelessWidget {
  const OpStickyHeader({super.key, this.onMenuTap});

  final VoidCallback? onMenuTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.97),
        border: const Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 12,
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
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(11),
                border: Border.all(color: const Color(0xFFE2E8F0)),
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
              children: [
                Text(
                  'OP Dashboard',
                  style: portalText(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F172A),
                    height: 1.15,
                  ),
                ),
                Text(
                  'Healthcare Outpatient',
                  style: portalText(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(11),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Icon(
                  Icons.notifications_none_rounded,
                  size: 17,
                  color: Color(0xFF64748B),
                ),
                Positioned(
                  top: 7,
                  right: 8,
                  child: Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF43F5E),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
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

class OpSearchFiltersBar extends StatelessWidget {
  const OpSearchFiltersBar({
    super.key,
    required this.searchController,
    required this.filters,
    required this.selectedPeriod,
    required this.onPeriodSelected,
  });

  final TextEditingController searchController;
  final List<String> filters;
  final String selectedPeriod;
  final ValueChanged<String> onPeriodSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
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
              const Icon(Icons.search_rounded, size: 16, color: Color(0xFF94A3B8)),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: searchController,
                  style: portalText(fontSize: 12, color: OpColors.heading),
                  decoration: InputDecoration(
                    hintText: 'Search patients, doctors, MRN...',
                    hintStyle: portalText(
                      fontSize: 12,
                      color: const Color(0xFF94A3B8),
                    ),
                    border: InputBorder.none,
                    isDense: true,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        OpPeriodFiltersRow(
          filters: filters,
          selected: selectedPeriod,
          onSelected: onPeriodSelected,
        ),
      ],
    );
  }
}

class OpPeriodFiltersRow extends StatelessWidget {
  const OpPeriodFiltersRow({
    super.key,
    required this.filters,
    required this.selected,
    required this.onSelected,
  });

  final List<String> filters;
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth = (constraints.maxWidth - (3 * 6)) / 4;

        return SizedBox(
          height: 32,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                for (var i = 0; i < filters.length; i++) ...[
                  if (i > 0) const SizedBox(width: 6),
                  GestureDetector(
                    onTap: () => onSelected(filters[i]),
                    child: Container(
                      width: itemWidth,
                      height: 32,
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: filters[i] == selected
                            ? const Color(0xFF26204A)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: filters[i] == selected
                              ? const Color(0xFF26204A)
                              : const Color(0xFFE2E8F0),
                        ),
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          filters[i],
                          maxLines: 1,
                          style: portalText(
                            fontSize: 12,
                            fontWeight: filters[i] == selected
                                ? FontWeight.w800
                                : FontWeight.w500,
                            color: filters[i] == selected
                                ? Colors.white
                                : const Color(0xFF475569),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class OpRegisterBanner extends StatelessWidget {
  const OpRegisterBanner({super.key, required this.onTap});

  final VoidCallback onTap;

  static const _radius = 16.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(_radius),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF26204A).withValues(alpha: 0.35),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(_radius),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(_radius),
          child: Ink(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF26204A),
                  Color(0xFF332B63),
                  Color(0xFF26204A),
                ],
              ),
              borderRadius: BorderRadius.circular(_radius),
              border: Border.all(color: const Color(0x993E3577)),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                  ),
                  child: const Icon(
                    Icons.add_rounded,
                    color: Color(0xFF34D399),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              'Register New Patient',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: portalText(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0x3334D399),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(0x4D34D399),
                              ),
                            ),
                            child: Text(
                              'Fast OP',
                              style: portalText(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF6EE7B7),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'Quick intake, MRN creation & fee collection',
                        style: portalText(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xCCDDD6FE),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '+ New OP',
                        style: portalText(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF26204A),
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right_rounded,
                        size: 14,
                        color: Color(0xFF26204A),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class OpQuickActionsRow extends StatelessWidget {
  const OpQuickActionsRow({super.key, required this.actions, this.onTap});

  final List<OpQuickActionUi> actions;
  final ValueChanged<OpQuickActionUi>? onTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth = (constraints.maxWidth - (3 * 8)) / 4;

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              for (var i = 0; i < actions.length; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                GestureDetector(
                  onTap: onTap == null ? null : () => onTap!(actions[i]),
                  child: Container(
                    width: itemWidth,
                    padding: const EdgeInsets.fromLTRB(4, 10, 4, 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE9E7F2)),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x0C0F172A),
                          blurRadius: 10,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: actions[i].tint,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: actions[i].accent.withValues(alpha: 0.18),
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Icon(
                            actions[i].icon,
                            size: 16,
                            color: actions[i].accent,
                          ),
                        ),
                        const SizedBox(height: 8),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            actions[i].label,
                            maxLines: 1,
                            textAlign: TextAlign.center,
                            style: portalText(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF1E293B),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class OpTotalCollectedCard extends StatefulWidget {
  const OpTotalCollectedCard({super.key, required this.data});

  final OpCollectedUi data;

  @override
  State<OpTotalCollectedCard> createState() => _OpTotalCollectedCardState();
}

class _OpTotalCollectedCardState extends State<OpTotalCollectedCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _blink;

  @override
  void initState() {
    super.initState();
    _blink = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _blink.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.data;
    return Container(
      padding: const EdgeInsets.fromLTRB(13, 12, 13, 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF26204A), Color(0xFF1F1A3D), Color(0xFF141129)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x993B326D)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF26204A).withValues(alpha: 0.35),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: const Color(0x3334D399),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0x4D34D399)),
                ),
                alignment: Alignment.center,
                child: Text(
                  '₹',
                  style: portalText(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF34D399),
                  ),
                ),
              ),
              const SizedBox(width: 7),
              Text(
                'TOTAL COLLECTED',
                style: portalText(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFFDDD6FE),
                  letterSpacing: 0.5,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0x1A34D399),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0x4034D399)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FadeTransition(
                      opacity: Tween<double>(begin: 0.25, end: 1).animate(
                        CurvedAnimation(parent: _blink, curve: Curves.easeInOut),
                      ),
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Color(0xFF34D399),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Color(0x8034D399),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'Live',
                      style: portalText(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF6EE7B7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          Container(height: 1, color: Colors.white.withValues(alpha: 0.1)),
          const SizedBox(height: 9),
          Text(
            data.amount,
            style: portalText(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              height: 1,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              for (var i = 0; i < data.breakdown.length; i++) ...[
                if (i > 0) const SizedBox(width: 6),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(9),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data.breakdown[i].label,
                          style: portalText(
                            fontSize: 9,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xB3DDD6FE),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          data.breakdown[i].value,
                          style: portalText(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: data.breakdown[i].color,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class OpMetricsGrid extends StatelessWidget {
  const OpMetricsGrid({
    super.key,
    required this.metrics,
    required this.dueInvoices,
  });

  final List<OpMetricUi> metrics;
  final OpDueInvoiceUi dueInvoices;

  @override
  Widget build(BuildContext context) {
    final cards = metrics.take(4).toList();
    return Column(
      children: [
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: _StatCard(data: cards[0])),
              const SizedBox(width: 8),
              Expanded(child: _StatCard(data: cards[1])),
            ],
          ),
        ),
        const SizedBox(height: 8),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: _StatCard(data: cards[2])),
              const SizedBox(width: 8),
              Expanded(child: _StatCard(data: cards[3])),
            ],
          ),
        ),
        const SizedBox(height: 8),
        _DueInvoicesBanner(data: dueInvoices),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.data});

  final OpMetricUi data;

  List<InlineSpan> get _valueSpans {
    final valueStyle = portalText(
      fontSize: 16,
      fontWeight: FontWeight.w700,
      color: data.accent,
      height: 1.15,
    );
    final mutedStyle = portalText(
      fontSize: 10,
      fontWeight: FontWeight.w500,
      color: const Color(0xFF7C7A91),
      height: 1.15,
    );

    if (data.activeLabel != null) {
      return [
        TextSpan(text: data.value, style: valueStyle),
        TextSpan(text: ' ', style: mutedStyle),
        TextSpan(
          text: data.activeLabel!,
          style: portalText(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF059669),
            height: 1.15,
          ),
        ),
        if (data.inactiveLabel != null) ...[
          TextSpan(text: ' · ', style: mutedStyle),
          TextSpan(
            text: data.inactiveLabel!,
            style: portalText(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: const Color(0xFFDC2626),
              height: 1.15,
            ),
          ),
        ],
      ];
    }

    return [
      TextSpan(text: data.value, style: valueStyle),
      if (data.subtitle.isNotEmpty)
        TextSpan(text: ' ${data.subtitle}', style: mutedStyle),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE9E7F2)),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: data.accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(data.icon, size: 16, color: data.accent),
          ),
          const SizedBox(width: 7),
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
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF7C7A91),
                    letterSpacing: 0.3,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 3),
                Text.rich(
                  TextSpan(children: _valueSpans),
                  maxLines: 2,
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

class _DueInvoicesBanner extends StatelessWidget {
  const _DueInvoicesBanner({required this.data});

  final OpDueInvoiceUi data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 14, 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xB3FFF1F2), Color(0x66FFF1F2), Colors.white],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFECACA)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A0F172A),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: const Color(0xFFFFE4E6),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.warning_amber_rounded,
              size: 18,
              color: Color(0xFFE11D48),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'DUE INVOICES',
                      style: portalText(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFFE11D48),
                        letterSpacing: 0.4,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF43F5E),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${data.count} overdue',
                        style: portalText(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'Total outstanding amount',
                  style: portalText(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          Text(
            data.amount,
            style: portalText(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: const Color(0xFFE11D48),
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }
}
