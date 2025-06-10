class Mountain {
  final int id;
  final String name;
  final double latitude;
  final double longitude;
  final String location; // 위치 설명
  final String imageUrl;
  final double distance;
  final double height;
  final String description;

  Mountain({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.location,
    required this.imageUrl,
    required this.distance,
    required this.height,
    required this.description,
  });

  factory Mountain.fromJson(Map<String, dynamic> json) {
    // print('📦 Mountain JSON: $json');
    return Mountain(
      // id: json['id'] ?? 0,
      // name: json['name'] ?? '이름없음',
      // // latitude: double.tryParse(json['latitude'].toString()) ?? 0.0,
      // // longitude: double.tryParse(json['longitude'].toString()) ?? 0.0,
      // latitude: double.tryParse(json['yCoord'].toString()) ?? 0.0,
      // longitude: double.tryParse(json['xCoord'].toString()) ?? 0.0,
      // location: json['location'] ?? '',
      // imageUrl: json['imageUrl'] ?? '',
      // distance: json['distance'] ?? 0.0,
      // height: json['height']?.toDouble() ?? 0.0,
      // description: json['description'] ?? '',
      id: 0, // id는 없으니 기본값
      name: json['mntnm'] ?? '이름없음',
      latitude: double.tryParse(json['lat']?.toString() ?? '') ?? 0.0,
      longitude: double.tryParse(json['lon']?.toString() ?? '') ?? 0.0,
      location: json['mntiadd'] ?? '위치정보없음',
      imageUrl: '', // API에 이미지 없으므로 빈 값
      distance: 0.0,
      height: 0.0,
      description: json['details'] ?? json['aeatreason'] ?? '설명 없음',
    );
  }
}