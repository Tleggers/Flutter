import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../functions/jh/userprovider.dart';
import '../../../../services/jh/MyPage/deleteuser.dart';
import 'mypagefaq.dart';

class MyPageUseSection extends StatelessWidget {

  final double screenWidth;
  final double screenHeight;

  const MyPageUseSection({
    super.key,
    required this.screenWidth,
    required this.screenHeight,
  });

  @override
  Widget build(BuildContext context) {

    final isLoggedIn = Provider.of<UserProvider>(context).isLoggedIn;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: screenHeight * 0.01),
          child: Text(
            'TrekKit 이용하기',
            style: TextStyle(
              fontSize: screenWidth * 0.035,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),

        // 자주 묻는 질문
        ListTile(
          leading: const Icon(Icons.help_outline, color: Colors.deepOrange),
          title: Text(
            '자주 묻는 질문',
            style: TextStyle(fontSize: screenWidth * 0.04),
          ),
          trailing: const Icon(Icons.chevron_right, color: Colors.grey),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const FaqPage()),
            );
          },
        ),

        // 로그인 상태에서만 회원탈퇴 표시
        if (isLoggedIn)
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.redAccent),
            title: Text(
              '회원탈퇴',
              style: TextStyle(fontSize: screenWidth * 0.04),
            ),
            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
            onTap: () => deleteUser(context),
          ),

      ],
    );
  }
}
