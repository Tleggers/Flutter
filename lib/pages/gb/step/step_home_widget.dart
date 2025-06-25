import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:intl/intl.dart';

import 'package:trekkit_flutter/pages/gb/step/step_provider.dart';
import 'package:trekkit_flutter/functions/jh/userprovider.dart';

class StepHomeWidget extends StatelessWidget {
  const StepHomeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final stepProvider = Provider.of<StepProvider>(context);
    if (!stepProvider.isLoaded) {
      return const Center(child: CircularProgressIndicator());
    }

    final current = stepProvider.dailyTotal;
    final goal = stepProvider.goalInMeters;
    final percent = stepProvider.progressPercent;
    final userProvider = Provider.of<UserProvider>(context);
    final isLoggedIn = userProvider.isLoggedIn;

    final formatter = NumberFormat('#,###');

    return GestureDetector(
      onTap: () {
        if (isLoggedIn) {
          Navigator.pushNamed(context, '/stepDetail');
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('로그인 후 이용 가능합니다')));
        }
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 176, 206, 170),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '걸음 수',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),

            // ✅ 숫자 표시 라인 (current / goal)
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  formatter.format(current),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(width: 4), // 숫자 사이 간격
                Text(
                  '/ ${formatter.format(goal)}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black54, // 연한 텍스트
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // ✅ 게이지바: 숫자 라인과 정확히 정렬되게
            LinearPercentIndicator(
              lineHeight: 8.0,
              percent: percent,
              backgroundColor: Colors.grey[300],
              progressColor: Colors.deepOrange,
              barRadius: const Radius.circular(16),
              padding: EdgeInsets.zero, // ✅ 좌우 간격 제거 → 숫자라인과 정렬
            ),
          ],
        ),
      ),
    );
  }
}
