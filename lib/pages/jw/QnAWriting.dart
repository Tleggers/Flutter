import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trekkit_flutter/functions/jh/userprovider.dart';
import 'package:trekkit_flutter/services/jw/QnaService.dart';
import 'package:trekkit_flutter/models/jw/QnaQuestion.dart';

class QnAWriting extends StatefulWidget {
  const QnAWriting({super.key});

  @override
  State<QnAWriting> createState() => _QnAWritingState();
}

class _QnAWritingState extends State<QnAWriting> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  String? _selectedMountain;
  bool _isSubmitting = false;

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

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _submitQuestion() async {
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

    // UserProvider에서 사용자 정보 가져오기
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    // 로그인 상태 확인
    if (!userProvider.isLoggedIn || userProvider.index == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('로그인이 필요합니다. 다시 로그인해주세요.')));
      Navigator.pop(context);
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final question = QnaQuestion(
        id: 0,
        userId: userProvider.index!.toString(), // int를 String으로 변환
        nickname: userProvider.nickname ?? '익명',
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        mountain: _selectedMountain ?? '',
        imagePaths: [],
        viewCount: 0,
        answerCount: 0,
        likeCount: 0,
        isSolved: false,
        createdAt: DateTime.now(),
      );

      // 디버깅: 전송할 데이터 출력
      print('=== 질문 등록 데이터 ===');
      print('userId: ${question.userId}');
      print('nickname: ${question.nickname}');
      print('title: ${question.title}');
      print('content: ${question.content}');
      print('mountain: ${question.mountain}');
      print('token: ${userProvider.token}');
      print('=====================');

      await QnaService.createQuestion(question, userProvider.token!);

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('질문이 등록되었습니다')));
        Navigator.pop(context, true);
      }
    } catch (e) {
      // 더 자세한 에러 정보 출력
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('질문하기'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: _isSubmitting ? null : _submitQuestion,
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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 로그인 상태 표시 (디버깅용)
            Container(
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color:
                    userProvider.isLoggedIn ? Colors.green[50] : Colors.red[50],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  Icon(
                    userProvider.isLoggedIn ? Icons.check_circle : Icons.error,
                    size: 16,
                    color: userProvider.isLoggedIn ? Colors.green : Colors.red,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      userProvider.isLoggedIn
                          ? '로그인 상태: ${userProvider.nickname} (ID: ${userProvider.index})\n토큰: ${userProvider.token?.substring(0, 20)}...'
                          : '로그인이 필요합니다',
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

            // 산 선택
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: '산 선택 (선택사항)',
                border: OutlineInputBorder(),
              ),
              value: _selectedMountain,
              items: [
                const DropdownMenuItem<String>(
                  value: null,
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
                  _selectedMountain = value;
                });
              },
            ),

            const SizedBox(height: 16),

            // 제목 입력
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: '제목',
                border: OutlineInputBorder(),
                hintText: '질문의 제목을 입력해주세요',
              ),
              maxLength: 100,
            ),

            const SizedBox(height: 16),

            // 내용 입력
            Expanded(
              child: TextField(
                controller: _contentController,
                decoration: const InputDecoration(
                  labelText: '내용',
                  border: OutlineInputBorder(),
                  hintText: '궁금한 내용을 자세히 적어주세요',
                  alignLabelWithHint: true,
                ),
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
              ),
            ),

            const SizedBox(height: 16),

            // 안내 텍스트
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.green[600], size: 20),
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
