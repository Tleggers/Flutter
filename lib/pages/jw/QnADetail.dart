import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trekkit_flutter/functions/jh/userprovider.dart';
import 'package:trekkit_flutter/services/jw/QnaService.dart';
import 'package:trekkit_flutter/models/jw/QnaQuestion.dart';
import 'package:trekkit_flutter/pages/jh/Login_and_Signup/login.dart';

class QnADetail extends StatefulWidget {
  final QnaQuestion question;

  const QnADetail({super.key, required this.question});

  @override
  State<QnADetail> createState() => _QnADetailState();
}

class _QnADetailState extends State<QnADetail> {
  List<QnaAnswer> _answers = [];
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';
  bool _isLikeLoading = false;
  late QnaQuestion _currentQuestion; // late 키워드 유지

  final TextEditingController _answerController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _currentQuestion = widget.question; // initState에서 반드시 초기화
    _loadAnswers();
  }

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  Future<void> _loadAnswers() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final answers = await QnaService.getAnswersByQuestionId(
        _currentQuestion.id,
      );
      setState(() {
        _answers = answers;
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

  // 좋아요 토글 기능 추가
  Future<void> _toggleLike() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    // 로그인 상태 확인 (Provider 사용)
    if (!userProvider.isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('로그인이 필요합니다'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );

      // 로그인 페이지로 이동
      final result = await Navigator.push<bool>(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );

      if (result != true) return;
    }

    if (_isLikeLoading) return;

    setState(() {
      _isLikeLoading = true;
    });

    try {
      // userProvider.index가 null이 아닌지 확인
      if (userProvider.index != null) {
        // 반환값이 bool인 경우 처리
        final isLiked = await QnaService.toggleQuestionLike(
          _currentQuestion.id,
          userProvider.index.toString(), // userId 대신 index 사용
        );

        // 좋아요 수 직접 계산
        final newLikeCount =
            isLiked
                ? _currentQuestion.likeCount + 1
                : _currentQuestion.likeCount - 1;

        setState(() {
          _currentQuestion = _currentQuestion.copyWith(likeCount: newLikeCount);
          _isLikeLoading = false;
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
      setState(() {
        _isLikeLoading = false;
      });
    }
  }

  // 답변 좋아요 토글 기능 추가
  Future<void> _toggleAnswerLike(QnaAnswer answer, int index) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    // 로그인 상태 확인 (Provider 사용)
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

    try {
      // userProvider.index가 null이 아닌지 확인
      if (userProvider.index != null) {
        // 반환값이 bool인 경우 처리
        final isLiked = await QnaService.toggleAnswerLike(
          answer.id,
          userProvider.index.toString(), // index를 문자열로 변환
        );

        // 좋아요 수 직접 계산
        final newLikeCount =
            isLiked ? answer.likeCount + 1 : answer.likeCount - 1;

        setState(() {
          _answers[index] = _answers[index].copyWith(likeCount: newLikeCount);
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
    }
  }

  Future<void> _submitAnswer() async {
    // UserProvider를 통해 로그인 상태 확인
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    if (_answerController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('답변 내용을 입력해주세요')));
      return;
    }

    // 로그인 상태 확인 (Provider 사용)
    if (!userProvider.isLoggedIn) {
      final result = await Navigator.push<bool>(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
      if (result != true) return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // userProvider에서 정보 가져오기
      final answer = QnaAnswer(
        id: 0,
        questionId: _currentQuestion.id,
        userId: userProvider.index.toString(), // AuthService 대신 userProvider 사용
        nickname: userProvider.nickname ?? '익명',
        content: _answerController.text.trim(),
        imagePaths: [],
        likeCount: 0,
        isAccepted: false,
        createdAt: DateTime.now(),
      );

      await QnaService.createAnswer(answer, userProvider.token ?? '');
      _answerController.clear();
      await _loadAnswers();

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('답변이 등록되었습니다')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('답변 등록 실패: $e')));
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // UserProvider 가져오기
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Q&A'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // 질문 내용
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 질문 헤더
                  _buildQuestionHeader(),
                  const SizedBox(height: 16),

                  // 질문 내용
                  _buildQuestionContent(),
                  const SizedBox(height: 24),

                  // 답변 목록
                  _buildAnswersList(),
                ],
              ),
            ),
          ),

          // 답변 입력 영역
          _buildAnswerInput(userProvider),
        ],
      ),
    );
  }

  Widget _buildQuestionHeader() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 작성자 정보
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.green[100],
                  child: Text(
                    _currentQuestion.nickname.isNotEmpty
                        ? _currentQuestion.nickname[0].toUpperCase()
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
                        _currentQuestion.nickname,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        '${_currentQuestion.createdAt.year}-${_currentQuestion.createdAt.month.toString().padLeft(2, '0')}-${_currentQuestion.createdAt.day.toString().padLeft(2, '0')}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                if (_currentQuestion.mountain.isNotEmpty)
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
                      _currentQuestion.mountain,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 16),

            // 질문 제목
            Row(
              children: [
                Icon(Icons.help_outline, size: 20, color: Colors.green[600]),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _currentQuestion.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionContent() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _currentQuestion.content,
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),

            const SizedBox(height: 16),

            // 통계 정보
            Row(
              children: [
                Icon(
                  Icons.visibility_outlined,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  '${_currentQuestion.viewCount}',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),

                const SizedBox(width: 16),

                Icon(Icons.favorite_border, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  '${_currentQuestion.likeCount}',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),

                const Spacer(),

                InkWell(
                  onTap: _toggleLike, // 좋아요 기능 연결
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _isLikeLoading
                            ? SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.grey[600],
                              ),
                            )
                            : Icon(
                              Icons.favorite_border,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                        const SizedBox(width: 4),
                        Text(
                          '좋아요',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnswersList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '답글 총 ${_answers.length}개',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),

        if (_isLoading)
          const Center(child: CircularProgressIndicator())
        else if (_hasError)
          Center(
            child: Column(
              children: [
                Text('오류 발생: $_errorMessage'),
                ElevatedButton(
                  onPressed: _loadAnswers,
                  child: const Text('다시 시도'),
                ),
              ],
            ),
          )
        else if (_answers.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Text(
                '아직 답변이 없습니다.\n첫 번째 답변을 남겨보세요!',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _answers.length,
            itemBuilder: (context, index) {
              return _buildAnswerItem(_answers[index], index);
            },
          ),
      ],
    );
  }

  Widget _buildAnswerItem(QnaAnswer answer, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 답변자 정보
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.blue[100],
                  child: Text(
                    answer.nickname.isNotEmpty
                        ? answer.nickname[0].toUpperCase()
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
                  answer.nickname,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${answer.createdAt.year}-${answer.createdAt.month.toString().padLeft(2, '0')}-${answer.createdAt.day.toString().padLeft(2, '0')}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // 답변 내용
            Text(
              answer.content,
              style: const TextStyle(fontSize: 14, height: 1.4),
            ),

            const SizedBox(height: 8),

            // 답변 좋아요
            Row(
              children: [
                InkWell(
                  onTap: () => _toggleAnswerLike(answer, index), // 답변 좋아요 기능 연결
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.favorite_border,
                        size: 14,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${answer.likeCount}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnswerInput(UserProvider userProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _answerController,
              decoration: InputDecoration(
                hintText:
                    userProvider.isLoggedIn
                        ? '답변을 입력하세요...'
                        : '로그인 후 사용할 수 있어요',
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              maxLines: null,
              enabled: userProvider.isLoggedIn, // Provider를 통한 로그인 상태 확인
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed:
                userProvider.isLoggedIn && !_isSubmitting
                    ? _submitAnswer
                    : null, // 로그인 상태에 따라 버튼 활성화
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child:
                _isSubmitting
                    ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                    : const Text('등록'),
          ),
        ],
      ),
    );
  }
}

// QnaAnswer 클래스에 copyWith 메서드 추가 필요
extension QnaAnswerExtension on QnaAnswer {
  QnaAnswer copyWith({
    int? id,
    int? questionId,
    String? userId,
    String? nickname,
    String? content,
    List<String>? imagePaths,
    int? likeCount,
    bool? isAccepted,
    DateTime? createdAt,
  }) {
    return QnaAnswer(
      id: id ?? this.id,
      questionId: questionId ?? this.questionId,
      userId: userId ?? this.userId,
      nickname: nickname ?? this.nickname,
      content: content ?? this.content,
      imagePaths: imagePaths ?? this.imagePaths,
      likeCount: likeCount ?? this.likeCount,
      isAccepted: isAccepted ?? this.isAccepted,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

// QnaQuestion 클래스에 copyWith 메서드 수정
extension QnaQuestionExtension on QnaQuestion {
  QnaQuestion copyWith({
    int? id,
    String? userId,
    String? nickname,
    String? title,
    String? content,
    String? mountain,
    List<String>? imagePaths,
    int? viewCount,
    int? likeCount,
    int? answerCount,
    bool? isSolved, // isResolved에서 isSolved로 변경
    DateTime? createdAt,
  }) {
    return QnaQuestion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      nickname: nickname ?? this.nickname,
      title: title ?? this.title,
      content: content ?? this.content,
      mountain: mountain ?? this.mountain,
      imagePaths: imagePaths ?? this.imagePaths,
      viewCount: viewCount ?? this.viewCount,
      likeCount: likeCount ?? this.likeCount,
      answerCount: answerCount ?? this.answerCount,
      isSolved: isSolved ?? this.isSolved, // isResolved에서 isSolved로 변경
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
