import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

import 'coordinates_translator.dart';

class PoseDetectorPainter extends CustomPainter {
  PoseDetectorPainter(this.poses, this.absoluteImageSize, this.rotation);

  final List<Pose> poses;
  final Size absoluteImageSize;
  final InputImageRotation rotation;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = Colors.red;

    void drawLine(
        Canvas canvas, PoseLandmark? from, PoseLandmark? to, Paint paint) {
      if (from != null && to != null) {
        canvas.drawLine(
          Offset(
            translateX(from.x, rotation, size, absoluteImageSize),
            translateY(from.y, rotation, size, absoluteImageSize),
          ),
          Offset(
            translateX(to.x, rotation, size, absoluteImageSize),
            translateY(to.y, rotation, size, absoluteImageSize),
          ),
          paint,
        );
      }
    }

    void drawCircle(Canvas canvas, PoseLandmark? landmark, Paint paint) {
      if (landmark != null) {
        canvas.drawCircle(
          Offset(
            translateX(landmark.x, rotation, size, absoluteImageSize),
            translateY(landmark.y, rotation, size, absoluteImageSize),
          ),
          2.0,
          paint,
        );
      }
    }

    for (final Pose pose in poses) {
      // Draw upper body parts
      drawLine(canvas, pose.landmarks[PoseLandmarkType.leftShoulder],
          pose.landmarks[PoseLandmarkType.leftElbow]!, paint);
      drawLine(canvas, pose.landmarks[PoseLandmarkType.leftElbow],
          pose.landmarks[PoseLandmarkType.leftWrist], paint);
      drawLine(canvas, pose.landmarks[PoseLandmarkType.rightShoulder],
          pose.landmarks[PoseLandmarkType.rightElbow], paint);
      drawLine(canvas, pose.landmarks[PoseLandmarkType.rightElbow],
          pose.landmarks[PoseLandmarkType.rightWrist], paint);
      drawLine(canvas, pose.landmarks[PoseLandmarkType.leftShoulder],
          pose.landmarks[PoseLandmarkType.rightShoulder], paint);
      drawLine(canvas, pose.landmarks[PoseLandmarkType.leftShoulder],
          pose.landmarks[PoseLandmarkType.leftHip], paint);
      drawLine(canvas, pose.landmarks[PoseLandmarkType.rightShoulder],
          pose.landmarks[PoseLandmarkType.rightHip], paint);
      drawLine(canvas, pose.landmarks[PoseLandmarkType.leftHip],
          pose.landmarks[PoseLandmarkType.rightHip], paint);

      // Draw facial landmarks (optional)
      drawCircle(canvas, pose.landmarks[PoseLandmarkType.rightElbow], paint);
      drawCircle(canvas, pose.landmarks[PoseLandmarkType.rightShoulder], paint);
      drawCircle(canvas, pose.landmarks[PoseLandmarkType.rightHip], paint);
    }
  }

  @override
  bool shouldRepaint(PoseDetectorPainter oldDelegate) {
    return oldDelegate.absoluteImageSize != absoluteImageSize ||
        oldDelegate.poses != poses;
  }
}
