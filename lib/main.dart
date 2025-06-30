import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trekkit_flutter/pages/gb/region_map_page.dart';
import 'package:trekkit_flutter/pages/mainpage.dart';
import 'package:trekkit_flutter/pages/gb/step/step_detail_page.dart';
import 'package:trekkit_flutter/pages/gb/step/step_provider.dart';

import 'api/step_api.dart';
import 'functions/jh/userprovider.dart';

// 네이버 맵 SDK import
import 'package:flutter_naver_map/flutter_naver_map.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('ko', null); // ✅ 한글 로케일 초기화

  await requestActivityPermission(); // 만보기 권한 요청

  // .env 파일에서 환경 변수 로드
  await dotenv.load(fileName: ".env");

  final userProvider = await restoreUser();

  // 카카오 네이티브 키 로드
  final kakaoKey = dotenv.env['KAKAO_NATIVE_KEY'];
  if (kakaoKey == null || kakaoKey.isEmpty) {
    throw Exception("KAKAO_NATIVE_KEY is missing from .env file.");
  }

  KakaoSdk.init(nativeAppKey: kakaoKey);

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

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => userProvider), // 로그인 상태
        ChangeNotifierProvider(
          create: (_) => StepProvider(userProvider: userProvider),
        ), // 0609 만보기 상태
      ],
      child: const MyApp(),
    ),
  );
}

///  로그인 상태 복원 함수
Future<UserProvider> restoreUser() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');
  final nickname = prefs.getString('nickname');
  final profile = prefs.getString('profile');
  final logintype = prefs.getString('logintype');
  final index = prefs.getInt('index');
  final point = prefs.getInt('point');

  final userProvider = UserProvider();

  if (token != null && index != null) {
    userProvider.login(
      token,
      nickname ?? '',
      profile ?? '',
      logintype ?? '',
      index,
      point ?? 0,
    );
  }

  return userProvider;
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TrekKit',
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      theme: ThemeData(
        fontFamily: 'Hakgyo', // 앱 전체 폰트
      ),
      home: MainPage(title: 'TrkKit'),
      routes: {
        '/stepDetail': (context) => const StepDetailPage(), // ← 0609 만보기 상세페이지
        '/suggestRegionSelection':
            (context) => const RegionMap(), // 네이버 맵 페이지 추가
      },
    );
  }
}
