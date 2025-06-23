// lib/services/jw/PostService.dart
import 'dart:convert'; // JSON 데이터 인코딩 및 디코딩을 위한 패키지
import 'dart:io'; // SocketException (네트워크 오류) 처리를 위한 패키지
import 'package:http/http.dart' as http; // HTTP 통신을 위한 패키지
import 'package:trekkit_flutter/models/jw/Post.dart'; // Post 모델 클래스 임포트
import 'package:trekkit_flutter/services/jw/AuthService.dart'; // JWT 토큰 접근을 위한 AuthService 임포트
import 'package:flutter/material.dart'; // BuildContext 사용을 위한 Flutter Material 패키지 임포트

/// 게시글(Post) 관련 API 호출을 담당하는 서비스 클래스입니다.
/// 백엔드와의 통신을 처리하며, 인증 헤더를 자동으로 포함하고 다양한 오류를 처리합니다.
class PostService {
  // 백엔드 게시글 API의 기본 URL
  static const String baseUrl = 'http://10.0.2.2:30000/api/posts';

  /// JWT 토큰을 포함하는 HTTP 요청 헤더를 동적으로 생성하는 메서드입니다.
  /// 이 헤더는 인증이 필요한 API 요청에 사용됩니다.
  /// [context]를 통해 `AuthService`에 접근하여 토큰을 가져옵니다.
  static Map<String, String> _getAuthHeaders(BuildContext context) {
    // AuthService 싱글톤 인스턴스에서 현재 JWT 토큰을 가져옵니다.
    final String? token = AuthService().jwtToken;
    return {
      'Content-Type': 'application/json', // 요청 본문이 JSON 형식임을 명시
      'Accept': 'application/json', // 응답을 JSON 형식으로 받기를 원함을 명시
      'X-Client-Type': 'mobile', // 클라이언트 애플리케이션 타입 식별자
      if (token != null)
        'Authorization': 'Bearer $token', // 토큰이 존재할 경우 'Bearer' 스키마로 인증 헤더 추가
    };
  }

  /// 인증이 필요 없는 HTTP 요청에 사용되는 기본 헤더입니다.
  /// 클라이언트 타입만 필요할 때 사용됩니다.
  static const Map<String, String> _baseHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'X-Client-Type': 'mobile', // 일반 조회 시에도 클라이언트 타입 포함
  };

  /// 게시글 목록을 조회합니다.
  /// 정렬 기준, 산 필터, 페이지 번호, 페이지당 개수를 지정할 수 있습니다.
  /// 이 메서드는 인증 헤더를 포함하여 요청을 보냅니다.
  ///
  /// [sort] : 게시글 정렬 기준 (예: '최신순', '인기순'). 기본값은 '최신순'입니다.
  /// [mountain] : 특정 산으로 필터링할 경우의 산 이름. 선택 사항입니다.
  /// [page] : 조회할 페이지 번호 (0부터 시작). 기본값은 0입니다.
  /// [size] : 한 페이지당 게시글 개수. 기본값은 10입니다.
  /// [context] : 인증 헤더 생성을 위해 필요한 BuildContext.
  /// 반환값: `posts` (Post 객체 리스트)와 `totalCount` (전체 게시글 수)를 포함하는 Map.
  /// 예외: 네트워크 오류 등 발생 가능.
  static Future<Map<String, dynamic>> getPosts({
    String sort = '최신순',
    String? mountain,
    int page = 0,
    int size = 10,
    required BuildContext context, // BuildContext를 필수로 받음
  }) async {
    try {
      Map<String, String> queryParams = {
        'sort': sort,
        'page': page.toString(),
        'size': size.toString(),
      };
      // 산 필터가 지정된 경우 쿼리 파라미터에 추가
      if (mountain != null && mountain.isNotEmpty) {
        queryParams['mountain'] = mountain;
      }
      // 쿼리 파라미터를 포함한 URI 생성
      final uri = Uri.parse(baseUrl).replace(queryParameters: queryParams);

      // HTTP GET 요청
      final response = await http.get(
        uri,
        headers: _getAuthHeaders(context), // 인증 헤더 전달
      );

      // 응답 상태 코드에 따른 처리
      if (response.statusCode == 200) {
        // 성공 시 응답 본문을 UTF-8로 디코딩 후 JSON 파싱
        final data = json.decode(utf8.decode(response.bodyBytes));
        return {
          'posts':
              (data['posts'] as List) // 'posts' 키의 리스트를 Post 객체 리스트로 변환
                  .map((json) => Post.fromJson(json))
                  .toList(),
          'totalCount': data['totalCount'] ?? 0, // 'totalCount' 키의 값 또는 0
        };
      } else {
        // 성공 외의 상태 코드일 경우 예외 발생
        throw Exception('게시글 조회 실패: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('PostService.getPosts 오류: $e'); // 디버그 출력
      throw Exception('네트워크 오류: $e'); // 네트워크 오류로 예외 다시 발생
    }
  }

  /// 특정 게시글의 상세 정보를 조회합니다.
  /// 이 메서드는 인증이 필요 없으므로 기본 헤더를 사용합니다.
  ///
  /// [id] : 조회할 게시글의 고유 ID.
  /// 반환값: 조회된 `Post` 객체.
  /// 예외: 게시글을 찾을 수 없거나 네트워크 오류 등 발생 가능.
  static Future<Post> getPost(int id) async {
    try {
      // HTTP GET 요청
      final response = await http.get(
        Uri.parse('$baseUrl/$id'), // 게시글 ID에 해당하는 상세 조회 URL
        headers: _baseHeaders, // 인증이 필요 없는 기본 헤더 사용
      );

      // 응답 상태 코드에 따른 처리
      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        return Post.fromJson(data); // Post 객체로 변환하여 반환
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
  /// 이 메서드는 인증이 필요합니다.
  ///
  /// [post] : 작성할 `Post` 객체 (ID는 서버에서 생성되므로 제거됨).
  /// [context] : 인증 헤더 생성을 위해 필요한 BuildContext.
  /// 반환값: 서버에서 생성된 ID가 포함된 `Post` 객체.
  /// 예외: 로그인 필요, 게시글 작성 실패 (서버 오류 등) 발생 가능.
  static Future<Post> createPost(Post post, BuildContext context) async {
    try {
      // Post 객체를 JSON 형식으로 변환하고, ID 필드는 서버에서 생성되므로 제거
      final postData = post.toJson();
      postData.remove('id');

      // HTTP POST 요청
      final response = await http.post(
        Uri.parse(baseUrl), // 게시글 생성 API URL
        headers: _getAuthHeaders(context), // 인증 헤더 전달
        body: json.encode(postData), // JSON으로 인코딩된 게시글 데이터
      );

      // 응답 상태 코드에 따른 처리
      if (response.statusCode == 201 || response.statusCode == 200) {
        // 201 Created 또는 200 OK
        final data = json.decode(utf8.decode(response.bodyBytes));
        return Post.fromJson(data); // 생성된 Post 객체 반환
      } else if (response.statusCode == 401) {
        throw Exception('로그인이 필요합니다.');
      } else {
        // 그 외 오류 처리: 서버 응답 본문에서 에러 메시지 파싱 시도
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
        } catch (_) {
          // JSON 파싱 실패 시 기본 메시지 사용
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      debugPrint('PostService.createPost 오류: $e');
      throw Exception('네트워크 오류: $e');
    }
  }

  /// 이미지를 서버에 업로드합니다.
  /// 이 메서드는 인증이 필요하며, Multi-part 형식으로 파일을 전송합니다.
  ///
  /// [images] : 업로드할 `File` 객체 리스트.
  /// [context] : 인증 헤더 생성을 위해 필요한 BuildContext.
  /// 반환값: 업로드된 이미지 경로(URL) 리스트.
  /// 예외: 로그인 필요, 이미지 업로드 실패 발생 가능.
  static Future<List<String>> uploadImages(
    List<File> images,
    BuildContext context, // BuildContext를 받음
  ) async {
    try {
      // MultipartRequest 생성 (파일 업로드에 사용)
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/upload-images'), // 이미지 업로드 API URL
      );

      // 인증 헤더를 가져와 `Content-Type`을 제외하고 요청 헤더에 추가
      final authHeaders = _getAuthHeaders(context);
      request.headers.addAll(
        authHeaders..remove('Content-Type'),
      ); // Multipart 요청은 Content-Type을 자동으로 설정

      // 각 이미지를 MultipartFile로 변환하여 요청에 추가
      for (int i = 0; i < images.length; i++) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'images',
            images[i].path,
          ), // 'images'는 서버의 필드명
        );
      }

      // 요청 전송 및 응답 받기
      final response = await request.send();
      final responseBody = await response.stream.bytesToString(); // 응답 본문 읽기

      // 응답 상태 코드에 따른 처리
      if (response.statusCode == 200) {
        final data = json.decode(responseBody);
        return List<String>.from(
          data['imagePaths'] ?? [],
        ); // 'imagePaths' 키의 리스트 반환
      } else if (response.statusCode == 401) {
        throw Exception('로그인이 필요합니다.');
      } else {
        // 그 외 오류 처리: 서버 응답 본문에서 에러 메시지 파싱 시도
        String errorMessage = '이미지 업로드 실패: ${response.statusCode}';
        try {
          final errorData = json.decode(responseBody);
          if (errorData is Map && errorData.containsKey('error')) {
            errorMessage = errorData['error'];
          }
        } catch (_) {
          // JSON 파싱 실패 시 기본 메시지 사용
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      debugPrint('PostService.uploadImages 오류: $e');
      throw Exception('네트워크 오류: $e');
    }
  }

  /// 게시글에 좋아요를 토글(추가/취소)합니다.
  /// 이 메서드는 인증이 필요합니다.
  ///
  /// [postId] : 좋아요를 토글할 게시글의 고유 ID.
  /// [context] : 인증 헤더 생성을 위해 필요한 BuildContext.
  /// 반환값: `isLiked` (좋아요 상태)와 `likeCount` (갱신된 좋아요 수)를 포함하는 Map.
  /// 예외: 로그인 필요, 좋아요 처리 실패 발생 가능.
  static Future<Map<String, dynamic>> toggleLike(
    int postId,
    BuildContext context, // BuildContext를 받음
  ) async {
    try {
      // HTTP POST 요청
      final response = await http.post(
        Uri.parse('$baseUrl/$postId/like'), // 좋아요 토글 API URL
        headers: _getAuthHeaders(context), // 인증 헤더 전달
      );

      // 응답 상태 코드에 따른 처리
      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        return {
          'isLiked': data['isLiked'] ?? false, // 좋아요 상태 (true/false)
          'likeCount': data['likeCount'] ?? 0, // 갱신된 좋아요 수
        };
      } else if (response.statusCode == 401) {
        throw Exception('로그인이 필요합니다.');
      } else {
        // 그 외 오류 처리: 서버 응답 본문에서 에러 메시지 파싱 시도
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
  /// 이 메서드는 인증이 필요합니다.
  ///
  /// [postId] : 북마크를 토글할 게시글의 고유 ID.
  /// [context] : 인증 헤더 생성을 위해 필요한 BuildContext.
  /// 반환값: 북마크 상태 (`true` 또는 `false`).
  /// 예외: 로그인 필요, 북마크 처리 실패 발생 가능.
  static Future<bool> toggleBookmark(int postId, BuildContext context) async {
    try {
      // HTTP POST 요청
      final response = await http.post(
        Uri.parse('$baseUrl/$postId/bookmark'), // 북마크 토글 API URL
        headers: _getAuthHeaders(context), // 인증 헤더 전달
      );

      // 응답 상태 코드에 따른 처리
      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        return data['isBookmarked'] ?? false; // 북마크 상태 반환
      } else if (response.statusCode == 401) {
        throw Exception('로그인이 필요합니다.');
      } else {
        // 그 외 오류 처리: 서버 응답 본문에서 에러 메시지 파싱 시도
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
  /// 이 메서드는 인증이 필요 없지만, `X-Client-Type` 헤더를 포함합니다.
  ///
  /// 반환값: 산 이름(String) 리스트.
  /// 예외: 네트워크 오류 등 발생 가능. 오류 시에는 기본 산 목록 반환.
  static Future<List<String>> getMountains() async {
    try {
      // HTTP GET 요청
      final response = await http.get(
        Uri.parse('$baseUrl/mountains'), // 산 목록 조회 API URL
        headers: _baseHeaders, // 기본 헤더 (X-Client-Type 포함)
      );

      // 응답 상태 코드에 따른 처리
      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        return List<String>.from(data); // String 리스트로 변환하여 반환
      } else if (response.statusCode == 400) {
        throw Exception('잘못된 요청: 클라이언트 타입 헤더가 누락되었거나 유효하지 않습니다.');
      } else {
        throw Exception('산 목록 조회 실패: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('PostService.getMountains 오류: $e');
      // 오류 발생 시 임시 또는 기본 산 목록 반환
      return ['한라산', '지리산', '설악산', '북한산', '내장산'];
    }
  }

  /// 기존 게시글을 수정합니다.
  /// 이 메서드는 인증이 필요합니다.
  ///
  /// [post] : 수정할 `Post` 객체 (ID를 포함해야 함).
  /// [context] : 인증 헤더 생성을 위해 필요한 BuildContext.
  /// 반환값: 수정된 `Post` 객체.
  /// 예외: 로그인 필요, 권한 없음, 게시글 없음, 수정 실패 발생 가능.
  static Future<Post> updatePost(Post post, BuildContext context) async {
    try {
      final postData = post.toJson(); // Post 객체를 JSON 형식으로 변환

      // HTTP PUT 요청
      final response = await http.put(
        Uri.parse('$baseUrl/${post.id}'), // 게시글 ID에 해당하는 수정 URL
        headers: _getAuthHeaders(context), // 인증 헤더 전달
        body: json.encode(postData), // JSON으로 인코딩된 게시글 데이터
      );

      // 응답 상태 코드에 따른 처리
      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        return Post.fromJson(data); // 수정된 Post 객체 반환
      } else if (response.statusCode == 401) {
        throw Exception('로그인이 필요합니다.');
      } else if (response.statusCode == 403) {
        throw Exception('수정 권한이 없습니다.');
      } else if (response.statusCode == 404) {
        throw Exception('게시글을 찾을 수 없습니다.');
      } else {
        // 그 외 오류 처리: 서버 응답 본문에서 에러 메시지 파싱 시도
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
  /// 이 메서드는 인증이 필요합니다.
  ///
  /// [postId] : 삭제할 게시글의 고유 ID.
  /// [context] : 인증 헤더 생성을 위해 필요한 BuildContext.
  /// 반환값: 삭제 성공 여부 (`true` 또는 `false`).
  /// 예외: 로그인 필요, 권한 없음, 게시글 없음, 삭제 실패 발생 가능.
  static Future<bool> deletePost(int postId, BuildContext context) async {
    try {
      // HTTP DELETE 요청
      final response = await http.delete(
        Uri.parse('$baseUrl/$postId'), // 게시글 삭제 API URL
        headers: _getAuthHeaders(context), // 인증 헤더 전달
      );

      // 응답 상태 코드에 따른 처리
      if (response.statusCode == 204) {
        // 204 No Content (성공적으로 삭제되었지만 응답 본문 없음)
        return true;
      } else if (response.statusCode == 401) {
        throw Exception('로그인이 필요합니다.');
      } else if (response.statusCode == 403) {
        throw Exception('삭제 권한이 없습니다.');
      } else if (response.statusCode == 404) {
        throw Exception('게시글을 찾을 수 없습니다.');
      } else {
        // 그 외 오류 처리: 서버 응답 본문에서 에러 메시지 파싱 시도
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
