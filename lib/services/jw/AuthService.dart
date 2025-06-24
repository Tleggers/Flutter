// lib/services/jw/AuthService.dart
import 'package:http/http.dart' as http; // HTTP 통신을 위한 패키지
import 'dart:convert'; // JSON 인코딩/디코딩을 위한 패키지
import 'package:trekkit_flutter/functions/jh/userprovider.dart'; // 사용자 상태 관리를 위한 UserProvider 임포트
import 'package:flutter/material.dart'; // Flutter UI 및 ChangeNotifier를 위한 패키지
import 'package:provider/provider.dart'; // Provider 패턴 사용을 위한 패키지
import 'package:shared_preferences/shared_preferences.dart'; // 로컬 데이터 저장을 위한 패키지
import 'package:trekkit_flutter/services/jw/PostService.dart'; // 토큰 유효성 간접 확인을 위해 PostService 임포트

const String API_URL = "http://10.0.2.2:30000"; // 백엔드 API의 기본 URL

/// 사용자 인증 및 로그인 상태를 관리하는 서비스 클래스입니다.
/// 싱글톤 패턴으로 구현되어 앱 전체에서 동일한 인스턴스를 사용합니다.
/// `ChangeNotifier`를 상속하여 로그인 상태 변경 시 관련 위젯에 알림을 보낼 수 있습니다.
class AuthService extends ChangeNotifier {
  // 싱글톤 인스턴스
  static final AuthService _instance = AuthService._internal();

  /// `AuthService`의 팩토리 생성자. 항상 동일한 싱글톤 인스턴스를 반환합니다.
  factory AuthService() {
    return _instance;
  }

  /// 내부 생성자. 외부에서 직접 인스턴스 생성을 막습니다.
  AuthService._internal();

  String? _jwtToken; // 현재 사용자의 JWT 토큰

  /// JWT 토큰을 외부에 노출하는 getter입니다.
  String? get jwtToken => _jwtToken;

  /// 로컬 저장소(`SharedPreferences`)에서 JWT 토큰 및 사용자 정보를 로드합니다.
  /// 앱 시작 시 호출되어 로그인 상태를 복원하는 데 사용됩니다.
  /// `handlelogin.dart`에서 저장하는 키(`token`, `nickname`, `profile`, `logintype`, `index`)와 호환됩니다.
  Future<void> _loadTokenAndUserInfo() async {
    debugPrint('AuthService: SharedPreferences에서 토큰 및 사용자 정보 로드 시도 중...');
    final prefs =
        await SharedPreferences.getInstance(); // SharedPreferences 인스턴스 가져오기

    // `handlelogin.dart`가 저장하는 'token' 키로 JWT 토큰 로드
    _jwtToken = prefs.getString('token'); // 'token' 키로 저장된 JWT 토큰 로드
    debugPrint(
      'AuthService: 로드된 JWT 토큰 (키 "token"): $_jwtToken',
    ); // 로드된 토큰 값 출력

    // UserProvider에 필요한 나머지 정보도 로드 (주석 처리된 부분은 현재 코드에서 직접 사용되지 않음)
    final String? nickname = prefs.getString(
      'nickname',
    ); // 'nickname' 키로 닉네임 로드
    final String? profile = prefs.getString('profile'); // 'profile' 키로 프로필 로드
    final String? logintype = prefs.getString(
      'logintype',
    ); // 'logintype' 키로 로그인 타입 로드
    final int? index = prefs.getInt('index'); // 'index' 키로 사용자 인덱스 로드

    // JWT 토큰과 필수 사용자 정보가 모두 존재하면 로드 성공으로 간주
    if (_jwtToken != null &&
        nickname != null &&
        logintype != null &&
        index != null) {
      debugPrint(
        'AuthService: SharedPreferences에서 사용자 정보 로드됨. JWT 토큰 존재.',
      ); // 로드 성공 메시지
    } else {
      _jwtToken = null; // 하나라도 없으면 토큰을 무효화하여 비로그인 상태로 만듦
      debugPrint('AuthService: 부분적 또는 사용자 정보 없음. 토큰 무효화.'); // 로드 실패 메시지
    }
  }

  /// 로컬 저장소에서 모든 로그인 관련 정보(토큰, 사용자 데이터)를 삭제합니다.
  /// 로그아웃 시 호출됩니다.
  Future<void> _deleteToken() async {
    debugPrint('AuthService: 모든 로그인 관련 토큰/정보 삭제 시도 중...'); // 삭제 시도 메시지
    final prefs =
        await SharedPreferences.getInstance(); // SharedPreferences 인스턴스 가져오기
    await prefs.remove('token'); // 'token' 키 삭제
    await prefs.remove('nickname'); // 'nickname' 키 삭제
    await prefs.remove('profile'); // 'profile' 키 삭제
    await prefs.remove('logintype'); // 'logintype' 키 삭제
    await prefs.remove('index'); // 'index' 키 삭제
    await prefs.remove('point'); // 'points' 키 삭제
    await prefs.remove(
      'jwtToken',
    ); // AuthService가 자체적으로 저장했을 수 있는 'jwtToken' 키도 삭제
    debugPrint('AuthService: 모든 로그인 관련 정보 삭제 완료.'); // 삭제 완료 메시지
  }

  /// 앱 시작 시 또는 로그인 상태가 필요할 때 호출되어 현재 로그인 상태를 확인합니다.
  /// 로컬에 저장된 토큰의 유효성을 간접적으로 검증하고, [UserProvider]의 상태를 업데이트합니다.
  Future<void> checkLoginStatus(BuildContext context) async {
    final userProvider = Provider.of<UserProvider>(
      context,
      listen: false,
    ); // UserProvider 인스턴스 가져오기

    await _loadTokenAndUserInfo(); // 로컬 저장소에서 토큰 및 사용자 정보 로드

    // 로드된 토큰이 없으면 로그아웃 처리
    if (_jwtToken == null) {
      debugPrint(
        'AuthService: checkLoginStatus - 로컬 토큰 없음. UserProvider 로그아웃 처리.',
      );
      userProvider.logout(); // UserProvider 로그아웃
      notifyListeners(); // 상태 변경 알림
      return; // 함수 종료
    }

    try {
      debugPrint(
        'AuthService: checkLoginStatus - PostService.getPosts를 통해 토큰 유효성 간접 확인 시도 중...',
      );

      // PostService.getPosts를 호출하여 토큰이 유효한지 간접적으로 확인합니다.
      // PostService.getPosts는 내부적으로 인증 헤더를 포함하여 요청을 보낼 것입니다.
      // 백엔드의 JWT 필터/인터셉터가 토큰의 유효성을 검사하고, 유효하면 정상 응답을 반환할 것이므로
      // 이 요청이 성공하면 토큰이 유효하다고 간주합니다.
      final Map<String, dynamic> response = await PostService.getPosts(
        page: 0, // 최소한의 데이터만 요청
        size: 1,
        context: context, // PostService.getPosts가 이제 context를 필수로 받음
      );

      debugPrint(
        'AuthService: checkLoginStatus - PostService.getPosts 성공. 토큰 유효한 것으로 보임.',
      );

      // 토큰이 유효하면 UserProvider에 필요한 사용자 정보를 다시 로드하여 업데이트합니다.
      final prefs =
          await SharedPreferences.getInstance(); // SharedPreferences 인스턴스 다시 가져오기
      final String? nickname = prefs.getString('nickname'); // 닉네임 로드
      final String? profile = prefs.getString('profile'); // 프로필 로드
      final String? logintype = prefs.getString('logintype'); // 로그인 타입 로드
      final int? index = prefs.getInt('index'); // 사용자 인덱스 로드
      final int? point = prefs.getInt('point'); // 포인트

      // 사용자 정보가 모두 유효하면 UserProvider를 통해 로그인 상태로 설정합니다.
      if (nickname != null && logintype != null && index != null) {
        userProvider.login(
          _jwtToken!, // SharedPreferences에서 로드한 토큰
          nickname, // 로드된 닉네임
          profile ?? '', // 프로필이 null일 경우 빈 문자열 전달 (UserProvider의 요구사항에 맞춤)
          logintype, // 로드된 로그인 타입
          index, // 로드된 사용자 인덱스
          point!, // 로드된 포인트
        );
        debugPrint(
          'AuthService: 로그인 상태 확인 성공 (간접 검증): $index (로그인됨)',
        ); // 성공 메시지
      } else {
        // 사용자 정보가 불완전하면 토큰을 무효화하고 로그아웃 처리합니다.
        debugPrint('AuthService: 간접 검증 후 사용자 정보 불완전. 로그아웃 처리.');
        _jwtToken = null; // 토큰 무효화
        await _deleteToken(); // 로컬 토큰 삭제
        userProvider.logout(); // UserProvider 로그아웃
      }
    } catch (e) {
      // 토큰 유효성 간접 검증 실패 시 (예: 네트워크 오류, 401 Unauthorized 등)
      debugPrint(
        'AuthService: checkLoginStatus - 간접 토큰 유효성 검증 실패: $e. 토큰 무효화.',
      );
      _jwtToken = null; // 토큰 무효화
      await _deleteToken(); // 로컬 토큰 삭제
      userProvider.logout(); // UserProvider 로그아웃
      debugPrint('AuthService: 로그인 상태 확인: (로그아웃됨)'); // 로그아웃 메시지
    }
    notifyListeners(); // 상태 변경 알림
  }

  /// 이 `login` 메서드는 현재 앱의 로그인 흐름에서 `handlelogin.dart`가 직접 로그인 API를 호출하므로 사용되지 않습니다.
  /// 하지만 파일 수정 제약으로 인해 제거할 수 없으며, 향후 `AuthService`가 직접 로그인 처리를 담당할 때 사용될 수 있습니다.
  Future<bool> login(
    BuildContext context,
    String username,
    String password,
  ) async {
    debugPrint(
      'AuthService: WARNING: AuthService.login 메서드가 호출되었습니다. 현재 설정에서는 handlelogin.dart가 로그인을 처리해야 합니다.',
    );
    return false; // 실제 로그인 처리를 하지 않으므로 항상 `false`를 반환
  }

  /// 현재 사용자를 로그아웃 처리하는 메서드입니다.
  /// 백엔드에 로그아웃 요청을 보내고, 로컬 저장소의 토큰 및 사용자 정보를 삭제하며,
  /// [UserProvider]의 상태를 로그아웃으로 업데이트합니다.
  Future<void> logout(BuildContext context) async {
    final userProvider = Provider.of<UserProvider>(
      context,
      listen: false,
    ); // UserProvider 인스턴스 가져오기
    try {
      debugPrint('AuthService: 로그아웃 요청 전송 중. 토큰: $_jwtToken'); // 로그아웃 요청 메시지
      final response = await http.post(
        // 백엔드 `/logout` 엔드포인트로 POST 요청
        Uri.parse('$API_URL/logout'), // 로그아웃 API URL
        headers: {
          'X-Client-Type': 'mobile', // 클라이언트 타입 헤더
          if (_jwtToken != null)
            'Authorization': 'Bearer $_jwtToken', // JWT 토큰이 있으면 인증 헤더 추가
        },
      );
      debugPrint(
        'AuthService: 로그아웃 응답 - 상태: ${response.statusCode}, 본문: ${utf8.decode(response.bodyBytes)}',
      ); // 응답 상태 및 본문 출력
    } catch (e) {
      debugPrint('AuthService: 로그아웃 요청 중 오류 발생: $e'); // 오류 메시지 출력
    } finally {
      _jwtToken = null; // 로컬 JWT 토큰 무효화
      await _deleteToken(); // 로컬 저장소에서 모든 토큰 및 사용자 정보 삭제
      userProvider.logout(); // UserProvider 로그아웃
      notifyListeners(); // 상태 변경 알림
      debugPrint('AuthService: 클라이언트 측 로그아웃 완료.'); // 클라이언트 측 로그아웃 완료 메시지
    }
  }

  /// `UserProvider`를 통해 로그인 여부를 반환하는 getter입니다.
  /// (현재 `UserProvider`에서 직접 로그인 상태를 확인하는 것이 아니라,
  /// `AuthService` 내부에서 관리되는 `_jwtToken`을 통해 확인하는 것이 더 일반적일 수 있습니다.
  /// 하지만 기존 코드에 맞춰 이 getter는 항상 `false`를 반환합니다.)
  bool get isLoggedInFromUserProvider {
    return false; // 이 getter는 항상 false를 반환하도록 기존 코드 유지
  }
}
