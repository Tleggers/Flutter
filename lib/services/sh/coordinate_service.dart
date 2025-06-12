import 'dart:convert';
import 'package:csv/csv.dart';
import 'package:flutter/services.dart';
import 'package:trekkit_flutter/models/sh/mountain.dart';

class CoordinateService {
  static final Map<String, List<double>> _coordinateMap = {};

  /// CSV를 로드해서 map에 캐싱
  static Future<void> loadCoordinates() async {
    
    final rawData = await rootBundle.loadString('assets/csv/mountain_coordinates.csv');
    List<List<dynamic>> csvTable = const CsvToListConverter().convert(rawData, eol: '\n');

    for (var row in csvTable) {
      if (row.length >= 3) {
        String name = row[0].toString().trim();
        double lat = double.tryParse(row[1].toString()) ?? 0.0;
        double lng = double.tryParse(row[2].toString()) ?? 0.0;
        _coordinateMap[name] = [lat, lng];
      }
    }
  }

  /// 산 이름으로 좌표 반환 (없으면 null)
  static List<double>? getCoordinatesFor(String mountainName) {
    return _coordinateMap[mountainName.trim()];
  }
}
