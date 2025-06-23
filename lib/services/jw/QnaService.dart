import 'dart:convert';
import 'dart:io';
import 'dart:async'; // TimeoutException 사용을 위해 추가
import 'package:http/http.dart' as http;
import 'package:trekkit_flutter/models/jw/QnaQuestion.dart';
import 'package:trekkit_flutter/models/jw/QnaAnswer.dart'; // QnaAnswer 모델 임포트
import 'package:trekkit_flutter/services/jw/AuthService.dart'; // AuthService 임포트
import 'package:flutter/material.dart'; // BuildContext 사용을 위해 추가

class QnaService {
  static const String baseUrl = 'http://10.0.2.2:30000/api/qna';

  // JWT 토큰을 포함하는 동적 헤더
  static Map<String, String> _getAuthHeaders(BuildContext context) {
    final String? token = AuthService().jwtToken;
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'X-Client-Type': 'mobile',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // 기본 헤더 (인증 불필요한 요청용, X-Client-Type 포함)
  static const Map<String, String> _baseHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'X-Client-Type': 'mobile',
  };

  /// 질문 목록 조회 (백엔드가 @PostMapping("/questions-list") 이므로 POST로 변경)
  static Future<Map<String, dynamic>> getQuestions({
    String sort = 'latest',
    String? mountain,
    int page = 0,
    int size = 10,
    required BuildContext context, // 인증 헤더를 위해 context 추가
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/questions-list'), // POST 메서드 사용
            headers: _getAuthHeaders(context), // 인증 헤더 포함 (간접적으로 userId 추출 등)
            body: json.encode(
              {},
            ), // @RequestBody(required = false) Map<String, Object> reqBody에 빈 Map 전달
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        return {
          'questions': data.map((json) => QnaQuestion.fromJson(json)).toList(),
          'totalCount': data.length, // 백엔드가 totalCount를 안주므로 목록 길이로 대체
        };
      } else {
        String errorMessage = '질문 목록 불러오기 실패: ${response.statusCode}';
        try {
          final errorBody = utf8.decode(response.bodyBytes);
          final errorData = json.decode(errorBody);
          if (errorData is String) {
            errorMessage = errorData;
          } else if (errorData is Map && errorData.containsKey('message')) {
            // containsKey 안전하게 호출
            errorMessage = errorData['message'];
          }
        } catch (_) {}
        throw Exception(errorMessage);
      }
    } on SocketException {
      throw Exception('네트워크 오류');
    } on TimeoutException {
      throw Exception('요청 시간 초과');
    } catch (e) {
      print('QnaService.getQuestions 오류: $e');
      throw Exception('질문 목록을 불러오는 데 실패했습니다: $e');
    }
  }

  /// 질문 상세 조회 (백엔드가 @PostMapping("/questions-detail/{id}") 이므로 POST로 변경)
  static Future<QnaQuestion?> getQuestion(int id, BuildContext context) async {
    // context 인자 추가
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/questions-detail/$id'), // POST 메서드 사용
            headers: _getAuthHeaders(context), // 인증 헤더 포함
            body: json.encode(
              {},
            ), // @RequestBody(required = false) Map<String, Object> reqBody에 빈 Map 전달
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        return QnaQuestion.fromJson(data);
      } else if (response.statusCode == 404) {
        return null;
      } else {
        String errorMessage = '질문 상세 조회 실패: ${response.statusCode}';
        try {
          final errorBody = utf8.decode(response.bodyBytes);
          final errorData = json.decode(errorBody);
          if (errorData is String) {
            errorMessage = errorData;
          } else if (errorData is Map && errorData.containsKey('message')) {
            // containsKey 안전하게 호출
            errorMessage = errorData['message'];
          }
        } catch (_) {}
        throw Exception(errorMessage);
      }
    } on SocketException {
      throw Exception('네트워크 오류');
    } on TimeoutException {
      throw Exception('요청 시간 초과');
    } catch (e) {
      print('QnaService.getQuestion 오류: $e');
      throw Exception('질문 상세 정보를 불러오는 데 실패했습니다: $e');
    }
  }

  /// 새 질문 생성 (백엔드 @PostMapping("/questions") 적절)
  static Future<void> createQuestion(
    QnaQuestion question,
    BuildContext context,
  ) async {
    // context 인자 추가
    try {
      final questionData = question.toJson();
      questionData.remove('id'); // ID는 서버에서 생성
      questionData.remove(
        'userId',
      ); // 백엔드 QnaController는 getUserIdFromRequest(request)로 userId를 추출
      questionData.remove(
        'nickname',
      ); // 백엔드 QnaQuestionDTO에 nickname 필드가 없으므로 제거

      final response = await http
          .post(
            Uri.parse('$baseUrl/questions'),
            headers: _getAuthHeaders(context), // 인증 헤더 포함
            body: json.encode(questionData),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 201) {
        // HttpStatus.CREATED
        return; // 성공
      } else {
        String errorMessage = '질문 생성 실패: ${response.statusCode}';
        try {
          final errorBody = utf8.decode(response.bodyBytes);
          final errorData = json.decode(errorBody);
          if (errorData is String) {
            errorMessage = errorData;
          } else if (errorData is Map && errorData.containsKey('message')) {
            // containsKey 안전하게 호출
            errorMessage = errorData['message'];
          }
        } catch (_) {}
        throw Exception(errorMessage);
      }
    } on SocketException {
      throw Exception('네트워크 연결을 확인해주세요');
    } on TimeoutException {
      throw Exception('요청 시간 초과');
    } catch (e) {
      print('QnaService.createQuestion 오류: $e');
      throw Exception('질문 생성 실패: $e');
    }
  }

  /// 답변 목록 조회 (백엔드가 @PostMapping("/questions-answers/{questionId}") 이므로 POST로 변경)
  static Future<List<QnaAnswer>> getAnswersByQuestionId(
    int questionId,
    BuildContext context,
  ) async {
    // context 인자 추가
    try {
      final response = await http
          .post(
            // POST 메서드 사용
            Uri.parse('$baseUrl/questions-answers/$questionId'),
            headers: _getAuthHeaders(context), // 인증 헤더 포함
            body: json.encode(
              {},
            ), // @RequestBody(required = false) Map<String, Object> reqBody에 빈 Map 전달
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        return data.map((json) => QnaAnswer.fromJson(json)).toList();
      } else {
        String errorMessage = '답변 목록 조회 실패: ${response.statusCode}';
        try {
          final errorBody = utf8.decode(response.bodyBytes);
          final errorData = json.decode(errorBody);
          if (errorData is String) {
            errorMessage = errorData;
          } else if (errorData is Map && errorData.containsKey('message')) {
            // containsKey 안전하게 호출
            errorMessage = errorData['message'];
          }
        } catch (_) {}
        throw Exception(errorMessage);
      }
    } on SocketException {
      throw Exception('네트워크 오류');
    } on TimeoutException {
      throw Exception('요청 시간 초과');
    } catch (e) {
      print('QnaService.getAnswersByQuestionId 오류: $e');
      throw Exception('답변 목록을 불러오는 데 실패했습니다: $e');
    }
  }

  /// 답변 생성 (백엔드 @PostMapping("/answers") 적절)
  static Future<void> createAnswer(
    QnaAnswer answer,
    BuildContext context,
  ) async {
    // context 인자 추가
    try {
      final answerData = answer.toJson();
      answerData.remove('id'); // ID는 서버에서 생성
      answerData.remove('userId'); // 백엔드 QnaController는 userId를 JWT에서 추출
      answerData.remove('nickname'); // 백엔드 QnaAnswerDTO에 nickname 필드가 없으므로 제거

      final response = await http
          .post(
            Uri.parse('$baseUrl/answers'),
            headers: _getAuthHeaders(context), // 인증 헤더 포함
            body: json.encode(answerData),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 201) {
        // HttpStatus.CREATED
        return; // 성공
      } else {
        String errorMessage = '답변 생성 실패: ${response.statusCode}';
        try {
          final errorBody = utf8.decode(response.bodyBytes);
          final errorData = json.decode(errorBody);
          if (errorData is String) {
            errorMessage = errorData;
          } else if (errorData is Map && errorData.containsKey('message')) {
            // containsKey 안전하게 호출
            errorMessage = errorData['message'];
          }
        } catch (_) {}
        throw Exception(errorMessage);
      }
    } on SocketException {
      throw Exception('네트워크 연결을 확인해주세요');
    } on TimeoutException {
      throw Exception('요청 시간 초과');
    } catch (e) {
      print('QnaService.createAnswer 오류: $e');
      throw Exception('답변 생성 실패: $e');
    }
  }

  /// 질문 좋아요 토글 (백엔드 @PostMapping("/questions/{questionId}/like") 적절)
  static Future<bool> toggleQuestionLike(
    int questionId,
    BuildContext context,
  ) async {
    // context 인자 추가
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/questions/$questionId/like'),
            headers: _getAuthHeaders(context), // 인증 헤더 포함
            body: json.encode(
              {},
            ), // 백엔드가 @RequestBody(required = false) Map<String, Object> reqBody를 받으므로 빈 Map 전달
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        return data as bool; // 백엔드는 ResponseEntity<Boolean>을 반환
      } else {
        String errorMessage = '질문 좋아요 처리 실패: ${response.statusCode}';
        try {
          final errorBody = utf8.decode(response.bodyBytes);
          final errorData = json.decode(errorBody);
          if (errorData is String) {
            errorMessage = errorData;
          } else if (errorData is Map && errorData.containsKey('message')) {
            // containsKey 안전하게 호출
            errorMessage = errorData['message'];
          }
        } catch (_) {}
        throw Exception(errorMessage);
      }
    } on SocketException {
      throw Exception('네트워크 연결을 확인해주세요');
    } on TimeoutException {
      throw Exception('요청 시간 초과');
    } catch (e) {
      print('QnaService.toggleQuestionLike 오류: $e');
      throw Exception('질문 좋아요 처리 실패: $e');
    }
  }

  /// 답변 좋아요 토글 (백엔드 @PostMapping("/answers/{answerId}/like") 적절)
  static Future<bool> toggleAnswerLike(
    int answerId,
    BuildContext context,
  ) async {
    // context 인자 추가
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/answers/$answerId/like'),
            headers: _getAuthHeaders(context), // 인증 헤더 포함
            body: json.encode(
              {},
            ), // 백엔드가 @RequestBody(required = false) Map<String, Object> reqBody를 받으므로 빈 Map 전달
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        return data as bool; // 백엔드는 ResponseEntity<Boolean>을 반환
      } else {
        String errorMessage = '답변 좋아요 처리 실패: ${response.statusCode}';
        try {
          final errorBody = utf8.decode(response.bodyBytes);
          final errorData = json.decode(errorBody);
          if (errorData is String) {
            errorMessage = errorData;
          } else if (errorData is Map && errorData.containsKey('message')) {
            // containsKey 안전하게 호출
            errorMessage = errorData['message'];
          }
        } catch (_) {}
        throw Exception(errorMessage);
      }
    } on SocketException {
      throw Exception('네트워크 오류');
    } on TimeoutException {
      throw Exception('요청 시간 초과');
    } catch (e) {
      print('QnaService.toggleAnswerLike 오류: $e');
      throw Exception('답변 좋아요 처리 실패: $e');
    }
  }

  // TODO: 질문 및 답변 수정/삭제, 채택 API 추가 (필요 시)
}

// QnaService에서 사용될 예외 클래스
class QnaException implements Exception {
  final String message;
  final QnaErrorType type;

  QnaException(this.message, this.type);

  @override
  String toString() => 'QnaException: $message';
}

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
