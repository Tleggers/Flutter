import 'package:flutter/material.dart';
// 인기 등산 코스를 보여주는 커스텀 위젯을 불러옴
import 'package:trekkit_flutter/pages/gb/popular_mountain.dart';

// 홈 화면을 나타내는 Stateless 위젯
class HomePage extends StatelessWidget {
  const HomePage({super.key}); // 생성자, super.key로 부모 StatelessWidget의 key 설정 가능

  @override
  Widget build(BuildContext context) {
    // 화면 너비와 높이를 가져오는 변수 (반응형 레이아웃에 사용)
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // 전체 화면 구조를 반환
    return Scaffold(
      // 화면의 내용을 스크롤 가능하게 만듦
      body: SingleChildScrollView(
        // 화면 양쪽에 패딩 설정 (화면 너비의 4%)
        padding: EdgeInsets.all(screenWidth * 0.04),
        // 화면 전체를 세로 방향으로 구성
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // 왼쪽 정렬
          children: [
            // 화면 상단: 만보기 + 추천 코스 + 커뮤니티 구성하는 Row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start, // 위쪽 정렬
              children: [
                // 왼쪽 영역: 만보기와 커뮤니티 영역을 세로로 쌓음
                SizedBox(
                  width: screenWidth * 0.45, // 전체 너비의 45% 차지
                  child: Column(
                    children: [
                      // 만보기 영역
                      Container(
                        height: screenHeight * 0.075, // 전체 높이의 7.5%
                        color: Colors.green[100], // 연한 초록색 배경
                        child: Center(
                          child: Text('만보기 영역'), // 가운데 텍스트
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.02), // 세로 간격 (2%)
                      // 커뮤니티 최근 글 영역
                      Container(
                        height: screenHeight * 0.225, // 전체 높이의 22.5%
                        color: Colors.orange[100], // 연한 주황색 배경
                        child: Center(
                          child: Text('커뮤니티 최근글'), // 가운데 텍스트
                        ),
                      ),
                    ],
                  ),
                ),
                // 왼쪽과 오른쪽 사이 간격
                SizedBox(width: screenWidth * 0.04), // 너비의 4%
                // 오른쪽 추천 코스 영역
                Expanded(
                  // Row의 나머지 공간 모두 사용
                  child: Container(
                    height: screenHeight * 0.32, // 전체 높이의 32%
                    color: Colors.blue[100], // 연한 파란색 배경
                    child: Center(
                      child: Text('추천 코스'), // 가운데 텍스트
                    ),
                  ),
                ),
              ],
            ),

            // 위 Row 아래 간격
            SizedBox(height: screenHeight * 0.04), // 전체 높이의 4%
            // 인기 등산 코스 섹션 (외부 위젯)
            Text(
              '지금 인기있는 산',
              style: TextStyle(
                fontSize: screenWidth * 0.05, // 반응형 폰트 크기
                fontWeight: FontWeight.bold, // 굵은 글씨
              ),
            ),
            PopularCourseSection(
              screenWidth: screenWidth, // 화면 너비 전달
              screenHeight: screenHeight, // 화면 높이 전달
            ),

            SizedBox(height: screenHeight * 0.02), // 아래 간격 (2%)
            // 테마별 코스 제목
            Text(
              '테마별 코스',
              style: TextStyle(
                fontSize: screenWidth * 0.05, // 반응형 폰트 크기
                fontWeight: FontWeight.bold, // 굵은 글씨
              ),
            ),

            SizedBox(height: screenHeight * 0.02), // 제목 아래 간격 (2%)
            // 테마별 코스 목록 (예시 컨테이너)
            Container(
              height: screenHeight * 0.25, // 전체 높이의 25%
              color: Colors.purple[100], // 연한 보라색 배경
              child: Center(
                child: Text('테마별 코스 - 카테고리별 목록'), // 가운데 텍스트
              ),
            ),
          ],
        ),
      ),
    );
  }
}
