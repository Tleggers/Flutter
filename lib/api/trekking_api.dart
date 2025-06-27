import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:trekkit_flutter/models/sh/mountain.dart';
import 'package:trekkit_flutter/services/sh/mountain_service.dart';

// 한국 트레킹센터 100대 명산 API를 요청하고 데이터를 가져오는 클래스
class TrekkingApi {
  static const String _apiKey =
  'b96eSjTza7C7QbPobZvC9k42Yn9TmGV4y%2BxTx%2B0W2d97ycimCfjKE%2F5rd5Bpj9%2FYTvDxlQPEceC6dctxSDDytA%3D%3D';
  static const String _baseUrl =
  'https://apis.data.go.kr/B553662/top100FamtListBasiInfoService';

  static Future<Map<String, Map<String, dynamic>>> fetchMountainCoords() async {
    final url = Uri.parse(
      '$_baseUrl/getTop100FamtListBasiInfoList?serviceKey=$_apiKey&numOfRows=100&pageNo=1&type=json');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      final items = data['response']?['body']?['items']?['item'];

      final Map<String, Map<String, dynamic>> result = {};

      for (var item in items) {
        final name = item['frtrlNm']?.toString().trim();
        final region = item['ctpvNm']?.toString().trim();
        final lat = (item['lat'] as num?)?.toDouble() ?? 0.0;
        final lng = (item['lot'] as num?)?.toDouble() ?? 0.0;
        final height = (item['aslAltide'] as num?)?.toDouble() ?? 0.0;
        if (name != null) {
          result[name] = {'lat': lat, 'lng': lng, 'region': region,};
        }
      }

    return result;
    } else {
      print('🚨 트레킹센터 API 호출 실패: ${response.statusCode}');
      print('📥 트레킹센터 응답 본문: ${response.body}');
      return {};
    }
  }
}