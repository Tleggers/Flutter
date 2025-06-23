import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trekkit_flutter/functions/jh/userprovider.dart';
import 'package:trekkit_flutter/services/jw/QnaService.dart';
import 'package:trekkit_flutter/models/jw/QnaQuestion.dart';
import 'package:trekkit_flutter/models/jw/QnaAnswer.dart'; // QnaAnswer 모델 임포트
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
  late QnaQuestion _currentQuestion;

  final TextEditingController _answerController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _currentQuestion = widget.question;
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
        context, // context 전달
      );
      setState(() {
        _answers = answers;
        _isLoading = false;
      });
    } on QnaException catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = e.message;
      });
      _showErrorSnackBar(e.message, e.type);
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = e.toString();
      });
      _showErrorSnackBar('답변 로딩 중 예상치 못한 오류 발생', QnaErrorType.unknown);
    }
  }

  // 좋아요 토글 기능 추가
  Future<void> _toggleLike() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    if (!userProvider.isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('로그인이 필요합니다'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
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
      final isLiked = await QnaService.toggleQuestionLike(
        _currentQuestion.id,
        context, // context 전달
      );

      final newLikeCount =
          isLiked
              ? _currentQuestion.likeCount + 1
              : _currentQuestion.likeCount - 1;

      setState(() {
        _currentQuestion = _currentQuestion.copyWith(likeCount: newLikeCount);
      });
    } on QnaException catch (e) {
      if (mounted) {
        _showErrorSnackBar(e.message, e.type);
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

  // 답변 좋아요 토글 기능 추가
  Future<void> _toggleAnswerLike(QnaAnswer answer, int index) async {
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

    try {
      final isLiked = await QnaService.toggleAnswerLike(
        answer.id,
        context, // context 전달
      );

      final newLikeCount =
          isLiked ? answer.likeCount + 1 : answer.likeCount - 1;

      setState(() {
        _answers[index] = _answers[index].copyWith(likeCount: newLikeCount);
      });
    } on QnaException catch (e) {
      if (mounted) {
        _showErrorSnackBar(e.message, e.type);
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
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    if (_answerController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('답변 내용을 입력해주세요')));
      return;
    }

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
      final answer = QnaAnswer(
        id: 0,
        questionId: _currentQuestion.id,
        userId: userProvider.index!, // userId는 int 타입
        nickname: userProvider.nickname ?? '익명',
        content: _answerController.text.trim(),
        imagePaths: [],
        likeCount: 0,
        isAccepted: false,
        createdAt: DateTime.now(),
      );

      await QnaService.createAnswer(answer, context); // context 전달
      _answerController.clear();
      await _loadAnswers(); // 답변 등록 후 답변 목록 새로고침

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('답변이 등록되었습니다')));
    } on QnaException catch (e) {
      if (mounted) {
        _showErrorSnackBar(e.message, e.type);
      }
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

  // 🆕 에러 스낵바 표시 (에러 타입별 색상 구분)
  void _showErrorSnackBar(String message, QnaErrorType errorType) {
    Color backgroundColor;
    IconData icon;

    switch (errorType) {
      case QnaErrorType.network:
        backgroundColor = Colors.orange;
        icon = Icons.wifi_off;
        break;
      case QnaErrorType.serverError:
        backgroundColor = Colors.red;
        icon = Icons.error;
        break;
      case QnaErrorType.unauthorized:
      case QnaErrorType.forbidden:
        backgroundColor = Colors.amber;
        icon = Icons.lock;
        break;
      case QnaErrorType.validation:
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
            errorType == QnaErrorType.network
                ? SnackBarAction(
                  label: '재시도',
                  textColor: Colors.white,
                  onPressed: () => _loadAnswers(), // 답변 로딩 재시도
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

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Q&A'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildQuestionHeader(),
                  const SizedBox(height: 16),
                  _buildQuestionContent(),
                  const SizedBox(height: 24),
                  _buildAnswersList(),
                ],
              ),
            ),
          ),
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
                        _formatDate(_currentQuestion.createdAt),
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
                  onTap: _toggleLike,
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
                  _formatDate(answer.createdAt),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              answer.content,
              style: const TextStyle(fontSize: 14, height: 1.4),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                InkWell(
                  onTap: () => _toggleAnswerLike(answer, index),
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
              enabled: userProvider.isLoggedIn,
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed:
                userProvider.isLoggedIn && !_isSubmitting
                    ? _submitAnswer
                    : null,
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
