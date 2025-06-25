import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:xml2json/xml2json.dart';
import 'package:trekkit_flutter/models/sh/mountain.dart';

//산림청 등산로정보 API
class MountainTrailApi {
  static const String _apiKey = 
      'b96eSjTza7C7QbPobZvC9k42Yn9TmGV4y%2BxTx%2B0W2d97ycimCfjKE%2F5rd5Bpj9%2FYTvDxlQPEceC6dctxSDDytA%3D%3D';
  static const String _baseUrl =
      'http://openapi.forest.go.kr/openapi/service/trailInfoService/getforestspatialdataservice';

   static Future<Map<String, Map<String, String>>> fetchTrails(List<String> mountainNames) async {
    final Map<String, Map<String, String>> trailInfoMap = {};
    final Xml2Json xml2json = Xml2Json();

    for (final name in mountainNames) {
      final uri = Uri.parse(
          '$_baseUrl?mntnNm=$name&serviceKey=$_apiKey&numOfRows=1000&pageNo=1&_type=json');

          print('🌐 요청 보냄: $name');

       try {
        final response = await http.get(uri);
        if (response.statusCode != 200) {
          print('❌ $name: 응답 코드 ${response.statusCode}');
          continue;
        }

        // XML → JSON 변환
        xml2json.parse(utf8.decode(response.bodyBytes));
        final jsonString = xml2json.toParker();
        final jsonData = jsonDecode(jsonString);

        final responseBody = jsonData['OpenAPI_ServiceResponse']?['cmmMsgHeader'];
        if (responseBody != null && responseBody['returnReasonCode'] != '00') {
          print('❌ $name: 실패 - ${responseBody['returnAuthMsg']}');
          continue;
        }

        final body = jsonData['OpenAPI_ServiceResponse']?['body'];
        final items = body?['items']?['item'];

        if (items == null) {
          print('⚠️ $name: item 없음');
          continue;
        }

        // 여러 개일 경우 List, 하나면 Map
        final itemList = items is List ? items : [items];

        for (var item in itemList) {
          final trailName = item['mntnNm'] ?? name;
          trailInfoMap[trailName] = {
            'trailInfoUrl': item['course'] ?? '',
            'trailImageUrl': item['imgurl'] ?? '',
            'trailFileUrl': item['fileurl'] ?? '',
          };
        }
      } catch (e, stack) {
        print('❌ $name: 예외 발생 $e');
        print(stack);
      }
    }

    print('✅ 최종 trail map 개수: ${trailInfoMap.length}');
    return trailInfoMap;
  }
}