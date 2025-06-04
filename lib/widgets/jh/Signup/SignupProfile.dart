import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

class ProfileImagePicker extends StatefulWidget {
  const ProfileImagePicker({super.key});

  @override
  State<ProfileImagePicker> createState() => _ProfileImagePickerState();
}

class _ProfileImagePickerState extends State<ProfileImagePicker> {
  
  // 선택된 이미지
  File? _selectedImage;

  // 허용할 확장자, 나머지 확장자는 불가(보안 공격 때문에)
  final List<String> _allowedExtensions = ['jpg', 'jpeg', 'png'];

  Future<void> _pickImage() async {

    final picker = ImagePicker(); // ImagePicker를 생성
    final pickedFile = await picker.pickImage(source: ImageSource.gallery); // 선택된 사진 넣는 변수

    if (pickedFile != null) {
      final extension = path.extension(pickedFile.path).toLowerCase().replaceAll('.', '');

      if (_allowedExtensions.contains(extension)) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('jpg, jpeg, png 형식의 이미지 파일만 선택 가능합니다.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            '프로필 사진',
            style: TextStyle(
              fontSize: screenWidth * 0.04,
              color: Colors.grey,
            ),
          ),
        ),
        SizedBox(height: screenHeight * 0.01),
        Column(
          children: [
            CircleAvatar(
              radius: screenWidth * 0.12,
              backgroundColor: Colors.grey.shade300,
              backgroundImage: _selectedImage != null ? FileImage(_selectedImage!) : null,
              
              // 선택된 사진이 없으면 아이콘, 있으면 사진
              child: _selectedImage == null
                  ? Icon(
                Icons.person,
                size: screenWidth * 0.2,
                color: Colors.white,
              )
                  : null,
            ),

            SizedBox(height: screenHeight * 0.01),

            GestureDetector(
              onTap: _pickImage,
              child: Text(
                '편집',
                style: TextStyle(
                  fontSize: screenWidth * 0.04,
                  color: Colors.teal,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}