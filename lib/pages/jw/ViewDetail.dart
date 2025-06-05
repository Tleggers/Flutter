import 'package:flutter/material.dart';
import 'package:trekkit_flutter/models/jw/Post.dart';

class ViewDetail extends StatefulWidget {
  final Post post;

  const ViewDetail({super.key, required this.post});

  @override
  State<ViewDetail> createState() => _ViewDetailState();
}

class _ViewDetailState extends State<ViewDetail> {
  bool isFavorite = false;
  bool isBookmarked = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('게시글 상세')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. 글쓴이 정보
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
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 2. 이미지 슬라이더
            SizedBox(
              height: 250,
              child: PageView.builder(
                itemCount: widget.post.imagePaths.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    color: Colors.grey[300],
                    child: Center(child: Text('사진 ${index + 1}')),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // 3. 본문
            Text(widget.post.content, style: const TextStyle(fontSize: 16)),

            const SizedBox(height: 20),

            // 4. 아이콘 영역 (토글 가능)
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      isFavorite = !isFavorite;
                    });
                  },
                  child: Icon(
                    Icons.favorite,
                    color: isFavorite ? Colors.red : Colors.grey,
                  ),
                ),
                const SizedBox(width: 4),
                const Text('12'),
                const SizedBox(width: 20),
                const Icon(Icons.comment, color: Colors.grey),
                const SizedBox(width: 4),
                const Text('5'),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      isBookmarked = !isBookmarked;
                    });
                  },
                  child: Icon(
                    isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                    color: isBookmarked ? Colors.yellow[700] : Colors.black,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 5. 댓글 수 및 리스트 (더미 유지)
            const Text(
              '댓글 총 3개',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Column(
              children: List.generate(3, (index) {
                return ListTile(
                  leading: const CircleAvatar(backgroundColor: Colors.grey),
                  title: Text('유저 $index'),
                  subtitle: const Text('댓글 내용이 여기에 표시됩니다.'),
                  trailing: const Text(
                    '2025-06-04',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
