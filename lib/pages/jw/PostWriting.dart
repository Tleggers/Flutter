import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trekkit_flutter/functions/jh/userprovider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:trekkit_flutter/models/jw/Post.dart';
import 'package:trekkit_flutter/services/jw/AuthService.dart';
import 'package:trekkit_flutter/services/jw/PostService.dart';

class PostWriting extends StatefulWidget {
  const PostWriting({super.key});

  @override
  State<PostWriting> createState() => _PostWritingState();
}

class _PostWritingState extends State<PostWriting> {
  String? _selectedMountain;
  List<XFile> _images = [];
  List<String> _uploadedImagePaths = [];

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  bool _isSubmitting = false;

  // 데이터베이스의 5가지 산
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

  void _selectMountain(String? mountain) {
    setState(() {
      _selectedMountain = mountain;
    });
  }

  Future<void> _pickImages() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> picked = await picker.pickMultiImage();

    setState(() {
      _images = (picked.length > 5) ? picked.sublist(0, 5) : picked;
    });
  }

  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }

  Future<void> _uploadImages() async {
    if (_images.isEmpty) {
      _uploadedImagePaths = [];
      return;
    }

    try {
      final imagePaths = await PostService.uploadImages(
        _images.map((xfile) => File(xfile.path)).toList(),
      );
      _uploadedImagePaths = imagePaths;
    } catch (e) {
      throw Exception('이미지 업로드 실패: $e');
    }
  }

  Future<void> _submitPost() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    // 로그인 상태 확인
    if (!userProvider.isLoggedIn) {
      _showErrorSnackBar('로그인이 필요합니다.');
      return;
    }
    // 유효성 검사
    if (_selectedMountain == null || _selectedMountain!.isEmpty) {
      _showErrorSnackBar('산을 선택해주세요.');
      return;
    }

    if (_contentController.text.trim().isEmpty) {
      _showErrorSnackBar('내용을 입력해주세요.');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // 1. 이미지 업로드 (있는 경우)
      await _uploadImages();

      // 2. 게시글 작성
      final post = Post(
        nickname: userProvider.nickname ?? 'Unknown',
        // userId 필드가 있다면 추가
        // userId: userProvider.index.toString(),
        title:
            _titleController.text.trim().isEmpty
                ? null
                : _titleController.text.trim(),
        mountain: _selectedMountain!,
        content: _contentController.text.trim(),
        imagePaths: _uploadedImagePaths,
        createdAt: DateTime.now(),
      );

      await PostService.createPost(post);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('게시글이 성공적으로 작성되었습니다.'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('게시글 작성 실패: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    // UserProvider 가져오기
    final userProvider = Provider.of<UserProvider>(context);

    // 로그인 상태 확인 및 처리
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

    // 로그인된 경우 기존 UI 반환
    return Scaffold(
      appBar: AppBar(
        title: const Text('글쓰기'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
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
              onPressed: _submitPost,
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
        padding: EdgeInsets.all(screenWidth * 0.05),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 제목 입력 (선택사항)
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                hintText: '제목 (선택사항)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.title),
              ),
              maxLines: 1,
            ),

            const SizedBox(height: 16),

            // 산 선택
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: '산 선택 *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.landscape),
              ),
              value: _selectedMountain,
              items:
                  _mountainOptions.map((mountain) {
                    return DropdownMenuItem<String>(
                      value: mountain,
                      child: Text(mountain),
                    );
                  }).toList(),
              onChanged: _selectMountain,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '산을 선택해주세요';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // 내용 입력
            TextField(
              controller: _contentController,
              decoration: const InputDecoration(
                hintText: '등산 후기나 경험을 공유해주세요 *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.edit),
                alignLabelWithHint: true,
              ),
              maxLines: 8,
            ),

            const SizedBox(height: 20),

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
                        const Spacer(),
                        OutlinedButton.icon(
                          onPressed: _pickImages,
                          icon: const Icon(Icons.add_photo_alternate),
                          label: Text('사진 선택 (${_images.length}/5)'),
                        ),
                      ],
                    ),

                    if (_images.isNotEmpty) ...[
                      const SizedBox(height: 16),
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
                                      File(_images[index].path),
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Positioned(
                                    top: 4,
                                    right: 4,
                                    child: GestureDetector(
                                      onTap: () => _removeImage(index),
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

            const SizedBox(height: 24),

            // 작성 가이드
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green[200]!),
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
                  const SizedBox(height: 8),
                  Text(
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
