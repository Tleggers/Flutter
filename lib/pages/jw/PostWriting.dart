import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trekkit_flutter/functions/jh/userprovider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:trekkit_flutter/models/jw/Post.dart';
import 'package:trekkit_flutter/services/jw/PostService.dart';

/// 게시글 작성 또는 수정을 위한 StatefulWidget입니다.
/// [post] 파라미터가 제공되면 '수정 모드'로, 없으면 '작성 모드'로 동작합니다.
class PostWriting extends StatefulWidget {
  final Post? post; // 수정을 위한 선택적 Post 객체

  const PostWriting({super.key, this.post});

  @override
  State<PostWriting> createState() => _PostWritingState();
}

/// PostWriting 페이지의 상태를 관리하는 State 클래스입니다.
/// 게시글 제목, 내용, 산 선택, 이미지 첨부, 제출 로직을 담당합니다.
class _PostWritingState extends State<PostWriting> {
  String? _selectedMountain; // 사용자가 선택한 산 이름
  List<XFile> _images = []; // 선택된 이미지 파일 목록
  List<String> _uploadedImagePaths = []; // 업로드된 이미지 경로 목록
  final TextEditingController _titleController =
      TextEditingController(); // 제목 입력 필드 컨트롤러
  final TextEditingController _contentController =
      TextEditingController(); // 내용 입력 필드 컨트롤러
  bool _isSubmitting = false; // 게시글 제출 중 여부
  bool _isEditMode = false; // 수정 모드 여부

  // TODO: 실제 앱에서는 서버나 파일에서 산 목록을 비동기적으로 불러오는 것이 좋습니다.
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
    // 위젯에 post 데이터가 전달되면 수정 모드로 초기화합니다.
    if (widget.post != null) {
      _isEditMode = true;
      _titleController.text = widget.post!.title ?? '';
      _contentController.text = widget.post!.content;
      // _selectedMountain이 _mountainOptions에 포함된 값인지 확인 후 할당합니다.
      if (_mountainOptions.contains(widget.post!.mountain)) {
        _selectedMountain = widget.post!.mountain;
      } else {
        // 만약 기존 post의 산이 목록에 없으면 null로 초기화하여 '산 선택 *' 힌트가 보이도록 합니다.
        _selectedMountain = null;
      }
      // TODO: 기존 이미지를 표시하고 관리하는 로직 추가 필요
      // 현재는 텍스트 데이터만 채워지며, 이미지 수정 시 새로 선택해야 합니다.
    }
  }

  @override
  void dispose() {
    _titleController.dispose(); // 제목 입력 컨트롤러 dispose
    _contentController.dispose(); // 내용 입력 컨트롤러 dispose
    super.dispose();
  }

  /// 갤러리에서 이미지를 선택하는 기능을 수행합니다.
  /// 최대 5장까지 선택 가능하도록 제한합니다.
  Future<void> _pickImages() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> picked = await picker.pickMultiImage();
    if (picked.length > 5) {
      _showErrorSnackBar('사진은 최대 5장까지 선택할 수 있습니다.');
    }
    setState(() {
      _images =
          (picked.length > 5) ? picked.sublist(0, 5) : picked; // 5장 초과 시 자름
    });
  }

  /// 선택된 이미지 목록에서 특정 이미지를 제거합니다.
  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }

  /// 선택된 이미지들을 서버에 업로드합니다.
  /// 업로드된 이미지들의 경로를 [_uploadedImagePaths]에 저장합니다.
  Future<void> _uploadImages() async {
    if (_images.isEmpty) {
      _uploadedImagePaths = []; // 이미지가 없으면 경로 목록 초기화
      return;
    }
    try {
      _uploadedImagePaths = await PostService.uploadImages(
        _images
            .map((xfile) => File(xfile.path))
            .toList(), // XFile을 File로 변환하여 전달
        context,
      );
    } catch (e) {
      throw Exception('이미지 업로드 실패: $e');
    }
  }

  /// 게시글을 서버에 제출(작성 또는 수정)합니다.
  /// 입력 유효성 검사, 사용자 로그인 상태 확인, 이미지 업로드 후 API를 호출합니다.
  Future<void> _submitPost() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    // 로그인 확인
    if (!userProvider.isLoggedIn) {
      _showErrorSnackBar('로그인이 필요합니다.');
      return;
    }
    // 산 선택 확인
    if (_selectedMountain == null || _selectedMountain!.isEmpty) {
      _showErrorSnackBar('산을 선택해주세요.');
      return;
    }
    // 내용 입력 확인
    if (_contentController.text.trim().isEmpty) {
      _showErrorSnackBar('내용을 입력해주세요.');
      return;
    }

    setState(() => _isSubmitting = true); // 제출 중 상태 시작

    try {
      // 이미지가 새로 선택된 경우에만 업로드합니다.
      await _uploadImages();

      // 수정 모드와 작성 모드를 분기하여 처리합니다.
      if (_isEditMode) {
        // [수정 로직] 기존 게시글 업데이트
        final updatedPost = Post(
          id: widget.post!.id, // 기존 ID 사용
          nickname: widget.post!.nickname,
          userId: widget.post!.userId,
          title:
              _titleController.text.trim().isEmpty
                  ? null
                  : _titleController.text.trim(),
          mountain: _selectedMountain!,
          content: _contentController.text.trim(),
          imagePaths:
              _uploadedImagePaths.isNotEmpty
                  ? _uploadedImagePaths // 새 이미지가 있으면 새 경로 사용
                  : widget.post!.imagePaths, // 새 이미지가 없으면 기존 이미지 경로 유지
          createdAt: widget.post!.createdAt,
        );
        await PostService.updatePost(updatedPost, context);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('게시글이 성공적으로 수정되었습니다.'),
              backgroundColor: Colors.green,
            ),
          );
          // 수정 성공 후, 이전 화면(상세보기)으로 true 값을 두 번 보내 목록까지 갱신
          Navigator.pop(context, true);
        }
      } else {
        // [작성 로직] 새로운 게시글 생성
        final post = Post(
          nickname: userProvider.nickname ?? 'Unknown',
          userId: userProvider.index, // 현재 로그인된 사용자 고유 ID
          title:
              _titleController.text.trim().isEmpty
                  ? null
                  : _titleController.text.trim(),
          mountain: _selectedMountain!,
          content: _contentController.text.trim(),
          imagePaths: _uploadedImagePaths,
          createdAt: DateTime.now(),
        );
        await PostService.createPost(post, context);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('게시글이 성공적으로 작성되었습니다.'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('처리 실패: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false); // 제출 중 상태 종료
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
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? '글 수정' : '글쓰기'), // 모드에 따라 앱 바 제목 변경
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          // 제출 중일 때 로딩 인디케이터 표시, 아니면 '완료' 버튼 표시
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
            TextButton(
              onPressed: _submitPost, // 게시글 제출 함수 호출
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
        padding: const EdgeInsets.all(16.0), // 전체 패딩
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 제목 입력 필드
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                hintText: '제목 (선택사항)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            // 산 선택 드롭다운 필드
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: '산 선택 *', // 필수 입력 표시
                border: OutlineInputBorder(),
              ),
              value: _selectedMountain, // 현재 선택된 산
              items:
                  _mountainOptions.map((mountain) {
                    return DropdownMenuItem<String>(
                      value: mountain,
                      child: Text(mountain),
                    );
                  }).toList(),
              onChanged:
                  (value) => setState(
                    () => _selectedMountain = value,
                  ), // 값 변경 시 상태 업데이트
            ),
            const SizedBox(height: 16),
            // 내용 입력 필드
            TextField(
              controller: _contentController,
              decoration: const InputDecoration(
                hintText: '등산 후기나 경험을 공유해주세요 *', // 필수 입력 표시
                border: OutlineInputBorder(),
              ),
              maxLines: 8, // 최대 8줄까지 표시
            ),
            const SizedBox(height: 20),
            // 이미지 선택 UI 영역
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
                        const Spacer(),
                        OutlinedButton.icon(
                          onPressed: _pickImages, // 이미지 선택 함수 호출
                          icon: const Icon(Icons.add_photo_alternate),
                          label: Text(
                            '사진 선택 (${_images.length}/5)',
                          ), // 현재 선택된 이미지 수 표시
                        ),
                      ],
                    ),
                    if (_images.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      // 선택된 이미지 미리보기 목록 (가로 스크롤)
                      SizedBox(
                        height: 100,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _images.length,
                          itemBuilder: (context, index) {
                            return Container(
                              margin: const EdgeInsets.only(right: 8),
                              child: Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.file(
                                      File(_images[index].path), // 이미지 파일 표시
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Positioned(
                                    top: 4,
                                    right: 4,
                                    child: GestureDetector(
                                      onTap:
                                          () => _removeImage(index), // 이미지 제거
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
          ],
        ),
      ),
    );
  }
}
