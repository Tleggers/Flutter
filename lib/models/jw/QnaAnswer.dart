// lib/models/jw/QnaAnswer.dart
class QnaAnswer {
  final int id;
  final int questionId;
  final int userId; // int 타입
  final String nickname;
  final String content;
  final List<String> imagePaths;
  final int likeCount;
  final bool isAccepted;
  final DateTime createdAt;
  final DateTime? updatedAt;

  QnaAnswer({
    required this.id,
    required this.questionId,
    required this.userId, // int 타입
    required this.nickname,
    required this.content,
    this.imagePaths = const [],
    required this.likeCount,
    required this.isAccepted,
    required this.createdAt,
    this.updatedAt,
  });

  factory QnaAnswer.fromJson(Map<String, dynamic> json) {
    return QnaAnswer(
      id: json['id'] ?? 0,
      questionId: json['questionId'] ?? 0,
      userId:
          (json['userId'] is String)
              ? int.parse(json['userId'])
              : (json['userId'] ?? 0), // String -> int 안전 파싱
      nickname: json['nickname'] ?? '',
      content: json['content'] ?? '',
      imagePaths:
          json['imagePaths'] != null
              ? List<String>.from(json['imagePaths'])
              : [],
      likeCount: json['likeCount'] ?? 0,
      isAccepted: json['isAccepted'] ?? false,
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
      'questionId': questionId,
      'userId': userId, // int 그대로 전송
      'nickname': nickname,
      'content': content,
      'imagePaths': imagePaths,
      'likeCount': likeCount,
      'isAccepted': isAccepted,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  QnaAnswer copyWith({
    int? id,
    int? questionId,
    int? userId, // int 타입
    String? nickname,
    String? content,
    List<String>? imagePaths,
    int? likeCount,
    bool? isAccepted,
    DateTime? createdAt,
  }) {
    return QnaAnswer(
      id: id ?? this.id,
      questionId: questionId ?? this.questionId,
      userId: userId ?? this.userId,
      nickname: nickname ?? this.nickname,
      content: content ?? this.content,
      imagePaths: imagePaths ?? this.imagePaths,
      likeCount: likeCount ?? this.likeCount,
      isAccepted: isAccepted ?? this.isAccepted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
