import 'dart:async';

import 'package:flutter/material.dart';
import 'package:timelay_health/app/app.dart';
import 'package:timelay_health/core/notifications/push_notification_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const TimelayHealthApp());
  unawaited(PushNotificationService.initialize());
}
