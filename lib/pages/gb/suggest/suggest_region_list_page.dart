import 'package:flutter/material.dart';
import 'package:trekkit_flutter/api/suggest_mountain_api.dart';
import 'package:trekkit_flutter/api/suggest_mountain_image_api.dart';
import 'package:trekkit_flutter/models/gb/suggest_mountain.dart';
import 'package:trekkit_flutter/pages/gb/detail/mountain_detail_page.dart';

/// ✅ 지역별 산 리스트 페이지 (걷기길 탭 제거 버전)
class RegionListPage extends StatefulWidget {
  final String regionId; // 선택한 지역 ID (예: seoul, gangwon 등)

  const RegionListPage({super.key, required this.regionId});

  @override
  State<RegionListPage> createState() => _RegionListPageState();
}

class _RegionListPageState extends State<RegionListPage> {
  // ✅ 영어 regionId → 한글 지역명 매핑 테이블
  final Map<String, String> regionNameMap = {
    'seoul': '서울',
    'gyeonggi': '경기',
    'gangwon': '강원',
    'chungbuk': '충북',
    'chungnam': '충남',
    'jeonbuk': '전북',
    'jeonnam': '전남',
    'gyeongbuk': '경북',
    'gyeongnam': '경남',
    'jeju': '제주',
  };

  @override
  Widget build(BuildContext context) {
    // ✅ 영문 regionId를 한글 지역명으로 변환
    String regionName = regionNameMap[widget.regionId] ?? widget.regionId;

    return Scaffold(
      appBar: AppBar(
        title: Text(regionName), // 상단에 한글 지역명 출력
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: _buildMountainList(regionName), // ✅ 산 리스트만 출력 (탭 제거)
    );
  }

  /// ✅ 산 리스트 빌드
  Widget _buildMountainList(String regionName) {
    return FutureBuilder<List<SuggestMountain>>(
      future: SuggestMountainApi.fetchMountains(), // 전체 산 데이터 API 호출
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator()); // 로딩 중
        } else if (snapshot.hasError) {
          return const Center(child: Text('데이터 로딩 실패')); // 에러 처리
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('산 데이터 없음')); // 데이터 없음
        } else {
          final allMountains = snapshot.data!;

          // ✅ 해당 지역명 포함되는 산만 필터링
          final filtered =
              allMountains.where((mountain) {
                return mountain.location.contains(regionName);
              }).toList();

          return ListView.builder(
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              final mountain = filtered[index];

              // ✅ 각 산에 대해 이미지도 비동기로 불러오기
              return FutureBuilder<String?>(
                future: SuggestMountainImageApi.fetchImagesByMountainCode(
                  mountain.id,
                ).then((images) {
                  if (images.isNotEmpty) {
                    return images[0].fullImageUrl;
                  } else {
                    return null;
                  }
                }),
                builder: (context, snapshot) {
                  Widget leadingWidget;
                  final imageUrl = snapshot.data;

                  // ✅ 이미지 로딩 상태에 따라 다르게 출력
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    leadingWidget = Container(
                      width: 60,
                      height: 60,
                      color: Colors.grey[300],
                      child: const CircularProgressIndicator(),
                    );
                  } else if (snapshot.hasError ||
                      !snapshot.hasData ||
                      snapshot.data == null) {
                    leadingWidget = Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.image,
                        size: 30,
                        color: Color.fromARGB(255, 100, 201, 103),
                      ),
                    );
                  } else {
                    leadingWidget = Image.network(
                      snapshot.data!,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    );
                  }

                  // ✅ 최종 리스트 항목 출력
                  return ListTile(
                    leading: leadingWidget,
                    title: Text(mountain.name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (mountain.height != 0)
                          Text('${mountain.height}m'), // 높이 출력
                        Text(shortLocation(mountain.location)), // 간략 소재지 출력
                      ],
                    ),
                    onTap: () {
                      // ✅ 상세 페이지 이동 (이미지도 함께 전달)
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => MountainDetailPage(
                                mountainName: mountain.name,
                                imageUrl: imageUrl,
                              ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        }
      },
    );
  }

  /// ✅ 소재지 간략화 함수 (시/군까지만 표시)
  String shortLocation(String? location) {
    if (location == null || location.isEmpty) return '';

    final firstPart = location.split(',')[0].trim();
    final parts = firstPart.split(' ');
    if (parts.length >= 2) {
      return '${parts[0]} ${parts[1]}';
    } else {
      return firstPart;
    }
  }
}
