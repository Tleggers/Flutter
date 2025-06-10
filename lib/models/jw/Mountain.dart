class Mountain {
  final String? id;
  final String name;
  final String? description;
  final String? imageUrl;
  final String? location;

  Mountain({
    this.id,
    required this.name,
    this.description,
    this.imageUrl,
    this.location,
  });

  factory Mountain.fromJson(Map<String, dynamic> json) {
    return Mountain(
      id: json['mntnid']?.toString() ?? json['id']?.toString(),
      name: json['mntnNm'] ?? json['name'] ?? '',
      description: json['mntnInfoDtlInfoCont'] ?? json['description'] ?? '',
      imageUrl: json['mntnAttchImageSeq'] ?? json['imageUrl'] ?? '',
      location: json['mntnInfoAraCont'] ?? json['location'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'location': location,
    };
  }

  @override
  String toString() {
    return 'Mountain{id: $id, name: $name, description: $description, imageUrl: $imageUrl, location: $location}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Mountain && other.name == name;
  }

  @override
  int get hashCode => name.hashCode;
}
