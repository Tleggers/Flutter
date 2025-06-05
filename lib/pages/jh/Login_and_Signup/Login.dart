import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../functions/jh/Login/UserProvider.dart';
import '../../MainPage.dart';
import 'Signup.dart';

// 로그인 페이지
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  // ID / PW 입력 컨트롤러
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();

  // 로그인 처리 함수
  Future<void> handleLogin() async {
    final id = _idController.text.trim();
    final pw = _pwController.text;

    // 정규식 정의
    final idRegex = RegExp(r'^[a-zA-Z0-9]{1,16}$');
    final pwRegex = RegExp(r'^[a-zA-Z0-9!@#%^&*]{1,16}$');

    // 입력값 비었는지 확인
    if (id.isEmpty || pw.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('아이디와 비밀번호를 모두 입력해주세요.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // 아이디 정규식 확인
    if (!idRegex.hasMatch(id)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('아이디는 영어/숫자만 사용하며 최대 16자까지 가능합니다.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // 비밀번호 정규식 확인
    if (!pwRegex.hasMatch(pw) || pw.contains(RegExp(r'[ㄱ-ㅎ가-힣]'))) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('비밀번호는 한글 없이, 영문/숫자/특수문자만 사용하며 최대 16자까지 가능합니다.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // 로그인 요청
    final url = Uri.parse('http://10.0.2.2:30000/login/dologin');
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "userid": id,
          "password": pw,
        }),
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final token = body['token'];
        final nickname = body['nickname'];
        final profile = body['profile'];

        print(token);
        print(nickname);
        print(profile);

        if (token != null) {
          // 로그인 성공 후 SharedPreferences에 저장
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', token);
          await prefs.setString('nickname', nickname);
          await prefs.setString('profile', profile);

          // Provider에 저장
          Provider.of<UserProvider>(context, listen: false).login(
            token,
            nickname,
            profile,
          );
          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const MainPage(title: '트레킷'),
            ),
          );
        } else {
          // 실패 처리
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('로그인 실패: 아이디 또는 비밀번호가 틀렸습니다.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        throw Exception('서버 오류');
      }
    } catch (e) {
      //  예외 처리
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('서버 통신 중 오류가 발생했습니다.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

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
              controller: _idController, // ✅ ID 입력 컨트롤러 연결
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
              controller: _pwController, // ✅ 비밀번호 입력 컨트롤러 연결
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
              height: screenHeight * 0.07,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: handleLogin, // ✅ 로그인 함수 호출
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