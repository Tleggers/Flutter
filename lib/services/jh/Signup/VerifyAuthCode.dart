import 'dart:convert';
import 'package:http/http.dart' as http;

// 이메일 인증코드 검증 함수
Future<bool> verifyAuthCode(String email, String code) async {
  final url = Uri.parse('http://10.0.2.2:30000/signup/checkAuthCode');

  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'authCode': code,
      }),
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return body == true || body['result'] == true;
    } else {
      return false;
    }
  } catch (e) {
    return false;
  }
}