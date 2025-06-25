import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trekkit_flutter/functions/jh/userprovider.dart';
import 'package:trekkit_flutter/models/jw/QnaQuestion.dart';
import 'package:trekkit_flutter/services/jw/QnaService.dart';
import 'package:trekkit_flutter/pages/jh/Login_and_Signup/login.dart'; // 로그인 페이지 임포트

/// Q&A 질문 작성 또는 수정을 위한 StatefulWidget입니다.
/// [question] 파라미터가 제공되면 '수정 모드'로, 없으면 '작성 모드'로 동작합니다.
class QnAWriting extends StatefulWidget {
  final QnaQuestion? question; // 수정을 위한 선택적 QnaQuestion 객체

  const QnAWriting({super.key, this.question});

  @override
  State<QnAWriting> createState() => _QnAWritingState();
}

/// QnAWriting 페이지의 상태를 관리하는 State 클래스입니다.
/// 질문 제목과 내용 입력, 산 선택, 질문 제출 로직을 담당합니다.
class _QnAWritingState extends State<QnAWriting> {
  final TextEditingController _titleController =
      TextEditingController(); // 질문 제목 입력 컨트롤러
  final TextEditingController _contentController =
      TextEditingController(); // 질문 내용 입력 컨트롤러

  String? _selectedMountain; // 사용자가 선택한 산 이름
  bool _isSubmitting = false; // 질문 제출(작성/수정) 중인지 여부
  bool _isEditMode = false; // 수정 모드 여부

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
    '관악산',
  ];

  @override
  void initState() {
    super.initState();
    // 위젯에 question 데이터가 전달되면 수정 모드로 초기화합니다.
    if (widget.question != null) {
      _isEditMode = true; // 수정 모드 활성화
      _titleController.text = widget.question!.title;
      _contentController.text = widget.question!.content;

      // _selectedMountain 초기화 시 _mountainOptions에 해당 산이 있는지 확인
      if (_mountainOptions.contains(widget.question!.mountain)) {
        _selectedMountain = widget.question!.mountain;
      } else {
        // 기존 질문의 산이 옵션에 없다면 null로 설정하여 '선택 안함' 힌트가 보이도록 함
        _selectedMountain = null;
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose(); // 컨트롤러 dispose
    _contentController.dispose(); // 컨트롤러 dispose
    super.dispose();
  }

  /// 질문 제출 버튼이 눌렸을 때 호출되는 함수입니다.
  /// 입력 유효성 검사, 사용자 로그인 상태 확인 후, Q&A 질문 생성/수정 API를 호출합니다.
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

    // 2. UserProvider에서 사용자 정보 가져오기
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    // 3. 로그인 상태 및 사용자 ID 유효성 확인
    if (!userProvider.isLoggedIn || userProvider.index == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('로그인이 필요합니다. 다시 로그인해주세요.')));
      // 로그인 필요 시 로그인 페이지로 이동하거나, 상위 위젯에서 로그인 여부를 확인하도록 할 수 있습니다.
      // 여기서는 단순히 메시지를 띄우고 함수를 종료합니다.
      return;
    }

    setState(() {
      _isSubmitting = true; // 제출 중 상태로 변경하여 로딩 인디케이터 표시
    });

    try {
      if (_isEditMode) {
        // 수정 모드: 기존 질문 업데이트
        final updatedQuestion = QnaQuestion(
          id: widget.question!.id, // 기존 질문의 ID 사용
          userId: widget.question!.userId, // 작성자는 변경 불가
          nickname: widget.question!.nickname, // 닉네임 변경 불가
          title: _titleController.text.trim(),
          content: _contentController.text.trim(),
          mountain: _selectedMountain ?? '', // 선택된 산 (선택 안함 시 빈 문자열)
          imagePaths: widget.question!.imagePaths, // 기존 이미지 경로 유지
          viewCount: widget.question!.viewCount,
          answerCount: widget.question!.answerCount,
          likeCount: widget.question!.likeCount,
          isSolved: widget.question!.isSolved,
          createdAt: widget.question!.createdAt, // 생성일 변경 불가
        );
        // QnaService를 통해 질문 업데이트 API 호출
        await QnaService.updateQuestion(updatedQuestion, context);
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('질문이 성공적으로 수정되었습니다.')));
          Navigator.pop(context, true); // 수정 성공 시 true 반환 (이전 화면 갱신 유도)
        }
      } else {
        // 작성 모드: 새로운 질문 생성
        final question = QnaQuestion(
          id: 0, // ID는 서버에서 자동 생성되므로 임시값
          userId: userProvider.index!, // 사용자 고유 ID (int 타입)
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

        // QnaService를 통해 질문 생성 API 호출
        await QnaService.createQuestion(question, context);

        // 질문 작성 성공 시 스낵바 표시 및 이전 화면으로 이동
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('질문이 등록되었습니다')));
          Navigator.pop(context, true); // 성공 시 이전 페이지로 돌아가면서 true 반환 (성공 알림)
        }
      }
    } catch (e) {
      // 오류 발생 시 스낵바 표시
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('질문 ${_isEditMode ? '수정' : '등록'} 실패: $e'),
            duration: const Duration(seconds: 5), // 에러 메시지를 더 오래 표시
          ),
        );
      }
    } finally {
      // 제출 상태 초기화 (로딩 인디케이터 숨김)
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    // 로그인 상태에 따른 조건부 UI: 로그인되어 있지 않으면 로그인 요청 화면 표시
    if (!userProvider.isLoggedIn) {
      return Scaffold(
        appBar: AppBar(
          title: Text(_isEditMode ? '질문 수정' : '질문하기'), // 모드에 따라 제목 변경
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginPage(),
                    ), // 실제 로그인 페이지 위젯으로 대체
                  );
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

    // 로그인된 경우 Q&A 질문 작성/수정 UI 반환
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? '질문 수정' : '질문하기'), // 앱 바 제목
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
                    : Text(
                      _isEditMode ? '수정 완료' : '등록', // 버튼 텍스트 변경
                      style: const TextStyle(
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
            // 산 선택 드롭다운
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: '산 선택 (선택사항)',
                border: OutlineInputBorder(),
              ),
              // value를 사용하고, _selectedMountain이 null일 때 빈 문자열로 표시
              initialValue: _selectedMountain ?? '',
              items: [
                const DropdownMenuItem<String>(
                  value: '', // '선택 안함'의 실제 값은 빈 문자열로 처리
                  child: Text('선택 안함'),
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
                  _selectedMountain =
                      value == '' ? null : value; // 빈 문자열일 때 null로 설정
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
