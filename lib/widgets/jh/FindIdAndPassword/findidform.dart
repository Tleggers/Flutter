import 'package:flutter/material.dart';
import '../../../functions/jh/timer.dart';
import '../../../services/jh/FindIdAndPassword/findidservice.dart';
import '../../../services/jh/Signup/verifyauthcode.dart';

class FindIdForm extends StatefulWidget {

  final double screenWidth;
  final double screenHeight;
  final Function(String) onResult;

  const FindIdForm({
    super.key,
    required this.screenWidth,
    required this.screenHeight,
    required this.onResult,
  });

  @override
  State<FindIdForm> createState() => _FindIdFormState();

}

class _FindIdFormState extends State<FindIdForm> {

  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  final AuthTimer _authTimer = AuthTimer();

  bool isValidEmail = false;
  String? emailCheckMessage;
  Color? emailCheckColor;
  
  bool _showCodeField = false;

  // 정규식
  bool validateEmail(String input) {
    final regex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    final isValid = regex.hasMatch(input);

    setState(() {
      isValidEmail = isValid;
      emailCheckMessage = input.isEmpty
          ? null
          : (isValid ? null : '이메일 형식이 올바르지 않습니다.');
      emailCheckColor = isValid ? null : Colors.red;
    });

    return isValid;
  }

  @override
  void dispose() {
    _authTimer.cancel();
    _emailController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      
      children: [
        
        Text('이메일로 찾기', style: TextStyle(color: Colors.grey, fontSize: widget.screenWidth * 0.035)),
        
        SizedBox(height: widget.screenHeight * 0.005),

        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          onChanged: validateEmail,

          decoration: InputDecoration(
            hintText: 'example@email.com',
            errorText: emailCheckMessage,

            suffixIcon: TextButton(
              onPressed: isValidEmail
                  ? () async {
                try {
                  setState(() {
                    _showCodeField = true;
                  });
                  _authTimer.start(() => setState(() {}));
                  await sendMail(_emailController.text.trim());
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('메일 전송 실패: $e')),
                  );
                }
              }
                  : null, // 유효하지 않으면 버튼 비활성화
              child: Text('인증번호전송', style: TextStyle(fontSize: widget.screenWidth * 0.035)),
            ),
          ),
        ),
        
        // 인증번호전송 버튼 눌렀을 때 나오는 부분
        if (_showCodeField) ...[
          
          SizedBox(height: widget.screenHeight * 0.02),
          
          Text('남은 시간: ${_authTimer.formattedTime}', style: TextStyle(color: Colors.red)),
          
          SizedBox(height: widget.screenHeight * 0.015),
          
          TextField(
            controller: _codeController,
            keyboardType: TextInputType.number,
            
            decoration: InputDecoration(
              hintText: 'ex)123456',
              
              suffixIcon: TextButton(
                onPressed: () async {
                  final email = _emailController.text.trim();
                  final code = _codeController.text.trim();
                  _authTimer.cancel();

                  // 인증을 하고 성공하면 if문 실행
                  final isVerified = await verifyAuthCode(email, code);
                  if (isVerified) {
                    final result = await fetchUserIdByEmail(email);
                    if (result != null && result['logintype'] == 'LOCAL') {
                      widget.onResult('아이디는 ${result['userid']} 입니다');
                    } else {
                      widget.onResult('해당 이메일로 가입된 계정이 없습니다.');
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('인증번호가 올바르지 않습니다')),
                    );
                  }
                },
                child: Text('인증확인', style: TextStyle(fontSize: widget.screenWidth * 0.035)),
              ),
            ),
          ),
        ]
      ],
    );
  }
}
