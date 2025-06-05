import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

import '../../../functions/jh/Login/UserProvider.dart';
import '../../../pages/MainPage.dart';

Future<void> loginWithKakao(BuildContext context) async {

  try {
    // 1. 카카오 로그인
    if (await isKakaoTalkInstalled()) {
      await UserApi.instance.loginWithKakaoTalk();
    } else {
      await UserApi.instance.loginWithKakaoAccount();
    }

    // 2. 사용자 정보 가져오기
    final user = await UserApi.instance.me();
    final email = user.kakaoAccount?.email;
    final nickname = user.kakaoAccount?.profile?.nickname ?? '익명';
    final profile = user.kakaoAccount?.profile?.profileImageUrl ?? '';

    if (email == null) {
      showSnackBar(context, '카카오 계정에 이메일 권한이 없습니다.');
      return;
    }

    // 3. 백엔드로 POST 요청 보내기
    final url = Uri.parse('http://10.0.2.2:30000/login/kakao');

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": email,
        "nickname": nickname,
        "profile": profile,
      }),
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

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const MainPage(title: '트레킷')),
              (route) => false,
        );
      } else {
        showSnackBar(context, '로그인 실패: 서버 응답 오류');
      }
    } else {
      showSnackBar(context, '서버 오류가 발생했습니다.');
    }
  } catch (e) {
    print("❌ 카카오 로그인 실패: $e");
    showSnackBar(context, '카카오 로그인 중 오류 발생');
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