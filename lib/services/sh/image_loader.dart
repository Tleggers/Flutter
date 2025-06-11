import 'package:flutter/services.dart' show rootBundle;

class ImageLoader {
  static Future<List<String>> loadMountainImages(String mountainName) async {
    List<String> images = [];
    for (int i = 1; i <= 5; i++) {
      String path = 'assets/images/$mountainName/$i.jpg';
      try {
        print('🔍 확인 중: $path');
        await rootBundle.load(path); // 존재 확인
        images.add(path);
      } catch (e) {
        break; // 이미지 없으면 반복 종료
      }
    }
    return images;
  }
}
