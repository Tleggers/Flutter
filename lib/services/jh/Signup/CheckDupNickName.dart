import 'package:http/http.dart' as http;
import 'dart:convert';

// 닉네임 중복 확인 메소드
Future<bool> checkDupNickName(String nickname) async {

  // 10.0.2.2 << localhost같은 역할
  final url = Uri.parse('http://10.0.2.2:30000/signup/checkDupNickname');

  final response = await http.post(
    url,
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({"nickname": nickname}),
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
