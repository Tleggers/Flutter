import 'package:flutter/material.dart';
import '../../../services/jh/Signup/VerifyAuthCode.dart';

class AuthCodeInput extends StatelessWidget {

  final TextEditingController controller;
  final String email;
  final VoidCallback onVerified;

  const AuthCodeInput({
    super.key,
    required this.controller,
    required this.email,
    required this.onVerified,
  });

  @override
  Widget build(BuildContext context) {

    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        hintText: 'ex)123456',
        suffixIcon: TextButton(
          onPressed: () async {
            final isVerified = await verifyAuthCode(email, controller.text.trim());
            if (isVerified) {
              onVerified();
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('인증번호가 올바르지 않습니다')),
              );
            }
          },
          child: const Text('인증확인'),
        ),
      ),
    );
  }
}