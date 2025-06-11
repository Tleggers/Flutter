import 'package:flutter/material.dart';

class BannerContent extends StatelessWidget {

  const BannerContent({super.key});

  @override
  Widget build(BuildContext context) {

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(

      appBar: AppBar(
        title: Text(
          '우리 앱은 이런 앱이에요',
          style: TextStyle(
            color: Colors.black, // 글자색: 검정
            fontSize: screenWidth * 0.045,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white, // 배경색: 흰색
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black), // ← 뒤로가기 아이콘도 검정색
      ),

      body: SingleChildScrollView(
        padding: EdgeInsets.all(screenWidth * 0.05),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const SizedBox(height: 16),
            Row(
              children: const [
                Icon(Icons.explore, color: Colors.blueAccent),
                SizedBox(width: 8),
                Text(
                  '우리 앱은?',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              '🎒 이 앱은 당신의 하이킹 여정을 더 편리하고 즐겁게 만들어주는 종합 플랫폼입니다!\n\n'
                  '🧭 산행 계획부터 🔍 경로 탐색, 📝 후기 작성까지 한 번에 해결하세요.\n\n',
              style: TextStyle(fontSize: 16),
            ),

            const Divider(thickness: 1.5),

            const SizedBox(height: 20),
            Row(
              children: const [
                Icon(Icons.star, color: Colors.orange),
                SizedBox(width: 8),
                Text(
                  '주요 기능',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Text(
              '✅ 산행 기록 저장\n'
                  '✅ 실시간 피드 공유 📸\n'
                  '✅ 후기 작성 및 포인트 적립 💰\n'
                  '✅ 지도 기반 경로 탐색 🗺️\n'
                  '✅ 나만의 등산일지 작성 📝\n'
                  '✅ 커뮤니티 Q&A 기능 💬\n'
                  '✅ 레벨업과 뱃지 시스템 🏅\n',
              style: TextStyle(fontSize: 15, height: 1.6),
            ),

            const Divider(thickness: 1.5),

            const SizedBox(height: 20),
            Row(
              children: const [
                Icon(Icons.card_giftcard, color: Colors.redAccent),
                SizedBox(width: 8),
                Text(
                  '포인트 제도',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Text(
              '💡 후기 첫 글 작성 시 3,000P 지급!\n'
                  '📷 사진 + ✍️ 텍스트 포함된 글만 포인트 인정\n'
                  '🛒 포인트는 스토어에서 아이템 교환 가능!\n',
              style: TextStyle(fontSize: 15, height: 1.6),
            ),

            const Divider(thickness: 1.5),

            const SizedBox(height: 20),
            Row(
              children: const [
                Icon(Icons.emoji_people, color: Colors.green),
                SizedBox(width: 8),
                Text(
                  '이 앱은 이런 분께 추천드려요',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Text(
              '🥾 하이킹을 자주 다니는 사람\n'
                  '📷 추억을 기록하고 싶은 사람\n'
                  '🎁 포인트 모아서 보상받고 싶은 사람\n'
                  '📍 다른 사람의 등산 코스가 궁금한 사람\n'
                  '📢 커뮤니티에서 소통하고 싶은 사람\n',
              style: TextStyle(fontSize: 15, height: 1.6),
            ),

            const SizedBox(height: 40),
            Center(
              child: Text(
                '함께 산을 오르고\n함께 추억을 쌓는\n우리의 하이킹 여정\n⛰️ TrekKit과 함께 시작하세요!',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  height: 1.6,
                  color: Colors.blueGrey[800],
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }
}
