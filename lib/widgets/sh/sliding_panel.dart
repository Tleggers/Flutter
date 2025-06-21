import 'package:flutter/material.dart';
import 'package:trekkit_flutter/models/sh/mountain.dart';
import 'package:trekkit_flutter/views/sh/mountain_collage_view.dart';
import 'package:trekkit_flutter/widgets/sh/mountain_card.dart';

class SlidingPanel extends StatelessWidget {
  final List<Mountain> mountains;

  const SlidingPanel({super.key, required this.mountains, required MountainCollageView child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        boxShadow: [BoxShadow(blurRadius: 6, color: Colors.black26)],
      ),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: mountains.length,
        itemBuilder: (context, index) {
          return MountainCard(mountain: mountains[index]);
        },
      ),
    );
  }
}
