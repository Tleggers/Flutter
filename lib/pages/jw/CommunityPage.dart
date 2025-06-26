import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trekkit_flutter/functions/jh/userprovider.dart';
import 'package:trekkit_flutter/models/jw/Post.dart';
import 'package:trekkit_flutter/pages/jh/Login_and_Signup/login.dart';
import 'package:trekkit_flutter/pages/jw/PostWriting.dart';
import 'package:trekkit_flutter/pages/jw/QnAPage.dart';
import 'package:trekkit_flutter/pages/jw/ViewDetail.dart';
import 'package:trekkit_flutter/services/jw/AuthService.dart';
import 'package:trekkit_flutter/services/jw/PostService.dart';

/// 커뮤니티 메인 페이지 위젯입니다.
/// '실시간' 탭과 'Q&A' 탭으로 구성됩니다.
class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

/// [CommunityPage]의 상태를 관리하는 State 클래스입니다.
/// [SingleTickerProviderStateMixin]을 사용하여 TabController의 애니메이션을 처리합니다.
class _CommunityPageState extends State<CommunityPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this); // 탭 컨트롤러 2개 탭으로 초기화
    AuthService().checkLoginStatus(context); // 앱 시작 시 로그인 상태 확인

    // 탭 변경을 감지하여 UI를 업데이트합니다 (FloatingActionButton 표시 여부 등).
    _tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose(); // 탭 컨트롤러 dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('커뮤니티'), // 앱 바 제목
        backgroundColor: Colors.green, // 앱 바 배경색
        foregroundColor: Colors.white, // 앱 바 전경색
        actions: [
          // 로그인 상태일 때만 프로필 아이콘을 표시합니다.
          if (userProvider.isLoggedIn)
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: Center(child: Icon(Icons.person)),
            ),
        ],
        // AppBar 하단에 탭 바를 추가합니다.
        bottom: TabBar(
          controller: _tabController,
          tabs: const [Tab(text: '실시간'), Tab(text: 'Q&A')], // 탭 목록
          labelColor: Colors.white, // 선택된 탭 라벨 색상
          unselectedLabelColor: Colors.white70, // 선택되지 않은 탭 라벨 색상
          indicatorColor: Colors.white, // 인디케이터 색상
          indicatorWeight: 3, // 인디케이터 두께
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // '실시간' 탭의 내용
          Padding(
            padding: EdgeInsets.all(screenWidth * 0.04),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const PostFilter(), // 게시글 필터 위젯
                const SizedBox(height: 16),
                Expanded(child: PostList(context: context)), // 게시글 목록 위젯
              ],
            ),
          ),
          // 'Q&A' 탭의 내용
          const QnAPage(), // Q&A 페이지 위젯
        ],
      ),
      // '실시간' 탭이 선택되었을 때만 글쓰기 FloatingActionButton을 표시합니다.
      floatingActionButton:
          _tabController.index == 0
              ? FloatingActionButton(
                onPressed: () async {
                  final userProvider = Provider.of<UserProvider>(
                    context,
                    listen: false,
                  );

                  // 비로그인 상태면 로그인 페이지로 이동시킵니다.
                  if (!userProvider.isLoggedIn) {
                    final result = await Navigator.push<bool>(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginPage(),
                      ),
                    );
                    // 로그인 성공 후 돌아왔을 때 UI를 갱신합니다.
                    if (result == true) {
                      setState(() {});
                    }
                    return;
                  }

                  // 로그인 상태면 글쓰기 페이지로 이동합니다.
                  final result = await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PostWriting(),
                    ),
                  );
                  // 글 작성 완료 후 돌아왔을 때 목록을 갱신하기 위해 setState를 호출할 수 있습니다.
                  if (result == true) {
                    setState(() {});
                  }
                },
                backgroundColor: Colors.lightGreenAccent,
                child: const Icon(Icons.add, size: 30, color: Colors.black),
              )
              : null, // 'Q&A' 탭에서는 버튼을 표시하지 않음
    );
  }
}

/// 게시글 필터링 UI를 제공하는 위젯입니다.
/// 정렬(최신순, 인기순)과 산 선택 필터를 모두 포함합니다.
class PostFilter extends StatefulWidget {
  const PostFilter({super.key});

  @override
  State<PostFilter> createState() => _PostFilterState();
}

/// PostFilter의 상태를 관리하는 State 클래스입니다.
/// 사용자가 선택한 정렬 옵션과 산 필터를 관리합니다.
class _PostFilterState extends State<PostFilter> {
  String _sortOption = '최신순'; // 현재 선택된 정렬 옵션 (기본값: 최신순)
  String? _selectedMountain; // 현재 선택된 산 (기본값: null)

  // 정렬 옵션 목록
  final List<String> _sortOptions = const ['최신순', '인기순'];

  // 산 선택 드롭다운 목록 (실제 앱에서는 서버나 파일에서 비동기적으로 불러오는 것이 좋습니다.)
  final List<String> _mountainOptions = const [
    '가공산',
    '가덕산',
    '가두봉',
    '가득봉',
    '가라산',
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
    '관악산',
  ];

  /// 산 선택 드롭다운의 값이 변경될 때 호출됩니다.
  void _selectMountain(String? mountain) {
    setState(() {
      _selectedMountain = mountain;
    });
    _notifyFilterChange(); // 필터 변경 사항을 PostList 위젯에 알림
  }

  /// 정렬 옵션 드롭다운의 값이 변경될 때 호출됩니다.
  void _selectSortOption(String? option) {
    if (option != null && option != _sortOption) {
      setState(() {
        _sortOption = option;
      });
      _notifyFilterChange(); // 필터 변경 사항을 PostList 위젯에 알림
    }
  }

  /// PostListState의 static instance에 접근하여 필터 변경을 알리고,
  /// 게시글 목록을 새로고침 하도록 요청합니다.
  /// [주의] 이 패턴은 위젯 간의 결합도를 높여 코드를 복잡하게 만들 수 있으므로,
  /// 앱의 규모가 커지면 Provider나 Riverpod 같은 전문 상태관리 라이브러리를
  /// 사용하여 상태를 공유하는 것이 더 안정적이고 권장되는 방법입니다.
  void _notifyFilterChange() {
    PostListState.instance?.applyFilter(_sortOption, _selectedMountain);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
        child: Row(
          children: [
            // 정렬 옵션 드롭다운
            Expanded(
              flex: 2, // 상대적 너비 비율 설정
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _sortOption,
                  icon: const Icon(Icons.sort, size: 20), // 정렬 아이콘
                  isExpanded: true,
                  items:
                      _sortOptions.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value, overflow: TextOverflow.ellipsis),
                        );
                      }).toList(),
                  onChanged: _selectSortOption,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(height: 24, width: 1, color: Colors.grey.shade300), // 구분선
            const SizedBox(width: 8),

            // 산 선택 드롭다운
            Expanded(
              flex: 3, // 상대적 너비 비율 설정
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedMountain,
                  hint: const Text('산 선택 (전체)'),
                  icon: const Icon(Icons.filter_hdr_rounded, size: 20), // 산 아이콘
                  isExpanded: true,
                  items:
                      ['전체', ..._mountainOptions].map((String value) {
                        return DropdownMenuItem<String>(
                          value:
                              value == '전체' ? null : value, // '전체' 선택 시 null 반환
                          child: Text(value, overflow: TextOverflow.ellipsis),
                        );
                      }).toList(),
                  onChanged: _selectMountain,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 게시글 목록을 표시하고 관리하는 위젯입니다.
class PostList extends StatefulWidget {
  final BuildContext context;

  const PostList({super.key, required this.context});

  @override
  State<PostList> createState() => PostListState();
}

/// [PostList]의 상태를 관리하며, 데이터 로딩, 무한 스크롤, 새로고침 로직을 처리합니다.
class PostListState extends State<PostList> {
  // PostFilter와 같은 다른 위젯에서 이 State의 메서드(applyFilter)를 호출할 수 있도록
  // static instance를 제공합니다.
  static PostListState? instance;

  List<Post> _posts = []; // 현재 표시될 게시글 목록
  bool _isLoading = false; // 데이터 로딩 중 여부
  bool _hasError = false; // 오류 발생 여부
  String _errorMessage = ''; // 발생한 오류 메시지
  String _currentSort = '최신순'; // 현재 적용된 정렬 기준
  String? _currentMountain; // 현재 적용된 산 필터
  int _currentPage = 0; // 현재 페이지 번호 (0부터 시작)
  int _totalCount = 0; // 전체 게시글 수
  final ScrollController _scrollController = ScrollController(); // 스크롤 감지 컨트롤러

  @override
  void initState() {
    super.initState();
    instance = this; // static instance 설정
    _loadPosts(); // 위젯이 생성될 때 첫 페이지 게시글 로드
    _scrollController.addListener(_onScroll); // 스크롤 이벤트 리스너 추가
  }

  @override
  void dispose() {
    instance = null; // 위젯이 제거될 때 static instance 정리
    _scrollController.dispose(); // 스크롤 컨트롤러 dispose
    super.dispose();
  }

  /// 스크롤이 맨 아래에 도달하면 다음 페이지의 게시글을 로드합니다.
  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _loadMorePosts();
    }
  }

  /// [PostFilter] 위젯에서 호출되어 필터링된 게시글 목록을 새로 불러옵니다.
  /// 정렬 및 산 필터를 업데이트하고, 목록을 초기화한 후 게시글을 다시 로드합니다.
  void applyFilter(String sort, String? mountain) {
    setState(() {
      _currentSort = sort;
      _currentMountain = mountain;
      _currentPage = 0;
      _posts.clear();
    });
    _loadPosts();
  }

  /// [PostService]를 통해 백엔드에서 게시글 데이터를 비동기적으로 가져옵니다.
  /// 로딩 상태, 에러 상태를 관리하고 결과를 [_posts]에 업데이트합니다.
  Future<void> _loadPosts() async {
    if (_isLoading) return; // 이미 로딩 중이면 중복 실행 방지

    // 로딩 시작 상태 업데이트
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    //게시글 리스트 가지고 오는 함수
    try {
      final result = await PostService.getPosts(
        sort: _currentSort,
        mountain: _currentMountain,
        page: _currentPage,
        size: 10,
        context: widget.context,
      );

      // 비동기 작업 후 위젯이 여전히 화면에 있는지(mounted) 확인 (매우 중요)
      if (mounted) {
        setState(() {
          final newPosts = result['posts'] as List<Post>;
          _totalCount = result['totalCount'] as int;

          if (_currentPage == 0) {
            _posts = newPosts; // 첫 페이지는 목록을 교체
          } else {
            _posts.addAll(newPosts); // 다음 페이지는 기존 목록에 추가
          }
        });
      }
    } catch (e) {
      // 에러 발생 시 위젯이 화면에 있는지 확인하고 에러 상태 업데이트
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = e.toString();
        });
      }
    } finally {
      // 작업 성공/실패와 관계없이 로딩 상태를 종료
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// 다음 페이지의 게시글을 로드합니다. (무한 스크롤 기능의 일부)
  /// 로드된 게시글 수가 전체 수보다 적을 때만 다음 페이지를 로드합니다.
  Future<void> _loadMorePosts() async {
    if (_posts.length >= _totalCount) return; // 이미 모든 게시글을 로드했으면 중단
    _currentPage++; // 페이지 번호 증가
    await _loadPosts(); // 게시글 로드 함수 호출
  }

  /// '아래로 당겨서 새로고침(Pull-to-refresh)' 시 호출됩니다.
  /// 현재 페이지를 0으로 초기화하고 게시글 목록을 비운 후 다시 로드합니다.
  Future<void> _refresh() async {
    setState(() {
      _currentPage = 0;
      _posts.clear();
    });
    await _loadPosts();
  }

  @override
  Widget build(BuildContext context) {
    // 에러 발생 시 UI
    if (_hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('게시글을 불러오는 데 실패했습니다.'),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Text(
                _errorMessage, // 서버에서 받은 실제 에러 메시지 표시
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),
            ElevatedButton(onPressed: _refresh, child: const Text('다시 시도')),
          ],
        ),
      );
    }

    // 게시글이 없거나 로딩 중일 때 UI
    if (_posts.isEmpty) {
      return _isLoading
          ? const Center(child: CircularProgressIndicator()) // 로딩 중이면 로딩 인디케이터
          : Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.hiking, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text('아직 게시글이 없습니다', style: TextStyle(fontSize: 16)),
                const SizedBox(height: 8),
                const Text(
                  '첫 번째 등산 후기를 공유해보세요!',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
    }

    // 게시글 목록을 스크롤 가능한 리스트로 표시 (Pull-to-refresh 기능 포함)
    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView.builder(
        controller: _scrollController,
        // 로딩 중일 때 마지막에 로딩 인디케이터를 표시하기 위해 아이템 개수 1 증가
        itemCount: _posts.length + (_isLoading && _posts.isNotEmpty ? 1 : 0),
        itemBuilder: (context, index) {
          // 마지막 아이템이면서 로딩 중일 때 로딩 인디케이터 표시
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
              // 좋아요/북마크 상태 변경 시 목록 UI를 즉시 갱신하기 위한 콜백
              onUpdate: () => setState(() {}),
            ),
          );
        },
      ),
    );
  }
}

/// 개별 게시글 UI를 구성하는 위젯입니다.
/// 작성자 정보, 제목, 내용 미리보기, 이미지, 좋아요/댓글/조회수/북마크 통계를 표시합니다.
class PostItem extends StatefulWidget {
  final Post post; // 표시할 게시글 데이터
  final VoidCallback? onUpdate; // 게시글 업데이트 시 호출될 콜백

  const PostItem({super.key, required this.post, this.onUpdate});

  @override
  State<PostItem> createState() => _PostItemState();
}

/// PostItem의 상태를 관리하며, 좋아요 및 북마크 토글 로직을 처리합니다.
class _PostItemState extends State<PostItem> {
  bool _isLikeLoading = false; // 좋아요 처리 중 여부
  bool _isBookmarkLoading = false; // 북마크 처리 중 여부

  /// 좋아요 버튼 클릭 시 호출됩니다.
  /// 로그인 상태 확인 후 좋아요 API를 호출하고 상위 위젯에 UI 갱신을 알립니다.
  Future<void> _toggleLike() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (!userProvider.isLoggedIn) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('로그인이 필요합니다')));
      return;
    }

    if (_isLikeLoading) return; // 이미 처리 중이면 중복 호출 방지
    setState(() => _isLikeLoading = true); // 로딩 상태 시작

    try {
      await PostService.toggleLike(widget.post.id!, context);
      widget.onUpdate?.call(); // PostList의 UI를 갱신하도록 콜백 호출
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('좋아요 처리 실패: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLikeLoading = false); // 로딩 상태 종료
    }
  }

  /// 북마크 버튼 클릭 시 호출됩니다.
  /// 로그인 상태 확인 후 북마크 API를 호출하고 상위 위젯에 UI 갱신을 알립니다.
  Future<void> _toggleBookmark() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (!userProvider.isLoggedIn) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('로그인이 필요합니다')));
      return;
    }

    if (_isBookmarkLoading) return; // 이미 처리 중이면 중복 호출 방지
    setState(() => _isBookmarkLoading = true); // 로딩 상태 시작

    try {
      await PostService.toggleBookmark(widget.post.id!, context);
      widget.onUpdate?.call(); // PostList의 UI를 갱신하도록 콜백 호출
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('북마크 처리 실패: $e')));
      }
    } finally {
      if (mounted) setState(() => _isBookmarkLoading = false); // 로딩 상태 종료
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2, // 카드 그림자 깊이
      child: InkWell(
        onTap: () {
          // 게시글 탭 시 상세 페이지로 이동
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ViewDetail(post: widget.post),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0), // 내부 패딩
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, // 내용을 왼쪽 정렬
            children: [
              // 상단 프로필 영역 (아바타, 닉네임, 작성일, 산 태그)
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.green[100],
                    child: Text(
                      widget.post.nickname.isNotEmpty
                          ? widget.post.nickname[0].toUpperCase()
                          : 'U', // 닉네임 첫 글자 또는 'U' 표시
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
                          widget.post.nickname, // 작성자 닉네임
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          // 작성일 포맷팅 (YYYY-MM-DD)
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
                        widget.post.mountain, // 산 태그
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
              // 제목과 내용 미리보기
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
              Text(
                widget.post.content,
                maxLines: 3, // 최대 3줄 표시
                overflow: TextOverflow.ellipsis, // 3줄 초과 시 ...으로 표시
                style: const TextStyle(fontSize: 14, height: 1.4),
              ),
              // 이미지 영역 (현재는 플레이스홀더, 실제 이미지 표시하려면 NetworkImage 활성화 필요)
              if (widget.post.imagePaths.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                      // 실제 이미지를 표시하려면 아래 코드를 활성화하고, child를 제거하세요.
                      // image: DecorationImage(
                      //   image: NetworkImage('http://10.0.2.2:30000${widget.post.imagePaths.first}'),
                      //   fit: BoxFit.cover,
                      // ),
                    ),
                    // 실제 이미지를 표시할 때는 아래 child를 제거하세요.
                    child: const Center(
                      child: Icon(Icons.image, size: 40, color: Colors.grey),
                    ),
                  ),
                ),
              const SizedBox(height: 12),
              // 하단 아이콘 영역 (좋아요, 댓글, 조회수, 북마크 통계)
              Row(
                children: [
                  // 좋아요 아이콘 및 통계
                  InkWell(
                    onTap: _toggleLike,
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          _isLikeLoading
                              ? const SizedBox(
                                width: 18,
                                height: 18,
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
                  // 댓글 아이콘 및 통계
                  Row(
                    children: [
                      const Icon(Icons.comment_outlined, size: 20),
                      const SizedBox(width: 4),
                      Text('${widget.post.commentCount}'),
                    ],
                  ),
                  const SizedBox(width: 16),
                  // 조회수 아이콘 및 통계
                  Row(
                    children: [
                      const Icon(Icons.visibility_outlined, size: 20),
                      const SizedBox(width: 4),
                      Text('${widget.post.viewCount}'),
                    ],
                  ),
                  const Spacer(),
                  // 북마크 아이콘
                  InkWell(
                    onTap: _toggleBookmark,
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child:
                          _isBookmarkLoading
                              ? const SizedBox(
                                width: 18,
                                height: 18,
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
