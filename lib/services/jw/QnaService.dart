// QnaService.dart

import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:trekkit_flutter/models/jw/QnaQuestion.dart';
import 'package:trekkit_flutter/models/jw/QnaAnswer.dart';
import 'package:trekkit_flutter/services/jw/AuthService.dart';
import 'package:flutter/material.dart';

/// Q&A 관련 API 호출 서비스 클래스입니다.
class QnaService {
  /// AuthService에서 API 기본 URL을 가져옵니다.
  static String get _apiBaseUrl {
    return AuthService().API_URL;
  }

  /// 인증이 필요한 API 요청 헤더를 동적으로 생성합니다.
  static Map<String, String> _getAuthHeaders() {
    final String? token = AuthService().jwtToken;
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'X-Client-Type': 'mobile',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// HTTP 응답을 처리하고 `QnaException`을 던지는 헬퍼 함수입니다.
  static void _handleResponseError(http.Response response) {
    String errorMessage = '알 수 없는 오류가 발생했습니다.';
    QnaErrorType errorType = QnaErrorType.unknown;

    try {
      final Map<String, dynamic> errorBody = json.decode(
        utf8.decode(response.bodyBytes),
      );
      if (errorBody.containsKey('message')) {
        errorMessage = errorBody['message'];
      } else if (response.bodyBytes.isNotEmpty) {
        errorMessage = utf8.decode(response.bodyBytes);
      }
    } catch (e) {
      errorMessage =
          '응답 파싱 오류 또는 비어있는 응답: ${response.bodyBytes.isEmpty ? '빈 응답' : utf8.decode(response.bodyBytes)} (Status: ${response.statusCode})';
    }

    switch (response.statusCode) {
      case 400:
        errorType = QnaErrorType.badRequest;
        break;
      case 401:
        errorType = QnaErrorType.unauthorized;
        errorMessage =
            errorMessage.contains("JWT expired") ||
                    errorMessage.contains("token")
                ? "로그인 정보가 만료되었거나 유효하지 않습니다. 다시 로그인해주세요."
                : "인증되지 않은 요청입니다. 로그인해주세요.";
        break;
      case 403:
        errorType = QnaErrorType.forbidden;
        break;
      case 404:
        errorType = QnaErrorType.notFound;
        break;
      case 500:
      case 502:
      case 503:
        errorType = QnaErrorType.serverError;
        break;
      default:
        errorType = QnaErrorType.http;
        break;
    }
    throw QnaException(errorMessage, errorType);
  }

  /// Q&A 질문 목록을 조회합니다.
  static Future<Map<String, dynamic>> getQuestions({
    String sort = 'latest',
    String? mountain,
    int page = 0,
    int size = 10,
    required BuildContext context,
  }) async {
    /// context가 더 이상 마운트되지 않았다면 즉시 반환합니다.
    if (!context.mounted) return {};

    try {
      final response = await http
          .post(
            Uri.parse('$_apiBaseUrl/api/qna/questions-list'),
            headers: _getAuthHeaders(),
            body: json.encode({}),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        return {
          'questions': data.map((json) => QnaQuestion.fromJson(json)).toList(),
          'totalCount': data.length,
        };
      } else {
        _handleResponseError(response);
        return {};
      }
    } on SocketException {
      throw QnaException('네트워크 연결을 확인해주세요', QnaErrorType.network);
    } on TimeoutException {
      throw QnaException('요청 시간 초과', QnaErrorType.network);
    } catch (e) {
      debugPrint('QnaService.getQuestions 오류: $e');
      if (e is QnaException) rethrow;
      throw QnaException('질문 목록을 불러오는 데 실패했습니다: $e', QnaErrorType.unknown);
    }
  }

  /// 특정 질문의 상세 정보를 조회합니다.
  static Future<QnaQuestion?> getQuestionById(
    int id,
    BuildContext context,
  ) async {
    /// context가 더 이상 마운트되지 않았다면 즉시 반환합니다.
    if (!context.mounted) return null;

    try {
      final response = await http
          .post(
            Uri.parse('$_apiBaseUrl/api/qna/questions-detail/$id'),
            headers: _getAuthHeaders(),
            body: json.encode({}),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        return QnaQuestion.fromJson(data);
      } else if (response.statusCode == 404) {
        return null;
      } else {
        _handleResponseError(response);
        return null;
      }
    } on SocketException {
      throw QnaException('네트워크 연결을 확인해주세요', QnaErrorType.network);
    } on TimeoutException {
      throw QnaException('요청 시간 초과', QnaErrorType.network);
    } catch (e) {
      debugPrint('QnaService.getQuestionById 오류: $e');
      if (e is QnaException) rethrow;
      throw QnaException('질문 상세 정보를 불러오는 데 실패했습니다: $e', QnaErrorType.unknown);
    }
  }

  /// 새로운 Q&A 질문을 생성하여 서버에 전송합니다.
  static Future<void> createQuestion(
    QnaQuestion question,
    BuildContext context,
  ) async {
    /// context가 더 이상 마운트되지 않았다면 즉시 반환합니다.
    if (!context.mounted) return;

    try {
      final questionData = question.toJson();
      questionData.remove('id');
      questionData.remove('userId');
      questionData.remove('nickname');

      final response = await http
          .post(
            Uri.parse('$_apiBaseUrl/api/qna/questions'),
            headers: _getAuthHeaders(),
            body: json.encode(questionData),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 201) {
        return;
      } else {
        _handleResponseError(response);
      }
    } on SocketException {
      throw QnaException('네트워크 연결을 확인해주세요', QnaErrorType.network);
    } on TimeoutException {
      throw QnaException('요청 시간 초과', QnaErrorType.network);
    } catch (e) {
      debugPrint('QnaService.createQuestion 오류: $e');
      if (e is QnaException) rethrow;
      throw QnaException('질문 생성 실패: $e', QnaErrorType.unknown);
    }
  }

  /// 기존 Q&A 질문을 수정합니다.
  static Future<void> updateQuestion(
    QnaQuestion question,
    BuildContext context,
  ) async {
    /// context가 더 이상 마운트되지 않았다면 즉시 반환합니다.
    if (!context.mounted) return;

    final String? token = AuthService().jwtToken;
    if (token == null) {
      throw QnaException('로그인이 필요합니다.', QnaErrorType.unauthorized);
    }

    try {
      final response = await http
          .put(
            Uri.parse('$_apiBaseUrl/api/qna/questions/${question.id}'),
            headers: _getAuthHeaders(),
            body: json.encode(question.toJson()),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        _handleResponseError(response);
      }
    } on SocketException {
      throw QnaException('네트워크 연결을 확인해주세요', QnaErrorType.network);
    } on TimeoutException {
      throw QnaException('요청 시간 초과', QnaErrorType.network);
    } catch (e) {
      debugPrint('QnaService.updateQuestion 오류: $e');
      if (e is QnaException) rethrow;
      throw QnaException('질문 수정 실패: $e', QnaErrorType.unknown);
    }
  }

  /// 특정 Q&A 질문을 삭제합니다.
  static Future<void> deleteQuestion(int id, BuildContext context) async {
    /// context가 더 이상 마운트되지 않았다면 즉시 반환합니다.
    if (!context.mounted) return;

    final String? token = AuthService().jwtToken;
    if (token == null) {
      throw QnaException('로그인이 필요합니다.', QnaErrorType.unauthorized);
    }

    try {
      final response = await http
          .delete(
            Uri.parse('$_apiBaseUrl/api/qna/questions/$id'),
            headers: _getAuthHeaders(),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        _handleResponseError(response);
      }
    } on SocketException {
      throw QnaException('네트워크 연결을 확인해주세요', QnaErrorType.network);
    } on TimeoutException {
      throw QnaException('요청 시간 초과', QnaErrorType.network);
    } catch (e) {
      debugPrint('QnaService.deleteQuestion 오류: $e');
      if (e is QnaException) rethrow;
      throw QnaException('질문 삭제 실패: $e', QnaErrorType.unknown);
    }
  }

  /// 특정 질문에 대한 답변 목록을 조회합니다.
  static Future<List<QnaAnswer>> getAnswersByQuestionId(
    int questionId,
    BuildContext context,
  ) async {
    /// context가 더 이상 마운트되지 않았다면 즉시 반환합니다.
    if (!context.mounted) return [];

    try {
      final response = await http
          .post(
            Uri.parse('$_apiBaseUrl/api/qna/questions-answers/$questionId'),
            headers: _getAuthHeaders(),
            body: json.encode({}),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        return data.map((json) => QnaAnswer.fromJson(json)).toList();
      } else {
        _handleResponseError(response);
        return [];
      }
    } on SocketException {
      throw QnaException('네트워크 연결을 확인해주세요', QnaErrorType.network);
    } on TimeoutException {
      throw QnaException('요청 시간 초과', QnaErrorType.network);
    } catch (e) {
      debugPrint('QnaService.getAnswersByQuestionId 오류: $e');
      if (e is QnaException) rethrow;
      throw QnaException('답변 목록을 불러오는 데 실패했습니다: $e', QnaErrorType.unknown);
    }
  }

  /// 새로운 답변을 생성하여 서버에 전송합니다.
  static Future<void> createAnswer(
    QnaAnswer answer,
    BuildContext context,
  ) async {
    /// context가 더 이상 마운트되지 않았다면 즉시 반환합니다.
    if (!context.mounted) return;

    try {
      final answerData = answer.toJson();
      answerData.remove('id');
      answerData.remove('userId');
      answerData.remove('nickname');

      final response = await http
          .post(
            Uri.parse('$_apiBaseUrl/api/qna/answers'),
            headers: _getAuthHeaders(),
            body: json.encode(answerData),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 201) {
        return;
      } else {
        _handleResponseError(response);
      }
    } on SocketException {
      throw QnaException('네트워크 연결을 확인해주세요', QnaErrorType.network);
    } on TimeoutException {
      throw QnaException('요청 시간 초과', QnaErrorType.network);
    } catch (e) {
      debugPrint('QnaService.createAnswer 오류: $e');
      if (e is QnaException) rethrow;
      throw QnaException('답변 생성 실패: $e', QnaErrorType.unknown);
    }
  }

  /// 기존 답변을 수정합니다.
  static Future<void> updateAnswer(
    QnaAnswer answer,
    BuildContext context,
  ) async {
    /// context가 더 이상 마운트되지 않았다면 즉시 반환합니다.
    if (!context.mounted) return;

    final String? token = AuthService().jwtToken;
    if (token == null) {
      throw QnaException('로그인이 필요합니다.', QnaErrorType.unauthorized);
    }

    try {
      final response = await http
          .put(
            Uri.parse('$_apiBaseUrl/api/qna/answers/${answer.id}'),
            headers: _getAuthHeaders(),
            body: json.encode(answer.toJson()),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        _handleResponseError(response);
      }
    } on SocketException {
      throw QnaException('네트워크 연결을 확인해주세요', QnaErrorType.network);
    } on TimeoutException {
      throw QnaException('요청 시간 초과', QnaErrorType.network);
    } catch (e) {
      debugPrint('QnaService.updateAnswer 오류: $e');
      if (e is QnaException) rethrow;
      throw QnaException('답변 수정 실패: $e', QnaErrorType.unknown);
    }
  }

  /// 특정 Q&A 답변을 삭제합니다.
  static Future<void> deleteAnswer(
    int answerId,
    int questionId,
    BuildContext context,
  ) async {
    /// context가 더 이상 마운트되지 않았다면 즉시 반환합니다.
    if (!context.mounted) return;

    final String? token = AuthService().jwtToken;
    if (token == null) {
      throw QnaException('로그인이 필요합니다.', QnaErrorType.unauthorized);
    }

    try {
      final response = await http
          .delete(
            Uri.parse(
              '$_apiBaseUrl/api/qna/answers/$answerId/question/$questionId',
            ),
            headers: _getAuthHeaders(),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        _handleResponseError(response);
      }
    } on SocketException {
      throw QnaException('네트워크 연결을 확인해주세요', QnaErrorType.network);
    } on TimeoutException {
      throw QnaException('요청 시간 초과', QnaErrorType.network);
    } catch (e) {
      debugPrint('QnaService.deleteAnswer 오류: $e');
      if (e is QnaException) rethrow;
      throw QnaException('답변 삭제 실패: $e', QnaErrorType.unknown);
    }
  }

  /// 특정 질문에 대한 좋아요를 토글합니다.
  static Future<bool> toggleQuestionLike(
    int questionId,
    BuildContext context,
  ) async {
    /// context가 더 이상 마운트되지 않았다면 즉시 반환합니다.
    if (!context.mounted) return false;

    try {
      final response = await http
          .post(
            Uri.parse('$_apiBaseUrl/api/qna/questions/$questionId/like'),
            headers: _getAuthHeaders(),
            body: json.encode({}),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        return data as bool;
      } else {
        _handleResponseError(response);
        return false;
      }
    } on SocketException {
      throw QnaException('네트워크 연결을 확인해주세요', QnaErrorType.network);
    } on TimeoutException {
      throw QnaException('요청 시간 초과', QnaErrorType.network);
    } catch (e) {
      debugPrint('QnaService.toggleQuestionLike 오류: $e');
      if (e is QnaException) rethrow;
      throw QnaException('질문 좋아요 처리 실패: $e', QnaErrorType.unknown);
    }
  }

  /// 특정 답변에 대한 좋아요를 토글합니다.
  static Future<bool> toggleAnswerLike(
    int answerId,
    BuildContext context,
  ) async {
    /// context가 더 이상 마운트되지 않았다면 즉시 반환합니다.
    if (!context.mounted) return false;

    try {
      final response = await http
          .post(
            Uri.parse('$_apiBaseUrl/api/qna/answers/$answerId/like'),
            headers: _getAuthHeaders(),
            body: json.encode({}),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        return data as bool;
      } else {
        _handleResponseError(response);
        return false;
      }
    } on SocketException {
      throw QnaException('네트워크 연결을 확인해주세요', QnaErrorType.network);
    } on TimeoutException {
      throw QnaException('요청 시간 초과', QnaErrorType.network);
    } catch (e) {
      debugPrint('QnaService.toggleAnswerLike 오류: $e');
      if (e is QnaException) rethrow;
      throw QnaException('답변 좋아요 처리 실패: $e', QnaErrorType.unknown);
    }
  }
}

/// Q&A 서비스 관련 커스텀 예외 클래스입니다.
class QnaException implements Exception {
  final String message;
  final QnaErrorType type;

  QnaException(this.message, this.type);

  @override
  String toString() => 'QnaException: $message';
}

/// Q&A 서비스 오류 종류를 정의하는 열거형입니다.
enum QnaErrorType {
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
