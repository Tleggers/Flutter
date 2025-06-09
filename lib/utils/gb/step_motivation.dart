import 'dart:math';

/// 응원 메시지를 하루에 하나만 보여주기 위한 유틸 클래스
class StepMotivation {
  static final List<String> _messages = [
    '오늘도 건강한 하루 보내세요!',
    '멋지게 움직이고 있어요!',
    '조금만 더 힘내봐요!',
    '등산 준비 완료~ 파이팅!',
    '좋은 하루 되세요 :)',
    '한 걸음 한 걸음이 건강으로!',
    '꾸준함이 최고의 무기입니다!',
    '포기하지 마세요, 잘하고 있어요!',
    '몸도 마음도 활기차게!',
    '지금도 충분히 멋져요!',
  ];

  /// 오늘 날짜 기준으로 동일한 메시지 반환
  static String getTodayMessage() {
    final today = DateTime.now();
    final seed = today.year + today.month + today.day;
    final rand = Random(seed);
    return _messages[rand.nextInt(_messages.length)];
  }
}
