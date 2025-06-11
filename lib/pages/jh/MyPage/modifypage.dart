import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../functions/jh/userprovider.dart';
import '../../mainpage.dart';

class ModifyPage extends StatefulWidget {
  const ModifyPage({super.key});

  @override
  State<ModifyPage> createState() => _ModifyPageState();
}

class _ModifyPageState extends State<ModifyPage> {

  final TextEditingController idController = TextEditingController();
  final TextEditingController nicknameController = TextEditingController();
  final TextEditingController pwController = TextEditingController();
  final TextEditingController cpwController = TextEditingController();

  bool isLoading = true; // 로딩중
  String? loginType; // 백엔드에서 가지고 올 로그인 타입
  String? profileUrl; // 백엔드에서 가지고 올 프로필사진 url
  File? selectedImageFile; // 편집 눌러서 새로 선택한 사진

  bool _obscurePw = true; // 비밀번호 및 비밀번호 확인에서 입력값을 보이게 할 지 말지 해주는거
  bool _obscureCpw = true; // 비밀번호 및 비밀번호 확인에서 입력값을 보이게 할 지 말지 해주는거

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchUserData(); // context 안전하게 사용 가능
    });
  }

  // ✅ 유저 데이터 불러오기
  Future<void> fetchUserData() async {
    final baseUrl = dotenv.env['API_URL']!;
    final url = Uri.parse('$baseUrl/modify/getUserData');
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final token = userProvider.token;

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
          "X-Client-Type": "app",
        },
        body: jsonEncode({}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          idController.text = data['id'] ?? '';
          nicknameController.text = data['nickname'] ?? '';
          loginType = data['logintype'];
          profileUrl = data['profile'];
          isLoading = false;
        });
      } else {
        showErrorSnackbar();
      }
    } catch (e) {
      showErrorSnackbar();
      setState(() {
        isLoading = false;
      });
    }
  }

  // 수정 함수 (닉네임, 비밀번호, 이미지)
  Future<void> submitUserData() async {

    final nickname = nicknameController.text.trim();
    final password = pwController.text.trim();
    final confirmPassword = cpwController.text.trim();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final token = userProvider.token;

    final nicknameRegex = RegExp(r'^[a-zA-Z0-9가-힣]{1,16}$');
    if (!nicknameRegex.hasMatch(nickname)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('닉네임은 한글/영문/숫자 조합의 1~16자여야 합니다.')),
      );
      return;
    }

    if (loginType == 'LOCAL') {
      if (password.length > 16 || confirmPassword.length > 16) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('비밀번호는 16자 이하로 입력해주세요.')),
        );
        return;
      }
      if (password != confirmPassword) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('비밀번호가 일치하지 않습니다.')),
        );
        return;
      }
    }

    final baseUrl = dotenv.env['API_URL']!;
    final url = Uri.parse('$baseUrl/modify/updateUserData');

    try {
      var request = http.MultipartRequest('POST', url);
      request.headers.addAll({
        "Authorization": "Bearer $token",
        "X-Client-Type": "app",
      });

      request.fields['pw'] = password;
      request.fields['nickname'] = nickname;

      if (selectedImageFile != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'profileImage',
          selectedImageFile!.path,
        ));
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {

        // 로그아웃 처리
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();
        userProvider.logout();

        if (!context.mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('정보가 수정되었습니다. 다시 로그인해주세요.')),
        );

        // 홈으로 이동
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const MainPage(title: 'TrekKit')),
              (route) => false,
        );
      } else {
        showErrorSnackbar();
      }
    } catch (e) {
      showErrorSnackbar();
    }

  }

  // 에러용 스낵바 함수
  void showErrorSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('오류가 발생했습니다. 잠시 후 다시 시도해주세요.'),
        duration: Duration(seconds: 3),
      ),
    );
  }

  // 이미지 선택 함수
  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      final file = File(pickedFile.path);
      final ext = file.path.split('.').last.toLowerCase();
      if (["jpg", "jpeg", "png"].contains(ext)) {
        setState(() {
          selectedImageFile = file;
          profileUrl = null; // ✅ 기존 URL 제거
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("jpg, jpeg, png 형식만 지원합니다.")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      resizeToAvoidBottomInset: true,

      //AppBar
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.close, size: screenWidth * 0.06),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) =>
                const MainPage(title: 'TrekKit', initialIndex: 3),
              ),
                (Route<dynamic> route) => false,
            );
          },
        ),

        // AppBar안에 Text
        title: Text(
          '정보수정',
          style: TextStyle(
            fontSize: screenWidth * 0.05,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: EdgeInsets.all(screenWidth * 0.06),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            SizedBox(height: screenHeight * 0.01),

            Text(
              '아이디',
              style: TextStyle(
                fontSize: screenWidth * 0.035,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF6B7280), // 회색
              ),
            ),

            SizedBox(height: screenHeight * 0.005),

            TextField(
              controller: idController,
              enabled: false,
              style: TextStyle(fontSize: screenWidth * 0.04),
              decoration: InputDecoration(
                hintText: '아이디를 입력해주세요.',
                hintStyle: TextStyle(
                  color: Colors.grey,
                  fontSize: screenWidth * 0.038,
                ),
                contentPadding: EdgeInsets.symmetric(
                  vertical: screenHeight * 0.015,
                ),
                border: const UnderlineInputBorder(),
              ),
            ),

            SizedBox(height: screenHeight * 0.025),

            if (loginType == 'LOCAL') ...[

              // 새 비밀번호
              Text(
                '새 비밀번호',
                style: TextStyle(
                  fontSize: screenWidth * 0.035,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF6B7280),
                ),
              ),

              SizedBox(height: screenHeight * 0.005),

              TextField(
                controller: pwController,
                obscureText: _obscurePw,
                style: TextStyle(fontSize: screenWidth * 0.04),
                decoration: InputDecoration(
                  hintText: '새 비밀번호를 입력해주세요.',
                  hintStyle: TextStyle(
                    color: Colors.grey,
                    fontSize: screenWidth * 0.038,
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: screenHeight * 0.015,
                  ),
                  border: const UnderlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePw ? Icons.visibility_off : Icons.visibility,
                      size: screenWidth * 0.05,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePw = !_obscurePw;
                      });
                    },
                  ),
                ),
              ),

              SizedBox(height: screenHeight * 0.02),

              // 비밀번호 확인
              Text(
                '비밀번호 확인',
                style: TextStyle(
                  fontSize: screenWidth * 0.035,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF6B7280),
                ),
              ),

              SizedBox(height: screenHeight * 0.005),

              TextField(
                controller: cpwController,
                obscureText: _obscureCpw,
                style: TextStyle(fontSize: screenWidth * 0.04),
                decoration: InputDecoration(
                  hintText: '비밀번호를 다시 입력해주세요.',
                  hintStyle: TextStyle(
                    color: Colors.grey,
                    fontSize: screenWidth * 0.038,
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: screenHeight * 0.015,
                  ),
                  border: const UnderlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureCpw ? Icons.visibility_off : Icons.visibility,
                      size: screenWidth * 0.05,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureCpw = !_obscureCpw;
                      });
                    },
                  ),
                ),
              ),

              SizedBox(height: screenHeight * 0.025),

            ],

            Text(
              '닉네임',
              style: TextStyle(
                fontSize: screenWidth * 0.035,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF6B7280),
              ),
            ),

            SizedBox(height: screenHeight * 0.005),

            TextField(
              controller: nicknameController,
              style: TextStyle(fontSize: screenWidth * 0.04),
              decoration: InputDecoration(
                hintText: '닉네임을 입력해주세요.',
                hintStyle: TextStyle(
                  color: Colors.grey,
                  fontSize: screenWidth * 0.038,
                ),
                suffixIcon: IconButton(
                  icon: Icon(Icons.clear, size: screenWidth * 0.06),
                  onPressed: () => nicknameController.clear(),
                ),
                contentPadding: EdgeInsets.symmetric(
                  vertical: screenHeight * 0.015,
                ),
                border: const UnderlineInputBorder(),
              ),
            ),

            SizedBox(height: screenHeight * 0.025),

            Text(
              '프로필 사진',
              style: TextStyle(fontSize: screenWidth * 0.038),
            ),
            SizedBox(height: screenHeight * 0.01),
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: screenWidth * 0.11,
                    backgroundColor: Colors.grey.shade300,
                    backgroundImage: selectedImageFile != null
                        ? FileImage(selectedImageFile!)
                        : (profileUrl != null && profileUrl!.startsWith('http')
                        ? NetworkImage(profileUrl!)
                        : null),
                    child: (selectedImageFile == null &&
                        (profileUrl == null || !profileUrl!.startsWith('http')))
                        ? Icon(Icons.person, size: screenWidth * 0.11, color: Colors.white)
                        : null,
                  ),
                  TextButton(
                    onPressed: pickImage,
                    child: Text(
                      '편집',
                      style: TextStyle(fontSize: screenWidth * 0.04),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: screenHeight * 0.05),

            SizedBox(
              width: double.infinity,
              height: screenHeight * 0.06,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(screenWidth * 0.02),
                  ),
                ),
                onPressed: submitUserData,
                child: Text(
                  '수정하기',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: screenWidth * 0.045,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}