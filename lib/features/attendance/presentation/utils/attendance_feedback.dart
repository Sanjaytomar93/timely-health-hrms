import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:timelay_health/core/logging/app_log.dart';

class AttendanceFeedback {
  AttendanceFeedback._();

  static final FlutterTts _tts = FlutterTts();
  static final AudioPlayer _sfx = AudioPlayer();
  static bool _ttsReady = false;
  static bool _speaking = false;
  static int _session = 0;

  static bool get isSpeaking => _speaking;

  static Future<void> _ensureTts() async {
    if (_ttsReady) return;
    try {
      await _tts.setSharedInstance(true);
      await _tts.awaitSpeakCompletion(true);
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.15);
      await _tts.setSpeechRate(0.45);
      await _selectFemaleVoice();
      _ttsReady = true;
    } catch (e) {
      AppLog.d('[AttendanceFeedback] TTS init failed: $e');
    }
  }

  static Future<void> _selectFemaleVoice() async {
    try {
      await _tts.setLanguage('en-IN');
      final raw = await _tts.getVoices;
      if (raw is! List) return;

      final voices = raw
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();

      const femaleHints = [
        'female',
        'woman',
        'zira',
        'samantha',
        'karen',
        'moira',
        'tessa',
        'veena',
        'raveena',
        'google uk english female',
        'en-in-x-ena',
      ];

      Map<String, dynamic>? pick;
      for (final v in voices) {
        final name = '${v['name'] ?? ''}'.toLowerCase();
        final locale = '${v['locale'] ?? ''}'.toLowerCase();
        if (femaleHints.any((h) => name.contains(h))) {
          pick = v;
          if (locale.contains('en-in') || locale.contains('en_in')) break;
        }
      }
      if (pick == null) {
        for (final v in voices) {
          final locale = '${v['locale'] ?? ''}'.toLowerCase();
          if (locale.contains('en-in') || locale.contains('en_in')) {
            pick = v;
            break;
          }
        }
      }
      pick ??= voices.isNotEmpty ? voices.first : null;

      if (pick != null) {
        final name = pick['name']?.toString();
        final locale = pick['locale']?.toString();
        if (name != null &&
            name.isNotEmpty &&
            locale != null &&
            locale.isNotEmpty) {
          await _tts.setVoice({'name': name, 'locale': locale});
        } else if (locale != null && locale.isNotEmpty) {
          await _tts.setLanguage(locale.replaceAll('_', '-'));
        }
      }
    } catch (e) {
      AppLog.d('[AttendanceFeedback] voice select failed: $e');
    }
  }

  static Future<void> playShutterSound() async {
    try {
      final wav = _buildToneWav(
        freqs: const [1500, 1200],
        durationsMs: const [40, 35],
        volume: 0.35,
        square: true,
      );
      await _sfx.stop();
      await _sfx.play(BytesSource(wav, mimeType: 'audio/wav'));
    } catch (e) {
      AppLog.d('[AttendanceFeedback] shutter failed: $e');
    }
  }

  static Future<void> playSuccessSound() async {
    final session = _session;
    try {
      if (session != _session) return;
      final wav = _buildToneWav(
        freqs: const [523.25, 659.25, 783.99, 1046.50],
        durationsMs: const [110, 110, 110, 160],
        volume: 0.28,
        square: false,
      );
      if (session != _session) return;
      await _sfx.stop();
      if (session != _session) return;
      await _sfx.play(BytesSource(wav, mimeType: 'audio/wav'));
    } catch (e) {
      AppLog.d('[AttendanceFeedback] success sfx failed: $e');
    }
  }

  static Future<void> speakCheckInSuccess(String name) {
    final n = name.trim().isEmpty ? 'there' : name.trim();
    return _speak(
      'Hello $n! You have successfully checked in. Have a great day!',
    );
  }

  static Future<void> speakCheckOutSuccess(String name) {
    final n = name.trim().isEmpty ? 'there' : name.trim();
    return _speak('Hello $n! You have successfully checked out. Thank you!');
  }

  static Future<void> _speak(String message, {int retries = 5}) async {
    final session = _session;
    await _ensureTts();
    if (session != _session) return;

    _speaking = true;
    try {
      for (var i = 0; i < retries; i++) {
        if (session != _session) return;
        try {
          if (i > 0) {
            await Future<void>.delayed(Duration(milliseconds: 180 * i));
            if (session != _session) return;
            await _selectFemaleVoice();
            if (session != _session) return;
          }
          try {
            await _tts.stop();
          } catch (_) {}
          if (session != _session) return;
          final result = await _tts.speak(message);
          if (session != _session) {
            try {
              await _tts.stop();
            } catch (_) {}
            return;
          }
          if (result == 1 || result == true) return;
        } catch (e) {
          if (session != _session) return;
          AppLog.d('[AttendanceFeedback] speak retry $i: $e');
        }
      }
    } finally {
      if (session == _session) {
        _speaking = false;
      }
    }
  }

  static Future<void> stop() async {
    _session++;
    _speaking = false;
    try {
      await _tts.stop();
    } catch (_) {}
    try {
      await _sfx.stop();
    } catch (_) {}
  }

  static Uint8List _buildToneWav({
    required List<double> freqs,
    required List<int> durationsMs,
    required double volume,
    required bool square,
  }) {
    const sampleRate = 22050;
    final samples = <int>[];
    final amp = (volume.clamp(0.0, 1.0) * 30000).round();

    for (var i = 0; i < freqs.length; i++) {
      final freq = freqs[i];
      final n = (sampleRate * durationsMs[i] / 1000).round();
      for (var s = 0; s < n; s++) {
        final t = s / sampleRate;
        final phase = 2 * math.pi * freq * t;
        final raw = square
            ? (math.sin(phase) >= 0 ? 1.0 : -1.0)
            : math.sin(phase);
        final env = (s < 40) ? s / 40 : (s > n - 60 ? (n - s) / 60 : 1.0);
        samples.add((raw * amp * env.clamp(0.0, 1.0)).round());
      }
      samples.addAll(List.filled(sampleRate ~/ 80, 0));
    }

    final dataSize = samples.length * 2;
    final bytes = BytesBuilder();
    void u32(int v) {
      bytes.add([v & 255, (v >> 8) & 255, (v >> 16) & 255, (v >> 24) & 255]);
    }

    void u16(int v) {
      bytes.add([v & 255, (v >> 8) & 255]);
    }

    bytes.add('RIFF'.codeUnits);
    u32(36 + dataSize);
    bytes.add('WAVE'.codeUnits);
    bytes.add('fmt '.codeUnits);
    u32(16);
    u16(1);
    u16(1);
    u32(sampleRate);
    u32(sampleRate * 2);
    u16(2);
    u16(16);
    bytes.add('data'.codeUnits);
    u32(dataSize);
    for (final s in samples) {
      final v = s.clamp(-32768, 32767);
      u16(v < 0 ? v + 65536 : v);
    }
    return bytes.toBytes();
  }
}
