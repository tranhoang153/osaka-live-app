import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class LocationSyncService {
  StreamSubscription<Position>? _positionSubscription;
  bool _starting = false;

  Future<void> start({
    required void Function(Position position) onPosition,
  }) async {
    if (_starting || _positionSubscription != null) {
      return;
    }

    _starting = true;
    try {
      final ready = await _ensurePermissionAndService();
      if (!ready) {
        return;
      }

      await _pushCurrentPosition(onPosition);
      await _startPositionStream(onPosition);
    } catch (e) {
      debugPrint('LocationSyncService start failed: $e');
    } finally {
      _starting = false;
    }
  }

  Future<void> stop() async {
    await _positionSubscription?.cancel();
    _positionSubscription = null;
  }

  Future<bool> _ensurePermissionAndService() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      return false;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    return permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
  }

  Future<void> _pushCurrentPosition(
    void Function(Position position) onPosition,
  ) async {
    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );
    onPosition(position);
  }

  Future<void> _startPositionStream(
    void Function(Position position) onPosition,
  ) async {
    _positionSubscription ??= Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 50,
      ),
    ).listen(
      onPosition,
      onError: (error) {
        debugPrint('Location stream error: $error');
      },
    );
  }
}
