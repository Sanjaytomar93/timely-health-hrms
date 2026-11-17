import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class DownloadSaveResult {
  const DownloadSaveResult({
    required this.path,
    required this.notified,
  });

  final String path;
  final bool notified;
}

class DownloadNotification {
  const DownloadNotification._();

  static const _channel = MethodChannel(
    'com.timelayhealth.timelay_health/downloads',
  );

  static Future<DownloadSaveResult?> savePdfAndNotify({
    required List<int> bytes,
    required String fileName,
  }) async {
    if (kIsWeb || !Platform.isAndroid) return null;
    try {
      final raw = await _channel.invokeMethod<dynamic>(
        'savePdfAndNotify',
        {
          'fileName': fileName,
          'bytes': Uint8List.fromList(bytes),
        },
      );
      if (raw is! Map) return null;
      final path = (raw['path'] as String?)?.trim() ?? '';
      if (path.isEmpty) return null;
      return DownloadSaveResult(
        path: path,
        notified: raw['notified'] == true,
      );
    } on MissingPluginException {
      return null;
    } on PlatformException {
      return null;
    } catch (_) {
      return null;
    }
  }
}
