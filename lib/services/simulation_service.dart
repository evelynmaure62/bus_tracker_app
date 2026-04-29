import 'dart:async';

import '../models/bus.dart';

class SimulationService {
  /// SFA Day Shuttle route:
  /// Hall 20 Parking Lot -> Steen Library -> Cole STEM Building -> loop back.
  static const List<(double, double)> _route = [
    (31.624617434220244, -94.64281231503264), // Hall 20 parking lot
    (31.623142428784288, -94.64281900316561), // Turn off E College into Hall 20 lot
    (31.623085478294485, -94.64423019921927), // Turn onto E College St
    (31.62047141343814, -94.64461811092345), // Turn out of Steen lot onto Wilson Dr
    (31.620220823824347, -94.6456480833873), // Steen Library
    (31.619571565837422, -94.64495251755872), // Turn into parking lot behind Steen
    (31.61615434383252, -94.64534042926736), // Turn onto Wilson Dr
    (31.61609560413906, -94.64879441151513), // Turn onto E Starr Ave
    (31.618776326481484, -94.64888714288159), // Cole STEM Building
  ];

  /// Smaller interval = smoother movement.
  static const Duration _updateInterval = Duration(milliseconds: 250);

  /// Number of tiny movements between each real route point.
  /// Higher = smoother but slower between points.
  static const int _stepsBetweenPoints = 20;

  Stream<Bus> simulatedBusStream(String busId) {
    int routeIndex = 0;
    int stepIndex = 0;

    late StreamController<Bus> controller;
    Timer? timer;

    void emit() {
      final currentPoint = _route[routeIndex];
      final nextPoint = _route[(routeIndex + 1) % _route.length];

      final progress = stepIndex / _stepsBetweenPoints;

      final lat = currentPoint.$1 + (nextPoint.$1 - currentPoint.$1) * progress;
      final lng = currentPoint.$2 + (nextPoint.$2 - currentPoint.$2) * progress;

      controller.add(
        Bus(
          id: busId,
          lat: lat,
          lng: lng,
          lastUpdated: DateTime.now(),
        ),
      );

      stepIndex++;

      if (stepIndex > _stepsBetweenPoints) {
        stepIndex = 0;
        routeIndex = (routeIndex + 1) % _route.length;
      }
    }

    controller = StreamController<Bus>(
      onListen: () {
        emit();
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