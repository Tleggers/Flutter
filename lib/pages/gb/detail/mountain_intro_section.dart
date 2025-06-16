import 'package:flutter/material.dart';
import 'package:trekkit_flutter/models/gb/mountain_course.dart';

// ✅ 소개 영역 위젯 분리
class MountainIntroSection extends StatelessWidget {
  final MountainCourse? data; // API에서 받은 데이터 (nullable 허용)
  final String mountainName; // 리스트에서 받은 산 이름 (항상 있음)

  const MountainIntroSection({
    super.key,
    required this.data,
    required this.mountainName,
  });

  @override
  Widget build(BuildContext context) {
    if (data != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ✅ 산 이름 + 높이 + 소재지 한 줄에 출력
          Row(
            children: [
              Text(
                data!.mountainName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${data!.mountainHeight} · ${data!.mountainLocation}',
                style: const TextStyle(
                  fontSize: 14,
                  color: Color.fromARGB(255, 124, 120, 120),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(data!.mountainIntro),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            mountainName,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Text('산 소개 준비중입니다.', style: TextStyle(fontSize: 16)),
        ],
      );
    }
  }
}
