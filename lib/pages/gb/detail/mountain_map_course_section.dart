import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:dio/dio.dart';
import 'package:trekkit_flutter/models/gb/hiking_course.segment.dart';
import 'package:trekkit_flutter/models/gb/mountain_course.dart';
import 'package:trekkit_flutter/models/gb/hiking_course.dart';

class MountainMapCourseSection extends StatefulWidget {
  final MountainCourse data; // ✅ 산 DB에서 읽어온 정보 (난이도 포함)

  const MountainMapCourseSection({super.key, required this.data});

  @override
  State<MountainMapCourseSection> createState() =>
      _MountainMapCourseSectionState();
}

class _MountainMapCourseSectionState extends State<MountainMapCourseSection> {
  final dio = Dio(); // ✅ HTTP 통신 라이브러리
  final String apiKey = '01B8ABC1-D783-386C-902B-DD365F23BF71';

  List<HikingCourse> courseList = []; // ✅ 브이월드 등산로 리스트
  NaverMapController? _mapController;
  final ScrollController listController = ScrollController(); // ✅ 리스트 스크롤 컨트롤러

  final List<Color> polylineColors = [
    Colors.red,
    Colors.orange,
    Colors.green,
    Colors.blue,
    Colors.purple,
    Colors.brown,
    Colors.pink,
    Colors.teal,
    Colors.indigo,
    Colors.deepOrange,
  ];

  @override
  void initState() {
    super.initState();
    fetchLimitedHikingCourses();
  }

  /// ✅ 브이월드에서 등산로 10개 제한 호출
  Future<void> fetchLimitedHikingCourses() async {
    double delta = 0.02;
    double lngMin = widget.data.longitude - delta;
    double lngMax = widget.data.longitude + delta;
    double latMin = widget.data.latitude - delta;
    double latMax = widget.data.latitude + delta;

    final url =
        'https://api.vworld.kr/req/data?service=data&request=GetFeature&data=LT_L_FRSTCLIMB'
        '&key=$apiKey&format=json&size=10&page=1&geomFilter=BOX($lngMin,$latMin,$lngMax,$latMax)';

    try {
      final response = await dio.get(url);
      final features =
          response.data['response']['result']['featureCollection']['features'];

      for (var feature in features) {
        final properties = feature['properties'];
        final geometry = feature['geometry'];

        final segment = HikingCourseSegment.fromProperties(properties);
        List<NLatLng> polylinePoints = [];

        if (geometry['type'] == 'MultiLineString') {
          final coords = geometry['coordinates'];
          for (var line in coords) {
            for (var point in line) {
              double lng = point[0];
              double lat = point[1];
              polylinePoints.add(NLatLng(lat, lng));
            }
          }
        }

        courseList.add(
          HikingCourse(segment: segment, polyline: polylinePoints),
        );
      }

      setState(() {});
      if (_mapController != null) {
        drawPolylines();
        moveCameraToPolylines();
      }
    } catch (e) {
      print("브이월드 호출 실패: $e");
    }
  }

  /// ✅ 폴리라인 지도에 표시
  void drawPolylines() {
    for (int i = 0; i < courseList.length; i++) {
      // ✅ 폴리라인 먼저 추가
      _mapController?.addOverlay(
        NPolylineOverlay(
          id: 'course_line_$i',
          coords: courseList[i].polyline,
          color: polylineColors[i % polylineColors.length],
          width: 5,
        ),
      );

      // ✅ 중간 좌표 계산
      final midIndex = courseList[i].polyline.length ~/ 2;
      final midPoint = courseList[i].polyline[midIndex];

      // ✅ 마커 대신 Caption만 표시
      _mapController?.addOverlay(
        NMarker(
          id: 'course_marker_$i',
          position: midPoint,
          caption: NOverlayCaption(
            text: '코스 ${i + 1}',
            textSize: 14,
            color: Colors.black,
          ),
        ),
      );
    }
  }

  /// ✅ 전체 폴리라인 화면 맞추기
  void moveCameraToPolylines() {
    if (courseList.isEmpty) return;

    final allPoints = courseList.expand((c) => c.polyline).toList();
    double minLat = allPoints.first.latitude;
    double maxLat = allPoints.first.latitude;
    double minLng = allPoints.first.longitude;
    double maxLng = allPoints.first.longitude;

    for (var point in allPoints) {
      if (point.latitude < minLat) minLat = point.latitude;
      if (point.latitude > maxLat) maxLat = point.latitude;
      if (point.longitude < minLng) minLng = point.longitude;
      if (point.longitude > maxLng) maxLng = point.longitude;
    }

    final bounds = NLatLngBounds(
      southWest: NLatLng(minLat, minLng),
      northEast: NLatLng(maxLat, maxLng),
    );

    _mapController?.updateCamera(
      NCameraUpdate.fitBounds(bounds, padding: EdgeInsets.all(50)),
    );
  }

  /// ✅ DB 난이도 파싱 함수 (이게 핵심)
  String extractDifficulty() {
    final regex = RegExp(r'난이도\s*:\s*(\S+)');
    final match = regex.firstMatch(widget.data.difficulty);
    if (match != null) {
      final raw = match.group(1)!;
      if (raw.contains('초급')) return '쉬움';
      if (raw.contains('중급')) return '중간';
      if (raw.contains('고급')) return '어려움';
    }
    return '정보없음';
  }

  /// ✅ 난이도 색상 (텍스트 색)
  Color getDifficultyTextColor(String difficulty) {
    if (difficulty == "쉬움") return Colors.green;
    if (difficulty == "중간") return Colors.orange;
    if (difficulty == "어려움") return Colors.red;
    return Colors.black;
  }

  @override
  Widget build(BuildContext context) {
    final parsedDifficulty = extractDifficulty(); // ✅ DB 난이도 미리 추출

    return SingleChildScrollView(
      child: Column(
        children: [
          // ✅ 지도 출력
          SizedBox(
            height: 300,
            child: NaverMap(
              options: NaverMapViewOptions(
                initialCameraPosition: NCameraPosition(
                  target: NLatLng(widget.data.latitude, widget.data.longitude),
                  zoom: 13,
                ),
                scrollGesturesEnable: true,
                zoomGesturesEnable: true,
                tiltGesturesEnable: true,
                scaleBarEnable: true,
                logoAlign: NLogoAlign.leftBottom,
              ),
              onMapReady: (controller) {
                _mapController = controller;
                if (courseList.isNotEmpty) {
                  drawPolylines();
                  moveCameraToPolylines();
                }
              },
            ),
          ),

          const SizedBox(height: 10),

          // ✅ 코스 리스트 (브이월드)
          ListView.builder(
            controller: listController,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: courseList.length,
            itemBuilder: (context, index) {
              final course = courseList[index];
              final distanceKm = course.segment.secLen / 1000;
              final totalTime = course.segment.upMin + course.segment.downMin;

              return GestureDetector(
                onTap: () {
                  final polyline = courseList[index].polyline;
                  final midPoint = polyline[polyline.length ~/ 2];

                  _mapController?.updateCamera(
                    NCameraUpdate.scrollAndZoomTo(target: midPoint, zoom: 14),
                  );

                  listController.animateTo(
                    index * 150.0,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                  );
                },
                child: Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "코스 ${index + 1}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),

                        Row(
                          children: [
                            const Icon(
                              Icons.route,
                              size: 18,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 5),
                            Text("거리: ${distanceKm.toStringAsFixed(1)} km"),
                          ],
                        ),

                        Row(
                          children: [
                            const Icon(
                              Icons.access_time,
                              size: 18,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 5),
                            Text("소요시간: $totalTime 분"),
                          ],
                        ),

                        Row(
                          children: [
                            const Icon(
                              Icons.flag,
                              size: 18,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              "난이도: $parsedDifficulty",
                              style: TextStyle(
                                color: getDifficultyTextColor(parsedDifficulty),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
