import 'dart:math';
import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:fruitgame/game.dart';
import 'camera_view.dart';
import 'painters/pose_detector_painter.dart';

class PoseDetectorView extends StatefulWidget {
  const PoseDetectorView({Key? key}) : super(key: key);

  @override
  State<PoseDetectorView> createState() => _PoseDetectorViewState();
}

class _PoseDetectorViewState extends State<PoseDetectorView> {
  final PoseDetector _poseDetector = PoseDetector(
      options: PoseDetectorOptions(model: PoseDetectionModel.base));

  bool _canProcess = true;
  bool _isBusy = false;
  CustomPaint? _customPaint;
  String? _text;

  @override
  void dispose() {
    _canProcess = false;
    _poseDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CameraView(
      title: 'Pose Detector',
      customPaint: _customPaint,
      text: _text,
      onImage: (inputImage) {
        processImage(inputImage);
      },
      initialDirection: CameraLensDirection.front,
    );
  }

  Future<void> processImage(InputImage inputImage) async {
    if (!_canProcess) return;
    if (_isBusy) return;
    _isBusy = true;
    setState(() {
      _text = '';
    });

    var poses = await _poseDetector.processImage(inputImage);

    for (Pose pose in poses) {
      PoseLandmark rightHip = pose.landmarks[PoseLandmarkType.rightHip]!;
      PoseLandmark rightElbow = pose.landmarks[PoseLandmarkType.rightElbow]!;
      PoseLandmark rightShoulder =
          pose.landmarks[PoseLandmarkType.rightShoulder]!;

      PoseLandmark leftHip = pose.landmarks[PoseLandmarkType.leftHip]!;
      PoseLandmark leftElbow = pose.landmarks[PoseLandmarkType.leftElbow]!;
      PoseLandmark leftShoulder =
          pose.landmarks[PoseLandmarkType.leftShoulder]!;

      double rangle = calculateAngle(rightHip.x, rightHip.y, rightShoulder.x,
          rightShoulder.y, rightElbow.x, rightElbow.y);

      double langle = calculateAngle(leftHip.x, leftHip.y, leftShoulder.x,
          leftShoulder.y, leftElbow.x, leftElbow.y);

      // Define a threshold angle to determine significant upward movement
      const double upwardMovementThreshold = 20.0;
      // Adjust the threshold as needed

      if (rangle >= langle && rangle >= upwardMovementThreshold) {
        print('Right arm has more upward movement!');
        print(rangle);
        rightControl();
      } else if (langle >= upwardMovementThreshold) {
        print('Left arm has more upward movement!');
        print(langle);
        leftControl();
        // Perform actions for the left arm's upward movement
      }

      void clearPoses() {
        // Clear poses logic goes here...
        poses = [];
      }

      // Clear poses after a certain time
      const clearDuration = Duration(seconds: 5);
      Timer(clearDuration, () {
        clearPoses();
      });

      if (inputImage.inputImageData?.size != null &&
          inputImage.inputImageData?.imageRotation != null) {
        final painter = PoseDetectorPainter(
            poses,
            inputImage.inputImageData!.size,
            inputImage.inputImageData!.imageRotation);
        _customPaint = CustomPaint(painter: painter);
      } else {
        String text = 'Poses found: ${poses.length}\n\n';
        for (final pose in poses) {
          text += 'pose: ${pose.toString()}\n\n';
        }
        _text = text;
        // TODO: set _customPaint to draw pose lines on top of image
        _customPaint = null;
      }
      _isBusy = false;
      if (mounted) {
        setState(() {});
      }
    }
  }

  double calculateAngle(
      double x1, double y1, double x2, double y2, double x3, double y3) {
    double angle = atan2(y1 - y2, x1 - x2) - atan2(y3 - y2, x3 - x2);
    angle = angle * 180 / pi;
    if (angle < 0) angle += 360;
    return angle;
  }
}
