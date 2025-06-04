import 'package:flutter/material.dart';
import 'package:trekkit_flutter/api/mountain_api.dart'; // 산 정보를 가져오는 API 클래스
import 'package:trekkit_flutter/models/gb/popular_course_section.dart'; // 산 정보 모델 클래스

// ▶ 인기 산 코스를 보여주는 UI 위젯 (가로 스크롤 형식)
class PopularCourseSection extends StatefulWidget {
  final double screenWidth; // 외부에서 전달받은 화면 너비
  final double screenHeight; // 외부에서 전달받은 화면 높이

  const PopularCourseSection({
    Key? key,
    required this.screenWidth,
    required this.screenHeight,
  }) : super(key: key);

  @override
  State<PopularCourseSection> createState() => _PopularCourseSectionState();
}

class _PopularCourseSectionState extends State<PopularCourseSection> {
  // ▶ 산 목록 데이터를 담을 Future 변수
  late Future<List<PopularMountain>> _mountainsFuture;

  @override
  void initState() {
    super.initState();
    // ▶ 초기화 시 산 데이터 요청 시작 (최대 10개 가져옴)
    _mountainsFuture = MountainApi.fetchPopularMountains(numOfRows: 10);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.screenHeight * 0.05, // ▶ 위젯 높이 (화면 높이 비율 기반)
      child: FutureBuilder<List<PopularMountain>>(
        future: _mountainsFuture, // ▶ 산 데이터 로딩 상태 감시
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // ▶ 로딩 중이면 로딩 인디케이터 표시
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            // ▶ 오류 발생 시 에러 메시지 표시
            return Center(child: Text('데이터 로드 중 오류가 발생했습니다.'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            // ▶ 데이터가 없거나 빈 경우 메시지 표시
            return Center(child: Text('데이터가 없습니다.'));
          }

          // ▶ 데이터가 정상적으로 존재할 경우 리스트로 구성
          final mountains = snapshot.data!;

          return ListView.builder(
            scrollDirection: Axis.horizontal, // ▶ 가로 스크롤 리스트뷰
            itemCount: mountains.length, // ▶ 산의 개수만큼 아이템 생성
            itemBuilder: (context, index) {
              final mountain = mountains[index]; // ▶ 현재 산 데이터

              return GestureDetector(
                onTap: () {
                  // TODO: 산을 선택했을 때 처리할 로직 추가 예정
                },
                child: Container(
                  width: widget.screenWidth * 0.2, // ▶ 아이템의 너비
                  // height: widget.screenHeight * 0.1,
                  margin: EdgeInsets.only(right: 12), // ▶ 아이템 간 간격
                  decoration: BoxDecoration(
                    color: Colors.white, // ▶ 배경색
                    borderRadius: BorderRadius.circular(30), // ▶ 모서리 둥글게
                    border: Border.all(
                      color: Colors.grey, // 테두리 색상
                      width: 1.0, // 테두리 두께
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center, // 세로 방향 중앙 정렬
                    crossAxisAlignment:
                        CrossAxisAlignment.center, // 가로 방향 중앙 정렬
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          mountain.name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: widget.screenWidth * 0.033,
                          ),
                          textAlign: TextAlign.center, // 텍스트 내부 중앙 정렬
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
