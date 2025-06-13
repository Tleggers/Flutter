import 'package:flutter/material.dart';
import 'package:trekkit_flutter/models/gb/mountain_course.dart';
import '../../../services/gb/mountain_course_service.dart';
import 'mountain_intro_section.dart'; // ✅ 소개 영역 컴포넌트 import

class MountainDetailPage extends StatefulWidget {
  final String mountainName;
  final String? imageUrl;

  const MountainDetailPage({
    super.key,
    required this.mountainName,
    required this.imageUrl,
  });

  @override
  State<MountainDetailPage> createState() => _MountainDetailPageState();
}

class _MountainDetailPageState extends State<MountainDetailPage> {
  late Future<MountainCourse?> courseFuture;

  @override
  void initState() {
    super.initState();
    courseFuture = MountainCourseService.fetchByMountainName(
      widget.mountainName,
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. 이미지 영역
            Container(
              width: double.infinity,
              height: 250,
              color: Colors.grey[300],
              child:
                  widget.imageUrl != null
                      ? Image.network(widget.imageUrl!, fit: BoxFit.cover)
                      : const Center(child: Text('이미지 없음')),
            ),

            // ✅ 여기서 FutureBuilder로 산 소개 영역만 따로 API 호출
            FutureBuilder<MountainCourse?>(
              future: courseFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                final data = snapshot.data;

                return Transform.translate(
                  offset: const Offset(0, -30),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                    ),
                    child: MountainIntroSection(
                      data: data,
                      mountainName: widget.mountainName,
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            // 3. 날씨 영역 (임시 하드코딩)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(64),
              color: Colors.blue[50],
              child: const Text('날씨 영역'),
            ),

            const SizedBox(height: 20),

            // 4. 지도 + 코스 영역 (임시 하드코딩)
            Container(
              width: double.infinity,
              height: 300,
              color: Colors.green[100],
              child: const Center(child: Text('지도 + 코스 리스트')),
            ),

            const SizedBox(height: 20),

            // 5. 실시간 정보 영역 (임시 하드코딩)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Colors.orange[50],
              child: const Text('실시간 등산정보 영역'),
            ),
          ],
        ),
      ),
    );
  }
}
