import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../functions/jh/Login/UserProvider.dart';

class ProfileAvatar extends StatelessWidget {

  final double screenWidth;

  const ProfileAvatar({
    super.key,
    required this.screenWidth,
  });

  @override
  Widget build(BuildContext context) {

    // 백엔드에서 가지고 온 값들
    final userProvider = Provider.of<UserProvider>(context);
    final isLoggedIn = userProvider.isLoggedIn;
    final profileUrl = userProvider.profileUrl?.trim();

    if (isLoggedIn && profileUrl != null && profileUrl.isNotEmpty) {
      // 👉 로그인 O + 프로필 O → 이미지
      return CircleAvatar(
        radius: screenWidth * 0.08,
        backgroundColor: Colors.grey.shade300,
        child: ClipOval(
          child: CachedNetworkImage(
            imageUrl: profileUrl,
            width: screenWidth * 0.16,
            height: screenWidth * 0.16,
            fit: BoxFit.cover,
            placeholder: (context, url) => const CircularProgressIndicator(),
            errorWidget: (context, url, error) => Icon(
              Icons.person,
              size: screenWidth * 0.08,
              color: Colors.white,
            ),
          ),
        ),
      );
    } else {
      // 로그인 X 또는 프로필 X
      return CircleAvatar(
        radius: screenWidth * 0.08,
        backgroundColor: Colors.grey.shade300,
        child: Icon(
          Icons.person,
          size: screenWidth * 0.08,
          color: Colors.white,
        ),
      );
    }
  }
}