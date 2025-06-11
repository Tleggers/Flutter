import 'package:flutter/material.dart';

import 'bannercontent.dart';

class MyPageBanner extends StatelessWidget {

  final double screenWidth;
  final double screenHeight;

  const MyPageBanner({
    super.key,
    required this.screenWidth,
    required this.screenHeight,
  });

  @override
  Widget build(BuildContext context) {
    
    return GestureDetector(
      
      // 실행시 새 페이지로 이동
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const BannerContent()),
        );
      },
      
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: screenHeight * 0.02,
          horizontal: screenWidth * 0.04,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF2D3A68),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // 왼쪽 아이콘 원형 배경
            Container(
              padding: EdgeInsets.all(screenWidth * 0.015),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: Icon(Icons.lightbulb, color: Color(0xFF2D3A68), size: screenWidth*0.04),
            ),
            SizedBox(width: screenWidth * 0.04),

            // 텍스트 영역
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '우리 앱은 어떻게 사용하나요?',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: screenWidth * 0.04,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.004),
                  Text(
                    '한 눈에 알 수 있도록 알려드립니다!',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: screenWidth * 0.035,
                    ),
                  ),
                ],
              ),
            ),

            Icon(Icons.chevron_right, color: Colors.white, size: screenWidth*0.08),

          ],
        ),
      ),
    );
  }
}