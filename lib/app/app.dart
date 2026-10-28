import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:timelay_health/core/routes/app_routes.dart';
import 'package:timelay_health/core/theme/app_theme.dart';
import 'package:timelay_health/core/theme/portal_system_ui.dart';

class TimelayHealthApp extends StatelessWidget {
  const TimelayHealthApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Timely Health',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      builder: (context, child) {
        final media = MediaQuery.of(context);
        return MediaQuery(
          data: media.copyWith(
            textScaler: const TextScaler.linear(0.85),
          ),
          child: AnnotatedRegion<SystemUiOverlayStyle>(
            value: PortalSystemUi.lightStatusBar,
            child: child ?? const SizedBox.shrink(),
          ),
        );
      },
      initialRoute: AppRoutes.splash,
      onGenerateRoute: AppRoutes.onGenerateRoute,
    );
  }
}
