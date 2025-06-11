import 'package:flutter/material.dart';
import 'package:trekkit_flutter/api/mountain_api.dart';
import 'package:trekkit_flutter/models/sh/mountain.dart';
import 'package:trekkit_flutter/services/sh/coordinate_service.dart';
import 'package:trekkit_flutter/services/sh/location_service.dart';
import 'package:trekkit_flutter/functions/sh/distance_util.dart';
import 'package:trekkit_flutter/widgets/sh/mountain_card.dart';
import 'package:trekkit_flutter/widgets/sh/sliding_panel.dart';
import 'package:geolocator/geolocator.dart';

class MapPage extends StatefulWidget {
  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  List<Mountain> nearbyMountains = [];
  bool isLoading = true;

  @override
  void initState() {
  super.initState();
  initializeData();
}

  Future<void> initializeData() async {
    await CoordinateService.loadCoordinates(); // CSV 먼저 로드
    await loadNearbyMountains();              // 산 정보 불러오기
  }

  Future<void> loadNearbyMountains() async {
    try {
      print('📡 전체 산 데이터를 불러오는 중...');
      List<Mountain> allMountains = await MountainApi.fetchMountains();
      print('📋 전체 산 개수: ${allMountains.length}');

      if (allMountains.isNotEmpty) {
      final sample = allMountains.first;
      print('🗻 샘플 산 위치: ${sample.name}, latitude: ${sample.latitude}, longitude: ${sample.longitude}');
      }

      print('📍 현재 위치 불러오는 중...');
      Position current = await LocationService.determinePosition();
      // Position current = await LocationService.getCurrentPosition();
      if (current == null) {
        print('⚠️ 현재 위치를 가져오지 못했습니다.');
        setState(() {
          nearbyMountains = []; // 위치 못 불러온 경우 빈 리스트 처리
          isLoading = false;
        });
        return;
      }
      print("🧭 현재 위치: ${current.latitude}, ${current.longitude}");

      List<Mountain> filtered = allMountains.where((mountain) {
        if (mountain.latitude == null || mountain.longitude == null) return false;

        double distance = DistanceUtil.calculateDistance(
          current.latitude,
          current.longitude,
          mountain.latitude,
          mountain.longitude,
        );
        return distance < 500.0; // 해당 반경 이내
      }).toList();

      print('🎯 필터링된 산 개수 (500km 이내): ${filtered.length}');


      setState(() {
        nearbyMountains = filtered;
        isLoading = false;
      });
    } catch (e) {
      print('🚨 오류 발생: $e');
      setState(() {
      isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("근처 산")),
      body: isLoading
    ? Center(child: CircularProgressIndicator())
    : nearbyMountains.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('근처 산이 없습니다 🏔️'),
                SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      isLoading = true;
                    });
                    loadNearbyMountains(); // 다시 불러오기
                  },
                  child: Text('다시 시도'),
                ),
              ],
            ),
          )
        : SlidingPanel(mountains: nearbyMountains),
    );
  }
}
