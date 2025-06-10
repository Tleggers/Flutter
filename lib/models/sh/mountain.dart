class Mountain {
  final int id;
  final String name;
  final double lat;
  final double lng;
  final String imageUrl;
  final double distance;

  Mountain({
    required this.id,
    required this.name,
    required this.lat,
    required this.lng,
    required this.imageUrl,
    required this.distance,
  });

  factory Mountain.fromJson(Map<String, dynamic> json) {
    return Mountain(
      id: json['id'],
      name: json['name'],
      lat: json['lat'],
      lng: json['lng'],
      imageUrl: json['imageUrl'],
      distance: json['distance'] ?? 0.0,
    );
  }
}