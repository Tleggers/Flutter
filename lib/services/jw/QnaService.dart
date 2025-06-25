// QnaService.dart

import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:trekkit_flutter/models/jw/QnaQuestion.dart';
import 'package:trekkit_flutter/models/jw/QnaAnswer.dart';
import 'package:trekkit_flutter/services/jw/AuthService.dart';
import 'package:flutter/material.dart';

/// Q&A(질문과 답변) 관련 API 호출을 담당하는 서비스 클래스입니다.
/// 백엔드와의 통신을 처리하며, 인증 헤더를 자동으로 포함하고 다양한 오류를 처리합니다.
class QnaService {
  // 백엔드 Q&A API의 기본 URL (안드로이드 에뮬레이터에서 로컬 호스트 접근)
  static const String baseUrl = 'http://10.0.2.2:30000/api/qna';

  /// JWT 토큰을 포함하는 HTTP 요청 헤더를 동적으로 생성합니다.
  /// 이 헤더는 인증이 필요한 API 요청에 사용됩니다.
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
  /// 다양한 HTTP 상태 코드에 따라 적절한 오류 유형과 메시지를 생성합니다.
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
  /// 백엔드 API와의 호환성을 위해 POST 메서드를 사용하며, 필터링 및 페이지네이션을 지원합니다.
  static Future<Map<String, dynamic>> getQuestions({
    String sort = 'latest',
    String? mountain,
    int page = 0,
    int size = 10,
    required BuildContext context,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/questions-list'),
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
  /// 백엔드 API와의 호환성을 위해 POST 메서드를 사용합니다.
  static Future<QnaQuestion?> getQuestionById(
    int id,
    BuildContext context,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/questions-detail/$id'),
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
    try {
      final questionData = question.toJson();
      // ID, userId, nickname 필드는 서버에서 처리하거나 JWT에서 추출하므로 제거
      questionData.remove('id');
      questionData.remove('userId');
      questionData.remove('nickname');

      final response = await http
          .post(
            Uri.parse('$baseUrl/questions'),
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
  /// 백엔드 API는 `PUT /api/qna/questions/{id}` 형태로 구현되어 있습니다.
  static Future<void> updateQuestion(
    QnaQuestion question,
    BuildContext context,
  ) async {
    final String? token = AuthService().jwtToken;
    if (token == null) {
      throw QnaException('로그인이 필요합니다.', QnaErrorType.unauthorized);
    }

    try {
      final response = await http
          .put(
            Uri.parse('$baseUrl/questions/${question.id}'),
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
  /// 백엔드 API는 `DELETE /api/qna/questions/{id}` 형태로 구현되어 있습니다.
  static Future<void> deleteQuestion(int id, BuildContext context) async {
    final String? token = AuthService().jwtToken;
    if (token == null) {
      throw QnaException('로그인이 필요합니다.', QnaErrorType.unauthorized);
    }

    try {
      final response = await http
          .delete(
            Uri.parse('$baseUrl/questions/$id'),
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

  /// 특정 질문([questionId])에 대한 답변 목록을 조회합니다.
  static Future<List<QnaAnswer>> getAnswersByQuestionId(
    int questionId,
    BuildContext context,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/questions-answers/$questionId'),
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
    try {
      final answerData = answer.toJson();
      // ID, userId, nickname 필드는 서버에서 처리하거나 JWT에서 추출하므로 제거
      answerData.remove('id');
      answerData.remove('userId');
      answerData.remove('nickname');

      final response = await http
          .post(
            Uri.parse('$baseUrl/answers'),
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
  /// 백엔드 API는 `PUT /api/qna/answers/{id}` 형태로 구현되어 있습니다.
  static Future<void> updateAnswer(
    QnaAnswer answer,
    BuildContext context,
  ) async {
    final String? token = AuthService().jwtToken;
    if (token == null) {
      throw QnaException('로그인이 필요합니다.', QnaErrorType.unauthorized);
    }

    try {
      final response = await http
          .put(
            Uri.parse('$baseUrl/answers/${answer.id}'),
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
  /// 백엔드 API는 `DELETE /api/qna/answers/{id}/question/{questionId}` 형태로 구현되어 있습니다.
  static Future<void> deleteAnswer(
    int answerId,
    int questionId,
    BuildContext context,
  ) async {
    final String? token = AuthService().jwtToken;
    if (token == null) {
      throw QnaException('로그인이 필요합니다.', QnaErrorType.unauthorized);
    }

    try {
      final response = await http
          .delete(
            Uri.parse('$baseUrl/answers/$answerId/question/$questionId'),
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

  /// 특정 질문에 대한 좋아요를 토글(추가/취소)합니다.
  static Future<bool> toggleQuestionLike(
    int questionId,
    BuildContext context,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/questions/$questionId/like'),
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

  /// 특정 답변에 대한 좋아요를 토글(추가/취소)합니다.
  static Future<bool> toggleAnswerLike(
    int answerId,
    BuildContext context,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/answers/$answerId/like'),
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

/// Q&A 서비스 관련 오류를 나타내는 커스텀 예외 클래스입니다.
class QnaException implements Exception {
  final String message;
  final QnaErrorType type;

  QnaException(this.message, this.type);

  @override
  String toString() => 'QnaException: $message';
}

/// Q&A 서비스에서 발생할 수 있는 오류의 종류를 정의하는 열거형(enum)입니다.
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
