import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:trekkit_flutter/models/jw/Post.dart';

class PostService {
  // 백엔드 서버 URL - Android 에뮬레이터용 주소로 수정
  static const String baseUrl = 'http://10.0.2.2:30000/api/posts';

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
          'totalCount': data['totalCount'] ?? 0,
          'currentPage': data['currentPage'] ?? 0,
          'pageSize': data['pageSize'] ?? size,
        };
      } else {
        throw Exception('게시글 조회 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('PostService.getPosts 오류: $e');
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
      print('PostService.getPost 오류: $e');
      throw Exception('네트워크 오류: $e');
    }
  }

  /// 새 게시글 작성
  static Future<Post> createPost(Post post) async {
    try {
      final postData = post.toJson();
      // ID는 서버에서 생성하므로 제거
      postData.remove('id');

      final response = await http.post(
        Uri.parse(baseUrl),
        headers: headers,
        body: json.encode(postData),
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        return Post.fromJson(data);
      } else {
        final errorData = json.decode(utf8.decode(response.bodyBytes));
        throw Exception(
          '게시글 작성 실패: ${errorData['error'] ?? response.statusCode}',
        );
      }
    } catch (e) {
      print('PostService.createPost 오류: $e');
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

      // 각 이미지를 'images' 필드명으로 추가
      for (int i = 0; i < images.length; i++) {
        request.files.add(
          await http.MultipartFile.fromPath('images', images[i].path),
        );
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final data = json.decode(responseBody);
        if (data['success'] == true) {
          return List<String>.from(data['imagePaths'] ?? []);
        } else {
          throw Exception(data['error'] ?? '이미지 업로드 실패');
        }
      } else {
        throw Exception('이미지 업로드 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('PostService.uploadImages 오류: $e');
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
        return {
          'isLiked': data['isLiked'] ?? false,
          'likeCount': data['likeCount'] ?? 0,
        };
      } else {
        final errorData = json.decode(utf8.decode(response.bodyBytes));
        throw Exception(
          '좋아요 처리 실패: ${errorData['error'] ?? response.statusCode}',
        );
      }
    } catch (e) {
      print('PostService.toggleLike 오류: $e');
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
        return data['isBookmarked'] ?? false;
      } else {
        final errorData = json.decode(utf8.decode(response.bodyBytes));
        throw Exception(
          '북마크 처리 실패: ${errorData['error'] ?? response.statusCode}',
        );
      }
    } catch (e) {
      print('PostService.toggleBookmark 오류: $e');
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
      print('PostService.getMountains 오류: $e');
      // 오류 시 기본 산 목록 반환
      return ['한라산', '지리산', '설악산', '북한산', '내장산'];
    }
  }

  /// 게시글 삭제
  static Future<bool> deletePost(int postId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/$postId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        return data['success'] ?? false;
      } else {
        return false;
      }
    } catch (e) {
      print('PostService.deletePost 오류: $e');
      throw Exception('네트워크 오류: $e');
    }
  }
}
