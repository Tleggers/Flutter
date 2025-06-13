class Mountain {
  final String name;
  final String overview;
  final double height;
  final String imageUrl;
  double latitude;
  double longitude;

  Mountain({
    required this.name,
    required this.overview,
    required this.height,
    required this.imageUrl,
    this.latitude = 0.0,
    this.longitude = 0.0,
  });

  factory Mountain.fromAApi(Map<String, dynamic> json) {
    return Mountain(
      name: json['mntnm'] ?? '',
      overview: json['overview'] ?? '',
      height: double.tryParse(json['mntheight']?.toString() ?? '0') ?? 0.0,
      imageUrl: json['imageUrl'] ?? '',
    );
  }

  void applyCoordinates(double lat, double lng) {
    latitude = lat;
    longitude = lng;
  }
}


//트레킹 센터 키 목록
// {
//   "header": {
//     "resultCode": "string",
//     "resultMsg": "string"
//   },
//   "body": {
//     "items": {
//       "item": {
//         "frtrlId": "string",
//         "frtrlNm": "string",
//         "mtnCd": "string",
//         "ctpvNm": "string",
//         "addrNm": "string",
//         "lat": 0,
//         "lot": 0,
//         "aslAltide": 0,
//         "crtrDt": "string"
//       }
//     },
//     "pageNo": 0,
//     "numOfRows": 0,
//     "totalCount": 0
//   }
// }
