import 'package:geolocator/geolocator.dart';

class LocationService {
  static Future<Position> determinePosition() async { //getCurrentPosition()
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
     if (!serviceEnabled) {
      print('🚫 위치 서비스 꺼짐');
      throw Exception('위치 서비스가 비활성화되어 있습니다.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) {
      print('❌ 위치 권한 완전 거부됨');
      throw Exception('위치 권한이 영구적으로 거부되어 있습니다.');
    }

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
          print('❌ 위치 권한 거부됨');
        throw Exception('위치 권한이 거부되어 있습니다.');
      }
    }

    Position pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    print('📍 현재 위치: ${pos.latitude}, ${pos.longitude}');

    return pos;
  }
}