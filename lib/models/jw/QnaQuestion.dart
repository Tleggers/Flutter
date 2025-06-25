/// lib/models/jw/QnaQuestion.dart
library;

// Flutter의 기본 유틸리티 기능을 위해 임포트 (예: @immutable 등)

/// QnA 질문(QnaQuestion) 데이터를 나타내는 모델 클래스입니다.
/// 이 클래스는 질문의 고유 ID, 작성자 ID, 닉네임, 제목, 내용,
/// 관련 산 이름, 이미지 경로 목록, 조회수, 답변 수, 좋아요 수,
/// 해결 여부, 채택된 답변 ID, 생성일 및 수정일 정보를 포함합니다.
class QnaQuestion {
  /// 질문의 고유 ID
  final int id;

  /// 질문을 작성한 사용자의 ID (백엔드의 Long 타입에 대응되도록 int로 사용)
  final int userId;

  /// 질문을 작성한 사용자의 닉네임
  final String nickname;

  /// 질문의 제목
  final String title;

  /// 질문의 내용
  final String content;

  /// 질문과 관련된 산의 이름
  final String mountain;

  /// 질문에 첨부된 이미지 경로 목록 (기본값: 빈 리스트)
  final List<String> imagePaths;

  /// 질문의 조회수
  final int viewCount;

  /// 질문에 달린 답변의 수
  final int answerCount;

  /// 질문의 좋아요 수
  final int likeCount;

  /// 질문이 해결되었는지 여부
  final bool isSolved;

  /// 채택된 답변의 ID (선택 사항, 질문이 해결된 경우에만 존재)
  final int? acceptedAnswerId;

  /// 질문이 생성된 날짜 및 시간
  final DateTime createdAt;

  /// 질문이 마지막으로 수정된 날짜 및 시간 (선택 사항)
  final DateTime? updatedAt;

  /// `QnaQuestion` 클래스의 생성자입니다.
  /// 필수 필드는 반드시 제공되어야 하며, 일부 필드는 기본값을 가집니다.
  QnaQuestion({
    required this.id,
    required this.userId,
    required this.nickname,
    required this.title,
    required this.content,
    required this.mountain,
    this.imagePaths = const [], // 기본값으로 빈 리스트 제공
    required this.viewCount,
    required this.answerCount,
    required this.likeCount,
    required this.isSolved,
    this.acceptedAnswerId,
    required this.createdAt,
    this.updatedAt,
  });

  /// JSON 데이터로부터 `QnaQuestion` 객체를 생성하는 팩토리 메서드입니다.
  /// `userId`가 String으로 넘어올 경우를 대비하여 `int.parse`를 시도합니다.
  /// 각 필드에 대해 null 체크 및 기본값 설정을 통해 안전하게 파싱합니다.
  factory QnaQuestion.fromJson(Map<String, dynamic> json) {
    return QnaQuestion(
      id: json['id'] ?? 0, // 'id'가 null이면 0으로 기본값 설정
      userId:
          (json['userId'] is String) // 'userId'가 String 타입인지 확인
              ? int.parse(json['userId']) // String이면 int로 파싱
              : (json['userId'] ?? 0), // String이 아니거나 null이면 0으로 기본값 설정
      nickname: json['nickname'] ?? '', // 'nickname'이 null이면 빈 문자열로 기본값 설정
      title: json['title'] ?? '', // 'title'이 null이면 빈 문자열로 기본값 설정
      content: json['content'] ?? '', // 'content'가 null이면 빈 문자열로 기본값 설정
      mountain: json['mountain'] ?? '', // 'mountain'이 null이면 빈 문자열로 기본값 설정
      imagePaths:
          json['imagePaths'] !=
                  null // 'imagePaths'가 null이 아니면
              ? List<String>.from(json['imagePaths']) // 이미지 경로 목록 파싱
              : [], // 'imagePaths'가 null이면 빈 리스트로 기본값 설정
      viewCount: json['viewCount'] ?? 0, // 'viewCount'가 null이면 0으로 기본값 설정
      answerCount: json['answerCount'] ?? 0, // 'answerCount'가 null이면 0으로 기본값 설정
      likeCount: json['likeCount'] ?? 0, // 'likeCount'가 null이면 0으로 기본값 설정
      isSolved: json['isSolved'] ?? false, // 'isSolved'가 null이면 false로 기본값 설정
      acceptedAnswerId: json['acceptedAnswerId'], // 'acceptedAnswerId'는 null 허용
      createdAt:
          json['createdAt'] !=
                  null // 'createdAt'이 null이 아니면
              ? DateTime.parse(json['createdAt']) // DateTime으로 파싱
              : DateTime.now(), // 'createdAt'이 null이면 현재 시간으로 기본값 설정
      updatedAt:
          json['updatedAt'] !=
                  null // 'updatedAt'이 null이 아니면
              ? DateTime.parse(json['updatedAt']) // DateTime으로 파싱
              : null, // 'updatedAt'이 null이면 null로 설정
    );
  }

  /// `QnaQuestion` 객체를 JSON 형태로 변환하는 메서드입니다.
  /// 서버로 데이터를 전송할 때 사용됩니다.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId, // int 타입 그대로 전송
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
      'createdAt': createdAt.toIso8601String(), // DateTime을 ISO 8601 문자열로 변환
      'updatedAt':
          updatedAt?.toIso8601String(), // null이 아닐 경우에만 ISO 8601 문자열로 변환
    };
  }

  /// 현재 `QnaQuestion` 객체의 특정 필드를 변경하여 새로운 `QnaQuestion` 객체를 생성하는 메서드입니다.
  /// 이 메서드는 객체의 불변성을 유지하면서 특정 필드만 수정된 새 인스턴스를 만들 때 사용됩니다.
  QnaQuestion copyWith({
    int? id,
    int? userId,
    String? nickname,
    String? title,
    String? content,
    String? mountain,
    List<String>? imagePaths,
    int? viewCount,
    int? likeCount,
    int? answerCount,
    bool? isSolved,
    int? acceptedAnswerId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return QnaQuestion(
      id: id ?? this.id, // 변경 값이 제공되면 사용, 아니면 기존 값 사용
      userId: userId ?? this.userId,
      nickname: nickname ?? this.nickname,
      title: title ?? this.title,
      content: content ?? this.content,
      mountain: mountain ?? this.mountain,
      imagePaths: imagePaths ?? this.imagePaths,
      viewCount: viewCount ?? this.viewCount,
      likeCount: likeCount ?? this.likeCount,
      answerCount: answerCount ?? this.answerCount,
      isSolved: isSolved ?? this.isSolved,
      acceptedAnswerId:
          acceptedAnswerId ?? this.acceptedAnswerId, // acceptedAnswerId 반영
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt, // updatedAt 반영
    );
  }
}
