import 'package:flutter/material.dart';
import 'Signup.dart';

// 로그인 페이지
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      resizeToAvoidBottomInset: true, // 키보드가 올라와도 자동으로 조정

      // AppBar
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close), // X 아이콘
          onPressed: () {
            Navigator.pop(context); // ← 이전 페이지로 돌아가기
          },
        ),
        title: const Text("TrekKit 로그인"),
      ),

      // 키보드가 올라와도 밀리지 않도록 SingleChildScrollView로 감싸기
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.08),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: screenHeight * 0.1),

            // 제목 느낌?
            Text(
              'Hello, Tlegger!',
              style: TextStyle(
                fontSize: screenWidth * 0.07,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: screenHeight * 0.05),

            // 아이디 입력
            Text(
              '아이디',
              style: TextStyle(
                  fontSize: screenWidth * 0.035, color: Colors.grey[700]),
            ),
            SizedBox(height: screenHeight * 0.008),
            TextField(
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
            Text(
              '비밀번호',
              style: TextStyle(
                  fontSize: screenWidth * 0.035, color: Colors.grey[700]),
            ),
            SizedBox(height: screenHeight * 0.008),
            TextField(
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

            SizedBox(height: screenHeight * 0.03),

            // 로그인 버튼
            SizedBox(
              width: double.infinity,
              height: screenHeight * 0.065,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  // 로그인 처리 함수
                },
                child: Text(
                  '로그인 😎',
                  style: TextStyle(fontSize: screenWidth * 0.045),
                ),
              ),
            ),

            SizedBox(height: screenHeight * 0.03),

            // 하단 링크들
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: () {
                    // 아이디 찾기 이동
                  },
                  child: Text(
                    '아이디 찾기',
                    style: TextStyle(fontSize: screenWidth * 0.035),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    // 비밀번호 찾기 이동
                  },
                  child: Text(
                    '비밀번호 찾기',
                    style: TextStyle(fontSize: screenWidth * 0.035),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SignupPage()),
                    );
                  },
                  child: Text(
                    '회원가입',
                    style: TextStyle(fontSize: screenWidth * 0.035),
                  ),
                ),
              ],
            ),

            SizedBox(height: screenHeight * 0.03),
          ],
        ),
      ),
    );
  }
}