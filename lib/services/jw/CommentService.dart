import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:trekkit_flutter/models/jw/Comment.dart';

class CommentService {
  static const String baseUrl = 'http://10.0.2.2:30000/api/comments';

  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  /// 특정 게시글의 댓글 목록 조회 (개선된 에러 처리)
  static Future<List<Comment>> getCommentsByPostId(int postId) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/post/$postId'), headers: headers)
          .timeout(const Duration(seconds: 10));

      // HTTP 상태 코드별 세분화된 에러 처리
      switch (response.statusCode) {
        case 200:
          final List<dynamic> data = json.decode(
            utf8.decode(response.bodyBytes),
          );
          return data.map((json) => Comment.fromJson(json)).toList();

        case 404:
          throw CommentException('게시글을 찾을 수 없습니다', CommentErrorType.notFound);

        case 500:
          throw CommentException('서버 오류가 발생했습니다', CommentErrorType.serverError);

        case 403:
          throw CommentException('접근 권한이 없습니다', CommentErrorType.forbidden);

        default:
          throw CommentException(
            '댓글 조회 실패: ${response.statusCode}',
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
      print('CommentService.getCommentsByPostId 오류: $e');
      if (e is CommentException) rethrow;
      throw CommentException('예상치 못한 오류가 발생했습니다: $e', CommentErrorType.unknown);
    }
  }

  /// 새 댓글 작성 (개선된 에러 처리 및 입력 검증)
  static Future<Comment> createComment(Comment comment) async {
    try {
      // 입력 검증
      if (comment.content.trim().isEmpty) {
        throw CommentException('댓글 내용을 입력해주세요', CommentErrorType.validation);
      }

      if (comment.content.length > 200) {
        throw CommentException(
          '댓글은 200자를 초과할 수 없습니다',
          CommentErrorType.validation,
        );
      }

      final commentData = comment.toJson();
      commentData.remove('id'); // ID는 서버에서 생성

      final response = await http
          .post(
            Uri.parse(baseUrl),
            headers: headers,
            body: json.encode(commentData),
          )
          .timeout(const Duration(seconds: 15));

      switch (response.statusCode) {
        case 200:
        case 201:
          final data = json.decode(utf8.decode(response.bodyBytes));
          return Comment.fromJson(data);

        case 400:
          throw CommentException('잘못된 요청입니다', CommentErrorType.badRequest);

        case 401:
          throw CommentException('로그인이 필요합니다', CommentErrorType.unauthorized);

        case 403:
          throw CommentException('댓글 작성 권한이 없습니다', CommentErrorType.forbidden);

        case 500:
          throw CommentException(
            '서버 오류로 댓글 작성에 실패했습니다',
            CommentErrorType.serverError,
          );

        default:
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
      print('CommentService.createComment 오류: $e');
      if (e is CommentException) rethrow;
      throw CommentException('예상치 못한 오류가 발생했습니다: $e', CommentErrorType.unknown);
    }
  }

  /// 댓글 수정 (개선된 에러 처리)
  static Future<Comment> updateComment(Comment comment) async {
    try {
      // 입력 검증
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
            Uri.parse('$baseUrl/${comment.id}'),
            headers: headers,
            body: json.encode(comment.toJson()),
          )
          .timeout(const Duration(seconds: 15));

      switch (response.statusCode) {
        case 200:
          final data = json.decode(utf8.decode(response.bodyBytes));
          return Comment.fromJson(data);

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
      print('CommentService.updateComment 오류: $e');
      if (e is CommentException) rethrow;
      throw CommentException('예상치 못한 오류가 발생했습니다: $e', CommentErrorType.unknown);
    }
  }

  /// 댓글 삭제 (개선된 에러 처리)
  static Future<bool> deleteComment(int commentId, int postId) async {
    try {
      final response = await http
          .delete(
            Uri.parse('$baseUrl/$commentId/post/$postId'),
            headers: headers,
          )
          .timeout(const Duration(seconds: 10));

      switch (response.statusCode) {
        case 200:
          final data = json.decode(utf8.decode(response.bodyBytes));
          return data['success'] ?? false;

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
      print('CommentService.deleteComment 오류: $e');
      if (e is CommentException) rethrow;
      throw CommentException('예상치 못한 오류가 발생했습니다: $e', CommentErrorType.unknown);
    }
  }
}

// 커스텀 예외 클래스
class CommentException implements Exception {
  final String message;
  final CommentErrorType type;

  CommentException(this.message, this.type);

  @override
  String toString() => 'CommentException: $message';
}

// 에러 타입 열거형
enum CommentErrorType {
  network, // 네트워크 오류
  serverError, // 서버 오류 (500)
  notFound, // 리소스 없음 (404)
  unauthorized, // 인증 필요 (401)
  forbidden, // 권한 없음 (403)
  badRequest, // 잘못된 요청 (400)
  validation, // 입력 검증 오류
  format, // 데이터 형식 오류
  http, // HTTP 관련 오류
  unknown, // 알 수 없는 오류
}
