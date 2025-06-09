import 'package:flutter/material.dart';

class ResetPasswordFields extends StatelessWidget {

  final TextEditingController newPwController;
  final TextEditingController confirmPwController;
  final bool isValidPw;
  final bool isSamePw;
  final bool obscureNewPw;
  final bool obscureConfirmPw;
  final VoidCallback toggleNewPw;
  final VoidCallback toggleConfirmPw;
  final void Function(String) onPwChanged;
  final void Function(String) onPwCheckChanged;
  final VoidCallback onSubmit;

  final double screenWidth;
  final double screenHeight;

  const ResetPasswordFields({
    super.key,
    required this.newPwController,
    required this.confirmPwController,
    required this.isValidPw,
    required this.isSamePw,
    required this.obscureNewPw,
    required this.obscureConfirmPw,
    required this.toggleNewPw,
    required this.toggleConfirmPw,
    required this.onPwChanged,
    required this.onPwCheckChanged,
    required this.onSubmit,
    required this.screenWidth,
    required this.screenHeight,
  });

  @override
  Widget build(BuildContext context) {

    return Column(
      children: [

        TextField(
          controller: newPwController,
          obscureText: obscureNewPw,
          onChanged: onPwChanged,
          decoration: InputDecoration(
            hintText: '비밀번호 입력',
            errorText: (!isValidPw && newPwController.text.isNotEmpty)
                ? '비밀번호 형식이 올바르지 않습니다.'
                : null,
            suffixIcon: IconButton(
              icon: Icon(obscureNewPw ? Icons.visibility_off : Icons.visibility),
              onPressed: toggleNewPw,
            ),
          ),
        ),

        SizedBox(height: screenHeight * 0.02),

        TextField(
          controller: confirmPwController,
          obscureText: obscureConfirmPw,
          onChanged: onPwCheckChanged,
          decoration: InputDecoration(
            hintText: '비밀번호 다시 입력',
            errorText: (!isSamePw && confirmPwController.text.isNotEmpty)
                ? '비밀번호가 일치하지 않습니다.'
                : null,
            suffixIcon: IconButton(
              icon: Icon(obscureConfirmPw ? Icons.visibility_off : Icons.visibility),
              onPressed: toggleConfirmPw,
            ),
          ),
        ),

        SizedBox(height: screenHeight * 0.025),

        SizedBox(
          width: double.infinity,
          height: screenHeight*0.08,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,        // 배경색: 검정
              foregroundColor: Colors.white,        // 글자색: 흰색
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,    // 네모모양
              ),
              // padding: EdgeInsets.symmetric(vertical: s), // 높이
            ),
            onPressed: (isValidPw && isSamePw) ? onSubmit : null,
            child: Text(
              '수정하기',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: screenWidth*0.07),
            ),
          ),
        ),
      ],
    );
  }
}