import 'package:flutter/material.dart';

// 비밀번호 확인 입력창 UI
class SignupPwCheckInput extends StatefulWidget {
  final TextEditingController pwCheckController;
  final bool isSamePw;
  final void Function(String) onChanged;
  final String? pwCheckMessage;
  final Color? pwCheckColor;

  const SignupPwCheckInput({
    super.key,
    required this.pwCheckController,
    required this.isSamePw,
    required this.onChanged,
    required this.pwCheckMessage,
    required this.pwCheckColor,
  });

  @override
  State<SignupPwCheckInput> createState() => _SignupPwCheckInputState();
}

class _SignupPwCheckInputState extends State<SignupPwCheckInput> {
  
  // input type password 같은 느낌
  bool _obscureText = true;

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
            '비밀번호 확인',
            style: TextStyle(
              fontSize: screenWidth * 0.035,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF6B7280),
            ),
          ),

          // 텍스트 필드
          TextField(
            controller: widget.pwCheckController,
            obscureText: _obscureText,
            onChanged: widget.onChanged,
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
                  _obscureText ? Icons.visibility_off : Icons.visibility,
                  size: screenWidth * 0.05,
                ),
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
              ),
            ),
          ),

          SizedBox(height: screenHeight * 0.01),

          // 안내 메시지
          if (widget.pwCheckMessage != null)
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                widget.pwCheckMessage!,
                style: TextStyle(
                  color: widget.pwCheckColor ?? Colors.black,
                  fontSize: screenWidth * 0.032,
                ),
              ),
            ),
        ],
      ),
    );
  }
}