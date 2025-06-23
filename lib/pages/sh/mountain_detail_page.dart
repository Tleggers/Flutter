import 'package:flutter/material.dart';
import 'package:trekkit_flutter/models/sh/mountain.dart';
import 'package:html_unescape/html_unescape.dart';

class MountainDetailPage extends StatelessWidget {
  final Mountain mountain;

  const MountainDetailPage({super.key, required this.mountain});

  @override
  Widget build(BuildContext context) {
    final unescape = HtmlUnescape();
    String cleanDescription = unescape.convert(
      mountain.overview
      .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
      .replaceAllMapped(RegExp(r'([\.。])(?=\S)'), (match) => '${match.group(1)}\n'),);
    final List<String> imagePaths = List.generate(
      5,
      (index) => 'assets/mtimages/${mountain.name}_${index + 1}.jpg',
    );

    return Scaffold(
      appBar: AppBar(title: Text(mountain.name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 250,
              child: PageView.builder(
                itemCount: imagePaths.length,
                itemBuilder: (context, index) {
                  return Image.asset(
                    imagePaths[index],
                    fit: BoxFit.cover,
                    errorBuilder:
                        (context, error, stackTrace) =>
                            const Icon(Icons.broken_image, size: 100),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mountain.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${mountain.height}m',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  Text(cleanDescription),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
