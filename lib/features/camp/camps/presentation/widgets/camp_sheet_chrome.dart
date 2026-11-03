import 'package:flutter/material.dart';
import 'package:timelay_health/core/theme/portal_text.dart';
import 'package:timelay_health/features/camp/camps/presentation/models/camp_list_ui.dart';
import 'package:timelay_health/features/camp/dashboard/presentation/theme/camp_colors.dart';

const campSheetGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [CampColors.primary, Color(0xFF3A3268), CampColors.primaryLight],
);

class CampSheetFrame extends StatelessWidget {
  const CampSheetFrame({
    super.key,
    required this.header,
    required this.child,
    this.footer,
    this.maxHeightFactor = 0.78,
  });

  final Widget header;
  final Widget child;
  final Widget? footer;
  final double maxHeightFactor;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final width = (size.width - 28).clamp(300.0, 420.0);
    final maxH = size.height * maxHeightFactor;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 24),
      child: Container(
        width: width,
        constraints: BoxConstraints(maxHeight: maxH),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 28,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            header,
            Flexible(child: child),
            ?footer,
          ],
        ),
      ),
    );
  }
}

class CampSheetGradientHeader extends StatelessWidget {
  const CampSheetGradientHeader({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 12, 16),
      decoration: const BoxDecoration(gradient: campSheetGradient),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: portalText(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: portalText(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),
          Material(
            color: Colors.white.withValues(alpha: 0.18),
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () => Navigator.of(context).pop(),
              child: const SizedBox(
                width: 34,
                height: 34,
                child: Icon(Icons.close_rounded, size: 18, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CampSheetCloseButton extends StatelessWidget {
  const CampSheetCloseButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: SizedBox(
        width: double.infinity,
        height: 46,
        child: OutlinedButton(
          onPressed: () => Navigator.of(context).pop(),
          style: OutlinedButton.styleFrom(
            foregroundColor: CampColors.heading,
            side: const BorderSide(color: CampColors.border),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: Text(
            'Close',
            style: portalText(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: CampColors.heading,
            ),
          ),
        ),
      ),
    );
  }
}

class CampPersonAvatar extends StatelessWidget {
  const CampPersonAvatar({
    super.key,
    required this.person,
    this.size = 40,
  });

  final CampPersonUi person;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: CampColors.primaryTint,
        borderRadius: BorderRadius.circular(size * 0.3),
        border: Border.all(
          color: CampColors.primary.withValues(alpha: 0.1),
        ),
      ),
      child: Text(
        person.initial,
        style: portalText(
          fontSize: size * 0.36,
          fontWeight: FontWeight.w700,
          color: CampColors.primary,
        ),
      ),
    );
  }
}
