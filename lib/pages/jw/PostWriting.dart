import 'package:flutter/material.dart'; // Flutter UI 구성 요소를 위한 핵심 패키지
import 'package:provider/provider.dart'; // 상태 관리를 위한 Provider 패키지
import 'package:trekkit_flutter/functions/jh/userprovider.dart'; // 사용자 로그인 상태 및 정보 관리를 위한 UserProvider 임포트
import 'package:image_picker/image_picker.dart'; // 이미지 갤러리/카메라 접근을 위한 image_picker 패키지
import 'dart:io'; // 파일 시스템 상호작용을 위한 dart:io 패키지
import 'package:trekkit_flutter/models/jw/Post.dart'; // 게시글 데이터 모델인 Post 임포트
import 'package:trekkit_flutter/services/jw/PostService.dart'; // 게시글 관련 API 호출을 위한 PostService 임포트

/// 게시글 작성 페이지를 담당하는 StatefulWidget입니다.
/// 사용자가 제목, 내용, 산을 선택하고 이미지를 첨부하여 게시글을 작성할 수 있도록 합니다.
class PostWriting extends StatefulWidget {
  const PostWriting({super.key});

  @override
  State<PostWriting> createState() => _PostWritingState();
}

/// PostWriting 페이지의 상태를 관리하는 State 클래스입니다.
/// 게시글 입력 필드 관리, 이미지 선택 및 미리보기, 게시글 제출 로직을 담당합니다.
class _PostWritingState extends State<PostWriting> {
  String? _selectedMountain; // 사용자가 선택한 산 이름
  List<XFile> _images = []; // ImagePicker를 통해 선택된 이미지 파일 목록 (최대 5장)
  List<String> _uploadedImagePaths = []; // 서버에 업로드된 이미지 URL 경로 목록

  // 게시글 제목과 내용을 위한 TextEditingController
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  bool _isSubmitting = false; // 게시글 제출(작성) 중인지 여부를 나타내는 플래그

  // 드롭다운에 표시될 산 목록 (데이터베이스에 있는 산 기준)
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

  /// 산 선택 드롭다운 값이 변경될 때 호출됩니다.
  void _selectMountain(String? mountain) {
    setState(() {
      _selectedMountain = mountain; // 선택된 산 업데이트
    });
  }

  /// 갤러리 또는 카메라에서 이미지를 선택하는 기능을 수행합니다.
  /// 선택된 이미지는 [_images] 리스트에 추가되며, 최대 5장으로 제한됩니다.
  Future<void> _pickImages() async {
    final ImagePicker picker = ImagePicker();
    // 여러 이미지 선택
    final List<XFile> picked = await picker.pickMultiImage();

    setState(() {
      // 선택된 이미지 중 최대 5장까지만 저장
      _images = (picked.length > 5) ? picked.sublist(0, 5) : picked;
    });
  }

  /// 선택된 이미지 목록에서 특정 인덱스의 이미지를 제거합니다.
  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index); // 이미지 리스트에서 해당 이미지 제거
    });
  }

  /// 선택된 이미지들을 서버에 업로드하고, 업로드된 이미지 경로를 [_uploadedImagePaths]에 저장합니다.
  Future<void> _uploadImages() async {
    if (_images.isEmpty) {
      _uploadedImagePaths = []; // 이미지가 없으면 빈 리스트로 초기화
      return;
    }

    try {
      // PostService를 사용하여 이미지 업로드 호출
      final imagePaths = await PostService.uploadImages(
        _images
            .map((xfile) => File(xfile.path))
            .toList(), // XFile을 File 타입으로 변환하여 전달
        context, // context 전달
      );
      _uploadedImagePaths = imagePaths; // 업로드된 이미지 경로 저장
    } catch (e) {
      // 이미지 업로드 실패 시 예외 발생
      throw Exception('이미지 업로드 실패: $e');
    }
  }

  /// 게시글 제출 버튼이 눌렸을 때 호출되는 함수입니다.
  /// 로그인 상태 및 입력 유효성 검사 후, 이미지 업로드 및 게시글 생성을 처리합니다.
  Future<void> _submitPost() async {
    // UserProvider를 통해 사용자 로그인 상태 가져오기 (listen: false로 불필요한 리빌드 방지)
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    // 1. 로그인 상태 확인
    if (!userProvider.isLoggedIn) {
      _showErrorSnackBar('로그인이 필요합니다.');
      return;
    }

    // 2. 입력 유효성 검사
    if (_selectedMountain == null || _selectedMountain!.isEmpty) {
      _showErrorSnackBar('산을 선택해주세요.');
      return;
    }

    if (_contentController.text.trim().isEmpty) {
      _showErrorSnackBar('내용을 입력해주세요.');
      return;
    }

    setState(() {
      _isSubmitting = true; // 제출 중 상태로 변경
    });

    try {
      // 3. 이미지 업로드 (선택된 이미지가 있을 경우)
      await _uploadImages();

      // 4. Post 모델 객체 생성
      final post = Post(
        nickname:
            userProvider.nickname ?? 'Unknown', // 사용자 닉네임 사용, 없으면 'Unknown'
        // Post 모델에 userId 필드가 있다면 여기 추가 (예: userId: userProvider.index,)
        title:
            _titleController.text.trim().isEmpty
                ? null // 제목이 비어있으면 null로 설정
                : _titleController.text.trim(),
        mountain: _selectedMountain!, // 선택된 산 (필수)
        content: _contentController.text.trim(), // 내용 (필수)
        imagePaths: _uploadedImagePaths, // 업로드된 이미지 경로 목록
        createdAt: DateTime.now(), // 현재 시간으로 생성일 설정
      );

      // 5. PostService를 통해 게시글 생성 API 호출
      await PostService.createPost(post, context); // context 전달

      // 6. 게시글 작성 성공 시 스낵바 표시 및 이전 화면으로 이동
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('게시글이 성공적으로 작성되었습니다.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // 이전 화면으로 돌아가면서 true 반환 (성공 알림)
      }
    } catch (e) {
      // 7. 오류 발생 시 스낵바 표시
      if (mounted) {
        _showErrorSnackBar('게시글 작성 실패: $e');
      }
    } finally {
      // 8. 제출 상태 초기화 (로딩 인디케이터 숨김)
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  /// 오류 메시지를 표시하는 스낵바를 띄웁니다.
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final userProvider = Provider.of<UserProvider>(
      context,
    ); // UserProvider 가져오기

    // 사용자가 로그인되어 있지 않으면 로그인 요청 UI 반환
    if (!userProvider.isLoggedIn) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('글쓰기'),
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

    // 로그인된 경우 게시글 작성 UI 반환
    return Scaffold(
      appBar: AppBar(
        title: const Text('글쓰기'), // 앱 바 제목
        backgroundColor: Colors.green, // 앱 바 배경색
        foregroundColor: Colors.white, // 앱 바 전경색
        actions: [
          // 게시글 제출 중일 때 로딩 인디케이터 표시
          if (_isSubmitting)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ),
              ),
            )
          else
            // 제출 버튼
            TextButton(
              onPressed: _submitPost, // 제출 버튼 클릭 시 _submitPost 함수 호출
              child: const Text(
                '완료',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(screenWidth * 0.05), // 반응형 패딩
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // 내용을 왼쪽 정렬
          children: [
            // 제목 입력 필드 (선택사항)
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                hintText: '제목 (선택사항)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.title),
              ),
              maxLines: 1, // 한 줄로 제한
            ),

            const SizedBox(height: 16), // 간격
            // 산 선택 드롭다운 필드
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: '산 선택 *', // 필수 항목 표시
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.landscape),
              ),
              value: _selectedMountain, // 현재 선택된 산
              items:
                  _mountainOptions.map((mountain) {
                    return DropdownMenuItem<String>(
                      value: mountain,
                      child: Text(mountain),
                    );
                  }).toList(),
              onChanged: _selectMountain, // 값 변경 시 _selectMountain 호출
              validator: (value) {
                // 유효성 검사: 산이 선택되지 않았으면 메시지 반환
                if (value == null || value.isEmpty) {
                  return '산을 선택해주세요.';
                }
                return null; // 유효성 통과
              },
            ),

            const SizedBox(height: 16), // 간격
            // 내용 입력 필드
            TextField(
              controller: _contentController,
              decoration: const InputDecoration(
                hintText: '등산 후기나 경험을 공유해주세요 *', // 필수 항목 표시
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.edit),
                alignLabelWithHint: true, // 힌트 텍스트를 위로 정렬 (멀티라인 입력 시 유용)
              ),
              maxLines: 8, // 여러 줄 입력 가능
            ),

            const SizedBox(height: 20), // 간격
            // 이미지 선택 섹션
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.photo_camera, color: Colors.green),
                        const SizedBox(width: 8),
                        const Text(
                          '사진 추가',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(), // 남은 공간 채우기
                        // 사진 선택 버튼
                        OutlinedButton.icon(
                          onPressed: _pickImages, // _pickImages 함수 호출
                          icon: const Icon(Icons.add_photo_alternate),
                          label: Text(
                            '사진 선택 (${_images.length}/5)',
                          ), // 현재 선택된 이미지 수 표시
                        ),
                      ],
                    ),

                    // 선택된 이미지가 있을 경우 미리보기 표시
                    if (_images.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 100, // 이미지 미리보기 목록의 높이
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal, // 수평 스크롤
                          itemCount: _images.length, // 이미지 개수만큼 아이템 생성
                          itemBuilder: (context, index) {
                            return Container(
                              margin: const EdgeInsets.only(right: 8),
                              child: Stack(
                                children: [
                                  // 이미지 미리보기
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(
                                      8,
                                    ), // 모서리 둥글게
                                    child: Image.file(
                                      File(
                                        _images[index].path,
                                      ), // 선택된 이미지 파일 표시
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  // 이미지 제거 버튼
                                  Positioned(
                                    top: 4,
                                    right: 4,
                                    child: GestureDetector(
                                      onTap:
                                          () => _removeImage(
                                            index,
                                          ), // 이미지 제거 함수 호출
                                      child: Container(
                                        decoration: const BoxDecoration(
                                          color: Colors.black54,
                                          shape: BoxShape.circle,
                                        ),
                                        padding: const EdgeInsets.all(4),
                                        child: const Icon(
                                          Icons.close,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24), // 간격
            // 작성 가이드 섹션
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green[50], // 연한 녹색 배경
                borderRadius: BorderRadius.circular(12), // 모서리 둥글게
                border: Border.all(color: Colors.green[200]!), // 테두리
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.green[700]),
                      const SizedBox(width: 8),
                      Text(
                        '작성 가이드',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.green[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8), // 간격
                  Text(
                    // 작성 가이드 내용
                    '• 등산 경험이나 후기를 자유롭게 공유해주세요\n'
                    '• 사진은 최대 5장까지 첨부 가능합니다\n'
                    '• 다른 등산객들에게 도움이 되는 정보를 포함해주세요\n'
                    '• 안전한 등산 문화를 만들어가요',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.green[600],
                      height: 1.4,
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
