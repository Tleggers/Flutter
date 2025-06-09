import 'dart:async';

// 타이머
class AuthTimer {
  int _secondsRemaining = 0;
  Timer? _timer;

  // 타이머 시작
  void start(Function update) {
    _secondsRemaining = 180;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining == 0) {
        timer.cancel();
      } else {
        _secondsRemaining--;
        update(); // 화면 업데이트용 콜백
      }
    });
  }

  // 타이머 멈추기
  void cancel() {
    _timer?.cancel();
  }

  // 시간 포맷(mm:ss)
  String get formattedTime {
    final minutes = (_secondsRemaining ~/ 60).toString().padLeft(2, '0');
    final seconds = (_secondsRemaining % 60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  // 시간이 0초 이상일 때만 실행
  bool get isRunning => _secondsRemaining > 0;

}