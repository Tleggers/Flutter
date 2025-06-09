import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<void> sendMail(String email) async {

  final baseUrl = dotenv.env['API_URL']!; // 여기서 ! << 절대 null이면 안된다는 의미
  final url = Uri.parse('$baseUrl/signup/sendMail');

  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({"email": email}),
  );

  if (response.statusCode != 200) {
    throw Exception('메일 전송 실패: ${response.statusCode}');
  }

}
