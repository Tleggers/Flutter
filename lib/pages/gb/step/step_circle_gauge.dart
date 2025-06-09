import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

/// 동그라미 게이지 위젯
/// 현재 거리와 목표 거리, 퍼센트 진행률을 받아 원형 게이지로 표시
class StepCircleGauge extends StatelessWidget {
  final int current; // 현재 걸은 거리 (m)
  final int goal; // 목표 거리 (m)
  final VoidCallback? onGoalTap; // 목표 거리 설정 아이콘 클릭 시 호출

  const StepCircleGauge({
    super.key,
    required this.current,
    required this.goal,
    this.onGoalTap,
  });

  @override
  Widget build(BuildContext context) {
    // 퍼센트 계산 (최소 0.0, 최대 1.0로 고정)
    final percent = (current / goal).clamp(0.0, 1.0);

    return CircularPercentIndicator(
      radius: 100.0, // 게이지 반지름
      lineWidth: 16.0, // 게이지 두께
      percent: percent, // 퍼센트 값
      animation: true,
      animationDuration: 600,

      // ⚪ 빈 게이지 배경 색 (연한 주황)
      backgroundColor: const Color.fromARGB(255, 241, 196, 128),

      // 🟠 채워진 게이지 색 (진한 주황)
      progressColor: Colors.deepOrange,

      circularStrokeCap: CircularStrokeCap.round, // 둥근 끝
      center: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            '오늘의 걸음수',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          // 현재 거리 / 목표 거리
          Text('$current m / $goal m', style: const TextStyle(fontSize: 14)),

          const SizedBox(height: 12), // ⬅️ 거리 아래에 여백 추가
          // ⬇️ "목표 - 0000 걸음 >" 텍스트 줄
          GestureDetector(
            onTap: onGoalTap,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '목표 - $goal 걸음',
                  style: const TextStyle(fontSize: 14, color: Colors.blue),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: Colors.blue,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
