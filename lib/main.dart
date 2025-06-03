import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),

    );
  }
}

// 임시 홈페이지
class MyHomePage extends StatelessWidget {
  final String title;

  const MyHomePage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            // 사용할 때 각자 이 아래에 주석부분 지우고 함수 넣으면 됩니다.

            // 홈
            // TextButton(
            //   onPressed: () {
            //     // 여기에 홈 페이지로 이동하는 함수 넣으면 됨
            //     Navigator.push(context, MaterialPageRoute(builder: (context) => const HomePage()));
            //   },
            //   child: const Text('홈'),
            // ),

            // 지도
            // TextButton(
            //   onPressed: () {
            //     // 여기에 지도 페이지로 이동하는 함수 넣으면 됨
            //     Navigator.push(context, MaterialPageRoute(builder: (context) => const MapPage()));
            //   },
            //   child: const Text('지도'),
            // ),


            // 커뮤니티
            // TextButton(
            //   onPressed: () {
            //     // 여기에 커뮤니티 페이지로 이동하는 함수 넣으면 됨
            //     Navigator.push(context, MaterialPageRoute(builder: (context) => const CommunityPage()));
            //   },
            //   child: const Text('커뮤니티'),
            // ),

            // 마이페이지
            // TextButton(
            //   onPressed: () {
            //     Navigator.push(context, MaterialPageRoute(builder: (context) => const MyPage()));
            //   },
            //   child: const Text('마이'),
            // ),
          ],
        ),
      ),
    );
  }
}