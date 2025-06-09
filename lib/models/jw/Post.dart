class Post {
  final int? id;
  final String nickname;
  final String? title;
  final String mountain;
  final String content;
  final List<String> imagePaths;
  final int viewCount;
  final int likeCount;
  final int commentCount;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Post({
    this.id,
    required this.nickname,
    this.title,
    required this.mountain,
    required this.content,
    required this.imagePaths,
    this.viewCount = 0,
    this.likeCount = 0,
    this.commentCount = 0,
    required this.createdAt,
    this.updatedAt,
  });

  // JSON에서 Post 객체 생성
  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      nickname: json['nickname'] ?? '',
      title: json['title'],
      mountain: json['mountain'] ?? '',
      content: json['content'] ?? '',
      imagePaths: List<String>.from(json['imagePaths'] ?? []),
      viewCount: json['viewCount'] ?? 0,
      likeCount: json['likeCount'] ?? 0,
      commentCount: json['commentCount'] ?? 0,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  // Post 객체를 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nickname': nickname,
      'title': title,
      'mountain': mountain,
      'content': content,
      'imagePaths': imagePaths,
      'viewCount': viewCount,
      'likeCount': likeCount,
      'commentCount': commentCount,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  // 복사본 생성 (일부 필드 수정)
  Post copyWith({
    int? id,
    String? nickname,
    String? title,
    String? mountain,
    String? content,
    List<String>? imagePaths,
    int? viewCount,
    int? likeCount,
    int? commentCount,
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
      viewCount: viewCount ?? this.viewCount,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
