import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:trekkit_flutter/models/sh/mountain.dart';

class ApiService {
  static const baseUrl = 'http://localhost:30000';

  static Future<List<Mountain>> fetchNearbyMountains(double lat, double lng) async {
    final response = await http.get(Uri.parse('$baseUrl/mountain/nearby?lat=$lat&lng=$lng'));
    if (response.statusCode == 200) {
      List jsonList = json.decode(response.body);
      return jsonList.map((e) => Mountain.fromJson(e)).toList();
    } else {
      throw Exception('근처 산 데이터를 불러오지 못했습니다');
    }
  }
}