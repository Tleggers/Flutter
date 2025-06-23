import 'package:flutter/material.dart'; // Flutter UI 구성 요소를 위한 핵심 패키지
import 'package:provider/provider.dart'; // 상태 관리를 위한 Provider 패키지
import 'package:trekkit_flutter/functions/jh/userprovider.dart'; // 사용자 로그인 상태 및 정보 관리를 위한 UserProvider 임포트
import 'package:trekkit_flutter/services/jw/QnaService.dart'; // Q&A 관련 API 호출을 위한 QnaService 임포트
import 'package:trekkit_flutter/models/jw/QnaQuestion.dart'; // Q&A 질문 데이터 모델인 QnaQuestion 임포트
import 'package:trekkit_flutter/pages/jh/Login_and_Signup/login.dart'; // 로그인 페이지 임포트
import 'package:trekkit_flutter/pages/jw/QnADetail.dart'; // Q&A 상세 페이지 임포트
import 'package:trekkit_flutter/pages/jw/QnAWriting.dart'; // Q&A 작성 페이지 임포트

/// Q&A 목록 페이지를 담당하는 StatefulWidget입니다.
/// 질문 목록을 표시하고, 필터링, 검색, 무한 스크롤, 그리고 질문 작성 기능을 제공합니다.
class QnAPage extends StatefulWidget {
  const QnAPage({super.key});

  @override
  State<QnAPage> createState() => _QnAPageState();
}

/// QnAPage의 상태를 관리하는 State 클래스입니다.
/// 질문 목록을 비동기로 로드하고, 필터 변경, 스크롤에 따른 추가 로드, 새로고침 등을 처리합니다.
class _QnAPageState extends State<QnAPage> {
  List<QnaQuestion> _questions = []; // 현재 표시될 Q&A 질문 목록
  bool _isLoading = false; // 데이터 로딩 중인지 여부
  bool _hasError = false; // 오류 발생 여부
  String _errorMessage = ''; // 발생한 오류 메시지

  String _currentSort = 'latest'; // 현재 적용된 정렬 기준 (기본값: 최신순)
  String? _currentMountain; // 현재 적용된 산 필터 (기본값: null, 전체)
  int _currentPage = 0; // 현재 페이지 번호 (0부터 시작)
  int _totalCount = 0; // 전체 질문 수

  final ScrollController _scrollController = ScrollController(); // 스크롤 감지 컨트롤러

  @override
  void initState() {
    super.initState();
    _loadQuestions(); // 페이지 초기화 시 질문 로드
    _scrollController.addListener(_onScroll); // 스크롤 리스너 추가
  }

  @override
  void dispose() {
    _scrollController.dispose(); // 스크롤 컨트롤러 dispose하여 리소스 누수 방지
    super.dispose();
  }

  /// 스크롤 위치가 리스트의 끝에 도달했는지 확인하고, 끝에 도달하면 추가 질문을 로드합니다.
  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _loadMoreQuestions();
    }
  }

  /// 필터 옵션([sort], [mountain])이 변경될 때 호출되어
  /// 질문 목록을 초기화하고 새로운 필터로 질문을 다시 로드합니다.
  void _applyFilter(String sort, String? mountain) {
    setState(() {
      _currentSort = sort; // 정렬 기준 업데이트
      _currentMountain = mountain; // 산 필터 업데이트
      _currentPage = 0; // 페이지 초기화
      _questions.clear(); // 기존 질문 목록 비움
    });
    _loadQuestions(); // 새로운 필터로 질문 로드
  }

  /// 백엔드에서 Q&A 질문 데이터를 비동기로 로드합니다.
  /// 로딩 상태, 에러 상태를 관리하고 결과를 [_questions]에 업데이트합니다.
  Future<void> _loadQuestions() async {
    if (_isLoading) return; // 이미 로딩 중이면 중복 호출 방지

    setState(() {
      _isLoading = true; // 로딩 상태 시작
      _hasError = false; // 에러 상태 초기화
      _errorMessage = ''; // 에러 메시지 초기화
    });

    try {
      final result = await QnaService.getQuestions(
        sort: _currentSort, // 현재 정렬 기준 적용
        mountain: _currentMountain, // 현재 산 필터 적용
        page: _currentPage, // 현재 페이지 번호 적용
        size: 10, // 한 페이지당 10개 질문 로드
        context: context, // context 전달
      );

      setState(() {
        if (_currentPage == 0) {
          _questions = result['questions']; // 첫 페이지 로드 시 기존 목록 대체
        } else {
          _questions.addAll(result['questions']); // 다음 페이지 로드 시 기존 목록에 추가
        }
        _totalCount = result['totalCount']; // 전체 질문 수 업데이트
        _isLoading = false; // 로딩 상태 종료
      });
    } catch (e) {
      // 오류 발생 시 에러 상태 및 메시지 설정
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = e.toString();
      });
    }
  }

  /// 다음 페이지의 질문을 로드합니다. (무한 스크롤 기능의 일부)
  Future<void> _loadMoreQuestions() async {
    // 현재 로드된 질문 수가 전체 질문 수보다 많거나 같으면 더 이상 로드하지 않음
    if (_questions.length >= _totalCount) return;
    _currentPage++; // 다음 페이지로 증가
    await _loadQuestions(); // 질문 로드 함수 호출
  }

  /// 질문 목록을 새로고침합니다. (Pull-to-refresh)
  Future<void> _refresh() async {
    setState(() {
      _currentPage = 0; // 페이지 초기화
      _questions.clear(); // 질문 목록 비움
    });
    await _loadQuestions(); // 질문 로드 함수 호출
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Q&A 질문 필터링 위젯
          QnAFilter(onFilterChanged: _applyFilter),
          const SizedBox(height: 16), // 간격
          // 질문 목록을 표시하는 부분 (Expanded로 남은 공간 모두 사용)
          Expanded(child: _buildQuestionList()),
        ],
      ),
      // 질문 작성 FloatingActionButton
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Provider를 통해 UserProvider 인스턴스에 접근 (listen: false로 불필요한 리빌드 방지)
          final userProvider = Provider.of<UserProvider>(
            context,
            listen: false,
          );

          if (userProvider.isLoggedIn) {
            // 로그인 상태: Q&A 글쓰기 페이지로 이동
            final result = await Navigator.push<bool>(
              context,
              MaterialPageRoute(builder: (context) => const QnAWriting()),
            );
            if (result == true) {
              _refresh(); // 글 작성 후 돌아오면 목록 새로고침
            }
          } else {
            // 비로그인 상태: 로그인 페이지로 이동
            final result = await Navigator.push<bool>(
              context,
              MaterialPageRoute(builder: (context) => const LoginPage()),
            );
            if (result == true) {
              setState(
                () {},
              ); // 로그인 후 돌아오면 UI 새로고침 (이 부분이 왜 필요한지 명확하진 않지만 기존 코드 유지)
            }
          }
        },
        backgroundColor: Colors.green, // 버튼 배경색
        child: const Icon(Icons.add, color: Colors.white), // 버튼 아이콘
      ),
    );
  }

  /// 질문 목록을 빌드하는 위젯입니다.
  /// 로딩, 에러, 질문 없음 상태를 처리하고, RefreshIndicator를 통해 새로고침 기능을 제공합니다.
  Widget _buildQuestionList() {
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

    // 질문이 비어있고 로딩 중일 때 로딩 인디케이터 표시
    if (_questions.isEmpty && _isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // 질문이 비어있을 때 (로딩 완료 후) 메시지 표시
    if (_questions.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.help_outline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('아직 질문이 없습니다', style: TextStyle(fontSize: 16)),
            SizedBox(height: 8),
            Text('첫 번째 질문을 올려보세요!', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    // 질문 목록 표시 (Pull-to-refresh 기능 포함)
    return RefreshIndicator(
      onRefresh: _refresh, // 새로고침 시 _refresh 함수 호출
      child: ListView.builder(
        controller: _scrollController, // 스크롤 컨트롤러 연결
        itemCount:
            _questions.length +
            (_isLoading ? 1 : 0), // 로딩 중이면 로딩 인디케이터를 위해 아이템 개수 1 증가
        itemBuilder: (context, index) {
          // 마지막 아이템이면서 로딩 중일 때 로딩 인디케이터 표시
          if (index == _questions.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ),
            );
          }

          // 각 질문 아이템을 QnAItem 위젯으로 표시
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: QnAItem(
              question: _questions[index], // QnaQuestion 데이터 전달
              onTap: () async {
                // 질문 아이템 탭 시 QnADetail 페이지로 이동
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => QnADetail(question: _questions[index]),
                  ),
                );
                if (result == true) {
                  _refresh(); // 상세 페이지에서 돌아왔을 때 목록 새로고침
                }
              },
            ),
          );
        },
      ),
    );
  }
}

/// Q&A 질문 목록을 필터링하는 기능을 제공하는 StatefulWidget입니다.
/// 정렬 옵션과 산 선택 드롭다운을 포함합니다.
class QnAFilter extends StatefulWidget {
  // 필터 변경 시 호출될 콜백 함수
  final Function(String sort, String? mountain) onFilterChanged;

  const QnAFilter({super.key, required this.onFilterChanged});

  @override
  State<QnAFilter> createState() => _QnAFilterState();
}

/// QnAFilter의 상태를 관리하는 State 클래스입니다.
/// 선택된 정렬 옵션과 산을 관리하고, 변경 시 [onFilterChanged] 콜백을 통해 상위 위젯에 알립니다.
class _QnAFilterState extends State<QnAFilter> {
  String _sortOption = 'latest'; // 현재 선택된 정렬 옵션 (기본값: 'latest')
  String? _selectedMountain; // 현재 선택된 산 (기본값: null, '전체')

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

  // 드롭다운에 사용될 정렬 옵션 코드
  final List<String> sortOptions = const ['latest', 'popular', 'answered'];
  // 정렬 옵션 코드에 대한 사용자 친화적인 라벨 매핑
  final Map<String, String> sortLabels = const {
    'latest': '최신순',
    'popular': '인기순',
    'answered': '답변순',
  };

  /// 산 선택 드롭다운 값이 변경될 때 호출됩니다.
  void _selectMountain(String? mountain) {
    setState(() {
      _selectedMountain = mountain;
    });
    // 필터 변경 사항을 상위 위젯에 알림
    widget.onFilterChanged(_sortOption, _selectedMountain);
  }

  /// 정렬 옵션 드롭다운 값이 변경될 때 호출됩니다.
  void _changeSortOption(String? option) {
    if (option != null) {
      setState(() {
        _sortOption = option;
      });
      // 필터 변경 사항을 상위 위젯에 알림
      widget.onFilterChanged(_sortOption, _selectedMountain);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // 정렬 옵션 드롭다운 필드
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
                        child: Text(
                          sortLabels[option] ?? option,
                        ), // 매핑된 라벨 또는 코드 표시
                      );
                    }).toList(),
                onChanged: _changeSortOption, // 값 변경 시 호출될 콜백
              ),
            ),
            const SizedBox(width: 16), // 간격
            // 산 선택 드롭다운 필드
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

/// 개별 Q&A 질문 항목을 표시하는 StatelessWidget입니다.
/// 질문 제목, 내용 미리보기, 작성자 정보, 통계(조회수, 답변 수, 좋아요 수)를 표시합니다.
class QnAItem extends StatelessWidget {
  final QnaQuestion question; // 표시할 Q&A 질문 데이터
  final VoidCallback onTap; // 질문 항목 탭 시 호출될 콜백

  const QnAItem({super.key, required this.question, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1, // 카드 그림자 깊이
      // 카드 전체를 탭 가능하게 하여 상세 페이지로 이동
      child: InkWell(
        onTap: onTap, // 탭 시 [onTap] 콜백 호출
        child: Padding(
          padding: const EdgeInsets.all(16.0), // 내부 패딩
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, // 내용을 왼쪽 정렬
            children: [
              // 질문 제목
              Row(
                children: [
                  Icon(
                    Icons.help_outline,
                    size: 16,
                    color: Colors.green[600],
                  ), // 질문 아이콘
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      question.title, // 질문 제목
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2, // 최대 2줄까지 표시
                      overflow: TextOverflow.ellipsis, // 2줄 초과 시 ...으로 표시
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8), // 간격
              // 질문 내용 미리보기
              Text(
                question.content, // 질문 내용
                style: const TextStyle(fontSize: 14, color: Colors.grey),
                maxLines: 2, // 최대 2줄까지 표시
                overflow: TextOverflow.ellipsis, // 2줄 초과 시 ...으로 표시
              ),

              const SizedBox(height: 12), // 간격
              // 하단 정보 (작성자, 날짜, 산 태그, 통계)
              Row(
                children: [
                  // 작성자 정보 (아바타, 닉네임, 작성일)
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: Colors.green[100],
                    child: Text(
                      question.nickname.isNotEmpty
                          ? question.nickname[0]
                              .toUpperCase() // 닉네임 첫 글자 표시
                          : 'U', // 닉네임이 없으면 'U' 표시
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    question.nickname, // 작성자 닉네임
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    // 작성월일 포맷팅 (MM-DD)
                    '${question.createdAt.month.toString().padLeft(2, '0')}-${question.createdAt.day.toString().padLeft(2, '0')}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),

                  const Spacer(), // 남은 공간 채우기
                  // 산 태그
                  if (question.mountain.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green[200]!),
                      ),
                      child: Text(
                        question.mountain, // 산 이름
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.green[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 8), // 간격
              // 통계 정보 (조회수, 답변 수, 좋아요 수)
              Row(
                children: [
                  // 조회수
                  Icon(
                    Icons.visibility_outlined,
                    size: 14,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${question.viewCount}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),

                  const SizedBox(width: 16), // 간격
                  // 답변 수
                  Icon(
                    Icons.comment_outlined,
                    size: 14,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${question.answerCount}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),

                  const SizedBox(width: 16), // 간격
                  // 좋아요 수
                  Icon(
                    Icons.favorite_border,
                    size: 14,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${question.likeCount}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
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
