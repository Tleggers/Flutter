import 'dart:async';
import 'package:pedometer/pedometer.dart';
import 'package:flutter/material.dart';
import 'package:trekkit_flutter/pages/gb/step/step_provider.dart';

/// 실제 걸음 수 센서에서 데이터를 받아오는 서비스 클래스
class StepService {
  static final StepService _instance = StepService._internal();
  factory StepService() => _instance;
  StepService._internal();

  StreamSubscription<StepCount>? _stepSubscription;
  int? _initialStep;

  /// 🚶 센서 시작: StepProvider와 BuildContext 함께 전달
  void startListening(StepProvider provider, BuildContext context) {
    if (_stepSubscription != null) return; // ✅ 중복 리스닝 방지

    const double strideLengthInMeters = 0.78; // 평균 보폭 길이

    _stepSubscription = Pedometer.stepCountStream.listen(
      (StepCount event) {
        print('📥 걸음 수 감지: ${event.steps} - ${event.timeStamp}');

        // 처음 감지된 걸음 수 저장
        _initialStep ??= event.steps;

        // 시작점 기준 걸음 수 계산
        int stepCount = event.steps - _initialStep!;
        if (stepCount < 0) stepCount = 0;

        // 걸은 거리 계산 (m 단위)
        int distanceMeters = (stepCount * strideLengthInMeters).toInt();

        // ✅ StepProvider 업데이트 (팝업 포함)
        provider.updateSteps(distanceMeters, context);
      },
      onError: (error) => print('🚨 걸음 수 수신 오류: $error'),
      onDone: () {
        print('✅ 걸음 수 스트림 종료');
        _stepSubscription = null;
      },
      cancelOnError: true,
    );
  }

  /// 센서 중지
  void stopListening() {
    _stepSubscription?.cancel();
    _stepSubscription = null;
    _initialStep = null;
  }
}
