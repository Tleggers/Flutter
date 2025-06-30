// lib/services/jw/PostService.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:trekkit_flutter/models/jw/Post.dart';
import 'package:trekkit_flutter/services/jw/AuthService.dart';
import 'package:flutter/material.dart';

/// 게시글 관련 API 호출 서비스 클래스입니다.
class PostService {
  /// AuthService에서 API 기본 URL을 가져옵니다.
  static String get _apiBaseUrl {
    return AuthService().API_URL;
  }

  /// 인증이 필요한 API 요청 헤더를 생성합니다.
  static Map<String, String> _getAuthHeaders(BuildContext context) {
    final String? token = AuthService().jwtToken;
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'X-Client-Type': 'mobile',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// 인증이 필요 없는 API 요청을 위한 기본 헤더입니다.
  static const Map<String, String> _baseHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'X-Client-Type': 'mobile',
  };

  /// 게시글 목록을 조회합니다.
  static Future<Map<String, dynamic>> getPosts({
    String sort = '최신순',
    String? mountain,
    int page = 0,
    int size = 10,
    required BuildContext context,
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
      final uri = Uri.parse(
        '$_apiBaseUrl/api/posts',
      ).replace(queryParameters: queryParams);

      final response = await http.get(uri, headers: _getAuthHeaders(context));

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
      debugPrint('PostService.getPosts 오류: $e');
      throw Exception('네트워크 오류: $e');
    }
  }

  /// 특정 게시글의 상세 정보를 조회합니다.
  static Future<Post> getPost(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$_apiBaseUrl/api/posts/$id'),
        headers: _baseHeaders,
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
      debugPrint('PostService.getPost 오류: $e');
      throw Exception('네트워크 오류: $e');
    }
  }

  /// 새 게시글을 작성하여 서버에 전송합니다.
  static Future<Post> createPost(Post post, BuildContext context) async {
    try {
      final postData = post.toJson();
      postData.remove('id');

      final response = await http.post(
        Uri.parse('$_apiBaseUrl/api/posts'),
        headers: _getAuthHeaders(context),
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
      debugPrint('PostService.createPost 오류: $e');
      throw Exception('네트워크 오류: $e');
    }
  }

  /// 이미지를 서버에 업로드합니다.
  static Future<List<String>> uploadImages(
    List<File> images,
    BuildContext context,
  ) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$_apiBaseUrl/api/posts/upload-images'),
      );

      final authHeaders = _getAuthHeaders(context);
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
      debugPrint('PostService.uploadImages 오류: $e');
      throw Exception('네트워크 오류: $e');
    }
  }

  /// 게시글에 좋아요를 토글(추가/취소)합니다.
  static Future<Map<String, dynamic>> toggleLike(
    int postId,
    BuildContext context,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$_apiBaseUrl/api/posts/$postId/like'),
        headers: _getAuthHeaders(context),
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
      debugPrint('PostService.toggleLike 오류: $e');
      throw Exception('네트워크 오류: $e');
    }
  }

  /// 게시글에 북마크를 토글(추가/취소)합니다.
  static Future<bool> toggleBookmark(int postId, BuildContext context) async {
    try {
      final response = await http.post(
        Uri.parse('$_apiBaseUrl/api/posts/$postId/bookmark'),
        headers: _getAuthHeaders(context),
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
      debugPrint('PostService.toggleBookmark 오류: $e');
      throw Exception('네트워크 오류: $e');
    }
  }

  /// 산 목록을 조회합니다.
  static Future<List<String>> getMountains() async {
    try {
      final response = await http.get(
        Uri.parse('$_apiBaseUrl/api/posts/mountains'),
        headers: _baseHeaders,
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
      debugPrint('PostService.getMountains 오류: $e');
      return ['한라산', '지리산', '설악산', '북한산', '내장산'];
    }
  }

  /// 기존 게시글을 수정합니다.
  static Future<Post> updatePost(Post post, BuildContext context) async {
    try {
      final postData = post.toJson();

      final response = await http.put(
        Uri.parse('$_apiBaseUrl/api/posts/${post.id}'),
        headers: _getAuthHeaders(context),
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
      debugPrint('PostService.updatePost 오류: $e');
      throw Exception('네트워크 오류: $e');
    }
  }

  /// 특정 게시글을 삭제합니다.
  static Future<bool> deletePost(int postId, BuildContext context) async {
    try {
      final response = await http.delete(
        Uri.parse('$_apiBaseUrl/api/posts/$postId'),
        headers: _getAuthHeaders(context),
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
      debugPrint('PostService.deletePost 오류: $e');
      throw Exception('네트워크 오류: $e');
    }
  }
}
