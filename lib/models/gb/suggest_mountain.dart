class SuggestMountain {
  final String id; // 산코드 (mntilistno)
  final String name; // 산이름 (mntiname)
  final double height; // 산높이 (mntihigh)
  final String location; // 소재지 (mntiadd)
  final String? imageUrl; // 이미지 URL (nullable)

  SuggestMountain({
    required this.id,
    required this.name,
    required this.height,
    required this.location,
    this.imageUrl,
  });

  // 산정보 API로부터 JSON 파싱
  factory SuggestMountain.fromJson(Map<dynamic, dynamic> json) {
    return SuggestMountain(
      id: json['mntilistno'].toString(),
      name: json['mntiname'] ?? '',
      height: _parseDouble(json['mntihigh']),
      location: json['mntiadd'] ?? '',
    );
  }

  // 이미지 URL 주입을 위한 복사 메서드
  SuggestMountain copyWithImage(String? imageUrl) {
    return SuggestMountain(
      id: id,
      name: name,
      height: height,
      location: location,
      imageUrl: imageUrl,
    );
  }
}

// 안전한 double 파서
double _parseDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is int) return value.toDouble();
  if (value is double) return value;
  if (value is String) return double.tryParse(value) ?? 0.0;
  return 0.0;
}
