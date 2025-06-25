/// 게시글(Post) 데이터를 나타내는 모델 클래스입니다.
class Post {
  final int? id;

  // [추가] 컨트롤러 및 다른 위젯에서 작성자를 식별하기 위해 userId 필드를 추가합니다.
  final int? userId;

  final String nickname;
  final String? title;
  final String mountain;
  final String content;
  final List<String> imagePaths;
  final int likeCount;
  final int commentCount;
  final int viewCount;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Post({
    this.id,
    this.userId, // [추가]
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

  /// JSON 데이터로부터 Post 객체를 생성하는 팩토리 메서드입니다.
  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      userId: json['userId'], // [추가]
      nickname: json['nickname'] ?? '',
      title: json['title'],
      mountain: json['mountain'] ?? json['mountainName'] ?? '',
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

  /// Post 객체를 JSON 형태로 변환하는 메서드입니다.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId, // [추가]
      'nickname': nickname,
      'title': title,
      'mountainName': mountain,
      'content': content,
      'imagePaths': imagePaths,
    };
  }

  /// 현재 Post 객체의 특정 필드를 변경하여 새로운 Post 객체를 생성하는 메서드입니다.
  Post copyWith({
    int? id,
    int? userId,
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
      userId: userId ?? this.userId, // [추가]
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
