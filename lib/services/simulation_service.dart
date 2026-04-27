import 'dart:async';

import '../models/bus.dart';

/// Simulates a bus moving along a predefined route by emitting [Bus] updates
/// on a fixed interval. Useful for demoing the tracking feature without a
/// real device location or a live Firebase connection.
class SimulationService {
  /// A loop of (lat, lng) waypoints around the Googleplex area.
  static const List<(double, double)> _route = [
    (37.4219, -122.0841),
    (37.4225, -122.0860),
    (37.4235, -122.0882),
    (37.4250, -122.0898),
    (37.4265, -122.0892),
    (37.4278, -122.0876),
    (37.4287, -122.0857),
    (37.4282, -122.0836),
    (37.4268, -122.0820),
    (37.4250, -122.0818),
    (37.4235, -122.0826),
    (37.4219, -122.0841),
  ];

  static const Duration _updateInterval = Duration(seconds: 2);

  /// Returns a broadcast stream that emits a new [Bus] position every
  /// [_updateInterval], cycling through [_route] indefinitely.
  Stream<Bus> simulatedBusStream(String busId) {
    int step = 0;
    late StreamController<Bus> controller;
    Timer? timer;

    void emit() {
      final (lat, lng) = _route[step % _route.length];
      step++;
      controller.add(Bus(
        id: busId,
        lat: lat,
        lng: lng,
        lastUpdated: DateTime.now(),
      ));
    }

    controller = StreamController<Bus>(
      onListen: () {
        emit(); // emit immediately so the map updates right away
        timer = Timer.periodic(_updateInterval, (_) => emit());
      },
      onCancel: () {
        timer?.cancel();
        timer = null;
      },
    );

    return controller.stream;
  }
}
