import 'dart:async';
import 'package:pedometer/pedometer.dart';
import 'package:flutter/foundation.dart';
import 'package:trekkit_flutter/pages/gb/step/step_provider.dart';

/// 실제 걸음 수 센서에서 데이터를 받아오는 서비스 클래스
class StepService {
  static final StepService _instance = StepService._internal();
  factory StepService() => _instance;
  StepService._internal();

  StreamSubscription<StepCount>? _stepSubscription;
  int? _initialStep;

  void startListening(StepProvider provider) {
    if (_stepSubscription != null) return; // ✅ 이미 리스닝 중이면 재등록 방지

    const double strideLengthInMeters = 0.78;

    _stepSubscription = Pedometer.stepCountStream.listen(
      (StepCount event) {
        print('📥 걸음 수 감지: ${event.steps} - ${event.timeStamp}'); // 🟡 이 줄 추가

        _initialStep ??= event.steps;

        int stepCount = event.steps - _initialStep!;
        if (stepCount < 0) stepCount = 0;

        int distanceMeters = (stepCount * strideLengthInMeters).toInt();

        provider.updateSteps(distanceMeters);
      },
      onError: (error) => print('걸음 수 수신 오류: $error'),
      onDone: () {
        print('걸음 수 스트림 종료');
        _stepSubscription = null;
      },
      cancelOnError: true,
    );
  }

  void stopListening() {
    _stepSubscription?.cancel();
    _stepSubscription = null;
    _initialStep = null;
  }
}
