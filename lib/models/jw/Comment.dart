// lib/models/jw/Comment.dart

/// 댓글(Comment) 데이터를 나타내는 모델 클래스입니다.
/// 이 클래스는 댓글의 고유 ID, 게시글 ID, 사용자 ID, 닉네임, 내용,
/// 생성일 및 수정일 정보를 포함합니다.
class Comment {
  /// 댓글의 고유 ID (선택 사항, 데이터베이스에서 자동 생성될 수 있음)
  final int? id;

  /// 댓글이 속한 게시글의 ID
  final int postId;

  /// 댓글을 작성한 사용자의 ID (백엔드의 Long 타입에 대응되도록 int로 정의)
  final int userId;

  /// 댓글을 작성한 사용자의 닉네임
  final String nickname;

  /// 댓글 내용
  final String content;

  /// 댓글이 생성된 날짜 및 시간
  final DateTime createdAt;

  /// 댓글이 마지막으로 수정된 날짜 및 시간 (선택 사항)
  final DateTime? updatedAt;

  /// Comment 클래스의 생성자입니다.
  /// 필수 필드(postId, userId, nickname, content, createdAt)는 반드시 제공되어야 합니다.
  /// 선택적 필드(id, updatedAt)는 null을 허용합니다.
  Comment({
    this.id,
    required this.postId,
    required this.userId,
    required this.nickname,
    required this.content,
    required this.createdAt,
    this.updatedAt,
  });

  /// JSON 데이터로부터 Comment 객체를 생성하는 팩토리 메서드입니다.
  /// 백엔드에서 userId가 String으로 넘어올 경우를 대비하여 int.parse를 시도합니다.
  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      postId: json['postId'],
      userId:
          (json['userId'] is String)
              ? int.parse(json['userId']) // 백엔드에서 Long(문자열)으로 올 경우 처리
              : json['userId'], // 이미 int 또는 다른 숫자로 올 경우 그대로 사용
      nickname: json['nickname'],
      content: json['content'],
      createdAt: DateTime.parse(
        json['createdAt'],
      ), // ISO 8601 문자열을 DateTime으로 파싱
      updatedAt:
          json['updatedAt'] != null
              ? DateTime.parse(json['updatedAt'])
              : null, // 수정일이 null이 아니면 파싱
    );
  }

  /// Comment 객체를 JSON 형태로 변환하는 메서드입니다.
  /// 서버로 데이터를 전송할 때 사용됩니다.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'postId': postId,
      'userId': userId, // int 타입 그대로 전송
      'nickname': nickname,
      'content': content,
      'createdAt': createdAt.toIso8601String(), // DateTime을 ISO 8601 문자열로 변환
      'updatedAt':
          updatedAt?.toIso8601String(), // null이 아닐 경우에만 ISO 8601 문자열로 변환
    };
  }

  /// 현재 Comment 객체의 특정 필드를 변경하여 새로운 Comment 객체를 생성하는 메서드입니다.
  /// (불변성 유지를 위해 사용)
  Comment copyWith({
    int? id,
    int? postId,
    int? userId,
    String? nickname,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Comment(
      id: id ?? this.id, // 변경 값이 제공되면 사용, 아니면 기존 값 사용
      postId: postId ?? this.postId,
      userId: userId ?? this.userId,
      nickname: nickname ?? this.nickname,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
