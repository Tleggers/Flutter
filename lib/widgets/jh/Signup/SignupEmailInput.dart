import 'dart:async';
import 'package:flutter/material.dart';
import '../../../services/jh/Signup/SendMail.dart';

class SignupEmailInput extends StatefulWidget {
  final TextEditingController emailController;
  final Future<bool> Function(String email) onRequestVerification;
  final bool Function(String email) validateEmail;
  final String? emailCheckMessage;
  final Color? emailCheckColor;

  const SignupEmailInput({
    super.key,
    required this.emailController,
    required this.onRequestVerification,
    required this.validateEmail,
    required this.emailCheckMessage,
    required this.emailCheckColor,
  });

  @override
  State<SignupEmailInput> createState() => _SignupEmailInputState();
}

class _SignupEmailInputState extends State<SignupEmailInput> {
  
  Timer? _debounce;
  Timer? _countdownTimer;
  int _remainingSeconds = 0;

  String? _emailMessage;
  Color? _emailMessageColor;

  String _formatTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '남은 시간: $minutes:$secs';
  }

  // 버튼 눌렀을 때 시작되는 타이머
  void _startTimer() {
    _countdownTimer?.cancel();
    setState(() {
      _remainingSeconds = 180;
    });

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds <= 1) {
          timer.cancel();
          _remainingSeconds = 0;
        } else {
          _remainingSeconds--;
        }
      });
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _countdownTimer?.cancel();
    super.dispose();
  }

  // 이메일 입력 값이 onChange 되면 실행되는 메소드
  // 0.5초 동안 아무것도 안하면 함수 실행
  void _onEmailChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      if (value.isNotEmpty) {
        await widget.onRequestVerification(value);
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
            '이메일(*필수)',
            style: TextStyle(
              fontSize: screenWidth * 0.035,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF6B7280),
            ),
          ),
          SizedBox(height: screenHeight * 0.005),

          // 입력창
          TextField(
            controller: widget.emailController,
            onChanged: _onEmailChanged,
            style: TextStyle(fontSize: screenWidth * 0.04),
            decoration: InputDecoration(
              hintText: '이메일을 입력해주세요.',
              hintStyle: TextStyle(
                color: Colors.grey,
                fontSize: screenWidth * 0.038,
              ),
              contentPadding: EdgeInsets.symmetric(
                vertical: screenHeight * 0.015,
                horizontal: screenWidth * 0.03,
              ),
              border: const UnderlineInputBorder(),
              
              // 인증 요청 눌렀을 때 실행되는 함수
              suffix: TextButton(
                onPressed: () async {
                  final email = widget.emailController.text.trim();

                  final isValidFormat = widget.validateEmail(email);

                  // 이메일 형식 오류
                  if (!isValidFormat) {
                    setState(() {
                      _emailMessage = '이메일 형식이 올바르지 않습니다.';
                      _emailMessageColor = Colors.red;
                    });
                    return;
                  }

                  try {
                    // 중복 체크
                    final isAvailable = await widget.onRequestVerification(email);

                    if (!mounted) return;

                    if (!isAvailable) {
                      setState(() {
                        _emailMessage = '이미 사용 중인 이메일입니다.';
                        _emailMessageColor = Colors.red;
                      });
                      return;
                    }

                    // 이메일 전송
                    await sendMail(email);

                    setState(() {
                      _emailMessage = '사용 가능한 이메일입니다';
                      _emailMessageColor = Colors.green;
                    });

                    _startTimer();

                  } catch (e) {
                    if (!context.mounted) return;
                    setState(() {
                      _emailMessage = '메일 전송에 실패했습니다. 다시 시도해주세요.';
                      _emailMessageColor = Colors.red;
                    });
                  }
                },
                child: Text(
                  '인증요청',
                  style: TextStyle(
                    fontSize: screenWidth * 0.032,
                    color: Colors.blue,
                  ),
                ),
              ),
            ),
          ),

          SizedBox(height: screenHeight * 0.01),

          // 메시지 + 타이머 항상 표시
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [

              // 이메일 체크 메시지 (인증요청 눌렀을 때만 표시)
              Expanded(
                child: Text(
                  _emailMessage ?? '',
                  style: TextStyle(
                    color: _emailMessageColor ?? Colors.transparent,
                    fontSize: screenWidth * 0.032,
                  ),
                ),
              ),

              // 타이머 또는 시간 만료
              Text(
                _remainingSeconds > 0
                    ? _formatTime(_remainingSeconds)
                    : (_countdownTimer != null ? '시간 만료' : ''),
                style: TextStyle(
                  color: _remainingSeconds > 0 ? Colors.red : Colors.grey,
                  fontSize: screenWidth * 0.032,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}