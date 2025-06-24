import 'dart:convert';
import 'package:http/http.dart' as http;

//산림청 등산로정보 API
class MountainTrailApi {
  static const String _apiKey = 
      'b96eSjTza7C7QbPobZvC9k42Yn9TmGV4y%2BxTx%2B0W2d97ycimCfjKE%2F5rd5Bpj9%2FYTvDxlQPEceC6dctxSDDytA%3D%3D';
  static const String _baseUrl =
      'http://openapi.forest.go.kr/openapi/service/cultureInfoService/gdTrailInfoOpenAPI';

  // static Future<Map<String, List<String>>> fetchTrails() async {
   static Future<Map<String, Map<String, String>>> fetchTrails(List<String> mountainNames) async {
    final Map<String, Map<String, String>> trailInfoMap = {};

    for (final name in mountainNames) {
      final uri = Uri.parse(
          '$_baseUrl?mntnNm=$name&serviceKey=$_apiKey&numOfRows=&pageNo=&_type=json');

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final items = data['response']?['body']?['items']?['item'];

        if (items != null) {
        if (items is List) {
          for (var item in items) {
            trailInfoMap[name] = {
              'trailInfoUrl': item['mntninfourl']?.toString() ?? '',
              'trailImageUrl': item['mntnimg']?.toString() ?? '',
              'trailFileUrl': item['mntnfile']?.toString() ?? '',
            };
            break; // 여러 개 있을 경우 첫 번째만 사용
          }
        } else if (items is Map) {
          trailInfoMap[name] = {
            'trailInfoUrl': items['mntninfourl']?.toString() ?? '',
            'trailImageUrl': items['mntnimg']?.toString() ?? '',
            'trailFileUrl': items['mntnfile']?.toString() ?? '',
          };
        }
       }
      }
    }

    return trailInfoMap;
  }
}