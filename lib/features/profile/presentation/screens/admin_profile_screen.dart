import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:timelay_health/core/theme/portal_colors.dart';
import 'package:timelay_health/core/theme/portal_text.dart';
import 'package:timelay_health/core/widgets/portal_back_button.dart';
import 'package:timelay_health/core/widgets/portal_safe_area.dart';
import 'package:timelay_health/features/auth/data/auth_session.dart';
import 'package:timelay_health/features/auth/domain/entities/employee.dart';
import 'package:timelay_health/features/holidays/presentation/widgets/top_calendar_button.dart';
import 'package:timelay_health/features/notifications/presentation/widgets/top_notification_button.dart';

class AdminProfileScreen extends StatelessWidget {
  const AdminProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final admin = AuthSession.currentEmployee;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: PortalColors.background,
        body: PortalSafeArea(
          bottom: false,
          child: Column(
            children: [
              const _TopBar(),
              Expanded(
                child: admin == null
                    ? Center(
                        child: Text(
                          'Admin session not found. Please login again.',
                          style: portalText(
                            fontSize: 13,
                            color: PortalColors.muted,
                          ),
                        ),
                      )
                    : _AdminProfileBody(admin: admin),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: PortalColors.surface,
        border: Border(bottom: BorderSide(color: PortalColors.border)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 10, 18, 10),
      child: Row(
        children: [
          const PortalBackButton(),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'My Profile',
                  style: portalText(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: PortalColors.heading,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Admin account details',
                  style: portalText(
                    fontSize: 11,
                    color: PortalColors.muted,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const TopNotificationButton(),
          const SizedBox(width: 14),
          const TopCalendarButton(),
        ],
      ),
    );
  }
}

class _AdminProfileBody extends StatelessWidget {
  const _AdminProfileBody({required this.admin});

  final Employee admin;

  @override
  Widget build(BuildContext context) {
    final phone = (admin.phone ?? '').trim();
    final role = admin.role.trim().isEmpty ? 'Admin' : admin.role.trim();
    final dept = admin.department.trim();
    final userType =
        admin.userType.trim().isEmpty ? 'admin' : admin.userType.trim();
    final address = (admin.address ?? '').trim();
    final lastLogin = admin.lastLoginLocation;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
      children: [
        _HeroCard(admin: admin, role: role),
        const SizedBox(height: 14),
        _StatsRow(
          items: [
            _StatItem(
              label: 'Access',
              value: 'Full',
              icon: Icons.verified_user_rounded,
              tint: PortalColors.greenTint,
              iconColor: PortalColors.green,
            ),
            _StatItem(
              label: 'Portal',
              value: 'Admin',
              icon: Icons.admin_panel_settings_rounded,
              tint: PortalColors.brandTint,
              iconColor: PortalColors.brand,
            ),
            _StatItem(
              label: 'Status',
              value: admin.isActive ? 'Active' : 'Inactive',
              icon: Icons.circle,
              tint: admin.isActive
                  ? PortalColors.greenTint
                  : PortalColors.redTint,
              iconColor:
                  admin.isActive ? PortalColors.green : PortalColors.red,
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'Account details',
          style: portalText(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: PortalColors.heading,
          ),
        ),
        const SizedBox(height: 10),
        _DetailsCard(
          rows: [
            _DetailRow(
              icon: Icons.mail_outline_rounded,
              label: 'Email',
              value: admin.email.trim().isEmpty ? '—' : admin.email.trim(),
              tint: const Color(0xFFEFF6FF),
              iconColor: const Color(0xFF2563EB),
            ),
            _DetailRow(
              icon: Icons.phone_outlined,
              label: 'Mobile',
              value: phone.isEmpty ? '—' : phone,
              tint: PortalColors.greenTint,
              iconColor: PortalColors.green,
            ),
            _DetailRow(
              icon: Icons.badge_outlined,
              label: 'Role',
              value: role,
              tint: PortalColors.brandTint,
              iconColor: PortalColors.brand,
            ),
            _DetailRow(
              icon: Icons.apartment_rounded,
              label: 'Department',
              value: dept.isEmpty ? 'Management' : dept,
              tint: PortalColors.orangeTint,
              iconColor: PortalColors.orange,
            ),
            _DetailRow(
              icon: Icons.manage_accounts_outlined,
              label: 'Account type',
              value: userType,
              tint: const Color(0xFFF3E8FF),
              iconColor: const Color(0xFF7C3AED),
            ),
            _DetailRow(
              icon: Icons.fingerprint_rounded,
              label: 'Admin ID',
              value: admin.id.trim().isEmpty ? '—' : admin.id.trim(),
              tint: PortalColors.redTint,
              iconColor: PortalColors.red,
            ),
          ],
        ),
        if (address.isNotEmpty || lastLogin != null) ...[
          const SizedBox(height: 16),
          Text(
            'Location',
            style: portalText(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: PortalColors.heading,
            ),
          ),
          const SizedBox(height: 10),
          _DetailsCard(
            rows: [
              if (address.isNotEmpty)
                _DetailRow(
                  icon: Icons.location_on_outlined,
                  label: 'Address',
                  value: address,
                  tint: const Color(0xFFE8F1FF),
                  iconColor: const Color(0xFF2563EB),
                ),
              if (lastLogin != null)
                _DetailRow(
                  icon: Icons.my_location_rounded,
                  label: 'Last login',
                  value: _formatLastLogin(lastLogin),
                  tint: PortalColors.greenTint,
                  iconColor: PortalColors.green,
                ),
            ],
          ),
        ],
      ],
    );
  }

  String _formatLastLogin(EmployeeLocation loc) {
    final parts = <String>[];
    final addr = (loc.address ?? '').trim();
    if (addr.isNotEmpty) parts.add(addr);
    if (loc.timestamp != null) {
      final t = loc.timestamp!;
      parts.add(
        '${t.day.toString().padLeft(2, '0')}/'
        '${t.month.toString().padLeft(2, '0')}/'
        '${t.year} · '
        '${t.hour.toString().padLeft(2, '0')}:'
        '${t.minute.toString().padLeft(2, '0')}',
      );
    } else {
      parts.add(
        '${loc.latitude.toStringAsFixed(5)}, ${loc.longitude.toStringAsFixed(5)}',
      );
    }
    return parts.isEmpty ? '—' : parts.join('\n');
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.admin, required this.role});

  final Employee admin;
  final String role;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF26204A), Color(0xFF3D3670), Color(0xFF4B4285)],
        ),
        boxShadow: [
          BoxShadow(
            color: PortalColors.brand.withValues(alpha: 0.28),
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
              right: -30,
              top: -36,
              child: _Glow(size: 140, opacity: 0.14),
            ),
            Positioned(
              left: -24,
              bottom: -40,
              child: _Glow(size: 120, opacity: 0.1),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        alignment: Alignment.center,
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
                        child: Text(
                          admin.initials,
                          style: portalText(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981)
                                    .withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: const Color(0xFF34D399)
                                      .withValues(alpha: 0.45),
                                ),
                              ),
                              child: Text(
                                'ADMIN PORTAL',
                                style: portalText(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFFA7F3D0),
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              admin.displayName,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: portalText(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                height: 1.15,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              role.toUpperCase(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: portalText(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFFB8B0E8),
                                letterSpacing: 0.6,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
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
                        Icon(
                          Icons.shield_moon_rounded,
                          size: 18,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Secure admin access · Timely Health HRMS',
                            style: portalText(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: Colors.white.withValues(alpha: 0.88),
                            ),
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

class _StatItem {
  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.tint,
    required this.iconColor,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color tint;
  final Color iconColor;
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.items});

  final List<_StatItem> items;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) const SizedBox(width: 10),
          Expanded(child: _StatCard(item: items[i])),
        ],
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.item});

  final _StatItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      decoration: BoxDecoration(
        color: PortalColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: PortalColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: item.tint,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Icon(item.icon, size: 16, color: item.iconColor),
          ),
          const SizedBox(height: 10),
          Text(
            item.value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: portalText(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: PortalColors.heading,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            item.label,
            style: portalText(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: PortalColors.muted,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.tint,
    required this.iconColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color tint;
  final Color iconColor;
}

class _DetailsCard extends StatelessWidget {
  const _DetailsCard({required this.rows});

  final List<_DetailRow> rows;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: PortalColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: PortalColors.border),
      ),
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0)
              const Divider(height: 1, color: PortalColors.border),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: rows[i].tint,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      rows[i].icon,
                      size: 18,
                      color: rows[i].iconColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          rows[i].label,
                          style: portalText(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: PortalColors.muted,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          rows[i].value,
                          style: portalText(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: PortalColors.heading,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
