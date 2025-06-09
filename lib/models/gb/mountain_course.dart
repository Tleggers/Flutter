class Mountain {
  final String name; // 명산_이름 (FMMNT_NM)
  final String location; // 명산_소재지 (FMMNT_POFLC)
  final String height; // 명산_높이 (FMMNT_HGHT)
  final String difficulty; // 난이도 (DGDFF)
  final String overview; // 산_개요 (MNTN_SMMAR)
  final String hikingPoints; // 산행포인트 (HKNG_PNT)
  final String hikingCourse; // 산행코스 (HKNG_COURS)
  final String transportInfo; // 교통정보 (TRNSP_INFO)
  final String yCoord; // Y좌표 (Y_CRD)
  final String xCoord; // X좌표 (X_CRD)

  Mountain({
    required this.name,
    required this.location,
    required this.height,
    required this.difficulty,
    required this.overview,
    required this.hikingPoints,
    required this.hikingCourse,
    required this.transportInfo,
    required this.yCoord,
    required this.xCoord,
  });

  factory Mountain.fromList(List<dynamic> row) {
    return Mountain(
      name: row[0].toString(),
      location: row[1].toString(),
      height: row[2].toString(),
      difficulty: row[3].toString(),
      overview: row[4].toString(),
      hikingPoints: row[5].toString(),
      hikingCourse: row[6].toString(),
      transportInfo: row[7].toString(),
      yCoord: row[8].toString(),
      xCoord: row[9].toString(),
    );
  }
}
