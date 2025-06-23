/// 산(Mountain) 데이터를 나타내는 모델 클래스입니다.
/// 이 클래스는 산의 고유 ID, 이름, 설명, 이미지 URL, 위치 정보를 포함합니다.
class Mountain {
  /// 산의 고유 ID (선택 사항)
  /// 백엔드에서 'mntnid' 또는 'id' 필드로 올 수 있습니다.
  final String? id;

  /// 산의 이름 (필수)
  /// 백엔드에서 'mntnNm' 또는 'name' 필드로 올 수 있습니다.
  final String name;

  /// 산에 대한 설명 (선택 사항)
  /// 백엔드에서 'mntnInfoDtlInfoCont' 또는 'description' 필드로 올 수 있습니다.
  final String? description;

  /// 산 이미지의 URL (선택 사항)
  /// 백엔드에서 'mntnAttchImageSeq' 또는 'imageUrl' 필드로 올 수 있습니다.
  final String? imageUrl;

  /// 산의 위치 정보 (선택 사항)
  /// 백엔드에서 'mntnInfoAraCont' 또는 'location' 필드로 올 수 있습니다.
  final String? location;

  /// Mountain 클래스의 생성자입니다.
  /// 필수 필드(name)는 반드시 제공되어야 합니다.
  /// 선택적 필드(id, description, imageUrl, location)는 null을 허용합니다.
  Mountain({
    this.id,
    required this.name,
    this.description,
    this.imageUrl,
    this.location,
  });

  /// JSON 데이터로부터 Mountain 객체를 생성하는 팩토리 메서드입니다.
  /// 백엔드 API 응답의 유연성을 위해 여러 가능한 필드 이름을 고려합니다.
  factory Mountain.fromJson(Map<String, dynamic> json) {
    return Mountain(
      id:
          json['mntnid']?.toString() ??
          json['id']?.toString(), // 'mntnid' 또는 'id' 중 하나를 사용
      name:
          json['mntnNm'] ??
          json['name'] ??
          '', // 'mntnNm' 또는 'name' 중 하나를 사용, 없으면 빈 문자열
      description:
          json['mntnInfoDtlInfoCont'] ??
          json['description'] ??
          '', // 'mntnInfoDtlInfoCont' 또는 'description' 중 하나를 사용
      imageUrl:
          json['mntnAttchImageSeq'] ??
          json['imageUrl'] ??
          '', // 'mntnAttchImageSeq' 또는 'imageUrl' 중 하나를 사용
      location:
          json['mntnInfoAraCont'] ??
          json['location'] ??
          '', // 'mntnInfoAraCont' 또는 'location' 중 하나를 사용
    );
  }

  /// Mountain 객체를 JSON 형태로 변환하는 메서드입니다.
  /// 서버로 데이터를 전송할 때 사용됩니다.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'location': location,
    };
  }

  /// Mountain 객체의 문자열 표현을 반환합니다. 디버깅에 유용합니다.
  @override
  String toString() {
    return 'Mountain{id: $id, name: $name, description: $description, imageUrl: $imageUrl, location: $location}';
  }

  /// 두 Mountain 객체가 동일한지 비교하는 메서드입니다.
  /// 여기서는 'name' 필드만을 기준으로 동일성을 판단합니다.
  @override
  bool operator ==(Object other) {
    // 메모리상 동일한 객체인지 확인
    if (identical(this, other)) return true;
    // other가 Mountain 타입이고, name 필드가 같은지 확인
    return other is Mountain && other.name == name;
  }

  /// 객체의 해시 코드를 반환합니다.
  /// operator ==를 오버라이드할 경우 반드시 오버라이드해야 합니다.
  /// 여기서는 'name' 필드의 해시 코드를 사용합니다.
  @override
  int get hashCode => name.hashCode;
}
