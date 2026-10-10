import 'dart:async';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:timelay_health/firebase_options.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.android);
  }
}

class PushNotificationService {
  PushNotificationService._();

  static bool _ready = false;
  static Future<void>? _initializing;
  static String _token = '';
  static Future<String>? _fetchingToken;

  static Future<void> initialize() {
    return _initializing ??= _initialize();
  }

  static Future<void> _initialize() async {
    if (kIsWeb || !Platform.isAndroid) return;
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(options: DefaultFirebaseOptions.android);
      }
    } catch (_) {
      _initializing = null;
      return;
    }

    try {
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    } catch (_) {}

    try {
      FirebaseMessaging.instance.onTokenRefresh.listen((value) {
        final token = value.trim();
        if (token.isNotEmpty) _token = token;
      });
    } catch (_) {}

    try {
      await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      _ready = true;
      unawaited(currentToken());
    } catch (_) {
      _initializing = null;
    }
  }

  static Future<String> currentToken() async {
    if (_token.isNotEmpty) return _token;
    await initialize();
    if (!_ready) return '';
    if (_token.isNotEmpty) return _token;
    return _fetchingToken ??= _fetchToken().whenComplete(
      () => _fetchingToken = null,
    );
  }

  static Future<String> _fetchToken() async {
    for (var attempt = 0; attempt < 2; attempt++) {
      try {
        final token = await FirebaseMessaging.instance.getToken().timeout(
          const Duration(seconds: 8),
        );
        final value = token?.trim() ?? '';
        if (value.isNotEmpty) {
          _token = value;
          return value;
        }
      } catch (_) {}
    }
    return '';
  }

  static Future<void> deleteLocalToken() async {
    if (kIsWeb || !Platform.isAndroid) return;
    _token = '';
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(options: DefaultFirebaseOptions.android);
      }
      await FirebaseMessaging.instance.deleteToken();
    } catch (_) {}
  }
}
