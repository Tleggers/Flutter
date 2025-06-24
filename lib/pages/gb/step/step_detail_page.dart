import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:trekkit_flutter/pages/gb/step/step_circle_gauge.dart';
import 'package:trekkit_flutter/pages/gb/step/step_goal_bottom_sheet.dart';
import 'package:trekkit_flutter/pages/gb/step/step_provider.dart';
import 'package:trekkit_flutter/utils/gb/step_motivation.dart';

class StepDetailPage extends StatefulWidget {
  const StepDetailPage({super.key});

  @override
  State<StepDetailPage> createState() => _StepDetailPageState();
}

class _StepDetailPageState extends State<StepDetailPage>
    with SingleTickerProviderStateMixin {
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  /// 날짜를 'yyyy.MM.dd' 형식으로 출력
  String get formattedDate => DateFormat('yyyy.MM.dd').format(_selectedDate);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('만보기'), // 상단 제목
      ),
      body: _buildDailyTab(), // 일별 탭 UI
    );
  }

  /// 일별 탭 UI 구성
  Widget _buildDailyTab() {
    final stepProvider = context.watch<StepProvider>();
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 🔻 날짜 선택 영역
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_left),
                onPressed: () {
                  setState(() {
                    _selectedDate = _selectedDate.subtract(
                      const Duration(days: 1),
                    );
                  });
                },
              ),
              GestureDetector(
                onTap: () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2024),
                    lastDate: DateTime.now(),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      _selectedDate = pickedDate;
                    });
                  }
                },
                child: Row(
                  children: [
                    Text(
                      formattedDate,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.arrow_drop_down), // ▼ 아이콘
                  ],
                ),
              ),
              IconButton(
                // 항상 오른쪽 자리를 차지하도록, 투명 아이콘으로 유지
                icon: Icon(
                  Icons.arrow_right,
                  color: _isToday ? Colors.transparent : Colors.black,
                ),
                onPressed:
                    _isToday
                        ? null
                        : () {
                          setState(() {
                            _selectedDate = _selectedDate.add(
                              const Duration(days: 1),
                            );
                          });
                        },
              ),
            ],
          ),

          const SizedBox(height: 32),

          // ⭕ 동그라미 게이지 바 삽입
          StepCircleGauge(
            current: stepProvider.currentStep,
            goal: stepProvider.goalInMeters, // ✅ Provider에서 현재 값 가져옴
            onGoalTap: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                builder: (_) => const StepGoalBottomSheet(),
              );
            },
          ),

          const SizedBox(height: 32),

          // 👣 비교/응원 메시지 영역 자리만 잡기
          // 비교 영역
          Builder(
            builder: (context) {
              final stepProvider = context.watch<StepProvider>();
              final today = stepProvider.currentStep;
              final yesterday = stepProvider.yesterdayStep;
              final diff = today - yesterday;

              Icon icon;
              String text;

              if (diff > 0) {
                icon = const Icon(Icons.arrow_upward, color: Colors.red);
                text = '$diff m 더 걸었어요';
              } else if (diff < 0) {
                icon = const Icon(Icons.arrow_downward, color: Colors.blue);
                text = '${diff.abs()} m 적게 걸었어요';
              } else {
                icon = const Icon(Icons.horizontal_rule, color: Colors.grey);
                text = '어제와 같아요!';
              }

              return Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 20,
                ),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 228, 223, 223), // 부드러운 배경
                  borderRadius: BorderRadius.circular(12), // 모서리 둥글게
                ),
                child: Column(
                  children: [
                    const Text(
                      '어제보다',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        icon,
                        const SizedBox(width: 8),
                        Text(text, style: const TextStyle(fontSize: 14)),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),

          // ↓ _buildDailyTab() 안 하단에 추가 (비교 아래)
          Text(
            StepMotivation.getTodayMessage(),
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  /// 오늘 날짜와 동일한지 확인하는 헬퍼
  bool get _isToday {
    final now = DateTime.now();
    return _selectedDate.year == now.year &&
        _selectedDate.month == now.month &&
        _selectedDate.day == now.day;
  }
}
