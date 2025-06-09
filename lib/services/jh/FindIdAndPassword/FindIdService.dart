import 'dart:convert';
import 'package:http/http.dart' as http;

// 메일 보내는 함수
Future<void> sendMail(String email) async {
  final url = Uri.parse('http://192.168.0.51:30000/signup/sendFindMail');
  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({"email": email}),
  );

  if (response.statusCode != 200) {
    throw Exception('메일 전송 실패: ${response.statusCode}');
  }
}

// 메일로 아이디 찾는 함수
Future<Map<String, dynamic>?> fetchUserIdByEmail(String email) async {
  final url = Uri.parse('http://192.168.0.51:30000/find/findid');
  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'email': email}),
  );

  if (response.statusCode == 200) {
    final body = jsonDecode(response.body);
    final userId = body['userid'];
    final loginType = body['logintype'];

    if (userId != null && loginType != null) {
      return {'userid': userId, 'logintype': loginType};
    }
  }
  return null;
}