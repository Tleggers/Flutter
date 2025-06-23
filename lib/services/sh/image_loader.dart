import 'package:flutter/services.dart' show rootBundle;

class ImageLoader {
  static String normalizeMountainName(String name) {
    return name.trim().replaceAll(' ', '').replaceAll(RegExp(r'[^\w가-힣]'), '');
  }

  static Future<List<String>> loadMountainImages(String mountainName) async {
    List<String> images = [];
    final cleanName =
        mountainName
            .replaceAll(RegExp(r'\s+'), '')
            .trim(); //normalizeMountainName(mountainName);

    for (int i = 1; i <= 5; i++) {
      // String path = 'assets/mtimages/$folderName/$i.jpg';
      String path = 'assets/mtimages/${cleanName}_$i.jpg';
      print('📁 checking file exists: $path');
      try {
        final data = await rootBundle.load(path); // 존재 확인
        print('✅ Found: $path (${data.lengthInBytes} bytes)');
        images.add(path);
      } catch (e) {
        print('❌ Not found: $path');
        break; // 이미지 없으면 종료
      }
    }
    return images;
  }
}
