import 'package:flutter/material.dart'; // Flutter UI 구성 요소를 위한 핵심 패키지
import 'package:provider/provider.dart'; // 상태 관리를 위한 Provider 패키지
import 'package:trekkit_flutter/functions/jh/userprovider.dart'; // 사용자 로그인 상태 및 정보 관리를 위한 UserProvider 임포트
import 'package:trekkit_flutter/services/jw/QnaService.dart'; // Q&A 관련 API 호출을 위한 QnaService 임포트
import 'package:trekkit_flutter/models/jw/QnaQuestion.dart'; // Q&A 질문 데이터 모델인 QnaQuestion 임포트
import 'package:trekkit_flutter/models/jw/QnaAnswer.dart'; // Q&A 답변 데이터 모델인 QnaAnswer 임포트
import 'package:trekkit_flutter/pages/jh/Login_and_Signup/login.dart'; // 로그인 페이지 임포트

/// Q&A 상세 페이지를 담당하는 StatefulWidget입니다.
/// 특정 질문의 내용과 그에 대한 답변 목록을 표시하고, 답변을 작성할 수 있도록 합니다.
class QnADetail extends StatefulWidget {
  final QnaQuestion question; // 상세 보기할 Q&A 질문 데이터

  const QnADetail({super.key, required this.question});

  @override
  State<QnADetail> createState() => _QnADetailState();
}

/// QnADetail 페이지의 상태를 관리하는 State 클래스입니다.
/// 답변 목록 로딩, 좋아요 토글, 답변 제출 등의 비동기 작업을 처리합니다.
class _QnADetailState extends State<QnADetail> {
  List<QnaAnswer> _answers = []; // 현재 질문에 대한 답변 목록
  bool _isLoading = false; // 답변 로딩 중인지 여부
  bool _hasError = false; // 오류 발생 여부
  String _errorMessage = ''; // 발생한 오류 메시지
  bool _isLikeLoading = false; // 질문 좋아요 처리 중인지 여부
  late QnaQuestion _currentQuestion; // 현재 표시되는 질문 (좋아요 수 업데이트를 위해 State 내에서 관리)

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
    // 위젯이 dispose될 때 답변 입력 컨트롤러를 dispose하여 리소스 누수 방지
    _answerController.dispose();
    super.dispose();
  }

  /// 현재 질문에 대한 답변 목록을 백엔드에서 비동기로 로드합니다.
  Future<void> _loadAnswers() async {
    setState(() {
      _isLoading = true; // 로딩 상태 시작
      _hasError = false; // 에러 상태 초기화
      _errorMessage = ''; // 에러 메시지 초기화
    });

    try {
      final answers = await QnaService.getAnswersByQuestionId(
        _currentQuestion.id, // 질문 ID로 답변 요청
        context, // context 전달
      );
      setState(() {
        _answers = answers; // 로드된 답변 목록 업데이트
        _isLoading = false; // 로딩 상태 종료
      });
    } on QnaException catch (e) {
      // QnaException 발생 시 처리
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = e.message;
      });
      _showErrorSnackBar(e.message, e.type); // 커스텀 스낵바로 에러 메시지 표시
    } catch (e) {
      // 그 외 예상치 못한 오류 발생 시 처리
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

    // 로그인되지 않은 경우 로그인 페이지로 이동 요청
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
      if (result != true) return; // 로그인 실패 또는 취소 시 함수 종료
    }

    if (_isLikeLoading) return; // 이미 좋아요 처리 중이면 중복 호출 방지

    setState(() {
      _isLikeLoading = true; // 좋아요 로딩 상태 시작
    });

    try {
      final isLiked = await QnaService.toggleQuestionLike(
        _currentQuestion.id, // 질문 ID로 좋아요 토글 요청
        context, // context 전달
      );

      // 좋아요 상태에 따라 좋아요 수 업데이트
      final newLikeCount =
          isLiked
              ? _currentQuestion.likeCount + 1
              : _currentQuestion.likeCount - 1;

      setState(() {
        // currentQuestion 객체를 새로운 좋아요 수로 업데이트
        _currentQuestion = _currentQuestion.copyWith(likeCount: newLikeCount);
      });
    } on QnaException catch (e) {
      // QnaException 발생 시 스낵바 표시
      if (mounted) {
        _showErrorSnackBar(e.message, e.type);
      }
    } catch (e) {
      // 그 외 예상치 못한 오류 발생 시 스낵바 표시
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('좋아요 처리 실패: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLikeLoading = false; // 좋아요 로딩 상태 종료
        });
      }
    }
  }

  /// 특정 답변에 대한 좋아요/좋아요 취소 기능을 토글합니다.
  /// 로그인 상태 확인 후, API를 호출하고 답변의 좋아요 수를 업데이트합니다.
  Future<void> _toggleAnswerLike(QnaAnswer answer, int index) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    // 로그인되지 않은 경우 스낵바 메시지 표시
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
        answer.id, // 답변 ID로 좋아요 토글 요청
        context, // context 전달
      );

      // 좋아요 상태에 따라 좋아요 수 업데이트
      final newLikeCount =
          isLiked ? answer.likeCount + 1 : answer.likeCount - 1;

      setState(() {
        // 답변 목록에서 해당 답변을 찾아 좋아요 수를 업데이트 (불변성 유지)
        _answers[index] = _answers[index].copyWith(likeCount: newLikeCount);
      });
    } on QnaException catch (e) {
      // QnaException 발생 시 스낵바 표시
      if (mounted) {
        _showErrorSnackBar(e.message, e.type);
      }
    } catch (e) {
      // 그 외 예상치 못한 오류 발생 시 스낵바 표시
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

    // 답변 내용이 비어있는지 확인
    if (_answerController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('답변 내용을 입력해주세요')));
      return;
    }

    // 로그인되지 않은 경우 로그인 페이지로 이동
    if (!userProvider.isLoggedIn) {
      final result = await Navigator.push<bool>(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
      if (result != true) return; // 로그인 실패 또는 취소 시 함수 종료
    }

    setState(() {
      _isSubmitting = true; // 제출 중 상태로 변경
    });

    try {
      // QnaAnswer 객체 생성
      final answer = QnaAnswer(
        id: 0, // ID는 백엔드에서 생성되므로 임시값
        questionId: _currentQuestion.id, // 현재 질문 ID
        userId: userProvider.index!, // 사용자 ID (int 타입)
        nickname: userProvider.nickname ?? '익명', // 사용자 닉네임, 없으면 '익명'
        content: _answerController.text.trim(), // 답변 내용
        imagePaths: [], // 답변에는 현재 이미지 첨부 없음
        likeCount: 0, // 초기 좋아요 수 0
        isAccepted: false, // 초기 채택 여부 false
        createdAt: DateTime.now(), // 현재 시간으로 생성일 설정
      );

      // QnaService를 통해 답변 생성 API 호출
      await QnaService.createAnswer(answer, context); // context 전달
      _answerController.clear(); // 답변 입력 필드 초기화
      await _loadAnswers(); // 답변 등록 후 답변 목록 새로고침

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('답변이 등록되었습니다')));
    } on QnaException catch (e) {
      // QnaException 발생 시 스낵바 표시
      if (mounted) {
        _showErrorSnackBar(e.message, e.type);
      }
    } catch (e) {
      // 그 외 예상치 못한 오류 발생 시 스낵바 표시
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('답변 등록 실패: $e')));
    } finally {
      setState(() {
        _isSubmitting = false; // 제출 상태 초기화
      });
    }
  }

  /// 오류 메시지를 표시하는 스낵바를 띄웁니다.
  /// [errorType]에 따라 스낵바의 배경색과 아이콘이 달라집니다.
  void _showErrorSnackBar(String message, QnaErrorType errorType) {
    Color backgroundColor;
    IconData icon;

    // 에러 타입에 따라 배경색과 아이콘 설정
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
            Icon(icon, color: Colors.white), // 아이콘
            const SizedBox(width: 8),
            Expanded(child: Text(message)), // 메시지
          ],
        ),
        backgroundColor: backgroundColor, // 배경색
        duration: const Duration(seconds: 4), // 스낵바 표시 시간
        action:
            // 네트워크 오류일 경우 '재시도' 버튼 제공
            errorType == QnaErrorType.network
                ? SnackBarAction(
                  label: '재시도',
                  textColor: Colors.white,
                  onPressed: () => _loadAnswers(), // 답변 로딩 재시도
                )
                : null, // 그 외 경우 버튼 없음
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

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(
      context,
    ); // UserProvider 인스턴스 가져오기

    return Scaffold(
      appBar: AppBar(
        title: const Text('Q&A'), // 앱 바 제목
        backgroundColor: Colors.green, // 앱 바 배경색
        foregroundColor: Colors.white, // 앱 바 전경색
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16), // 전체 패딩
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildQuestionHeader(), // 질문 헤더 부분 빌드
                  const SizedBox(height: 16), // 간격
                  _buildQuestionContent(), // 질문 내용 부분 빌드
                  const SizedBox(height: 24), // 간격
                  _buildAnswersList(), // 답변 목록 부분 빌드
                ],
              ),
            ),
          ),
          _buildAnswerInput(userProvider), // 답변 입력 필드 빌드
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
                        ? _currentQuestion.nickname[0]
                            .toUpperCase() // 닉네임 첫 글자 표시
                        : 'U', // 닉네임이 없으면 'U' 표시
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
                        _currentQuestion.nickname, // 작성자 닉네임
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        _formatDate(_currentQuestion.createdAt), // 작성일 포맷팅
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                // 산 태그 표시
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
                      _currentQuestion.mountain, // 산 이름
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
                Icon(
                  Icons.help_outline,
                  size: 20,
                  color: Colors.green[600],
                ), // 질문 아이콘
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _currentQuestion.title, // 질문 제목
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
              _currentQuestion.content, // 질문 내용
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                // 조회수
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
                // 좋아요 수
                Icon(Icons.favorite_border, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  '${_currentQuestion.likeCount}',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const Spacer(), // 남은 공간 채우기
                // 좋아요 버튼
                InkWell(
                  onTap: _toggleLike, // 좋아요 토글 함수 호출
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
  /// 로딩, 에러, 답변 없음 상태를 처리합니다.
  Widget _buildAnswersList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '답글 총 ${_answers.length}개', // 총 답변 개수 표시
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        // 로딩 중일 때 로딩 인디케이터
        if (_isLoading)
          const Center(child: CircularProgressIndicator())
        // 에러 발생 시 에러 메시지 및 재시도 버튼
        else if (_hasError)
          Center(
            child: Column(
              children: [
                Text('오류 발생: $_errorMessage'),
                ElevatedButton(
                  onPressed: _loadAnswers, // 다시 시도 버튼 클릭 시 답변 로드 재시도
                  child: const Text('다시 시도'),
                ),
              ],
            ),
          )
        // 답변이 없을 때 메시지
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
        // 답변 목록 표시
        else
          ListView.builder(
            shrinkWrap: true, // ListView가 Column 내에서 공간을 차지하도록 설정
            physics:
                const NeverScrollableScrollPhysics(), // ListView 자체 스크롤 비활성화 (SingleChildScrollView가 처리)
            itemCount: _answers.length, // 답변 개수만큼 아이템 생성
            itemBuilder: (context, index) {
              return _buildAnswerItem(_answers[index], index); // 각 답변 아이템 빌드
            },
          ),
      ],
    );
  }

  /// 개별 답변 항목을 표시하는 위젯입니다.
  /// 작성자 정보, 내용, 좋아요 버튼 등을 포함합니다.
  Widget _buildAnswerItem(QnaAnswer answer, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8), // 카드 간 간격
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // 작성자 아바타
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.blue[100],
                  child: Text(
                    answer.nickname.isNotEmpty
                        ? answer.nickname[0]
                            .toUpperCase() // 닉네임 첫 글자 표시
                        : 'U', // 닉네임이 없으면 'U' 표시
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[700],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  answer.nickname, // 작성자 닉네임
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _formatDate(answer.createdAt), // 작성일 포맷팅
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              answer.content, // 답변 내용
              style: const TextStyle(fontSize: 14, height: 1.4),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                // 좋아요 버튼
                InkWell(
                  onTap:
                      () => _toggleAnswerLike(answer, index), // 답변 좋아요 토글 함수 호출
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
                        '${answer.likeCount}', // 좋아요 수
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

  /// 답변 입력 필드와 등록 버튼을 포함하는 위젯입니다.
  /// 로그인 상태에 따라 입력 가능 여부가 달라집니다.
  Widget _buildAnswerInput(UserProvider userProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[300]!)), // 상단에 경계선
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _answerController, // 답변 입력 컨트롤러 연결
              decoration: InputDecoration(
                // 로그인 상태에 따라 힌트 텍스트 변경
                hintText:
                    userProvider.isLoggedIn
                        ? '답변을 입력하세요...'
                        : '로그인 후 사용할 수 있어요',
                border: const OutlineInputBorder(), // 테두리 스타일
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              maxLines: null, // 여러 줄 입력 가능
              enabled: userProvider.isLoggedIn, // 로그인 상태에 따라 입력 활성화/비활성화
            ),
          ),
          const SizedBox(width: 8), // 간격
          // 답변 등록 버튼
          ElevatedButton(
            onPressed:
                userProvider.isLoggedIn && !_isSubmitting
                    ? _submitAnswer // 로그인되어 있고 제출 중이 아니면 _submitAnswer 호출
                    : null, // 그렇지 않으면 버튼 비활성화
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green, // 버튼 배경색
              foregroundColor: Colors.white, // 버튼 전경색
            ),
            child:
                _isSubmitting
                    ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.white,
                        ), // 로딩 인디케이터 색상
                      ),
                    )
                    : const Text('등록'), // 로딩 중이 아니면 '등록' 텍스트 표시
          ),
        ],
      ),
    );
  }
}
