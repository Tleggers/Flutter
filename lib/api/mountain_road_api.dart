import 'dart:convert';
import 'package:http/http.dart' as http;

//산림청 명산등산로 API
class MountainRoadApi {
  static const String _apiKey = 
      'YTmDaHkK9QsxNgBXNgrwBKrWEK7bZ23jIpDqGvGL8E%2BD1EaPNA21sEPu3Nd1kOQpkJSHD923d%2Bl%2F62Wl%2FxGj5w%3D%3D';
  static const String _baseUrl =
      'http://openapi.forest.go.kr/openapi/service/cultureInfoService/gdTrailInfoOpenAPI';

  static Future<Map<String, Map<String, dynamic>>> fetchMountainRoads() async {
      final uri = Uri.parse('$_baseUrl?serviceKey=$_apiKey&numOfRows=1000&pageNo=1&_type=json');

      final Map<String, Map<String, dynamic>> result = {};

      try {
        final response = await http.get(uri);

        if (response.statusCode == 200) {
          final data = jsonDecode(utf8.decode(response.bodyBytes));
          final items = data['response']?['body']?['items']?['item'];

           if (items is List) {
              for (final item in items) {
                final name = item['mntnm'] ?? '';
                result[name] = {
                  'subnm': item['subnm'] ?? '',
                  'aeatreason': item['aeatreason'] ?? '',
                  'overview': item['overview'] ?? '',
                  'details': item['details'] ?? '',
                  'transport': item['transport'] ?? '',
                  'tourisminf': item['tourisminf'] ?? '',
                  'etccourse': item['etccourse'] ?? '',
                };
              }
            } else if (items is Map) {
              final name = items['mntnm'] ?? '';
              result[name] = {
                'subnm': items['subnm'] ?? '',
                'aeatreason': items['aeatreason'] ?? '',
                'overview': items['overview'] ?? '',
                'details': items['details'] ?? '',
                'transport': items['transport'] ?? '',
                'tourisminf': items['tourisminf'] ?? '',
                'etccourse': items['etccourse'] ?? '',
              };
            }
          } else {
            print('❌ 산림청 명산등산로 API 호출 실패: ${response.statusCode}');
          }
        } catch (e) {
          print('❌ 산림청 명산등산로 API 예외 발생: $e');
        }

        return {};
      }
}