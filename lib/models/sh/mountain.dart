class Mountain {
  final String name;
  final String overview;
  final double height;

  double latitude;
  double longitude;

  String? trailImageUrl;
  String? trailFileUrl;
  String? trailInfoUrl;
  
  final String? region;
  final String? details;
  final String? topReason;
  final String? subName;
  final String? tourismInfo;
  final String? transport;
  final String? etccourse;
  
  final String? summary;
  final String? listNo;

  Mountain({
    required this.name,
    required this.overview,
    required this.height,
    this.latitude = 0.0,
    this.longitude = 0.0,
    this.region,
    this.details,
    this.topReason,
    this.subName,
    this.tourismInfo,
    this.transport,
    this.etccourse,
    this.trailImageUrl,
    this.trailFileUrl,
    this.trailInfoUrl,
    this.summary,
    this.listNo,
  });

  factory Mountain.fromAApi(Map<String, dynamic> json) {
    return Mountain(
      name: json['mntnm'] ?? '',
      overview: json['overview'] ?? '',
      height: double.tryParse(json['mntheight']?.toString() ?? '0') ?? 0.0,
      region: json['areanm'],
    );
  }

  void applyCoordinates(double lat, double lng) {
    latitude = lat;
    longitude = lng;
  }
}