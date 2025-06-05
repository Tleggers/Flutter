import 'package:flutter/material.dart';
import 'dart:async';

class SignupNicknameInput extends StatefulWidget {
  final TextEditingController nicknameController;
  final String? nicknameCheckMessage;
  final Color? nicknameCheckColor;
  final Future<bool> Function(String) onCheckDupNickName;
  final bool Function(String) validateNickname;

  const SignupNicknameInput({
    super.key,
    required this.nicknameController,
    required this.nicknameCheckMessage,
    required this.nicknameCheckColor,
    required this.onCheckDupNickName,
    required this.validateNickname,
  });

  @override
  State<SignupNicknameInput> createState() => _SignupNicknameInputState();
}

class _SignupNicknameInputState extends State<SignupNicknameInput> {
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _onChangedWithDebounce(String value) {
    _debounce?.cancel();

    // 🔥 validateNickname 호출 먼저
    final isValid = widget.validateNickname(value); // 여기서 setState + print 실행됨

    _debounce = Timer(const Duration(milliseconds: 500), () async {
      if (isValid) {
        await widget.onCheckDupNickName(value);
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
          Text(
            '닉네임(*선택)',
            style: TextStyle(
              fontSize: screenWidth * 0.035,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF6B7280),
            ),
          ),
          SizedBox(height: screenHeight * 0.005),
          TextField(
            controller: widget.nicknameController,
            onChanged: _onChangedWithDebounce, // ✅ 이 안에서 validateNickname 호출됨
            style: TextStyle(fontSize: screenWidth * 0.04),
            decoration: InputDecoration(
              hintText: '닉네임을 입력해주세요.',
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
          if (widget.nicknameCheckMessage != null)
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                widget.nicknameCheckMessage!,
                style: TextStyle(
                  color: widget.nicknameCheckColor ?? Colors.black,
                  fontSize: screenWidth * 0.032,
                ),
              ),
            ),
        ],
      ),
    );
  }
}