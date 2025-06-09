import 'package:flutter/material.dart';
import 'package:trekkit_flutter/pages/jw/PostWriting.dart';
import 'ViewDetail.dart';
import 'package:trekkit_flutter/models/jw/Post.dart';
import 'package:trekkit_flutter/models/jw/PostService.dart';

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => CommunityPageState();
}

class CommunityPageState extends State<CommunityPage> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(title: const Text('커뮤니티')),
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.all(screenWidth * 0.1),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [PostFilter(), Expanded(child: PostList())],
            ),
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: GestureDetector(
              onTap: () async {
                final result = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(builder: (context) => const PostWriting()),
                );

                // 글 작성 후 새로고침
                if (result == true) {
                  setState(() {});
                }
              },
              child: Container(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(
                  color: Colors.lightGreenAccent,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(Icons.add, size: 30, color: Colors.black),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PostFilter extends StatefulWidget {
  const PostFilter({super.key});

  @override
  State<PostFilter> createState() => _PostFilterState();
}

class _PostFilterState extends State<PostFilter> {
  String _sortOption = '최신순';
  String? _selectedMountain;
  List<String> _mountainOptions = [];

  final List<String> sortOptions = ['최신순', '인기순'];

  @override
  void initState() {
    super.initState();
    _loadMountains();
  }

  // 산 목록 로드
  Future<void> _loadMountains() async {
    try {
      final mountains = await PostService.getMountains();
      setState(() {
        _mountainOptions = mountains;
      });
    } catch (e) {
      print('산 목록 로드 실패: $e');
    }
  }

  void _selectMountain(String? mountain) {
    setState(() {
      _selectedMountain = mountain;
    });
    // 필터 변경 시 PostList에 알림
    _notifyFilterChange();
  }

  void _changeSortOption(String? option) {
    if (option != null) {
      setState(() {
        _sortOption = option;
      });
      _notifyFilterChange();
    }
  }

  void _notifyFilterChange() {
    // PostList에 필터 변경 알림
    PostListState.instance?.applyFilter(_sortOption, _selectedMountain);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          children: [
            DropdownButton<String>(
              value: _sortOption,
              items:
                  sortOptions.map((option) {
                    return DropdownMenuItem<String>(
                      value: option,
                      child: Text(option),
                    );
                  }).toList(),
              onChanged: _changeSortOption,
            ),
            DropdownButton<String>(
              hint: const Text('산 선택'),
              value: _selectedMountain,
              items: [
                const DropdownMenuItem<String>(value: null, child: Text('전체')),
                ..._mountainOptions.map((mountain) {
                  return DropdownMenuItem<String>(
                    value: mountain,
                    child: Text(mountain),
                  );
                }).toList(),
              ],
              onChanged: _selectMountain,
            ),
          ],
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}

class PostList extends StatefulWidget {
  const PostList({super.key});

  @override
  State<PostList> createState() => PostListState();
}

class PostListState extends State<PostList> {
  static PostListState? instance;

  List<Post> _posts = [];
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';

  String _currentSort = '최신순';
  String? _currentMountain;
  int _currentPage = 0;
  int _totalCount = 0;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    instance = this;
    _loadPosts();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    instance = null;
    _scrollController.dispose();
    super.dispose();
  }

  // 무한 스크롤 처리
  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _loadMorePosts();
    }
  }

  // 필터 적용
  void applyFilter(String sort, String? mountain) {
    setState(() {
      _currentSort = sort;
      _currentMountain = mountain;
      _currentPage = 0;
      _posts.clear();
    });
    _loadPosts();
  }

  // 게시글 로드
  Future<void> _loadPosts() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final result = await PostService.getPosts(
        sort: _currentSort,
        mountain: _currentMountain,
        page: _currentPage,
        size: 10,
      );

      setState(() {
        if (_currentPage == 0) {
          _posts = result['posts'];
        } else {
          _posts.addAll(result['posts']);
        }
        _totalCount = result['totalCount'];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = e.toString();
      });
    }
  }

  // 더 많은 게시글 로드 (무한 스크롤)
  Future<void> _loadMorePosts() async {
    if (_posts.length >= _totalCount) return;

    _currentPage++;
    await _loadPosts();
  }

  // 새로고침
  Future<void> _refresh() async {
    setState(() {
      _currentPage = 0;
      _posts.clear();
    });
    await _loadPosts();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('오류 발생: $_errorMessage'),
            ElevatedButton(onPressed: _refresh, child: const Text('다시 시도')),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView.builder(
        controller: _scrollController,
        itemCount: _posts.length + (_isLoading ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _posts.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: PostItem(
              post: _posts[index],
              onUpdate: () => setState(() {}), // 좋아요/북마크 업데이트 시 리빌드
            ),
          );
        },
      ),
    );
  }
}

class PostItem extends StatefulWidget {
  final Post post;
  final VoidCallback? onUpdate;

  const PostItem({super.key, required this.post, this.onUpdate});

  @override
  State<PostItem> createState() => _PostItemState();
}

class _PostItemState extends State<PostItem> {
  bool _isLikeLoading = false;
  bool _isBookmarkLoading = false;

  // 좋아요 토글
  Future<void> _toggleLike() async {
    if (_isLikeLoading) return;

    setState(() {
      _isLikeLoading = true;
    });

    try {
      final result = await PostService.toggleLike(
        widget.post.id!,
        'currentUserId', // 실제 사용자 ID로 변경
      );

      // 좋아요 상태 업데이트
      widget.post.copyWith(likeCount: result['likeCount']);
      widget.onUpdate?.call();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('좋아요 처리 실패: $e')));
    } finally {
      setState(() {
        _isLikeLoading = false;
      });
    }
  }

  // 북마크 토글
  Future<void> _toggleBookmark() async {
    if (_isBookmarkLoading) return;

    setState(() {
      _isBookmarkLoading = true;
    });

    try {
      await PostService.toggleBookmark(
        widget.post.id!,
        'currentUserId', // 실제 사용자 ID로 변경
      );

      widget.onUpdate?.call();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('북마크 처리 실패: $e')));
    } finally {
      setState(() {
        _isBookmarkLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ViewDetail(post: widget.post),
          ),
        );
      },
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 프로필 정보
              Row(
                children: [
                  const CircleAvatar(radius: 20, backgroundColor: Colors.grey),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.post.nickname,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${widget.post.createdAt.year}-${widget.post.createdAt.month.toString().padLeft(2, '0')}-${widget.post.createdAt.day.toString().padLeft(2, '0')}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  if (widget.post.mountain.isNotEmpty)
                    Chip(
                      label: Text(widget.post.mountain),
                      backgroundColor: Colors.green[100],
                    ),
                ],
              ),
              const SizedBox(height: 10),

              // 이미지 (있는 경우)
              if (widget.post.imagePaths.isNotEmpty)
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Icon(Icons.image, size: 50, color: Colors.grey),
                  ),
                ),

              const SizedBox(height: 10),

              // 본문 내용
              Text(
                widget.post.content,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 10),

              // 아이콘 영역
              Row(
                children: [
                  // 좋아요
                  IconButton(
                    onPressed: _isLikeLoading ? null : _toggleLike,
                    icon:
                        _isLikeLoading
                            ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                            : const Icon(Icons.favorite_border),
                  ),
                  Text('${widget.post.likeCount}'),

                  const SizedBox(width: 16),

                  // 댓글
                  const Icon(Icons.comment_outlined),
                  const SizedBox(width: 4),
                  Text('${widget.post.commentCount}'),

                  const SizedBox(width: 16),

                  // 조회수
                  const Icon(Icons.visibility_outlined),
                  const SizedBox(width: 4),
                  Text('${widget.post.viewCount}'),

                  const Spacer(),

                  // 북마크
                  IconButton(
                    onPressed: _isBookmarkLoading ? null : _toggleBookmark,
                    icon:
                        _isBookmarkLoading
                            ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                            : const Icon(Icons.bookmark_border),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
