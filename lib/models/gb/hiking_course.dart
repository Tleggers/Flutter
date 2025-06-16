import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:trekkit_flutter/models/gb/hiking_course.segment.dart';

class HikingCourse {
  final HikingCourseSegment segment; // 속성정보 (거리, 시간, 난이도)
  final List<NLatLng> polyline; // 해당 코스의 경로좌표

  HikingCourse({required this.segment, required this.polyline});
}
