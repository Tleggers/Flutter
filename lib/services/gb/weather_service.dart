import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/gb/weather.dart';

class WeatherService {
  static const String apiKey = '53cd642aeb4aa5974fd7a10103899bda';

  // 👉 디버깅 위해 일단 2.5 버전 사용 (문제 확인 위해)
  static const String baseUrl =
      'https://api.openweathermap.org/data/3.0/onecall';

  static Future<List<DailyWeather>> fetchDailyWeather(
    double lat,
    double lon,
  ) async {
    try {
      // ✅ 위경도 확인 로그 추가
      print('📍 요청 위경도: lat=$lat, lon=$lon');
      final url = Uri.parse(
        '$baseUrl?lat=$lat&lon=$lon&exclude=minutely,hourly,alerts&appid=$apiKey&units=metric&lang=kr',
      );

      print('📡 호출 URL: $url'); // ✅ 호출 URL 확인

      final response = await http.get(url);

      print('📡 응답 코드: ${response.statusCode}'); // ✅ 응답 상태코드 출력

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        print(
          '📡 응답 바디 일부: ${response.body.substring(0, 300)}',
        ); // ✅ 응답 바디 앞부분 출력

        final List<dynamic>? dailyList = json['daily'];

        if (dailyList == null) {
          print('❌ daily 데이터가 null 입니다!');
          throw Exception('daily 날씨 데이터가 없습니다.');
        }

        print('✅ daily 리스트 길이: ${dailyList.length}');

        return dailyList.map((e) => DailyWeather.fromJson(e)).toList();
      } else {
        print('❌ 응답 실패 - 상태코드: ${response.statusCode}');
        throw Exception('날씨 데이터를 불러오지 못했습니다.');
      }
    } catch (e, stacktrace) {
      print('❌ 예외 발생: $e');
      print('🔎 스택트레이스: $stacktrace');
      throw Exception('날씨 데이터를 불러오는 중 오류 발생');
    }
  }
}
