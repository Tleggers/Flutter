import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// 아이디 중복 확인 메소드
Future<bool> checkDupId(String id) async {

  final baseUrl = dotenv.env['API_URL']!; // 여기서 ! << 절대 null이면 안된다는 의미
  final url = Uri.parse('$baseUrl/signup/checkDupid');

  final response = await http.post(
    url,
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({"id": id}),
  );

  if (response.statusCode == 200) {
    final body = jsonDecode(response.body); // body는 true 또는 false, response.body가 true나 false이기 때문

    // body가 bool형태면 body를 리턴
    if (body is bool) {
      return body;
    } else {
      throw Exception("예상치 못한 응답 형식: $body");
    }
  } else {
    throw Exception("서버 요청 실패: ${response.statusCode}");
  }
  
}
