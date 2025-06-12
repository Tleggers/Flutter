import 'package:flutter/material.dart';
import 'package:trekkit_flutter/api/suggest_mountain_api.dart';
import 'package:trekkit_flutter/api/suggest_mountain_image_api.dart';
import 'package:trekkit_flutter/models/gb/suggest_mountain.dart';
import 'package:trekkit_flutter/pages/gb/mountain_detail_page.dart';

// ✅ 지역 리스트 페이지
class RegionListPage extends StatefulWidget {
  final String regionId; // 선택한 지역 ID (예: seoul, gangwon 등)

  const RegionListPage({super.key, required this.regionId});

  @override
  State<RegionListPage> createState() => _RegionListPageState();
}

class _RegionListPageState extends State<RegionListPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

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
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this); // 탭 2개 (산, 걷기길)
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String regionName = regionNameMap[widget.regionId] ?? widget.regionId;

    return Scaffold(
      appBar: AppBar(
        title: Text(regionName), // 상단 지역명 출력
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [Tab(text: '산'), Tab(text: '걷기길')],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildMountainList(regionName), _buildTrailList()],
      ),
    );
  }

  // ✅ 산 리스트 위젯
  Widget _buildMountainList(String regionName) {
    return FutureBuilder<List<SuggestMountain>>(
      future: SuggestMountainApi.fetchMountains(), // 산림청 API에서 전체 산 데이터 불러오기
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text('데이터 로딩 실패'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('산 데이터 없음'));
        } else {
          final allMountains = snapshot.data!;

          // ✅ 해당 지역명 포함되는 산만 필터링
          final filtered =
              allMountains.where((mountain) {
                return mountain.location.contains(regionName);
              }).toList();

          // ✅ 랜덤 추천용으로 7개만 뽑기 (filtered가 7개 이하일 경우도 고려)
          filtered.shuffle(); // 리스트 랜덤 섞기
          final randomSample = filtered.take(7).toList();

          return ListView.builder(
            itemCount: randomSample.length,
            itemBuilder: (context, index) {
              final mountain = filtered[index];

              return FutureBuilder<String?>(
                // ✅ 산 ID 기준으로 이미지 가져오기 (코드 기준 API)
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

                  return ListTile(
                    leading: leadingWidget,
                    title: Text(mountain.name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (mountain.height != 0)
                          Text('${mountain.height}m'), // 높이가 0이 아닐 때만 출력
                        Text(shortLocation(mountain.location)), // 소재지 간소화 출력
                      ],
                    ),
                    onTap: () {
                      // ✅ 상세페이지 이동
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => MountainDetailPage(
                                mountainName: mountain.name,
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

  // ✅ 소재지 짧게 자르기 헬퍼함수
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

  // ✅ 걷기길 탭 (아직 미구현)
  Widget _buildTrailList() {
    return const Center(child: Text('걷기길 데이터 없음'));
  }
}
