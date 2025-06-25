import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trekkit_flutter/functions/jh/userprovider.dart';
import 'package:trekkit_flutter/services/jw/QnaService.dart';
import 'package:trekkit_flutter/models/jw/QnaQuestion.dart';
import 'package:trekkit_flutter/models/jw/QnaAnswer.dart';
import 'package:trekkit_flutter/pages/jh/Login_and_Signup/login.dart';
import 'package:trekkit_flutter/pages/jw/QnAWriting.dart';

/// Q&A 상세 페이지를 담당하는 StatefulWidget입니다.
/// 특정 질문의 내용과 그에 대한 답변 목록을 표시하고, 답변을 작성할 수 있도록 합니다.
class QnADetail extends StatefulWidget {
  final QnaQuestion question; // 상세 보기할 Q&A 질문 데이터

  const QnADetail({super.key, required this.question});

  @override
  State<QnADetail> createState() => _QnADetailState();
}

/// QnADetail 페이지의 상태를 관리하는 State 클래스입니다.
/// 답변 목록 로딩, 좋아요 토글, 답변 제출, 수정, 삭제 등의 비동기 작업을 처리합니다.
class _QnADetailState extends State<QnADetail> {
  List<QnaAnswer> _answers = []; // 현재 질문에 대한 답변 목록
  bool _isLoading = false; // 답변 로딩 중인지 여부
  bool _hasError = false; // 오류 발생 여부
  String _errorMessage = ''; // 발생한 오류 메시지
  bool _isLikeLoading = false; // 질문 좋아요 처리 중인지 여부
  late QnaQuestion
  _currentQuestion; // 현재 표시되는 질문 (좋아요 수 업데이트 및 수정 후 갱신을 위해 State 내에서 관리)

  final TextEditingController _answerController =
      TextEditingController(); // 답변 입력 필드 컨트롤러
  bool _isSubmitting = false; // 답변 제출 중인지 여부

  @override
  void initState() {
    super.initState();
    _currentQuestion = widget.question; // 초기 질문 데이터 설정
    _loadAnswers(); // 페이지 초기화 시 답변 목록 로드
  }

  @override
  void dispose() {
    _answerController
        .dispose(); // 위젯이 dispose될 때 답변 입력 컨트롤러를 dispose하여 리소스 누수 방지
    super.dispose();
  }

  /// 현재 질문에 대한 답변 목록을 백엔드에서 비동기로 로드합니다.
  /// 로딩 상태, 에러 상태를 관리하고 결과를 [_answers]에 업데이트합니다.
  Future<void> _loadAnswers() async {
    setState(() {
      _isLoading = true; // 로딩 상태 시작
      _hasError = false; // 에러 상태 초기화
      _errorMessage = ''; // 에러 메시지 초기화
    });

    try {
      final answers = await QnaService.getAnswersByQuestionId(
        _currentQuestion.id,
        context,
      );
      setState(() {
        _answers = answers; // 로드된 답변 목록 업데이트
        _isLoading = false; // 로딩 상태 종료
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

  /// 질문에 대한 좋아요/좋아요 취소 기능을 토글합니다.
  /// 로그인 상태 확인 후, API를 호출하고 질문의 좋아요 수를 업데이트합니다.
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
        context,
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

  /// 특정 답변에 대한 좋아요/좋아요 취소 기능을 토글합니다.
  /// 로그인 상태 확인 후, API를 호출하고 답변의 좋아요 수를 업데이트합니다.
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
      final isLiked = await QnaService.toggleAnswerLike(answer.id, context);

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

  /// 답변을 제출하는 기능을 수행합니다.
  /// 입력 유효성 및 로그인 상태를 확인 후, 답변 생성 API를 호출합니다.
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
        id: 0, // ID는 백엔드에서 생성되므로 임시값
        questionId: _currentQuestion.id,
        userId: userProvider.index!,
        nickname: userProvider.nickname ?? '익명',
        content: _answerController.text.trim(),
        imagePaths: [],
        likeCount: 0,
        isAccepted: false,
        createdAt: DateTime.now(),
      );

      await QnaService.createAnswer(answer, context);
      _answerController.clear();
      await _loadAnswers();

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

  /// 오류 메시지를 표시하는 스낵바를 띄웁니다.
  /// [errorType]에 따라 스낵바의 배경색과 아이콘이 달라집니다.
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
                  onPressed: () => _loadAnswers(),
                )
                : null,
      ),
    );
  }

  /// 날짜를 'YYYY-MM-DD', 'X시간 전', 'X분 전', '방금 전' 형식으로 포맷팅합니다.
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

  /// 질문 수정 페이지로 이동하는 함수입니다.
  /// 수정 완료 후 돌아왔을 때 질문 정보를 갱신합니다.
  Future<void> _navigateToEditQuestion() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QnAWriting(question: _currentQuestion),
      ),
    );

    if (result == true) {
      try {
        final updatedQuestion = await QnaService.getQuestionById(
          _currentQuestion.id,
          context,
        );
        if (updatedQuestion != null && mounted) {
          setState(() {
            _currentQuestion = updatedQuestion;
          });
        }
      } on QnaException catch (e) {
        if (mounted) {
          _showErrorSnackBar('질문 정보 갱신 실패: ${e.message}', e.type);
        }
      } catch (e) {
        if (mounted) {
          _showErrorSnackBar('질문 정보 갱신 중 오류 발생: $e', QnaErrorType.unknown);
        }
      }
    }
  }

  /// 질문을 삭제하는 함수입니다.
  /// 사용자에게 삭제 확인 다이얼로그를 표시한 후, 삭제 API를 호출합니다.
  Future<void> _deleteQuestion() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    if (!userProvider.isLoggedIn ||
        userProvider.index != _currentQuestion.userId) {
      if (mounted) {
        _showErrorSnackBar('질문을 삭제할 권한이 없습니다.', QnaErrorType.forbidden);
      }
      return;
    }

    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('질문 삭제'),
          content: const Text('정말로 이 질문을 삭제하시겠습니까? 이 작업은 되돌릴 수 없습니다.'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('취소'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('삭제', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      try {
        await QnaService.deleteQuestion(_currentQuestion.id, context);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('질문이 성공적으로 삭제되었습니다.'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        }
      } on QnaException catch (e) {
        if (mounted) {
          _showErrorSnackBar(e.message, e.type);
        }
      } catch (e) {
        if (mounted) {
          _showErrorSnackBar('질문 삭제 실패: $e', QnaErrorType.unknown);
        }
      }
    }
  }

  /// 답변을 수정하는 다이얼로그를 표시하고 수정 요청을 처리합니다.
  Future<void> _editAnswer(QnaAnswer answerToEdit) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (!userProvider.isLoggedIn || userProvider.index != answerToEdit.userId) {
      _showErrorSnackBar('답변 수정 권한이 없습니다.', QnaErrorType.forbidden);
      return;
    }

    final TextEditingController editController = TextEditingController(
      text: answerToEdit.content,
    );
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('답변 수정'),
            content: TextField(
              controller: editController,
              decoration: const InputDecoration(hintText: '답변 내용을 입력하세요'),
              maxLines: null,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('취소'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('수정'),
              ),
            ],
          ),
    );

    if (confirmed == true && editController.text.trim().isNotEmpty) {
      try {
        final updatedAnswer = answerToEdit.copyWith(
          content: editController.text.trim(),
        );
        await QnaService.updateAnswer(updatedAnswer, context);
        _showErrorSnackBar('답변이 수정되었습니다.', QnaErrorType.unknown);
        _loadAnswers();
      } on QnaException catch (e) {
        _showErrorSnackBar(e.message, e.type);
      } catch (e) {
        _showErrorSnackBar('답변 수정 실패: $e', QnaErrorType.unknown);
      }
    } else if (confirmed == true && editController.text.trim().isEmpty) {
      _showErrorSnackBar('답변 내용을 입력해주세요.', QnaErrorType.validation);
    }
    editController.dispose();
  }

  /// 답변을 삭제하는 로직을 처리합니다.
  Future<void> _deleteAnswer(QnaAnswer answerToDelete) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (!userProvider.isLoggedIn ||
        userProvider.index != answerToDelete.userId) {
      _showErrorSnackBar('답변 삭제 권한이 없습니다.', QnaErrorType.forbidden);
      return;
    }

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('답변 삭제'),
            content: const Text('정말로 이 답변을 삭제하시겠습니까?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('취소'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('삭제', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      try {
        await QnaService.deleteAnswer(
          answerToDelete.id,
          answerToDelete.questionId,
          context,
        );
        _showErrorSnackBar('답변이 삭제되었습니다.', QnaErrorType.unknown);
        _loadAnswers();
        setState(() {
          _currentQuestion = _currentQuestion.copyWith(
            answerCount: _currentQuestion.answerCount - 1,
          );
        });
      } on QnaException catch (e) {
        _showErrorSnackBar(e.message, e.type);
      } catch (e) {
        _showErrorSnackBar('답변 삭제 실패: $e', QnaErrorType.unknown);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    // 현재 로그인된 사용자가 질문 작성자인지 확인
    final bool isAuthor =
        userProvider.isLoggedIn &&
        userProvider.index == _currentQuestion.userId;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Q&A'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          if (isAuthor)
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  _navigateToEditQuestion();
                } else if (value == 'delete') {
                  _deleteQuestion();
                }
              },
              itemBuilder:
                  (BuildContext context) => <PopupMenuEntry<String>>[
                    const PopupMenuItem<String>(
                      value: 'edit',
                      child: Text('수정'),
                    ),
                    const PopupMenuItem<String>(
                      value: 'delete',
                      child: Text('삭제'),
                    ),
                  ],
            ),
        ],
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

  /// 질문의 작성자 정보, 산 태그, 제목을 표시하는 위젯입니다.
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

  /// 질문의 상세 내용과 조회수, 좋아요 수, 좋아요 버튼을 표시하는 위젯입니다.
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

  /// 질문에 대한 답변 목록을 표시하는 위젯입니다.
  /// 로딩, 에러, 답변 없음 상태를 처리하며, 각 답변의 작성자에게 수정/삭제 옵션을 제공합니다.
  /// 질문 작성자에게는 답변 채택 기능을 제공합니다.
  Widget _buildAnswersList() {
    final userProvider = Provider.of<UserProvider>(context);
    final bool isQuestionAuthor =
        userProvider.isLoggedIn &&
        userProvider.index == _currentQuestion.userId;

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
              final answer = _answers[index];
              final bool isAnswerAuthor =
                  userProvider.isLoggedIn &&
                  userProvider.index == answer.userId;

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
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          const Spacer(),
                          if (isAnswerAuthor)
                            PopupMenuButton<String>(
                              onSelected: (value) {
                                if (value == 'edit') {
                                  _editAnswer(answer);
                                } else if (value == 'delete') {
                                  _deleteAnswer(answer);
                                }
                              },
                              itemBuilder:
                                  (context) => [
                                    const PopupMenuItem(
                                      value: 'edit',
                                      child: Text('수정'),
                                    ),
                                    const PopupMenuItem(
                                      value: 'delete',
                                      child: Text('삭제'),
                                    ),
                                  ],
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
                          const Spacer(),
                          if (answer.isAccepted && isQuestionAuthor)
                            Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 16,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  /// 답변 입력 필드와 등록 버튼을 포함하는 위젯입니다.
  /// 로그인 상태에 따라 입력 가능 여부가 달라지며, 키보드가 자동으로 활성화됩니다.
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
