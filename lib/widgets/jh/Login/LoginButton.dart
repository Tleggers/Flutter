import 'package:flutter/material.dart';
import '../../../functions/jh/Login/KaKaoLogin.dart';
import '../../../services/jh/Login/HandleLogin.dart';

// 여러개의 로그인 버튼들을 모아놓은 위젯
class LoginButtonSection extends StatelessWidget {

  final TextEditingController idController;
  final TextEditingController pwController;
  final double screenWidth;
  final double screenHeight;
  final BuildContext context;

  const LoginButtonSection({
    super.key,
    required this.idController,
    required this.pwController,
    required this.screenWidth,
    required this.screenHeight,
    required this.context,
  });

  @override
  Widget build(BuildContext ctx) {
    
    return Column(
      children: [
        
        // 일반 로그인 버튼
        SizedBox(
          width: double.infinity,
          height: screenHeight * 0.07,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              final id = idController.text.trim();
              final pw = pwController.text.trim();
              loginHandler(context: context, id: id, pw: pw);
            },
            child: Text(
              '로그인',
              style: TextStyle(
                fontSize: screenWidth * 0.07,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        
        // 공백
        SizedBox(height: screenHeight * 0.02),
        
        // 네이버 로그인 버튼
        SizedBox(
          width: double.infinity,
          height: screenHeight * 0.07,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF03C75A),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              // 네이버 로그인 로직 추가 예정
            },
            label: Text(
              'NAVER로 로그인',
              style: TextStyle(
                fontSize: screenWidth * 0.065,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),

        SizedBox(height: screenHeight * 0.015),

        // ✅ 카카오 로그인 버튼
        SizedBox(
          width: double.infinity,
          height: screenHeight * 0.07,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFEE500), // 카카오 노란색
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              await loginWithKakao(); // 🔥 여기서 호출하면 됨
            },
            label: Text(
              'KAKAO로 로그인',
              style: TextStyle(
                fontSize: screenWidth * 0.065,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),

      ],
    );
  }
}