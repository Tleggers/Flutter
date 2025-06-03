import 'package:flutter/material.dart';

class Community extends StatefulWidget {
  const Community({super.key});

  @override
  State<Community> createState() => _CommunityState();
}

class _CommunityState extends State<Community> {
  // 선택 상태
  String selectedSort = '최신순'; // 단일 선택 유지
  List<String> selectedMountains = [];
  List<String> selectedAges = [];

  // 필터 항목들
  final List<String> sortOptions = ['최신순', '인기순'];
  final List<String> mountainOptions = ['한라산', '설악산', '지리산'];
  final List<String> ageOptions = ['30대', '40대', '50대'];

  // 체크 여부 토글 함수
  void toggleSelection(List<String> selectedList, String value) {
    setState(() {
      if (selectedList.contains(value)) {
        selectedList.remove(value);
      } else {
        selectedList.add(value);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(title: Text('커뮤니티')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 정렬 필터 (단일 선택 유지)
            Row(
              children: [
                Text("정렬:", style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(width: 10),
                DropdownButton<String>(
                  value: selectedSort,
                  items:
                      sortOptions.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedSort = value!;
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 20),

            // 산 필터 (다중 선택)
            Text("산:", style: TextStyle(fontWeight: FontWeight.bold)),
            Wrap(
              spacing: 10,
              children:
                  mountainOptions.map((mountain) {
                    final isSelected = selectedMountains.contains(mountain);
                    return FilterChip(
                      label: Text(mountain),
                      selected: isSelected,
                      onSelected: (selected) {
                        toggleSelection(selectedMountains, mountain);
                      },
                    );
                  }).toList(),
            ),
            SizedBox(height: 20),

            // 연령 필터 (다중 선택)
            Text("연령대:", style: TextStyle(fontWeight: FontWeight.bold)),
            Wrap(
              spacing: 10,
              children:
                  ageOptions.map((age) {
                    final isSelected = selectedAges.contains(age);
                    return FilterChip(
                      label: Text(age),
                      selected: isSelected,
                      onSelected: (selected) {
                        toggleSelection(selectedAges, age);
                      },
                    );
                  }).toList(),
            ),
            SizedBox(height: 30),

            // 필터 상태 확인
            Text("📌 현재 필터 상태:", style: TextStyle(fontWeight: FontWeight.bold)),
            Text("정렬: $selectedSort"),
            Text("산: ${selectedMountains.join(', ')}"),
            Text("연령대: ${selectedAges.join(', ')}"),
          ],
        ),
      ),
    );
  }
}
