import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

import '../../../functions/jh/Login/UserProvider.dart';
import '../../../pages/MainPage.dart';

Future<void> loginWithKakao(BuildContext context) async {

  print('카카오 접속 성공'); // 얘는 들어옴

  try {

    // 1. 카카오 로그인
    OAuthToken token;
    print("1");

    // 혹여나 토큰이 남아있으면 제거
    if (await AuthApi.instance.hasToken()) {
      try {
        await UserApi.instance.logout();
      } catch (e) {
        print('⚠️ 로그아웃 중 오류: $e');
      }
    }

    if (await isKakaoTalkInstalled()) {
      token = await UserApi.instance.loginWithKakaoTalk();
    } else {
      token = await UserApi.instance.loginWithKakaoAccount();
    }

    final user = await UserApi.instance.me();
    final nickname = user.kakaoAccount?.profile?.nickname ?? '익명';
    final profile = user.kakaoAccount?.profile?.profileImageUrl ?? '';
    final kakaoId = user.id;

    // 3. 백엔드로 POST 요청 보내기
    // final url = Uri.parse('http://10.0.2.2:30000/login/kakao'); // 에뮬레이터
    final url = Uri.parse('http://192.168.0.7:30000/login/kakao'); // 실제 기기(주소는 각자 주소 넣기)

    print(nickname);
    print(profile);
    print(kakaoId);

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "nickname": nickname,
        "profile": profile,
        "userid": kakaoId,
      }),
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final token = body['token'];
      final nickname = body['nickname'];
      final profile = body['profile'];
      final logintype = body['logintype'];

      if (token != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        await prefs.setString('nickname', nickname);
        await prefs.setString('profile', profile);
        await prefs.setString('logintype', logintype);

        Provider.of<UserProvider>(context, listen: false).login(
          token,
          nickname,
          profile,
          logintype,
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