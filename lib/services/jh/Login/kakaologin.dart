import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

import '../../../functions/jh/userprovider.dart';
import '../../../pages/mainpage.dart';

Future<void> loginWithKakao(BuildContext context) async {

  try {

    // 1. 카카오 로그인
    OAuthToken token;

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
    final baseUrl = dotenv.env['API_URL']!; // 여기서 ! << 절대 null이면 안된다는 의미
    final url = Uri.parse('$baseUrl/login/sociallogin');

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "X-Client-Type": "app", // 클라이언트 타입
      },
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