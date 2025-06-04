class MountainDetail {
  final String name;
  final String address;
  final String description;

  MountainDetail({
    required this.name,
    required this.address,
    required this.description,
  });

  factory MountainDetail.fromJson(Map<String, dynamic> json) {
    return MountainDetail(
      name: json['mntnm'] ?? '',
      address: json['mntninfopoflc'] ?? '',
      description: json['mntninfodtlinfocont'] ?? '',
    );
  }
}
