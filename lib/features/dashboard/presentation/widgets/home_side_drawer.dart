import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:timelay_health/core/routes/app_routes.dart';
import 'package:timelay_health/core/theme/app_logos.dart';
import 'package:timelay_health/core/theme/portal_colors.dart';
import 'package:timelay_health/core/theme/portal_text.dart';
import 'package:timelay_health/features/auth/data/auth_session.dart';
import 'package:timelay_health/features/dashboard/presentation/screens/employee_home_shell.dart';

class HomeSideDrawer extends StatelessWidget {
  const HomeSideDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width * 0.72;
    final employee = AuthSession.currentEmployee;
    final name = (employee?.name ?? '').trim();
    final firstName = name.isEmpty
        ? 'there'
        : name.split(RegExp(r'\s+')).first;
    final dept = (employee?.department ?? '').trim();

    return Drawer(
      width: width.clamp(250, 288),
      backgroundColor: PortalColors.background,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _DrawerHero(
            firstName: firstName,
            department: dept.isEmpty ? 'HRMS Portal' : dept,
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(12, 18, 12, 8),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    'Management',
                    style: portalText(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: PortalColors.muted,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                _NavTile(
                  title: 'Admin Dashboard',
                  subtitle: 'Org attendance overview',
                  icon: Icons.space_dashboard_rounded,
                  color: PortalColors.brand,
                  tint: PortalColors.brandTint,
                  onTap: () {
                    Navigator.of(context).pop();
                    EmployeeHomeShell.goToDashboard(context);
                  },
                ),
                _NavTile(
                  title: 'OP Management',
                  subtitle: 'Outpatient visits & records',
                  icon: Icons.local_hospital_rounded,
                  color: PortalColors.brand,
                  tint: PortalColors.brandTint,
                  onTap: () {
                    Navigator.of(context).pop();
                    AppRoutes.push(context, AppRoutes.opManagement);
                  },
                ),
                _NavTile(
                  title: 'Camp Management',
                  subtitle: 'Camps, patients & reports',
                  icon: Icons.medical_services_rounded,
                  color: PortalColors.green,
                  tint: PortalColors.greenTint,
                  onTap: () {
                    Navigator.of(context).pop();
                    AppRoutes.push(context, AppRoutes.campManagement);
                  },
                ),
              ],
            ),
          ),
          const _DrawerFooter(),
        ],
      ),
    );
  }
}

class _DrawerFooter extends StatelessWidget {
  const _DrawerFooter();

  static const _icons = [
    'assets/icons/social/ic_instagram.svg',
    'assets/icons/social/ic_x.svg',
    'assets/icons/social/ic_linkedin.svg',
    'assets/icons/social/ic_facebook.svg',
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(AppLogos.mark, width: 16, height: 16),
              const SizedBox(width: 8),
              Text(
                'Timely Health  ·  HRMS',
                style: portalText(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: PortalColors.muted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < _icons.length; i++) ...[
                if (i > 0) const SizedBox(width: 10),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: PortalColors.brand.withValues(alpha: 0.1),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: SvgPicture.asset(_icons[i], width: 32, height: 32),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'App Version 1.0.0',
            style: portalText(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: PortalColors.heading.withValues(alpha: 0.75),
            ),
          ),
        ],
      ),
    );
  }
}

class _DrawerHero extends StatelessWidget {
  const _DrawerHero({required this.firstName, required this.department});

  final String firstName;
  final String department;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1A1638),
            PortalColors.brand,
            PortalColors.brandLight,
          ],
          stops: [0, 0.45, 1],
        ),
        borderRadius: BorderRadius.only(bottomRight: Radius.circular(28)),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -36,
            top: top + 8,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
          ),
          Positioned(
            right: 28,
            bottom: -28,
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
          Positioned(
            left: -20,
            bottom: 18,
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.12),
                  width: 1.5,
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20, top + 18, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.22),
                            blurRadius: 14,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: SvgPicture.asset(
                        AppLogos.appIcon,
                        fit: BoxFit.contain,
                        width: 48,
                        height: 48,
                      ),
                    ),
                    const Spacer(),
                    Material(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        onTap: () => Navigator.of(context).pop(),
                        borderRadius: BorderRadius.circular(12),
                        child: const SizedBox(
                          width: 36,
                          height: 36,
                          child: Icon(
                            Icons.close_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                Text(
                  'Hello, $firstName',
                  style: portalText(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.4,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  department,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: portalText(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.72),
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.16),
                    ),
                  ),
                  child: Text(
                    'Switch workspace modules',
                    style: portalText(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withValues(alpha: 0.9),
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

class _NavTile extends StatelessWidget {
  const _NavTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.tint,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Color tint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        leading: Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: tint,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 20, color: color),
        ),
        title: Text(
          title,
          style: portalText(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: PortalColors.heading,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: portalText(
            fontSize: 11.5,
            color: PortalColors.muted,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right_rounded,
          color: PortalColors.muted.withValues(alpha: 0.7),
          size: 20,
        ),
      ),
    );
  }
}
