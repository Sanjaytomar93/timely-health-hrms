import 'package:flutter/foundation.dart';

/// Debug-only logging. No-op in release/profile.
abstract final class AppLog {
  static void d(Object? message) {
    if (kDebugMode) debugPrint('$message');
  }
}
