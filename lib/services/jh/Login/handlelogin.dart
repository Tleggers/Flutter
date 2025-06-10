import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

import '../../../functions/jh/userprovider.dart';
import '../../../pages/mainpage.dart';

Future<void> loginHandler({
  required BuildContext context,
  required String id,
  required String pw,
}) async {
  final idRegex = RegExp(r'^[a-zA-Z0-9]{1,16}$');
  final pwRegex = RegExp(r'^[a-zA-Z0-9!@#%^&*]{1,16}$');

  if (id.isEmpty || pw.isEmpty) {
    showSnackBar(context, '아이디와 비밀번호를 모두 입력해주세요.');
    return;
  }

  if (!idRegex.hasMatch(id)) {
    showSnackBar(context, '아이디는 영어/숫자만 사용하며 최대 16자까지 가능합니다.');
    return;
  }

  if (!pwRegex.hasMatch(pw) || pw.contains(RegExp(r'[ㄱ-ㅎ가-힣]'))) {
    showSnackBar(context, '비밀번호는 한글 없이, 영문/숫자/특수문자만 사용하며 최대 16자까지 가능합니다.');
    return;
  }

  final baseUrl = dotenv.env['API_URL']!; // 여기서 ! << 절대 null이면 안된다는 의미
  final url = Uri.parse('$baseUrl/login/dologin');

  try {
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"userid": id, "password": pw}),
    );

    print("응답 본문: ${response.body}");

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final token = body['token']; // 토큰
      final nickname = body['nickname']; // 닉네임
      final profile = body['profile']; // 프로필
      final logintype = body['logintype']; // 로그인 타입(ex.KAKAO,LOCAL)
      final index = body['index']; // 인덱스 (DB에서 ID를 의미)

      if (token != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        await prefs.setString('nickname', nickname);
        await prefs.setString('profile', profile);
        await prefs.setString('logintype', logintype);
        await prefs.setInt('index', index);

        Provider.of<UserProvider>(context, listen: false).login(
          token,
          nickname,
          profile,
          logintype,
          index,
        );

        if (!context.mounted) return;
        
        // 로그인 성공 -> 메인으로 이동 -> AppBar에 뒤로가기 버튼은 사라짐
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const MainPage(title: '트레킷')),
              (route) => false, // 👈 이전 모든 route 제거
        );
      } else {
        showSnackBar(context, '로그인 실패: 아이디 또는 비밀번호가 틀렸습니다.');
      }
    } else {
      showSnackBar(context, '서버 오류가 발생했습니다.');
    }
  } catch (e) {
    showSnackBar(context, '서버 통신 중 오류가 발생했습니다.');
  }
}

void showSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
    ),
  );
}