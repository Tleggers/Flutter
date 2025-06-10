import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

// 메일 보내는 함수
Future<void> sendMail(BuildContext context, String email, String userid) async {

  try {

    final baseUrl = dotenv.env['API_URL']!; // 여기서 ! << 절대 null이면 안된다는 의미
    final url = Uri.parse('$baseUrl/signup/sendFindPwMail');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({"email": email, "userid": userid}),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('인증 메일이 전송되었습니다')),
      );
    } else {
      final message = utf8.decode(response.bodyBytes);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('실패: $message')),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('오류 발생: $e')),
    );
    
  }

}

// 비밀번호 재설정 하는 함수
Future<bool> resetPassword(String userid, String newPw, BuildContext context) async {

  try {

    final baseUrl = dotenv.env['API_URL']!; // 여기서 ! << 절대 null이면 안된다는 의미
    final url = Uri.parse('$baseUrl/find/resetPassword');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({"userid": userid, "newPassword": newPw}),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('오류 코드: ${response.statusCode}');
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('비밀번호 변경 실패: $e')),
    );
    return false;
  }

}
