import 'package:flutter/material.dart';
import 'package:trekkit_flutter/pages/gb/suggest/suggest_random_list_page.dart'; // ✅ 수정된 부분
// Flutter UI 구성에 필요한 라이브러리

// 추천 코스 영역 위젯
class SuggestHomeWidget extends StatelessWidget {
  const SuggestHomeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width; // 화면 너비
    final screenHeight = MediaQuery.of(context).size.height; // 화면 높이

    // 추천 코스 UI 구성
    return GestureDetector(
      // 이미지 영역을 터치했을 때 이벤트 처리
      onTap: () {
        // 지역 선택 페이지로 이동 (페이지 전환)
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const SuggestRandomListPage(),
          ),
        );
      },
      child: Container(
        // 추천 코스 영역 크기 설정
        height: screenHeight * 0.32, // 화면의 32% 크기
        width: screenWidth, // 화면의 전체 너비
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/suggest.png'), // 숲길 이미지
            fit: BoxFit.cover, // 이미지가 컨테이너 크기에 맞게 확대/축소
          ),
          borderRadius: BorderRadius.circular(16), // 테두리 둥글게 설정
        ),
        child: Padding(
          padding: EdgeInsets.only(
            left: screenWidth * 0.03,
            top: screenHeight * 0.02,
          ), // 왼쪽 상단 패딩 추가
          child: Text(
            '어디로\n여행 가야 할지\n모르겠다면?', // 줄바꿈 추가
            style: TextStyle(
              fontSize: screenWidth * 0.045, // 텍스트 크기 줄이기
              fontWeight: FontWeight.bold, // 텍스트 두께
              color: Colors.white, // 텍스트 색상: 흰색
            ),
          ),
        ),
      ),
    );
  }
}
