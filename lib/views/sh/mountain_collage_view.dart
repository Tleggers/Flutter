import 'package:flutter/material.dart';
import 'package:trekkit_flutter/models/sh/mountain.dart';
import 'package:trekkit_flutter/services/sh/image_loader.dart';

class MountainCollageView extends StatelessWidget {
  final List<Mountain> mountains;
  final ScrollController scrollController;

  const MountainCollageView({super.key, required this.mountains, required this.scrollController});

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
    return ListView.builder(
      controller: scrollController,
      itemCount: mountains.length,
      itemBuilder: (context, index) {
        final mountain = mountains[index];
        return FutureBuilder<List<String>>(
          future: ImageLoader.loadMountainImages(mountain.name),
          builder: (context, snapshot) {
            // 아직 이미지 안 넣은 산이 안보여서 취소
            // if (!snapshot.hasData || snapshot.data!.isEmpty) {
            //   return const SizedBox.shrink(); // 이미지 없을 경우 건너뜀
            // }
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      mountain.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
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
                      children: selectedImages
                          .map(
                            (imgPath) => ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.asset(
                                imgPath,
                                fit: BoxFit.cover,
                              ),
                            ),
                          )
                          .toList(),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
