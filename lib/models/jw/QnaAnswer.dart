/// lib/models/jw/QnaAnswer.dart
library;

/// QnA 답변(QnaAnswer) 데이터를 나타내는 모델 클래스입니다.
/// 이 클래스는 답변의 고유 ID, 질문 ID, 작성자 ID, 닉네임, 내용,
/// 이미지 경로 목록, 좋아요 수, 채택 여부, 생성일 및 수정일 정보를 포함합니다.
class QnaAnswer {
  /// 답변의 고유 ID
  final int id;

  /// 답변이 속한 질문의 ID
  final int questionId;

  /// 답변을 작성한 사용자의 ID (백엔드의 Long 타입에 대응될 수 있으나 여기서는 int로 사용)
  final int userId;

  /// 답변을 작성한 사용자의 닉네임
  final String nickname;

  /// 답변 내용
  final String content;

  /// 답변에 첨부된 이미지 경로 목록 (기본값: 빈 리스트)
  final List<String> imagePaths;

  /// 답변의 좋아요 수
  final int likeCount;

  /// 이 답변이 채택되었는지 여부
  final bool isAccepted;

  /// 답변이 생성된 날짜 및 시간
  final DateTime createdAt;

  /// 답변이 마지막으로 수정된 날짜 및 시간 (선택 사항)
  final DateTime? updatedAt;

  /// QnaAnswer 클래스의 생성자입니다.
  /// 모든 필드는 필수이며, imagePaths는 기본값을 가집니다.
  QnaAnswer({
    required this.id,
    required this.questionId,
    required this.userId,
    required this.nickname,
    required this.content,
    this.imagePaths = const [],
    required this.likeCount,
    required this.isAccepted,
    required this.createdAt,
    this.updatedAt,
  });

  /// JSON 데이터로부터 QnaAnswer 객체를 생성하는 팩토리 메서드입니다.
  /// 'userId'가 String으로 넘어올 경우를 대비하여 int.parse를 시도합니다.
  factory QnaAnswer.fromJson(Map<String, dynamic> json) {
    return QnaAnswer(
      id: json['id'] ?? 0, // 'id'가 null이면 0으로 기본값 설정
      questionId: json['questionId'] ?? 0, // 'questionId'가 null이면 0으로 기본값 설정
      userId:
          (json['userId'] is String)
              ? int.parse(json['userId']) // 'userId'가 String이면 int로 파싱
              : (json['userId'] ??
                  0), // 'userId'가 null이면 0으로 기본값 설정 (String이 아닐 경우)
      nickname: json['nickname'] ?? '', // 'nickname'이 null이면 빈 문자열로 기본값 설정
      content: json['content'] ?? '', // 'content'가 null이면 빈 문자열로 기본값 설정
      imagePaths:
          json['imagePaths'] != null
              ? List<String>.from(json['imagePaths']) // 이미지 경로 목록 파싱
              : [], // 'imagePaths'가 null이면 빈 리스트로 기본값 설정
      likeCount: json['likeCount'] ?? 0, // 'likeCount'가 null이면 0으로 기본값 설정
      isAccepted:
          json['isAccepted'] ?? false, // 'isAccepted'가 null이면 false로 기본값 설정
      createdAt:
          json['createdAt'] != null
              ? DateTime.parse(
                json['createdAt'],
              ) // 'createdAt'이 null이 아니면 DateTime으로 파싱
              : DateTime.now(), // 'createdAt'이 null이면 현재 시간으로 기본값 설정
      updatedAt:
          json['updatedAt'] != null
              ? DateTime.parse(json['updatedAt'])
              : null, // 'updatedAt'이 null이 아니면 DateTime으로 파싱
    );
  }

  /// QnaAnswer 객체를 JSON 형태로 변환하는 메서드입니다.
  /// 서버로 데이터를 전송할 때 사용됩니다.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'questionId': questionId,
      'userId': userId, // int 타입 그대로 전송
      'nickname': nickname,
      'content': content,
      'imagePaths': imagePaths,
      'likeCount': likeCount,
      'isAccepted': isAccepted,
      'createdAt': createdAt.toIso8601String(), // DateTime을 ISO 8601 문자열로 변환
      'updatedAt':
          updatedAt?.toIso8601String(), // null이 아닐 경우에만 ISO 8601 문자열로 변환
    };
  }

  /// 현재 QnaAnswer 객체의 특정 필드를 변경하여 새로운 QnaAnswer 객체를 생성하는 메서드입니다.
  /// (불변성 유지를 위해 사용)
  QnaAnswer copyWith({
    int? id,
    int? questionId,
    int? userId,
    String? nickname,
    String? content,
    List<String>? imagePaths,
    int? likeCount,
    bool? isAccepted,
    DateTime? createdAt,
    DateTime? updatedAt, // copyWith에도 updatedAt 필드 추가
  }) {
    return QnaAnswer(
      id: id ?? this.id, // 변경 값이 제공되면 사용, 아니면 기존 값 사용
      questionId: questionId ?? this.questionId,
      userId: userId ?? this.userId,
      nickname: nickname ?? this.nickname,
      content: content ?? this.content,
      imagePaths: imagePaths ?? this.imagePaths,
      likeCount: likeCount ?? this.likeCount,
      isAccepted: isAccepted ?? this.isAccepted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt, // updatedAt 필드도 copyWith에 반영
    );
  }
}
