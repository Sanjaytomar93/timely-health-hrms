import 'package:flutter/material.dart';
import 'package:timelay_health/features/camp/presentation/models/patient_list_ui.dart';
import 'package:timelay_health/features/camp/presentation/theme/camp_colors.dart';

// ─────────────────────────────────────────────────────────────
//  Design tokens
// ─────────────────────────────────────────────────────────────

const _kPrimary = CampColors.primary; // #6C63FF
const _kPrimaryDeep = Color(0xFF5048E5);
const _kPrimaryDark = Color(0xFF3730C1);
const _kSurface = CampColors.surface;
const _kBorder = CampColors.border;
const _kBg = CampColors.background;
const _kHeading = CampColors.heading;
const _kMuted = CampColors.muted;

// ─────────────────────────────────────────────────────────────
//  HERO HEADER  – gradient banner
// ─────────────────────────────────────────────────────────────

class PatientsHeroHeader extends StatelessWidget {
  const PatientsHeroHeader({super.key, required this.data});

  final PatientListUi data;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_kPrimaryDark, _kPrimary, Color(0xFF9087FF)],
          stops: [0.0, 0.55, 1.0],
        ),
      ),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            right: -30,
            top: -30,
            child: _GlowCircle(size: 140, opacity: 0.08),
          ),
          Positioned(
            right: 40,
            bottom: -20,
            child: _GlowCircle(size: 90, opacity: 0.06),
          ),
          Positioned(
            left: -20,
            bottom: 10,
            child: _GlowCircle(size: 70, opacity: 0.05),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Breadcrumb pill
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.grid_view_rounded,
                              size: 11, color: Colors.white70),
                          SizedBox(width: 5),
                          Text(
                            'Camp · Patients',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: Colors.white70,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Add patient button
                    _AddPatientButton(),
                  ],
                ),

                const SizedBox(height: 14),

                // Title
                const Text(
                  'All Patients',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 1.1,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),

                // Subtitle row
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFF7EFFD4),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      data.subtitle,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GlowCircle extends StatelessWidget {
  const _GlowCircle({required this.size, required this.opacity});
  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: opacity),
      ),
    );
  }
}

class _AddPatientButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 34,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: _kPrimaryDark.withValues(alpha: 0.30),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.add_rounded, size: 15, color: _kPrimary),
              SizedBox(width: 5),
              Text(
                'Add patient',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: _kPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  STAT GRID  – 2×2, overlapping the hero
// ─────────────────────────────────────────────────────────────

class PatientsStatGrid extends StatelessWidget {
  const PatientsStatGrid({super.key, required this.stats});

  final List<PatientStatUi> stats;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 2.1,
        ),
        itemCount: stats.length,
        itemBuilder: (_, i) => _StatTile(stat: stats[i], index: i),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.stat, required this.index});

  final PatientStatUi stat;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _kBorder),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A1A2E).withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            // Icon pill
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: stat.iconBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(stat.icon, size: 18, color: stat.iconFg),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    stat.value,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: _kHeading,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    stat.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 9.5,
                      fontWeight: FontWeight.w400,
                      color: _kMuted,
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
}

// ─────────────────────────────────────────────────────────────
//  SEARCH + FILTER BAR
// ─────────────────────────────────────────────────────────────

class PatientsSearchBar extends StatelessWidget {
  const PatientsSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
    this.onFilter,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback? onFilter;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: _kSurface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _kBorder),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const SizedBox(width: 14),
                  const Icon(Icons.search_rounded, size: 18, color: _kMuted),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: controller,
                      onChanged: onChanged,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        color: _kHeading,
                      ),
                      decoration: const InputDecoration(
                        isDense: true,
                        border: InputBorder.none,
                        hintText: 'Search name, camp or phone...',
                        hintStyle: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          color: Color(0xFFBBBAC4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Filter icon button
          Material(
            color: _kPrimary,
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              onTap: onFilter,
              borderRadius: BorderRadius.circular(14),
              child: const SizedBox(
                width: 44,
                height: 44,
                child: Icon(Icons.tune_rounded, size: 18, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  FILTER CHIPS
// ─────────────────────────────────────────────────────────────

class PatientsFilterChips extends StatelessWidget {
  const PatientsFilterChips({
    super.key,
    required this.selected,
    required this.onSelected,
    required this.counts,
  });

  final String selected;
  final ValueChanged<String> onSelected;
  final Map<String, int> counts;

  static const _chips = ['All', 'Female', 'Male', 'Minors'];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
        itemCount: _chips.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final label = _chips[i];
          final active = label == selected;
          final count = counts[label];
          return GestureDetector(
            onTap: () => onSelected(label),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: active ? _kPrimary : _kSurface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: active ? _kPrimary : _kBorder,
                  width: active ? 1.5 : 1,
                ),
                boxShadow: active
                    ? [
                        BoxShadow(
                          color: _kPrimary.withValues(alpha: 0.30),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        )
                      ]
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: active ? Colors.white : _kMuted,
                    ),
                  ),
                  if (count != null) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: active
                            ? Colors.white.withValues(alpha: 0.25)
                            : _kBg,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$count',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: active ? Colors.white : _kMuted,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  SECTION HEADER
// ─────────────────────────────────────────────────────────────

class PatientsSectionHeader extends StatelessWidget {
  const PatientsSectionHeader({
    super.key,
    required this.label,
    required this.count,
  });

  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: _kHeading,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: _kPrimary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$count',
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: _kPrimary,
              ),
            ),
          ),
          const Spacer(),
          // thin line
          Expanded(
            flex: 3,
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [_kBorder, _kBorder.withValues(alpha: 0)],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  ACCORDION PATIENT CARD
// ─────────────────────────────────────────────────────────────

class PatientAccordionCard extends StatelessWidget {
  const PatientAccordionCard({
    super.key,
    required this.patient,
    required this.index,
    this.onView,
    this.onEdit,
    this.onDelete,
  });

  final PatientUi patient;
  final int index;
  final VoidCallback? onView;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final p = patient;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: Container(
        decoration: BoxDecoration(
          color: _kSurface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: _kPrimary.withValues(alpha: 0.25),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: _kPrimary.withValues(alpha: 0.07),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Header row (avatar + name + tag)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
              child: Row(
                children: [
                  // Avatar with gender dot
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: p.resolvedAvatarBg,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: p.resolvedAvatarFg.withValues(alpha: 0.35),
                            width: 1.5,
                          ),
                        ),
                        child: Text(
                          p.initials,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: p.resolvedAvatarFg,
                            height: 1,
                          ),
                        ),
                      ),
                      // Gender dot
                      Positioned(
                        right: -2,
                        bottom: -2,
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: p.gender == PatientGender.female
                                ? const Color(0xFF0F6E56)
                                : p.gender == PatientGender.male
                                    ? const Color(0xFF185FA5)
                                    : _kPrimary,
                            shape: BoxShape.circle,
                            border: Border.all(color: _kSurface, width: 2),
                          ),
                          child: Icon(
                            p.gender == PatientGender.female
                                ? Icons.female_rounded
                                : Icons.male_rounded,
                            size: 9,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),

                  // Name + age/gender
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                p.name,
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: _kHeading,
                                  height: 1.2,
                                ),
                              ),
                            ),
                            if (p.campTag != null)
                              _Tag(
                                label: p.campTag!,
                                bg: const Color(0xFFF0EFFE),
                                fg: const Color(0xFF534AB7),
                              )
                            else if (p.statusTag != null)
                              _Tag(
                                label: p.statusTag!,
                                bg: const Color(0xFFE1F5EE),
                                fg: const Color(0xFF0F6E56),
                              ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            Icon(Icons.cake_outlined, size: 11, color: _kMuted),
                            const SizedBox(width: 4),
                            Text(
                              p.ageGenderLine,
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 11,
                                color: _kMuted,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Gradient divider
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Container(
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _kPrimary.withValues(alpha: 0.0),
                      _kPrimary.withValues(alpha: 0.20),
                      _kPrimary.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),

            // ── Detail chips (phone + gender + age)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _DetailChip(
                        icon: Icons.phone_in_talk_rounded,
                        label: p.phone,
                        bg: const Color(0xFFF5F6FA),
                        fg: const Color(0xFF444444),
                      ),
                      const SizedBox(width: 8),
                      _DetailChip(
                        icon: p.gender == PatientGender.female
                            ? Icons.female_rounded
                            : Icons.male_rounded,
                        label: p.genderLabel,
                        bg: p.gender == PatientGender.female
                            ? const Color(0xFFE1F5EE)
                            : const Color(0xFFE6F1FB),
                        fg: p.gender == PatientGender.female
                            ? const Color(0xFF0F6E56)
                            : const Color(0xFF185FA5),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _DetailChip(
                    icon: Icons.person_outline_rounded,
                    label: '${p.age} years old',
                    bg: const Color(0xFFF5F6FA),
                    fg: const Color(0xFF444444),
                  ),
                ],
              ),
            ),

            // ── Second divider
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Container(
                height: 1,
                color: const Color(0xFFF0EFF6),
              ),
            ),

            // ── Action buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
              child: Row(
                children: [
                  Expanded(
                    child: _AccordionActionBtn(
                      label: 'View',
                      icon: Icons.visibility_outlined,
                      bg: _kPrimary,
                      fg: Colors.white,
                      hasBorder: false,
                      onTap: onView,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _AccordionActionBtn(
                      label: 'Edit',
                      icon: Icons.edit_outlined,
                      bg: const Color(0xFFF5F6FA),
                      fg: const Color(0xFF5F5E5A),
                      onTap: onEdit,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _AccordionActionBtn(
                      label: 'Delete',
                      icon: Icons.delete_outline_rounded,
                      bg: const Color(0xFFFCEBEB),
                      fg: const Color(0xFFA32D2D),
                      borderColor: const Color(0xFFF7C1C1),
                      onTap: onDelete,
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
}


// ─────────────────────────────────────────────────────────────
//  Shared small widgets
// ─────────────────────────────────────────────────────────────

class _Tag extends StatelessWidget {
  const _Tag({required this.label, required this.bg, required this.fg});
  final String label;
  final Color bg;
  final Color fg;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 9.5,
            fontWeight: FontWeight.w600,
            color: fg,
          ),
        ),
      );
}

class _DetailChip extends StatelessWidget {
  const _DetailChip({
    required this.icon,
    required this.label,
    required this.bg,
    required this.fg,
  });
  final IconData icon;
  final String label;
  final Color bg;
  final Color fg;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: fg),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: fg,
              ),
            ),
          ],
        ),
      );
}

class _AccordionActionBtn extends StatelessWidget {
  const _AccordionActionBtn({
    required this.label,
    required this.icon,
    required this.bg,
    required this.fg,
    this.borderColor,
    this.hasBorder = true,
    this.onTap,
  });
  final String label;
  final IconData icon;
  final Color bg;
  final Color fg;
  final Color? borderColor;
  final bool hasBorder;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 36,
          alignment: Alignment.center,
          decoration: hasBorder
              ? BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: borderColor ?? fg.withValues(alpha: 0.30),
                  ),
                )
              : BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    colors: [_kPrimaryDeep, _kPrimary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _kPrimary.withValues(alpha: 0.35),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 13, color: fg),
              const SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
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

// ─────────────────────────────────────────────────────────────
//  EMPTY STATE
// ─────────────────────────────────────────────────────────────

class PatientsEmptyState extends StatelessWidget {
  const PatientsEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: _kPrimary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(
              Icons.people_alt_outlined,
              size: 34,
              color: _kPrimary,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No patients found',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: _kHeading,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Try adjusting your search or filter',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              color: _kMuted,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  ADD NEW PATIENT FAB-STYLE BUTTON
// ─────────────────────────────────────────────────────────────

class PatientsAddNewButton extends StatelessWidget {
  const PatientsAddNewButton({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            height: 52,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [_kPrimaryDark, _kPrimary, Color(0xFF9087FF)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: _kPrimary.withValues(alpha: 0.40),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Subtle circle decoration
                Positioned(
                  right: 20,
                  top: -10,
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.20),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.add_rounded,
                          size: 18,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Add New Patient',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.2,
                        ),
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
