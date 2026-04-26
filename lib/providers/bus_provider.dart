import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/bus.dart';
import '../services/firebase_service.dart';

class BusProvider extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();

  final Map<String, Bus> _buses = {};
  final Map<String, StreamSubscription<Bus>> _subscriptions = {};

  bool _isLoading = true;
  String? _error;

  Map<String, Bus> get buses => Map.unmodifiable(_buses);
  bool get isLoading => _isLoading;
  String? get error => _error;

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

  @override
  void dispose() {
    for (final sub in _subscriptions.values) {
      sub.cancel();
    }
    super.dispose();
  }
}
