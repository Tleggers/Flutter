import 'package:flutter/material.dart';
import '../../../widgets/jh/Login/EtcLink.dart';
import '../../../widgets/jh/Login/LoginButton.dart';
import '../../../widgets/jh/Login/LoginForm.dart';

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

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      
      // AppBar
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("TrekKit 로그인"),
      ),
      
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.08),
        
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          
          children: [
            
            // 공백
            SizedBox(height: screenHeight * 0.1),
            
            // 타이틀 + 아이디 및 비밀번호 입력창
            LoginFormSection(
              idController: _idController,
              pwController: _pwController,
              screenWidth: screenWidth,
              screenHeight: screenHeight,
            ),
            
            // 공백
            SizedBox(height: screenHeight * 0.03),
            
            // 로그인 버튼들 위젯
            LoginButtonSection(
              idController: _idController,
              pwController: _pwController,
              screenWidth: screenWidth,
              screenHeight: screenHeight,
              context: context,
            ),
            
            // 공백
            SizedBox(height: screenHeight * 0.03),
            
            // 아이디 및 비밀번호 찾기 + 회원가입 위젯
            LoginLink(screenWidth: screenWidth),
            SizedBox(height: screenHeight * 0.03),
          ],
        ),
      ),
    );
  }
}