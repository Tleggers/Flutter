import 'package:flutter/material.dart';

class MyPage extends StatelessWidget {
  const MyPage({super.key});

  @override
  Widget build(BuildContext context) {

    final screenWidth = MediaQuery.of(context).size.width; // 화면 가로 크기
    final screenHeight = MediaQuery.of(context).size.height; // 화면 세로 크기

    return Scaffold(

      // AppBar부분
      appBar: AppBar(
        
        // AppBar 알고리즘
        // 맨 왼쪽에 로고, 그 옆에 마이페이지
        // 오른쪽 끝에는 로그아웃 버튼,
        // 로그인 X -> 아무것도 안뜨고 로그인 O -> 로그아웃 버튼 뜨게

      ),

      body: Padding(
        padding: EdgeInsets.all(screenWidth*0.01),
        child: Column(
          children: [
            Text("하이")
          ],
        ),
      ),

    );
  }
}