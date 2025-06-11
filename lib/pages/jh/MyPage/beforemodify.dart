import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../functions/jh/userprovider.dart';
import 'modifypage.dart';

class BeforeModifyPage extends StatefulWidget {
  const BeforeModifyPage({super.key});

  @override
  State<BeforeModifyPage> createState() => _BeforeModifyPageState();
}

class _BeforeModifyPageState extends State<BeforeModifyPage> {
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      resizeToAvoidBottomInset: true, // 키보드 대응
      appBar: AppBar(
        title: Text(
          '비밀번호 확인',
          style: TextStyle(fontSize: screenWidth * 0.05, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag, // 스크롤 시 키보드 내리기
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.06),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: screenHeight * 0.05),

              // 상단 텍스트
              Center(
                child: Text(
                  '마이페이지',
                  style: TextStyle(fontSize: screenWidth * 0.08, fontWeight: FontWeight.bold),
                ),
              ),

              SizedBox(height: screenHeight * 0.03),

              // 안내 텍스트
              Padding(
                padding: EdgeInsets.symmetric(vertical: screenHeight * 0.015),
                child: Text(
                  '회원님의 소중한 개인정보 보호를 위해\n회원님의 비밀번호를 다시 한 번 입력해 주세요.\n정확한 본인 확인을 통해 고객님의 정보를\n안전하게 수정하실 수 있습니다.',
                  style: TextStyle(
                    fontSize: screenWidth * 0.04,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.start,
                ),
              ),

              SizedBox(height: screenHeight * 0.05),

              // 라벨
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '비밀번호 입력',
                  style: TextStyle(
                    fontSize: screenWidth * 0.035,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ),

              SizedBox(height: screenHeight * 0.005),

              // 입력창
              TextField(
                controller: _passwordController,
                obscureText: true,
                style: TextStyle(fontSize: screenWidth * 0.04),
                decoration: InputDecoration(
                  hintText: '비밀번호를 입력해주세요.',
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

              SizedBox(height: screenHeight * 0.03),

              // 확인 버튼
              SizedBox(
                width: double.infinity,
                height: screenHeight * 0.06,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                  ),
                  onPressed: () async {
                    final password = _passwordController.text.trim();
                    final jwtToken = Provider.of<UserProvider>(context, listen: false).token;

                    if (password.isEmpty || jwtToken == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('비밀번호를 입력해주세요.')),
                      );
                      return;
                    }

                    final baseUrl = dotenv.env['API_URL']!;
                    final url = Uri.parse('$baseUrl/modify/checkuser');

                    try {
                      final response = await http.post(
                        url,
                        headers: {
                          "Content-Type": "application/json",
                          "Authorization": "Bearer $jwtToken",
                          "X-Client-Type": "app",
                        },
                        body: jsonEncode({"pw": password}),
                      );

                      if (response.statusCode == 200) {
                        final isMatch = response.body.toLowerCase() == 'true';

                        if (isMatch) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => ModifyPage()),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('비밀번호가 일치하지 않습니다.')),
                          );
                        }
                      } else {
                        throw Exception("서버 오류: ${response.statusCode}");
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('에러 발생: $e')),
                      );
                    }
                  },
                  child: Text(
                    '확인',
                    style: TextStyle(fontSize: screenWidth * 0.045),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}