import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';

class MountainImageService {
  /// 산 이름과 위치로 DB 이미지 URL 요청
  static Future<String?> fetchImageFromDB(String name, String location) async {
    try {
      final baseUrl = dotenv.env['API_URL']; // ✅ .env에서 불러오기

      if (baseUrl == null) {
        throw Exception("API_URL이 설정되지 않았습니다.");
      }

      final uri = Uri.parse(
        '$baseUrl/mountainlist/image?mountain_name=$name&location=$location',
      );
      print('🌐 서버 요청: $uri');

      final response = await http.get(uri);
      print('응답 body: ${response.body}');

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        return response.body;
      } else {
        return null;
      }
    } catch (e) {
      print('❌ 서버 이미지 요청 실패: $e');
      return null;
    }
  }
}
