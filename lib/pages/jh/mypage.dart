import 'package:flutter/material.dart';

import '../../widgets/jh/MyPage/mypageheader.dart';

// 마이페이지
class MyPage extends StatelessWidget {
  
  const MyPage({super.key});

  @override
  Widget build(BuildContext context) {
    
    final screenWidth = MediaQuery.of(context).size.width; // 화면 가로 크기
    final screenHeight = MediaQuery.of(context).size.height; // 화면 세로 크기

    return Scaffold(
      
      // 혹시나 스크롤을 하게 될 수도 있어 ListView사용
      body: ListView(
        padding: EdgeInsets.all(screenWidth * 0.03), // 전체 패딩

        children: [

          // 프로필 박스
          Container(
            padding: EdgeInsets.all(screenWidth * 0.01),

            // 비 로그인 시 로그인 및 회원가입
            // 로그인 시 프사 및 닉네임, 끝쪽에 있는 버튼 클릭 시 회원정보 수정(비 로그인 시는 눌러도 아무 효과 없게)
            // MyPageHeader -> 로그인 및 회원가입 있는 Container
            child: MyPageHeader(screenWidth: screenWidth, screenHeight: screenHeight,),

          ),

          SizedBox(height: screenHeight * 0.02), // 공백
          
          Divider(thickness: screenHeight*0.01), // 가로 선

          SizedBox(height: screenHeight * 0.015), // 위쪽 공백(선과 아래 요소를 나누기 위함)
          
          // 이 자리에 포인트/뱃지/스탬프 만들어서 넣기

          SizedBox(height: screenHeight * 0.015), // 공백

          // 북마크 내역을 출력 시켜줄 Container
          Container(
            height: screenHeight * 0.12, // Container 높이
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black),
            ),
            child: const Text('북마크 내역'), // 이건 나중에 지울 계획
          ),

          SizedBox(height: screenHeight * 0.015), // 공백
          
          // Q&A 버튼

          SizedBox(height: screenHeight * 0.015), // 공백
          
          // 공지사항 버튼

          SizedBox(height: screenHeight * 0.03),
          
          // 이용약관 버튼

        ],
      ),
    );
  }
}