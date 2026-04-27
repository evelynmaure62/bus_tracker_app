import 'package:flutter_test/flutter_test.dart';

import 'package:bus_tracker_app/models/bus.dart';

void main() {
  group('Bus model', () {
    test('fromMap creates Bus with correct values', () {
      final bus = Bus.fromMap('bus1', {'lat': 37.4279, 'lng': -122.0857});
      expect(bus.id, 'bus1');
      expect(bus.lat, 37.4279);
      expect(bus.lng, -122.0857);
      expect(bus.lastUpdated, isNull);
    });

    test('fromMap parses lastUpdated timestamp', () {
      final ts = DateTime(2024, 1, 15, 10, 30).millisecondsSinceEpoch;
      final bus = Bus.fromMap('bus1', {'lat': 0.0, 'lng': 0.0, 'lastUpdated': ts});
      expect(bus.lastUpdated, isNotNull);
      expect(bus.lastUpdated!.millisecondsSinceEpoch, ts);
    });

    test('toMap returns correct map without lastUpdated', () {
      final bus = Bus(id: 'bus1', lat: 37.4279, lng: -122.0857);
      final map = bus.toMap();
      expect(map['lat'], 37.4279);
      expect(map['lng'], -122.0857);
      expect(map.containsKey('lastUpdated'), isFalse);
    });

    test('toMap includes lastUpdated when set', () {
      final now = DateTime(2024, 6, 1);
      final bus = Bus(id: 'bus1', lat: 1.0, lng: 2.0, lastUpdated: now);
      final map = bus.toMap();
      expect(map['lastUpdated'], now.millisecondsSinceEpoch);
    });

    test('fromMap handles integer lat/lng', () {
      final bus = Bus.fromMap('bus2', {'lat': 37, 'lng': -122});
      expect(bus.lat, 37.0);
      expect(bus.lng, -122.0);
    });
  });
}

