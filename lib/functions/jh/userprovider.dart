import 'package:flutter/material.dart';

// 로그인 정보를 전역 변수로 저장하기 위한 파일
class UserProvider with ChangeNotifier {

  String? token; // 토큰
  String? nickname; // 닉네임
  String? profileUrl; // 프로필 URL
  String? logintype; // 로그인 type
  int? index; // 인덱스
  int point = 0; // 포인트

  // token이 null이 아니면 true, 아니면 false
  // 즉 로그인이 되어 있으면 true, 아니면 false
  bool get isLoggedIn => token != null;

  // 로그인이 되면 각각의 변수에 리턴해서 가지고 온 데이터를 집어 넣음
  void login(String t, String n, String p, String l, int i, int po ) {
    token = t;
    nickname = n;
    profileUrl = p;
    logintype = l;
    index = i;
    point = po;
    notifyListeners();
  }

  // 로그아웃되면 null로 변환
  void logout() {
    token = null;
    nickname = null;
    profileUrl = null;
    logintype = null;
    index = null;
    point = 0;
    notifyListeners();
  }

  void setProfileUrl(String? url) {
    profileUrl = url;
    notifyListeners();
  }

  void updatePoint(int newPoint) {
    point = newPoint;
    notifyListeners();
  }

  void addPoint(int delta) {
    point += delta;
    notifyListeners();
  }

}