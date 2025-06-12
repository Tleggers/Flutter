import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:trekkit_flutter/models/gb/suggest_mountain.image.dart';

class SuggestMountainImageApi {
  static const String serviceKey =
      'YTmDaHkK9QsxNgBXNgrwBKrWEK7bZ23jIpDqGvGL8E+D1EaPNA21sEPu3Nd1kOQpkJSHD923d+l/62Wl/xGj5w==';

  // 산코드를 이용해서 이미지 가져오기
  static Future<List<SuggestMountainImage>> fetchImagesByMountainCode(
    String mntilistno,
  ) async {
    try {
      final uri = Uri.https(
        'apis.data.go.kr',
        '/1400000/service/cultureInfoService2/mntInfoImgOpenAPI2',
        {
          'serviceKey': serviceKey,
          'mntiListNo': mntilistno,
          'numOfRows': '10',
          'pageNo': '1',
          '_type': 'json',
        },
      );

      final response = await http.get(uri);
      print('🌐 이미지 응답코드: ${response.statusCode}');

      if (response.statusCode == 200) {
        final decodedBody = const Utf8Decoder().convert(response.bodyBytes);
        final jsonResult = json.decode(decodedBody);
        final body = jsonResult['response']['body'];
        final itemsRaw = body['items'];

        if (itemsRaw == null || itemsRaw is String) {
          return []; // 이미지 없는 경우
        }

        final items = itemsRaw['item'];

        if (items is List) {
          return items
              .map<SuggestMountainImage>(
                (item) => SuggestMountainImage.fromJson(item),
              )
              .toList();
        } else if (items is Map) {
          return [SuggestMountainImage.fromJson(items)];
        } else {
          return [];
        }
      } else {
        print('❌ 이미지 API 호출 실패: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('❌ 이미지 예외 발생: $e');
      return [];
    }
  }
}
