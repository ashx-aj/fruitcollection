import 'dart:math';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:vector_math/vector_math.dart';
import 'package:fruitgame/game.dart';

import 'camera_view.dart';
import 'painters/pose_detector_painter.dart';

class PoseDetectorView extends StatefulWidget {
  PoseDetectorView({Key? key});

  @override
  State<PoseDetectorView> createState() => _PoseDetectorViewState();
}

class _PoseDetectorViewState extends State<PoseDetectorView> {
  //int intial = 0;
  final PoseDetector _poseDetector = PoseDetector(
      options: PoseDetectorOptions(
          model: PoseDetectionModel.base, mode: PoseDetectionMode.stream));

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

    final poses = await _poseDetector.processImage(inputImage);

    for (Pose pose in poses) {
      PoseLandmark rightHip = pose.landmarks[PoseLandmarkType.rightHip]!;
      PoseLandmark rightElbow = pose.landmarks[PoseLandmarkType.rightElbow]!;
      PoseLandmark rightShoulder =
          pose.landmarks[PoseLandmarkType.rightShoulder]!;

      PoseLandmark leftHip = pose.landmarks[PoseLandmarkType.leftHip]!;
      PoseLandmark leftElbow = pose.landmarks[PoseLandmarkType.leftElbow]!;
      PoseLandmark leftShoulder =
          pose.landmarks[PoseLandmarkType.leftShoulder]!;

      double rangle = calculate(rightHip, rightShoulder, rightElbow);

      double langle = calculate(leftHip, leftShoulder, leftElbow);

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

  calculate(PoseLandmark hipLandmark, PoseLandmark shoulderLandmark,
      PoseLandmark elbowLandmark) {
    // Get the coordinates of the landmarks
    final Offset hip = Offset(hipLandmark.x, hipLandmark.y);
    final Offset shoulder = Offset(shoulderLandmark.x, shoulderLandmark.y);
    final Offset elbow = Offset(elbowLandmark.x, elbowLandmark.y);

    // Calculate the vectors from the hip to the shoulder and from the shoulder to the elbow
    final Vector2 shoulderVector =
        Vector2(shoulder.dx - hip.dx, shoulder.dy - hip.dy);
    final Vector2 elbowVector =
        Vector2(elbow.dx - shoulder.dx, elbow.dy - shoulder.dy);

    // Calculate the dot product of the two vectors
    final double dotProduct = shoulderVector.dot(elbowVector);

    // Calculate the magnitudes of the vectors
    final double shoulderMagnitude = shoulderVector.length;
    final double elbowMagnitude = elbowVector.length;

    // Calculate the angle between the vectors using the dot product and magnitudes
    final double angle =
        acos(dotProduct / (shoulderMagnitude * elbowMagnitude));

    // Convert the angle to degrees
    final double angleDegrees = angle * (180 / pi);

    return angleDegrees;
  }
}
  /*double calculateAngle(
      double x1, double y1, double x2, double y2, double x3, double y3) {
    double angle = atan2(y1 - y2, x1 - x2) - atan2(y3 - y2, x3 - x2);
    angle = angle * 180 / pi;
    if (angle < 0) angle += 360;
    return angle;
  }*/
  