import 'package:flutter/material.dart';
import 'package:trekkit_flutter/widgets/jh/MyPage/MyPagePolicy/privacypolicy.dart';
import 'package:trekkit_flutter/widgets/jh/MyPage/MyPagePolicy/termofservicepage.dart';

import 'morugetta.dart';

class MyPagePolicySection extends StatelessWidget {

  final double screenWidth;
  final double screenHeight;

  const MyPagePolicySection({
    super.key,
    required this.screenWidth,
    required this.screenHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: screenHeight * 0.01),
          child: Text(
            '이용정책',
            style: TextStyle(
              fontSize: screenWidth * 0.035,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),

        // 이용약관
        ListTile(
          leading: const Icon(Icons.edit_note_rounded, color: Colors.orangeAccent),
          title: Text(
            '이용약관',
            style: TextStyle(fontSize: screenWidth * 0.04),
          ),
          trailing: const Icon(Icons.chevron_right, color: Colors.grey),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TermsOfServicePage()),
            );
          },
        ),

        // 개인정보 처리방침
        ListTile(
          leading: const Icon(Icons.face_retouching_natural_rounded, color: Colors.purple),
          title: Text(
            '개인정보 처리방침',
            style: TextStyle(fontSize: screenWidth * 0.04),
          ),
          trailing: const Icon(Icons.chevron_right, color: Colors.grey),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PrivacyPolicyPage()),
            );
          },
        ),

        // 위치기반 서비스 이용약관
        ListTile(
          leading: const Icon(Icons.public, color: Colors.blueAccent),
          title: Text(
            '위치기반서비스 이용약관',
            style: TextStyle(fontSize: screenWidth * 0.04),
          ),
          trailing: const Icon(Icons.chevron_right, color: Colors.grey),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const Morugetta()),
            );
          },
        ),
      ],
    );
  }
}