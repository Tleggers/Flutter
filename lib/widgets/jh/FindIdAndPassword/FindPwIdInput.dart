import 'package:flutter/material.dart';

class IdInput extends StatelessWidget {

  final TextEditingController controller;
  final bool isValid;
  final String? errorText;
  final void Function(String) onChanged;

  const IdInput({
    super.key,
    required this.controller,
    required this.isValid,
    required this.errorText,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(hintText: 'ex)user123', errorText: errorText),
    );
  }
}