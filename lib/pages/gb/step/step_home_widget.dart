import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:trekkit_flutter/pages/gb/step/step_provider.dart'; // 상태 관리 Provider

class StepHomeWidget extends StatelessWidget {
  const StepHomeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // 상태를 가져옴 (걸음 수와 목표 거리 등)
    final stepProvider = Provider.of<StepProvider>(context);
    final current = stepProvider.currentStep; // 현재 걸음(m)
    final goal = stepProvider.goalInMeters; // 목표 거리(m)
    final percent = stepProvider.progressPercent; // 퍼센트 비율 (0.0 ~ 1.0)

    // 로그인 여부 (임시로 false → 전체 접근 허용)
    // final bool isLoggedIn = false; // TODO: 나중에 UserProvider로 대체

    return GestureDetector(
      onTap: () {
        // ✅ 현재는 로그인 여부 확인 없이 무조건 상세 페이지로 이동
        Navigator.pushNamed(context, '/stepDetail');

        // 🔒 로그인 여부 체크 (추후 적용)
        /*
        if (isLoggedIn) {
          // 로그인된 상태 → 상세 페이지로 이동
          Navigator.pushNamed(context, '/stepDetail');
        } else {
          // 로그인 안 된 상태 → 로그인 페이지로 이동 (추후 적용 예정)
          // Navigator.pushNamed(context, '/login');

          // 임시로 알림만 표시
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('로그인 후 이용 가능합니다')),
          );
        }
        */
      },
      child: Container(
        padding: const EdgeInsets.all(12), // 안쪽 여백
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 209, 198, 198), // 연한 초록색 배경
          borderRadius: BorderRadius.circular(12), // 둥근 테두리
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // 왼쪽 정렬
          children: [
            const Text(
              '오늘 걸음수',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              '$current m / $goal m',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            LinearPercentIndicator(
              lineHeight: 8.0,
              percent: percent,
              backgroundColor: Colors.grey[300],
              progressColor: Colors.green,
              barRadius: const Radius.circular(16),
            ),
          ],
        ),
      ),
    );
  }
}
