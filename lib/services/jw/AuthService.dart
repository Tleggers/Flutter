// lib/services/jw/AuthService.dart
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:trekkit_flutter/functions/jh/userprovider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trekkit_flutter/services/jw/PostService.dart'; // PostService 임포트

const String API_URL = "http://10.0.2.2:30000"; // 백엔드 기본 URL

class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._internal();

  factory AuthService() {
    return _instance;
  }

  AuthService._internal();

  String? _jwtToken;

  String? get jwtToken => _jwtToken;

  // 1. 앱 시작 시 로컬 저장소에서 토큰 및 사용자 정보 로드 (handlelogin.dart와 호환)
  Future<void> _loadTokenAndUserInfo() async {
    print(
      'AuthService: Attempting to load token and user info from SharedPreferences...',
    );
    final prefs = await SharedPreferences.getInstance();

    // handlelogin.dart가 저장하는 'token' 키로 JWT 토큰 로드
    _jwtToken = prefs.getString('token');
    print('AuthService: Loaded JWT token (key "token"): $_jwtToken');

    // UserProvider에 필요한 나머지 정보도 로드
    final String? nickname = prefs.getString('nickname');
    final String? profile = prefs.getString('profile');
    final String? logintype = prefs.getString('logintype');
    final int? index = prefs.getInt('index'); // 'index'는 int로 저장됨

    // 로드된 정보가 있다면 UserProvider를 업데이트
    if (_jwtToken != null &&
        nickname != null &&
        logintype != null &&
        index != null) {
      print(
        'AuthService: User info loaded from SharedPreferences. JWT Token is present.',
      );
    } else {
      _jwtToken = null; // 하나라도 없으면 토큰 무효화
      print('AuthService: Partial or no user info found in SharedPreferences.');
    }
  }

  // 2. 토큰을 로컬 저장소에 저장 (AuthService가 로그인 처리를 직접 할 때 사용. 현재는 handlelogin.dart가 담당)
  Future<void> _saveToken(String token) async {
    print(
      'AuthService: This _saveToken method is not expected to be called by login process if handlelogin.dart is used.',
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('jwtToken', token); // AuthService가 자체적으로 저장할 때 사용할 키
    print('AuthService: Saved token using AuthService logic: $token');
  }

  // 3. 토큰을 로컬 저장소에서 삭제 (AuthService가 로그인 처리할 때 사용. 현재는 handlelogin.dart가 담당)
  Future<void> _deleteToken() async {
    print('AuthService: Attempting to delete all login related tokens/info...');
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token'); // handlelogin.dart가 저장하는 'token' 키 삭제
    await prefs.remove('nickname');
    await prefs.remove('profile');
    await prefs.remove('logintype');
    await prefs.remove('index');
    await prefs.remove('jwtToken'); // 혹시 AuthService가 자체적으로 저장한 키도 삭제
    print('AuthService: All login related info deleted.');
  }

  // 로그인 상태 확인 메서드 (앱 시작 시 호출됨)
  Future<void> checkLoginStatus(BuildContext context) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    await _loadTokenAndUserInfo(); // SharedPreferences에서 토큰 로드

    if (_jwtToken == null) {
      print(
        'AuthService: checkLoginStatus - No local token found. Logging out UserProvider.',
      );
      userProvider.logout();
      notifyListeners();
      return;
    }

    try {
      print(
        'AuthService: checkLoginStatus - Attempting to validate token via PostService.getPosts...',
      );

      // PostService.getPosts를 호출하여 토큰이 유효한지 간접적으로 확인
      // PostService.getPosts는 _getAuthHeaders()를 통해 Authorization 헤더를 보낼 것임.
      final Map<String, dynamic> response = await PostService.getPosts(
        page: 0,
        size: 1, // 최소한의 데이터만 요청
        context: context, // PostService.getPosts가 이제 context를 필수로 받음
      );

      // PostService.getPosts가 성공적으로 응답하면 토큰은 유효하다고 가정
      // (백엔드에서 JWT 필터/인터셉터가 토큰 유효성 검사 후 통과시켰을 것이므로)
      print(
        'AuthService: checkLoginStatus - PostService.getPosts successful. Token seems valid.',
      );

      // 토큰이 유효하면 사용자 정보를 다시 로드하여 UserProvider 업데이트
      final prefs = await SharedPreferences.getInstance();
      final String? nickname = prefs.getString('nickname');
      final String? profile = prefs.getString('profile');
      final String? logintype = prefs.getString('logintype');
      final int? index = prefs.getInt('index');

      if (nickname != null && logintype != null && index != null) {
        userProvider.login(
          _jwtToken!, // SharedPreferences에서 로드한 토큰
          nickname,
          profile ??
              '', // profile이 null일 경우 빈 문자열 전달 (UserProvider가 String?이 아닐 경우 대비)
          logintype,
          index,
        );
        print('AuthService: 로그인 상태 확인 성공 (간접 검증): $index (로그인됨)');
      } else {
        print(
          'AuthService: User info incomplete after indirect validation. Logging out.',
        );
        _jwtToken = null;
        await _deleteToken();
        userProvider.logout();
      }
    } catch (e) {
      print(
        'AuthService: checkLoginStatus - Indirect token validation failed: $e. Invalidating token.',
      );
      _jwtToken = null;
      await _deleteToken();
      userProvider.logout();
      print('AuthService: 로그인 상태 확인: (로그아웃됨)');
    }
    notifyListeners();
  }

  // 이 login 메서드는 이제 handlelogin.dart가 직접 호출하지 않으므로 사용되지 않습니다.
  // 하지만 제거할 수 없다는 제약 때문에 그대로 둡니다.
  // 이 메서드는 향후 AuthService가 직접 로그인 API를 호출하는 구조로 변경될 때 사용될 수 있습니다.
  Future<bool> login(
    BuildContext context,
    String username,
    String password,
  ) async {
    // 이 메서드는 현재 loginHandler에서 직접 호출되지 않으므로, 사실상 이 앱의 로그인 흐름에서는 사용되지 않습니다.
    // 하지만 파일 수정 제약 때문에 남겨둡니다.
    print(
      'AuthService: WARNING: AuthService.login method was called. In this setup, handlelogin.dart should be handling login.',
    );
    return false; // 실제 로그인 처리를 하지 않으므로 false 반환
  }

  // 로그아웃 메서드
  Future<void> logout(BuildContext context) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    try {
      print(
        'AuthService: logout - Sending logout request with token: $_jwtToken',
      );
      final response = await http.post(
        Uri.parse('$API_URL/logout'),
        headers: {
          'X-Client-Type': 'mobile', // 또는 'app'
          if (_jwtToken != null) 'Authorization': 'Bearer $_jwtToken',
        },
      );
      print(
        'AuthService: logout - Response Status: ${response.statusCode}, Body: ${utf8.decode(response.bodyBytes)}',
      );
    } catch (e) {
      print('AuthService: Error during logout request: $e');
    } finally {
      _jwtToken = null;
      await _deleteToken(); // 로컬 토큰 삭제
      userProvider.logout();
      notifyListeners();
      print('AuthService: Logout completed on client side.');
    }
  }

  bool get isLoggedInFromUserProvider {
    return false;
  }
}
