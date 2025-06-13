// ✅ models/mountain_course.dart

class MountainCourse {
  // DB의 모든 컬럼 그대로 반영
  final String mountainName; // 산 이름
  final String mountainLocation; // 소재지
  final String mountainHeight; // 높이 (단위: m)
  final String difficulty; // 난이도 + 산행시간
  final String mountainIntro; // 산 소개 (설명글)
  final String hikingCourse; // 산행 코스
  final String transportation; // 교통 정보
  final double latitude; // 위도 (지도에 활용)
  final double longitude; // 경도 (지도에 활용)

  MountainCourse({
    required this.mountainName,
    required this.mountainLocation,
    required this.mountainHeight,
    required this.difficulty,
    required this.mountainIntro,
    required this.hikingCourse,
    required this.transportation,
    required this.latitude,
    required this.longitude,
  });

  // ✅ JSON → MountainCourse 변환 (서버 응답 파싱용)
  factory MountainCourse.fromJson(Map<String, dynamic> json) {
    return MountainCourse(
      mountainName: json['mountain_name'] as String,
      mountainLocation: json['mountain_location'] as String,
      mountainHeight: json['mountain_height'] as String,
      difficulty: json['difficulty'] as String,
      mountainIntro: json['mountain_intro'] as String,
      hikingCourse: json['hiking_course'] as String,
      transportation: json['transportation'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );
  }
}
