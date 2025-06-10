import 'package:flutter/material.dart';
import 'package:trekkit_flutter/models/sh/mountain.dart';
import 'package:trekkit_flutter/pages/sh/mountain_detail_page.dart';

class MountainCard extends StatelessWidget {
  final Mountain mountain;

  const MountainCard({super.key, required this.mountain});

  // @override
  // Widget build(BuildContext context) {
  //   return Card(
  //     margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  //     child: ListTile(
  //       leading: mountain.imageUrl.isNotEmpty
  //           ? Image.network(mountain.imageUrl, width: 60, height: 60, fit: BoxFit.cover)
  //           : Icon(Icons.landscape, size: 60),
  //       title: Text(mountain.name),
  //       subtitle: Text('위도: ${mountain.lat}, 경도: ${mountain.lng}'),
  //       onTap: () {
  //         // 상세 페이지 이동 구현 시 여기에 추가
  //       },
  //     ),
  //   );
  // }

   @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MountainDetailPage(mountain: mountain),
          ),
        );
      },
      child: Card(
        child: Row(
          children: [
            // 이미지 로딩 실패 대비
            Image.network(
              mountain.imageUrl,
              width: 100,
              height: 100,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Icon(Icons.image_not_supported, size: 80, color: Colors.grey),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(mountain.name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text('${mountain.height}m', style: TextStyle(color: Colors.grey)),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
