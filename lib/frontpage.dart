import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'vision_detector_views/pose_detector_view.dart';
import 'game.dart';

class Frontpage extends StatelessWidget {
  const Frontpage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ElevatedButton(
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const Nextpage()),
          );
        },
        child: const Text("START"),
      ),
    );
  }
}

class Nextpage extends StatelessWidget {
  const Nextpage({super.key});

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
