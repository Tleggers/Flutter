import 'package:flutter/material.dart';

// 비밀번호 입력창 UI
class SignupPwInput extends StatefulWidget {

  final TextEditingController pwController;
  final bool isValidPw;
  final void Function(String) onChanged;
  final String? pwCheckMessage;
  final Color? pwCheckColor;

  const SignupPwInput({
    super.key,
    required this.pwController,
    required this.isValidPw,
    required this.onChanged,
    required this.pwCheckMessage,
    required this.pwCheckColor,
  });

  @override
  State<SignupPwInput> createState() => _SignupPwInputState();
}

class _SignupPwInputState extends State<SignupPwInput> {

  // obscureText -> 사용자가 입력한 값을 안보이게 해주는는거
  // 리액트에서 input type password와 동일
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
            '비밀번호(*필수)',
            style: TextStyle(
              fontSize: screenWidth * 0.035,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF6B7280),
            ),
          ),

          // 텍스트 필드
          TextField(
            controller: widget.pwController, // 입력 컨트롤러
            obscureText: _obscureText, // 입력값 안보이게 하는거
            onChanged: widget.onChanged,
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
              
              // 클릭시 input type password랑 text랑 바뀌게 하는거
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