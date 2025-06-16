import 'package:flutter/material.dart';
import 'package:trekkit_flutter/api/suggest_mountain_api.dart';
import 'package:trekkit_flutter/api/suggest_mountain_image_api.dart';
import 'package:trekkit_flutter/models/gb/suggest_mountain.dart';
import 'package:trekkit_flutter/pages/gb/detail/mountain_detail_page.dart';

class SuggestRandomListPage extends StatefulWidget {
  const SuggestRandomListPage({super.key});

  @override
  State<SuggestRandomListPage> createState() => _SuggestRandomListPageState();
}

class _SuggestRandomListPageState extends State<SuggestRandomListPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("추천 산 리스트"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: FutureBuilder<List<SuggestMountain>>(
        future: SuggestMountainApi.fetchMountains(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('데이터 로딩 실패'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('산 데이터 없음'));
          } else {
            final allMountains = snapshot.data!;
            allMountains.shuffle(); // ✅ 리스트 섞기
            final randomSample = allMountains.take(8).toList(); // ✅ 8개 추출

            return ListView.builder(
              itemCount: randomSample.length,
              itemBuilder: (context, index) {
                final mountain = randomSample[index];

                return FutureBuilder<String?>(
                  future: SuggestMountainImageApi.fetchImagesByMountainCode(
                    mountain.id,
                  ).then((images) {
                    if (images.isNotEmpty) {
                      return images[0].fullImageUrl;
                    } else {
                      return null;
                    }
                  }),
                  builder: (context, snapshot) {
                    Widget leadingWidget;
                    final imageUrl = snapshot.data;

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      leadingWidget = Container(
                        width: 60,
                        height: 60,
                        color: Colors.grey[300],
                        child: const CircularProgressIndicator(),
                      );
                    } else if (snapshot.hasError ||
                        !snapshot.hasData ||
                        snapshot.data == null) {
                      leadingWidget = Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.image,
                          size: 30,
                          color: Colors.green,
                        ),
                      );
                    } else {
                      leadingWidget = Image.network(
                        snapshot.data!,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      );
                    }

                    return ListTile(
                      leading: leadingWidget,
                      title: Text(mountain.name),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (mountain.height != 0) Text('${mountain.height}m'),
                          Text(shortLocation(mountain.location)),
                        ],
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => MountainDetailPage(
                                  mountainName: mountain.name,
                                  imageUrl: imageUrl,
                                ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            );
          }
        },
      ),
    );
  }

  String shortLocation(String? location) {
    if (location == null || location.isEmpty) return '';
    final firstPart = location.split(',')[0].trim();
    final parts = firstPart.split(' ');
    if (parts.length >= 2) {
      return '${parts[0]} ${parts[1]}';
    } else {
      return firstPart;
    }
  }
}
