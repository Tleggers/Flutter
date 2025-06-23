import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trekkit_flutter/functions/jh/userprovider.dart'; // UserProvider 임포트
import 'package:trekkit_flutter/services/jw/PostService.dart';
import 'package:trekkit_flutter/models/jw/Post.dart'; // Post 모델 임포트
import 'package:trekkit_flutter/pages/jh/Login_and_Signup/login.dart';
import 'package:trekkit_flutter/pages/jw/PostWriting.dart';
import 'package:trekkit_flutter/pages/jw/ViewDetail.dart';
import 'package:trekkit_flutter/pages/jw/QnAPage.dart';
import 'package:trekkit_flutter/services/jw/AuthService.dart'; // AuthService 임포트

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // 앱 시작 시 로그인 상태 확인
    AuthService().checkLoginStatus(context);

    // 탭 변경 감지를 위한 리스너 추가
    _tabController.addListener(() {
      setState(() {}); // 탭이 변경될 때마다 UI 업데이트
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final userProvider = Provider.of<UserProvider>(
      context,
    ); // UserProvider 인스턴스 가져오기

    return Scaffold(
      appBar: AppBar(
        title: const Text('커뮤니티'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          if (userProvider.isLoggedIn) // UserProvider를 통해 로그인 상태 확인
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: Center(child: Icon(Icons.person)),
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [Tab(text: '실시간'), Tab(text: 'Q&A')],
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // 실시간 탭 - 기존 커뮤니티 글 표시
          Padding(
            padding: EdgeInsets.all(screenWidth * 0.04),
            child: Column(
              // const 제거, PostList에 context 전달 위해 Column 위젯 사용
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const PostFilter(),
                const SizedBox(height: 16),
                Expanded(
                  child: PostList(context: context), // PostList에 context 전달
                ),
              ],
            ),
          ),
          // Q&A 탭 - 기존 QnAPage 그대로 사용
          const QnAPage(),
        ],
      ),
      // 탭에 따라 다른 동작을 하는 FloatingActionButton
      floatingActionButton:
          _tabController.index == 0
              ? FloatingActionButton(
                onPressed: () async {
                  final userProvider = Provider.of<UserProvider>(
                    context,
                    listen: false,
                  );

                  if (!userProvider.isLoggedIn) {
                    // UserProvider를 통해 로그인 상태 확인
                    // 비로그인 상태: 로그인 페이지로 이동
                    final result = await Navigator.push<bool>(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginPage(),
                      ),
                    );
                    if (result == true) {
                      setState(() {}); // 로그인 후 새로고침
                    }
                    return;
                  }

                  // 실시간 탭에서만 PostWriting으로 이동
                  final result = await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PostWriting(),
                    ),
                  );
                  if (result == true) {
                    setState(() {}); // 새로고침
                  }
                },
                backgroundColor: Colors.lightGreenAccent,
                child: const Icon(Icons.add, size: 30, color: Colors.black),
              )
              : null, // Q&A 탭에서는 FloatingActionButton을 숨김
    );
  }
}

// 나머지 클래스들은 기존과 동일...
class PostFilter extends StatefulWidget {
  const PostFilter({super.key});

  @override
  State<PostFilter> createState() => _PostFilterState();
}

class _PostFilterState extends State<PostFilter> {
  String _sortOption = '최신순';
  String? _selectedMountain;

  final List<String> _mountainOptions = [
    '한라산',
    '지리산',
    '설악산',
    '북한산',
    '내장산',
    '가리산',
    '가리왕산',
    '가야산',
    '가지산',
    '감악산',
  ];

  final List<String> sortOptions = ['최신순', '인기순'];

  void _selectMountain(String? mountain) {
    setState(() {
      _selectedMountain = mountain;
    });
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
    PostListState.instance?.applyFilter(_sortOption, _selectedMountain);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: '정렬',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
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
            ),
            const SizedBox(width: 16),
            Expanded(
              child: DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: '산 선택',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                value: _selectedMountain,
                items: [
                  const DropdownMenuItem<String>(
                    value: null,
                    child: Text('전체'),
                  ),
                  ..._mountainOptions.map((mountain) {
                    return DropdownMenuItem<String>(
                      value: mountain,
                      child: Text(mountain),
                    );
                  }),
                ],
                onChanged: _selectMountain,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// PostList에 context를 추가 (기존 PostList 코드에 context 파라미터 추가)
class PostList extends StatefulWidget {
  final BuildContext context; // context를 필수로 받도록 추가
  const PostList({super.key, required this.context}); // 생성자에 context 추가

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

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _loadMorePosts();
    }
  }

  void applyFilter(String sort, String? mountain) {
    setState(() {
      _currentSort = sort;
      _currentMountain = mountain;
      _currentPage = 0;
      _posts.clear();
    });
    _loadPosts();
  }

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
        context: widget.context, // PostService.getPosts에 context 전달
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

  Future<void> _loadMorePosts() async {
    if (_posts.length >= _totalCount) return;
    _currentPage++;
    await _loadPosts(); // _loadPosts가 context를 사용하므로 이대로 두면 됨
  }

  Future<void> _refresh() async {
    setState(() {
      _currentPage = 0;
      _posts.clear();
    });
    await _loadPosts(); // _loadPosts가 context를 사용하므로 이대로 두면 됨
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text('오류 발생: $_errorMessage'),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _refresh, child: const Text('다시 시도')),
          ],
        ),
      );
    }

    if (_posts.isEmpty && _isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_posts.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.hiking, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('아직 게시글이 없습니다', style: TextStyle(fontSize: 16)),
            SizedBox(height: 8),
            Text('첫 번째 등산 후기를 공유해보세요!', style: TextStyle(color: Colors.grey)),
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
            padding: const EdgeInsets.only(bottom: 12),
            child: PostItem(
              post: _posts[index],
              onUpdate: () => setState(() {}),
              // PostItem 내에서 PostService 호출 시 context가 필요하다면
              // 여기에 context를 전달하거나, PostItem 내부에서 Provider.of를 통해 직접 접근해야 함.
              // 현재 PostItem에서는 context를 직접 사용하므로 별도 전달 불필요.
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

  Future<void> _toggleLike() async {
    // AuthService().isLoggedIn 대신 UserProvider를 직접 사용합니다.
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (!userProvider.isLoggedIn) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('로그인이 필요합니다')));
      return;
    }

    if (_isLikeLoading) return;
    setState(() => _isLikeLoading = true);

    try {
      // PostService.toggleLike에 context 전달
      await PostService.toggleLike(widget.post.id!, context);
      widget.onUpdate?.call();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('좋아요 처리 실패: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLikeLoading = false);
    }
  }

  Future<void> _toggleBookmark() async {
    // AuthService().isLoggedIn 대신 UserProvider를 직접 사용합니다.
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (!userProvider.isLoggedIn) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('로그인이 필요합니다')));
      return;
    }

    if (_isBookmarkLoading) return;
    setState(() => _isBookmarkLoading = true);

    try {
      // PostService.toggleBookmark에 context 전달
      await PostService.toggleBookmark(widget.post.id!, context);
      widget.onUpdate?.call();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('북마크 처리 실패: $e')));
      }
    } finally {
      if (mounted) setState(() => _isBookmarkLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ViewDetail(post: widget.post),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 프로필 정보
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.green[100],
                    child: Text(
                      widget.post.nickname.isNotEmpty
                          ? widget.post.nickname[0].toUpperCase()
                          : 'U',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.post.nickname,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
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
                  ),
                  if (widget.post.mountain.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        widget.post.mountain,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              // 제목
              if (widget.post.title != null && widget.post.title!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    widget.post.title!,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              // 본문
              Text(
                widget.post.content,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 14, height: 1.4),
              ),
              // 이미지
              if (widget.post.imagePaths.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.image, size: 40, color: Colors.grey),
                          SizedBox(height: 8),
                          Text('이미지 1장', style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 12),
              // 아이콘 영역
              Row(
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
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                              : const Icon(Icons.favorite_border, size: 20),
                          const SizedBox(width: 4),
                          Text('${widget.post.likeCount}'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.comment_outlined, size: 20),
                      const SizedBox(width: 4),
                      Text('${widget.post.commentCount}'),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.visibility_outlined, size: 20),
                      const SizedBox(width: 4),
                      Text('${widget.post.viewCount}'),
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
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                              : const Icon(Icons.bookmark_border, size: 20),
                    ),
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
