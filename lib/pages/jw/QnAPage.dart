import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trekkit_flutter/functions/jh/userprovider.dart';
import 'package:trekkit_flutter/services/jw/QnaService.dart';
import 'package:trekkit_flutter/models/jw/QnaQuestion.dart';
import 'package:trekkit_flutter/pages/jh/Login_and_Signup/login.dart';
import 'package:trekkit_flutter/pages/jw/QnADetail.dart';
import 'package:trekkit_flutter/pages/jw/QnAWriting.dart';

class QnAPage extends StatefulWidget {
  const QnAPage({super.key});

  @override
  State<QnAPage> createState() => _QnAPageState();
}

class _QnAPageState extends State<QnAPage> {
  List<QnaQuestion> _questions = [];
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';

  String _currentSort = 'latest';
  String? _currentMountain;
  int _currentPage = 0;
  int _totalCount = 0;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadQuestions();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _loadMoreQuestions();
    }
  }

  void _applyFilter(String sort, String? mountain) {
    setState(() {
      _currentSort = sort;
      _currentMountain = mountain;
      _currentPage = 0;
      _questions.clear();
    });
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final result = await QnaService.getQuestions(
        sort: _currentSort,
        mountain: _currentMountain,
        page: _currentPage,
        size: 10,
      );

      setState(() {
        if (_currentPage == 0) {
          _questions = result['questions'];
        } else {
          _questions.addAll(result['questions']);
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

  Future<void> _loadMoreQuestions() async {
    if (_questions.length >= _totalCount) return;
    _currentPage++;
    await _loadQuestions();
  }

  Future<void> _refresh() async {
    setState(() {
      _currentPage = 0;
      _questions.clear();
    });
    await _loadQuestions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // 필터 영역
          QnAFilter(onFilterChanged: _applyFilter),
          const SizedBox(height: 16),
          // 질문 목록
          Expanded(child: _buildQuestionList()),
        ],
      ),
      // FloatingActionButton 추가
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
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
              _refresh(); // 새로고침
            }
          } else {
            // 비로그인 상태: 로그인 페이지로 이동
            final result = await Navigator.push<bool>(
              context,
              MaterialPageRoute(builder: (context) => const LoginPage()),
            );
            if (result == true) {
              setState(() {}); // 로그인 후 새로고침
            }
          }
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildQuestionList() {
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

    if (_questions.isEmpty && _isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

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

    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView.builder(
        controller: _scrollController,
        itemCount: _questions.length + (_isLoading ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _questions.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: QnAItem(
              question: _questions[index],
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => QnADetail(question: _questions[index]),
                  ),
                );
                if (result == true) {
                  _refresh();
                }
              },
            ),
          );
        },
      ),
    );
  }
}

// 나머지 클래스들은 동일하게 유지
class QnAFilter extends StatefulWidget {
  final Function(String sort, String? mountain) onFilterChanged;

  const QnAFilter({super.key, required this.onFilterChanged});

  @override
  State<QnAFilter> createState() => _QnAFilterState();
}

class _QnAFilterState extends State<QnAFilter> {
  String _sortOption = 'latest';
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

  final List<String> sortOptions = ['latest', 'popular', 'answered'];
  final Map<String, String> sortLabels = {
    'latest': '최신순',
    'popular': '인기순',
    'answered': '답변순',
  };

  void _selectMountain(String? mountain) {
    setState(() {
      _selectedMountain = mountain;
    });
    widget.onFilterChanged(_sortOption, _selectedMountain);
  }

  void _changeSortOption(String? option) {
    if (option != null) {
      setState(() {
        _sortOption = option;
      });
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
                        child: Text(sortLabels[option] ?? option),
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

class QnAItem extends StatelessWidget {
  final QnaQuestion question;
  final VoidCallback onTap;

  const QnAItem({super.key, required this.question, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 질문 제목
              Row(
                children: [
                  Icon(Icons.help_outline, size: 16, color: Colors.green[600]),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      question.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // 질문 내용 미리보기
              Text(
                question.content,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 12),

              // 하단 정보
              Row(
                children: [
                  // 작성자 정보
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: Colors.green[100],
                    child: Text(
                      question.nickname.isNotEmpty
                          ? question.nickname[0].toUpperCase()
                          : 'U',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    question.nickname,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${question.createdAt.month.toString().padLeft(2, '0')}-${question.createdAt.day.toString().padLeft(2, '0')}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),

                  const Spacer(),

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
                        question.mountain,
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.green[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 8),

              // 통계 정보
              Row(
                children: [
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

                  const SizedBox(width: 16),

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

                  const SizedBox(width: 16),

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
