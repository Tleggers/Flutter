import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trekkit_flutter/pages/gb/step/step_provider.dart';

class StepGoalBottomSheet extends StatefulWidget {
  const StepGoalBottomSheet({super.key});

  @override
  State<StepGoalBottomSheet> createState() => _StepGoalBottomSheetState();
}

class _StepGoalBottomSheetState extends State<StepGoalBottomSheet> {
  late int goal;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<StepProvider>(context, listen: false);
    goal = provider.goalInMeters; // 현재 설정된 목표로 초기화
  }

  void _increase() {
    setState(() {
      goal += 100;
    });
  }

  void _decrease() {
    setState(() {
      if (goal > 100) goal -= 100;
    });
  }

  @override
  Widget build(BuildContext context) {
    final stepProvider = Provider.of<StepProvider>(context, listen: false);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            '하루 걸음 수 목표 설정',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle, size: 32),
                onPressed: _decrease,
              ),
              const SizedBox(width: 20),
              Text(
                '$goal m',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 20),
              IconButton(
                icon: const Icon(Icons.add_circle, size: 32),
                onPressed: _increase,
              ),
            ],
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: () {
              stepProvider.setGoal(goal); // 목표 저장
              Navigator.pop(context); // 바텀시트 닫기
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 62, 20, 134), // 버튼 배경색
                borderRadius: BorderRadius.circular(8), // 덜 둥글게
              ),
              child: const Center(
                child: Text(
                  '설정 완료하기',
                  style: TextStyle(
                    color: Colors.white, // 버튼 글씨 흰색
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
