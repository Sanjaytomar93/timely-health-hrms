import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

class LocationFailure implements Exception {
  LocationFailure(this.message);
  final String message;

  @override
  String toString() => message;
}

class LocationHelper {
  LocationHelper._();

  static Position get _fallbackPosition {
    return Position(
      latitude: 28.6139,
      longitude: 77.2090,
      timestamp: DateTime.now(),
      accuracy: 0,
      altitude: 0,
      altitudeAccuracy: 0,
      heading: 0,
      headingAccuracy: 0,
      speed: 0,
      speedAccuracy: 0,
      isMocked: true,
    );
  }

  static bool get _allowFallback {
    if (kDebugMode) return true;
    if (!kIsWeb && Platform.isIOS) return true;
    return false;
  }

  static Future<Position> getFastPosition({
    bool allowFallback = true,
  }) async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (allowFallback && _allowFallback) return _fallbackPosition;
        throw LocationFailure(
          'Location services are off. Please turn on GPS and try again.',
        );
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (allowFallback && _allowFallback) return _fallbackPosition;
        throw LocationFailure(
          permission == LocationPermission.deniedForever
              ? 'Location permission permanently denied. Enable it from Settings.'
              : 'Location permission denied. Allow location access to continue.',
        );
      }

      if (permission == LocationPermission.unableToDetermine) {
        if (allowFallback && _allowFallback) return _fallbackPosition;
        throw LocationFailure(
          'Unable to determine location permission. Please try again.',
        );
      }

      final last = await Geolocator.getLastKnownPosition();
      if (last != null) {
        final age = DateTime.now().difference(last.timestamp);
        if (age.inMinutes <= 8) return last;
      }

      try {
        return await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.low,
            timeLimit: Duration(seconds: 4),
          ),
        );
      } on TimeoutException {
        if (last != null) return last;
        if (allowFallback && _allowFallback) return _fallbackPosition;
        throw LocationFailure('Could not get location. Please try again.');
      }
    } on LocationFailure {
      rethrow;
    } on PermissionDeniedException catch (e) {
      throw LocationFailure(
        e.message?.isNotEmpty == true
            ? e.message!
            : 'Location permission denied. Allow location access to continue.',
      );
    } on PermissionRequestInProgressException {
      throw LocationFailure(
        'Location permission request already in progress. Please wait.',
      );
    } catch (_) {
      try {
        final last = await Geolocator.getLastKnownPosition();
        if (last != null) return last;
      } catch (_) {}
      if (allowFallback && _allowFallback) return _fallbackPosition;
      throw LocationFailure(
        'Could not get location. Allow location access and try again.',
      );
    }
  }

  static Future<Position> getCurrentPosition({
    bool allowFallback = true,
    bool precise = false,
  }) async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (allowFallback && _allowFallback) return _fallbackPosition;
        throw LocationFailure(
          'Location services are off. Please turn on GPS and try again.',
        );
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (allowFallback && _allowFallback) return _fallbackPosition;
        throw LocationFailure(
          permission == LocationPermission.deniedForever
              ? 'Location permission permanently denied. Enable it from Settings.'
              : 'Location permission denied. Allow location access to continue.',
        );
      }

      if (permission == LocationPermission.unableToDetermine) {
        if (allowFallback && _allowFallback) return _fallbackPosition;
        throw LocationFailure(
          'Unable to determine location permission. Please try again.',
        );
      }

      try {
        return await Geolocator.getCurrentPosition(
          locationSettings: LocationSettings(
            accuracy: precise
                ? LocationAccuracy.best
                : LocationAccuracy.low,
            distanceFilter: 0,
            timeLimit: Duration(seconds: precise ? 15 : 6),
          ),
        );
      } on TimeoutException {
        final last = await Geolocator.getLastKnownPosition();
        final lastIsPreciseEnough =
            last != null && (!precise || last.accuracy <= 20);
        if (lastIsPreciseEnough) return last!;
        if (allowFallback && _allowFallback) return _fallbackPosition;
        throw LocationFailure(
          'Could not get location. Please try again.',
        );
      }
    } on LocationFailure {
      rethrow;
    } on PermissionDeniedException catch (e) {
      throw LocationFailure(
        e.message?.isNotEmpty == true
            ? e.message!
            : 'Location permission denied. Allow location access to continue.',
      );
    } on PermissionRequestInProgressException {
      throw LocationFailure(
        'Location permission request already in progress. Please wait.',
      );
    } catch (_) {
      try {
        final last = await Geolocator.getLastKnownPosition();
        if (last != null) return last;
      } catch (_) {}
      if (allowFallback && _allowFallback) return _fallbackPosition;
      throw LocationFailure(
        'Could not get location. Allow location access and try again.',
      );
    }
  }

  static Future<bool> openAppSettings() => Geolocator.openAppSettings();
}
