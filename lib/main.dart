import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trekkit_flutter/pages/gb/suggest/suggest_region_selection_page.dart';
import 'package:trekkit_flutter/pages/mainpage.dart';
import 'package:trekkit_flutter/pages/gb/step/step_detail_page.dart';
import 'package:trekkit_flutter/pages/gb/step/step_provider.dart';
import 'package:trekkit_flutter/pages/sh/map_page.dart';
import 'package:trekkit_flutter/pages/gb/suggest/suggest_region_list_page.dart';

import 'functions/jh/userprovider.dart';

// 네이버 맵 SDK 임포트 추가
import 'package:flutter_naver_map/flutter_naver_map.dart';

import 'package:trekkit_flutter/services/sh/mountain_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // .env 파일에서 환경 변수 로드
  await dotenv.load(fileName: ".env");

  // 카카오 네이티브 키 로드
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

  // 네이버 맵 API 키 로드
  final naverMapClientId =
      dotenv.env['NAVER_MAP_CLIENT_ID']; // `NAVER_MAP_CLIENT_ID`로 변수명 수정

  if (naverMapClientId == null || naverMapClientId.isEmpty) {
    throw Exception("NAVER_MAP_CLIENT_ID is missing from .env file.");
  }

  // 네이버 맵 SDK 초기화
  await FlutterNaverMap().init(
    clientId: naverMapClientId,
    onAuthFailed: (ex) {
      print("네이버맵 인증오류 : $ex");
    },
  );

  //20250612 추가
  //100대 명산 정보 호출
  final mountains = await MountainService.fetchTop100WithFullInfo();
    for (var m in mountains) {
      print('📌 ${m.name} → ${m.latitude}, ${m.longitude}');
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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      home: MainPage(title: 'TrekKit'),
      routes: {
        '/stepDetail': (context) => const StepDetailPage(), // ← 0609 만보기 상세페이지
        '/suggestRegionSelection':
            (context) => const SuggestRegionSelectionPage(), // 네이버 맵 페이지 추가
      },
    );
  }
}
