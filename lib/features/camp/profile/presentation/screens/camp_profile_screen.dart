import 'package:flutter/material.dart';
import 'package:timelay_health/features/auth/data/auth_session.dart';
import 'package:timelay_health/features/auth/domain/entities/employee.dart';
import 'package:timelay_health/features/camp/dashboard/presentation/theme/camp_colors.dart';
import 'package:timelay_health/features/camp/dashboard/presentation/widgets/camp_top_bar.dart';
import 'package:timelay_health/features/camp/patients/presentation/widgets/patient_tokens.dart';

class CampProfileScreen extends StatefulWidget {
  const CampProfileScreen({super.key});

  @override
  State<CampProfileScreen> createState() => _CampProfileScreenState();
}

class _CampProfileScreenState extends State<CampProfileScreen> {
  Employee? _employee;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final employee = AuthSession.currentEmployee ?? await AuthSession.load();
    if (!mounted) return;
    setState(() {
      _employee = employee;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: CampColors.background,
      child: Column(
        children: [
          const CampTopBar(),
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(color: CampColors.primary),
                  )
                : _employee == null
                    ? const Center(
                        child: Text(
                          'No profile data found',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 13,
                            color: CampColors.muted,
                          ),
                        ),
                      )
                    : ListView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(14, 12, 14, 28),
                        children: [
                          _HeroCard(employee: _employee!),
                          const SizedBox(height: 14),
                          _QuickFacts(employee: _employee!),
                          const SizedBox(height: 14),
                          _DetailsCard(employee: _employee!),
                        ],
                      ),
          ),
        ],
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.employee});

  final Employee employee;

  @override
  Widget build(BuildContext context) {
    final first = employee.displayName.split(RegExp(r'\s+')).first;
    final role = employee.designation.trim().isNotEmpty
        ? employee.designation
        : (employee.role.isEmpty ? 'Staff' : employee.role);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: kPatientHeroGradient,
        boxShadow: [
          BoxShadow(
            color: kPatientPrimary.withValues(alpha: 0.28),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          children: [
            Positioned(
              right: -40,
              top: -44,
              child: _Glow(size: 150, opacity: 0.12),
            ),
            Positioned(
              left: -30,
              bottom: -50,
              child: _Glow(size: 130, opacity: 0.08),
            ),
            Positioned(
              right: 28,
              bottom: 20,
              child: _Glow(size: 52, opacity: 0.1),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Avatar(letter: employee.avatarLetter),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome back, $first',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.white.withValues(alpha: 0.72),
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              employee.displayName,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 19,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              role.toUpperCase(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFFB8B0E8),
                                letterSpacing: 0.7,
                                height: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _StatusPill(
                        label: employee.statusLabel,
                        active: employee.isActive,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 11,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.12),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _HeroMeta(
                            icon: Icons.badge_outlined,
                            label: employee.employeeId.isEmpty
                                ? '—'
                                : employee.employeeId,
                          ),
                        ),
                        _HeroDivider(),
                        Expanded(
                          child: _HeroMeta(
                            icon: Icons.apartment_rounded,
                            label: employee.department.isEmpty
                                ? '—'
                                : employee.department,
                          ),
                        ),
                        _HeroDivider(),
                        Expanded(
                          child: _HeroMeta(
                            icon: Icons.calendar_today_outlined,
                            label: employee.joinDateShort,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (employee.email.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(
                          Icons.mail_outline_rounded,
                          size: 14,
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            employee.email,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: Colors.white.withValues(alpha: 0.85),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Glow extends StatelessWidget {
  const _Glow({required this.size, required this.opacity});

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

class _Avatar extends StatelessWidget {
  const _Avatar({required this.letter});

  final String letter;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.35),
          width: 2,
        ),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF6B63A8), Color(0xFF3D3670)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        letter,
        style: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 24,
          fontWeight: FontWeight.w800,
          color: Colors.white,
          height: 1,
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label, required this.active});

  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: active
            ? const Color(0xFF1FA971).withValues(alpha: 0.22)
            : CampColors.red.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: active
              ? const Color(0xFF6EE7B7).withValues(alpha: 0.45)
              : CampColors.red.withValues(alpha: 0.45),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: active ? const Color(0xFFA7F3D0) : const Color(0xFFFFCDD2),
        ),
      ),
    );
  }
}

class _HeroMeta extends StatelessWidget {
  const _HeroMeta({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 15, color: Colors.white.withValues(alpha: 0.75)),
        const SizedBox(height: 5),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            height: 1.15,
          ),
        ),
      ],
    );
  }
}

class _HeroDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 28,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      color: Colors.white.withValues(alpha: 0.18),
    );
  }
}

class _QuickFacts extends StatelessWidget {
  const _QuickFacts({required this.employee});

  final Employee employee;

  @override
  Widget build(BuildContext context) {
    final phone = (employee.phone ?? '').trim();
    final role = employee.role.isEmpty ? '—' : employee.role;

    final tiles = [
      _Fact(
        label: 'Employee ID',
        value: employee.employeeId.isEmpty ? '—' : employee.employeeId,
        icon: Icons.badge_outlined,
        accent: CampColors.primary,
        tint: CampColors.primaryTint,
      ),
      _Fact(
        label: 'Department',
        value: employee.department.isEmpty ? '—' : employee.department,
        icon: Icons.apartment_rounded,
        accent: CampColors.blue,
        tint: CampColors.blueTint,
      ),
      _Fact(
        label: 'Role',
        value: role,
        icon: Icons.work_outline_rounded,
        accent: CampColors.green,
        tint: CampColors.greenTint,
      ),
      _Fact(
        label: phone.isEmpty ? 'Joined' : 'Phone',
        value: phone.isEmpty ? employee.joinDateShort : phone,
        icon: phone.isEmpty
            ? Icons.calendar_today_outlined
            : Icons.phone_outlined,
        accent: CampColors.orange,
        tint: CampColors.orangeTint,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 2, bottom: 10),
          child: Text(
            'Quick facts',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13.5,
              fontWeight: FontWeight.w800,
              color: CampColors.heading,
              height: 1.2,
            ),
          ),
        ),
        Row(
          children: [
            Expanded(child: _FactTile(fact: tiles[0])),
            const SizedBox(width: 10),
            Expanded(child: _FactTile(fact: tiles[1])),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: _FactTile(fact: tiles[2])),
            const SizedBox(width: 10),
            Expanded(child: _FactTile(fact: tiles[3])),
          ],
        ),
      ],
    );
  }
}

class _Fact {
  const _Fact({
    required this.label,
    required this.value,
    required this.icon,
    required this.accent,
    required this.tint,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color accent;
  final Color tint;
}

class _FactTile extends StatelessWidget {
  const _FactTile({required this.fact});

  final _Fact fact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      decoration: CampColors.card(radius: 16),
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
                  color: fact.tint,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(fact.icon, size: 15, color: fact.accent),
              ),
              const Spacer(),
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: fact.accent,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            fact.label.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: CampColors.muted,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            fact.value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 13.5,
              fontWeight: FontWeight.w800,
              color: CampColors.heading,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailsCard extends StatelessWidget {
  const _DetailsCard({required this.employee});

  final Employee employee;

  @override
  Widget build(BuildContext context) {
    final phone = (employee.phone ?? '').trim();
    final rows = <({IconData icon, Color tint, Color accent, String label, String value})>[
      (
        icon: Icons.mail_outline_rounded,
        tint: CampColors.primaryTint,
        accent: CampColors.primary,
        label: 'Email',
        value: employee.email.isEmpty ? '—' : employee.email,
      ),
      if (phone.isNotEmpty)
        (
          icon: Icons.phone_outlined,
          tint: CampColors.greenTint,
          accent: CampColors.green,
          label: 'Phone',
          value: phone,
        ),
      (
        icon: Icons.apartment_rounded,
        tint: CampColors.blueTint,
        accent: CampColors.blue,
        label: 'Department',
        value: employee.department.isEmpty ? '—' : employee.department,
      ),
      (
        icon: Icons.work_outline_rounded,
        tint: CampColors.orangeTint,
        accent: CampColors.orange,
        label: 'Role',
        value: employee.role.isEmpty ? '—' : employee.role,
      ),
      (
        icon: Icons.calendar_today_outlined,
        tint: CampColors.slateTint,
        accent: CampColors.slate,
        label: 'Joined',
        value: employee.joinDateLong,
      ),
    ];

    return Container(
      width: double.infinity,
      decoration: CampColors.card(radius: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 4),
            child: Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: CampColors.primaryTint,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: const Icon(
                    Icons.person_outline_rounded,
                    size: 16,
                    color: CampColors.primary,
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Profile details',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: CampColors.heading,
                  ),
                ),
              ],
            ),
          ),
          for (var i = 0; i < rows.length; i++)
            _DetailRow(
              icon: rows[i].icon,
              tint: rows[i].tint,
              accent: rows[i].accent,
              label: rows[i].label,
              value: rows[i].value,
              showDivider: i != rows.length - 1,
            ),
          const SizedBox(height: 6),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.tint,
    required this.accent,
    required this.label,
    required this.value,
    required this.showDivider,
  });

  final IconData icon;
  final Color tint;
  final Color accent;
  final String label;
  final String value;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 11),
      decoration: showDivider
          ? const BoxDecoration(
              border: Border(bottom: BorderSide(color: CampColors.border)),
            )
          : null,
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: tint,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 16, color: accent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: CampColors.muted,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: CampColors.heading,
                    height: 1.25,
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
