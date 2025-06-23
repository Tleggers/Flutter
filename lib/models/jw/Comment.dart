// lib/models/jw/Comment.dart
class Comment {
  final int? id;
  final int postId;
  final int userId; // Long userId에 대응되도록 int로 변경
  final String nickname;
  final String content;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Comment({
    this.id,
    required this.postId,
    required this.userId,
    required this.nickname,
    required this.content,
    required this.createdAt,
    this.updatedAt,
  });

  // JSON에서 Comment 객체 생성
  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      postId: json['postId'],
      userId:
          (json['userId'] is String)
              ? int.parse(json['userId'])
              : json['userId'], // 백엔드 Long -> int
      nickname: json['nickname'],
      content: json['content'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  // Comment 객체를 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'postId': postId,
      'userId': userId, // int 그대로 전송
      'nickname': nickname,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  // 복사본 생성
  Comment copyWith({
    int? id,
    int? postId,
    int? userId, // int로 변경
    String? nickname,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Comment(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      userId: userId ?? this.userId,
      nickname: nickname ?? this.nickname,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
