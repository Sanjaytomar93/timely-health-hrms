import 'package:flutter/material.dart';
import 'package:timelay_health/core/routes/app_routes.dart';
import 'package:timelay_health/features/camp/presentation/models/camp_list_ui.dart';
import 'package:timelay_health/features/camp/presentation/theme/camp_colors.dart';

/// Locations top bar — logo + notification only (no AD).
class CampListTopBar extends StatelessWidget {
  const CampListTopBar({super.key});

  static const _logoAsset = 'assets/images/camp_timely_health_logo.png';

  void _goToHrms(BuildContext context) {
    Navigator.of(context).popUntil(
      (route) => route.isFirst || route.settings.name == AppRoutes.home,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      color: CampColors.surface,
      child: Row(
        children: [
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: GestureDetector(
                onTap: () => _goToHrms(context),
                behavior: HitTestBehavior.opaque,
                child: Image.asset(
                  _logoAsset,
                  height: 36,
                  fit: BoxFit.contain,
                  alignment: Alignment.centerLeft,
                  filterQuality: FilterQuality.high,
                ),
              ),
            ),
          ),
          Material(
            color: CampColors.background,
            borderRadius: BorderRadius.circular(10),
            child: InkWell(
              onTap: () => AppRoutes.push(context, AppRoutes.notifications),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: CampColors.border),
                ),
                child: const Icon(
                  Icons.notifications_none_rounded,
                  size: 18,
                  color: CampColors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CampListSearchBar extends StatelessWidget {
  const CampListSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: CampColors.border),
        ),
        child: Row(
          children: [
            const Icon(Icons.search_rounded, size: 20, color: CampColors.muted),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: controller,
                onChanged: onChanged,
                style: const TextStyle(fontSize: 13, color: CampColors.heading),
                decoration: const InputDecoration(
                  isDense: true,
                  border: InputBorder.none,
                  hintText: 'Search camps by name or location',
                  hintStyle: TextStyle(fontSize: 13, color: Color(0xFFBBBAC4)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Horizontal strip — ~3 cards visible, rest via scroll.
class CampListStatStrip extends StatelessWidget {
  const CampListStatStrip({super.key, required this.stats});

  final List<CampListStatUi> stats;

  static const _pad = 16.0;
  static const _gap = 8.0;
  static const _visible = 3;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final usable = constraints.maxWidth - (_pad * 2) - (_gap * (_visible - 1));
        final cardW = usable / _visible;

        return SizedBox(
          height: 96,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(_pad, 6, _pad, 6),
            itemCount: stats.length,
            separatorBuilder: (_, _) => const SizedBox(width: _gap),
            itemBuilder: (context, i) => SizedBox(
              width: cardW,
              child: _StripStatCard(stat: stats[i]),
            ),
          ),
        );
      },
    );
  }
}

class _StripStatCard extends StatelessWidget {
  const _StripStatCard({required this.stat});

  final CampListStatUi stat;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 8, 8, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: CampColors.border),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A1A2E).withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
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
                  stat.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                    height: 1,
                    color: CampColors.muted,
                  ),
                ),
              ),
              Container(
                width: 24,
                height: 24,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: stat.iconBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(stat.icon, size: 12, color: stat.iconColor),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            stat.value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: CampColors.heading,
              height: 1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            stat.subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 9,
              height: 1.1,
              color: CampColors.muted,
            ),
          ),
        ],
      ),
    );
  }
}

class CampListFilterChips extends StatelessWidget {
  const CampListFilterChips({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final String selected;
  final ValueChanged<String> onSelected;

  static const _chips = ['All camps', 'Today', 'Live', 'Upcoming', 'Completed'];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 34,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _chips.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final label = _chips[i];
          final active = label == selected;
          return GestureDetector(
            onTap: () => onSelected(label),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: active ? CampColors.heading : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: active ? CampColors.heading : CampColors.border,
                ),
              ),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: active ? Colors.white : CampColors.muted,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class CampListSectionHeader extends StatelessWidget {
  const CampListSectionHeader({super.key, required this.title, this.count});

  final String title;
  final int? count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: CampColors.heading,
            ),
          ),
          if (count != null) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: CampColors.background,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: CampColors.border),
              ),
              child: Text(
                '$count',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: CampColors.muted,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class CampListCard extends StatelessWidget {
  const CampListCard({super.key, required this.camp, this.onView});

  final CampItemUi camp;
  final VoidCallback? onView;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: CampColors.primary.withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(
            color: CampColors.primary.withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        camp.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: CampColors.heading,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: camp.badgeBg,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        camp.statusLabel.toUpperCase(),
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                          color: camp.badgeFg,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _InfoLine(icon: Icons.location_on_outlined, text: camp.location),
                const SizedBox(height: 6),
                _InfoLine(icon: Icons.calendar_today_outlined, text: camp.date),
                const SizedBox(height: 6),
                _InfoLine(icon: Icons.access_time_rounded, text: camp.time),
                const SizedBox(height: 8),
                Text.rich(
                  TextSpan(
                    style: const TextStyle(fontSize: 11, color: CampColors.muted),
                    children: [
                      const TextSpan(text: 'Created by: '),
                      TextSpan(
                        text: camp.createdBy,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: CampColors.heading,
                        ),
                      ),
                      const TextSpan(text: '    Assigned Partner: '),
                      TextSpan(
                        text: camp.assignedPartner,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: CampColors.heading,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: CampColors.border),
          _PeopleRow(
            icon: Icons.groups_outlined,
            label: 'VOLUNTEERS:',
            people: camp.volunteers,
            extra: camp.volunteerExtra,
            emptyLabel: camp.noVolunteers ? 'No volunteers' : null,
          ),
          const Divider(height: 1, color: CampColors.border),
          _PeopleRow(
            icon: Icons.work_outline_rounded,
            label: 'PARTNERS:',
            people: camp.partners,
            extra: camp.partnerExtra,
            showDot: true,
            emptyLabel: camp.partners.isEmpty ? 'No partners' : null,
          ),
          const Divider(height: 1, color: CampColors.border),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: CampColors.background,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: CampColors.border),
                  ),
                  child: Text(
                    '${camp.patients} Patients',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: CampColors.secondary,
                    ),
                  ),
                ),
                const Spacer(),
                Material(
                  color: CampColors.primaryTint,
                  borderRadius: BorderRadius.circular(20),
                  child: InkWell(
                    onTap: onView,
                    borderRadius: BorderRadius.circular(20),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.visibility_outlined,
                            size: 16,
                            color: CampColors.primary,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'View',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: CampColors.primary,
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

class _InfoLine extends StatelessWidget {
  const _InfoLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 15, color: CampColors.muted),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              height: 1.25,
              color: CampColors.secondary,
            ),
          ),
        ),
      ],
    );
  }
}

class _PeopleRow extends StatelessWidget {
  const _PeopleRow({
    required this.icon,
    required this.label,
    required this.people,
    this.extra = 0,
    this.showDot = false,
    this.emptyLabel,
  });

  final IconData icon;
  final String label;
  final List<CampPersonUi> people;
  final int extra;
  final bool showDot;
  final String? emptyLabel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          Icon(icon, size: 16, color: CampColors.muted),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
              color: CampColors.muted,
            ),
          ),
          const SizedBox(width: 8),
          if (emptyLabel != null && people.isEmpty)
            Expanded(
              child: Text(
                emptyLabel!,
                style: const TextStyle(fontSize: 11, color: Color(0xFFBBBAC4)),
              ),
            )
          else ...[
            _AvatarStack(people: people, size: 26, showDot: showDot),
            if (extra > 0) ...[
              const SizedBox(width: 6),
              Text(
                '+$extra',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: CampColors.heading,
                ),
              ),
            ],
            const Spacer(),
          ],
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: CampColors.primaryTint,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.visibility_outlined,
              size: 15,
              color: CampColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _AvatarStack extends StatelessWidget {
  const _AvatarStack({
    required this.people,
    this.size = 22,
    this.showDot = false,
  });

  final List<CampPersonUi> people;
  final double size;
  final bool showDot;

  @override
  Widget build(BuildContext context) {
    if (people.isEmpty) return const SizedBox.shrink();
    final visible = people.take(3).toList();
    return SizedBox(
      width: size + (visible.length - 1) * (size - 6),
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          for (var i = 0; i < visible.length; i++)
            Positioned(
              left: i * (size - 6),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: size,
                    height: size,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: visible[i].bg,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Text(
                      visible[i].initial,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: visible[i].fg,
                      ),
                    ),
                  ),
                  if (showDot)
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF9F27),
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
