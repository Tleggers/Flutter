// import 'package:flutter/material.dart';
// import 'package:trekkit_flutter/models/sh/mountain.dart';
// import 'package:trekkit_flutter/pages/sh/mountain_detail_page.dart';
// import 'package:trekkit_flutter/services/sh/image_loader.dart';


// class MountainImageCarousel extends StatelessWidget {
//   final List<String> imagePaths;

//   const MountainImageCarousel({required this.imagePaths, super.key});

//   @override
//   Widget build(BuildContext context) {
//     if (imagePaths.isEmpty) {
//       return const Text('이미지가 없습니다.');
//     }

//     return SizedBox(
//       height: 180,
//       child: ListView.builder(
//         scrollDirection: Axis.horizontal,
//         itemCount: imagePaths.length,
//         itemBuilder: (context, index) {
//           return Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Image.asset(imagePaths[index]),
//           );
//         },
//       ),
//     );
//   }
// }

// class MountainCard extends StatelessWidget {
//   final Mountain mountain;

//   const MountainCard({super.key, required this.mountain});

//    @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () {
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (_) => MountainDetailPage(mountain: mountain),
//           ),
//         );
//       },
//       child: Card(
//         child: Row(
//           children: [
//             // 이미지 로딩 실패 대비
//             Image.network(
//               mountain.imageUrl,
//               width: 100,
//               height: 100,
//               fit: BoxFit.cover,
//               errorBuilder: (context, error, stackTrace) => Icon(Icons.image_not_supported, size: 80, color: Colors.grey),
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(mountain.name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//                   Text('${mountain.height}m', style: TextStyle(color: Colors.grey)),
//                 ],
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:trekkit_flutter/models/sh/mountain.dart';
import 'package:trekkit_flutter/pages/sh/mountain_detail_page.dart';
import 'package:trekkit_flutter/services/sh/image_loader.dart';

class MountainCard extends StatefulWidget {
  final Mountain mountain;

  const MountainCard({super.key, required this.mountain});

  @override
  State<MountainCard> createState() => _MountainCardState();
}

class _MountainCardState extends State<MountainCard> {
  List<String> imagePaths = [];

  @override
  void initState() {
    super.initState();
    loadImages();
  }

  void loadImages() async {
    final images = await ImageLoader.loadMountainImages(widget.mountain.name);
    setState(() {
      imagePaths = images;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MountainDetailPage(mountain: widget.mountain),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            imagePaths.isNotEmpty
                ? SizedBox(
                    height: 180,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: imagePaths.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Image.asset(
                                  imagePaths[index],
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                  print('❌ 이미지 로드 실패: ${imagePaths[index]}');
                                  return Icon(Icons.image_not_supported, size: 80, color: Colors.grey);
                                 },
                            ),
                        );
                      },
                    ),
                  )
                : const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('이미지가 없습니다.'),
                  ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
              child: Text(
                widget.mountain.name,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4),
              child: Text('${widget.mountain.height}m', style: const TextStyle(color: Colors.grey)),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}