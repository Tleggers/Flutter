import 'package:flutter/material.dart';

class MountainDetailPage extends StatelessWidget {
  final String mountainName;

  const MountainDetailPage({super.key, required this.mountainName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(mountainName), // 산 이름 앱바에 출력
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: Center(child: Text('여기에 $mountainName 상세정보 표시')),
    );
  }
}
