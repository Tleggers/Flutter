// 폴더 보이게 하기 위한 용도
import 'package:flutter/material.dart';

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
              children: const [PostFilter(), PostList()],
            ),
          ),

          // ✅ 우측 하단 고정 버튼
          Positioned(
            bottom: 20,
            right: 20,
            child: GestureDetector(
              onTap: () {
                // 여기에 버튼 클릭시 동작을 추가하세요.
                print('추가 버튼 클릭됨!');
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
    // 나중에 백엔드 데이터로 대체할 리스트
    //dummyPosts, 즉 로컬데이터 테스트 상태
    final dummyPosts = List.generate(5, (index) => {}); // 빈 리스트로 틀만 잡음

    return Expanded(
      child: ListView.builder(
        itemCount: dummyPosts.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: PostItem(), //하단의 class 추적
          );
        },
      ),
    );
  }
}

//_PostListeState의 자식
class PostItem extends StatelessWidget {
  const PostItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 🟡 프로필 정보 (유저 프로필 + 닉네임 + 등록일)
        Row(
          children: [
            const CircleAvatar(
              radius: 20,
              backgroundColor: Colors.grey, // 실제 이미지 올 때 교체
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              //로컬테스트 상태라서 '닉네임','작성일자'가 그대로 노출, 추후 백앤드 연결 후 데이터 노출
              children: const [
                Text('닉네임', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  '2025-06-01',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),

        const SizedBox(height: 10),

        // 🟡 사진 영역 (슬라이더 가능하게 틀만)
        SizedBox(
          height: 200,
          child: PageView.builder(
            itemCount: 5, //사진 몇개 노출 할 지 정하는 코드
            itemBuilder: (context, index) {
              //테스트를 위해 Containor에 회색,글씨 돌출, 추후 DB에 있는 사진으로 대처
              return Container(
                color: Colors.grey[300],
                margin: const EdgeInsets.symmetric(horizontal: 4),
                child: Center(child: Text('사진 $index')),
              );
            },
          ),
        ),

        const SizedBox(height: 10),

        // 🟡 본문 텍스트
        const Text(
          '게시글 내용이 여기에 들어갑니다. 3줄 이상이면 자동으로 ... 표시됩니다.',
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),

        const SizedBox(height: 10), //ui 디자인을 위해 10픽셀 빈공간 생성
        // 🟡 하트 / 댓글 / 북마크 아이콘
        Row(
          children: const [
            Icon(Icons.favorite, color: Colors.red),
            SizedBox(width: 4),
            Text('12'),
            SizedBox(width: 20),
            Icon(Icons.comment, color: Colors.grey),
            SizedBox(width: 4),
            Text('5'),
            Spacer(),
            Icon(Icons.bookmark_border, color: Colors.grey),
          ],
        ),
      ],
    );
  }
}
