import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// 회원가입 함수
Future<bool> signUp({
  required String id,
  required String pw,
  required String nickname,
  required String email,
  required File? profileImage,
}) async {

  // final url = Uri.parse('http://10.0.2.2:30000/signup/dosignup'); // 에뮬레이터
  // final url = Uri.parse('http://192.168.0.7:30000/signup/dosignup'); // 실제 기기
  final url = Uri.parse('http://192.168.0.51:30000/signup/dosignup'); // 실제 기기

  try {
    var request = http.MultipartRequest('POST', url);
    request.fields['id'] = id;
    request.fields['pw'] = pw;
    request.fields['nickname'] = nickname;
    request.fields['email'] = email;

    if (profileImage != null) {
      request.files.add(
        await http.MultipartFile.fromPath('profileImage', profileImage.path),
      );
    }

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      return result == true;
    } else {
      return false;
    }
  } catch (e) {
    return false;
  }
}