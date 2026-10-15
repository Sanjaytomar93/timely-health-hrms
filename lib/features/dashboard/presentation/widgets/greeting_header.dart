import 'package:flutter/material.dart';
import 'package:timelay_health/core/theme/portal_colors.dart';
import 'package:timelay_health/core/theme/portal_text.dart';
import 'package:timelay_health/features/dashboard/presentation/models/dashboard_home_ui.dart';

class GreetingHeader extends StatelessWidget {
  const GreetingHeader({super.key, this.data});

  final DashboardGreetingUi? data;

  static const double _leadingWidth = 26;

  @override
  Widget build(BuildContext context) {
    final greeting = data?.greeting ?? 'Good afternoon';
    final firstName = data?.firstName ?? 'there';
    final dateLabel = data?.dateLabel ?? '';

    final titleStyle = portalText(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.2,
      height: 24 / 20,
      color: PortalColors.heading,
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: _leadingWidth,
                child: Center(child: Text('👋', style: titleStyle)),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    style: titleStyle,
                    children: [
                      TextSpan(text: '$greeting, '),
                      TextSpan(
                        text: firstName,
                        style: titleStyle.copyWith(color: PortalColors.green),
                      ),
                    ],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const SizedBox(
                width: _leadingWidth,
                child: Center(
                  child: Icon(
                    Icons.calendar_today_outlined,
                    size: 14,
                    color: PortalColors.muted,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  dateLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: portalText(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w400,
                    color: PortalColors.muted,
                    height: 15 / 12.5,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
