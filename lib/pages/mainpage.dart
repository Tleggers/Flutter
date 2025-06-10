import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trekkit_flutter/pages/gb/home_page.dart';
import 'package:trekkit_flutter/pages/gb/step/step_provider.dart';
import 'package:trekkit_flutter/pages/jw/CommunityPage.dart';
import 'package:provider/provider.dart';
import '../functions/jh/userprovider.dart';
import 'package:trekkit_flutter/pages/sh/map_page.dart';
import 'jh/mypage.dart';

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
    HomePage(),
    // 지도 화면
    MapPage(),
    // 커뮤니티 화면
    CommunityPage(),
    // 마이페이지 화면
    MyPage(),
  ];

  // 로고 옆에 있는 글자 리스트
  final List<String> _titles = ['트레킷', '지도', '커뮤니티', '마이페이지'];

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
            Image.asset(
              'assets/images/logo_final2.png',
              width: screenWidth * 0.12,
              height: screenHeight * 0.06,
              fit: BoxFit.contain,
            ),
            SizedBox(width: screenWidth * 0.02),
            Text(
              _titles[_selectedIndex],
              style: TextStyle(fontSize: screenWidth * 0.06),
            ),
          ],
        ),

        // 설정한 인덱스에서는 로그아웃 버튼 생기게 하기
        actions:
            _selectedIndex == 2
                ? [
                  Padding(
                    padding: EdgeInsets.only(right: screenWidth * 0.06),
                    child: TextButton(
                      onPressed: () async {
                        // 로그인 상태가 아닌 경우 -> 아무것도 안 함
                        final userProvider = Provider.of<UserProvider>(
                          context,
                          listen: false,
                        );
                        if (!userProvider.isLoggedIn) return;

                        final prefs = await SharedPreferences.getInstance();
                        final loginType = prefs.getString(
                          'logintype',
                        ); // 'NORMAL', 'KAKAO', 'GOOGLE'

                        try {
                          if (loginType == 'KAKAO') {
                            await UserApi.instance.logout();
                            await UserApi.instance
                                .unlink(); // 이건 배포 전 무조건 지워야함(매번 로그인을 띄우게 하기 위함)
                          } else if (loginType == 'GOOGLE') {
                            // final GoogleSignIn _googleSignIn = GoogleSignIn();
                            // await _googleSignIn.signOut();
                            await GoogleSignIn().signOut();
                            print('구글 로그아웃 완료');
                          } else {
                            print('일반 로그인 로그아웃');
                          }
                        } catch (e) {
                          print('소셜 로그아웃 실패: $e');
                        }

                        await prefs.remove('token');
                        await prefs.remove('logintype');
                        await prefs.remove('nickname');
                        await prefs.remove('profile');
                        await prefs.remove('index');

                        // Provider에서 로그인 상태 초기화
                        userProvider.logout();

                        // UI 메시지 출력
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('로그아웃 되었습니다')),
                          );
                        }
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.black, // 글자 색만 검정
                        backgroundColor: Colors.transparent, // 배경 투명
                        padding: EdgeInsets.zero, // 패딩 최소화
                        tapTargetSize:
                            MaterialTapTargetSize.shrinkWrap, // 클릭 영역 최소화
                        minimumSize: Size.zero, // 크기 최소화
                      ),
                      child: Text(
                        '로그아웃',
                        style: TextStyle(
                          color: Colors.blue.shade900,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ]
                : null,
      ),

      // IndexedStack -> 선택된 index 하나만 화면에 출력시킴
      body: IndexedStack(index: _selectedIndex, children: _pages),

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
  Widget _buildNavItem(
    String label,
    int index,
    double screenWidth,
    double screenHeight,
  ) {
    // 현재 선택된 인덱스(선택된 인덱스와 매개변수로 보낸 인덱스가 동일하면 변수에 넣기, 다를 경우를 방지)
    final isSelected = _selectedIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => _onItemSelect(index), // 누르면 ItemSelect에 인덱스 전달(0~3)
        // 네비게이션 바 UI
        child: Container(
          height: screenHeight * 0.07,
          color:
              isSelected
                  ? Colors.blue.shade100
                  : Colors.white, // 선택됐으면 shade100 아니면 white
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

  //0609 gb
  @override
  void initState() {
    super.initState();
    //initState()는 build()보다 먼저 호출되고,
    //이때 context.read()는 위젯 트리가 완전히 구축되지 않아서 실패할 수 있습니다.
    // context 안전하게 접근하기 위한 post-frame callback 사용
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final stepProvider = context.read<StepProvider>();
      stepProvider.fetchTodayStepFromServer();
      // stepProvider.fetchMonthlyStepFromServer();
    });
  }
}
