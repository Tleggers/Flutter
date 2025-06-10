import 'package:flutter/material.dart';
import '../../../pages/jh/FindIdAndPassword/findidpage.dart';
import '../../../pages/jh/FindIdAndPassword/findpwpage.dart';
import '../../../pages/jh/Login_and_Signup/signup.dart';

// 회원가입, 아이디 및 비밀번호 링크 
class LoginLink extends StatelessWidget {
  final double screenWidth;
  const LoginLink({super.key, required this.screenWidth});

  @override
  Widget build(BuildContext context) {
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      
      children: [
        
        // 아이디 찾기
        GestureDetector(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const FindIdPage()));
          },
          child: Text('아이디 찾기', style: TextStyle(fontSize: screenWidth * 0.035)),
        ),
        
        // 비밀번호 찾기
        GestureDetector(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const FindPwPage()));
          },
          child: Text('비밀번호 찾기', style: TextStyle(fontSize: screenWidth * 0.035)),
        ),
        
        // 회원가입
        GestureDetector(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const SignupPage()));
          },
          child: Text('회원가입', style: TextStyle(fontSize: screenWidth * 0.035)),
        ),
      ],
    );
  }
}
