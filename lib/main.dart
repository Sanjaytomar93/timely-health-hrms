import 'dart:async';

import 'package:flutter/material.dart';
import 'package:timelay_health/app/app.dart';
import 'package:timelay_health/core/crash/crash_reporting.dart';
import 'package:timelay_health/core/notifications/push_notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await CrashReporting.initialize();
  runApp(const TimelayHealthApp());
  unawaited(PushNotificationService.initialize());
}
