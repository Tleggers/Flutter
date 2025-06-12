import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:trekkit_flutter/models/sh/mountain.dart';
import 'package:trekkit_flutter/api/mountain_api.dart';

class MountainService {
  static const String _apiKey =
  'b96eSjTza7C7QbPobZvC9k42Yn9TmGV4y%2BxTx%2B0W2d97ycimCfjKE%2F5rd5Bpj9%2FYTvDxlQPEceC6dctxSDDytA%3D%3D';
  static const String _baseUrl =
  'https://apis.data.go.kr/B553662/top100FamtListBasiInfoService';
  static Future<Map<String, Map<String, double>>> fetchCoordinates() async {
    final url = Uri.parse('$_baseUrl?serviceKey=$_apiKey&numOfRows=100&pageNo=1&_type=json');
    final response = await http.get(url);

    final Map<String, Map<String, double>> result = {};

    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      final items = data['response']?['body']?['items']?['item'] ?? [];

      for (var item in items) {
        final name = item['mntnnm']?.trim();
        final lat = double.tryParse(item['latitude'] ?? '0') ?? 0.0;
        final lng = double.tryParse(item['longitude'] ?? '0') ?? 0.0;
        if (name != null) {
          result[name] = {'lat': lat, 'lng': lng};
        }
      }
    }

    return result;
  }

  static Future<List<Mountain>> fetchTop100WithFullInfo() async {
    final apiAList = await MountainApi.fetchMountains();
    final coordMap = await fetchCoordinates();

    for (var mountain in apiAList) {
      final coords = coordMap[mountain.name];
      if (coords != null) {
        mountain.applyCoordinates(coords['lat']!, coords['lng']!);
      }
    }

    return apiAList;
  }
}
