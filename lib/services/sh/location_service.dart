import 'dart:async';
import 'package:geolocator/geolocator.dart';

class LocationService {
  static Future<Position?> determinePosition() async {
    print('🚀 위치 요청 시작됨');
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('🚫 위치 서비스 꺼짐');
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.deniedForever) {
        print('❌ 위치 권한 완전 거부됨');
        return null;
      }

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission != LocationPermission.whileInUse &&
            permission != LocationPermission.always) {
          print('❌ 위치 권한 거부됨');
          return null;
        }
      }

      Position pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          print('⏰ 위치 요청 시간초과');
          throw TimeoutException('위치 요청이 너무 오래 걸립니다.');
        },
      );

      print('📍 현재 위치: ${pos.latitude}, ${pos.longitude}');
      return pos;
    } on TimeoutException catch (e) {
      print('🛑 위치 요청 Timeout: $e');
      return null;
    } on Exception catch (e) {
      print('🛑 위치 요청 중 예외 발생: $e');
      return null;
    } catch (e, stacktrace) {
      print('🔥 치명적 시스템 예외 발생: $e');
      print(stacktrace);
      return null;
    }
  }
}
