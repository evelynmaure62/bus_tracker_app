import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:location/location.dart';

import '../models/bus.dart';
import '../services/firebase_service.dart';
import '../services/location_service.dart';
import '../services/simulation_service.dart';

class BusProvider extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  final LocationService _locationService = LocationService();
  final SimulationService _simulationService = SimulationService();

  final Map<String, Bus> _buses = {};
  final Map<String, StreamSubscription<Bus>> _subscriptions = {};
  StreamSubscription<LocationData>? _locationSubscription;
  StreamSubscription<Bus>? _simulationSubscription;

  bool _isLoading = true;
  String? _error;

  bool _isTrackingLocation = false;
  String? _locationError;

  bool _isSimulating = false;

  Map<String, Bus> get buses => Map.unmodifiable(_buses);
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isTrackingLocation => _isTrackingLocation;
  String? get locationError => _locationError;
  bool get isSimulating => _isSimulating;

  /// Start listening to a bus node in Firebase.
  /// Does nothing if already subscribed to [busId].
  void listenToBus(String busId) {
    if (_subscriptions.containsKey(busId)) return;

    _subscriptions[busId] = _firebaseService.busStream(busId).listen(
      (bus) {
        _buses[bus.id] = bus;
        _isLoading = false;
        _error = null;
        notifyListeners();
      },
      onError: (Object e) {
        _error = e.toString();
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  /// Stop listening to a specific bus and remove its cached data.
  void stopListening(String busId) {
    _subscriptions.remove(busId)?.cancel();
    _buses.remove(busId);
    notifyListeners();
  }

  /// Request GPS permission and start pushing location updates to Firebase
  /// under [busId]. Does nothing if already tracking.
  Future<void> startTracking(String busId) async {
    if (_isTrackingLocation) return;

    final granted = await _locationService.requestPermission();
    if (!granted) {
      _locationError = 'Location permission denied.';
      notifyListeners();
      return;
    }

    _locationError = null;
    _isTrackingLocation = true;
    notifyListeners();

    _locationSubscription = _locationService.locationStream.listen(
      (LocationData data) async {
        final lat = data.latitude;
        final lng = data.longitude;
        if (lat == null || lng == null) return;
        try {
          await _firebaseService.updateBusLocation(busId, lat, lng);
        } catch (e) {
          debugPrint('BusProvider.startTracking: Firebase update failed: $e');
        }
      },
      onError: (Object e) {
        _locationError = e.toString();
        _isTrackingLocation = false;
        notifyListeners();
      },
      onDone: () {
        _isTrackingLocation = false;
        notifyListeners();
      },
    );
  }

  /// Stop pushing GPS updates to Firebase.
  void stopTracking() {
    _locationSubscription?.cancel();
    _locationSubscription = null;
    _isTrackingLocation = false;
    notifyListeners();
  }

  /// Start simulating bus movement along a predefined route.
  /// Stops any active real-GPS tracking before starting.
  /// Does nothing if simulation is already running.
  void startSimulation(String busId) {
    if (_isSimulating) return;

    // Stop real GPS tracking so the two sources don't fight each other.
    stopTracking();

    _isSimulating = true;
    _isLoading = false;
    _error = null;
    notifyListeners();

    _simulationSubscription =
        _simulationService.simulatedBusStream(busId).listen(
      (bus) {
        _buses[bus.id] = bus;
        notifyListeners();
      },
      onError: (Object e) {
        debugPrint('BusProvider.startSimulation: simulation error: $e');
        _isSimulating = false;
        notifyListeners();
      },
    );
  }

  /// Stop the simulation and remove the simulated bus from the map.
  void stopSimulation(String busId) {
    _simulationSubscription?.cancel();
    _simulationSubscription = null;
    _isSimulating = false;
    _buses.remove(busId);
    _isLoading = true;
    notifyListeners();
  }

  @override
  void dispose() {
    for (final sub in _subscriptions.values) {
      sub.cancel();
    }
    _locationSubscription?.cancel();
    _simulationSubscription?.cancel();
    super.dispose();
  }
}
