import 'package:permission_handler/permission_handler.dart';

Future<void> requestActivityPermission() async {
  final status = await Permission.activityRecognition.status;
  if (!status.isGranted) {
    final result = await Permission.activityRecognition.request();
    if (result.isGranted) {
    }
  }
}