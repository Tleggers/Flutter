import 'package:http/http.dart' as http;
import 'dart:convert';

Future<void> sendMail(String email) async {
  final url = Uri.parse('http://10.0.2.2:30000/signup/sendMail');

  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({"email": email}),
  );

  if (response.statusCode != 200) {
    throw Exception('메일 전송 실패: ${response.statusCode}');
  }

}
