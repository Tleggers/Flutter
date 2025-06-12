import 'dart:convert'; // JSON 데이터를 디코딩하기 위해 필요
import 'package:http/http.dart' as http; // HTTP 요청을 보내기 위한 패키지
import 'package:trekkit_flutter/models/sh/mountain.dart';

// 산 관련 API를 요청하고 데이터를 가져오는 클래스
class MountainApi {
  // ▶ API 인증키 (주의: 실제 앱 배포 시 노출되면 안 되므로 dotenv 같은 보안 처리 필요)
  static const String _apiKey =
      'YTmDaHkK9QsxNgBXNgrwBKrWEK7bZ23jIpDqGvGL8E%2BD1EaPNA21sEPu3Nd1kOQpkJSHD923d%2Bl%2F62Wl%2FxGj5w%3D%3D';

  // ▶ API의 실제 요청 주소 (명산 등산로 이미지 API 엔드포인트)
  static const String _baseUrl =
      'http://openapi.forest.go.kr/openapi/service/cultureInfoService/gdTrailInfoOpenAPI';

  // static Future<void> printMountainNames() async {
  // final url = Uri.parse('$_baseUrl?serviceKey=$_apiKey&numOfRows=100&pageNo=1&_type=json');
  // final response = await http.get(url);

//   if (response.statusCode == 200) {
//     final decoded = jsonDecode(utf8.decode(response.bodyBytes));
//     final items = decoded['response']?['body']?['items']?['item'];

//     if (items is List) {
//       print('📋 API에서 가져온 산 이름 목록 (${items.length}개):');
//       for (var item in items) {
//         final map = Map<String, dynamic>.from(item);
//         print('🗻 ${map["mntnm"]}');
//       }
//     } else if (items is Map) {
//       final map = Map<String, dynamic>.from(items);
//       print('🗻 ${map["mntnm"]}');
//     } else {
//       print('❌ 아이템 형식 오류');
//     }
//   } else {
//     print('❌ API 호출 실패: ${response.statusCode}');
//   }
// }

  /// ▶ 전체 산 정보를 가져오는 비동기 함수(산림청 명산등산로API)
  // static Future<List<Mountain>> fetchMountains() async {
  //   final url = Uri.parse('$_baseUrl?serviceKey=$_apiKey&numOfRows=100&pageNo=1&_type=json',);
  //   final response = await http.get(url);
  //   if (response.statusCode == 200) {
  //     final decoded = jsonDecode(utf8.decode(response.bodyBytes));
  //     final items = decoded['response']?['body']?['items']?['item'];
      
  //     //100대 명산 API 키(컬럼) 확인
  //     if (items is List && items.isNotEmpty) {
  //     final firstItem = Map<String, dynamic>.from(items.first);
  //     print('🧾 실제 키 목록: ${firstItem.keys.toList()}');  // ✅ 여기에 넣으세요
  //   }

  //     if (items is List) {
  //       return items
  //           .map((item) => Mountain.fromAApi(Map<String, dynamic>.from(item)))
  //           .toList();
  //     } else if (items is Map) {
  //       return [
  //         Mountain.fromAApi(Map<String, dynamic>.from(items)),
  //       ];
  //     } else {
  //       return [];
  //     }
  //   } else {
  //     throw Exception('산 데이터 로드 실패: ${response.statusCode}');
  //   }
  // }
    static Future<List<Mountain>> fetchMountains() async {
    final url = Uri.parse(
        '$_baseUrl?serviceKey=$_apiKey&numOfRows=100&pageNo=1&_type=json');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      final items = decoded['response']?['body']?['items']?['item'];

      if (items is List) {
        return items
            .map((item) => Mountain.fromAApi(Map<String, dynamic>.from(item)))
            .toList();
      } else if (items is Map) {
        return [
          Mountain.fromAApi(Map<String, dynamic>.from(items)),
        ];
      } else {
        return [];
      }
    } else {
      throw Exception('API A 로드 실패: ${response.statusCode}');
    }
  }
}
