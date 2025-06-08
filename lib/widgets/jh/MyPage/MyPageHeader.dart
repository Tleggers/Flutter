import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../functions/jh/Login/UserProvider.dart';
import '../../../pages/jh/Login_and_Signup/Login.dart';
import 'MyPageHeader/Profile.dart';

// 프사, 닉네임 (로그인, 회원가입) 부분
class MyPageHeader extends StatefulWidget {
  final double screenWidth;
  final double screenHeight;

  const MyPageHeader({
    super.key,
    required this.screenWidth,
    required this.screenHeight,
  });

  @override
  State<MyPageHeader> createState() => _MyPageHeaderState();
}

class _MyPageHeaderState extends State<MyPageHeader> {
  @override
  Widget build(BuildContext context) {

    final userProvider = Provider.of<UserProvider>(context); // ✅ Provider에서 로그인 정보 가져옴
    final isLoggedIn = userProvider.isLoggedIn;
    final nickname = userProvider.nickname;
    final index = userProvider.index;

    return GestureDetector(

      onTap: () async {
        if (!isLoggedIn) {
          // 로그인 안 되어있을 때 로그인 페이지로 이동
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => LoginPage()),
          );
        } else {
          // 로그인 시 마이페이지로 이동하는 코드 추가
        }
      },

      child: Container(
        padding: EdgeInsets.all(widget.screenWidth * 0.04),

        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            
            // 프로필 아이콘
            // 로그인 O + 프로필 O -> 이미지
            // 로그인 O + 프로필 X -> 아이콘
            // 로그인 X -> 아이콘
            ProfileAvatar(screenWidth: widget.screenWidth),

            SizedBox(width: widget.screenWidth * 0.04),

            // 가운데 텍스트 영역
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    isLoggedIn ? '$nickname님 환영합니다!' : '로그인 및 회원가입',
                    style: TextStyle(
                      fontSize: widget.screenWidth * 0.043,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: widget.screenHeight * 0.001),
                  Text(
                    isLoggedIn
                        ? '트레킷과 함께 즐거운 산행 되세요!'
                        : 'TrekKit과 함께 한 걸음 더 가까이!',
                    style: TextStyle(
                      fontSize: widget.screenWidth * 0.035,
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
              size: widget.screenWidth * 0.08,
            ),
          ],
        ),
      ),
    );
  }
}