import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:trekkit_flutter/main.dart';
import 'package:provider/provider.dart';

import '../../../functions/jh/userprovider.dart';

class StepProvider with ChangeNotifier {
  StepProvider() {
    loadRewardedStatus(); // ✅ 보상 상태 로드
    loadTodayDistanceFromPrefs(); // ✅ 걸음 수 로컬에서 불러오기
  }
  int _currentStep = 0; // 오늘 걸은 거리 (m)
  int _dailyTotal = 0; // 오늘 누적 거리 (m)
  int _goalInMeters = 3000; // 기본 목표 거리 (3km)

  int? _userId; // 로그인된 유저 ID (없으면 null)
  DateTime _lastUpdated = DateTime.now(); // 마지막 업데이트 일시

  bool _alreadyRewarded = false; // 포인트 보상 지급 여부 (앱 재시작 전까지 유효)

  //선택 날짜 걸음수 저장용 변수
  int? _selectedDateStep;
  int? get selectedDateStep => _selectedDateStep;

  //전날 걸음 수 변수 추가
  int _previousDateStep = 0;
  int get previousDateStep => _previousDateStep;

  // 👉 외부에서 접근 가능한 getter
  int get currentStep => _currentStep;
  int get dailyTotal => _dailyTotal;
  int get goalInMeters => _goalInMeters;
  int yesterdayStep = 0;
  double get progressPercent {
    if (_goalInMeters <= 0) return 0.0;
    return (_currentStep / _goalInMeters).clamp(0.0, 1.0);
  }

  // ✅ 로그인 시 userId를 세팅
  void setUserId(int id) {
    _userId = id;
  }

  bool _isLoaded = false;
  bool get isLoaded => _isLoaded;

  // 앱 시작 시 저장된 걸음 수를 불러오는 함수
  Future<void> loadTodayDistanceFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split("T")[0];
    final saved = prefs.getInt('distance_$today');

    if (saved != null) {
      _currentStep = saved;
      _dailyTotal = saved;
      notifyListeners();
      print('📥 로컬에서 오늘 걸음 수 불러옴: $saved m');
    } else {
      print('📭 저장된 거리 없음');
    }

    _isLoaded = true;
    notifyListeners();
  }

  // ✅ SharedPreferences에서 목표 거리 로드
  Future<void> loadGoalFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _goalInMeters = prefs.getInt('goal') ?? 3000;
    notifyListeners();
  }

  // ✅ 목표 거리 저장 + 반영
  Future<void> setGoal(int meters) async {
    _goalInMeters = meters;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('goal', meters);
  }

  /// ✅ SharedPreferences에서 보상 지급 상태 로드
  Future<void> loadRewardedStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split("T")[0];
    _alreadyRewarded = prefs.getBool('rewarded_$today') ?? false;
    notifyListeners();
  }

  /// ✅ SharedPreferences에 보상 지급 상태 저장
  Future<void> saveRewardedStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split("T")[0];
    await prefs.setBool('rewarded_$today', true);
  }

  Future<void> _saveTodayDistanceToPrefs(int meters) async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split("T")[0];
    await prefs.setInt('distance_$today', meters);
  }

  // ✅ 걸음 수 업데이트 호출 시
  Future<bool> updateSteps(int stepInMeters, BuildContext context) async {
    final now = DateTime.now();

    final baseUrl = dotenv.env['API_URL']!; // 백엔드 url

    final userid = userProvider.index; // 유저 인덱스
    final token = userProvider.token; // 토큰

    // 🕛 날짜가 바뀐 경우 → 초기화 + 전날 서버 저장
    if (!_isSameDay(_lastUpdated, now)) {
      final yesterdayDate = _lastUpdated;
      final yesterdayDistance = _dailyTotal;

      if (_userId != null) {
        _sendYesterdayDataToServer(
          date: yesterdayDate,
          distance: yesterdayDistance,
        );
      }

      _currentStep = 0;
      _dailyTotal = 0;
      _alreadyRewarded = false; // 보상 초기화
      _lastUpdated = now;
    }

    // ✅ 오늘 거리 누적값 반영
    _currentStep = stepInMeters;
    _dailyTotal = stepInMeters;
    _saveTodayDistanceToPrefs(stepInMeters); // 만보기 거리 저장되게
    notifyListeners();

    // ✅ 1000m 이상 걷고 아직 보상 안 했으면 → 팝업 + 서버 전송
    if (_dailyTotal >= 10 && !_alreadyRewarded) {
      _alreadyRewarded = true;
      saveRewardedStatus(); // 보상 지급 여부
      _sendTodayStepToServer(rewarded: true);
    }

    notifyListeners();
  }

  // ✅ 오늘의 모든 상태 초기화
  void resetAll() {
    _currentStep = 0;
    _dailyTotal = 0;
    _goalInMeters = 3000;
    _lastUpdated = DateTime.now();
    _alreadyRewarded = false;
    notifyListeners();
  }

  // ✅ 날짜 비교 함수 (년/월/일 기준 동일 여부)
  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  // ✅ 어제 거리 서버 전송 (자정 넘을 때)
  Future<void> _sendYesterdayDataToServer({
    required DateTime date,
    required int distance,
  }) async {
    if (_userId == null) return;

    final walkDate = date.toIso8601String().split("T")[0];
    final baseUrl = dotenv.env['API_URL']!;
    final url = Uri.parse('$baseUrl/step/save');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': _userId,
          'walkDate': walkDate,
          'distance': distance,
          'rewarded': false, // 자정 저장은 보상 아님
        }),
      );

      if (response.statusCode == 200) {
        print('✅ 전날 기록 저장 성공');
      } else {
        print('❌ 전날 기록 저장 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('🚨 네트워크 오류: $e');
    }
  }

  // ✅ 보상과 함께 오늘 거리 서버 전송
  Future<void> _sendTodayStepToServer({required bool rewarded}) async {
    if (_userId == null) return;

    final walkDate = DateTime.now().toIso8601String().split("T")[0];
    final baseUrl = dotenv.env['API_URL']!;
    final url = Uri.parse('$baseUrl/step/save');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': _userId,
          'walkDate': walkDate,
          'distance': _dailyTotal,
          'rewarded': rewarded,
        }),
      );

      if (response.statusCode == 200) {
        print('✅ 오늘 기록 저장 완료');
      } else {
        print('❌ 오늘 기록 저장 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('🚨 네트워크 오류: $e');
    }
  }

  // ✅ 1000m 보상 팝업 표시
  void showRewardPopup() {
    final context = navigatorKey.currentContext;
    if (context == null) return;

    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('🎉 포인트 지급 완료'),
            content: const Text('오늘 1000m 이상 걸어 100포인트가 지급되었습니다!'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('확인'),
              ),
            ],
          ),
    );
  }

  /// ✅ 서버에서 어제 걸음 수 조회 (예: 비교용, 통계용 등)
  Future<void> fetchYesterdayStepFromServer() async {
    if (_userId == null) return;

    final baseUrl = dotenv.env['API_URL']!;
    final yesterday =
        DateTime.now()
            .subtract(const Duration(days: 1))
            .toIso8601String()
            .split("T")[0];

    final url = Uri.parse(
      '$baseUrl/step/daily?userId=$_userId&walkDate=$yesterday',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        if (response.body.isNotEmpty) {
          final json = jsonDecode(response.body);
          yesterdayStep = json['distance'] ?? 0;
          print('📥 어제 걸음 수 로드 완료: $yesterdayStep m');
        } else {
          // body가 비었을 경우 → 0으로 처리
          yesterdayStep = 0;
          print('📭 어제 걸음 수 없음 → 0으로 처리');
        }
      } else {
        print('❌ 어제 걸음 수 조회 실패: ${response.statusCode}');
      }

      notifyListeners(); // 위치 통합
    } catch (e) {
      print('🚨 네트워크 오류 (어제 걸음 수): $e');
    }
  }

  // ✅ 서버에서 오늘 거리 조회 (앱 시작 시 사용)
  Future<void> fetchTodayStepFromServer() async {
    if (_userId == null) return;

    final baseUrl = dotenv.env['API_URL']!;
    final today = DateTime.now().toIso8601String().split("T")[0];
    final url = Uri.parse(
      '$baseUrl/step/daily?userId=$_userId&walkDate=$today',
    );

    try {
      final response = await http.get(url);

        if (response.statusCode == 200) {
          final json = jsonDecode(response.body);
          _currentStep = json['distance'];
          notifyListeners();
        } else {
          print('❌ 오늘 걸음 수 조회 실패: ${response.statusCode}');
        }
      } catch (e) {
        print('🚨 네트워크 오류: $e');
      }
    }
  }
}
