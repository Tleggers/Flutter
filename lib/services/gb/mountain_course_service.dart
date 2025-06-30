import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart'; // ✅ dotenv 추가
import '../../models/gb/mountain_course.dart';

class MountainCourseService {
  // ✅ .env에서 API_URL 읽기
  static final String? baseApiUrl = dotenv.env['API_URL'];

  // ✅ 산 이름과 위치로 MountainCourse 가져오기
  static Future<MountainCourse?> fetchByNameAndLocation(
    String mountainName,
    String location,
  ) async {
    try {
      if (baseApiUrl == null) {
        throw Exception("API_URL이 .env에 설정되어 있지 않습니다.");
      }

      final encodedName = Uri.encodeComponent(mountainName);
      final encodedLocation = Uri.encodeComponent(location);

      final url = Uri.parse(
        '$baseApiUrl/mountaincourse/findByNameAndLocation?name=$encodedName&location=$encodedLocation',
      );

      final response = await http.get(url);

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final json = jsonDecode(response.body);
        return MountainCourse.fromJson(json);
      }

      if (response.statusCode == 404 || response.body.isEmpty) {
        return null;
      }

      throw Exception('산 코스 불러오기 실패 (상태코드 ${response.statusCode})');
    } catch (e) {
      print('❌ API 호출 실패: $e');
      return null;
    }
  }
}
