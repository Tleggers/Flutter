import 'package:flutter/material.dart'; // Flutter UI 구성 요소를 위한 핵심 패키지
import 'package:provider/provider.dart'; // 상태 관리를 위한 Provider 패키지
import 'package:trekkit_flutter/functions/jh/userprovider.dart'; // 사용자 로그인 상태 및 정보 관리를 위한 UserProvider 임포트
import 'package:trekkit_flutter/models/jw/Post.dart'; // 게시글 데이터 모델인 Post 임포트
import 'package:trekkit_flutter/models/jw/Comment.dart'; // 댓글 데이터 모델인 Comment 임포트
import 'package:trekkit_flutter/services/jw/PostService.dart'; // 게시글 관련 API 호출을 위한 PostService 임포트
import 'package:trekkit_flutter/services/jw/CommentService.dart'; // 댓글 관련 API 호출을 위한 CommentService 임포트
import 'package:trekkit_flutter/pages/jh/Login_and_Signup/login.dart'; // 로그인 페이지 임포트 (로그인 필요 시 이동)

// CommentException과 CommentErrorType은 CommentService에 정의되어 있다고 가정합니다.
// 만약 다른 파일에 정의되어 있다면 해당 파일을 임포트해야 합니다.

/// 단일 게시글의 상세 내용을 표시하는 StatefulWidget입니다.
/// 게시글 내용, 이미지, 좋아요/북마크 기능, 그리고 댓글 섹션을 포함합니다.
/// 사용자는 댓글을 조회, 작성, 삭제할 수 있습니다.
class ViewDetail extends StatefulWidget {
  final Post post; // 상세 보기를 위한 Post 객체

  const ViewDetail({super.key, required this.post}); // Post 객체를 필수로 받는 생성자

  @override
  State<ViewDetail> createState() => _ViewDetailState(); // 이 위젯의 가변 상태를 생성
}

/// `ViewDetail`의 상태를 관리하는 State 클래스입니다.
/// 게시글 상세 내용, 좋아요/북마크 상태, 댓글 목록 및 입력 로직을 처리합니다.
class _ViewDetailState extends State<ViewDetail> {
  // 게시글 좋아요 및 북마크 관련 로딩 상태
  bool _isLikeLoading = false; // 좋아요 작업 진행 중 여부
  bool _isBookmarkLoading = false; // 북마크 작업 진행 중 여부

  late Post _currentPost; // 현재 표시되는 게시글 데이터 (좋아요 수 등 업데이트를 위해 상태로 관리)

  // 댓글 관련 상태 변수
  List<Comment> _comments = []; // 현재 게시글에 대한 댓글 목록
  bool _isLoadingComments = false; // 댓글 로딩 중 여부
  bool _isPostingComment = false; // 댓글 작성 중 여부
  final TextEditingController _commentController =
      TextEditingController(); // 댓글 입력 필드 컨트롤러

  @override
  void initState() {
    super.initState();
    _currentPost = widget.post; // 위젯 생성 시 전달받은 Post 객체로 초기화
    _loadComments(); // 페이지 초기화 시 댓글 목록 로드
  }

  @override
  void dispose() {
    _commentController.dispose(); // 댓글 텍스트 컨트롤러를 dispose하여 메모리 누수 방지
    super.dispose();
  }

  /// 현재 게시글의 댓글 목록을 백엔드에서 비동기로 로드합니다.
  /// 로딩 상태와 에러 상태를 관리하고, 로드된 댓글로 UI를 업데이트합니다.
  Future<void> _loadComments() async {
    if (_currentPost.id == null) return; // 게시글 ID가 없으면 댓글 로드하지 않음

    setState(() {
      _isLoadingComments = true; // 댓글 로딩 시작 상태로 변경
    });

    try {
      final comments = await CommentService.getCommentsByPostId(
        _currentPost.id!, // 게시글 ID를 사용하여 댓글 요청
      );
      setState(() {
        _comments = comments; // 로드된 댓글 목록으로 업데이트
        _isLoadingComments = false; // 댓글 로딩 완료 상태로 변경
      });
    } on CommentException catch (e) {
      // CommentException 발생 시 처리
      if (mounted) {
        _showErrorSnackBar(e.message, e.type); // 에러 스낵바 표시
        setState(() {
          _isLoadingComments = false; // 댓글 로딩 완료 상태로 변경 (오류 발생으로 완료)
        });
      }
    } catch (e) {
      // 예상치 못한 다른 오류 발생 시 처리
      if (mounted) {
        _showErrorSnackBar(
          '댓글 로딩 중 예상치 못한 오류가 발생했습니다', // 일반적인 오류 메시지
          CommentErrorType.unknown, // 알 수 없는 에러 타입으로 분류
        );
        setState(() {
          _isLoadingComments = false; // 댓글 로딩 완료 상태로 변경
        });
      }
    }
  }

  /// 새 댓글을 현재 게시글에 작성하는 기능을 처리합니다.
  /// 사용자 로그인 상태와 댓글 내용 유효성을 검사한 후, API를 호출합니다.
  Future<void> _postComment() async {
    // Provider를 통해 UserProvider 인스턴스에 접근 (listen: false로 불필요한 리빌드 방지)
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    // 로그인되지 않은 경우 로그인 페이지로 이동
    if (!userProvider.isLoggedIn) {
      final result = await Navigator.push<bool>(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
      if (result != true) return; // 로그인 실패 또는 취소 시 함수 실행 중단
    }

    final content = _commentController.text.trim(); // 댓글 내용 가져오기 및 공백 제거
    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('댓글 내용을 입력해주세요.'),
          backgroundColor: Colors.orange, // 경고성 배경색
        ),
      );
      return; // 내용이 비어있으면 함수 실행 중단
    }

    setState(() {
      _isPostingComment = true; // 댓글 작성 중 상태로 변경
    });

    try {
      // 새로운 Comment 객체 생성
      final newComment = Comment(
        postId: _currentPost.id!, // 현재 게시글 ID
        userId: userProvider.index!, // 로그인한 사용자 ID
        nickname: userProvider.nickname!, // 로그인한 사용자 닉네임
        content: content, // 입력된 댓글 내용
        createdAt: DateTime.now(), // 현재 시간으로 생성일 설정
      );

      // CommentService를 통해 댓글 생성 API 호출
      final createdComment = await CommentService.createComment(
        newComment,
        context, // context 전달
      );

      setState(() {
        _comments.add(createdComment); // 성공적으로 생성된 댓글을 목록에 추가
        _commentController.clear(); // 댓글 입력 필드 초기화
        _isPostingComment = false; // 댓글 작성 완료 상태로 변경
        // 게시글의 댓글 수를 1 증가시켜 UI에 반영 (불변성 유지를 위해 copyWith 사용)
        _currentPost = _currentPost.copyWith(
          commentCount: _currentPost.commentCount + 1,
        );
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('댓글이 작성되었습니다'),
            backgroundColor: Colors.green, // 성공 메시지 배경색
          ),
        );
      }
    } on CommentException catch (e) {
      // CommentException 발생 시 처리
      if (mounted) {
        _showErrorSnackBar(e.message, e.type); // 에러 스낵바 표시
        setState(() {
          _isPostingComment = false; // 댓글 작성 완료 상태로 변경 (오류 발생으로 완료)
        });
      }
    } catch (e) {
      // 예상치 못한 다른 오류 발생 시 처리
      if (mounted) {
        _showErrorSnackBar(
          '댓글 작성 중 예상치 못한 오류가 발생했습니다', // 일반적인 오류 메시지
          CommentErrorType.unknown, // 알 수 없는 에러 타입으로 분류
        );
        setState(() {
          _isPostingComment = false; // 댓글 작성 완료 상태로 변경
        });
      }
    }
  }

  /// 특정 댓글을 삭제하는 기능을 처리합니다.
  /// 로그인한 사용자가 해당 댓글의 작성자인지 확인 후, 삭제 API를 호출합니다.
  Future<void> _deleteComment(Comment comment) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    // 로그인되지 않았거나, 현재 사용자의 댓글이 아닌 경우 삭제 불가 메시지 표시
    if (!userProvider.isLoggedIn || comment.userId != userProvider.index) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('자신의 댓글만 삭제할 수 있습니다')));
      return; // 함수 실행 중단
    }

    // 삭제 확인 다이얼로그 표시
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('댓글 삭제'),
            content: const Text('정말 이 댓글을 삭제하시겠습니까?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false), // 취소 버튼
                child: const Text('취소'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true), // 삭제 확인 버튼
                child: const Text('삭제', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );

    if (confirmed != true) return; // 사용자가 삭제를 취소한 경우 함수 실행 중단

    try {
      // CommentService를 통해 댓글 삭제 API 호출
      final success = await CommentService.deleteComment(
        comment.id!, // 삭제할 댓글 ID
        _currentPost.id!, // 해당 댓글이 속한 게시글 ID
        context, // context 전달
      );

      if (success) {
        setState(() {
          _comments.removeWhere((c) => c.id == comment.id); // 목록에서 해당 댓글 제거
          // 게시글의 댓글 수를 1 감소시켜 UI에 반영
          _currentPost = _currentPost.copyWith(
            commentCount: _currentPost.commentCount - 1,
          );
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('댓글이 삭제되었습니다'),
              backgroundColor: Colors.green, // 성공 메시지 배경색
            ),
          );
        }
      }
    } on CommentException catch (e) {
      // CommentException 발생 시 처리
      if (mounted) {
        _showErrorSnackBar(e.message, e.type); // 에러 스낵바 표시
      }
    } catch (e) {
      // 예상치 못한 다른 오류 발생 시 처리
      if (mounted) {
        _showErrorSnackBar(
          '댓글 삭제 중 오류가 발생했습니다',
          CommentErrorType.unknown,
        ); // 일반적인 오류 메시지
      }
    }
  }

  /// 메시지와 에러 타입에 따라 다르게 표시되는 스낵바를 띄웁니다.
  /// 네트워크, 서버, 인증, 유효성 등 다양한 에러 상황에 맞춰 시각적 피드백을 제공합니다.
  void _showErrorSnackBar(String message, CommentErrorType errorType) {
    Color backgroundColor;
    IconData icon;

    // 에러 타입에 따라 스낵바의 배경색과 아이콘을 설정
    switch (errorType) {
      case CommentErrorType.network:
        backgroundColor = Colors.orange;
        icon = Icons.wifi_off;
        break;
      case CommentErrorType.serverError:
        backgroundColor = Colors.red;
        icon = Icons.error;
        break;
      case CommentErrorType.unauthorized:
      case CommentErrorType.forbidden:
        backgroundColor = Colors.amber;
        icon = Icons.lock;
        break;
      case CommentErrorType.validation:
        backgroundColor = Colors.blue;
        icon = Icons.info;
        break;
      default:
        backgroundColor = Colors.grey;
        icon = Icons.warning;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white), // 에러 아이콘
            const SizedBox(width: 8),
            Expanded(child: Text(message)), // 에러 메시지
          ],
        ),
        backgroundColor: backgroundColor, // 스낵바 배경색
        duration: const Duration(seconds: 4), // 스낵바 표시 시간
        action:
            // 네트워크 오류일 경우 '재시도' 버튼을 제공
            errorType == CommentErrorType.network
                ? SnackBarAction(
                  label: '재시도',
                  textColor: Colors.white,
                  onPressed: () => _loadComments(), // 댓글 로딩을 다시 시도
                )
                : null, // 그 외의 경우 액션 버튼 없음
      ),
    );
  }

  /// `DateTime` 객체를 'YYYY-MM-DD', 'X시간 전', 'X분 전', '방금 전' 형식으로 포맷팅합니다.
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date); // 현재 시간과의 차이 계산

    if (difference.inDays > 0) {
      // 1일 이상 차이 나면 'YYYY-MM-DD' 형식
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    } else if (difference.inHours > 0) {
      // 1시간 이상 차이 나면 'X시간 전'
      return '${difference.inHours}시간 전';
    } else if (difference.inMinutes > 0) {
      // 1분 이상 차이 나면 'X분 전'
      return '${difference.inMinutes}분 전';
    } else {
      // 그 외 (1분 미만) '방금 전'
      return '방금 전';
    }
  }

  /// 게시글에 대한 좋아요/좋아요 취소 기능을 토글합니다.
  /// 로그인 상태를 확인하고, PostService를 통해 API를 호출한 후 게시글의 좋아요 수를 업데이트합니다.
  Future<void> _toggleLike() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    // 로그인되지 않은 경우 스낵바 메시지 표시 및 함수 실행 중단
    if (!userProvider.isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('로그인이 필요합니다'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    if (_isLikeLoading) return; // 이미 좋아요 처리 중이면 중복 호출 방지

    setState(() {
      _isLikeLoading = true; // 좋아요 로딩 상태 시작
    });

    try {
      // PostService를 통해 좋아요/취소 API 호출
      final result = await PostService.toggleLike(
        _currentPost.id!, // 게시글 ID
        context, // context 전달
      );

      setState(() {
        // API 응답에서 받은 새로운 좋아요 수로 게시글 업데이트
        _currentPost = _currentPost.copyWith(likeCount: result['likeCount']);
      });
    } catch (e) {
      // 오류 발생 시 스낵바 메시지 표시
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('좋아요 처리 실패: $e')));
      }
    } finally {
      // 로딩 상태 종료
      if (mounted) {
        setState(() {
          _isLikeLoading = false;
        });
      }
    }
  }

  /// 게시글에 대한 북마크/북마크 취소 기능을 토글합니다.
  /// 로그인 상태를 확인하고, PostService를 통해 API를 호출합니다.
  Future<void> _toggleBookmark() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    // 로그인되지 않은 경우 스낵바 메시지 표시 및 함수 실행 중단
    if (!userProvider.isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('로그인이 필요합니다'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    if (_isBookmarkLoading) return; // 이미 북마크 처리 중이면 중복 호출 방지

    setState(() {
      _isBookmarkLoading = true; // 북마크 로딩 상태 시작
    });

    try {
      // PostService를 통해 북마크/취소 API 호출
      await PostService.toggleBookmark(_currentPost.id!, context); // context 전달

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('북마크가 처리되었습니다'),
            backgroundColor: Colors.green, // 성공 메시지 배경색
          ),
        );
      }
    } catch (e) {
      // 오류 발생 시 스낵바 메시지 표시
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('북마크 처리 실패: $e')));
      }
    } finally {
      // 로딩 상태 종료
      if (mounted) {
        setState(() {
          _isBookmarkLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // UserProvider 인스턴스 가져오기 (댓글 입력 필드의 활성화/비활성화에 사용)
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('게시글 상세'), // 앱 바 제목
        backgroundColor: Colors.green, // 앱 바 배경색
        foregroundColor: Colors.white, // 앱 바 전경색 (아이콘, 텍스트 색상)
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16), // 전체 스크롤 뷰 패딩
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 게시글 작성자 정보 및 산 태그
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 24, // 아바타 크기
                        backgroundColor: Colors.green[100],
                        child: Text(
                          _currentPost.nickname.isNotEmpty
                              ? _currentPost.nickname[0]
                                  .toUpperCase() // 닉네임 첫 글자를 대문자로
                              : 'U', // 닉네임이 없으면 'U' 표시
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12), // 간격
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _currentPost.nickname, // 작성자 닉네임
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            Text(
                              _formatDate(_currentPost.createdAt), // 작성일 포맷팅
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      // 산 태그
                      if (_currentPost.mountain.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green[100],
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            _currentPost.mountain, // 산 이름
                            style: TextStyle(
                              color: Colors.green[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20), // 간격
                  // 게시글 제목
                  if (_currentPost.title != null &&
                      _currentPost.title!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        _currentPost.title!, // 게시글 제목
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  // 게시글 이미지 (PageView로 슬라이드 가능)
                  if (_currentPost.imagePaths.isNotEmpty)
                    Container(
                      height: 250, // 이미지 갤러리 높이
                      margin: const EdgeInsets.only(bottom: 20),
                      child: PageView.builder(
                        itemCount: _currentPost.imagePaths.length, // 이미지 개수
                        itemBuilder: (context, index) {
                          // 이미지 URL 생성 (로컬 개발 환경 기준)
                          final imageUrl =
                              'http://10.0.2.2:30000${_currentPost.imagePaths[index]}';
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                imageUrl,
                                fit: BoxFit.cover, // 이미지가 컨테이너에 맞게 채워지도록
                                // 이미지 로드 실패 시 대체 위젯
                                errorBuilder:
                                    (context, error, stackTrace) => Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Icon(
                                            Icons.broken_image,
                                            size: 60,
                                            color: Colors.grey,
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            '이미지 로드 실패: ${index + 1}',
                                            style: const TextStyle(
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  // 게시글 내용
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50], // 연한 회색 배경
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _currentPost.content, // 게시글 내용
                      style: const TextStyle(fontSize: 16, height: 1.6),
                    ),
                  ),
                  const SizedBox(height: 20), // 간격
                  // 좋아요, 댓글 수, 조회수 및 북마크 버튼 섹션
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        // 좋아요 버튼
                        InkWell(
                          onTap: _toggleLike, // 좋아요 토글 함수 호출
                          borderRadius: BorderRadius.circular(20),
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _isLikeLoading
                                    ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                    : const Icon(
                                      Icons.favorite_border,
                                      color: Colors.red,
                                    ),
                                const SizedBox(width: 4),
                                Text('${_currentPost.likeCount}'), // 좋아요 수
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 20), // 간격
                        // 댓글 수 표시
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.comment, color: Colors.blue),
                            const SizedBox(width: 4),
                            Text('${_currentPost.commentCount}'), // 댓글 수
                          ],
                        ),
                        const SizedBox(width: 20), // 간격
                        // 조회수 표시
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.visibility, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text('${_currentPost.viewCount}'), // 조회수
                          ],
                        ),
                        const Spacer(), // 남은 공간을 채워 오른쪽 정렬
                        // 북마크 버튼
                        InkWell(
                          onTap: _toggleBookmark, // 북마크 토글 함수 호출
                          borderRadius: BorderRadius.circular(20),
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child:
                                _isBookmarkLoading
                                    ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                    : Icon(
                                      Icons.bookmark_border,
                                      color: Colors.yellow[700],
                                    ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 댓글 섹션 제목
                  Padding(
                    padding: const EdgeInsets.only(top: 24, bottom: 12),
                    child: Row(
                      children: [
                        const Icon(Icons.comment, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          '댓글 ${_comments.length}개', // 총 댓글 개수 표시
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 댓글 목록
                  if (_isLoadingComments)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: CircularProgressIndicator(), // 댓글 로딩 중일 때 표시
                      ),
                    )
                  else if (_comments.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(24),
                      alignment: Alignment.center,
                      child: Column(
                        children: [
                          Icon(
                            Icons.chat_bubble_outline,
                            size: 48,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '아직 댓글이 없습니다',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '첫 번째 댓글을 남겨보세요!',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true, // ListView가 필요한 만큼만 공간을 차지하도록
                      physics:
                          const NeverScrollableScrollPhysics(), // ListView 자체 스크롤 비활성화 (SingleChildScrollView가 처리)
                      itemCount: _comments.length, // 댓글 개수
                      separatorBuilder:
                          (context, index) => const Divider(), // 댓글 사이에 구분선
                      itemBuilder: (context, index) {
                        final comment = _comments[index];
                        return CommentItem(
                          comment: comment, // 댓글 데이터 전달
                          onDelete: () => _deleteComment(comment), // 댓글 삭제 콜백
                        );
                      },
                    ),
                ],
              ),
            ),
          ),

          // 댓글 입력 영역
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05), // 그림자 효과
                  blurRadius: 10,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController, // 댓글 입력 컨트롤러
                    decoration: InputDecoration(
                      hintText:
                          userProvider
                                  .isLoggedIn // 로그인 상태에 따라 힌트 텍스트 변경
                              ? '댓글을 입력하세요...'
                              : '로그인 후 댓글을 작성할 수 있습니다',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24), // 둥근 모서리
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      enabled: userProvider.isLoggedIn, // 로그인 상태에 따라 활성화/비활성화
                    ),
                    maxLines: 1, // 한 줄 입력 (넘치면 스크롤)
                    maxLength: 200, // 최대 200자
                    textInputAction: TextInputAction.send, // 키보드 액션 버튼을 보내기로
                    onSubmitted: (_) => _postComment(), // 엔터 시 댓글 작성
                  ),
                ),
                const SizedBox(width: 8), // 간격
                // 댓글 전송 버튼
                IconButton(
                  onPressed:
                      _isPostingComment || !userProvider.isLoggedIn
                          ? null // 댓글 작성 중이거나 로그인되지 않았으면 버튼 비활성화
                          : _postComment, // 댓글 작성 함수 호출
                  icon:
                      _isPostingComment
                          ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ), // 로딩 중일 때 표시
                          )
                          : const Icon(
                            Icons.send,
                            color: Colors.green,
                          ), // 보내기 아이콘
                  tooltip: '댓글 작성', // 툴팁
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 개별 댓글 항목을 표시하는 StatelessWidget입니다.
/// 댓글 작성자 정보, 내용, 그리고 작성자인 경우 삭제 버튼을 포함합니다.
class CommentItem extends StatelessWidget {
  final Comment comment; // 표시할 댓글 데이터
  final VoidCallback onDelete; // 댓글 삭제 시 호출될 콜백

  const CommentItem({super.key, required this.comment, required this.onDelete});

  /// `DateTime` 객체를 'YYYY-MM-DD', 'X시간 전', 'X분 전', '방금 전' 형식으로 포맷팅합니다.
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date); // 현재 시간과의 차이 계산

    if (difference.inDays > 0) {
      // 1일 이상 차이 나면 'YYYY-MM-DD' 형식
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    } else if (difference.inHours > 0) {
      // 1시간 이상 차이 나면 'X시간 전'
      return '${difference.inHours}시간 전';
    } else if (difference.inMinutes > 0) {
      // 1분 이상 차이 나면 'X분 전'
      return '${difference.inMinutes}분 전';
    } else {
      // 그 외 (1분 미만) '방금 전'
      return '방금 전';
    }
  }

  @override
  Widget build(BuildContext context) {
    // UserProvider를 통해 현재 사용자 정보 가져오기
    final userProvider = Provider.of<UserProvider>(context);
    // 현재 댓글이 로그인한 사용자의 댓글인지 확인
    final isMyComment = userProvider.index == comment.userId; // userId를 int로 비교

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start, // 내용을 상단에 정렬
        children: [
          // 프로필 아바타
          CircleAvatar(
            radius: 16,
            backgroundColor: Colors.green[50],
            child: Text(
              comment.nickname.isNotEmpty
                  ? comment.nickname[0]
                      .toUpperCase() // 닉네임 첫 글자를 대문자로
                  : 'U', // 닉네임이 없으면 'U' 표시
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green[700],
                fontSize: 14,
              ),
            ),
          ),

          const SizedBox(width: 12), // 간격
          // 댓글 내용
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      comment.nickname, // 작성자 닉네임
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatDate(comment.createdAt), // 작성일 포맷팅
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
                const SizedBox(height: 4), // 간격
                Text(
                  comment.content,
                  style: const TextStyle(fontSize: 14),
                ), // 댓글 내용
              ],
            ),
          ),

          // 삭제 버튼 (댓글이 현재 로그인한 사용자의 것일 경우에만 표시)
          if (isMyComment)
            IconButton(
              onPressed: onDelete, // 삭제 콜백 함수 호출
              icon: const Icon(Icons.delete_outline, size: 18), // 삭제 아이콘
              color: Colors.grey[600], // 아이콘 색상
              tooltip: '댓글 삭제', // 툴팁
              constraints: const BoxConstraints(), // 아이콘 버튼의 크기 제약 없이
              padding: const EdgeInsets.all(8), // 패딩
              visualDensity: VisualDensity.compact, // 시각적 밀도 압축
            ),
        ],
      ),
    );
  }
}
