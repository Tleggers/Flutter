import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trekkit_flutter/functions/jh/userprovider.dart';
import 'package:trekkit_flutter/pages/gb/step/step_home_widget.dart';
import 'package:trekkit_flutter/pages/gb/step/step_provider.dart';
import 'package:trekkit_flutter/pages/gb/suggest/suggest_home_widget.dart';

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
                        height: screenHeight * 0.14,
                        child: const StepHomeWidget(),
                      ),
                      SizedBox(height: screenHeight * 0.01),
                      Container(
                        height: screenHeight * 0.22,
                        color: Colors.orange[100],
                        child: const Center(child: Text('커뮤니티 최근글')),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: screenWidth * 0.04),
                Expanded(
                  child: Container(
                    height: screenHeight * 0.32,
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
            Text(
              '지금 인기있는 산',
              style: TextStyle(
                fontSize: screenWidth * 0.05,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: screenHeight * 0.02),
            Text(
              '테마별 코스',
              style: TextStyle(
                fontSize: screenWidth * 0.05,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: screenHeight * 0.02),
            Container(
              height: screenHeight * 0.25,
              color: Colors.purple[100],
              child: const Center(child: Text('테마별 코스 - 카테고리별 목록')),
            ),
          ],
        ),
      ),
    );
  }
}
