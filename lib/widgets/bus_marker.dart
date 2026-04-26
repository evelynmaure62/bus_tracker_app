import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../models/bus.dart';

class BusMarker {
  /// Creates a [Marker] from a [Bus] instance.
  static Marker fromBus(Bus bus) {
    return Marker(
      markerId: MarkerId(bus.id),
      position: LatLng(bus.lat, bus.lng),
      infoWindow: InfoWindow(title: bus.id.toUpperCase()),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
    );
  }
}
