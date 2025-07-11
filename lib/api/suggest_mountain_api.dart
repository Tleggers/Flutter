import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:trekkit_flutter/models/gb/suggest_mountain.dart';

class SuggestMountainApi {
  static const String serviceKey =
      'YTmDaHkK9QsxNgBXNgrwBKrWEK7bZ23jIpDqGvGL8E+D1EaPNA21sEPu3Nd1kOQpkJSHD923d+l/62Wl/xGj5w==';

  // 산 전체 목록 가져오기 (산정보 API 사용)
  static Future<List<SuggestMountain>> fetchMountains() async {
    try {
      final uri = Uri.https(
        'apis.data.go.kr',
        '/1400000/service/cultureInfoService2/mntInfoOpenAPI2',
        {
          'serviceKey': serviceKey,
          'numOfRows': '1000',
          'pageNo': '1',
          '_type': 'json',
        },
      );

      final response = await http.get(uri);
      print('🌐 응답코드: ${response.statusCode}');

      if (response.statusCode == 200) {
        final decodedBody = const Utf8Decoder().convert(response.bodyBytes);
        final jsonResult = json.decode(decodedBody);
        final body = jsonResult['response']['body'];
        final itemsRaw = body['items'];

        if (itemsRaw == null || itemsRaw is String) {
          return [];
        }

        final items = itemsRaw['item'];

        if (items is List) {
          return items
              .map<SuggestMountain>((item) => SuggestMountain.fromJson(item))
              .toList();
        } else if (items is Map) {
          return [SuggestMountain.fromJson(items)];
        } else {
          return [];
        }
      } else {
        print('❌ API 호출 실패: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('❌ 예외 발생: $e');
      return [];
    }
  }
}
