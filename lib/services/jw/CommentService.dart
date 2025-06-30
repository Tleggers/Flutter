// lib/services/jw/CommentService.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:trekkit_flutter/models/jw/Comment.dart';
import 'package:trekkit_flutter/services/jw/AuthService.dart';
import 'package:flutter/material.dart';

/// 댓글 관련 API 호출 서비스 클래스입니다.
class CommentService {
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

  /// 특정 게시글의 댓글 목록을 조회합니다.
  static Future<List<Comment>> getCommentsByPostId(int postId) async {
    try {
      final response = await http
          .get(
            Uri.parse('$_apiBaseUrl/api/comments/post/$postId'),
            headers: _baseHeaders,
          )
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
      debugPrint('CommentService.getCommentsByPostId 오류: $e');
      if (e is CommentException) rethrow;
      throw CommentException('예상치 못한 오류가 발생했습니다: $e', CommentErrorType.unknown);
    }
  }

  /// 새 댓글을 작성하여 서버에 전송합니다.
  static Future<Comment> createComment(
    Comment comment,
    BuildContext context,
  ) async {
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
            Uri.parse('$_apiBaseUrl/api/comments'),
            headers: _getAuthHeaders(context),
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
      debugPrint('CommentService.createComment 오류: $e');
      if (e is CommentException) rethrow;
      throw CommentException('예상치 못한 오류가 발생했습니다: $e', CommentErrorType.unknown);
    }
  }

  /// 기존 댓글을 수정합니다.
  static Future<Comment> updateComment(
    Comment comment,
    BuildContext context,
  ) async {
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
            Uri.parse('$_apiBaseUrl/api/comments/${comment.id}'),
            headers: _getAuthHeaders(context),
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
      debugPrint('CommentService.updateComment 오류: $e');
      if (e is CommentException) rethrow;
      throw CommentException('예상치 못한 오류가 발생했습니다: $e', CommentErrorType.unknown);
    }
  }

  /// 특정 댓글을 삭제합니다.
  static Future<bool> deleteComment(
    int commentId,
    int postId,
    BuildContext context,
  ) async {
    try {
      final response = await http
          .delete(
            Uri.parse('$_apiBaseUrl/api/comments/$commentId/post/$postId'),
            headers: _getAuthHeaders(context),
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
      debugPrint('CommentService.deleteComment 오류: $e');
      if (e is CommentException) rethrow;
      throw CommentException('예상치 못한 오류가 발생했습니다: $e', CommentErrorType.unknown);
    }
  }
}

/// 댓글 서비스 관련 커스텀 예외 클래스입니다.
class CommentException implements Exception {
  final String message;
  final CommentErrorType type;

  CommentException(this.message, this.type);

  @override
  String toString() => 'CommentException: $message';
}

/// 댓글 서비스 오류 종류를 정의하는 열거형입니다.
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
