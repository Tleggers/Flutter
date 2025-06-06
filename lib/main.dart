import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trekkit_flutter/pages/MainPage.dart';

import 'functions/jh/Login/UserProvider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  KakaoSdk.init(nativeAppKey: '07f1249d85be7b1d16504c545410ecb6');

  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');
  final nickname = prefs.getString('nickname');
  final profile = prefs.getString('profile');
  final logintype = prefs.getString('logintype');

  final userProvider = UserProvider();

  if (token != null && token.isNotEmpty) {
    userProvider.login(token, nickname ?? '', profile ?? '', logintype ?? '');
  }

  runApp(
    ChangeNotifierProvider(
      create: (_) => userProvider,
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      home: MainPage(title: 'TrekKit'),

    );
  }
}