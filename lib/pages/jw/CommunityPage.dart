import 'package:flutter/material.dart'; // Flutter UI 구성 요소를 위한 핵심 패키지
import 'package:provider/provider.dart'; // 상태 관리를 위한 Provider 패키지
import 'package:trekkit_flutter/functions/jh/userprovider.dart'; // 사용자 로그인 상태 등을 관리하는 UserProvider 임포트
import 'package:trekkit_flutter/services/jw/PostService.dart'; // 게시글 관련 API 호출을 위한 PostService 임포트
import 'package:trekkit_flutter/models/jw/Post.dart'; // 게시글 데이터 모델인 Post 임포트
import 'package:trekkit_flutter/pages/jh/Login_and_Signup/login.dart'; // 로그인 페이지 임포트
import 'package:trekkit_flutter/pages/jw/PostWriting.dart'; // 게시글 작성 페이지 임포트
import 'package:trekkit_flutter/pages/jw/ViewDetail.dart'; // 게시글 상세 보기 페이지 임포트
import 'package:trekkit_flutter/pages/jw/QnAPage.dart'; // Q&A 페이지 임포트
import 'package:trekkit_flutter/services/jw/AuthService.dart'; // 인증 관련 서비스를 위한 AuthService 임포트

/// 커뮤니티 페이지를 담당하는 StatefulWidget입니다.
/// '실시간' 게시글과 'Q&A' 게시글 탭을 포함하며,
/// 로그인 상태에 따라 글쓰기 버튼의 동작을 제어합니다.
class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

/// CommunityPage의 상태를 관리하는 State 클래스입니다.
/// TabController를 사용하여 탭 전환을 관리하고,
/// 앱 시작 시 로그인 상태를 확인하며, 탭 변경 시 UI를 업데이트합니다.
class _CommunityPageState extends State<CommunityPage>
    with SingleTickerProviderStateMixin {
  // 탭 전환을 제어하는 컨트롤러
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // 2개의 탭(실시간, Q&A)을 위한 TabController 초기화
    _tabController = TabController(length: 2, vsync: this);
    // 앱 시작 시 AuthService를 통해 사용자 로그인 상태를 확인하고 Provider에 반영
    AuthService().checkLoginStatus(context);

    // 탭 변경을 감지하여 UI를 다시 그리도록 리스너 추가
    _tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    // 위젯이 dispose될 때 TabController도 함께 dispose하여 리소스 누수 방지
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 화면 너비를 가져와 반응형 UI에 활용
    final screenWidth = MediaQuery.of(context).size.width;
    // Provider를 통해 UserProvider 인스턴스에 접근
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('커뮤니티'), // 앱 바 제목
        backgroundColor: Colors.green, // 앱 바 배경색
        foregroundColor: Colors.white, // 앱 바 전경색 (아이콘, 텍스트 색상)
        actions: [
          // 사용자가 로그인 상태일 경우 프로필 아이콘 표시
          if (userProvider.isLoggedIn)
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: Center(child: Icon(Icons.person)),
            ),
        ],
        // 탭 바 설정
        bottom: TabBar(
          controller: _tabController, // TabController 연결
          tabs: const [
            Tab(text: '실시간'), // 첫 번째 탭
            Tab(text: 'Q&A'), // 두 번째 탭
          ],
          labelColor: Colors.white, // 선택된 탭의 텍스트 색상
          unselectedLabelColor: Colors.white70, // 선택되지 않은 탭의 텍스트 색상
          indicatorColor: Colors.white, // 탭 표시기 색상
          indicatorWeight: 3, // 탭 표시기 두께
        ),
      ),
      body: TabBarView(
        controller: _tabController, // TabController 연결
        children: [
          // '실시간' 탭 내용: 게시글 필터와 게시글 목록
          Padding(
            padding: EdgeInsets.all(screenWidth * 0.04), // 화면 너비에 비례하는 패딩
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const PostFilter(), // 게시글 필터 위젯
                const SizedBox(height: 16), // 간격
                Expanded(
                  child: PostList(context: context), // 게시글 목록 위젯에 context 전달
                ),
              ],
            ),
          ),
          // 'Q&A' 탭 내용: QnAPage 위젯
          const QnAPage(),
        ],
      ),
      // 탭에 따라 다르게 동작하는 FloatingActionButton
      floatingActionButton:
          _tabController.index ==
                  0 // 현재 선택된 탭이 '실시간' 탭(인덱스 0)일 경우
              ? FloatingActionButton(
                onPressed: () async {
                  // UserProvider를 통해 로그인 상태를 확인 (listen: false로 불필요한 리빌드 방지)
                  final userProvider = Provider.of<UserProvider>(
                    context,
                    listen: false,
                  );

                  if (!userProvider.isLoggedIn) {
                    // 비로그인 상태일 경우 로그인 페이지로 이동
                    final result = await Navigator.push<bool>(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginPage(),
                      ),
                    );
                    // 로그인 성공 후 돌아왔을 경우 UI 새로고침
                    if (result == true) {
                      setState(() {});
                    }
                    return; // 로그인 페이지로 이동했으면 여기서 함수 종료
                  }

                  // 로그인 상태일 경우 게시글 작성 페이지로 이동
                  final result = await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PostWriting(),
                    ),
                  );
                  // 게시글 작성 후 돌아왔을 경우 UI 새로고침
                  if (result == true) {
                    setState(() {});
                  }
                },
                backgroundColor: Colors.lightGreenAccent, // 버튼 배경색
                child: const Icon(
                  Icons.add,
                  size: 30,
                  color: Colors.black,
                ), // 버튼 아이콘
              )
              : null, // 'Q&A' 탭에서는 FloatingActionButton을 숨김
    );
  }
}

/// 게시글 정렬 및 산 필터링을 위한 StatefulWidget입니다.
class PostFilter extends StatefulWidget {
  const PostFilter({super.key});

  @override
  State<PostFilter> createState() => _PostFilterState();
}

/// PostFilter의 상태를 관리하는 State 클래스입니다.
/// 선택된 정렬 옵션과 산을 관리하고, 변경 시 PostList에 필터 변경을 알립니다.
class _PostFilterState extends State<PostFilter> {
  String _sortOption = '최신순'; // 현재 선택된 정렬 옵션 (기본값: 최신순)
  String? _selectedMountain; // 현재 선택된 산 (기본값: null, 전체)

  // 드롭다운에 표시될 산 목록
  final List<String> _mountainOptions = const [
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

  // 드롭다운에 표시될 정렬 옵션 목록
  final List<String> sortOptions = const ['최신순', '인기순'];

  /// 산 선택 드롭다운 값이 변경될 때 호출됩니다.
  void _selectMountain(String? mountain) {
    setState(() {
      _selectedMountain = mountain;
    });
    _notifyFilterChange(); // 필터 변경 사항을 PostList에 알림
  }

  /// 정렬 옵션 드롭다운 값이 변경될 때 호출됩니다.
  void _changeSortOption(String? option) {
    if (option != null) {
      setState(() {
        _sortOption = option;
      });
      _notifyFilterChange(); // 필터 변경 사항을 PostList에 알림
    }
  }

  /// 현재 필터 설정을 PostListState 인스턴스에 전달하여 게시글 목록을 새로 로드하도록 지시합니다.
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
            // 정렬 옵션 드롭다운
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
                value: _sortOption, // 현재 선택된 값
                items:
                    sortOptions.map((option) {
                      return DropdownMenuItem<String>(
                        value: option,
                        child: Text(option),
                      );
                    }).toList(),
                onChanged: _changeSortOption, // 값 변경 시 호출될 콜백
              ),
            ),
            const SizedBox(width: 16), // 간격
            // 산 선택 드롭다운
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
                value: _selectedMountain, // 현재 선택된 값
                items: [
                  const DropdownMenuItem<String>(
                    value: null,
                    child: Text('전체'), // '전체' 옵션
                  ),
                  ..._mountainOptions.map((mountain) {
                    return DropdownMenuItem<String>(
                      value: mountain,
                      child: Text(mountain),
                    );
                  }),
                ],
                onChanged: _selectMountain, // 값 변경 시 호출될 콜백
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 게시글 목록을 표시하고 관리하는 StatefulWidget입니다.
/// 필터링, 페이지네이션(스크롤 시 추가 로드), 새로고침 기능을 제공합니다.
class PostList extends StatefulWidget {
  final BuildContext context; // PostService 호출 시 필요한 context를 받음

  const PostList({super.key, required this.context});

  @override
  State<PostList> createState() => PostListState();
}

/// PostList의 상태를 관리하는 State 클래스입니다.
/// 게시글 데이터를 비동기로 로드하고, 로딩/에러 상태를 관리하며,
/// 필터 변경 및 스크롤에 따른 추가 로드 기능을 구현합니다.
class PostListState extends State<PostList> {
  // PostFilter에서 접근할 수 있도록 static instance를 제공
  static PostListState? instance;

  List<Post> _posts = []; // 현재 표시될 게시글 목록
  bool _isLoading = false; // 데이터 로딩 중인지 여부
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
    instance = this; // static instance 초기화
    _loadPosts(); // 초기 게시글 로드
    _scrollController.addListener(_onScroll); // 스크롤 리스너 추가
  }

  @override
  void dispose() {
    instance = null; // 위젯 dispose 시 static instance 해제
    _scrollController.dispose(); // 스크롤 컨트롤러 dispose
    super.dispose();
  }

  /// 스크롤 위치가 끝에 도달했는지 확인하고, 끝에 도달하면 추가 게시글을 로드합니다.
  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _loadMorePosts();
    }
  }

  /// 필터 옵션이 변경될 때 호출되어 게시글 목록을 초기화하고 다시 로드합니다.
  void applyFilter(String sort, String? mountain) {
    setState(() {
      _currentSort = sort;
      _currentMountain = mountain;
      _currentPage = 0; // 페이지 초기화
      _posts.clear(); // 기존 게시글 목록 비움
    });
    _loadPosts(); // 새로운 필터로 게시글 로드
  }

  /// 백엔드에서 게시글 데이터를 비동기로 로드합니다.
  Future<void> _loadPosts() async {
    if (_isLoading) return; // 이미 로딩 중이면 중복 호출 방지
    setState(() {
      _isLoading = true; // 로딩 상태 시작
      _hasError = false; // 에러 상태 초기화
    });

    try {
      final result = await PostService.getPosts(
        sort: _currentSort,
        mountain: _currentMountain,
        page: _currentPage,
        size: 10, // 한 페이지당 10개 게시글 로드
        context: widget.context, // PostService에 context 전달
      );

      setState(() {
        if (_currentPage == 0) {
          _posts = result['posts']; // 첫 페이지 로드 시 기존 목록 대체
        } else {
          _posts.addAll(result['posts']); // 다음 페이지 로드 시 기존 목록에 추가
        }
        _totalCount = result['totalCount']; // 전체 게시글 수 업데이트
        _isLoading = false; // 로딩 상태 종료
      });
    } catch (e) {
      // 오류 발생 시
      setState(() {
        _isLoading = false; // 로딩 상태 종료
        _hasError = true; // 에러 상태 설정
        _errorMessage = e.toString(); // 에러 메시지 저장
      });
    }
  }

  /// 다음 페이지의 게시글을 로드합니다. (무한 스크롤)
  Future<void> _loadMorePosts() async {
    // 현재 로드된 게시글 수가 전체 게시글 수보다 많거나 같으면 더 이상 로드하지 않음
    if (_posts.length >= _totalCount) return;
    _currentPage++; // 다음 페이지로 증가
    await _loadPosts(); // 게시글 로드 함수 호출
  }

  /// 게시글 목록을 새로고침합니다. (Pull-to-refresh)
  Future<void> _refresh() async {
    setState(() {
      _currentPage = 0; // 페이지 초기화
      _posts.clear(); // 게시글 목록 비움
    });
    await _loadPosts(); // 게시글 로드 함수 호출
  }

  @override
  Widget build(BuildContext context) {
    // 에러 발생 시 UI
    if (_hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text('오류 발생: $_errorMessage'), // 에러 메시지 표시
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _refresh,
              child: const Text('다시 시도'),
            ), // 다시 시도 버튼
          ],
        ),
      );
    }

    // 게시글이 비어있고 로딩 중일 때 로딩 인디케이터 표시
    if (_posts.isEmpty && _isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // 게시글이 비어있을 때 (로딩 완료 후) 메시지 표시
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

    // 게시글 목록 표시 (Pull-to-refresh 기능 포함)
    return RefreshIndicator(
      onRefresh: _refresh, // 새로고침 시 _refresh 함수 호출
      child: ListView.builder(
        controller: _scrollController, // 스크롤 컨트롤러 연결
        itemCount:
            _posts.length +
            (_isLoading ? 1 : 0), // 로딩 중이면 로딩 인디케이터를 위해 아이템 개수 1 증가
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
          // 각 게시글 아이템을 PostItem 위젯으로 표시
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: PostItem(
              post: _posts[index], // Post 데이터 전달
              onUpdate: () => setState(() {}), // 게시글 업데이트 시 PostList 재빌드를 위한 콜백
            ),
          );
        },
      ),
    );
  }
}

/// 개별 게시글 항목을 표시하는 StatefulWidget입니다.
/// 좋아요 및 북마크 토글 기능을 포함하며, 게시글 클릭 시 상세 페이지로 이동합니다.
class PostItem extends StatefulWidget {
  final Post post; // 표시할 게시글 데이터
  final VoidCallback? onUpdate; // 게시글 업데이트 시 호출될 콜백

  const PostItem({super.key, required this.post, this.onUpdate});

  @override
  State<PostItem> createState() => _PostItemState();
}

/// PostItem의 상태를 관리하는 State 클래스입니다.
/// 좋아요 및 북마크 로딩 상태를 관리하고, 관련 서비스 호출을 담당합니다.
class _PostItemState extends State<PostItem> {
  bool _isLikeLoading = false; // 좋아요 처리 중인지 여부
  bool _isBookmarkLoading = false; // 북마크 처리 중인지 여부

  /// 좋아요 버튼 토글 로직을 처리합니다.
  /// 로그인 상태 확인 후, 좋아요 API를 호출하고 UI를 업데이트합니다.
  Future<void> _toggleLike() async {
    // UserProvider를 통해 로그인 상태 확인 (listen: false로 불필요한 리빌드 방지)
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (!userProvider.isLoggedIn) {
      // 비로그인 상태면 스낵바 메시지 표시
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('로그인이 필요합니다')));
      return;
    }

    if (_isLikeLoading) return; // 이미 좋아요 처리 중이면 중복 호출 방지
    setState(() => _isLikeLoading = true); // 좋아요 로딩 상태 시작

    try {
      // PostService를 통해 좋아요/취소 API 호출
      await PostService.toggleLike(widget.post.id!, context);
      widget.onUpdate?.call(); // 게시글 목록 새로고침을 위한 콜백 호출
    } catch (e) {
      if (mounted) {
        // 위젯이 마운트된 상태에서만 스낵바 표시
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('좋아요 처리 실패: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLikeLoading = false); // 로딩 상태 종료
    }
  }

  /// 북마크 버튼 토글 로직을 처리합니다.
  /// 로그인 상태 확인 후, 북마크 API를 호출하고 UI를 업데이트합니다.
  Future<void> _toggleBookmark() async {
    // UserProvider를 통해 로그인 상태 확인 (listen: false로 불필요한 리빌드 방지)
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (!userProvider.isLoggedIn) {
      // 비로그인 상태면 스낵바 메시지 표시
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('로그인이 필요합니다')));
      return;
    }

    if (_isBookmarkLoading) return; // 이미 북마크 처리 중이면 중복 호출 방지
    setState(() => _isBookmarkLoading = true); // 북마크 로딩 상태 시작

    try {
      // PostService를 통해 북마크/취소 API 호출
      await PostService.toggleBookmark(widget.post.id!, context);
      widget.onUpdate?.call(); // 게시글 목록 새로고침을 위한 콜백 호출
    } catch (e) {
      if (mounted) {
        // 위젯이 마운트된 상태에서만 스낵바 표시
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
      // 카드 전체를 탭 가능하게 하여 상세 페이지로 이동
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => ViewDetail(
                    post: widget.post,
                  ), // Post 데이터를 ViewDetail 페이지로 전달
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0), // 내부 패딩
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, // 내용을 왼쪽 정렬
            children: [
              // 프로필 정보 (아바타, 닉네임, 작성일, 산 태그)
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.green[100],
                    child: Text(
                      widget.post.nickname.isNotEmpty
                          ? widget.post.nickname[0]
                              .toUpperCase() // 닉네임의 첫 글자를 대문자로
                          : 'U', // 닉네임이 없으면 'U' 표시
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12), // 간격
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
                  // 산 태그 표시
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
              const SizedBox(height: 12), // 간격
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
                maxLines: 3, // 최대 3줄까지만 표시
                overflow: TextOverflow.ellipsis, // 3줄 초과 시 ...으로 표시
                style: const TextStyle(fontSize: 14, height: 1.4),
              ),
              // 이미지 (실제 이미지 대신 플레이스홀더 표시)
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
                          Text(
                            '이미지 1장',
                            style: TextStyle(color: Colors.grey),
                          ), // TODO: 실제 이미지 수에 따라 동적으로 변경 필요
                        ],
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 12), // 간격
              // 아이콘 영역 (좋아요, 댓글, 조회수, 북마크)
              Row(
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
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ), // 로딩 중일 때 인디케이터
                              )
                              : const Icon(
                                Icons.favorite_border,
                                size: 20,
                              ), // 좋아요 아이콘
                          const SizedBox(width: 4),
                          Text('${widget.post.likeCount}'), // 좋아요 수
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16), // 간격
                  // 댓글 아이콘 및 수
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.comment_outlined, size: 20), // 댓글 아이콘
                      const SizedBox(width: 4),
                      Text('${widget.post.commentCount}'), // 댓글 수
                    ],
                  ),
                  const SizedBox(width: 16), // 간격
                  // 조회수 아이콘 및 수
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.visibility_outlined,
                        size: 20,
                      ), // 조회수 아이콘
                      const SizedBox(width: 4),
                      Text('${widget.post.viewCount}'), // 조회수
                    ],
                  ),
                  const Spacer(), // 남은 공간 채우기
                  // 북마크 버튼
                  InkWell(
                    onTap: _toggleBookmark, // 북마크 토글 함수 호출
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
                                ), // 로딩 중일 때 인디케이터
                              )
                              : const Icon(
                                Icons.bookmark_border,
                                size: 20,
                              ), // 북마크 아이콘
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
