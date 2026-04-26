import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../models/bus.dart';
import '../providers/bus_provider.dart';
import '../widgets/bus_marker.dart';

const _trackedBusId = 'bus1';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;

  static const _defaultPosition = LatLng(37.4279, -122.0857);

  @override
  void initState() {
    super.initState();
    context.read<BusProvider>().listenToBus(_trackedBusId);
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    final s = dt.second.toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BusProvider>(
      builder: (context, busProvider, _) {
        if (busProvider.error != null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Bus Tracker')),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${busProvider.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<BusProvider>().listenToBus(_trackedBusId),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        final buses = busProvider.buses;
        final firstBus = buses.values.isNotEmpty ? buses.values.first : null;
        final cameraTarget = firstBus != null
            ? LatLng(firstBus.lat, firstBus.lng)
            : _defaultPosition;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Bus Tracker'),
            actions: [
              if (firstBus?.lastUpdated != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Center(
                    child: Text(
                      'Updated: ${_formatTime(firstBus!.lastUpdated!)}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ),
            ],
          ),
          body: Stack(
            children: [
              if (busProvider.isLoading)
                const Center(child: CircularProgressIndicator())
              else
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: cameraTarget,
                    zoom: 18,
                  ),
                  onMapCreated: (controller) {
                    _mapController = controller;
                  },
                  markers: buses.values.map(BusMarker.fromBus).toSet(),
                ),
              if (firstBus != null)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: _BusInfoSheet(bus: firstBus),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _BusInfoSheet extends StatelessWidget {
  final Bus bus;

  const _BusInfoSheet({required this.bus});

  String _formatDateTime(DateTime dt) {
    final date = '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    final s = dt.second.toString().padLeft(2, '0');
    return '$date $h:$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        boxShadow: const [BoxShadow(blurRadius: 8, color: Colors.black26)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.directions_bus, color: Colors.blue),
              const SizedBox(width: 8),
              Text(
                bus.id.toUpperCase(),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text('Active', style: TextStyle(color: Colors.green)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Lat: ${bus.lat.toStringAsFixed(6)},  Lng: ${bus.lng.toStringAsFixed(6)}',
          ),
          if (bus.lastUpdated != null)
            Text('Last updated: ${_formatDateTime(bus.lastUpdated!)}'),
        ],
      ),
    );
  }
}
