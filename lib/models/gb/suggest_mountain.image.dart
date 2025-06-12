class SuggestMountainImage {
  final String mountainId; // mntilistno
  final String imgfilename;
  final String imgname;
  final int imgno;

  SuggestMountainImage({
    required this.mountainId,
    required this.imgfilename,
    required this.imgname,
    required this.imgno,
  });

  factory SuggestMountainImage.fromJson(Map<dynamic, dynamic> json) {
    return SuggestMountainImage(
      mountainId: json['mntilistno'].toString(),
      imgfilename: json['imgfilename'] ?? '',
      imgname: json['imgname'] ?? '',
      imgno: _parseInt(json['imgno']),
    );
  }
  // 전체 URL 만들어주는 getter
  String get fullImageUrl {
    return 'https://www.forest.go.kr/images/data/down/mountain/$imgfilename';
  }
}

int _parseInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}
