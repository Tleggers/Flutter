import 'package:flutter/material.dart';
import 'package:trekkit_flutter/models/sh/mountain.dart';
import 'package:trekkit_flutter/services/sh/location_service.dart';
import 'package:trekkit_flutter/functions/sh/distance_util.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:trekkit_flutter/services/sh/mountain_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:trekkit_flutter/views/sh/mountain_collage_view.dart';
import 'package:trekkit_flutter/pages/sh/mountain_detail_page.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  List<Mountain> nearbyMountains = [];
  List<Mountain> filteredMountains = [];
  bool isLoading = true;

  String searchQuery = '';
  String selectedRegion = '전체';

  late NCameraPosition _initialCameraPosition;
  final PanelController _panelController = PanelController();
  final Set<NMarker> _markers = {};

  // 지역 목록 만들기
  List<String> getRegions() {
    final regions =
        nearbyMountains
            .map((m) => m.region)
            .where((region) => region != null && region.isNotEmpty)
            .map((region) => region!)
            .toSet()
            .toList();
    regions.sort();
    return ['전체', ...regions];
  }

  void applyFilter() {
    setState(() {
      filteredMountains =
          nearbyMountains.where((m) {
            final matchesName = m.name.contains(searchQuery);
            final matchesRegion =
                selectedRegion == '전체' || m.region == selectedRegion;
            return matchesName && matchesRegion;
          }).toList();
    });
  }

  @override
  void initState() {
    super.initState();
    initializeData();
  }

  Future<void> initializeData() async {
    await loadNearbyMountains(); // 산 정보 불러오기
  }

  Future<void> loadNearbyMountains() async {
    try {
      print('📡 전체 산 데이터를 불러오는 중...');
      // List<Mountain> allMountains = await MountainApi.fetchMountains();
      final allMountains = await MountainService.fetchMountainsWithAPIs();
      print('📋 전체 산 개수: ${allMountains.length}');

      print('📍 현재 위치 불러오는 중...');
      Position? current = await LocationService.determinePosition();
      print('✅ 위치 결과: $current');
      // Position current = await LocationService.getCurrentPosition();
      if (current == null) {
        print('⚠️ 현재 위치를 가져오지 못했습니다.');
        setState(() {
          nearbyMountains = []; // 위치 못 불러온 경우 빈 리스트 처리
          filteredMountains = [];
          isLoading = false;
        });
        return;
      }
      print("🧭 현재 위치: ${current.latitude}, ${current.longitude}");

      _initialCameraPosition = NCameraPosition(
        target: NLatLng(current.latitude, current.longitude),
        zoom: 10,
      );

      List<Mountain> filtered =
          allMountains.where((mountain) {
            double distance = DistanceUtil.calculateDistance(
              current.latitude,
              current.longitude,
              mountain.latitude,
              mountain.longitude,
            );
            return distance < 100.0; // 해당 반경 이내
          }).toList();

      print('🎯 필터링된 산 개수 (100km 이내): ${filtered.length}');

      // 마커 세팅
      _markers.clear();
      for (final mountain in filtered) {
        final marker = NMarker(
          id: mountain.name,
          position: NLatLng(mountain.latitude, mountain.longitude),
        );
        marker.setOnTapListener((_) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MountainDetailPage(mountain: mountain),
            ),
          );
        });
        _markers.add(marker);
      }

      setState(() {
        nearbyMountains = filtered;
        filteredMountains = filtered;
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
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 40, 16, 0),
                    child: Column(
                      children: [
                        TextField(
                          decoration: const InputDecoration(
                            hintText: '산 이름 검색',
                            prefixIcon: Icon(Icons.search),
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) {
                            searchQuery = value;
                            applyFilter();
                          },
                        ),
                        const SizedBox(height: 8),
                        DropdownButton<String>(
                          isExpanded: true,
                          value: selectedRegion,
                          items:
                              getRegions().map((region) {
                                return DropdownMenuItem<String>(
                                  value: region,
                                  child: Text(region),
                                );
                              }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              selectedRegion = value;
                              applyFilter();
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child:
                        nearbyMountains.isEmpty
                            ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text('근처 산이 없습니다 🏔️'),
                                  const SizedBox(height: 12),
                                  ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        isLoading = true;
                                      });
                                      loadNearbyMountains();
                                    },
                                    child: const Text('다시 시도'),
                                  ),
                                ],
                              ),
                            )
                            : SlidingUpPanel(
                              controller: _panelController,
                              minHeight: 140,
                              maxHeight:
                                  MediaQuery.of(context).size.height * 0.7,
                              // panel: MountainCollageView(mountains: filteredMountains),
                              panelBuilder:
                                  (ScrollController sc) => MountainCollageView(
                                    mountains: filteredMountains,
                                    scrollController: sc, // 👈 여기 전달
                                  ),
                              body: NaverMap(
                                options: NaverMapViewOptions(
                                  initialCameraPosition: _initialCameraPosition,
                                  locationButtonEnable: true,
                                  indoorEnable: true,
                                  consumeSymbolTapEvents:
                                      true, //네이버 심볼 이벤트 방지_false이면 네이버 마커 동작 수행
                                ),
                                onMapReady: (controller) async {
                                  for (final marker in _markers) {
                                    await controller.addOverlay(marker);
                                  }
                                },
                              ),
                            ),
                  ),
                ],
              ),
    );
  }
}
