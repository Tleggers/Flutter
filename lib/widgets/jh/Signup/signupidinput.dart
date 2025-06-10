import 'package:flutter/material.dart';
import 'dart:async';

class SignupIdInput extends StatefulWidget {
  final TextEditingController idController;
  final bool isValidId;
  final void Function(String) onChanged;
  final String? idCheckMessage;
  final Color? idCheckColor;
  final Future<bool> Function(String)? onCheckDupId; // 서버 요청 함수

  const SignupIdInput({
    super.key,
    required this.idController,
    required this.isValidId,
    required this.onChanged,
    required this.idCheckMessage,
    required this.idCheckColor,
    required this.onCheckDupId,
  });

  @override
  State<SignupIdInput> createState() => _SignupIdInputState();
}

class _SignupIdInputState extends State<SignupIdInput> {
  
  Timer? _debounce; // 타이머 변수

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _onChangedWithDebounce(String value) {
    widget.onChanged(value);
    _debounce?.cancel();

    // 입력한지 0.5초가 지나면 fetch문 실행
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      if (widget.isValidId && widget.onCheckDupId != null) {
        try {
          await widget.onCheckDupId!(value);
          // 결과는 부모에서 처리
        } catch (_) {
          // 무시
        }
      }
    });
  }

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
            '아이디(*필수)',
            style: TextStyle(
              fontSize: screenWidth * 0.035,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF6B7280), // 회색
            ),
          ),

          SizedBox(height: screenHeight * 0.00),

          // 텍스트 필드
          TextField(
            controller: widget.idController,
            onChanged: _onChangedWithDebounce,
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

          SizedBox(height: screenHeight * 0.01),

          // 메시지
          if (widget.idCheckMessage != null)
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                widget.idCheckMessage!,
                style: TextStyle(
                  color: widget.idCheckColor ?? Colors.black,
                  fontSize: screenWidth * 0.032,
                ),
              ),
            ),
        ],
      ),
    );
  }
}