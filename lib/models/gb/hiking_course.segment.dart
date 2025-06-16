class HikingCourseSegment {
  final int secLen; // 구간거리 (m)
  final int upMin; // 상행시간 (분)
  final int downMin; // 하행시간 (분)
  final String catNam; // 난이도

  HikingCourseSegment({
    required this.secLen,
    required this.upMin,
    required this.downMin,
    required this.catNam,
  });

  // 브이월드에서 받은 properties에서 바로 파싱할 수 있게 팩토리 메서드
  factory HikingCourseSegment.fromProperties(Map<String, dynamic> props) {
    return HikingCourseSegment(
      secLen: int.tryParse(props['sec_len'].toString()) ?? 0,
      upMin: int.tryParse(props['up_min'].toString()) ?? 0,
      downMin: int.tryParse(props['down_min'].toString()) ?? 0,
      catNam: props['cat_nam'] ?? '정보없음',
    );
  }
}
