import 'package:flutter/material.dart';
import 'package:trekkit_flutter/pages/jw/CommunityPage.dart';
import 'package:trekkit_flutter/pages/jw/ViewDetail.dart';
import 'package:trekkit_flutter/pages/mainpage.dart';
import 'package:trekkit_flutter/services/jw/PostService.dart';
import 'package:trekkit_flutter/models/jw/Post.dart';

class CommunityPreviewList extends StatefulWidget {
  const CommunityPreviewList({super.key});

  @override
  State<CommunityPreviewList> createState() => _CommunityPreviewListState();
}

class _CommunityPreviewListState extends State<CommunityPreviewList> {
  List<Post> _posts = []; // 게시글 저장 리스트

  @override
  void initState() {
    super.initState();
    _fetchPosts(); // 시작 시 게시글 가져오기
  }

  Future<void> _fetchPosts() async {
    try {
      final result = await PostService.getPosts(context: context, size: 5);

      print('📌 서버 응답 결과: $result');
      print('📌 받아온 게시글 수: ${result['posts'].length}');
      setState(() {
        _posts = result['posts'];
      });
    } catch (e) {
      print('❌ 게시글 불러오기 실패: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 185, 223, 170), // 연한 초록색 배경
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 제목 + 부제목 + 아이콘 버튼 영역
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  flex: 9, // 너비 비율 조정 (절대값 아님)
                  child: Text.rich(
                    TextSpan(
                      children: [
                        const TextSpan(
                          text: '실시간 Trekkit 👀',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const TextSpan(
                          text: 'Tleggers Chit-Chat! 👄',
                          style: TextStyle(
                            fontSize: 9,
                            color: Color.fromARGB(255, 136, 133, 133),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Flexible(
                  flex: 1,
                  child: Align(
                    alignment: Alignment.topRight,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => MainPage(
                                  title: '트레킷',
                                  initialIndex: 2, // 나중에 2로 수정(mapPage.dart생기면)
                                ),
                          ),
                          (route) => false, // ✅ 이전 스택 모두 제거
                        );
                      },
                      child: const Icon(Icons.chevron_right),
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: screenHeight * 0.0008),
          // 게시글 리스트 가로 스크롤
          SizedBox(
            height: screenHeight * 0.13,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              itemCount: _posts.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final post = _posts[index];

                return GestureDetector(
                  onTap: () async {
                    if (post.id == null) return;
                    try {
                      final detailedPost = await PostService.getPost(post.id!);
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ViewDetail(post: detailedPost),
                        ),
                      );

                      if (result == true) {
                        // 필요하다면 setState(() => ...) 등으로 목록 갱신
                      }
                    } catch (e) {
                      print("상세 조회 실패: $e");
                    }
                  },
                  child: Container(
                    width: screenHeight * 0.18,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            // const CircleAvatar(
                            //   radius: 10,
                            //   backgroundImage: AssetImage(
                            //     'assets/images/default_profile.png',
                            //   ),
                            // ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                post.nickname,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 10),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          post.title ?? '',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
