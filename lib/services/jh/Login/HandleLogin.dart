import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

import '../../../functions/jh/Login/UserProvider.dart';
import '../../../pages/MainPage.dart';

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

  final url = Uri.parse('http://10.0.2.2:30000/login/dologin');
  try {
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"userid": id, "password": pw}),
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final token = body['token'];
      final nickname = body['nickname'];
      final profile = body['profile'];

      if (token != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        await prefs.setString('nickname', nickname);
        await prefs.setString('profile', profile);

        Provider.of<UserProvider>(context, listen: false).login(
          token,
          nickname,
          profile,
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