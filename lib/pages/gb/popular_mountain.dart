import 'package:flutter/material.dart';
import 'package:trekkit_flutter/api/mountain_api.dart'; // 산 정보를 가져오는 API 클래스
import 'package:trekkit_flutter/models/gb/popular_course_section.dart'; // 산 정보 모델 클래스
import 'package:trekkit_flutter/utils/gb/string_utils.dart';

// ▶ 지금 인기있는 산 를 보여주는 UI 위젯 (가로 스크롤 형식)
class PopularCourseSection extends StatefulWidget {
  final double screenWidth; // 외부에서 전달받은 화면 너비
  final double screenHeight; // 외부에서 전달받은 화면 높이

  const PopularCourseSection({
    super.key,
    required this.screenWidth,
    required this.screenHeight,
  });

  @override
  State<PopularCourseSection> createState() => _PopularCourseSectionState();
}

class _PopularCourseSectionState extends State<PopularCourseSection> {
  late Future<List<PopularMountain>> _mountainsFuture;

  int selectedIndex = 0;

  late final PageController _pageController; // 이미지 영역
  late final ScrollController _listController; // 산 이름 리스트

  @override
  void initState() {
    super.initState();
    _mountainsFuture = MountainApi.fetchPopularMountains(numOfRows: 10);
    _pageController = PageController(initialPage: selectedIndex);
    _listController = ScrollController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _listController.dispose();
    super.dispose();
  }

  // ▶ 리스트를 index 위치로 부드럽게 스크롤
  void _scrollToIndex(int index) {
    final itemWidth = widget.screenWidth * 0.2 + 12; // 카드폭 + margin
    final offset = itemWidth * index;
    _listController.animateTo(
      offset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<PopularMountain>>(
      future: _mountainsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('데이터 로드 오류'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('데이터 없음'));
        }

        final mountains = snapshot.data!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /* ─────────── ① 산 이름 가로 리스트 ─────────── */
            SizedBox(
              height: widget.screenHeight * 0.05,
              child: ListView.builder(
                controller: _listController, // ★ 리스트 컨트롤러
                scrollDirection: Axis.horizontal,
                itemCount: mountains.length,
                itemBuilder: (context, index) {
                  final mountain = mountains[index];
                  final isSelected = index == selectedIndex;

                  return GestureDetector(
                    onTap: () {
                      setState(() => selectedIndex = index);
                      _pageController.animateToPage(
                        // ★ 이미지도 이동
                        index,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                      _scrollToIndex(index); // ★ 리스트 위치 맞춤
                    },
                    child: Container(
                      width: widget.screenWidth * 0.2,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.green[100] : Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: isSelected ? Colors.green : Colors.grey,
                          width: 1.5,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        mountain.name,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: widget.screenWidth * 0.033,
                          color: isSelected ? Colors.green[800] : Colors.black,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            SizedBox(height: widget.screenHeight * 0.02),

            /* ─────────── ② 이미지 PageView (스와이프 가능) ─────────── */
            SizedBox(
              height: widget.screenHeight * 0.25,
              child: PageView.builder(
                controller: _pageController,
                itemCount: mountains.length,
                onPageChanged: (index) {
                  setState(() => selectedIndex = index); // 카드 하이라이트
                  _scrollToIndex(index); // 이름 리스트도 이동
                },
                itemBuilder: (context, index) {
                  final mountain = mountains[index];
                  final imagePath =
                      'assets/images/${getImageFolder(mountain.name)}/1.jpg';

                  print('Loading image from: $imagePath'); // 디버깅용 출력
                  print(
                    '산 이름: ${mountain.name}, 변환된 폴더: ${getImageFolder(mountain.name)}',
                  );

                  return Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(
                        imagePath, // 여기에서 재사용
                        width: widget.screenWidth * 0.9,
                        height: widget.screenHeight * 0.25,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          print('Image load error: $error');
                          return const Text('이미지를 불러올 수 없습니다');
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
