import 'package:flutter/material.dart';

class FaqPage extends StatelessWidget {
  const FaqPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    final List<Map<String, String>> faqList = [
      {
        'question': 'TrekKit은 어떤 앱인가요?',
        'answer': 'TrekKit은 등산 기록, 경로 탐색, 커뮤니티 기능까지 제공하는 통합 하이킹 플랫폼입니다.',
      },
      {
        'question': '포인트는 어떻게 적립하나요?',
        'answer': '후기 작성 시 사진과 텍스트가 모두 포함되어야 포인트가 자동으로 적립됩니다. 첫 후기에는 보너스 포인트도 제공됩니다.',
      },
      {
        'question': '회원 탈퇴는 어떻게 하나요?',
        'answer': '마이페이지에서 "회원탈퇴"를 누르고 확인 버튼을 누르면 탈퇴가 완료됩니다. 탈퇴 후 정보는 복구되지 않습니다.',
      },
      {
        'question': 'SNS 계정으로 로그인했는데 탈퇴하면 연동도 해제되나요?',
        'answer': '네, 카카오 및 구글 계정과의 연동도 자동으로 해제됩니다.',
      },
      {
        'question': '등산 경로는 어떻게 탐색하나요?',
        'answer': '메인 화면의 지도 아이콘을 클릭하면 내 주변 등산 코스를 확인하고 경로를 탐색할 수 있습니다.',
      },
      {
        'question': '후기는 어떻게 작성하나요?',
        'answer': '산행을 완료한 후 해당 코스 페이지에서 "후기 작성" 버튼을 눌러 텍스트와 사진을 등록할 수 있습니다.',
      },
      {
        'question': '로그인 상태가 유지되지 않아요.',
        'answer': '앱을 재설치하거나 로그아웃한 경우 토큰이 초기화됩니다. 다시 로그인해 주세요.',
      },
      {
        'question': '닉네임이나 프로필 사진을 바꾸고 싶어요.',
        'answer': '마이페이지 > 회원정보 수정에서 닉네임과 프로필 이미지를 변경할 수 있습니다.',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('자주 묻는 질문'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        centerTitle: true,
        elevation: 1,
      ),
      body: ListView.separated(
        padding: EdgeInsets.all(screenWidth * 0.04),
        itemCount: faqList.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final item = faqList[index];
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
            child: ExpansionTile(
              title: Text(
                item['question']!,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Text(item['answer']!),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}