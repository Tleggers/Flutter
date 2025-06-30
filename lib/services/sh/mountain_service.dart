import 'package:trekkit_flutter/models/sh/mountain.dart';
import 'package:trekkit_flutter/api/mountain_api.dart'; // 기존 산림청 명산 등산로 API
import 'package:trekkit_flutter/api/trekking_api.dart'; // 트레킹센터 좌표 API

class MountainService {
  static Future<List<Mountain>> fetchMountainsWithAPIs() async {
    // 1. 산림청 100대 명산 정보
    final baseList = await MountainApi.fetchMountains(); // 기존 API (이름, 개요 등)

    // 2. 트레킹센터 좌표
    final coordMap = await TrekkingApi.fetchMountainCoords(); // 이름 → 위경도

    // 3. 병합
    List<Mountain> enrichedList = [];

    for (final mountain in baseList) {
      final nameKey = mountain.name.trim(); // 공백 제거해서 키로 사용

      final coord = coordMap[nameKey];

      // 좌표 없으면 스킵
      if (coord == null) continue;

      enrichedList.add(
        Mountain(
          name: mountain.name,
          overview: mountain.overview,
          height: mountain.height,

          latitude: coord['lat'] ?? 0.0,
          longitude: coord['lng'] ?? 0.0,
          region: coord['region'] ?? '',
        ),
      );
    }

    return enrichedList;
  }
}
