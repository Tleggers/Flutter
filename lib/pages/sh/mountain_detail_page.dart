import 'package:flutter/material.dart';
import 'package:trekkit_flutter/models/sh/mountain.dart';

class MountainDetailPage extends StatelessWidget {
  final Mountain mountain;

  const MountainDetailPage({super.key, required this.mountain});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(mountain.name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              mountain.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Icon(Icons.image_not_supported, size: 150),
            ),
            const SizedBox(height: 16),
            Text(
              mountain.name,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text('${mountain.height}m', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            Text(mountain.overview),
          ],
        ),
      ),
    );
  }
}
