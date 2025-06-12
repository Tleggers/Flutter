import 'package:flutter/material.dart';
import 'package:trekkit_flutter/api/suggest_mountain_api.dart';
import 'package:trekkit_flutter/models/gb/suggest_mountain.dart';

class RegionListPage extends StatefulWidget {
  final String regionId;

  const RegionListPage({super.key, required this.regionId});

  @override
  State<RegionListPage> createState() => _RegionListPageState();
}

class _RegionListPageState extends State<RegionListPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

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
    _tabController = TabController(length: 2, vsync: this);
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
        title: Text(regionName),
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

  // ✅ 산 리스트 호출
  Widget _buildMountainList(String regionName) {
    return FutureBuilder<List<SuggestMountain>>(
      future: SuggestMountainApi.fetchMountains(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text('데이터 로딩 실패'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('산 데이터 없음'));
        } else {
          final allMountains = snapshot.data!;

          // 👉 여기서 지역 필터링 (소재지에 지역명 포함되는지 확인)
          final filtered =
              allMountains.where((mountain) {
                return mountain.location.contains(regionName);
              }).toList();

          return ListView.builder(
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              final mountain = filtered[index];
              return ListTile(
                leading: Container(
                  width: 60,
                  height: 60,
                  color: Colors.grey[300],
                  child: const Icon(Icons.image, size: 30),
                ),
                title: Text(mountain.name),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${mountain.height}m'),
                    Text(shortLocation(mountain.location)),
                  ],
                ),
              );
            },
          );
        }
      },
    );
  }

  // 소재지 짧게 잘라주는 헬퍼함수
  String shortLocation(String? location) {
    if (location == null || location.isEmpty) return '';

    // 1단계: 쉼표 기준으로 앞 부분만 남김
    final firstPart = location.split(',')[0].trim();

    // 2단계: 앞에 시도/시군구까지만 남김
    final parts = firstPart.split(' ');
    if (parts.length >= 2) {
      return '${parts[0]} ${parts[1]}';
    } else {
      return firstPart;
    }
  }

  Widget _buildTrailList() {
    return const Center(child: Text('걷기길 데이터 없음'));
  }
}
