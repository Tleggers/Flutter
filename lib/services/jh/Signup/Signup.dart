import 'dart:convert';
import 'package:http/http.dart' as http;

// 회원가입 함수
Future<bool> signUp({
  required String id,
  required String pw,
  required String nickname,
  required String email,
}) async {

  final url = Uri.parse('http://10.0.2.2:30000/signup/dosignup'); // 실제 서버 주소로 변경

  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'id': id,
        'pw': pw,
        'nickname': nickname,
        'email': email,
      }),
    );

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      return result;
    } else {
      return false;
    }
  } catch (e) {
    return false;
  }
}