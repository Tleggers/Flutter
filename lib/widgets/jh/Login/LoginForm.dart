import 'package:flutter/material.dart';

// 타이틀 및 아이디 + 비밀번호 입력 창
class LoginFormSection extends StatelessWidget {

  // 컨트롤러
  final TextEditingController idController;
  final TextEditingController pwController;
  final double screenWidth;
  final double screenHeight;

  const LoginFormSection({
    super.key,
    required this.idController,
    required this.pwController,
    required this.screenWidth,
    required this.screenHeight,
  });

  @override
  Widget build(BuildContext context) {
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      
      children: [
        
        // 타이틀? 제목? 암튼 그 사이 무언가
        Text(
          'Hello, Tlegger!',
          style: TextStyle(
            fontSize: screenWidth * 0.07,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: screenHeight * 0.05),

        // 아이디 입력
        Text('아이디', style: TextStyle(fontSize: screenWidth * 0.035, color: Colors.grey[700])),
        SizedBox(height: screenHeight * 0.008),
        TextField(
          controller: idController,
          decoration: InputDecoration(
            hintText: '아이디를 입력해 주세요.',
            hintStyle: TextStyle(fontSize: screenWidth * 0.035),
            contentPadding: EdgeInsets.symmetric(
              vertical: screenHeight * 0.015,
              horizontal: screenWidth * 0.03,
            ),
            border: const UnderlineInputBorder(),
          ),
        ),

        SizedBox(height: screenHeight * 0.035),

        // 비밀번호 입력
        Text('비밀번호', style: TextStyle(fontSize: screenWidth * 0.035, color: Colors.grey[700])),
        SizedBox(height: screenHeight * 0.008),
        TextField(
          controller: pwController,
          obscureText: true,
          decoration: InputDecoration(
            hintText: '비밀번호를 입력해 주세요.',
            hintStyle: TextStyle(fontSize: screenWidth * 0.035),
            contentPadding: EdgeInsets.symmetric(
              vertical: screenHeight * 0.015,
              horizontal: screenWidth * 0.03,
            ),
            border: const UnderlineInputBorder(),
          ),
        ),
      ],
    );
  }
}