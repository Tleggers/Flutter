import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../../../functions/jh/userprovider.dart';
import '../../../pages/mainpage.dart';

Future<void> loginWithGoogle(BuildContext context) async {

  try {

    final GoogleSignIn googleSignIn = GoogleSignIn(
      serverClientId: '719721622586-7hgas4saqrk7k61ii86fb1s3hv16ukc7.apps.googleusercontent.com',
    );
    final GoogleSignInAccount? account = await googleSignIn.signIn();

    if (account == null) {
      showSnackBar(context, '로그인이 취소되었습니다.');
      return;
    }

    final GoogleSignInAuthentication auth = await account.authentication;
    final String oauthId = account.id;
    final String nickname = account.displayName ?? '익명';
    final String profile = account.photoUrl ?? '';
    final type = "GOOGLE";

    final baseUrl = dotenv.env['API_URL']!; // 여기서 ! << 절대 null이면 안된다는 의미
    final url = Uri.parse('$baseUrl/login/sociallogin');

    // 백엔드로 전송할 데이터
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userid': oauthId,
        'nickname': nickname,
        'profile': profile,
        'type': type,
      }),
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final token = body['token']; // 토큰
      final nickname = body['nickname']; // 닉네임
      final profile = body['profile']; // 프로필 사진
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
    showSnackBar(context, '구글 로그인 중 오류 발생');
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