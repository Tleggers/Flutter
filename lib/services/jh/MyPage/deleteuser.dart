import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../../functions/jh/userprovider.dart';
import '../../../pages/mainpage.dart';

Future<void> deleteUser(BuildContext context) async {

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        title: const Text('회원탈퇴'),
        content: const Text('정말 탈퇴하시겠습니까?'),
        actions: [
          TextButton(
            child: const Text('아니요'),
            onPressed: () {
              Navigator.of(dialogContext).pop();
            },
          ),
          TextButton(
            child: const Text('예'),
            onPressed: () async {
              Navigator.of(dialogContext).pop();

              final baseUrl = dotenv.env['API_URL']!;
              final userProvider = Provider.of<UserProvider>(context, listen: false);
              final token = userProvider.token;
              final logintype = userProvider.logintype;

              try {
                final response = await http.post(
                  Uri.parse('$baseUrl/modify/delete'),
                  headers: {
                    "Authorization": "Bearer $token",
                    "X-Client-Type": "app",
                  },
                );

                if (response.statusCode == 200) {

                  final prefs = await SharedPreferences.getInstance();
                  await prefs.clear();
                  userProvider.logout();

                  if (!context.mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('회원탈퇴가 완료되었습니다.')),
                  );

                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const MainPage(title: 'TrekKit'),
                    ),
                        (route) => false,
                  );

                  if (logintype == 'KAKAO') {
                    if (await AuthApi.instance.hasToken()) {
                      try {
                        // ✅ 실제 유효한 토큰인지 확인
                        await UserApi.instance.accessTokenInfo();
                        await UserApi.instance.unlink();
                      } catch (e) {
                        print('카카오 unlink 실패 또는 토큰 무효: $e');
                      }
                    } else {
                      print('카카오 토큰 없음: 이미 로그아웃 상태일 수 있음');
                    }
                  } else if (userProvider.logintype == 'GOOGLE') {
                    await GoogleSignIn().disconnect(); // 구글 연결 해제
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('오류가 발생했습니다. 다시 시도해주세요.')),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('서버 오류가 발생했습니다.')),
                );
              }
            },
          ),
        ],
      );
    },
  );
}
