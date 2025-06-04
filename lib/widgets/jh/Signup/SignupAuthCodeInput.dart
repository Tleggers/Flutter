import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SignupAuthCodeInput extends StatefulWidget {
  
  final TextEditingController emailCodeController;
  final TextEditingController emailController;
  final Future<bool> Function(String email, String code) onConfirm;

  const SignupAuthCodeInput({
    super.key,
    required this.emailCodeController,
    required this.emailController,
    required this.onConfirm,
  });

  @override
  State<SignupAuthCodeInput> createState() => _SignupAuthCodeInputState();
}

class _SignupAuthCodeInputState extends State<SignupAuthCodeInput> {
  
  String? resultMessage;
  Color? resultColor;

  @override
  Widget build(BuildContext context) {
    
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Padding(
      padding: EdgeInsets.only(bottom: screenHeight * 0.02),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          
          // 라벨
          Text(
            '인증코드',
            style: TextStyle(
              fontSize: screenWidth * 0.035,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF6B7280),
            ),
          ),
          
          SizedBox(height: screenHeight * 0.005),
          
          // 입력창
          TextField(
            controller: widget.emailCodeController,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
            ],
            style: TextStyle(fontSize: screenWidth * 0.04),
            decoration: InputDecoration(
              hintText: '인증코드를 입력해주세요.',
              hintStyle: TextStyle(
                color: Colors.grey,
                fontSize: screenWidth * 0.038,
              ),
              contentPadding: EdgeInsets.symmetric(
                vertical: screenHeight * 0.015,
                horizontal: screenWidth * 0.03,
              ),
              border: const UnderlineInputBorder(),
              suffix: TextButton(
                onPressed: () async {
                  final code = widget.emailCodeController.text.trim();
                  final email = widget.emailController.text.trim();

                  if (email.isNotEmpty && code.isNotEmpty) {
                    final isVerified = await widget.onConfirm(email, code);

                    setState(() {
                      resultMessage = isVerified
                          ? '인증 성공하였습니다.'
                          : '인증에 실패하였습니다.';
                      resultColor = isVerified ? Colors.green : Colors.red;
                    });
                  }
                },
                child: Text(
                  '확인',
                  style: TextStyle(
                    fontSize: screenWidth * 0.032,
                    color: Colors.blue,
                  ),
                ),
              ),
            ),
          ),
          
          // 밑에 인증 성공햇는지 아닌지 출력하는 메소드
          if (resultMessage != null) ...[
            SizedBox(height: screenHeight * 0.01),
            Text(
              resultMessage!,
              style: TextStyle(
                color: resultColor ?? Colors.black,
                fontSize: screenWidth * 0.032,
              ),
            ),
          ],
        ],
      ),
    );
  }
}