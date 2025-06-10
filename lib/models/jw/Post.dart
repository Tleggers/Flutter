class Post {
  final int? id;
  final String nickname;
  final String? title;
  final String mountain; // mountainName으로 백엔드에서 처리되지만 프론트에서는 mountain으로 유지
  final String content;
  final List<String> imagePaths;
  final int likeCount;
  final int commentCount;
  final int viewCount;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Post({
    this.id,
    required this.nickname,
    this.title,
    required this.mountain,
    required this.content,
    this.imagePaths = const [],
    this.likeCount = 0,
    this.commentCount = 0,
    this.viewCount = 0,
    required this.createdAt,
    this.updatedAt,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      nickname: json['nickname'] ?? '',
      title: json['title'],
      mountain: json['mountain'] ?? json['mountainName'] ?? '', // 백엔드 호환성
      content: json['content'] ?? '',
      imagePaths:
          json['imagePaths'] != null
              ? List<String>.from(json['imagePaths'])
              : [],
      likeCount: json['likeCount'] ?? 0,
      commentCount: json['commentCount'] ?? 0,
      viewCount: json['viewCount'] ?? 0,
      createdAt:
          json['createdAt'] != null
              ? DateTime.parse(json['createdAt'])
              : DateTime.now(),
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nickname': nickname,
      'title': title,
      'mountainName': mountain, // 백엔드로 전송할 때는 mountainName 사용
      'content': content,
      'imagePaths': imagePaths,
      'likeCount': likeCount,
      'commentCount': commentCount,
      'viewCount': viewCount,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  Post copyWith({
    int? id,
    String? nickname,
    String? title,
    String? mountain,
    String? content,
    List<String>? imagePaths,
    int? likeCount,
    int? commentCount,
    int? viewCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Post(
      id: id ?? this.id,
      nickname: nickname ?? this.nickname,
      title: title ?? this.title,
      mountain: mountain ?? this.mountain,
      content: content ?? this.content,
      imagePaths: imagePaths ?? this.imagePaths,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      viewCount: viewCount ?? this.viewCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
