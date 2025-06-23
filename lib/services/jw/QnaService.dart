import 'dart:convert'; // JSON 데이터 인코딩 및 디코딩을 위한 패키지
import 'dart:io'; // SocketException (네트워크 오류) 처리를 위한 패키지
import 'dart:async'; // TimeoutException 사용을 위해 추가
import 'package:http/http.dart' as http; // HTTP 통신을 위한 패키지
import 'package:trekkit_flutter/models/jw/QnaQuestion.dart'; // QnaQuestion 모델 클래스 임포트
import 'package:trekkit_flutter/models/jw/QnaAnswer.dart'; // QnaAnswer 모델 클래스 임포트
import 'package:trekkit_flutter/services/jw/AuthService.dart'; // JWT 토큰 접근을 위한 AuthService 임포트
import 'package:flutter/material.dart'; // BuildContext 사용을 위한 Flutter Material 패키지 임포트

/// Q&A(질문과 답변) 관련 API 호출을 담당하는 서비스 클래스입니다.
/// 백엔드와의 통신을 처리하며, 인증 헤더를 자동으로 포함하고 다양한 오류를 처리합니다.
class QnaService {
  // 백엔드 Q&A API의 기본 URL
  static const String baseUrl = 'http://10.0.2.2:30000/api/qna';

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
  /// `X-Client-Type`만 포함합니다.
  static const Map<String, String> _baseHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'X-Client-Type': 'mobile', // 일반 조회 시에도 클라이언트 타입 포함
  };

  /// Q&A 질문 목록을 조회합니다.
  /// 백엔드 API가 `POST /api/qna/questions-list` 형태로 구현되어 있어 `POST` 메서드를 사용합니다.
  ///
  /// [sort] : 질문 정렬 기준 (예: 'latest', 'popular', 'answered'). 기본값은 'latest'입니다.
  /// [mountain] : 특정 산으로 필터링할 경우의 산 이름. 선택 사항입니다.
  /// [page] : 조회할 페이지 번호 (0부터 시작). 기본값은 0입니다.
  /// [size] : 한 페이지당 질문 개수. 기본값은 10입니다.
  /// [context] : 인증 헤더 생성을 위해 필요한 BuildContext.
  /// 반환값: `questions` (QnaQuestion 객체 리스트)와 `totalCount` (전체 질문 수)를 포함하는 Map.
  /// 예외: 네트워크 오류, 서버 오류 등 `QnaException` 발생 가능.
  static Future<Map<String, dynamic>> getQuestions({
    String sort = 'latest',
    String? mountain,
    int page = 0,
    int size = 10,
    required BuildContext context, // 인증 헤더를 위해 context 필요
  }) async {
    try {
      // 백엔드가 @RequestBody(required = false) Map<String, Object> reqBody를 받으므로 빈 Map을 전달
      final response = await http
          .post(
            Uri.parse('$baseUrl/questions-list'), // POST 메서드 사용 및 질문 목록 API URL
            headers: _getAuthHeaders(context), // 인증 헤더 포함
            body: json.encode({}), // 요청 본문에 빈 JSON 객체 전달
          )
          .timeout(const Duration(seconds: 10)); // 10초 타임아웃 설정

      if (response.statusCode == 200) {
        // 성공 (OK) 시 응답 본문을 UTF-8로 디코딩 후 JSON 파싱
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        return {
          'questions':
              data // 파싱된 JSON 데이터를 QnaQuestion 객체 리스트로 변환
                  .map((json) => QnaQuestion.fromJson(json))
                  .toList(),
          'totalCount':
              data.length, // 백엔드에서 totalCount를 명시적으로 주지 않으므로 목록 길이로 대체
        };
      } else {
        // 성공 외의 상태 코드일 경우 에러 메시지 파싱 시도 후 예외 발생
        String errorMessage = '질문 목록 불러오기 실패: ${response.statusCode}';
        try {
          final errorBody = utf8.decode(response.bodyBytes);
          final errorData = json.decode(errorBody);
          if (errorData is String) {
            errorMessage = errorData;
          } else if (errorData is Map && errorData.containsKey('message')) {
            errorMessage = errorData['message']; // 'message' 키의 에러 메시지 사용
          }
        } catch (_) {} // JSON 파싱 실패 시 기본 메시지 사용
        throw QnaException(errorMessage, QnaErrorType.serverError); // 서버 오류로 분류
      }
    } on SocketException {
      // 네트워크 연결 오류 처리
      throw QnaException('네트워크 연결을 확인해주세요', QnaErrorType.network);
    } on TimeoutException {
      // 요청 시간 초과 오류 처리
      throw QnaException('요청 시간 초과', QnaErrorType.network);
    } catch (e) {
      // 예상치 못한 기타 오류 처리
      debugPrint('QnaService.getQuestions 오류: $e'); // 디버그 콘솔에 오류 출력
      if (e is QnaException) rethrow; // 이미 QnaException이면 다시 던짐
      throw QnaException('질문 목록을 불러오는 데 실패했습니다: $e', QnaErrorType.unknown);
    }
  }

  /// 특정 질문의 상세 정보를 조회합니다.
  /// 백엔드 API가 `POST /api/qna/questions-detail/{id}` 형태로 구현되어 있어 `POST` 메서드를 사용합니다.
  ///
  /// [id] : 조회할 질문의 고유 ID.
  /// [context] : 인증 헤더 생성을 위해 필요한 BuildContext.
  /// 반환값: 조회된 `QnaQuestion` 객체. 질문을 찾을 수 없으면 `null` 반환.
  /// 예외: 네트워크 오류, 서버 오류 등 `QnaException` 발생 가능.
  static Future<QnaQuestion?> getQuestion(int id, BuildContext context) async {
    try {
      final response = await http
          .post(
            Uri.parse(
              '$baseUrl/questions-detail/$id',
            ), // POST 메서드 사용 및 질문 상세 API URL
            headers: _getAuthHeaders(context), // 인증 헤더 포함
            body: json.encode({}), // 요청 본문에 빈 JSON 객체 전달
          )
          .timeout(const Duration(seconds: 10)); // 10초 타임아웃 설정

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        return QnaQuestion.fromJson(data); // QnaQuestion 객체로 변환하여 반환
      } else if (response.statusCode == 404) {
        return null; // 질문을 찾을 수 없으면 null 반환
      } else {
        // 성공 외의 상태 코드일 경우 에러 메시지 파싱 시도 후 예외 발생
        String errorMessage = '질문 상세 조회 실패: ${response.statusCode}';
        try {
          final errorBody = utf8.decode(response.bodyBytes);
          final errorData = json.decode(errorBody);
          if (errorData is String) {
            errorMessage = errorData;
          } else if (errorData is Map && errorData.containsKey('message')) {
            errorMessage = errorData['message'];
          }
        } catch (_) {}
        throw QnaException(errorMessage, QnaErrorType.serverError);
      }
    } on SocketException {
      throw QnaException('네트워크 연결을 확인해주세요', QnaErrorType.network);
    } on TimeoutException {
      throw QnaException('요청 시간 초과', QnaErrorType.network);
    } catch (e) {
      debugPrint('QnaService.getQuestion 오류: $e');
      if (e is QnaException) rethrow;
      throw QnaException('질문 상세 정보를 불러오는 데 실패했습니다: $e', QnaErrorType.unknown);
    }
  }

  /// 새로운 Q&A 질문을 생성하여 서버에 전송합니다.
  /// 백엔드 API는 `POST /api/qna/questions` 형태로 구현되어 있습니다.
  ///
  /// [question] : 작성할 `QnaQuestion` 객체 (ID, userId, nickname은 서버에서 처리).
  /// [context] : 인증 헤더 생성을 위해 필요한 BuildContext.
  /// 반환값: 없음 (성공 시 `void`).
  /// 예외: 네트워크 오류, 유효성 검사 실패, 인증 오류 등 `QnaException` 발생 가능.
  static Future<void> createQuestion(
    QnaQuestion question,
    BuildContext context, // 인증 헤더를 위해 context 필요
  ) async {
    try {
      final questionData = question.toJson();
      questionData.remove('id'); // ID는 서버에서 자동 생성되므로 제거
      // 백엔드 QnaController는 userId를 JWT에서 추출하므로 제거
      questionData.remove('userId');
      // 백엔드 QnaQuestionDTO에 nickname 필드가 없으므로 제거 (서버가 사용자 정보로 닉네임 가져옴)
      questionData.remove('nickname');

      final response = await http
          .post(
            Uri.parse('$baseUrl/questions'), // 질문 생성 API URL
            headers: _getAuthHeaders(context), // 인증 헤더 포함
            body: json.encode(questionData), // JSON으로 인코딩된 질문 데이터
          )
          .timeout(const Duration(seconds: 15)); // 15초 타임아웃 설정

      if (response.statusCode == 201) {
        // 성공 (Created)
        return; // 성공 시 아무것도 반환하지 않음
      } else {
        // 성공 외의 상태 코드일 경우 에러 메시지 파싱 시도 후 예외 발생
        String errorMessage = '질문 생성 실패: ${response.statusCode}';
        try {
          final errorBody = utf8.decode(response.bodyBytes);
          final errorData = json.decode(errorBody);
          if (errorData is String) {
            errorMessage = errorData;
          } else if (errorData is Map && errorData.containsKey('message')) {
            errorMessage = errorData['message'];
          }
        } catch (_) {}
        throw QnaException(errorMessage, QnaErrorType.serverError);
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

  /// 특정 질문([questionId])에 대한 답변 목록을 조회합니다.
  /// 백엔드 API가 `POST /api/qna/questions-answers/{questionId}` 형태로 구현되어 있어 `POST` 메서드를 사용합니다.
  ///
  /// [questionId] : 답변을 조회할 질문의 고유 ID.
  /// [context] : 인증 헤더 생성을 위해 필요한 BuildContext.
  /// 반환값: `QnaAnswer` 객체 리스트.
  /// 예외: 네트워크 오류, 서버 오류 등 `QnaException` 발생 가능.
  static Future<List<QnaAnswer>> getAnswersByQuestionId(
    int questionId,
    BuildContext context, // 인증 헤더를 위해 context 필요
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse(
              '$baseUrl/questions-answers/$questionId',
            ), // POST 메서드 사용 및 답변 목록 API URL
            headers: _getAuthHeaders(context), // 인증 헤더 포함
            body: json.encode({}), // 요청 본문에 빈 JSON 객체 전달
          )
          .timeout(const Duration(seconds: 10)); // 10초 타임아웃 설정

      if (response.statusCode == 200) {
        // 성공 (OK) 시 응답 본문을 UTF-8로 디코딩 후 JSON 파싱
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        return data
            .map((json) => QnaAnswer.fromJson(json))
            .toList(); // QnaAnswer 객체 리스트로 변환
      } else {
        // 성공 외의 상태 코드일 경우 에러 메시지 파싱 시도 후 예외 발생
        String errorMessage = '답변 목록 조회 실패: ${response.statusCode}';
        try {
          final errorBody = utf8.decode(response.bodyBytes);
          final errorData = json.decode(errorBody);
          if (errorData is String) {
            errorMessage = errorData;
          } else if (errorData is Map && errorData.containsKey('message')) {
            errorMessage = errorData['message'];
          }
        } catch (_) {}
        throw QnaException(errorMessage, QnaErrorType.serverError);
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
  /// 백엔드 API는 `POST /api/qna/answers` 형태로 구현되어 있습니다.
  ///
  /// [answer] : 작성할 `QnaAnswer` 객체 (ID, userId, nickname은 서버에서 처리).
  /// [context] : 인증 헤더 생성을 위해 필요한 BuildContext.
  /// 반환값: 없음 (성공 시 `void`).
  /// 예외: 네트워크 오류, 유효성 검사 실패, 인증 오류 등 `QnaException` 발생 가능.
  static Future<void> createAnswer(
    QnaAnswer answer,
    BuildContext context, // 인증 헤더를 위해 context 필요
  ) async {
    try {
      final answerData = answer.toJson();
      answerData.remove('id'); // ID는 서버에서 자동 생성되므로 제거
      // 백엔드 QnaController는 userId를 JWT에서 추출하므로 제거
      answerData.remove('userId');
      // 백엔드 QnaAnswerDTO에 nickname 필드가 없으므로 제거 (서버가 사용자 정보로 닉네임 가져옴)
      answerData.remove('nickname');

      final response = await http
          .post(
            Uri.parse('$baseUrl/answers'), // 답변 생성 API URL
            headers: _getAuthHeaders(context), // 인증 헤더 포함
            body: json.encode(answerData), // JSON으로 인코딩된 답변 데이터
          )
          .timeout(const Duration(seconds: 15)); // 15초 타임아웃 설정

      if (response.statusCode == 201) {
        // 성공 (Created)
        return; // 성공 시 아무것도 반환하지 않음
      } else {
        // 성공 외의 상태 코드일 경우 에러 메시지 파싱 시도 후 예외 발생
        String errorMessage = '답변 생성 실패: ${response.statusCode}';
        try {
          final errorBody = utf8.decode(response.bodyBytes);
          final errorData = json.decode(errorBody);
          if (errorData is String) {
            errorMessage = errorData;
          } else if (errorData is Map && errorData.containsKey('message')) {
            errorMessage = errorData['message'];
          }
        } catch (_) {}
        throw QnaException(errorMessage, QnaErrorType.serverError);
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

  /// 특정 질문에 대한 좋아요를 토글(추가/취소)합니다.
  /// 백엔드 API는 `POST /api/qna/questions/{questionId}/like` 형태로 구현되어 있습니다.
  ///
  /// [questionId] : 좋아요를 토글할 질문의 고유 ID.
  /// [context] : 인증 헤더 생성을 위해 필요한 BuildContext.
  /// 반환값: 좋아요 상태 (`true`는 좋아요 활성화, `false`는 좋아요 비활성화).
  /// 예외: 네트워크 오류, 인증 오류 등 `QnaException` 발생 가능.
  static Future<bool> toggleQuestionLike(
    int questionId,
    BuildContext context, // 인증 헤더를 위해 context 필요
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/questions/$questionId/like'), // 질문 좋아요 API URL
            headers: _getAuthHeaders(context), // 인증 헤더 포함
            body: json.encode(
              {},
            ), // 백엔드가 @RequestBody(required = false) Map<String, Object>를 받으므로 빈 Map 전달
          )
          .timeout(const Duration(seconds: 10)); // 10초 타임아웃 설정

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        return data as bool; // 백엔드는 `ResponseEntity<Boolean>`을 반환
      } else {
        // 성공 외의 상태 코드일 경우 에러 메시지 파싱 시도 후 예외 발생
        String errorMessage = '질문 좋아요 처리 실패: ${response.statusCode}';
        try {
          final errorBody = utf8.decode(response.bodyBytes);
          final errorData = json.decode(errorBody);
          if (errorData is String) {
            errorMessage = errorData;
          } else if (errorData is Map && errorData.containsKey('message')) {
            errorMessage = errorData['message'];
          }
        } catch (_) {}
        throw QnaException(errorMessage, QnaErrorType.serverError);
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
  /// 백엔드 API는 `POST /api/qna/answers/{answerId}/like` 형태로 구현되어 있습니다.
  ///
  /// [answerId] : 좋아요를 토글할 답변의 고유 ID.
  /// [context] : 인증 헤더 생성을 위해 필요한 BuildContext.
  /// 반환값: 좋아요 상태 (`true`는 좋아요 활성화, `false`는 좋아요 비활성화).
  /// 예외: 네트워크 오류, 인증 오류 등 `QnaException` 발생 가능.
  static Future<bool> toggleAnswerLike(
    int answerId,
    BuildContext context, // 인증 헤더를 위해 context 필요
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/answers/$answerId/like'), // 답변 좋아요 API URL
            headers: _getAuthHeaders(context), // 인증 헤더 포함
            body: json.encode(
              {},
            ), // 백엔드가 @RequestBody(required = false) Map<String, Object>를 받으므로 빈 Map 전달
          )
          .timeout(const Duration(seconds: 10)); // 10초 타임아웃 설정

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        return data as bool; // 백엔드는 `ResponseEntity<Boolean>`을 반환
      } else {
        // 성공 외의 상태 코드일 경우 에러 메시지 파싱 시도 후 예외 발생
        String errorMessage = '답변 좋아요 처리 실패: ${response.statusCode}';
        try {
          final errorBody = utf8.decode(response.bodyBytes);
          final errorData = json.decode(errorBody);
          if (errorData is String) {
            errorMessage = errorData;
          } else if (errorData is Map && errorData.containsKey('message')) {
            errorMessage = errorData['message'];
          }
        } catch (_) {}
        throw QnaException(errorMessage, QnaErrorType.serverError);
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
/// 특정 오류 메시지와 `QnaErrorType`을 포함합니다.
class QnaException implements Exception {
  final String message; // 사용자에게 표시할 오류 메시지
  final QnaErrorType type; // 오류의 구체적인 타입

  QnaException(this.message, this.type); // 생성자

  @override
  String toString() => 'QnaException: $message'; // 예외 객체를 문자열로 표현
}

/// Q&A 서비스에서 발생할 수 있는 오류의 종류를 정의하는 열거형(enum)입니다.
enum QnaErrorType {
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
