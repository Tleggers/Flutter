import 'dart:convert';
import 'package:http/http.dart' as http;

class MountainInfoApi {
  static const String _serviceKey =
      'b96eSjTza7C7QbPobZvC9k42Yn9TmGV4y%2BxTx%2B0W2d97ycimCfjKE%2F5rd5Bpj9%2FYTvDxlQPEceC6dctxSDDytA%3D%3D';
  static const String _baseUrl =
      'http://apis.data.go.kr/1400000/service/cultureInfoService2/mntInfoOpenAPI';

  static Future<Map<String, Map<String, dynamic>>> fetchMountainInfo() async {
    final url = Uri.parse(
        '$_baseUrl?serviceKey=$_serviceKey&numOfRows=100&pageNo=1&_type=json');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final decoded = const Utf8Decoder().convert(response.bodyBytes);
        final jsonResult = json.decode(decoded);
        final items = jsonResult['response']['body']['items']['item'];

        final Map<String, Map<String, dynamic>> result = {};

        if (items is List) {
          for (var item in items) {
            final name = item['mntiname']?.toString().trim();
            if (name != null && name.isNotEmpty) {
              result[name] = {
                'height': item['mntihigh'],
                'address': item['mntiadd'],
                'top': item['mntitop'],
                'summary': item['mntisummary'],
                'admin': item['mntiadmin'],
                'tel': item['mntiadminnum'],
                'details': item['mntidetails'],
              };
            }
          }
        } else if (items is Map) {
          final name = items['mntiname']?.toString().trim();
          if (name != null && name.isNotEmpty) {
            result[name] = {
              'height': items['mntihigh'],
              'address': items['mntiadd'],
              'top': items['mntitop'],
              'summary': items['mntisummary'],
              'admin': items['mntiadmin'],
              'tel': items['mntiadminnum'],
              'details': items['mntidetails'],
            };
          }
        }

        return result;
      } else {
        print('❌ 산정보 API 응답 실패: ${response.statusCode}');
        return {};
      }
    } catch (e) {
      print('❌ 예외 발생: $e');
      return {};
    }
  }
}
