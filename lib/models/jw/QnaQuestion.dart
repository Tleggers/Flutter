class QnaQuestion {
  final int id;
  final String userId;
  final String nickname;
  final String title;
  final String content;
  final String mountain;
  final List<String> imagePaths;
  final int viewCount;
  final int answerCount;
  final int likeCount;
  final bool isSolved;
  final int? acceptedAnswerId;
  final DateTime createdAt;
  final DateTime? updatedAt;

  QnaQuestion({
    required this.id,
    required this.userId,
    required this.nickname,
    required this.title,
    required this.content,
    required this.mountain,
    required this.imagePaths,
    required this.viewCount,
    required this.answerCount,
    required this.likeCount,
    required this.isSolved,
    this.acceptedAnswerId,
    required this.createdAt,
    this.updatedAt,
  });

  factory QnaQuestion.fromJson(Map<String, dynamic> json) {
    return QnaQuestion(
      id: json['id'] ?? 0,
      userId: json['userId'] ?? '',
      nickname: json['nickname'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      mountain: json['mountain'] ?? '',
      imagePaths:
          json['imagePaths'] != null
              ? List<String>.from(json['imagePaths'])
              : [],
      viewCount: json['viewCount'] ?? 0,
      answerCount: json['answerCount'] ?? 0,
      likeCount: json['likeCount'] ?? 0,
      isSolved: json['isSolved'] ?? false,
      acceptedAnswerId: json['acceptedAnswerId'],
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
      'userId': userId,
      'nickname': nickname,
      'title': title,
      'content': content,
      'mountain': mountain,
      'imagePaths': imagePaths,
      'viewCount': viewCount,
      'answerCount': answerCount,
      'likeCount': likeCount,
      'isSolved': isSolved,
      'acceptedAnswerId': acceptedAnswerId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}

class QnaAnswer {
  final int id;
  final int questionId;
  final String userId;
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
    required this.userId,
    required this.nickname,
    required this.content,
    required this.imagePaths,
    required this.likeCount,
    required this.isAccepted,
    required this.createdAt,
    this.updatedAt,
  });

  factory QnaAnswer.fromJson(Map<String, dynamic> json) {
    return QnaAnswer(
      id: json['id'] ?? 0,
      questionId: json['questionId'] ?? 0,
      userId: json['userId'] ?? '',
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
      'userId': userId,
      'nickname': nickname,
      'content': content,
      'imagePaths': imagePaths,
      'likeCount': likeCount,
      'isAccepted': isAccepted,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
