class Location {
  const Location({required this.lat, required this.lng});

  final double lat;
  final double lng;

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      lat: ((json['latitude'] ?? json['lat']) as num?)?.toDouble() ?? 0.0,
      lng: ((json['longitude'] ?? json['lng']) as num?)?.toDouble() ?? 0.0,
    );
  }
}
