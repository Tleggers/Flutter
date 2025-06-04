import 'package:flutter/material.dart';

import '../../../pages/jh/Login_and_Signup/Login.dart';

// 프사, 닉네임 (로그인, 회원가입) 부분
class MyPageHeader extends StatelessWidget {

  final double screenWidth;
  final double screenHeight;

  const MyPageHeader({
    super.key,
    required this.screenWidth,
    required this.screenHeight,
  });

  @override
  Widget build(BuildContext context) {

    return GestureDetector(

      onTap: () {
        // 클릭시 실행되는 함수(비로그인시 -> 로그인, 로그인시 -> 회원정보 수정페이지)
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) =>  LoginPage()),
        );
      },

      child: Container(
        padding: EdgeInsets.all(screenWidth * 0.04),

        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 프로필 아이콘
            CircleAvatar(
              radius: screenWidth * 0.08,
              backgroundColor: Colors.grey.shade300,
              child: Icon(
                Icons.person,
                size: screenWidth * 0.08,
                color: Colors.white,
              ),
            ),

            SizedBox(width: screenWidth * 0.04),

            // 가운데 텍스트 영역
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '로그인 및 회원가입',
                    style: TextStyle(
                      fontSize: screenWidth * 0.043,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.001),
                  Text(
                    'TrekKit과 함께 한 걸음 더 가까이!',
                    style: TextStyle(
                      fontSize: screenWidth * 0.035,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),

            // 화살표 아이콘
            Icon(
              Icons.chevron_right,
              color: Colors.grey,
              size: screenWidth * 0.08,
            ),
          ],
        ),
      ),
    );
  }
}