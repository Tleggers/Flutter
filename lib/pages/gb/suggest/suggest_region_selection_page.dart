import 'package:flutter/material.dart';
import 'package:trekkit_flutter/pages/gb/suggest/suggest_region_list_page.dart';

class SuggestRegionSelectionPage extends StatelessWidget {
  const SuggestRegionSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 화면 크기 받아오기 (나중에 비율 조정에 쓸 수 있음)
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // 서울 마커 위치 (수동으로 설정, 이미지의 비율에 맞춰서 조정해야 함)
    final seoulX = screenWidth * 0.5; // 예시: 가운데쯤
    final seoulY = screenHeight * 0.3; // 예시: 위쪽 30% 위치

    return Scaffold(
      appBar: AppBar(
        title: const Text('지역 선택'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: Container(
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
                left:
                    0.525 *
                    screenWidth *
                    0.55, // 이미지 기준으로 좌표 맞춤 (조금 실험하면서 조절해야 함)
                top: 1.0 * screenHeight * 0.25,
                child: GestureDetector(
                  onTap: () {
                    // 여기서 상세 페이지로 이동 (지역 id 넘김)
                    print('서울 마커 클릭됨');
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RegionListPage(regionId: 'seoul'),
                      ),
                    );
                  },
                  child: Column(
                    children: [
                      Icon(Icons.location_on, color: Colors.red, size: 30),
                      const Text(
                        '서울',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 경기 마커
              Positioned(
                left:
                    0.69 *
                    screenWidth *
                    0.55, // 이미지 기준으로 좌표 맞춤 (조금 실험하면서 조절해야 함)
                top: 1.125 * screenHeight * 0.25,
                child: GestureDetector(
                  onTap: () {
                    // 여기서 상세 페이지로 이동 (지역 id 넘김)
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => RegionListPage(regionId: 'gyeonggi'),
                      ),
                    );
                  },
                  child: Column(
                    children: [
                      Icon(Icons.location_on, color: Colors.red, size: 30),
                      const Text(
                        '경기',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // 강원 마커
              Positioned(
                left:
                    0.98 *
                    screenWidth *
                    0.55, // 이미지 기준으로 좌표 맞춤 (조금 실험하면서 조절해야 함)
                top: 0.9 * screenHeight * 0.25,
                child: GestureDetector(
                  onTap: () {
                    // 여기서 상세 페이지로 이동 (지역 id 넘김)
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => RegionListPage(regionId: 'gangwon'),
                      ),
                    );
                  },
                  child: Column(
                    children: [
                      Icon(Icons.location_on, color: Colors.red, size: 30),
                      const Text(
                        '강원',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // 충북 마커
              Positioned(
                left:
                    0.82 *
                    screenWidth *
                    0.55, // 이미지 기준으로 좌표 맞춤 (조금 실험하면서 조절해야 함)
                top: 1.3 * screenHeight * 0.25,
                child: GestureDetector(
                  onTap: () {
                    // 여기서 상세 페이지로 이동 (지역 id 넘김)
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => RegionListPage(regionId: 'chungbuk'),
                      ),
                    );
                  },
                  child: Column(
                    children: [
                      Icon(Icons.location_on, color: Colors.red, size: 30),
                      const Text(
                        '충북',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // 충남 마커
              Positioned(
                left:
                    0.5 *
                    screenWidth *
                    0.55, // 이미지 기준으로 좌표 맞춤 (조금 실험하면서 조절해야 함)
                top: 1.45 * screenHeight * 0.25,
                child: GestureDetector(
                  onTap: () {
                    // 여기서 상세 페이지로 이동 (지역 id 넘김)
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => RegionListPage(regionId: 'chungnam'),
                      ),
                    );
                  },
                  child: Column(
                    children: [
                      Icon(Icons.location_on, color: Colors.red, size: 30),
                      const Text(
                        '충남',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // 경북 마커
              Positioned(
                left:
                    1.14 *
                    screenWidth *
                    0.55, // 이미지 기준으로 좌표 맞춤 (조금 실험하면서 조절해야 함)
                top: 1.55 * screenHeight * 0.25,
                child: GestureDetector(
                  onTap: () {
                    // 여기서 상세 페이지로 이동 (지역 id 넘김)
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => RegionListPage(regionId: 'gyeongbuk'),
                      ),
                    );
                  },
                  child: Column(
                    children: [
                      Icon(Icons.location_on, color: Colors.red, size: 30),
                      const Text(
                        '경북',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // 경남 마커
              Positioned(
                left:
                    1.0 *
                    screenWidth *
                    0.55, // 이미지 기준으로 좌표 맞춤 (조금 실험하면서 조절해야 함)
                top: 1.97 * screenHeight * 0.25,
                child: GestureDetector(
                  onTap: () {
                    // 여기서 상세 페이지로 이동 (지역 id 넘김)
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => RegionListPage(regionId: 'gyeongnam'),
                      ),
                    );
                  },
                  child: Column(
                    children: [
                      Icon(Icons.location_on, color: Colors.red, size: 30),
                      const Text(
                        '경남',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // 전북 마커
              Positioned(
                left:
                    0.6 *
                    screenWidth *
                    0.55, // 이미지 기준으로 좌표 맞춤 (조금 실험하면서 조절해야 함)
                top: 1.83 * screenHeight * 0.25,
                child: GestureDetector(
                  onTap: () {
                    // 여기서 상세 페이지로 이동 (지역 id 넘김)
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => RegionListPage(regionId: 'jeonbuk'),
                      ),
                    );
                  },
                  child: Column(
                    children: [
                      Icon(Icons.location_on, color: Colors.red, size: 30),
                      const Text(
                        '전북',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // 전남 마커
              Positioned(
                left:
                    0.52 *
                    screenWidth *
                    0.55, // 이미지 기준으로 좌표 맞춤 (조금 실험하면서 조절해야 함)
                top: 2.122 * screenHeight * 0.25,
                child: GestureDetector(
                  onTap: () {
                    // 여기서 상세 페이지로 이동 (지역 id 넘김)
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => RegionListPage(regionId: 'jeonnam'),
                      ),
                    );
                  },
                  child: Column(
                    children: [
                      Icon(Icons.location_on, color: Colors.red, size: 30),
                      const Text(
                        '전남',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // 제주 마커
              Positioned(
                left:
                    0.381 *
                    screenWidth *
                    0.55, // 이미지 기준으로 좌표 맞춤 (조금 실험하면서 조절해야 함)
                top: 2.8 * screenHeight * 0.25,
                child: GestureDetector(
                  onTap: () {
                    // 여기서 상세 페이지로 이동 (지역 id 넘김)
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RegionListPage(regionId: 'jeju'),
                      ),
                    );
                  },
                  child: Column(
                    children: [
                      Icon(Icons.location_on, color: Colors.red, size: 30),
                      const Text(
                        '제주',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
