import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

/// 🚶 StepProvider: 걸음 수 상태 및 서버 전송 관리
/// - 비로그인 시에도 동작 가능
/// - 로그인 시(userId 세팅 시)에만 서버 전송 허용
class StepProvider with ChangeNotifier {
  int _currentStep = 0; // 오늘 걸은 거리
  int _dailyTotal = 0; // 오늘 누적 거리 (DB 저장용)
  int _goalInMeters = 3000; // 목표 거리 (기본값: 3km)

  int? _userId; // 로그인된 유저 ID (비로그인 시 null)
  DateTime _lastUpdated = DateTime.now(); // 마지막 업데이트 날짜

  // 외부에서 접근 가능한 Getter
  int get currentStep => _currentStep;
  int get dailyTotal => _dailyTotal;
  int get goalInMeters => _goalInMeters;
  int get yesterdayStep => 1800; // 추후 DB에서 동적으로 불러오기

  /// 📊 게이지 비율 (0.0 ~ 1.0 사이)
  double get progressPercent => (_currentStep / _goalInMeters).clamp(0.0, 1.0);

  /// ✅ userId 등록 (로그인 시에만 호출)
  void setUserId(int id) {
    _userId = id;
  }

  /// ✅ 목표 거리 SharedPreferences에서 불러오기 (앱 실행 시)
  Future<void> loadGoalFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _goalInMeters = prefs.getInt('goal') ?? 3000;
    notifyListeners();
  }

  /// ✅ 목표 거리 설정 + SharedPreferences에 저장
  Future<void> setGoal(int meters) async {
    _goalInMeters = meters;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('goal', meters);
  }

  /// 🏃 센서로부터 걸음 수(거리) 업데이트 시 호출
  void updateSteps(int stepInMeters) {
    final now = DateTime.now();

    // 🕛 날짜가 바뀐 경우 처리
    if (!_isSameDay(_lastUpdated, now)) {
      final yesterdayDate = _lastUpdated; // ✅ 전날 날짜 저장
      final yesterdayDistance = _dailyTotal; // ✅ 전날 거리 저장

      // 💾 로그인 상태일 경우 → 어제 데이터 서버 전송
      if (_userId != null) {
        _sendYesterdayDataToServer(
          date: yesterdayDate,
          distance: yesterdayDistance,
        );
      }

      // ✅ 오늘 날짜 기준으로 초기화
      _currentStep = 0;
      _dailyTotal = 0;

      _lastUpdated = now;
    }

    // 오늘 걸음 수 및 누적값 갱신
    _currentStep = stepInMeters;
    _dailyTotal = stepInMeters; // ✅ 센서 값은 원래 누적값이기 때문에 그대로 사용
    notifyListeners();
  }

  /// 🧹 전체 초기화 함수 (선택적으로 사용 가능)
  void resetAll() {
    _currentStep = 0;
    _dailyTotal = 0;
    _goalInMeters = 3000;
    _lastUpdated = DateTime.now();
    notifyListeners();
  }

  /// 📅 날짜 비교 함수 (년/월/일만 비교)
  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// 🛰️ 서버에 어제 걸음 수 전송 (로그인 유저만)
  Future<void> _sendYesterdayDataToServer({
    required DateTime date,
    required int distance,
  }) async {
    if (_userId == null) return;

    final walkDate = date.toIso8601String().split("T")[0]; // yyyy-MM-dd

    // TODO: 여기에서 실제 POST 요청 (Spring API 연동)
    print('📡 서버로 전송: user_id=$_userId, date=$walkDate, distance=$distance');

    final baseUrl = dotenv.env['API_URL']!; // 여기서 ! << 절대 null이면 안된다는 의미
    final url = Uri.parse('$baseUrl/step/save');

    try {
      final response = await http.post(
        url, // 🛠️ 실제 배포시 서버 주소로 변경
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': _userId,
          'walkDate': walkDate,
          'distance': distance,
        }),
      );

      if (response.statusCode == 200) {
        print('✅ 서버 전송 성공!');
      } else {
        print('❌ 서버 전송 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('🚨 네트워크 오류: $e');
    }
  }

  /// 📥 서버에서 오늘 거리 가져오기
  Future<void> fetchTodayStepFromServer() async {

    if (_userId == null) return;

    final baseUrl = dotenv.env['API_URL']!; // 여기서 ! << 절대 null이면 안된다는 의미
    final today = DateTime.now().toIso8601String().split("T")[0]; // yyyy-MM-dd
    final url = Uri.parse('$baseUrl/step/daily?userId=$_userId&walkDate=$today');

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
