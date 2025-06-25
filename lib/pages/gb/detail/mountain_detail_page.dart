import 'package:flutter/material.dart';
import 'package:trekkit_flutter/models/gb/mountain_course.dart';
import 'package:trekkit_flutter/pages/gb/detail/mountain_map_course_section.dart';
import 'package:trekkit_flutter/pages/gb/detail/mountain_weather_section.dart';
import '../../../services/gb/mountain_course_service.dart';
import 'mountain_intro_section.dart';

class MountainDetailPage extends StatefulWidget {
  final String mountainName;
  final String? imageUrl;
  final String location;

  const MountainDetailPage({
    super.key,
    required this.mountainName,
    required this.imageUrl,
    required this.location,
  });

  @override
  State<MountainDetailPage> createState() => _MountainDetailPageState();
}

class _MountainDetailPageState extends State<MountainDetailPage> {
  late Future<MountainCourse?> courseFuture;

  @override
  void initState() {
    super.initState();
    courseFuture = MountainCourseService.fetchByNameAndLocation(
      widget.mountainName,
      widget.location,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.mountainName} 등산 정보'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: FutureBuilder<MountainCourse?>(
        future: courseFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('데이터 없음'));
          }

          final data = snapshot.data!;

          return CustomScrollView(
            slivers: [
              // ✅ 1. 이미지 영역
              SliverToBoxAdapter(
                child: Container(
                  width: double.infinity,
                  height: 250,
                  color: Colors.grey[300],
                  child:
                      widget.imageUrl != null
                          ? Image.network(widget.imageUrl!, fit: BoxFit.cover)
                          : const Center(child: Text('이미지 없음')),
                ),
              ),

              // ✅ 2. 산 소개 영역
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: MountainIntroSection(
                    data: data,
                    mountainName: widget.mountainName,
                  ),
                ),
              ),

              // ✅ 3. 날씨 영역 (이제 FutureBuilder 불필요)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: MountainWeatherSection(
                    latitude: data.latitude,
                    longitude: data.longitude,
                  ),
                ),
              ),

              // ✅ 4. 지도 + 코스 리스트 영역 (전체 묶어서 안전하게 출력)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: MountainMapCourseSection(data: data),
                ),
              ),

              // ✅ 5. 실시간 등산정보
              SliverToBoxAdapter(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  color: Colors.orange[50],
                  child: const Text('실시간 등산정보 영역'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
