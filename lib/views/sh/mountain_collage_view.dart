import 'package:flutter/material.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:trekkit_flutter/models/sh/mountain.dart';
import 'package:trekkit_flutter/services/sh/image_loader.dart';
import 'package:trekkit_flutter/pages/sh/mountain_detail_page.dart';

//리스트 페이지 외부 이미지 콜라주
class MountainCollageView extends StatelessWidget {
  final List<Mountain> mountains;
  final ScrollController scrollController;
  final void Function(Mountain)? onMountainTap;

  const MountainCollageView({super.key, required this.mountains, required this.scrollController, this.onMountainTap,});

  String extractSummary(String overview) {
  final unescape = HtmlUnescape();
  // 먼저 HTML 이스케이프 문자 변환 (&lt; → <, &gt; → >)
  String decoded = unescape.convert(overview);

  // < > 사이의 내용만 추출
  final match = RegExp(r'<(.*?)>').firstMatch(decoded);
  return match != null ? match.group(1)!.trim() : '설명이 없습니다.';
}

 @override
  Widget build(BuildContext context) {
    if (mountains.isEmpty) {
      return const Center(child: Text("표시할 산이 없습니다."));
    }

    return ListView.builder(
      controller: scrollController,
      itemCount: mountains.length,
      itemBuilder: (context, index) {
        final mountain = mountains[index];
        return FutureBuilder<List<String>>(
          future: ImageLoader.loadMountainImages(mountain.name),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              );
            }

            final images = snapshot.data ?? [];
            final selectedImages = images.take(4).toList();

            return Card(
              margin: const EdgeInsets.all(12),
              child: InkWell(
                  onTap: () {
                    onMountainTap?.call(mountain);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MountainDetailPage(mountain: mountain),
                      ),
                    );
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "${mountain.name} (${mountain.height}m)",
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (mountain.overview.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            extractSummary(mountain.overview),
                            style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                          ),
                        ),
                      const SizedBox(height: 8),
                      if (selectedImages.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('이미지가 없습니다.'),
                        )
                      else
                        GridView.count(
                          shrinkWrap: true,
                          crossAxisCount: 2,
                          crossAxisSpacing: 4,
                          mainAxisSpacing: 4,
                          physics: const NeverScrollableScrollPhysics(),
                          children: selectedImages.map((imgPath) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.asset(
                                imgPath,
                                fit: BoxFit.cover,
                              ),
                            );
                          }).toList(),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      );
    }
  }