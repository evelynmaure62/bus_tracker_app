import 'package:flutter/material.dart';
import 'package:location/location.dart';

class LocationService {
  final Location _location = Location();

  /// Requests location service and permission.
  /// Returns true if both are granted.
  Future<bool> requestPermission() async {
    bool serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) return false;
    }

    PermissionStatus permission = await _location.hasPermission();
    if (permission == PermissionStatus.denied) {
      permission = await _location.requestPermission();
      if (permission != PermissionStatus.granted) return false;
    }

    return true;
  }

  /// One-shot current location.
  Future<LocationData?> getCurrentLocation() async {
    try {
      return await _location.getLocation();
    } catch (e) {
      debugPrint('LocationService.getCurrentLocation error: $e');
      return null;
    }
  }

  /// Continuous location updates.
  Stream<LocationData> get locationStream => _location.onLocationChanged;
}
