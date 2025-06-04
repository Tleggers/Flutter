// 인기산 정보를 담을 모델 클래스예요.
class PopularMountain {
  final String name; // 산 이름
  final double latitude; // 위도
  final double longitude; // 경도
  final String location; // 위치 설명
  final String imageUrl; // 이미지 URL (없을 수도 있어요)

  // 생성자
  PopularMountain({
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.location,
    required this.imageUrl,
  });

  // JSON 데이터를 객체로 바꿔주는 함수
  factory PopularMountain.fromJson(Map<String, dynamic> json) {
    return PopularMountain(
      name: json['mntnm'] ?? '이름없음',
      latitude: double.tryParse(json['lat'] ?? '0') ?? 0.0,
      longitude: double.tryParse(json['lon'] ?? '0') ?? 0.0,
      location: json['mntiadd'] ?? '위치정보없음',
      imageUrl: json['imgurl'] ?? '', // 이미지 정보가 있다면
    );
  }
}
