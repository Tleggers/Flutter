import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

// 이메일 인증코드 검증 함수
Future<bool> verifyAuthCode(String email, String code) async {

  final numberReg = RegExp(r'^[0-9]+$');// 예: 숫자만 허용
  if (!numberReg.hasMatch(code)) {
    return false;
  }

  final baseUrl = dotenv.env['API_URL']!; // 여기서 ! << 절대 null이면 안된다는 의미
  final url = Uri.parse('$baseUrl/signup/checkAuthCode');

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