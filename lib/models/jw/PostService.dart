import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:trekkit_flutter/models/jw/Post.dart';

class PostService {
  // 백엔드 서버 URL (실제 서버 주소로 변경하세요)
  static const String baseUrl = 'http://localhost:8080/api/posts';

  // HTTP 헤더 설정
  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  /// 게시글 목록 조회
  static Future<Map<String, dynamic>> getPosts({
    String sort = '최신순',
    String? mountain,
    int page = 0,
    int size = 10,
  }) async {
    try {
      // 쿼리 파라미터 구성
      Map<String, String> queryParams = {
        'sort': sort,
        'page': page.toString(),
        'size': size.toString(),
      };

      if (mountain != null && mountain.isNotEmpty) {
        queryParams['mountain'] = mountain;
      }

      final uri = Uri.parse(baseUrl).replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));

        return {
          'posts':
              (data['posts'] as List)
                  .map((json) => Post.fromJson(json))
                  .toList(),
          'totalCount': data['totalCount'],
          'currentPage': data['currentPage'],
          'pageSize': data['pageSize'],
        };
      } else {
        throw Exception('게시글 조회 실패: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('네트워크 오류: $e');
    }
  }

  /// 게시글 상세 조회
  static Future<Post> getPost(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/$id'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        return Post.fromJson(data);
      } else if (response.statusCode == 404) {
        throw Exception('게시글을 찾을 수 없습니다');
      } else {
        throw Exception('게시글 조회 실패: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('네트워크 오류: $e');
    }
  }

  /// 새 게시글 작성
  static Future<Post> createPost(Post post) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: headers,
        body: json.encode(post.toJson()),
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        return Post.fromJson(data);
      } else {
        throw Exception('게시글 작성 실패: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('네트워크 오류: $e');
    }
  }

  /// 이미지 업로드
  static Future<List<String>> uploadImages(List<File> images) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/upload-images'),
      );

      for (int i = 0; i < images.length; i++) {
        request.files.add(
          await http.MultipartFile.fromPath('images', images[i].path),
        );
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final data = json.decode(responseBody);
        if (data['success']) {
          return List<String>.from(data['imagePaths']);
        } else {
          throw Exception(data['error'] ?? '이미지 업로드 실패');
        }
      } else {
        throw Exception('이미지 업로드 실패: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('네트워크 오류: $e');
    }
  }

  /// 좋아요 토글
  static Future<Map<String, dynamic>> toggleLike(
    int postId,
    String userId,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/$postId/like?userId=$userId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        return {'isLiked': data['isLiked'], 'likeCount': data['likeCount']};
      } else {
        throw Exception('좋아요 처리 실패: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('네트워크 오류: $e');
    }
  }

  /// 북마크 토글
  static Future<bool> toggleBookmark(int postId, String userId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/$postId/bookmark?userId=$userId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        return data['isBookmarked'];
      } else {
        throw Exception('북마크 처리 실패: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('네트워크 오류: $e');
    }
  }

  /// 산 목록 조회
  static Future<List<String>> getMountains() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/mountains'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        return List<String>.from(data);
      } else {
        throw Exception('산 목록 조회 실패: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('네트워크 오류: $e');
    }
  }

  /// 게시글 삭제
  static Future<bool> deletePost(int postId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/$postId'),
        headers: headers,
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('네트워크 오류: $e');
    }
  }
}
