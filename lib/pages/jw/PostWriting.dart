import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class PostWriting extends StatefulWidget {
  const PostWriting({super.key});
  @override
  State<PostWriting> createState() => _PostWritingState();
}

class _PostWritingState extends State<PostWriting> {
  String? _selectedMountain;
  final List<String> mountainOptions = [
    '가령산',
    '감악산 (파주)',
    '관악산',
    '계룡산 (대전/충남)',
    '구봉산 (대전)',
  ];

  List<XFile> _images = [];
  final TextEditingController _textController = TextEditingController();

  // 필터 선택
  void _selectMountain(String? mountain) {
    setState(() {
      _selectedMountain = mountain;
    });
  }

  // 이미지 추가
  Future<void> _pickImages() async {
    final ImagePicker picker = ImagePicker();
    // ignore: unnecessary_nullable_for_final_variable_declarations
    final List<XFile>? picked = await picker.pickMultiImage();

    if (picked != null) {
      setState(() {
        _images = (picked.length > 5) ? picked.sublist(0, 5) : picked;
      });
    }
  }

  // 작성 완료 버튼
  void _submitPost() {
    if (_selectedMountain == null || _textController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('모든 항목을 작성해 주세요.')));
      return;
    }
    // 작성 로직
    // ignore: avoid_print
    print('선택된 산: $_selectedMountain');
    // ignore: avoid_print
    print('본문: ${_textController.text}');
    // ignore: avoid_print
    print('사진 개수: ${_images.length}');
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(title: const Text('글쓰기')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(screenWidth * 0.05),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔸 필터
            DropdownButton<String>(
              hint: const Text('산 선택'),
              value: _selectedMountain,
              items:
                  mountainOptions.map((mountain) {
                    return DropdownMenuItem<String>(
                      value: mountain,
                      child: Text(mountain),
                    );
                  }).toList(),
              onChanged: _selectMountain,
            ),

            const SizedBox(height: 16),

            // 🔸 사진 선택 영역
            GestureDetector(
              onTap: _pickImages,
              child: Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child:
                    _images.isEmpty
                        ? const Center(child: Text('사진을 추가하려면 눌러주세요'))
                        : ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _images.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Image.file(
                                File(_images[index].path),
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                            );
                          },
                        ),
              ),
            ),

            const SizedBox(height: 16),

            // 🔸 본문 텍스트 입력
            TextField(
              controller: _textController,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: '게시글을 작성하세요',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            // 🔸 작성 완료 버튼
            Center(
              child: ElevatedButton(
                onPressed: _submitPost,
                child: const Text('작성 완료'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
