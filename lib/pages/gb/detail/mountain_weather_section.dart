import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/gb/weather.dart';
import '../../../services/gb/weather_service.dart';

/// ✅ 산 날씨 섹션 (주간 날씨 카드 리스트)
/// 위경도(latitude, longitude)를 받아서 OpenWeather API 호출 후 출력
class MountainWeatherSection extends StatefulWidget {
  final double latitude;
  final double longitude;

  const MountainWeatherSection({
    super.key,
    required this.latitude,
    required this.longitude,
  });

  @override
  State<MountainWeatherSection> createState() => _MountainWeatherSectionState();
}

class _MountainWeatherSectionState extends State<MountainWeatherSection> {
  late Future<List<DailyWeather>> weatherFuture;

  @override
  void initState() {
    super.initState();
    // ✅ 위젯 초기화 시 날씨 API 호출
    weatherFuture = WeatherService.fetchDailyWeather(
      widget.latitude,
      widget.longitude,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<DailyWeather>>(
      future: weatherFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // ✅ 로딩 중
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          // ✅ 오류 발생 시
          return const Center(child: Text('날씨 데이터를 불러오지 못했습니다.'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          // ✅ 데이터 없을 경우
          return const Center(child: Text('날씨 데이터가 없습니다.'));
        }

        final dailyWeatherList = snapshot.data!;

        // ✅ 날씨 카드 리스트 가로 스크롤 출력
        return SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: dailyWeatherList.length,
            itemBuilder: (context, index) {
              final daily = dailyWeatherList[index];
              return buildWeatherCard(daily);
            },
          ),
        );
      },
    );
  }

  /// ✅ 하나의 날씨 카드 위젯
  Widget buildWeatherCard(DailyWeather daily) {
    // ✅ 날짜와 요일 분리 포맷팅
    final dateStr = DateFormat('M.d', 'ko').format(daily.date); // 예: 6.15
    final weekday = DateFormat('E', 'ko').format(daily.date); // 예: 토

    // 요일 색상 설정
    Color weekdayColor;
    if (weekday == '토') {
      weekdayColor = Colors.blue;
    } else if (weekday == '일') {
      weekdayColor = Colors.red;
    } else {
      weekdayColor = Colors.black;
    }

    return Container(
      width: 100,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // ✅ 날짜 + 요일 한 줄에 출력
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: dateStr,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                TextSpan(
                  text: ' $weekday',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: weekdayColor,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          Image.network(
            'https://openweathermap.org/img/wn/${daily.icon}@2x.png',
            width: 50,
            height: 50,
          ),

          const SizedBox(height: 8),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${daily.minTemp.toInt()}°',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.blue,
                ),
              ),
              const Text(' / '),
              Text(
                '${daily.maxTemp.toInt()}°',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.red,
                ),
              ),
            ],
          ),

          const SizedBox(height: 4),

          Text(
            '풍속 ${daily.windSpeed} m/s',
            style: const TextStyle(fontSize: 12),
          ),
          Text('강수 ${daily.rain} mm', style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
