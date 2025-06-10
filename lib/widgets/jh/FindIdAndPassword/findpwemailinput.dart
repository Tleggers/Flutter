import 'package:flutter/material.dart';

class EmailInput extends StatelessWidget {
  final TextEditingController controller;
  final String? errorText;
  final void Function(String) onChanged;

  const EmailInput({
    super.key,
    required this.controller,
    required this.errorText,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.emailAddress,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: 'ex)mtd@ohiker.com',
        errorText: errorText,
      ),
    );
  }
}