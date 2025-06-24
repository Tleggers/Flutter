import 'package:flutter/material.dart';
import 'package:trekkit_flutter/widgets/jh/MyPage/MyPageHeader/point/point_charge_page.dart';
import 'package:provider/provider.dart';

import '../../../../../functions/jh/userprovider.dart';
import '../../../../../pages/gb/step/step_provider.dart';

class PointWidget extends StatelessWidget {
  final double screenWidth;
  final double screenHeight;

  const PointWidget({
    super.key,
    required this.screenWidth,
    required this.screenHeight,
  });

  @override
  Widget build(BuildContext context) {

    final userProvider = Provider.of<UserProvider>(context); // 유저 provider
    final stepProvider = Provider.of<StepProvider>(context, listen: false); // 걸음 수 provider
    final currentStep = stepProvider.currentStep;

    double boxHeight = screenHeight * 0.1;
    double fontSizeTitle = screenWidth * 0.04;
    double fontSizeValue = screenWidth * 0.05;

    return Container(
      height: boxHeight,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(screenWidth * 0.02),
      ),
      child: Row(
        children: [
          _buildItem("내 포인트", userProvider.point.toString(), fontSizeTitle, fontSizeValue),
          _buildDivider(),
          _buildItem("오늘 걸음 수", currentStep.toString(), fontSizeTitle, fontSizeValue),
          _buildDivider(),
          Expanded(
            child: Center(
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PointChargePage(),
                    ),
                  );
                },
                child: Text(
                  "충전",
                  style: TextStyle(
                    fontSize: fontSizeTitle,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItem(String title, String value, double titleSize, double valueSize) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title, style: TextStyle(fontSize: titleSize, color: Colors.grey[700])),
          SizedBox(height: screenHeight * 0.005),
          Text(value, style: TextStyle(fontSize: valueSize, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      color: Colors.grey.shade300,
      height: screenHeight * 0.06,
    );
  }
}