import 'package:trekkit_flutter/api/mountain_road_api.dart';
import 'package:trekkit_flutter/models/sh/mountain.dart';
import 'package:trekkit_flutter/api/mountain_api.dart'; // 기존 산림청 명산 등산로 API
import 'package:trekkit_flutter/api/mountain_trail_api.dart'; // 새로 추가할 산림청 등산로 API
import 'package:trekkit_flutter/api/trekking_api.dart'; // 트레킹센터 좌표 API
import 'package:trekkit_flutter/api/mountain_info_api.dart'; // 새로 추가할 산림청 산 정보 API

class MountainService {
  static Future<List<Mountain>> fetchMountainsWithAPIs() async {
    // 1. 기본 명산 정보
    final baseList = await MountainApi.fetchMountains(); // 기존 API (이름, 개요 등)
    print('기본 명산 정보 개수: ${baseList.length}');

    // 2. 트레킹센터 좌표
    final coordMap = await TrekkingApi.fetchMountainCoords(); // 이름 → 위경도
    print('트레킹센터 좌표 개수: ${coordMap.length}');

    // 3. 산림청 산정보
    final forestInfoMap =
        await MountainInfoApi.fetchMountainInfo(); // 이름 → 상세정보 map
    print('산림청 산 정보 개수: ${forestInfoMap.length}'); // 디버깅용

    // 4. 산림청 등산로정보
    Map<String, Map<String, String>> trailInfoMap = {};
    try{
    final mountainNames = baseList.map((m) => m.name.trim()).toList(); // 공백 제거 후 이름 목록
    final trailInfoMap = await MountainTrailApi.fetchTrails(mountainNames); // 이름 → 코스 URL, 이미지 등
    print('📋 Trail API 결과 산 수: ${trailInfoMap.length}'
    );
    } catch (e) {
      print('MountainTrailAPI 오류: $e');
    } 
    // 5. 산림청 명산등산로
    final roadsMap = await MountainRoadApi.fetchMountainRoads();
    print('산림청 등산로 정보 개수: ${roadsMap.length}');

    // 6. 병합
    List<Mountain> enrichedList = [];

    String normalizeName(String name) {
      return name.replaceAll(RegExp(r'[^\uAC00-\uD7A3a-zA-Z0-9]'), '');
    }

    String? findBestMatch(String nameKey, Map<String, dynamic> map) {
      final cleanedKey = normalizeName(nameKey);
      for (final key in map.keys) {
        if (normalizeName(key) == cleanedKey) {
          return key;
        }
      }
      return null;
    }

    String? safeStringFrom(dynamic value) {
      if (value is String) return value;
      return value?.toString();
    }

    for (final mountain in baseList) {
      final nameKey = mountain.name.trim(); // 공백 제거해서 키로 사용
      
      final trailKey = findBestMatch(nameKey, trailInfoMap);
      final trail = trailKey != null ? trailInfoMap[trailKey] : null;

      final coordKey = findBestMatch(nameKey, coordMap);
      final coord = coordKey != null ? coordMap[coordKey] : null;
      if (coord == null) print('❌ 좌표 없음: $nameKey');

      final forestKey = findBestMatch(nameKey, forestInfoMap);
      final forest = forestKey != null ? forestInfoMap[forestKey] : null;

      final roadKey = findBestMatch(nameKey, roadsMap);
      final roads = roadKey != null ? roadsMap[roadKey] : null;

      print('🔍 $nameKey → forestKey: $forestKey → height: ${forest?['mntihigh']}');
      print('🔍 $nameKey → roadKey: $roadKey → tourisminf: ${roads?['tourisminf']}');

      // final coord = coordMap[nameKey];
      // final forest = forestInfoMap[nameKey];
      // final roadKey = findClosestRoadKey(nameKey, roadsMap);
      // final roads = roadKey != null ? roadsMap[roadKey] : null;
      
      // final trailUrl = (trail?['trailInfoUrl'])?.toString() ?? '';
      // final trailImg = (trail?['trailImageUrl'])?.toString() ?? '';
      // final trailFile = (trail?['trailFileUrl'])?.toString() ?? '';

      print('🔍 $nameKey: ${roads?['tourisminf']} (${roads?['tourisminf'].runtimeType})');

      enrichedList.add(
        Mountain(
          name: mountain.name,
          latitude: coord?['lat'] ?? 0.0,
          longitude: coord?['lng'] ?? 0.0,
          region: coord?['region'] ?? '',
          overview: mountain.overview,
          height:
              double.tryParse(forest?['mntihigh']?.toString() ?? '0') ?? 0.0,
          details: forest?['mntidetails'],
          summary: forest?['mntisummary'],
          transport: roads?['transport'],
          tourismInfo: roads?['tourisminf'],
          etccourse: roads?['etccourse'],
          subName: roads?['subnm'],
          topReason: roads?['aeatreason'],
          trailInfoUrl: safeStringFrom(trail?['mntninfourl']),
          trailImageUrl: safeStringFrom(trail?['mntnimg']),
          trailFileUrl: safeStringFrom(trail?['mntnfile']),
        ),
      );
    }
    return enrichedList;
  }
}
