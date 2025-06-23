// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:trekkit_flutter/models/sh/mountain.dart';
// import 'package:trekkit_flutter/api/mountain_api.dart'; // 기존 산림청 명산 등산로 API
// import 'package:trekkit_flutter/api/mountain_trail_api.dart';     // 새로 추가할 산림청 등산로 API
// import 'package:trekkit_flutter/api/trekking_api.dart';     // 트레킹센터 좌표 API
// import 'package:trekkit_flutter/api/mountain_info_api.dart';    // 새로 추가할 산림청 산 정보 API

// class MountainService {
//   static Future<List<Mountain>> fetchMountainsWithAPIs() async {
//     // 1. 기본 명산 정보
//     final baseList = await MountainApi.fetchMountains(); // 기존 API (이름, 개요 등)

//     // 2. 트레킹센터 좌표
//     final coordMap = await TrekkingApi.fetchMountainCoords(); // 이름 → 위경도

//     // 3. 산림청 산 정보
//     final forestInfoMap = await MountainInfoApi.fetchMountainInfo(); // 이름 → 상세정보 map

//     // 4. 산림청 등산로 정보
//     final mountainNames = baseList.map((m) => m.name.trim()).toList(); // 공백 제거 후 이름 목록
//     final trailInfoMap = await MountainTrailApi.fetchTrails(mountainNames); // 이름 → 코스 URL, 이미지 등

//     // 5. 병합
//     List<Mountain> enrichedList = [];

//     String? findClosestTrailKey(String nameKey, Map<String, dynamic> trailMap) {
//           for (final key in trailMap.keys) {
//             if (key.contains(nameKey) || nameKey.contains(key)) {
//               return key;
//             }
//           }
//           return null;
//         }

//     for (final mountain in baseList) {
//       final nameKey = mountain.name.trim(); // 공백 제거해서 키로 사용

//       final trailKey = findClosestTrailKey(nameKey, trailInfoMap);
//       final trail = trailKey != null ? trailInfoMap[trailKey] : null;

//       String? safeStringFrom(dynamic value) {
//         if (value is String) return value;
//         return value?.toString();
//       }

//       final coord = coordMap[nameKey];
//       final forest = forestInfoMap[nameKey];
//       // final trail = trailInfoMap[nameKey];
//       final trailUrl = (trail?['trailInfoUrl'])?.toString() ?? '';
//       final trailImg = (trail?['trailImageUrl'])?.toString() ?? '';
//       final trailFile = (trail?['trailFileUrl'])?.toString() ?? '';
  

//       // 좌표 없으면 스킵해도 됨 (지도에 안 보일 거니까)
//       if (coord == null) continue;
    
//       // if (trail != null) {
//       //   print('✅ trail data for ${nameKey}: $trail');

//       //   mountain.trailInfoUrl = trail['trailInfoUrl']?.toString() ?? '';
//       //   mountain.trailImageUrl = trail['trailImageUrl']?.toString();
//       //   mountain.trailFileUrl = trail['trailFileUrl']?.toString();
//       // }      

//       enrichedList.add(
//         Mountain(
//           name: mountain.name,
//           latitude: coord['lat'] ?? 0.0,
//           longitude: coord['lng'] ?? 0.0,
//           region: coord['region'] ?? '',
//           overview: mountain.overview,
//           // height: forest?['mntihigh']?.toDouble(), // 산림청 고도 정보
//           height: double.tryParse(forest?['mntihigh']?.toString() ?? '0') ?? 0.0,
//           details: forest?['mntidetails'],
//           topReason: forest?['mntitop'],
//           subName: forest?['mntisname'],
//           transport: forest?['transport'],
//           tourismInfo: forest?['tourisminf'],
//           etccourse: forest?['etccourse'],
//           // trailInfoUrl: trail?['trailInfoUrl']?.toString() ?? '',
//           // trailImageUrl: trail?['trailImageUrl']?.toString() ?? '',
//           // trailFileUrl: trail?['trailFileUrl']?.toString() ?? '',
//           trailInfoUrl: safeStringFrom(trail?['trailInfoUrl']),
//           trailImageUrl: safeStringFrom(trail?['trailImageUrl']),
//           trailFileUrl: safeStringFrom(trail?['trailFileUrl']),
//           summary: forest?['mntisummary'],
//           listNo: forest?['mntilistno']?.toString(),
//         ),
//       );
//     }
//     return enrichedList;
//   }
// }
//   //   for (var mountain in baseList) {
//   //     final coord = coordMap[mountain.name];
//   //     if (coord != null) {
//   //       mountain.latitude = coord['lat'] ?? 0.0;
//   //       mountain.longitude = coord['lng'] ?? 0.0;
//   //       mountain.region = coord['region'] ?? '';
//   //     }

//   //     final forest = forestInfoMap[mountain.name];
//   //     if (forest != null) {
//   //       mountain.details = forest['details'] ?? mountain.details;
//   //       mountain.transport = forest['transport'] ?? mountain.transport;
//   //       mountain.tourismInfo = forest['tourisminf'] ?? mountain.tourismInfo;
//   //       mountain.etccourse = forest['etcCourse'] ?? mountain.etccourse;
//   //     }

//   //     final trail = trailInfoMap[mountain.name];
//   //     if (trail != null) {
//   //       mountain.trailInfoUrl = trail['trailInfoUrl'];
//   //       mountain.trailImageUrl = trail['trailImageUrl'];
//   //       mountain.trailFileUrl = trail['trailFileUrl'];
//   //     }
//   //   }

//   //   return baseList;
//   // }
// //}

//   //산림청 API와 통합
// //   static Future<List<Mountain>> fetchTop100WithFullInfo() async {
// //     final apiAList = await MountainApi.fetchMountains();
// //     final coordMap = await fetchCoordinates();

// //     for (var mountain in apiAList) {
// //       final coords = coordMap[mountain.name];
// //       if (coords != null) {
// //         mountain.applyCoordinates(coords['lat']!, coords['lng']!);
// //       }
// //     }

// //     return apiAList;
// //   }
// // }
