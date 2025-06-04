import 'package:flutter/material.dart';

import 'jh/MyPage.dart';

// 메인 화면
class MainPage extends StatefulWidget {
  final String title;

  const MainPage({super.key, required this.title});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  
  // 현재 선택된 화면 인덱스
  int _selectedIndex = 0; // 0: 홈, 1: 지도, 2: 커뮤니티, 3: 마이페이지

  final List<Widget> _pages = [

    // 이 밑에 화면으로 이동하는 함수 추가할 것
    // 홈 화면
    // 지도 화면
    // 커뮤니티 화면
    // 마이페이지 화면
    MyPage()
    
  ];

  // 로고 옆에 있는 글자 리스트
  final List<String> _titles = [
    '트레킷',
    '지도',
    '커뮤니티',
    '마이페이지',
  ];

  // 선택된 화면으로 변경하는 State
  void _onItemSelect(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    
    // 실행하고 있는 화면의 가로 및 세로
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [

            // 여기에 로고 추가
            Image.asset(
              'assets/images/logo_final1.png', // 로고 이미지
              width: screenWidth * 0.12, // 너비 비율
              height: screenHeight * 0.06, // 높이 비율
              fit: BoxFit.contain,
            ),

            SizedBox(width: screenWidth * 0.02),

            // 선택된 화면의 제목을 출력
            Text(
              _titles[_selectedIndex],
              style: TextStyle(fontSize: screenWidth * 0.06), // 글자 크기
            ),

          ],
        ),
      ),

      // IndexedStack -> 선택된 index 하나만 화면에 출력시킴
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),

      // 하단바
      // 하단바에는 홈, 지도, 커뮤니티, 마이 총 4개,
      // 각각의 인덱스: 0~3
      bottomNavigationBar: Row(
        children: [
          _buildNavItem("홈", 0, screenWidth, screenHeight),
          _buildNavItem("지도", 1, screenWidth, screenHeight),
          _buildNavItem("커뮤니티", 2, screenWidth, screenHeight),
          _buildNavItem("마이", 3, screenWidth, screenHeight),
        ],
      ),
    );
  }

  // NavItem 위젯
  Widget _buildNavItem(String label, int index, double screenWidth, double screenHeight) {

    // 현재 선택된 인덱스(선택된 인덱스와 매개변수로 보낸 인덱스가 동일하면 변수에 넣기, 다를 경우를 방지)
    final isSelected = _selectedIndex == index;

    return Expanded(
      
      child: GestureDetector(
        onTap: () => _onItemSelect(index), // 누르면 ItemSelect에 인덱스 전달(0~3)
        
        // 네비게이션 바 UI
        child: Container(
          height: screenHeight * 0.07,
          color: isSelected ? Colors.blue.shade100 : Colors.white, // 선택됐으면 shade100 아니면 white
          alignment: Alignment.center, // 중앙 정렬
          child: Text(
            label, // 매개변수로 전달받은 label
            style: TextStyle(
              fontSize: screenWidth * 0.04,
              color: isSelected ? Colors.blue : Colors.grey,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}