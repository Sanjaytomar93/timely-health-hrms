import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:timelay_health/features/notifications/presentation/screens/notifications_screen.dart';

Future<void> openNotificationsScreen(BuildContext context) {
  return Navigator.of(
    context,
  ).push(MaterialPageRoute<void>(builder: (_) => const NotificationsScreen()));
}

class TopNotificationButton extends StatelessWidget {
  const TopNotificationButton({
    super.key,
    this.width = 34,
    this.height = 34,
    this.asset = 'assets/icons/top_bar/ic_top_notification.svg',
  });

  final double width;
  final double height;
  final String asset;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => openNotificationsScreen(context),
        borderRadius: BorderRadius.circular(17),
        child: Padding(
          padding: const EdgeInsets.all(2),
          child: SvgPicture.asset(asset, width: width, height: height),
        ),
      ),
    );
  }
}
