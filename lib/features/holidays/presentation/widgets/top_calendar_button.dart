import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:timelay_health/features/roster/presentation/screens/work_roster_screen.dart';

class TopCalendarButton extends StatelessWidget {
  const TopCalendarButton({
    super.key,
    this.width = 34,
    this.height = 34,
    this.asset = 'assets/icons/top_bar/ic_top_calendar.svg',
  });

  final double width;
  final double height;
  final String asset;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => WorkRosterScreen.open(context),
        borderRadius: BorderRadius.circular(17),
        child: SvgPicture.asset(asset, width: width, height: height),
      ),
    );
  }
}
