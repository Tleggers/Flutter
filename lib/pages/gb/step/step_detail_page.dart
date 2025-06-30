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
    Future.microtask(() {
      final stepProvider = context.read<StepProvider>();
      stepProvider.fetchYesterdayStepFromServer();
      stepProvider.loadStepByDate(_selectedDate); // ✅ 날짜별 걸음수 불러오기
    });
  }

  String get formattedDate => DateFormat('yyyy.MM.dd').format(_selectedDate);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('만보기')),
      body: _buildDailyTab(),
    );
  }

  Widget _buildDailyTab() {
    final stepProvider = context.watch<StepProvider>();
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
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
                  context.read<StepProvider>().loadStepByDate(_selectedDate);
                  context.read<StepProvider>().loadPreviousDateStep(
                    _selectedDate,
                  );
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
                    context.read<StepProvider>().loadStepByDate(_selectedDate);
                    context.read<StepProvider>().loadPreviousDateStep(
                      _selectedDate,
                    );
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
                    const Icon(Icons.arrow_drop_down),
                  ],
                ),
              ),
              IconButton(
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
                          context.read<StepProvider>().loadStepByDate(
                            _selectedDate,
                          );
                          context.read<StepProvider>().loadPreviousDateStep(
                            _selectedDate,
                          );
                        },
              ),
            ],
          ),
          const SizedBox(height: 32),
          StepCircleGauge(
            current:
                _isToday
                    ? stepProvider.currentStep
                    : stepProvider.selectedDateStep ?? 0,
            goal: stepProvider.goalInMeters,
            isToday: _isToday,
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
          Builder(
            builder: (context) {
              final today =
                  _isToday
                      ? stepProvider.currentStep
                      : stepProvider.selectedDateStep ?? 0;

              final yesterday =
                  _isToday
                      ? stepProvider.yesterdayStep
                      : stepProvider.previousDateStep;
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
                text = '0';
              }

              return Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 20,
                ),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 228, 223, 223),
                  borderRadius: BorderRadius.circular(12),
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
          Text(
            StepMotivation.getTodayMessage(),
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  bool get _isToday {
    final now = DateTime.now();
    return _selectedDate.year == now.year &&
        _selectedDate.month == now.month &&
        _selectedDate.day == now.day;
  }
}
