// lib/services/jw/PostService.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:trekkit_flutter/models/jw/Post.dart';
import 'package:trekkit_flutter/services/jw/AuthService.dart'; // AuthService 임포트
import 'package:flutter/material.dart'; // BuildContext 사용을 위해 추가

class PostService {
  static const String baseUrl = 'http://10.0.2.2:30000/api/posts';

  // 인증이 필요한 요청에 사용될 공통 헤더를 동적으로 생성하는 메서드
  // 이제 모든 호출 시 BuildContext를 받도록 변경되었습니다.
  static Map<String, String> _getAuthHeaders(BuildContext context) {
    final String? token = AuthService().jwtToken; // AuthService에서 JWT 토큰 가져오기
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'X-Client-Type': 'mobile', // 또는 'app' (일관성 유지를 위해)
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // 인증이 필요 없는 요청에 사용될 기본 헤더 (X-Client-Type만 필요할 때)
  static const Map<String, String> _baseHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'X-Client-Type': 'mobile', // 일반 조회 시에도 클라이언트 타입 필요
  };

  /// 게시글 목록 조회
  static Future<Map<String, dynamic>> getPosts({
    String sort = '최신순',
    String? mountain,
    int page = 0,
    int size = 10,
    required BuildContext context, // context를 필수로 받도록 변경
  }) async {
    try {
      Map<String, String> queryParams = {
        'sort': sort,
        'page': page.toString(),
        'size': size.toString(),
      };
      if (mountain != null && mountain.isNotEmpty) {
        queryParams['mountain'] = mountain;
      }
      final uri = Uri.parse(baseUrl).replace(queryParameters: queryParams);
      final response = await http.get(
        uri,
        headers: _getAuthHeaders(context), // _getAuthHeaders에 context 전달
      );
      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        return {
          'posts':
              (data['posts'] as List)
                  .map((json) => Post.fromJson(json))
                  .toList(),
          'totalCount': data['totalCount'] ?? 0,
        };
      } else {
        throw Exception('게시글 조회 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('PostService.getPosts 오류: $e');
      throw Exception('네트워크 오류: $e');
    }
  }

  /// 게시글 상세 조회 (인증 불필요 - _baseHeaders 사용)
  // 이 메서드는 인증이 필요 없으므로 _baseHeaders를 사용하며, context를 받지 않습니다.
  static Future<Post> getPost(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/$id'),
        headers: _baseHeaders, // X-Client-Type 포함
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
  static Future<Post> createPost(Post post, BuildContext context) async {
    // context 인자 추가
    try {
      final postData = post.toJson();
      postData.remove('id');

      final response = await http.post(
        Uri.parse(baseUrl),
        headers: _getAuthHeaders(context), // context 전달
        body: json.encode(postData),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        return Post.fromJson(data);
      } else if (response.statusCode == 401) {
        throw Exception('로그인이 필요합니다.');
      } else {
        final errorBody = utf8.decode(response.bodyBytes);
        String errorMessage = '게시글 작성 실패: ${response.statusCode}';
        try {
          final errorData = json.decode(errorBody);
          if (errorData is String) {
            errorMessage = errorData;
          } else if (errorData is Map && errorData.containsKey('error')) {
            errorMessage = errorData['error'];
          } else if (errorData is Map && errorData.containsKey('message')) {
            errorMessage = errorData['message'];
          }
        } catch (_) {}
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('PostService.createPost 오류: $e');
      throw Exception('네트워크 오류: $e');
    }
  }

  /// 이미지 업로드
  static Future<List<String>> uploadImages(
    List<File> images,
    BuildContext context,
  ) async {
    // context 인자 추가
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/upload-images'),
      );

      final authHeaders = _getAuthHeaders(context); // context 전달
      request.headers.addAll(authHeaders..remove('Content-Type'));

      for (int i = 0; i < images.length; i++) {
        request.files.add(
          await http.MultipartFile.fromPath('images', images[i].path),
        );
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final data = json.decode(responseBody);
        return List<String>.from(data['imagePaths'] ?? []);
      } else if (response.statusCode == 401) {
        throw Exception('로그인이 필요합니다.');
      } else {
        String errorMessage = '이미지 업로드 실패: ${response.statusCode}';
        try {
          final errorData = json.decode(responseBody);
          if (errorData is Map && errorData.containsKey('error')) {
            errorMessage = errorData['error'];
          }
        } catch (_) {}
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('PostService.uploadImages 오류: $e');
      throw Exception('네트워크 오류: $e');
    }
  }

  /// 좋아요 토글
  static Future<Map<String, dynamic>> toggleLike(
    int postId,
    BuildContext context,
  ) async {
    // context 인자 추가
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/$postId/like'),
        headers: _getAuthHeaders(context), // context 전달
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        return {
          'isLiked': data['isLiked'] ?? false,
          'likeCount': data['likeCount'] ?? 0,
        };
      } else if (response.statusCode == 401) {
        throw Exception('로그인이 필요합니다.');
      } else {
        final errorBody = utf8.decode(response.bodyBytes);
        String errorMessage = '좋아요 처리 실패: ${response.statusCode}';
        try {
          final errorData = json.decode(errorBody);
          if (errorData is Map && errorData.containsKey('error')) {
            errorMessage = errorData['error'];
          }
        } catch (_) {}
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('PostService.toggleLike 오류: $e');
      throw Exception('네트워크 오류: $e');
    }
  }

  /// 북마크 토글
  static Future<bool> toggleBookmark(int postId, BuildContext context) async {
    // context 인자 추가
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/$postId/bookmark'),
        headers: _getAuthHeaders(context), // context 전달
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        return data['isBookmarked'] ?? false;
      } else if (response.statusCode == 401) {
        throw Exception('로그인이 필요합니다.');
      } else {
        final errorBody = utf8.decode(response.bodyBytes);
        String errorMessage = '북마크 처리 실패: ${response.statusCode}';
        try {
          final errorData = json.decode(errorBody);
          if (errorData is Map && errorData.containsKey('error')) {
            errorMessage = errorData['error'];
          }
        } catch (_) {}
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('PostService.toggleBookmark 오류: $e');
      throw Exception('네트워크 오류: $e');
    }
  }

  /// 산 목록 조회 (백엔드는 X-Client-Type 헤더 요구)
  // 이 메서드는 _baseHeaders를 사용하므로 context를 받지 않습니다.
  static Future<List<String>> getMountains() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/mountains'),
        headers: _baseHeaders, // X-Client-Type 헤더 포함
      );
      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        return List<String>.from(data);
      } else if (response.statusCode == 400) {
        throw Exception('잘못된 요청: 클라이언트 타입 헤더가 누락되었거나 유효하지 않습니다.');
      } else {
        throw Exception('산 목록 조회 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('PostService.getMountains 오류: $e');
      return ['한라산', '지리산', '설악산', '북한산', '내장산'];
    }
  }

  /// 게시글 수정 (PUT)
  static Future<Post> updatePost(Post post, BuildContext context) async {
    // context 인자 추가
    try {
      final postData = post.toJson();

      final response = await http.put(
        Uri.parse('$baseUrl/${post.id}'),
        headers: _getAuthHeaders(context), // context 전달
        body: json.encode(postData),
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        return Post.fromJson(data);
      } else if (response.statusCode == 401) {
        throw Exception('로그인이 필요합니다.');
      } else if (response.statusCode == 403) {
        throw Exception('수정 권한이 없습니다.');
      } else if (response.statusCode == 404) {
        throw Exception('게시글을 찾을 수 없습니다.');
      } else {
        final errorBody = utf8.decode(response.bodyBytes);
        String errorMessage = '게시글 수정 실패: ${response.statusCode}';
        try {
          final errorData = json.decode(errorBody);
          if (errorData is String) {
            errorMessage = errorData;
          } else if (errorData is Map && errorData.containsKey('error')) {
            errorMessage = errorData['error'];
          }
        } catch (_) {}
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('PostService.updatePost 오류: $e');
      throw Exception('네트워크 오류: $e');
    }
  }

  /// 게시글 삭제
  static Future<bool> deletePost(int postId, BuildContext context) async {
    // context 인자 추가
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/$postId'),
        headers: _getAuthHeaders(context), // context 전달
      );

      if (response.statusCode == 204) {
        return true;
      } else if (response.statusCode == 401) {
        throw Exception('로그인이 필요합니다.');
      } else if (response.statusCode == 403) {
        throw Exception('삭제 권한이 없습니다.');
      } else if (response.statusCode == 404) {
        throw Exception('게시글을 찾을 수 없습니다.');
      } else {
        final errorBody = utf8.decode(response.bodyBytes);
        String errorMessage = '게시글 삭제 실패: ${response.statusCode}';
        try {
          final errorData = json.decode(errorBody);
          if (errorData is String) {
            errorMessage = errorData;
          } else if (errorData is Map && errorData.containsKey('error')) {
            errorMessage = errorData['error'];
          }
        } catch (_) {}
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('PostService.deletePost 오류: $e');
      throw Exception('네트워크 오류: $e');
    }
  }
}
