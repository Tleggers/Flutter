// lib/services/jw/CommentService.dart
import 'dart:convert'; // JSON 데이터 인코딩 및 디코딩을 위한 패키지
import 'dart:io'; // SocketException (네트워크 오류) 처리를 위한 패키지
import 'package:http/http.dart' as http; // HTTP 통신을 위한 패키지
import 'package:trekkit_flutter/models/jw/Comment.dart'; // Comment 모델 클래스 임포트
import 'package:trekkit_flutter/services/jw/AuthService.dart'; // JWT 토큰 접근을 위한 AuthService 임포트
import 'package:flutter/material.dart'; // BuildContext 사용을 위한 Flutter Material 패키지 임포트

/// 댓글(Comment) 관련 API 호출을 담당하는 서비스 클래스입니다.
/// 백엔드와의 통신을 처리하며, 인증 헤더를 자동으로 포함하고 다양한 오류를 처리합니다.
class CommentService {
  // 백엔드 댓글 API의 기본 URL
  static const String baseUrl = 'http://10.0.2.2:30000/api/comments';

  /// JWT 토큰을 포함하는 HTTP 요청 헤더를 생성하는 메서드입니다.
  /// 이 헤더는 인증이 필요한 API 요청에 사용됩니다.
  /// [context]는 `AuthService`에서 토큰을 가져올 때 필요할 수 있습니다.
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
  static const Map<String, String> _baseHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'X-Client-Type': 'mobile', // 일반 조회 시에도 클라이언트 타입 포함
  };

  /// 특정 게시글([postId])에 속한 댓글 목록을 조회합니다.
  /// 이 메서드는 인증 없이도 호출 가능합니다.
  ///
  /// [postId] : 댓글을 조회할 게시글의 고유 ID.
  /// 반환값: `Comment` 객체 리스트.
  /// 예외: `CommentException` (네트워크 오류, 서버 오류 등) 발생 가능.
  static Future<List<Comment>> getCommentsByPostId(int postId) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/post/$postId'), // 게시글 ID에 해당하는 댓글 조회 URL
            headers: _baseHeaders, // 인증이 필요 없는 기본 헤더 사용
          )
          .timeout(const Duration(seconds: 10)); // 10초 타임아웃 설정

      // HTTP 응답 상태 코드에 따른 처리
      switch (response.statusCode) {
        case 200: // 성공 (OK)
          final List<dynamic> data = json.decode(
            utf8.decode(response.bodyBytes), // 응답 본문을 UTF-8로 디코딩 후 JSON 파싱
          );
          // 파싱된 JSON 데이터를 Comment 객체 리스트로 변환하여 반환
          return data.map((json) => Comment.fromJson(json)).toList();

        case 404: // 찾을 수 없음 (Not Found)
          throw CommentException('게시글을 찾을 수 없습니다', CommentErrorType.notFound);
        case 500: // 서버 내부 오류 (Internal Server Error)
          throw CommentException('서버 오류가 발생했습니다', CommentErrorType.serverError);
        case 403: // 접근 금지 (Forbidden)
          throw CommentException('접근 권한이 없습니다', CommentErrorType.forbidden);
        default: // 그 외의 상태 코드
          throw CommentException(
            '댓글 조회 실패: ${response.statusCode}',
            CommentErrorType.unknown, // 알 수 없는 오류 타입
          );
      }
    } on SocketException {
      // 네트워크 연결 오류 처리
      throw CommentException('네트워크 연결을 확인해주세요', CommentErrorType.network);
    } on HttpException {
      // HTTP 요청 자체의 오류 처리
      throw CommentException('HTTP 요청 오류가 발생했습니다', CommentErrorType.http);
    } on FormatException {
      // 응답 데이터 형식 오류 처리 (예: 유효하지 않은 JSON)
      throw CommentException('데이터 형식 오류가 발생했습니다', CommentErrorType.format);
    } catch (e) {
      // 예상치 못한 기타 오류 처리
      debugPrint('CommentService.getCommentsByPostId 오류: $e'); // 디버그 콘솔에 오류 출력
      if (e is CommentException) rethrow; // 이미 CommentException이면 다시 던짐
      throw CommentException('예상치 못한 오류가 발생했습니다: $e', CommentErrorType.unknown);
    }
  }

  /// 새로운 댓글을 작성하여 서버에 전송합니다.
  /// 이 메서드는 인증이 필요하며, 댓글 내용의 유효성을 검사합니다.
  ///
  /// [comment] : 작성할 `Comment` 객체 (ID는 서버에서 생성되므로 null일 수 있음).
  /// [context] : 인증 헤더 생성을 위해 필요한 BuildContext.
  /// 반환값: 서버에서 생성된 ID가 포함된 `Comment` 객체.
  /// 예외: `CommentException` (유효성 검사 실패, 인증 오류, 서버 오류 등) 발생 가능.
  static Future<Comment> createComment(
    Comment comment,
    BuildContext context, // 인증 헤더 생성을 위해 context 필요
  ) async {
    try {
      // 댓글 내용 유효성 검사
      if (comment.content.trim().isEmpty) {
        throw CommentException('댓글 내용을 입력해주세요', CommentErrorType.validation);
      }
      if (comment.content.length > 200) {
        throw CommentException(
          '댓글은 200자를 초과할 수 없습니다',
          CommentErrorType.validation,
        );
      }

      // Comment 객체를 JSON 형식으로 변환하고, ID 필드는 서버에서 생성되므로 제거
      final commentData = comment.toJson();
      commentData.remove('id');

      final response = await http
          .post(
            Uri.parse(baseUrl), // 댓글 생성 API URL
            headers: _getAuthHeaders(context), // 인증 헤더 사용
            body: json.encode(commentData), // JSON으로 인코딩된 댓글 데이터
          )
          .timeout(const Duration(seconds: 15)); // 15초 타임아웃 설정

      // HTTP 응답 상태 코드에 따른 처리
      switch (response.statusCode) {
        case 200: // 성공 (OK) 또는 201 (Created)
        case 201:
          final data = json.decode(utf8.decode(response.bodyBytes));
          return Comment.fromJson(data); // 생성된 댓글 정보로 Comment 객체 생성 및 반환

        case 400: // 잘못된 요청 (Bad Request)
          throw CommentException('잘못된 요청입니다', CommentErrorType.badRequest);
        case 401: // 인증되지 않음 (Unauthorized)
          throw CommentException('로그인이 필요합니다', CommentErrorType.unauthorized);
        case 403: // 접근 금지 (Forbidden)
          throw CommentException('댓글 작성 권한이 없습니다', CommentErrorType.forbidden);
        case 500: // 서버 내부 오류 (Internal Server Error)
          throw CommentException(
            '서버 오류로 댓글 작성에 실패했습니다',
            CommentErrorType.serverError,
          );
        default: // 그 외의 상태 코드
          throw CommentException(
            '댓글 작성 실패: ${response.statusCode}',
            CommentErrorType.unknown,
          );
      }
    } on SocketException {
      throw CommentException('네트워크 연결을 확인해주세요', CommentErrorType.network);
    } on HttpException {
      throw CommentException('HTTP 요청 오류가 발생했습니다', CommentErrorType.http);
    } on FormatException {
      throw CommentException('데이터 형식 오류가 발생했습니다', CommentErrorType.format);
    } catch (e) {
      debugPrint('CommentService.createComment 오류: $e');
      if (e is CommentException) rethrow;
      throw CommentException('예상치 못한 오류가 발생했습니다: $e', CommentErrorType.unknown);
    }
  }

  /// 기존 댓글을 수정합니다.
  /// 이 메서드는 인증이 필요하며, 댓글 내용의 유효성을 검사합니다.
  ///
  /// [comment] : 수정할 `Comment` 객체 (ID를 포함해야 함).
  /// [context] : 인증 헤더 생성을 위해 필요한 BuildContext.
  /// 반환값: 수정된 `Comment` 객체.
  /// 예외: `CommentException` (유효성 검사 실패, 인증 오류, 권한 없음, 댓글 없음 등) 발생 가능.
  static Future<Comment> updateComment(
    Comment comment,
    BuildContext context, // 인증 헤더 생성을 위해 context 필요
  ) async {
    try {
      // 댓글 내용 유효성 검사
      if (comment.content.trim().isEmpty) {
        throw CommentException('댓글 내용을 입력해주세요', CommentErrorType.validation);
      }
      if (comment.content.length > 200) {
        throw CommentException(
          '댓글은 200자를 초과할 수 없습니다',
          CommentErrorType.validation,
        );
      }

      final response = await http
          .put(
            Uri.parse('$baseUrl/${comment.id}'), // 댓글 ID에 해당하는 수정 URL
            headers: _getAuthHeaders(context), // 인증 헤더 사용
            body: json.encode(comment.toJson()), // JSON으로 인코딩된 댓글 데이터
          )
          .timeout(const Duration(seconds: 15)); // 15초 타임아웃 설정

      // HTTP 응답 상태 코드에 따른 처리
      switch (response.statusCode) {
        case 200: // 성공 (OK)
          final data = json.decode(utf8.decode(response.bodyBytes));
          return Comment.fromJson(data); // 수정된 댓글 정보로 Comment 객체 생성 및 반환

        case 400:
          throw CommentException('잘못된 요청입니다', CommentErrorType.badRequest);
        case 401:
          throw CommentException('로그인이 필요합니다', CommentErrorType.unauthorized);
        case 403:
          throw CommentException('댓글 수정 권한이 없습니다', CommentErrorType.forbidden);
        case 404:
          throw CommentException(
            '수정할 댓글을 찾을 수 없습니다',
            CommentErrorType.notFound,
          );
        case 500:
          throw CommentException(
            '서버 오류로 댓글 수정에 실패했습니다',
            CommentErrorType.serverError,
          );
        default:
          throw CommentException(
            '댓글 수정 실패: ${response.statusCode}',
            CommentErrorType.unknown,
          );
      }
    } on SocketException {
      throw CommentException('네트워크 연결을 확인해주세요', CommentErrorType.network);
    } on HttpException {
      throw CommentException('HTTP 요청 오류가 발생했습니다', CommentErrorType.http);
    } on FormatException {
      throw CommentException('데이터 형식 오류가 발생했습니다', CommentErrorType.format);
    } catch (e) {
      debugPrint('CommentService.updateComment 오류: $e');
      if (e is CommentException) rethrow;
      throw CommentException('예상치 못한 오류가 발생했습니다: $e', CommentErrorType.unknown);
    }
  }

  /// 특정 댓글을 삭제합니다.
  /// 이 메서드는 인증이 필요하며, 사용자가 해당 댓글을 삭제할 권한이 있는지 확인합니다.
  ///
  /// [commentId] : 삭제할 댓글의 고유 ID.
  /// [postId] : 댓글이 속한 게시글의 고유 ID (경로 구성에 사용).
  /// [context] : 인증 헤더 생성을 위해 필요한 BuildContext.
  /// 반환값: 삭제 성공 여부 (`true` 또는 `false`).
  /// 예외: `CommentException` (댓글 없음, 권한 없음, 서버 오류 등) 발생 가능.
  static Future<bool> deleteComment(
    int commentId,
    int postId,
    BuildContext context, // 인증 헤더 생성을 위해 context 필요
  ) async {
    try {
      final response = await http
          .delete(
            Uri.parse('$baseUrl/$commentId/post/$postId'), // 댓글 삭제 API URL
            headers: _getAuthHeaders(context), // 인증 헤더 사용
          )
          .timeout(const Duration(seconds: 10)); // 10초 타임아웃 설정

      // HTTP 응답 상태 코드에 따른 처리
      switch (response.statusCode) {
        case 200: // 성공 (OK)
          return true; // 삭제 성공

        case 404:
          throw CommentException(
            '삭제할 댓글을 찾을 수 없습니다',
            CommentErrorType.notFound,
          );
        case 403:
          throw CommentException('댓글 삭제 권한이 없습니다', CommentErrorType.forbidden);
        case 500:
          throw CommentException(
            '서버 오류로 댓글 삭제에 실패했습니다',
            CommentErrorType.serverError,
          );
        default:
          throw CommentException(
            '댓글 삭제 실패: ${response.statusCode}',
            CommentErrorType.unknown,
          );
      }
    } on SocketException {
      throw CommentException('네트워크 연결을 확인해주세요', CommentErrorType.network);
    } on HttpException {
      throw CommentException('HTTP 요청 오류가 발생했습니다', CommentErrorType.http);
    } on FormatException {
      throw CommentException('데이터 형식 오류가 발생했습니다', CommentErrorType.format);
    } catch (e) {
      debugPrint('CommentService.deleteComment 오류: $e');
      if (e is CommentException) rethrow;
      throw CommentException('예상치 못한 오류가 발생했습니다: $e', CommentErrorType.unknown);
    }
  }
}

/// 댓글 서비스 관련 오류를 나타내는 커스텀 예외 클래스입니다.
/// 특정 오류 메시지와 `CommentErrorType`을 포함합니다.
class CommentException implements Exception {
  final String message; // 사용자에게 표시할 오류 메시지
  final CommentErrorType type; // 오류의 구체적인 타입

  CommentException(this.message, this.type); // 생성자

  @override
  String toString() => 'CommentException: $message'; // 예외 객체를 문자열로 표현
}

/// 댓글 서비스에서 발생할 수 있는 오류의 종류를 정의하는 열거형(enum)입니다.
enum CommentErrorType {
  network, // 네트워크 연결 관련 오류
  serverError, // 서버 측 오류
  notFound, // 리소스를 찾을 수 없을 때 발생하는 오류
  unauthorized, // 인증되지 않은 요청 (로그인 필요)
  forbidden, // 권한이 없는 요청
  badRequest, // 잘못된 요청 (클라이언트 측 유효성 검사 실패 등)
  validation, // 입력 데이터 유효성 검사 실패
  format, // 응답 데이터 형식 오류
  http, // 기타 HTTP 요청 관련 오류
  unknown, // 알 수 없는/예상치 못한 오류
}
