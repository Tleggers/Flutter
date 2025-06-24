import 'dart:convert';
import 'package:http/http.dart' as http;

//산림청 명산등산로 API
class MountainRoadApi {
  static const String _apiKey = 
      'b96eSjTza7C7QbPobZvC9k42Yn9TmGV4y%2BxTx%2B0W2d97ycimCfjKE%2F5rd5Bpj9%2FYTvDxlQPEceC6dctxSDDytA%3D%3D';
  static const String _baseUrl =
      'http://openapi.forest.go.kr/openapi/service/cultureInfoService/gdTrailInfoOpenAPI';

  static Future<Map<String, Map<String, String>>> fetchMountainRoads() async {
      final uri = Uri.parse('$_baseUrl?serviceKey=$_apiKey&numOfRows=1000&pageNo=1&_type=json');

      final Map<String, Map<String, String>> roadMap = {};

      try {
        final response = await http.get(uri);

        if (response.statusCode == 200) {
          final data = jsonDecode(utf8.decode(response.bodyBytes));
          final items = data['response']?['body']?['items']?['item'];

           if (items is List) {
          for (final item in items) {
            final name = item['mntnm'] ?? '';
            roadMap[name] = {
              'subName': item['subnm'] ?? '',
              'topReason': item['aeatreason'] ?? '',
              'overview': item['overview'] ?? '',
              'details': item['details'] ?? '',
              'transport': item['transport'] ?? '',
              'tourismInfo': item['tourisminf'] ?? '',
              'etccourse': item['etccourse'] ?? '',
            };
          }
        } else if (items is Map) {
          final name = items['mntnm'] ?? '';
          roadMap[name] = {
            'subName': items['subnm'] ?? '',
            'topReason': items['aeatreason'] ?? '',
            'overview': items['overview'] ?? '',
            'details': items['details'] ?? '',
            'transport': items['transport'] ?? '',
            'tourismInfo': items['tourisminf'] ?? '',
            'etccourse': items['etccourse'] ?? '',
          };
        }
      } else {
        print('❌ 명산등산로 API 호출 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ 명산등산로 API 예외 발생: $e');
    }

    return roadMap;
  }
}