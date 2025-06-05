import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';

Future<void> loginWithKakao() async {
  try {
    // 카카오톡 설치됨
    if (await isKakaoTalkInstalled()) {
      await UserApi.instance.loginWithKakaoTalk();
    } else {
      await UserApi.instance.loginWithKakaoAccount();
    }

    final user = await UserApi.instance.me();
    print("✅ 로그인 성공: ${user.kakaoAccount?.email}, ${user.kakaoAccount?.profile?.nickname}");

    // 여기서 백엔드에 토큰 전달하거나 JWT 받아오는 코드 넣으면 됨

  } catch (e) {
    print("❌ 로그인 실패: $e");
  }
}