// lib/services/jw/CommentService.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:trekkit_flutter/models/jw/Comment.dart';
import 'package:trekkit_flutter/services/jw/AuthService.dart'; // AuthService 임포트
import 'package:flutter/material.dart'; // BuildContext 사용을 위해 추가

class CommentService {
  static const String baseUrl = 'http://10.0.2.2:30000/api/comments';

  // JWT 토큰을 포함하는 동적 헤더
  static Map<String, String> _getAuthHeaders(BuildContext context) {
    // context 인자 추가
    final String? token = AuthService().jwtToken; // AuthService에서 JWT 토큰 가져오기
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'X-Client-Type': 'mobile', // 또는 'app' (PostService와 일관성 유지)
      if (token != null)
        'Authorization': 'Bearer $token', // 토큰이 있을 경우 Authorization 헤더 추가
    };
  }

  // 기본 헤더 (인증 불필요한 요청용, X-Client-Type 포함)
  static const Map<String, String> _baseHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'X-Client-Type': 'mobile', // 일반 조회 시에도 클라이언트 타입 필요
  };

  /// 특정 게시글의 댓글 목록 조회 (인증 불필요)
  // 이 메서드는 _baseHeaders를 사용하므로 context를 받지 않습니다.
  static Future<List<Comment>> getCommentsByPostId(int postId) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/post/$postId'), headers: _baseHeaders)
          .timeout(const Duration(seconds: 10));

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

  /// 새 댓글 작성
  static Future<Comment> createComment(
    Comment comment,
    BuildContext context,
  ) async {
    // context 인자 추가
    try {
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
      commentData.remove('id');

      final response = await http
          .post(
            Uri.parse(baseUrl),
            headers: _getAuthHeaders(context), // context 전달
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

  /// 댓글 수정
  static Future<Comment> updateComment(
    Comment comment,
    BuildContext context,
  ) async {
    // context 인자 추가
    try {
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
            headers: _getAuthHeaders(context), // context 전달
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

  /// 댓글 삭제
  static Future<bool> deleteComment(
    int commentId,
    int postId,
    BuildContext context,
  ) async {
    // context 인자 추가
    try {
      final response = await http
          .delete(
            Uri.parse('$baseUrl/$commentId/post/$postId'),
            headers: _getAuthHeaders(context), // context 전달
          )
          .timeout(const Duration(seconds: 10));

      switch (response.statusCode) {
        case 200:
          return true;

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
  network,
  serverError,
  notFound,
  unauthorized,
  forbidden,
  badRequest,
  validation,
  format,
  http,
  unknown,
}
