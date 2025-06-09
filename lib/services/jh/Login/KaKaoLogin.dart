import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

import '../../../functions/jh/UserProvider.dart';
import '../../../pages/MainPage.dart';

Future<void> loginWithKakao(BuildContext context) async {

  print('카카오 접속 성공'); // 얘는 들어옴

  try {

    // 1. 카카오 로그인
    OAuthToken token;

    // 혹여나 토큰이 남아있으면 제거
    if (await AuthApi.instance.hasToken()) {
      try {
        await UserApi.instance.logout();
      } catch (e) {
        showSnackBar(context, '로그아웃 중 오류 발생.');
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
    final type = "KAKAO";

    // 3. 백엔드로 POST 요청 보내기
    // final url = Uri.parse('http://10.0.2.2:30000/login/sociallogin'); // 에뮬레이터
    // final url = Uri.parse('http://192.168.0.7:30000/login/sociallogin'); // 실제 기기(주소는 각자 주소 넣기)
    final url = Uri.parse('http://192.168.0.51:30000/login/sociallogin'); // 실제 기기2(주소는 각자 주소 넣기)

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "nickname": nickname,
        "profile": profile,
        "userid": kakaoId,
        "type": type,
      }),
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final token = body['token']; // 토큰
      final nickname = body['nickname']; // 닉네임
      final profile = body['profile']; // 프로필
      final logintype = body['logintype']; // 로그인 타입
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
          index
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