import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:timelay_health/core/theme/portal_colors.dart';

class PortalBackButton extends StatelessWidget {
  const PortalBackButton({super.key, this.onTap});

  /// Defaults to popping the current route.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? () => Navigator.of(context).maybePop(),
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: PortalColors.background,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: PortalColors.border),
        ),
        alignment: Alignment.center,
        child: SvgPicture.asset(
          'assets/icons/payslips/ic_back.svg',
          width: 20,
          height: 20,
        ),
      ),
    );
  }
}
