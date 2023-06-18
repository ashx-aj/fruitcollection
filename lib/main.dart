import 'package:camera/camera.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fruitgame/game.dart';
import 'package:fruitgame/vision_detector_views/detector_views.dart';

List<CameraDescription> cameras = [];
final Changer changer = Changer();

Future<void> main() async {
  // Ensures that all bindings are initialized
  // before was start calling hive and flame code
  // dealing with platform channels.
  WidgetsFlutterBinding.ensureInitialized();

  // Makes the game full screen and landscape only.
  Flame.device.fullScreen();
  Flame.device.setPortrait();
  cameras = await availableCameras();
  runApp(const JustStyle());
}

class JustStyle extends StatelessWidget {
  const JustStyle({super.key});

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return MaterialApp(
      home: Scaffold(
          body: Column(
        children: [
          SizedBox(
            height: 0.5 * height,
            child: PoseDetectorView(),
          ),
          SizedBox(
            height: 0.5 * height,
            child: GameWidget(
              game: MyGame(),
            ),
          ),
        ],
      )),
    );
  }
}

// The main widget for this game.

class Changer extends ChangeNotifier {
  int btnPressed = -1;
  int selectedOpt = 0;

  void notify() {
    notifyListeners();
  }
}
