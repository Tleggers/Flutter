import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trekkit_flutter/functions/jh/userprovider.dart';
import 'package:trekkit_flutter/models/jw/Post.dart';
import 'package:trekkit_flutter/models/jw/Comment.dart';
import 'package:trekkit_flutter/pages/jw/PostWriting.dart';
import 'package:trekkit_flutter/services/jw/PostService.dart';
import 'package:trekkit_flutter/services/jw/CommentService.dart';
import 'package:trekkit_flutter/pages/jh/Login_and_Signup/login.dart';

/// 게시글 상세 페이지를 담당하는 StatefulWidget입니다.
/// 특정 게시글의 내용과 댓글 목록을 표시하고, 작성자는 수정/삭제할 수 있습니다.
class ViewDetail extends StatefulWidget {
  final Post post; // 상세 보기할 게시글 객체

  const ViewDetail({super.key, required this.post});

  @override
  State<ViewDetail> createState() => _ViewDetailState();
}

/// ViewDetail 페이지의 상태를 관리하는 State 클래스입니다.
/// 게시글 정보, 좋아요/북마크 상태, 댓글 목록 등을 관리합니다.
class _ViewDetailState extends State<ViewDetail> {
  bool _isLikeLoading = false; // 좋아요 처리 중 여부
  bool _isBookmarkLoading = false; // 북마크 처리 중 여부
  late Post _currentPost; // 현재 표시되는 게시글 (상태 변경 반영을 위해 State 내에서 관리)
  List<Comment> _comments = []; // 현재 게시글의 댓글 목록
  bool _isLoadingComments = false; // 댓글 로딩 중 여부
  bool _isPostingComment = false; // 댓글 작성 중 여부
  final TextEditingController _commentController =
      TextEditingController(); // 댓글 입력 필드 컨트롤러

  @override
  void initState() {
    super.initState();
    _currentPost = widget.post; // 초기 게시글 데이터 설정
    _loadComments(); // 페이지 초기화 시 댓글 목록 로드
  }

  @override
  void dispose() {
    _commentController.dispose(); // 댓글 입력 컨트롤러 dispose
    super.dispose();
  }

  /// 현재 게시글의 댓글 목록을 백엔드에서 비동기로 로드합니다.
  Future<void> _loadComments() async {
    if (_currentPost.id == null) return; // 게시글 ID가 없으면 로드하지 않음
    setState(() => _isLoadingComments = true); // 로딩 상태 시작
    try {
      final comments = await CommentService.getCommentsByPostId(
        _currentPost.id!,
      );
      if (mounted) {
        setState(() {
          _comments = comments; // 로드된 댓글 목록 업데이트
        });
      }
    } catch (e) {
      // 댓글 로딩 중 오류 발생 시 콘솔에 로깅
      print("댓글 로딩 중 오류 발생: $e");
    } finally {
      if (mounted) {
        setState(() => _isLoadingComments = false); // 로딩 상태 종료
      }
    }
  }

  /// 새 댓글을 현재 게시글에 작성하는 기능을 처리합니다.
  /// 로그인 여부 확인, 내용 유효성 검사 후 댓글 생성 API를 호출합니다.
  Future<void> _postComment() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    // 로그인되지 않은 경우 로그인 페이지로 이동 요청
    if (!userProvider.isLoggedIn) {
      final result = await Navigator.push<bool>(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
      if (result != true) return; // 로그인 실패 또는 취소 시 함수 종료
    }

    final content = _commentController.text.trim();
    if (content.isEmpty) {
      _showSnackBar('댓글 내용을 입력해주세요.', isError: true);
      return;
    }

    setState(() => _isPostingComment = true); // 댓글 작성 중 상태 시작

    try {
      final newComment = Comment(
        postId: _currentPost.id!,
        userId: userProvider.index!, // 사용자 고유 ID
        nickname: userProvider.nickname!,
        content: content,
        createdAt: DateTime.now(), // 현재 시간으로 생성일 설정
      );
      final createdComment = await CommentService.createComment(
        newComment,
        context,
      );
      setState(() {
        _comments.add(createdComment); // 새로 생성된 댓글 목록에 추가
        _commentController.clear(); // 입력 필드 초기화
        _currentPost = _currentPost.copyWith(
          commentCount: _currentPost.commentCount + 1, // 댓글 수 증가
        );
      });
      _showSnackBar('댓글이 작성되었습니다.');
    } catch (e) {
      _showSnackBar('댓글 작성 실패: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isPostingComment = false); // 댓글 작성 중 상태 종료
    }
  }

  /// 게시글 수정 페이지로 이동합니다.
  /// 수정 완료 시 이전 화면(게시글 목록)에 갱신이 필요함을 알립니다.
  void _navigateToEditPage() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => PostWriting(post: _currentPost)),
    );

    if (result == true && mounted) {
      // true를 반환하여 이전 화면(게시글 목록)에 갱신 필요를 알림
      Navigator.pop(context, true);
    }
  }

  /// 게시글 삭제 로직을 처리합니다.
  /// 사용자에게 삭제 확인 다이얼로그를 표시한 후, 삭제 API를 호출합니다.
  Future<void> _deletePost() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('게시글 삭제'),
            content: const Text('정말 이 게시글을 삭제하시겠습니까?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false), // 취소
                child: const Text('취소'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true), // 삭제 확인
                child: const Text('삭제', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );

    if (confirmed != true) return; // 삭제 취소 시 함수 종료

    try {
      await PostService.deletePost(_currentPost.id!, context);
      if (mounted) {
        _showSnackBar('게시글이 삭제되었습니다.');
        // true를 반환하여 이전 화면(게시글 목록)에 갱신 필요를 알림
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('게시글 삭제 실패: $e', isError: true);
      }
    }
  }

  /// 사용자에게 메시지를 표시하는 스낵바를 띄웁니다.
  /// [isError] 값에 따라 스낵바의 배경색이 달라집니다.
  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  /// 게시글 좋아요 상태를 토글(추가/취소)합니다.
  /// 로그인 여부 확인 후, 좋아요 API를 호출하고 좋아요 수를 업데이트합니다.
  Future<void> _toggleLike() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (!userProvider.isLoggedIn) {
      _showSnackBar('로그인이 필요합니다.', isError: true);
      return;
    }
    if (_isLikeLoading) return; // 이미 처리 중이면 중복 호출 방지
    setState(() => _isLikeLoading = true); // 로딩 상태 시작
    try {
      final result = await PostService.toggleLike(_currentPost.id!, context);
      setState(() {
        _currentPost = _currentPost.copyWith(
          likeCount: result['likeCount'],
        ); // 좋아요 수 업데이트
      });
    } catch (e) {
      _showSnackBar('좋아요 처리 실패: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isLikeLoading = false); // 로딩 상태 종료
    }
  }

  /// 게시글 북마크 상태를 토글(추가/취소)합니다.
  /// 로그인 여부 확인 후, 북마크 API를 호출합니다.
  Future<void> _toggleBookmark() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (!userProvider.isLoggedIn) {
      _showSnackBar('로그인이 필요합니다.', isError: true);
      return;
    }
    if (_isBookmarkLoading) return; // 이미 처리 중이면 중복 호출 방지
    setState(() => _isBookmarkLoading = true); // 로딩 상태 시작
    try {
      await PostService.toggleBookmark(_currentPost.id!, context);
      _showSnackBar('북마크가 처리되었습니다.');
    } catch (e) {
      _showSnackBar('북마크 처리 실패: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isBookmarkLoading = false); // 로딩 상태 종료
    }
  }

  /// 댓글을 수정하는 다이얼로그를 표시하고 수정 요청을 처리합니다.
  Future<void> _editComment(Comment commentToEdit) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (!userProvider.isLoggedIn ||
        userProvider.index != commentToEdit.userId) {
      _showSnackBar('댓글 수정 권한이 없습니다.', isError: true);
      return;
    }

    final TextEditingController editController = TextEditingController(
      text: commentToEdit.content,
    );
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('댓글 수정'),
            content: TextField(
              controller: editController,
              decoration: const InputDecoration(hintText: '댓글 내용을 입력하세요'),
              maxLines: null,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('취소'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('수정'),
              ),
            ],
          ),
    );

    if (confirmed == true && editController.text.trim().isNotEmpty) {
      try {
        final updatedComment = commentToEdit.copyWith(
          content: editController.text.trim(),
        );
        await CommentService.updateComment(updatedComment, context);
        _showSnackBar('댓글이 수정되었습니다.');
        _loadComments(); // 댓글 목록 새로고침
      } catch (e) {
        _showSnackBar('댓글 수정 실패: $e', isError: true);
      }
    } else if (confirmed == true && editController.text.trim().isEmpty) {
      _showSnackBar('댓글 내용을 입력해주세요.', isError: true);
    }
    editController.dispose();
  }

  /// 댓글을 삭제하는 로직을 처리합니다.
  Future<void> _deleteComment(Comment commentToDelete) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (!userProvider.isLoggedIn ||
        userProvider.index != commentToDelete.userId) {
      _showSnackBar('댓글 삭제 권한이 없습니다.', isError: true);
      return;
    }

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('댓글 삭제'),
            content: const Text('정말로 이 댓글을 삭제하시겠습니까?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('취소'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('삭제', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      try {
        await CommentService.deleteComment(
          commentToDelete.id!,
          commentToDelete.postId,
          context,
        );
        _showSnackBar('댓글이 삭제되었습니다.');
        _loadComments(); // 댓글 목록 새로고침
        setState(() {
          _currentPost = _currentPost.copyWith(
            commentCount: _currentPost.commentCount - 1,
          ); // 댓글 수 감소
        });
      } catch (e) {
        _showSnackBar('댓글 삭제 실패: $e', isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    // 현재 로그인된 사용자가 게시글 작성자인지 확인
    final bool isAuthor =
        userProvider.isLoggedIn && userProvider.index == _currentPost.userId;

    return Scaffold(
      appBar: AppBar(
        title: const Text('게시글 상세'), // 앱 바 제목
        backgroundColor: Colors.green, // 앱 바 배경색
        foregroundColor: Colors.white, // 앱 바 전경색
        actions: [
          // 작성자일 경우에만 수정/삭제 메뉴 버튼을 표시합니다.
          if (isAuthor)
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  _navigateToEditPage(); // 수정 페이지로 이동
                } else if (value == 'delete') {
                  _deletePost(); // 게시글 삭제
                }
              },
              itemBuilder:
                  (BuildContext context) => <PopupMenuEntry<String>>[
                    const PopupMenuItem<String>(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 20),
                          SizedBox(width: 8),
                          Text('수정'),
                        ],
                      ),
                    ),
                    const PopupMenuItem<String>(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(
                            Icons.delete_outline,
                            size: 20,
                            color: Colors.red,
                          ),
                          SizedBox(width: 8),
                          Text('삭제', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0), // 전체 패딩
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 작성자 정보 및 산 태그 영역
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        child: Text(
                          _currentPost.nickname.isNotEmpty
                              ? _currentPost.nickname[0].toUpperCase()
                              : 'U', // 닉네임 첫 글자 또는 'U' 표시
                        ),
                      ),
                      const SizedBox(width: 12),
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
                              _currentPost.createdAt
                                  .toString(), // 작성일 (추후 포맷팅 필요)
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      if (_currentPost.mountain.isNotEmpty)
                        Chip(label: Text(_currentPost.mountain)), // 산 태그
                    ],
                  ),
                  const SizedBox(height: 20),
                  // 게시글 제목
                  if (_currentPost.title != null)
                    Text(
                      _currentPost.title!,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  const SizedBox(height: 16),
                  // 게시글 이미지 슬라이더 (이미지가 있을 경우)
                  if (_currentPost.imagePaths.isNotEmpty)
                    SizedBox(
                      height: 250,
                      child: PageView.builder(
                        itemCount: _currentPost.imagePaths.length,
                        itemBuilder: (context, index) {
                          final imageUrl =
                              'http://10.0.2.2:30000${_currentPost.imagePaths[index]}';
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4.0,
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (context, error, stackTrace) =>
                                        const Center(
                                          child: Icon(Icons.broken_image),
                                        ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  const SizedBox(height: 16),
                  // 게시글 내용
                  Text(
                    _currentPost.content,
                    style: const TextStyle(fontSize: 16, height: 1.6),
                  ),
                  const SizedBox(height: 20),
                  // 좋아요, 댓글, 조회수, 북마크 아이콘 및 통계
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.favorite_border),
                            onPressed: _toggleLike, // 좋아요 토글
                          ),
                          Text('${_currentPost.likeCount}'), // 좋아요 수
                          const SizedBox(width: 16),
                          const Icon(Icons.comment),
                          Text('${_currentPost.commentCount}'), // 댓글 수
                          const SizedBox(width: 16),
                          const Icon(Icons.visibility),
                          Text('${_currentPost.viewCount}'), // 조회수
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.bookmark_border),
                        onPressed: _toggleBookmark, // 북마크 토글
                      ),
                    ],
                  ),
                  const Divider(height: 40), // 구분선
                  // 댓글 섹션 헤더
                  Text(
                    '댓글 ${_comments.length}개',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // 댓글 목록 (로딩 중이거나 댓글이 없는 경우 처리)
                  _isLoadingComments
                      ? const Center(child: CircularProgressIndicator())
                      : ListView.builder(
                        shrinkWrap: true,
                        physics:
                            const NeverScrollableScrollPhysics(), // ListView 자체 스크롤 비활성화
                        itemCount: _comments.length,
                        itemBuilder: (context, index) {
                          final comment = _comments[index];
                          final userProvider = Provider.of<UserProvider>(
                            context,
                          );
                          final bool isCommentAuthor =
                              userProvider.isLoggedIn &&
                              userProvider.index == comment.userId;

                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 16,
                                        backgroundColor: Colors.blue[100],
                                        child: Text(
                                          comment.nickname.isNotEmpty
                                              ? comment.nickname[0]
                                                  .toUpperCase()
                                              : 'U',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue[700],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        comment.nickname,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        comment.createdAt.toString().split(
                                          ' ',
                                        )[0], // 간단한 날짜 포맷
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      const Spacer(),
                                      // 댓글 작성자에게만 수정/삭제 버튼 노출
                                      if (isCommentAuthor)
                                        PopupMenuButton<String>(
                                          onSelected: (value) {
                                            if (value == 'edit') {
                                              _editComment(comment);
                                            } else if (value == 'delete') {
                                              _deleteComment(comment);
                                            }
                                          },
                                          itemBuilder:
                                              (context) => [
                                                const PopupMenuItem(
                                                  value: 'edit',
                                                  child: Text('수정'),
                                                ),
                                                const PopupMenuItem(
                                                  value: 'delete',
                                                  child: Text('삭제'),
                                                ),
                                              ],
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    comment.content,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                ],
              ),
            ),
          ),
          // 댓글 입력창
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController, // 댓글 입력 컨트롤러
                    decoration: InputDecoration(
                      hintText: '댓글을 입력하세요...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  // 댓글 전송 중에는 버튼 비활성화 및 로딩 인디케이터 표시
                  onPressed: _isPostingComment ? null : _postComment,
                  icon:
                      _isPostingComment
                          ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : const Icon(Icons.send), // 평상시에는 보내기 아이콘 표시
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
