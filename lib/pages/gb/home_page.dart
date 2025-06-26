import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trekkit_flutter/functions/jh/userprovider.dart';
import 'package:trekkit_flutter/pages/gb/step/step_home_widget.dart';
import 'package:trekkit_flutter/pages/gb/step/step_provider.dart';
import 'package:trekkit_flutter/pages/gb/suggest/suggest_home_widget.dart';
import 'package:trekkit_flutter/pages/gb/region_map_page.dart';
import 'package:trekkit_flutter/pages/gb/community/community_preview_list.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();

    // ✅ 로그인한 경우에만 userId 설정 0609
    final userProvider = context.read<UserProvider>();
    final stepProvider = context.read<StepProvider>();

    if (userProvider.isLoggedIn) {
      stepProvider.setUserId(userProvider.index!); // null이 아님을 보장
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: screenWidth * 0.45,
                  child: Column(
                    children: [
                      SizedBox(
                        height: screenHeight * 0.107,
                        child: const StepHomeWidget(),
                      ),
                      SizedBox(height: screenHeight * 0.01),
                      Container(
                        height: screenHeight * 0.22,
                        child: const CommunityPreviewList(),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: screenWidth * 0.04),
                Expanded(
                  child: Container(
                    height: screenHeight * 0.335,
                    decoration: BoxDecoration(
                      color: Colors.blue[100], // 배경 색
                      borderRadius: BorderRadius.circular(16), // 테두리 둥글게
                    ),
                    child: const SuggestHomeWidget(), // 추천 코스 영역 추가
                  ),
                ),
              ],
            ),
            SizedBox(height: screenHeight * 0.04),

            // ✅ 자연 느낌 배너 추가 버전
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFA8E6CF), Color(0xFFDCEDC1)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.3),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(width: 12),
                  const Text(
                    '원하는 지역을 선택해보세요!',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            const RegionMap(),
          ],
        ),
      ),
    );
  }
}
