import 'dart:convert'; // JSON 데이터를 디코딩하기 위해 필요
import 'package:http/http.dart' as http; // HTTP 요청을 보내기 위한 패키지
import 'package:trekkit_flutter/models/gb/popular_course_section.dart'; // 인기 산 정보를 담을 모델 클래스
import 'package:trekkit_flutter/models/sh/mountain.dart';

// 산 관련 API를 요청하고 데이터를 가져오는 클래스
class MountainApi {
  // ▶ API 인증키 (주의: 실제 앱 배포 시 노출되면 안 되므로 dotenv 같은 보안 처리 필요)
  static const String _apiKey =
      'YTmDaHkK9QsxNgBXNgrwBKrWEK7bZ23jIpDqGvGL8E%2BD1EaPNA21sEPu3Nd1kOQpkJSHD923d%2Bl%2F62Wl%2FxGj5w%3D%3D';

  // ▶ API의 실제 요청 주소 (명산 등산로 이미지 API 엔드포인트)
  static const String _baseUrl =
      'http://openapi.forest.go.kr/openapi/service/cultureInfoService/gdTrailInfoOpenAPI';
      
  /// ▶ 인기 산 정보를 가져오는 비동기 함수
  /// - [page]: 페이지 번호
  /// - [numOfRows]: 한 페이지에 가져올 산 개수
  static Future<List<PopularMountain>> fetchPopularMountains({
    int page = 1,
    int numOfRows = 10,
  }) async {
    // ✅ 요청 보낼 전체 URL 구성 (파라미터 포함)
    final url = Uri.parse(
      '$_baseUrl?serviceKey=$_apiKey&numOfRows=$numOfRows&pageNo=$page&_type=json',
    );

    print('📡 API 호출 시도: $url'); // 👉 이 줄 추가!

    try {
      // ✅ HTTP GET 요청 보내기
      final response = await http.get(url);

      print('✅ 응답 상태 코드: ${response.statusCode}'); // 👉 이 줄도 추가!
      print('📦 응답 본문: ${response.body}'); // 👉 응답 전체 확인용 (크면 생략 가능)
      final decodedBody = utf8.decode(response.bodyBytes);
      // ✅ 요청 성공 시 (200 OK)
      if (response.statusCode == 200) {
        // JSON 형식으로 파싱
        final Map<String, dynamic> jsonData = json.decode(decodedBody);

        // ▶ 데이터 구조 확인 및 item 리스트 추출
        final itemsRaw = jsonData['response']?['body']?['items']?['item'];

        if (itemsRaw is List) {
          // itemsRaw 가 List<dynamic> 인 경우
          return itemsRaw
              .map(
                (item) =>
                    PopularMountain.fromJson(Map<String, dynamic>.from(item)),
              )
              .toList();
        } else if (itemsRaw is Map) {
          // itemsRaw 가 Map<dynamic, dynamic> 인 경우, Map<String, dynamic>으로 변환 필요
          return [
            PopularMountain.fromJson(Map<String, dynamic>.from(itemsRaw)),
          ];
        } else {
          return [];
        }
      } else {
        // 서버에서 에러 코드 반환 시
        throw Exception('서버 오류: ${response.statusCode}');
      }
    } catch (e) {
      // 네트워크 오류, 파싱 오류 등 예외 발생 시
      throw Exception('데이터를 불러오는 중 문제가 발생했어요: $e');
    }
  }

  /// ▶ 전체 산 정보를 가져오는 비동기 함수

  static Future<List<Mountain>> fetchMountains() async {
    final url = Uri.parse('$_baseUrl?serviceKey=$_apiKey&numOfRows=100&pageNo=1&_type=json',);
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      final items = decoded['response']?['body']?['items']?['item'];
      
      print('🧾 첫 번째 산 JSON: ${jsonEncode(items is List ? items.first : items)}');

      if (items is List) {
        return items
            .map((item) => Mountain.fromJson(Map<String, dynamic>.from(item)))
            .toList();
      } else if (items is Map) {
        return [
          Mountain.fromJson(Map<String, dynamic>.from(items)),
        ];
      } else {
        return [];
      }
    } else {
      throw Exception('산 데이터 로드 실패: ${response.statusCode}');
    }
  }
}
