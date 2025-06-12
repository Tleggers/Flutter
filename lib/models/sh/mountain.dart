class Mountain {
  final String name;
  final String overview;
  final double height;
  final String imageUrl;
  double latitude;
  double longitude;

  Mountain({
    required this.name,
    required this.overview,
    required this.height,
    required this.imageUrl,
    this.latitude = 0.0,
    this.longitude = 0.0,
  });

  factory Mountain.fromAApi(Map<String, dynamic> json) {
    return Mountain(
      name: json['mntnm'] ?? '',
      overview: json['overview'] ?? '',
      height: double.tryParse(json['mntheight']?.toString() ?? '0') ?? 0.0,
      imageUrl: json['imageUrl'] ?? '',
    );
  }

  void applyCoordinates(double lat, double lng) {
    latitude = lat;
    longitude = lng;
  }
}
