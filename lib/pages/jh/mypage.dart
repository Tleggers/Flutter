import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../functions/jh/userprovider.dart';
import '../../widgets/jh/MyPage/MyPageBanner/mypagebanner.dart';
import '../../widgets/jh/MyPage/MyPageHeader/mypageheader.dart';
import '../../widgets/jh/MyPage/MyPageHeader/point/point_widget.dart';
import '../../widgets/jh/MyPage/MyPagePolicy/policysection.dart';
import '../../widgets/jh/MyPage/MyPageUse/mypageusesection.dart';

// 마이페이지
class MyPage extends StatelessWidget {
  
  const MyPage({super.key});

  @override
  Widget build(BuildContext context) {
    
    final screenWidth = MediaQuery.of(context).size.width; // 화면 가로 크기
    final screenHeight = MediaQuery.of(context).size.height; // 화면 세로 크기
    final userProvider = Provider.of<UserProvider>(context); // Provider
    final isLoggedIn = userProvider.isLoggedIn; // 현재 로그인 여부

    return Scaffold(
      
      // 혹시나 스크롤을 하게 될 수도 있어 ListView사용
      body: ListView(
        padding: EdgeInsets.all(screenWidth * 0.02), // 전체 패딩

        children: [

          // 프로필 박스
          // 비 로그인 시 로그인 및 회원가입
          // 로그인 시 프사 및 닉네임, 끝쪽에 있는 버튼 클릭 시 회원정보 수정(비 로그인 시는 눌러도 아무 효과 없게)
          // MyPageHeader -> 로그인 및 회원가입 있는 Container
          MyPageHeader(screenWidth: screenWidth, screenHeight: screenHeight,),

          // 로그인 상태라면 Point와 걸음수가 나와있는 위젯 호출
          isLoggedIn
              ? PointWidget(
            screenWidth: screenWidth,
            screenHeight: screenHeight,
          ): SizedBox.shrink(), // 로그인 안한 상태면 출력 X

          SizedBox(height: screenHeight * 0.01),

          // 우리 앱은? 배너
          MyPageBanner(screenWidth: screenWidth, screenHeight: screenHeight),

          SizedBox(height: screenHeight * 0.02),
          
          Divider(thickness: screenHeight*0.005), // 가로 선
          
          // TrekKit 이용하기
          MyPageUseSection(screenWidth: screenWidth, screenHeight: screenHeight),

          SizedBox(height: screenHeight * 0.015), // 공백

          Divider(thickness: screenHeight*0.005), // 가로 선

          // 이용약관 버튼
          MyPagePolicySection( screenWidth: screenWidth, screenHeight: screenHeight,),

        ],
      ),
    );
  }
}