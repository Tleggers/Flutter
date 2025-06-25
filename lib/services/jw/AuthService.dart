// lib/services/jw/AuthService.dart
import 'package:http/http.dart' as http;
import 'package:trekkit_flutter/functions/jh/userprovider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trekkit_flutter/services/jw/PostService.dart'; // PostService를 사용하여 토큰 유효성 검증

const String API_URL = "http://10.0.2.2:30000"; // 백엔드 API 기본 URL

/// 사용자 인증 및 로그인 상태를 관리하는 서비스 클래스입니다.
/// 싱글톤 패턴으로 구현되어 앱 전체에서 단일 인스턴스를 사용합니다.
class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._internal(); // 싱글톤 인스턴스

  factory AuthService() => _instance; // 팩토리 생성자

  AuthService._internal(); // 내부 생성자

  String? _jwtToken; // 현재 로그인된 사용자의 JWT 토큰
  String? get jwtToken => _jwtToken; // JWT 토큰 Getter

  /// SharedPreferences에서 JWT 토큰 및 사용자 필수 정보를 로드합니다.
  /// 필수 정보가 누락된 경우 토큰을 무효화하여 로그인 상태를 해제합니다.
  Future<void> _loadTokenAndUserInfo() async {
    final prefs = await SharedPreferences.getInstance();

    _jwtToken = prefs.getString('token'); // 'token' 키로 저장된 JWT 토큰 로드

    // 닉네임, 로그인 타입, 인덱스 등 필수 정보 중 하나라도 없으면 토큰 무효화
    if (prefs.getString('nickname') == null ||
        prefs.getString('logintype') == null ||
        prefs.getInt('index') == null) {
      _jwtToken = null;
    }
  }

  /// SharedPreferences에서 모든 로그인 관련 정보를 삭제합니다.
  Future<void> _deleteToken() async {
    final prefs = await SharedPreferences.getInstance();
    // SharedPreferences에 저장된 모든 로그인 관련 키 삭제
    await prefs.remove('token');
    await prefs.remove('nickname');
    await prefs.remove('profile');
    await prefs.remove('logintype');
    await prefs.remove('index');
    await prefs.remove('point');
    await prefs.remove('jwtToken'); // 이전 버전과의 호환성을 위한 키 삭제
  }

  /// 앱 시작 시 호출되어 로그인 상태를 확인하고 유지합니다.
  /// 로컬에 저장된 토큰의 유효성을 백엔드 API 호출을 통해 검증합니다.
  Future<void> checkLoginStatus(BuildContext context) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await _loadTokenAndUserInfo(); // 로컬에 저장된 토큰 및 사용자 정보 로드

    // 로컬에 토큰이 없으면 즉시 로그아웃 처리
    if (_jwtToken == null) {
      userProvider.logout();
      return; // 더 이상 진행하지 않고 종료
    }

    try {
      // PostService의 getPosts API 호출을 통해 토큰 유효성 검증 시도
      // (게시글 목록을 가져오는 데 성공하면 토큰이 유효한 것으로 간주)
      await PostService.getPosts(page: 0, size: 1, context: context);

      // 토큰이 유효하므로, 로컬에 저장된 정보를 기반으로 UserProvider 상태를 업데이트
      final prefs = await SharedPreferences.getInstance();
      final String? nickname = prefs.getString('nickname');
      final String? profile = prefs.getString('profile');
      final String? logintype = prefs.getString('logintype');
      final int? index = prefs.getInt('index');
      final int? point = prefs.getInt('point');

      // 필수 사용자 정보가 모두 존재하면 UserProvider에 로그인 상태 설정
      if (nickname != null && logintype != null && index != null) {
        userProvider.login(
          _jwtToken!,
          nickname,
          profile ?? '', // 프로필이 null일 경우 빈 문자열 사용
          logintype,
          index,
          point ?? 0, // 포인트가 null일 경우 0 사용
        );
      } else {
        // API 호출은 성공했으나 로컬 사용자 정보가 불완전한 경우, 로그아웃 절차 실행
        await logout(context);
      }
    } catch (e) {
      // API 호출 실패 시 (네트워크 오류, 서버 다운 등)
      // 사용자에게 불편을 주지 않기 위해 로컬에 저장된 정보로 로그인을 유지합니다.
      // 특정 에러 코드(예: 401 Unauthorized)에 따라 분기 처리도 가능합니다.
      print('AuthService: API 검증 실패 ($e) -> 하지만 클라이언트 로그인 상태는 유지');
    }

    notifyListeners(); // 상태 변경을 리스너들에게 알림
  }

  /// 사용자 로그아웃을 처리합니다.
  /// 백엔드에 로그아웃 요청을 보내고, 클라이언트 측의 모든 로그인 정보를 삭제합니다.
  Future<void> logout(BuildContext context) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    try {
      // 백엔드에 로그아웃 요청 전송
      await http.post(
        Uri.parse('$API_URL/logout'),
        headers: {
          'X-Client-Type': 'mobile',
          if (_jwtToken != null)
            'Authorization': 'Bearer $_jwtToken', // 토큰이 있다면 포함
        },
      );
    } catch (e) {
      print('AuthService: 백엔드 로그아웃 요청 중 오류 발생: $e');
    } finally {
      // 서버 요청 성공 여부와 관계없이 클라이언트 측 데이터는 항상 삭제
      _jwtToken = null;
      await _deleteToken(); // SharedPreferences에서 모든 로그인 정보 삭제
      userProvider.logout(); // UserProvider 상태 로그아웃으로 변경
      notifyListeners(); // 상태 변경을 리스너들에게 알림
    }
  }
}
