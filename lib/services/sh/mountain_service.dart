import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:trekkit_flutter/models/sh/mountain.dart';
import 'package:trekkit_flutter/api/mountain_api.dart';

// 한국 트레킹센터 100대 명산 API를 요청하고 데이터를 가져오는 클래스
class MountainService {
  static const String _apiKey =
  'b96eSjTza7C7QbPobZvC9k42Yn9TmGV4y%2BxTx%2B0W2d97ycimCfjKE%2F5rd5Bpj9%2FYTvDxlQPEceC6dctxSDDytA%3D%3D';
  static const String _baseUrl =
  'https://apis.data.go.kr/B553662/top100FamtListBasiInfoService';

  static Future<Map<String, Map<String, double>>> fetchCoordinates() async {
    final url = Uri.parse(
      '$_baseUrl/getTop100FamtListBasiInfoList?serviceKey=$_apiKey&numOfRows=100&pageNo=1&type=json');
        // print('📡 요청 URL: $url');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      final items = data['response']?['body']?['items']?['item'];

       //키(컬럼) 확인
      if (items is List && items.isNotEmpty) {
      final firstItem = Map<String, dynamic>.from(items.first);
      print('🧾 트레킹센터 키 목록: ${firstItem.keys.toList()}');
    }

      final Map<String, Map<String, double>> result = {};

      for (var item in items) {
        final name = item['frtrlNm']?.toString().trim();
        final lat = (item['lat'] as num?)?.toDouble() ?? 0.0;
        final lng = (item['lot'] as num?)?.toDouble() ?? 0.0;
        if (name != null) {
          result[name] = {'lat': lat, 'lng': lng};
        }
      }

    return result;

  } else {
      print('🚨 트레킹센터 API 호출 실패: ${response.statusCode}');
      print('📥 응답 본문: ${response.body}');
      return {};
  }
}

  //산림청 API와 통합
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
