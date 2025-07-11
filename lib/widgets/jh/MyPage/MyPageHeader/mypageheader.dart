import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../functions/jh/userprovider.dart';
import '../../../../pages/jh/Login_and_Signup/login.dart';
import '../../../../pages/jh/MyPage/beforemodify.dart';
import '../../../../pages/jh/MyPage/modifypage.dart';
import 'profile.dart';

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

    final userProvider = Provider.of<UserProvider>(context); // Provider에서 로그인 정보 가져옴
    final isLoggedIn = userProvider.isLoggedIn; // 로그인 여부
    final nickname = userProvider.nickname; // 닉네임
    final logintype = userProvider.logintype; // 로그인 타입

    return GestureDetector(

      onTap: () async {
        if (!isLoggedIn) {
          // 로그인 안 되어있을 때 로그인 페이지로 이동
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => LoginPage()),
          );
        } else {
          // 로그인 되어있을 시 마이 페이지로 이동
          // logintype << LOCAL이면 BeforeModify , 아니면 ModifyPage로 이동
          if (logintype == 'LOCAL') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => BeforeModifyPage()),
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ModifyPage()),
            );
          }
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
                        : 'TrekKit에 한 걸음 더 가까이!',
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