import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/gb/mountain_course.dart';

class MountainCourseService {
  static const String baseUrl = 'http://10.0.2.2:30000/mountaincourse';

  // ✅ 산 이름으로 검색해서 MountainCourse 데이터 가져오기
  static Future<MountainCourse?> fetchByNameAndLocation(
    String mountainName,
    String location,
  ) async {
    try {
      final encodedName = Uri.encodeComponent(mountainName);
      final encodedLocation = Uri.encodeComponent(location);

      final url = Uri.parse(
        '$baseUrl/findByNameAndLocation?name=$encodedName&location=$encodedLocation',
      );

      final response = await http.get(url);

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        // 🔹 이 부분 반드시 있어야 데이터 파싱 가능
        final json = jsonDecode(response.body);
        return MountainCourse.fromJson(json);
      }

      if (response.statusCode == 404 || response.body.isEmpty) {
        return null;
      }

      throw Exception(
        'Failed to load mountain course (status ${response.statusCode})',
      );
    } catch (e) {
      print('API 호출 실패: $e');
      return null;
    }
  }
}
