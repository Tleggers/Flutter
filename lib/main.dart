import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trekkit_flutter/pages/MainPage.dart';
import 'package:trekkit_flutter/pages/gb/step/step_detail_page.dart';
import 'package:trekkit_flutter/pages/gb/step/step_provider.dart';

import 'functions/jh/UserProvider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  final kakaoKey = dotenv.env['KAKAO_NATIVE_KEY'];

  if (kakaoKey == null || kakaoKey.isEmpty) {
    throw Exception("KAKAO_NATIVE_KEY is missing from .env file.");
  }

  KakaoSdk.init(nativeAppKey: kakaoKey);

  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');
  final nickname = prefs.getString('nickname');
  final profile = prefs.getString('profile');
  final logintype = prefs.getString('logintype');
  final index = prefs.getInt('index');

  final userProvider = UserProvider();

  if (token != null && token.isNotEmpty && index != null) {
    userProvider.login(
      token,
      nickname ?? '',
      profile ?? '',
      logintype ?? '',
      index,
    );
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => userProvider), // 로그인 상태
        ChangeNotifierProvider(create: (_) => StepProvider()), // 0609 만보기 상태
      ],
      child: const MyApp(),
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
      routes: {
        '/stepDetail': (context) => const StepDetailPage(), // ← 0609 만보기 상세페이지
      },
    );
  }
}
