// 폴더 보이게 하기 위한 용도
import 'package:flutter/material.dart';
import 'package:trekkit_flutter/pages/jw/PostWriting.dart';
import 'ViewDetail.dart';
import 'package:trekkit_flutter/models/jw/Post.dart';

//페이지 뷰
class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => CommunityPageState(); // ✅ 올바르게 State 객체 반환
}

class CommunityPageState extends State<CommunityPage> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(title: const Text('커뮤니티')),
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.all(screenWidth * 0.1),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              //children 내에 대괄호에 다른 클래스 작성
              children: const [PostFilter(), PostList()],
            ),
          ),

          // ✅ 우측 하단 고정 버튼
          Positioned(
            bottom: 20,
            right: 20,
            child: GestureDetector(
              onTap: () {
                // 👉 PostWriting 페이지로 이동
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) =>
                            const PostWriting(), // PostWriting이 Stateless 또는 StatefulWidget일 경우
                  ),
                );
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.lightGreenAccent, // ✅ 밝은 연두색 계열
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text(
                    '+',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

//필터
class PostFilter extends StatefulWidget {
  const PostFilter({super.key});

  @override
  State<PostFilter> createState() => _PostFilterState();
}

class _PostFilterState extends State<PostFilter> {
  String _sortOption = '최신순';
  String? _selectedMountain;
  final List<String> _selectedAges = [];

  final List<String> sortOptions = ['최신순', '인기순'];
  final List<String> ageOptions = ['30대', '40대', '50대', '60대 이상'];

  final List<String> mountainOptions = [
    '가령산',
    '감악산 (파주)',
    '관악산',
    '계룡산 (대전/충남)',
    '구봉산 (대전)',
  ];

  // 필터 연령대 토글
  // 동작 흐름:
  // 이미 선택된 연령이면 → 제거
  // 아직 선택되지 않은 연령이면 → 추가
  void _toggleAge(String age) {
    setState(() {
      if (_selectedAges.contains(age)) {
        _selectedAges.remove(age);
      } else {
        _selectedAges.add(age);
      }
    });
  }

  // 필터 산 토글
  void _selectMountain(String? mountain) {
    setState(() {
      _selectedMountain = mountain;
    });
  }

  // 필터
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          children: [
            //최신,인기순 구간
            DropdownButton<String>(
              value: _sortOption,
              items:
                  sortOptions.map((option) {
                    return DropdownMenuItem<String>(
                      value: option,
                      child: Text(option),
                    );
                  }).toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _sortOption = val;
                  });
                }
              },
            ),
            // 산 구간
            DropdownButton<String>(
              hint: const Text('산'),
              value: _selectedMountain,
              items:
                  mountainOptions.map((mountain) {
                    return DropdownMenuItem<String>(
                      value: mountain,
                      child: Text(mountain),
                    );
                  }).toList(),
              onChanged: _selectMountain,
            ),
            //연령 구간
            PopupMenuButton<String>(
              onSelected: _toggleAge,
              itemBuilder: (context) {
                return ageOptions.map((age) {
                  return CheckedPopupMenuItem<String>(
                    value: age,
                    checked: _selectedAges.contains(age),
                    child: Text(age),
                  );
                }).toList();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12, //가로여백
                  vertical: 8, //세로여백
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _selectedAges.isEmpty ? '연령' : _selectedAges.join(', '),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

//글(Post)
class PostList extends StatefulWidget {
  const PostList({super.key});
  @override
  State<PostList> createState() => _PostListState();
}

class _PostListState extends State<PostList> {
  @override
  Widget build(BuildContext context) {
    final dummyPosts = List.generate(
      5,
      (index) => Post(
        mountain: '관악산',
        content: '게시글 내용 $index입니다. 긴 텍스트가 들어갈 수 있어요.',
        imagePaths: ['path1', 'path2'],
        createdAt: DateTime(2025, 6, 1 + index),
      ),
    );

    return Expanded(
      child: ListView.builder(
        itemCount: dummyPosts.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: PostItem(post: dummyPosts[index]), // ✅ Post 전달
          );
        },
      ),
    );
  }
}

// _PostListeState의 자식
class PostItem extends StatefulWidget {
  final Post post; // ✅ Post 추가

  const PostItem({super.key, required this.post});

  @override
  State<PostItem> createState() => _PostItemState();
}

class _PostItemState extends State<PostItem> {
  bool isFavorite = false; // 좋아요 상태
  bool isBookmarked = false; // 북마크 상태

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // ✅ ViewDetail로 이동하며 post 전달
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ViewDetail(post: widget.post),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🟡 프로필 정보
          Row(
            children: [
              const CircleAvatar(radius: 20, backgroundColor: Colors.grey),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '닉네임',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${widget.post.createdAt.year}-${widget.post.createdAt.month.toString().padLeft(2, '0')}-${widget.post.createdAt.day.toString().padLeft(2, '0')}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),

          // 🟡 이미지 슬라이더
          SizedBox(
            height: 200,
            child: PageView.builder(
              itemCount: widget.post.imagePaths.length,
              itemBuilder: (context, index) {
                return Container(
                  color: Colors.grey[300],
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  child: Center(child: Text('사진 $index')), // 실제 이미지 대체 가능
                );
              },
            ),
          ),

          const SizedBox(height: 10),

          // 🟡 본문 내용
          Text(
            widget.post.content,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 10),

          // 🟡 아이콘 - 좋아요, 댓글, 북마크
          Row(
            children: [
              // 좋아요 아이콘 버튼
              IconButton(
                iconSize: 28,
                onPressed: () {
                  setState(() {
                    isFavorite = !isFavorite;
                  });
                },
                icon: Icon(
                  Icons.favorite,
                  color: isFavorite ? Colors.red : Colors.grey,
                ),
                splashRadius: 24,
                tooltip: '좋아요',
              ),
              const SizedBox(width: 4),
              const Text('12'),

              const SizedBox(width: 20),

              // 댓글 아이콘 (변경 없음)
              const Icon(Icons.comment, color: Colors.grey),
              const SizedBox(width: 4),
              const Text('5'),

              const Spacer(),

              // 북마크 아이콘 버튼
              IconButton(
                iconSize: 28,
                onPressed: () {
                  setState(() {
                    isBookmarked = !isBookmarked;
                  });
                },
                icon: Icon(
                  isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                  color: isBookmarked ? Colors.yellow : Colors.black,
                ),
                splashRadius: 24,
                tooltip: '북마크',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
