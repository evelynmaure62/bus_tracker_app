import 'package:firebase_database/firebase_database.dart';

import '../models/bus.dart';

class FirebaseService {
  final DatabaseReference _ref = FirebaseDatabase.instance.ref();

  /// Listens to real-time updates for a single bus node.
  Stream<Bus> busStream(String busId) {
    return _ref.child(busId).onValue.where((event) => event.snapshot.value != null).map((event) {
      final data = Map<String, dynamic>.from(event.snapshot.value as Map);
      return Bus.fromMap(busId, data);
    });
  }

  /// Writes the current location of a bus to Firebase.
  Future<void> updateBusLocation(String busId, double lat, double lng) async {
    await _ref.child(busId).set({
      'lat': lat,
      'lng': lng,
      'lastUpdated': DateTime.now().millisecondsSinceEpoch,
    });
  }
}
