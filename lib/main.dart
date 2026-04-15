import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MapScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? mapController;

  final database = FirebaseDatabase.instance.ref();

  LatLng currentPosition = const LatLng(37.4279, -122.0857);

  @override
  void initState() {
    super.initState();
    listenToBus();
    sendFakeBusData(); // remove later when using real GPS
  }

  // 📡 Listen to Firebase updates
  void listenToBus() {
    database.child("bus1").onValue.listen((event) {
      if (event.snapshot.value == null) return;

      final data = Map<String, dynamic>.from(event.snapshot.value as Map);

      double lat = data["lat"];
      double lng = data["lng"];

      LatLng newPosition = LatLng(lat, lng);

      setState(() {
        currentPosition = newPosition;
      });

      mapController?.animateCamera(
        CameraUpdate.newLatLng(newPosition),
      );
    });
  }

  // 🧪 Fake bus movement (for testing)
  void sendFakeBusData() {
    Timer.periodic(const Duration(seconds: 2), (timer) {
      double lat = 37.4279 + (timer.tick * 0.0001);
      double lng = -122.0857 + (timer.tick * 0.0001);

      database.child("bus1").set({
        "lat": lat,
        "lng": lng,
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bus Tracker')),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: currentPosition,
          zoom: 18,
        ),
        onMapCreated: (controller) {
          mapController = controller;
        },
        markers: {
          Marker(
            markerId: const MarkerId('bus'),
            position: currentPosition,
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueRed,
            ),
          ),
        },
      ),
    );
  }
}