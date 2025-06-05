// 폴더 보이게 하기 위한 용도
class Post {
  final String mountain;
  final String content;
  final List<String> imagePaths; // 로컬 파일 경로 또는 URL
  final DateTime createdAt;

  Post({
    required this.mountain,
    required this.content,
    required this.imagePaths,
    required this.createdAt,
  });
}
