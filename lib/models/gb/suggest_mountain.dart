class SuggestMountain {
  final String name;
  final int height;
  final String location;

  SuggestMountain({
    required this.name,
    required this.height,
    required this.location,
  });

  factory SuggestMountain.fromJson(Map<dynamic, dynamic> json) {
    return SuggestMountain(
      name: json['mntnm'] ?? '',
      height: _parseInt(json['mntheight']),
      location: json['areanm'] ?? '',
    );
  }
}

// 안전한 int 파서
int _parseInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}
