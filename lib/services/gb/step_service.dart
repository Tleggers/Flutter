import 'dart:async';
import 'package:pedometer/pedometer.dart';
import 'package:flutter/foundation.dart';
import 'package:trekkit_flutter/pages/gb/step/step_provider.dart';

/// 실제 걸음 수 센서에서 데이터를 받아오는 서비스 클래스
class StepService {
  StreamSubscription<StepCount>? _stepSubscription;

  /// 걸음 수 센서 스트림 시작
  void startListening(StepProvider provider) {
    // 평균 보폭 (미터 기준) - 일반 성인 남성 기준 약 0.78m
    const double strideLengthInMeters = 0.78;

    _stepSubscription = Pedometer.stepCountStream.listen(
      (StepCount event) {
        int stepCount = event.steps;

        // 거리 계산 = 걸음 수 × 평균 보폭
        int distanceMeters = (stepCount * strideLengthInMeters).toInt();

        // 🌟 디버깅 로그 출력
        if (kDebugMode) {
          print('걸음 수: $stepCount');
          print('계산된 거리: $distanceMeters m');
        }

        // Provider에 거리 기준으로 업데이트
        provider.updateSteps(distanceMeters);
      },
      onError: (error) {
        if (kDebugMode) {
          print('걸음 수 수신 오류: $error');
        }
      },
      onDone: () {
        if (kDebugMode) {
          print('걸음 수 스트림 종료');
        }
      },
      cancelOnError: true,
    );
  }

  /// 센서 스트림 정지
  void stopListening() {
    _stepSubscription?.cancel();
  }
}
