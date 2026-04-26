class Bus {
  final String id;
  final double lat;
  final double lng;
  final DateTime? lastUpdated;

  Bus({
    required this.id,
    required this.lat,
    required this.lng,
    this.lastUpdated,
  });

  factory Bus.fromMap(String id, Map<String, dynamic> data) {
    return Bus(
      id: id,
      lat: (data['lat'] as num).toDouble(),
      lng: (data['lng'] as num).toDouble(),
      lastUpdated: data['lastUpdated'] != null
          ? DateTime.fromMillisecondsSinceEpoch(data['lastUpdated'] as int)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'lat': lat,
      'lng': lng,
      if (lastUpdated != null) 'lastUpdated': lastUpdated!.millisecondsSinceEpoch,
    };
  }
}
