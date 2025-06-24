import 'package:trekkit_flutter/api/mountain_road_api.dart';
import 'package:trekkit_flutter/models/sh/mountain.dart';
import 'package:trekkit_flutter/api/mountain_api.dart'; // 기존 산림청 명산 등산로 API
import 'package:trekkit_flutter/api/mountain_trail_api.dart'; // 새로 추가할 산림청 등산로 API
import 'package:trekkit_flutter/api/trekking_api.dart'; // 트레킹센터 좌표 API
import 'package:trekkit_flutter/api/mountain_info_api.dart'; // 새로 추가할 산림청 산 정보 API
import 'package:trekkit_flutter/api/mountain_road_api.dart';

class MountainService {
  static Future<List<Mountain>> fetchMountainsWithAPIs() async {
    // 1. 기본 명산 정보
    final baseList = await MountainApi.fetchMountains(); // 기존 API (이름, 개요 등)

    // 2. 트레킹센터 좌표
    final coordMap = await TrekkingApi.fetchMountainCoords(); // 이름 → 위경도

    // 3. 산림청 산정보
    final forestInfoMap = await MountainInfoApi.fetchMountainInfo(); // 이름 → 상세정보 map
    print('산림청 산 정보 개수: ${forestInfoMap.length}'); // 디버깅용

    // 4. 산림청 등산로정보
    final mountainNames =
        baseList.map((m) => m.name.trim()).toList(); // 공백 제거 후 이름 목록
    final trailInfoMap = await MountainTrailApi.fetchTrails(
      mountainNames,
    ); // 이름 → 코스 URL, 이미지 등

    // 5. 산림청 명산등산로
    final roadsMap = await MountainRoadApi.fetchMountainRoads();
    
    // 6. 병합
    List<Mountain> enrichedList = [];

    String? findClosestTrailKey(String nameKey, Map<String, dynamic> trailMap) {
      for (final key in trailMap.keys) {
        if (key.contains(nameKey) || nameKey.contains(key)) {
          return key;
        }
      }
      return null;
    }

    for (final mountain in baseList) {
      final nameKey = mountain.name.trim(); // 공백 제거해서 키로 사용

      String? safeStringFrom(dynamic value) {
        if (value is String) return value;
        return value?.toString();
      }

      final coord = coordMap[nameKey];
      final forest = forestInfoMap[nameKey];
      final roads = roadsMap[nameKey];

      print('🔍 $nameKey: ${roads?['topReason']} (${roads?['topReason'].runtimeType})');

      enrichedList.add(
        Mountain(
          name: mountain.name,
          latitude: coord?['lat'] ?? 0.0,
          longitude: coord?['lng'] ?? 0.0,
          region: coord?['region'] ?? '',
          overview: mountain.overview,
          // height: forest?['mntihigh']?.toDouble(), // 산림청 고도 정보
          height: double.tryParse(forest?['mntihigh']?.toString() ?? '0') ?? 0.0,
          details: forest?['mntidetails'],
          summary: forest?['mntisummary'],
          transport: roads?['transport'],
          tourismInfo: roads?['tourismInfo'],
          etccourse: roads?['etccourse'],
          subName: roads?['subName'],
          topReason: roads?['topReason'],
        ),
      );
    }
    return enrichedList;
  }
}