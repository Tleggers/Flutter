import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

// 회원가입 함수
Future<bool> signUp({
  required String id,
  required String pw,
  required String nickname,
  required String email,
  required File? profileImage,
}) async {

  final baseUrl = dotenv.env['API_URL']!; // 여기서 ! << 절대 null이면 안된다는 의미
  final url = Uri.parse('$baseUrl/signup/dosignup');

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