import 'dart:convert'; // JSON 데이터를 디코딩하기 위해 필요
import 'package:http/http.dart' as http; // HTTP 요청을 보내기 위한 패키지
import 'package:trekkit_flutter/models/sh/mountain.dart';

// 산림청 명산등산로 API를 요청하고 데이터를 가져오는 클래스
class MountainApi {
  static const String _apiKey =
      'YTmDaHkK9QsxNgBXNgrwBKrWEK7bZ23jIpDqGvGL8E%2BD1EaPNA21sEPu3Nd1kOQpkJSHD923d%2Bl%2F62Wl%2FxGj5w%3D%3D';

  static const String _baseUrl =
      'http://openapi.forest.go.kr/openapi/service/cultureInfoService/gdTrailInfoOpenAPI';

  static Future<List<Mountain>> fetchMountains() async {
    final url = Uri.parse(
      '$_baseUrl?serviceKey=$_apiKey&numOfRows=100&pageNo=1&_type=json',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      final items = decoded['response']?['body']?['items']?['item'];

      if (items is List) {
        return items
            .map((item) => Mountain.fromAApi(Map<String, dynamic>.from(item)))
            .toList();
      } else if (items is Map) {
        return [Mountain.fromAApi(Map<String, dynamic>.from(items))];
      } else {
        return [];
      }
    } else {
      throw Exception('산림청 100대 명산 api 로드 실패: ${response.statusCode}');
    }
  }
}
