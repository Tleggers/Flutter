// lib/services/jw/AuthService.dart
import 'package:http/http.dart' as http;
import 'package:trekkit_flutter/functions/jh/userprovider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trekkit_flutter/services/jw/PostService.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// 사용자 인증 및 로그인 상태를 관리하는 서비스 클래스입니다.
/// 싱글톤 패턴으로 구현되어 앱 전체에서 단일 인스턴스를 사용합니다.
class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._internal();

  factory AuthService() => _instance;

  AuthService._internal();

  String? _jwtToken;
  String? get jwtToken => _jwtToken;

  String get API_URL {
    return dotenv.env['API_URL'] ??
        "http://localhost:30000"; // 기본값을 설정하거나 오류 처리
  }

  Future<void> _loadTokenAndUserInfo() async {
    final prefs = await SharedPreferences.getInstance();

    _jwtToken = prefs.getString('token');

    if (prefs.getString('nickname') == null ||
        prefs.getString('logintype') == null ||
        prefs.getInt('index') == null) {
      _jwtToken = null;
    }
  }

  Future<void> _deleteToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('nickname');
    await prefs.remove('profile');
    await prefs.remove('logintype');
    await prefs.remove('index');
    await prefs.remove('point');
    await prefs.remove('jwtToken');
  }

  Future<void> checkLoginStatus(BuildContext context) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await _loadTokenAndUserInfo();

    if (_jwtToken == null) {
      userProvider.logout();
      return;
    }

    try {
      // API_URL을 사용할 때 get API_URL getter를 통해 가져옵니다.
      await PostService.getPosts(page: 0, size: 1, context: context);

      final prefs = await SharedPreferences.getInstance();
      final String? nickname = prefs.getString('nickname');
      final String? profile = prefs.getString('profile');
      final String? logintype = prefs.getString('logintype');
      final int? index = prefs.getInt('index');
      final int? point = prefs.getInt('point');

      if (nickname != null && logintype != null && index != null) {
        userProvider.login(
          _jwtToken!,
          nickname,
          profile ?? '',
          logintype,
          index,
          point ?? 0,
        );
      } else {
        await logout(context);
      }
    } catch (e) {
      print('AuthService: API 검증 실패 ($e) -> 하지만 클라이언트 로그인 상태는 유지');
    }

    notifyListeners();
  }

  Future<void> logout(BuildContext context) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    try {
      // API_URL을 사용할 때 get API_URL getter를 통해 가져옵니다.
      await http.post(
        Uri.parse('${API_URL}/logout'), // API_URL을 getter로 호출
        headers: {
          'X-Client-Type': 'mobile',
          if (_jwtToken != null) 'Authorization': 'Bearer $_jwtToken',
        },
      );
    } catch (e) {
      print('AuthService: 백엔드 로그아웃 요청 중 오류 발생: $e');
    } finally {
      _jwtToken = null;
      await _deleteToken();
      userProvider.logout();
      notifyListeners();
    }
  }
}
