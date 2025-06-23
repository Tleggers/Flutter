import 'package:flutter/material.dart'; // Flutter UI 구성 요소를 위한 핵심 패키지
import 'package:provider/provider.dart'; // 상태 관리를 위한 Provider 패키지
import 'package:trekkit_flutter/functions/jh/userprovider.dart'; // 사용자 로그인 상태 및 정보 관리를 위한 UserProvider 임포트
import 'package:trekkit_flutter/models/jw/QnaQuestion.dart'; // Q&A 질문 데이터 모델인 QnaQuestion 임포트
import 'package:trekkit_flutter/services/jw/QnaService.dart'; // Q&A 관련 API 호출을 위한 QnaService 임포트
// 로그인 페이지 임포트 (로그인 필요 시 이동)

/// Q&A 질문 작성 페이지를 담당하는 StatefulWidget입니다.
/// 사용자가 질문의 제목, 내용, 그리고 관련 산을 선택하여 새로운 Q&A 질문을 작성할 수 있도록 합니다.
class QnAWriting extends StatefulWidget {
  const QnAWriting({super.key});

  @override
  State<QnAWriting> createState() => _QnAWritingState();
}

/// QnAWriting 페이지의 상태를 관리하는 State 클래스입니다.
/// 질문 제목과 내용 입력, 산 선택, 질문 제출 로직을 담당합니다.
class _QnAWritingState extends State<QnAWriting> {
  // 질문 제목과 내용을 위한 TextEditingController
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  String? _selectedMountain; // 사용자가 선택한 산 이름
  bool _isSubmitting = false; // 질문 제출(작성) 중인지 여부를 나타내는 플래그

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

  @override
  void dispose() {
    // 위젯이 dispose될 때 컨트롤러들을 dispose하여 리소스 누수 방지
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  /// 질문 제출 버튼이 눌렸을 때 호출되는 함수입니다.
  /// 입력 유효성 검사, 사용자 로그인 상태 확인 후, Q&A 질문 생성 API를 호출합니다.
  Future<void> _submitQuestion() async {
    // 1. 입력 유효성 검사 (제목과 내용 필수)
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('제목을 입력해주세요')));
      return;
    }

    if (_contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('내용을 입력해주세요')));
      return;
    }

    // 2. UserProvider에서 사용자 정보 가져오기 (listen: false로 불필요한 리빌드 방지)
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    // 3. 로그인 상태 및 사용자 ID 유효성 확인
    if (!userProvider.isLoggedIn || userProvider.index == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('로그인이 필요합니다. 다시 로그인해주세요.')));
      // 로그인 페이지로 이동하기 전에 현재 페이지를 닫음 (경로 스택 관리)
      Navigator.pop(context);
      return;
    }

    setState(() {
      _isSubmitting = true; // 제출 중 상태로 변경하여 로딩 인디케이터 표시
    });

    try {
      // 4. QnaQuestion 모델 객체 생성
      final question = QnaQuestion(
        id: 0, // ID는 서버에서 자동 생성되므로 임시값
        userId: userProvider.index!, // 사용자 ID (int 타입)
        nickname: userProvider.nickname ?? '익명', // 사용자 닉네임, 없으면 '익명'
        title: _titleController.text.trim(), // 질문 제목
        content: _contentController.text.trim(), // 질문 내용
        mountain: _selectedMountain ?? '', // 선택된 산 (선택 안함 시 빈 문자열)
        imagePaths: [], // Q&A 질문은 이미지를 첨부하지 않으므로 빈 리스트
        viewCount: 0, // 초기 조회수 (서버에서 초기화될 값)
        answerCount: 0, // 초기 답변 수 (서버에서 초기화될 값)
        likeCount: 0, // 초기 좋아요 수 (서버에서 초기화될 값)
        isSolved: false, // 초기 해결 여부 (서버에서 초기화될 값)
        createdAt: DateTime.now(), // 현재 시간으로 생성일 설정
      );

      // 5. 디버깅을 위해 전송할 데이터 출력 (개발 단계에서 유용)
      print('=== 질문 등록 데이터 ===');
      print('userId: ${question.userId}');
      print('nickname: ${question.nickname}');
      print('title: ${question.title}');
      print('content: ${question.content}');
      print('mountain: ${question.mountain}');
      print(
        'token: ${userProvider.token?.substring(0, 20)}...',
      ); // 토큰 일부만 출력 (보안)
      print('=====================');

      // 6. QnaService를 통해 질문 생성 API 호출
      await QnaService.createQuestion(question, context); // context 전달

      // 7. 질문 작성 성공 시 스낵바 표시 및 이전 화면으로 이동
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('질문이 등록되었습니다')));
        Navigator.pop(context, true); // 성공 시 이전 페이지로 돌아가면서 true 반환 (성공 알림)
      }
    } catch (e) {
      // 8. 오류 발생 시 자세한 에러 정보 출력 및 스낵바 표시
      print('=== 질문 등록 에러 ===');
      print('Error: $e');
      print('Error type: ${e.runtimeType}');
      print('==================');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('질문 등록 실패: $e'),
            duration: const Duration(seconds: 5), // 에러 메시지를 더 오래 표시
          ),
        );
      }
    } finally {
      // 9. 제출 상태 초기화 (로딩 인디케이터 숨김)
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // UserProvider 인스턴스 가져오기
    final userProvider = Provider.of<UserProvider>(context);

    // 로그인 상태에 따른 조건부 UI: 로그인되어 있지 않으면 로그인 요청 화면 표시
    if (!userProvider.isLoggedIn) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('질문하기'),
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '로그인이 필요합니다',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // 로그인 페이지로 이동
                  Navigator.pushNamed(context, '/login');
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: const Text(
                  '로그인하기',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // 로그인된 경우 Q&A 질문 작성 UI 반환
    return Scaffold(
      appBar: AppBar(
        title: const Text('질문하기'), // 앱 바 제목
        backgroundColor: Colors.green, // 앱 바 배경색
        foregroundColor: Colors.white, // 앱 바 전경색
        actions: [
          // 제출 버튼 (제출 중일 때는 로딩 인디케이터 표시)
          TextButton(
            onPressed: _isSubmitting ? null : _submitQuestion, // 제출 중이면 버튼 비활성화
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
                    : const Text(
                      '등록',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16), // 전체 패딩
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 로그인 상태 표시 (디버깅 및 사용자 피드백용)
            Container(
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color:
                    userProvider.isLoggedIn
                        ? Colors.green[50]
                        : Colors.red[50], // 로그인 상태에 따라 배경색 변경
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  Icon(
                    userProvider.isLoggedIn
                        ? Icons.check_circle
                        : Icons.error, // 아이콘 변경
                    size: 16,
                    color: userProvider.isLoggedIn ? Colors.green : Colors.red,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      userProvider.isLoggedIn
                          ? '로그인 상태: ${userProvider.nickname} (ID: ${userProvider.index})\n토큰: ${userProvider.token?.substring(0, 20)}...' // 로그인 정보 표시
                          : '로그인이 필요합니다', // 비로그인 메시지
                      style: TextStyle(
                        fontSize: 12,
                        color:
                            userProvider.isLoggedIn
                                ? Colors.green[800]
                                : Colors.red[800],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 산 선택 드롭다운
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: '산 선택 (선택사항)',
                border: OutlineInputBorder(),
              ),
              value: _selectedMountain, // 현재 선택된 산
              items: [
                const DropdownMenuItem<String>(
                  value: null,
                  child: Text('선택 안함'), // '선택 안함' 옵션
                ),
                ..._mountainOptions.map((mountain) {
                  return DropdownMenuItem<String>(
                    value: mountain,
                    child: Text(mountain),
                  );
                }),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedMountain = value; // 선택된 산 업데이트
                });
              },
            ),

            const SizedBox(height: 16), // 간격
            // 제목 입력 필드
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: '제목',
                border: OutlineInputBorder(),
                hintText: '질문의 제목을 입력해주세요',
              ),
              maxLength: 100, // 최대 100자 제한
            ),

            const SizedBox(height: 16), // 간격
            // 내용 입력 필드 (확장 가능)
            Expanded(
              child: TextField(
                controller: _contentController,
                decoration: const InputDecoration(
                  labelText: '내용',
                  border: OutlineInputBorder(),
                  hintText: '궁금한 내용을 자세히 적어주세요',
                  alignLabelWithHint: true, // 힌트 텍스트를 위로 정렬 (멀티라인 입력 시 유용)
                ),
                maxLines: null, // 여러 줄 입력 가능
                expands: true, // 부모 위젯의 남은 공간을 채우도록 확장
                textAlignVertical: TextAlignVertical.top, // 텍스트를 상단에 정렬
              ),
            ),

            const SizedBox(height: 16), // 간격
            // 안내 텍스트 컨테이너
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green[50], // 연한 녹색 배경
                borderRadius: BorderRadius.circular(8), // 모서리 둥글게
                border: Border.all(color: Colors.green[200]!), // 테두리
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.green[600],
                    size: 20,
                  ), // 정보 아이콘
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '등산과 관련된 질문을 올려주세요. 다른 등산러들이 도움을 드릴 수 있습니다.',
                      style: TextStyle(fontSize: 12, color: Colors.green[700]),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
