import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:trekkit_flutter/models/jw/QnaQuestion.dart';

class QnaService {
  static const String baseUrl = 'http://10.0.2.2:30000/api/qna';

  // Q&A 질문 목록 조회
  static Future<Map<String, dynamic>> getQuestions({
    String sort = 'latest',
    String? mountain,
    int page = 0,
    int size = 10,
  }) async {
    try {
      final Map<String, String> queryParams = {
        'sort': sort,
        'page': page.toString(),
        'size': size.toString(),
      };

      if (mountain != null && mountain.isNotEmpty) {
        queryParams['mountain'] = mountain;
      }

      final uri = Uri.parse(
        '$baseUrl/questions',
      ).replace(queryParameters: queryParams);

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));

        List<QnaQuestion> questions =
            (data['questions'] as List)
                .map((item) => QnaQuestion.fromJson(item))
                .toList();

        return {
          'questions': questions,
          'totalCount': data['totalCount'] ?? 0,
          'currentPage': data['currentPage'] ?? 0,
          'totalPages': data['totalPages'] ?? 0,
        };
      } else {
        throw Exception('질문 목록을 불러오는데 실패했습니다: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('네트워크 오류: $e');
    }
  }

  // Q&A 질문 상세 조회
  static Future<QnaQuestion?> getQuestionById(int id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/questions/$id'));

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        return QnaQuestion.fromJson(data);
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('질문을 불러오는데 실패했습니다: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('네트워크 오류: $e');
    }
  }

  // Q&A 질문 작성 - 토큰 인증 추가
  static Future<int> createQuestion(QnaQuestion question, String token) async {
    try {
      // 요청 데이터 로깅
      final requestBody = json.encode(question.toJson());
      print('=== HTTP 요청 정보 ===');
      print('URL: $baseUrl/questions');
      print('Method: POST');
      print(
        'Headers: {Content-Type: application/json, Authorization: Bearer $token}',
      );
      print('Body: $requestBody');
      print('==================');

      final response = await http.post(
        Uri.parse('$baseUrl/questions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // JWT 토큰 추가
        },
        body: requestBody,
      );

      // 응답 데이터 로깅
      print('=== HTTP 응답 정보 ===');
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
      print('==================');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return data['questionId'];
        } else {
          throw Exception(data['message'] ?? '질문 작성에 실패했습니다');
        }
      } else {
        // 더 자세한 에러 정보
        String errorMessage = '질문 작성에 실패했습니다: ${response.statusCode}';
        try {
          final errorData = json.decode(response.body);
          if (errorData['message'] != null) {
            errorMessage += ' - ${errorData['message']}';
          }
        } catch (e) {
          // JSON 파싱 실패 시 원본 응답 사용
          errorMessage += ' - ${response.body}';
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      throw Exception('네트워크 오류: $e');
    }
  }

  // 특정 질문의 답변 목록 조회
  static Future<List<QnaAnswer>> getAnswersByQuestionId(int questionId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/questions/$questionId/answers'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        return data.map((item) => QnaAnswer.fromJson(item)).toList();
      } else {
        throw Exception('답변 목록을 불러오는데 실패했습니다: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('네트워크 오류: $e');
    }
  }

  // 답변 작성
  static Future<int> createAnswer(QnaAnswer answer, String token) async {
    try {
      // 요청 데이터 로깅
      final requestBody = json.encode(answer.toJson());
      print('=== HTTP 답변 요청 정보 ===');
      print('URL: $baseUrl/questions/${answer.questionId}/answers');
      print('Method: POST');
      print(
        'Headers: {Content-Type: application/json, Authorization: Bearer $token}',
      );
      print('Body: $requestBody');
      print('==================');

      final response = await http.post(
        Uri.parse('$baseUrl/questions/${answer.questionId}/answers'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // JWT 토큰 추가
        },
        body: requestBody,
      );

      // 응답 데이터 로깅
      print('=== HTTP 답변 응답 정보 ===');
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
      print('==================');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return data['answerId'];
        } else {
          throw Exception(data['message'] ?? '답변 작성에 실패했습니다');
        }
      } else {
        // 더 자세한 에러 정보
        String errorMessage = '답변 작성에 실패했습니다: ${response.statusCode}';
        try {
          final errorData = json.decode(response.body);
          if (errorData['message'] != null) {
            errorMessage += ' - ${errorData['message']}';
          }
        } catch (e) {
          // JSON 파싱 실패 시 원본 응답 사용
          errorMessage += ' - ${response.body}';
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      throw Exception('네트워크 오류: $e');
    }
  }

  // 질문 좋아요 토글
  // 질문 좋아요 토글
  static Future<bool> toggleQuestionLike(int questionId, String userId) async {
    try {
      // 요청 정보 로깅
      final url = Uri.parse(
        '$baseUrl/questions/$questionId/like?userId=$userId',
      );
      print('=== 좋아요 요청 정보 ===');
      print('URL: $url');
      print('Method: POST');
      print('==================');

      final response = await http.post(url);

      // 응답 정보 로깅
      print('=== 좋아요 응답 정보 ===');
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
      print('==================');

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        if (data['success'] == true) {
          return data['isLiked'] ?? false;
        } else {
          throw Exception(data['message'] ?? '좋아요 처리에 실패했습니다');
        }
      } else {
        throw Exception('좋아요 처리에 실패했습니다: ${response.statusCode}');
      }
    } catch (e) {
      print('좋아요 처리 중 오류 발생: $e');
      throw Exception('네트워크 오류: $e');
    }
  }

  // 답변 좋아요 토글
  static Future<bool> toggleAnswerLike(int answerId, String userId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/answers/$answerId/like?userId=$userId'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return data['isLiked'];
        } else {
          throw Exception(data['message'] ?? '좋아요 처리에 실패했습니다');
        }
      } else {
        throw Exception('좋아요 처리에 실패했습니다: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('네트워크 오류: $e');
    }
  }
}
