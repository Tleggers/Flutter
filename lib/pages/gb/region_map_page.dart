import 'package:flutter/material.dart';
import 'package:trekkit_flutter/pages/gb/suggest/suggest_region_list_page.dart';

class RegionMap extends StatelessWidget {
  const RegionMap({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      color: const Color(0xFFF5F5F5),
      child: Center(
        child: Stack(
          children: [
            // 지도 이미지
            Center(
              child: Image.asset(
                'assets/images/korea_map.jpg',
                fit: BoxFit.contain,
                width: 0.9 * screenWidth,
                height: 0.7 * screenHeight,
              ),
            ),

            // 서울 마커
            Positioned(
              left: 0.455 * screenWidth * 0.55,
              top: 0.5 * screenHeight * 0.25,
              child: buildMarker(context, '서울', 'seoul'),
            ),

            // 경기 마커
            Positioned(
              left: 0.63 * screenWidth * 0.55,
              top: 0.65 * screenHeight * 0.25,
              child: buildMarker(context, '경기', 'gyeonggi'),
            ),

            // 강원 마커
            Positioned(
              left: 0.92 * screenWidth * 0.55,
              top: 0.4 * screenHeight * 0.25,
              child: buildMarker(context, '강원', 'gangwon'),
            ),

            // 충북 마커
            Positioned(
              left: 0.75 * screenWidth * 0.55,
              top: 0.85 * screenHeight * 0.25,
              child: buildMarker(context, '충북', 'chungbuk'),
            ),

            // 충남 마커
            Positioned(
              left: 0.45 * screenWidth * 0.55,
              top: 1.0 * screenHeight * 0.25,
              child: buildMarker(context, '충남', 'chungnam'),
            ),

            // 경북 마커
            Positioned(
              left: 1.075 * screenWidth * 0.55,
              top: 1.1 * screenHeight * 0.25,
              child: buildMarker(context, '경북', 'gyeongbuk'),
            ),

            // 경남 마커
            Positioned(
              left: 0.9 * screenWidth * 0.55,
              top: 1.6 * screenHeight * 0.25,
              child: buildMarker(context, '경남', 'gyeongnam'),
            ),

            // 전북 마커
            Positioned(
              left: 0.53 * screenWidth * 0.55,
              top: 1.4 * screenHeight * 0.25,
              child: buildMarker(context, '전북', 'jeonbuk'),
            ),

            // 전남 마커
            Positioned(
              left: 0.42 * screenWidth * 0.55,
              top: 1.75 * screenHeight * 0.25,
              child: buildMarker(context, '전남', 'jeonnam'),
            ),

            // 제주 마커
            Positioned(
              left: 0.311 * screenWidth * 0.55,
              top: 2.47 * screenHeight * 0.25,
              child: buildMarker(context, '제주', 'jeju'),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ 마커 위젯 빌더 분리 (코드 깔끔하게 정리)
  Widget buildMarker(BuildContext context, String label, String regionId) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RegionListPage(regionId: regionId),
          ),
        );
      },
      child: Column(
        children: [
          const Icon(Icons.location_on, color: Colors.red, size: 30),
          Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
