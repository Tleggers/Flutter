import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/gb/mountain_course.dart';

class MountainCourseService {
  // ✅ 서버 주소 (나중에 실제 서버 주소로 교체)
  static const String baseUrl = 'http://10.0.2.2:30000/mountaincourse';

  // ✅ 산 이름으로 검색해서 MountainCourse 데이터 가져오기
  static Future<MountainCourse?> fetchByMountainName(
    String mountainName,
  ) async {
    try {
      // 👉 한글 산 이름 등 URL 인코딩 (예: 관악산 → %EC%99%84%EC%95%85%EC%82%B0)
      final encodedName = Uri.encodeComponent(mountainName);

      // 👉 실제 요청 URL 만들기
      final url = Uri.parse('$baseUrl/findByName?name=$encodedName');

      // 👉 HTTP GET 요청 보내기
      final response = await http.get(url);

      // ✅ 서버 응답 정상일 때 (200 OK)
      if (response.statusCode == 200) {
        if (response.body.isEmpty) {
          // ✅ 서버에서 null 이면 데이터 없음으로 간주
          return null;
        }

        // ✅ 응답 바디를 JSON으로 파싱
        final json = jsonDecode(response.body);

        // ✅ JSON → MountainCourse 객체로 변환해서 반환
        return MountainCourse.fromJson(json);
      }

      // ✅ 서버에서 404 Not Found로 오는 경우 → DB에 해당 산이 없음
      if (response.statusCode == 404) {
        return null;
      }

      // ✅ 그 외는 예외 발생 (서버 오류 등)
      throw Exception(
        'Failed to load mountain course (status ${response.statusCode})',
      );
    } catch (e) {
      // ✅ 네트워크 예외, 파싱 예외 등 처리
      print('API 호출 실패: $e');
      return null;
    }
  }
}
