import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:trekkit_flutter/models/gb/suggest_mountain.dart';

class SuggestMountainApi {
  static const String serviceKey =
      'YTmDaHkK9QsxNgBXNgrwBKrWEK7bZ23jIpDqGvGL8E%2BD1EaPNA21sEPu3Nd1kOQpkJSHD923d%2Bl%2F62Wl%2FxGj5w%3D%3D';

  static Future<List<SuggestMountain>> fetchMountains() async {
    try {
      final url =
          'http://openapi.forest.go.kr/openapi/service/cultureInfoService/gdTrailInfoOpenAPI?serviceKey=$serviceKey&numOfRows=100&pageNo=1&_type=json';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final decodedBody = const Utf8Decoder().convert(response.bodyBytes);
        final Map<String, dynamic> jsonResult = json.decode(decodedBody);
        final body = jsonResult['response']['body'];
        final items = body['items']['item'];

        if (items is List) {
          return items.map((item) => SuggestMountain.fromJson(item)).toList();
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
