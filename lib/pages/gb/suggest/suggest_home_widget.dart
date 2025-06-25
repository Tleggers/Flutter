import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:trekkit_flutter/pages/gb/suggest/suggest_random_list_page.dart';
import 'package:provider/provider.dart';
import '../../../functions/jh/userprovider.dart';
import '../../../widgets/jh/MyPage/MyPageHeader/point/point_charge_page.dart'; // ✅ 수정된 부분
// Flutter UI 구성에 필요한 라이브러리

// 추천 코스 영역 위젯
class SuggestHomeWidget extends StatelessWidget {
  const SuggestHomeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width; // 화면 너비
    final screenHeight = MediaQuery.of(context).size.height; // 화면 높이
    final baseUrl = dotenv.env['API_URL']!;

    final userProvider = Provider.of<UserProvider>(context);
    final point = userProvider.point ?? 0;
    final userid = userProvider.index;
    final token = userProvider.token;

    // 추천 코스 UI 구성
    return GestureDetector(
      // 이미지 영역을 터치했을 때 이벤트 처리
      onTap: () async {
        // 팝업창 출력
        final shouldProceed = await showDialog<bool>(
          context: context,
          builder: (BuildContext dialogContext) {
            return AlertDialog(
              title: const Text('포인트 차감 안내'),
              content: const Text('추천 코스를 확인하려면\n보유 포인트에서 10포인트가 차감됩니다.\n열람하시겠습니까?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: const Text('아니오'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  child: const Text('예'),
                ),
              ],
            );
          },
        );

        if (shouldProceed != true) return;

        if (point < 10) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('포인트가 부족합니다.')),
            );

            Future.delayed(const Duration(seconds: 1), () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => PointChargePage()),
              );
            });
          }
          return;
        }

        try {
          final response = await http.post(
            Uri.parse('$baseUrl/pay/use'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
              'X-Client-Type': 'app',
            },
            body: jsonEncode({
              'point': 10,
              'userpoint': point,
              'id': userid,
            }),
          );

          if (response.statusCode == 200) {

            // 이동 전에 Provider에 포인터 차감
            userProvider.addPoint(-10);

            // 이동
            if (!context.mounted) return;
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SuggestRandomListPage()),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('추천 코스 열람에 실패했습니다.')),
            );
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('네트워크 오류가 발생했습니다.')),
          );
        }
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
