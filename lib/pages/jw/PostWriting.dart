import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:trekkit_flutter/models/jw/Post.dart';
import 'package:trekkit_flutter/models/jw/PostService.dart';

class PostWriting extends StatefulWidget {
  const PostWriting({super.key});

  @override
  State<PostWriting> createState() => _PostWritingState();
}

class _PostWritingState extends State<PostWriting> {
  String? _selectedMountain;
  List<String> _mountainOptions = [];
  List<XFile> _images = [];
  List<String> _uploadedImagePaths = [];

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  bool _isLoading = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadMountains();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  // 산 목록 로드
  Future<void> _loadMountains() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final mountains = await PostService.getMountains();
      setState(() {
        _mountainOptions = mountains;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('산 목록 로드 실패: $e')));
      }
    }
  }

  void _selectMountain(String? mountain) {
    setState(() {
      _selectedMountain = mountain;
    });
  }

  // 이미지 추가
  Future<void> _pickImages() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile>? picked = await picker.pickMultiImage();

    if (picked != null) {
      setState(() {
        _images = (picked.length > 5) ? picked.sublist(0, 5) : picked;
      });
    }
  }

  // 이미지 삭제
  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }

  // 이미지 업로드
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

  // 게시글 작성 완료
  Future<void> _submitPost() async {
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
        nickname: 'currentUser', // 실제 사용자 닉네임으로 변경
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('게시글이 성공적으로 작성되었습니다.')));

        // 성공 시 이전 페이지로 돌아가면서 새로고침 신호 전달
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('글쓰기'),
        actions: [
          if (_isSubmitting)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            TextButton(
              onPressed: _submitPost,
              child: const Text(
                '완료',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
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
                      ),
                      maxLines: 1,
                    ),

                    const SizedBox(height: 16),

                    // 산 선택
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: '산 선택 *',
                        border: OutlineInputBorder(),
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
                      ),
                      maxLines: 8,
                      keyboardType: TextInputType.multiline,
                    ),

                    const SizedBox(height: 16),

                    // 이미지 선택 섹션
                    Row(
                      children: [
                        const Text(
                          '사진 추가',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        TextButton.icon(
                          onPressed: _pickImages,
                          icon: const Icon(Icons.add_photo_alternate),
                          label: Text('사진 선택 (${_images.length}/5)'),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // 선택된 이미지 미리보기
                    if (_images.isNotEmpty)
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

                    const SizedBox(height: 24),

                    // 작성 가이드
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '작성 가이드',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '• 등산 경험이나 후기를 자유롭게 공유해주세요\n'
                            '• 사진은 최대 5장까지 첨부 가능합니다\n'
                            '• 다른 등산객들에게 도움이 되는 정보를 포함해주세요',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
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
