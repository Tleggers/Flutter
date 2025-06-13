import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trekkit_flutter/functions/jh/userprovider.dart';
import 'package:trekkit_flutter/models/jw/Post.dart';
import 'package:trekkit_flutter/models/jw/Comment.dart';
import 'package:trekkit_flutter/services/jw/AuthService.dart';
import 'package:trekkit_flutter/services/jw/PostService.dart';
import 'package:trekkit_flutter/services/jw/CommentService.dart';
import 'package:trekkit_flutter/pages/jh/Login_and_Signup/login.dart';

class ViewDetail extends StatefulWidget {
  final Post post;

  const ViewDetail({super.key, required this.post});

  @override
  State<ViewDetail> createState() => _ViewDetailState();
}

class _ViewDetailState extends State<ViewDetail> {
  bool _isLikeLoading = false;
  bool _isBookmarkLoading = false;
  late Post _currentPost;

  // 댓글 관련 상태 변수 추가
  List<Comment> _comments = [];
  bool _isLoadingComments = false;
  bool _isPostingComment = false;
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _currentPost = widget.post;
    _loadComments(); // 댓글 로딩 추가
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  // 🆕 개선된 댓글 로딩
  Future<void> _loadComments() async {
    if (_currentPost.id == null) return;

    setState(() {
      _isLoadingComments = true;
    });

    try {
      final comments = await CommentService.getCommentsByPostId(
        _currentPost.id!,
      );
      setState(() {
        _comments = comments;
        _isLoadingComments = false;
      });
    } on CommentException catch (e) {
      if (mounted) {
        _showErrorSnackBar(e.message, e.type);
        setState(() {
          _isLoadingComments = false;
        });
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar(
          '댓글 로딩 중 예상치 못한 오류가 발생했습니다',
          CommentErrorType.unknown,
        );
        setState(() {
          _isLoadingComments = false;
        });
      }
    }
  }

  // 🆕 개선된 댓글 작성
  Future<void> _postComment() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    if (!userProvider.isLoggedIn) {
      final result = await Navigator.push<bool>(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );

      if (result != true) return;
    }

    final content = _commentController.text.trim();

    setState(() {
      _isPostingComment = true;
    });

    try {
      final newComment = Comment(
        postId: _currentPost.id!,
        userId: userProvider.index.toString(), // index를 문자열로 변환
        nickname: userProvider.nickname!,
        content: content,
        createdAt: DateTime.now(),
      );

      final createdComment = await CommentService.createComment(newComment);

      setState(() {
        _comments.add(createdComment);
        _commentController.clear();
        _isPostingComment = false;
        _currentPost = _currentPost.copyWith(
          commentCount: _currentPost.commentCount + 1,
        );
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('댓글이 작성되었습니다'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } on CommentException catch (e) {
      // 기존 코드 유지
    } catch (e) {
      // 기존 코드 유지
    }
  }

  // 🆕 개선된 댓글 삭제
  Future<void> _deleteComment(Comment comment) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    if (comment.userId != userProvider.index.toString()) {
      // index를 문자열로 변환
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('자신의 댓글만 삭제할 수 있습니다')));
      return;
    }

    // 삭제 확인 다이얼로그
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('댓글 삭제'),
            content: const Text('정말 이 댓글을 삭제하시겠습니까?'),
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

    if (confirmed != true) return;

    try {
      final success = await CommentService.deleteComment(
        comment.id!,
        _currentPost.id!,
      );

      if (success) {
        setState(() {
          _comments.removeWhere((c) => c.id == comment.id);
          _currentPost = _currentPost.copyWith(
            commentCount: _currentPost.commentCount - 1,
          );
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('댓글이 삭제되었습니다'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } on CommentException catch (e) {
      if (mounted) {
        _showErrorSnackBar(e.message, e.type);
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('댓글 삭제 중 오류가 발생했습니다', CommentErrorType.unknown);
      }
    }
  }

  // 🆕 에러 스낵바 표시 (에러 타입별 색상 구분)
  void _showErrorSnackBar(String message, CommentErrorType errorType) {
    Color backgroundColor;
    IconData icon;

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
            Icon(icon, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: backgroundColor,
        duration: const Duration(seconds: 4),
        action:
            errorType == CommentErrorType.network
                ? SnackBarAction(
                  label: '재시도',
                  textColor: Colors.white,
                  onPressed: () => _loadComments(),
                )
                : null,
      ),
    );
  }

  // 🆕 날짜 포맷팅 함수
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}시간 전';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}분 전';
    } else {
      return '방금 전';
    }
  }

  // 좋아요 토글 수정
  Future<void> _toggleLike() async {
    // UserProvider를 사용하여 로그인 상태 확인
    final userProvider = Provider.of<UserProvider>(context, listen: false);

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

    if (_isLikeLoading) return;

    setState(() {
      _isLikeLoading = true;
    });

    try {
      // userProvider.index가 null이 아닌지 확인하고, 문자열로 변환하여 전달
      if (userProvider.index != null) {
        final result = await PostService.toggleLike(
          _currentPost.id!,
          userProvider.index.toString(), // index를 문자열로 변환
        );

        setState(() {
          _currentPost = _currentPost.copyWith(likeCount: result['likeCount']);
        });
      } else {
        throw Exception('사용자 ID가 유효하지 않습니다');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('좋아요 처리 실패: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLikeLoading = false;
        });
      }
    }
  }

  // 북마크 토글 수정
  Future<void> _toggleBookmark() async {
    // UserProvider를 사용하여 로그인 상태 확인
    final userProvider = Provider.of<UserProvider>(context, listen: false);

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

    if (_isBookmarkLoading) return;

    setState(() {
      _isBookmarkLoading = true;
    });

    try {
      // userProvider.index가 null이 아닌지 확인하고, 문자열로 변환하여 전달
      if (userProvider.index != null) {
        await PostService.toggleBookmark(
          _currentPost.id!,
          userProvider.index.toString(), // index를 문자열로 변환
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('북마크가 처리되었습니다'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        throw Exception('사용자 ID가 유효하지 않습니다');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('북마크 처리 실패: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isBookmarkLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // UserProvider 가져오기
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('게시글 상세'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // 게시글 내용 (스크롤 가능)
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 글쓴이 정보
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.green[100],
                        child: Text(
                          _currentPost.nickname.isNotEmpty
                              ? _currentPost.nickname[0].toUpperCase()
                              : 'U',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _currentPost.nickname,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            Text(
                              _formatDate(_currentPost.createdAt),
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
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
                            _currentPost.mountain,
                            style: TextStyle(
                              color: Colors.green[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // 제목 (있는 경우)
                  if (_currentPost.title != null &&
                      _currentPost.title!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        _currentPost.title!,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                  // 이미지 슬라이더 (있는 경우)
                  if (_currentPost.imagePaths.isNotEmpty)
                    Container(
                      height: 250,
                      margin: const EdgeInsets.only(bottom: 20),
                      child: PageView.builder(
                        itemCount: _currentPost.imagePaths.length,
                        itemBuilder: (context, index) {
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.image,
                                    size: 60,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '사진 ${index + 1}/${_currentPost.imagePaths.length}',
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                  // 본문
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _currentPost.content,
                      style: const TextStyle(fontSize: 16, height: 1.6),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 아이콘 영역
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        InkWell(
                          onTap: _toggleLike,
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
                                Text('${_currentPost.likeCount}'),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.comment, color: Colors.blue),
                            const SizedBox(width: 4),
                            Text('${_currentPost.commentCount}'),
                          ],
                        ),
                        const SizedBox(width: 20),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.visibility, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text('${_currentPost.viewCount}'),
                          ],
                        ),
                        const Spacer(),
                        InkWell(
                          onTap: _toggleBookmark,
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

                  // 🆕 댓글 섹션 제목
                  Padding(
                    padding: const EdgeInsets.only(top: 24, bottom: 12),
                    child: Row(
                      children: [
                        const Icon(Icons.comment, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          '댓글 ${_comments.length}개',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 🆕 댓글 목록
                  if (_isLoadingComments)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: CircularProgressIndicator(),
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
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _comments.length,
                      separatorBuilder: (context, index) => const Divider(),
                      itemBuilder: (context, index) {
                        final comment = _comments[index];
                        return CommentItem(
                          comment: comment,
                          onDelete: () => _deleteComment(comment),
                        );
                      },
                    ),
                ],
              ),
            ),
          ),

          // 🆕 댓글 입력 영역
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText:
                          userProvider.isLoggedIn
                              ? '댓글을 입력하세요...'
                              : '로그인 후 댓글을 작성할 수 있습니다',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      enabled: userProvider.isLoggedIn,
                    ),
                    maxLines: 1,
                    maxLength: 200,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _postComment(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _isPostingComment ? null : _postComment,
                  icon:
                      _isPostingComment
                          ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : const Icon(Icons.send, color: Colors.green),
                  tooltip: '댓글 작성',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// 🆕 댓글 아이템 위젯
class CommentItem extends StatelessWidget {
  final Comment comment;
  final VoidCallback onDelete;

  const CommentItem({super.key, required this.comment, required this.onDelete});

  // 날짜 포맷팅 함수
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}시간 전';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}분 전';
    } else {
      return '방금 전';
    }
  }

  @override
  Widget build(BuildContext context) {
    // UserProvider 가져오기
    final userProvider = Provider.of<UserProvider>(context);
    final isMyComment =
        userProvider.index.toString() == comment.userId; // index를 문자열로 변환

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 프로필 아바타
          CircleAvatar(
            radius: 16,
            backgroundColor: Colors.green[50],
            child: Text(
              comment.nickname.isNotEmpty
                  ? comment.nickname[0].toUpperCase()
                  : 'U',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green[700],
                fontSize: 14,
              ),
            ),
          ),

          const SizedBox(width: 12),

          // 댓글 내용
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      comment.nickname,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatDate(comment.createdAt),
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(comment.content, style: const TextStyle(fontSize: 14)),
              ],
            ),
          ),

          // 삭제 버튼 (내 댓글인 경우만)
          if (isMyComment)
            IconButton(
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline, size: 18),
              color: Colors.grey[600],
              tooltip: '댓글 삭제',
              constraints: const BoxConstraints(),
              padding: const EdgeInsets.all(8),
              visualDensity: VisualDensity.compact,
            ),
        ],
      ),
    );
  }
}
