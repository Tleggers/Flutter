import 'package:trekkit_flutter/services/sh/coordinate_service.dart';

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

  // factory Mountain.fromJson(Map<String, dynamic> json) {
  //   // print('📦 Mountain JSON: $json');
  //   return Mountain(
  //     // id: json['id'] ?? 0,
  //     // name: json['name'] ?? '이름없음',
  //     // // latitude: double.tryParse(json['latitude'].toString()) ?? 0.0,
  //     // // longitude: double.tryParse(json['longitude'].toString()) ?? 0.0,
  //     // latitude: double.tryParse(json['yCoord'].toString()) ?? 0.0,
  //     // longitude: double.tryParse(json['xCoord'].toString()) ?? 0.0,
  //     // location: json['location'] ?? '',
  //     // imageUrl: json['imageUrl'] ?? '',
  //     // distance: json['distance'] ?? 0.0,
  //     // height: json['height']?.toDouble() ?? 0.0,
  //     // description: json['description'] ?? '',
  //     id: 0, // 없으므로 기본값
  //     name: json['mntnm'] ?? '이름없음',
  //     latitude: 0.0, // 좌표 없음
  //     longitude: 0.0, // 좌표 없음
  //     location: json['areanm'] ?? '',
  //     imageUrl: '', // flashurl이나 videourl 활용 가능
  //     distance: 0.0,
  //     height: double.tryParse(json['mntheight']?.toString() ?? '0') ?? 0.0,
  //     description: json['details'] ?? '',
  //   );
  // }

  factory Mountain.fromJson(Map<String, dynamic> json) {
  String name = json['mntnm'] ?? '이름없음';
  
  // 기본 API 좌표
  double lat = double.tryParse(json['lat']?.toString() ?? '') ?? 0.0;
  double lng = double.tryParse(json['lng']?.toString() ?? '') ?? 0.0;

  // 좌표 없으면 CSV에서 보완
  if (lat == 0.0 && lng == 0.0) {
    final fallback = CoordinateService.getCoordinatesFor(name);
    if (fallback != null) {
      lat = fallback[0];
      lng = fallback[1];
    }
  }

  return Mountain(
    id: json['id'] ?? 0,
    name: name,
    latitude: lat,
    longitude: lng,
    location: json['areanm'] ?? '',
    imageUrl: json['imageUrl'] ?? '',
    distance: 0.0,
    height: double.tryParse(json['mntheight']?.toString() ?? '0') ?? 0.0,
    description: json['details'] ?? '',
  );
  }
}