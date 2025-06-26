import 'package:http/http.dart' as http;
import 'dart:convert';

class MountainImageService {
  /// 산 이름과 위치로 DB 이미지 URL 요청
  static Future<String?> fetchImageFromDB(String name, String location) async {
    try {
      final uri = Uri.http('10.0.2.2:30000', '/mountainlist/image', {
        'mountain_name': name,
        'location': location,
      });
      print('🌐 서버 요청: $uri');
      final response = await http.get(uri);

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        return response.body; // 서버에서 받은 이미지 URL (plain text)
      } else {
        return null;
      }
    } catch (e) {
      print('❌ 서버 이미지 요청 실패: $e');
      return null;
    }
  }
}
