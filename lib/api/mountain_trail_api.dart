import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:trekkit_flutter/models/sh/mountain.dart';

//산림청 등산로정보 API
class MountainTrailApi {
  static const String _apiKey =
      'YTmDaHkK9QsxNgBXNgrwBKrWEK7bZ23jIpDqGvGL8E%2BD1EaPNA21sEPu3Nd1kOQpkJSHD923d%2Bl%2F62Wl%2FxGj5w%3D%3D';
  static const String _baseUrl =
      'http://openapi.forest.go.kr/openapi/service/trailInfoService/getforestspatialdataservice';

   static Future<Map<String, Map<String, String>>> fetchTrails(List<String> mountainNames) async {
    final Map<String, Map<String, String>> trailInfoMap = {};

    for (final name in mountainNames) {
      final uri = Uri.parse(
        '$_baseUrl?mntnNm=$name&serviceKey=$_apiKey&numOfRows=1000&pageNo=1&_type=json',
      );

          print('🌐 요청 보냄: $name');

       try {
        final response = await http.get(uri);
        if (response.statusCode != 200) {
          print('❌ $name: 응답 코드 ${response.statusCode}');
          continue;
        }

        final jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        final body = jsonData['response']?['body'];
        final items = body?['items']?['item'];

        if (items == null) {
          print('⚠️ $name: item 없음');
          continue;
        }

        for (var item in items) {
          final trailName = item['mntnnm'] ?? name;
          trailInfoMap[trailName] = {
            'trailInfoUrl': item['mntninfourl'] ?? '',
            'trailImageUrl': item['mntnimg'] ?? '',
            'trailFileUrl': item['mntnfile'] ?? '',
          };
        }
      } catch (e, stack) {
        print('❌ $name: 예외 발생 ${e.runtimeType}: $e');
        print(stack);
      }
      await Future.delayed(Duration(milliseconds: 300));
    }
    print('✅ 산림청 등산로정보 개수: ${trailInfoMap.length}');
    return trailInfoMap;
  }
}
