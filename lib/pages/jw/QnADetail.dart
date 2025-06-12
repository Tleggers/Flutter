import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trekkit_flutter/functions/jh/userprovider.dart';
import 'package:trekkit_flutter/services/jw/AuthService.dart';
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

  final TextEditingController _answerController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
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
        widget.question.id,
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

  Future<void> _submitAnswer() async {
    if (_answerController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('답변 내용을 입력해주세요')));
      return;
    }

    if (!AuthService().isLoggedIn) {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
      if (result != true) return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final answer = QnaAnswer(
        id: 0,
        questionId: widget.question.id,
        userId: AuthService().userId!,
        nickname: userProvider.nickname ?? '익명',
        content: _answerController.text.trim(),
        imagePaths: [],
        likeCount: 0,
        isAccepted: false,
        createdAt: DateTime.now(),
      );

      await QnaService.createAnswer(answer, userProvider.token!);
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
          _buildAnswerInput(),
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
                    widget.question.nickname.isNotEmpty
                        ? widget.question.nickname[0].toUpperCase()
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
                        widget.question.nickname,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        '${widget.question.createdAt.year}-${widget.question.createdAt.month.toString().padLeft(2, '0')}-${widget.question.createdAt.day.toString().padLeft(2, '0')}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                if (widget.question.mountain.isNotEmpty)
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
                      widget.question.mountain,
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
                    widget.question.title,
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
              widget.question.content,
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
                  '${widget.question.viewCount}',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),

                const SizedBox(width: 16),

                Icon(Icons.favorite_border, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  '${widget.question.likeCount}',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),

                const Spacer(),

                InkWell(
                  onTap: () {
                    // 좋아요 기능 구현
                  },
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
                        Icon(
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
              return _buildAnswerItem(_answers[index]);
            },
          ),
      ],
    );
  }

  Widget _buildAnswerItem(QnaAnswer answer) {
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
                  onTap: () {
                    // 답변 좋아요 기능 구현
                  },
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

  Widget _buildAnswerInput() {
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
              decoration: const InputDecoration(
                hintText: '로그인 후 사용할 수 있어요',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              maxLines: null,
              enabled: AuthService().isLoggedIn,
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: _isSubmitting ? null : _submitAnswer,
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
