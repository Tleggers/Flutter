/// 게시글(Post) 데이터를 나타내는 모델 클래스입니다.
/// 이 클래스는 게시글의 고유 ID, 작성자 닉네임, 제목, 산 이름, 내용,
/// 이미지 경로 목록, 좋아요 수, 댓글 수, 조회수, 생성일 및 수정일 정보를 포함합니다.
class Post {
  /// 게시글의 고유 ID (선택 사항, 데이터베이스에서 자동 생성될 수 있음)
  final int? id;

  /// 게시글을 작성한 사용자의 닉네임
  final String nickname;

  /// 게시글의 제목 (선택 사항)
  final String? title;

  /// 게시글과 관련된 산의 이름
  /// 백엔드에서는 'mountainName'으로 처리될 수 있지만, 프론트에서는 'mountain'으로 유지됩니다.
  final String mountain;

  /// 게시글의 내용
  final String content;

  /// 게시글에 첨부된 이미지 경로 목록 (기본값: 빈 리스트)
  final List<String> imagePaths;

  /// 게시글의 좋아요 수 (기본값: 0)
  final int likeCount;

  /// 게시글의 댓글 수 (기본값: 0)
  final int commentCount;

  /// 게시글의 조회수 (기본값: 0)
  final int viewCount;

  /// 게시글이 생성된 날짜 및 시간
  final DateTime createdAt;

  /// 게시글이 마지막으로 수정된 날짜 및 시간 (선택 사항)
  final DateTime? updatedAt;

  /// Post 클래스의 생성자입니다.
  /// 필수 필드(nickname, mountain, content, createdAt)는 반드시 제공되어야 합니다.
  /// 선택적 필드(id, title, imagePaths, likeCount, commentCount, viewCount, updatedAt)는 기본값을 가지거나 null을 허용합니다.
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

  /// JSON 데이터로부터 Post 객체를 생성하는 팩토리 메서드입니다.
  /// 백엔드 API 응답의 유연성을 위해 'mountain' 또는 'mountainName' 필드를 모두 고려합니다.
  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      nickname: json['nickname'] ?? '',
      title: json['title'],
      mountain:
          json['mountain'] ??
          json['mountainName'] ??
          '', // 'mountain' 또는 'mountainName' 중 하나를 사용
      content: json['content'] ?? '',
      imagePaths:
          json['imagePaths'] != null
              ? List<String>.from(json['imagePaths']) // 이미지 경로 목록 파싱
              : [],
      likeCount: json['likeCount'] ?? 0,
      commentCount: json['commentCount'] ?? 0,
      viewCount: json['viewCount'] ?? 0,
      createdAt:
          json['createdAt'] != null
              ? DateTime.parse(json['createdAt']) // ISO 8601 문자열을 DateTime으로 파싱
              : DateTime.now(), // createdAt이 없을 경우 현재 시간으로 기본값 설정
      updatedAt:
          json['updatedAt'] != null
              ? DateTime.parse(json['updatedAt'])
              : null, // 수정일이 null이 아니면 파싱
    );
  }

  /// Post 객체를 JSON 형태로 변환하는 메서드입니다.
  /// 서버로 데이터를 전송할 때 사용됩니다.
  /// 특히, 'mountain' 필드는 백엔드의 'mountainName'에 맞춰 전송됩니다.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nickname': nickname,
      'title': title,
      'mountainName': mountain, // 백엔드로 전송할 때는 'mountainName' 키 사용
      'content': content,
      'imagePaths': imagePaths,
      'likeCount': likeCount,
      'commentCount': commentCount,
      'viewCount': viewCount,
      'createdAt': createdAt.toIso8601String(), // DateTime을 ISO 8601 문자열로 변환
      'updatedAt':
          updatedAt?.toIso8601String(), // null이 아닐 경우에만 ISO 8601 문자열로 변환
    };
  }

  /// 현재 Post 객체의 특정 필드를 변경하여 새로운 Post 객체를 생성하는 메서드입니다.
  /// (불변성 유지를 위해 사용)
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
      id: id ?? this.id, // 변경 값이 제공되면 사용, 아니면 기존 값 사용
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
