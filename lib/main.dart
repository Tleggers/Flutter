import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trekkit_flutter/pages/MainPage.dart';

import 'functions/jh/Login/UserProvider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  final token = prefs.getString('token');
  final nickname = prefs.getString('nickname');
  final profile = prefs.getString('profile');

  runApp(
    ChangeNotifierProvider(
      create: (_) => UserProvider()
        ..login(token ?? '', nickname ?? '', profile ?? ''),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: MainPage(title: 'TrekKit'),

    );
  }
}