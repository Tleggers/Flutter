import 'dart:convert';
import 'package:http/http.dart' as http;

//산림청 산정보 API
class MountainInfoApi {
  static const String _serviceKey =
      'YTmDaHkK9QsxNgBXNgrwBKrWEK7bZ23jIpDqGvGL8E%2BD1EaPNA21sEPu3Nd1kOQpkJSHD923d%2Bl%2F62Wl%2FxGj5w%3D%3D';
  static const String _baseUrl =
      'https://apis.data.go.kr/1400000/service/cultureInfoService2/mntInfoOpenAPI2';

  static Future<Map<String, Map<String, dynamic>>> fetchMountainInfo() async {
    const int pageSize = 100;
    int page = 1;
    bool done = false;

    final Map<String, Map<String, dynamic>> result = {};

    while (!done) {
      final url = Uri.parse(
        '$_baseUrl?serviceKey=$_serviceKey&numOfRows=$pageSize&pageNo=$page&MobileOS=ETC&MobileApp=trekkit&_type=json',
      );

      try {
        final response = await http.get(url);

        if (response.statusCode == 200) {
          final decoded = utf8.decode(response.bodyBytes);
          final jsonResult = json.decode(decoded);
          final items = jsonResult['response']['body']['items']['item'];

          if (items is List) {
            for (var item in items) {
              final name = item['mntiname']?.toString().trim();
              // print("🌲 ${item['mntiname']} → mntihigh: ${item['mntihigh']}");
              if (name != null && name.isNotEmpty) {
                result[name] = {
                  'height': item['mntihigh'],
                  'address': item['mntiadd'],
                  'summary': item['mntisummary'],
                  'details': item['mntidetails'],
                };
              }
            }
            if (items.length < pageSize) {
              done = true;
            } else {
              page++;
            }
          } else if (items is Map) {
            final name = items['mntiname']?.toString().trim();
            if (name != null && name.isNotEmpty) {
              result[name] = {
                'height': items['mntihigh'],
                'address': items['mntiadd'],
                'summary': items['mntisummary'],
                'details': items['mntidetails'],
              };
            }
            done = true;
          } else {
            done = true;
          }
        } else {
          print('❌ 산림청 산정보 API 응답 오류: ${response.statusCode}');
          done = true;
        }
      } catch (e) {
        print('❌ 산림청 산정보 예외 발생: $e');
        done = true;
      }
    }

    print('✅ 산림청 산정보에서 총 ${result.length}개의 산 정보를 불러왔습니다.');
    return result;
  }
}
