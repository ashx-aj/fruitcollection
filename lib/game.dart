import 'dart:async';
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/game.dart';
import 'package:flame/src/gestures/events.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flame_texturepacker/flame_texturepacker.dart';
import 'package:flame/widgets.dart';

List<SpriteComponent> fruits = [];

// values based on postion for collision

String positionReachingAfterRun = "";

bool boyRemoved = false;
bool runLeft = false;
bool runRight = false;
bool busy = false;

double distanceRun = 0;

Map<int, Timer> timers = {};

// Current Position

String currentPosition = "CENTER"; // LEFT OR CENTER OR RIGHT

String head = "RIGHT"; // LEFT OR RIGHT

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.immersive,
    overlays: [],
  );

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  runApp(
    GameWidget(
      game: MyGame(),
    ),
  );
}

class MyGame extends FlameGame with HasTappables {
  late TextComponent textComponent;

  SpriteComponent gameBackground = SpriteComponent();
  SpriteComponent boy = SpriteComponent();

  SpriteComponent orange1 = SpriteComponent();
  SpriteComponent orange2 = SpriteComponent();
  SpriteComponent orange3 = SpriteComponent();

  LeftButton lButton = LeftButton();
  RightButton rButton = RightButton();

  late SpriteAnimationComponent boyWalking;

  List<SpriteComponent> fruits = [];

  int fruitCollected = -1;
  int delete = 0;

  @override
  Future<void> onLoad() async {
    super.onLoad();

    // Background

    gameBackground
      ..sprite = await loadSprite('background.png')
      ..size = size;
    add(gameBackground);

    // Score
    TextPaint scoreText = TextPaint(
        style: const TextStyle(
            fontSize: 15, color: Color.fromARGB(255, 227, 19, 4)));

    textComponent = TextComponent(
        text: "SCORE :0",
        position: Vector2(size[0] * .10, size[1] * .1),
        textRenderer: scoreText);

    add(textComponent);

    // Boy

    boy
      ..sprite = await loadSprite('boy.png')
      ..size = Vector2(size[1] / 5, size[1] / 5)
      ..x = size[0] * 0.4
      ..y = size[1] / 1.3;

    // when flipped size[0]/10 must be subtracted
    add(boy);
    //print("boy is at ${boy.x}");

    // Left Button
    lButton
      ..sprite = await loadSprite('leftButton.png')
      ..size = Vector2(50, 50)
      ..x = size[0] * .1
      ..y = size[1] * .1;

    //add(lButton);

    // Right Button
    rButton
      ..sprite = await loadSprite('rightButton.png')
      ..size = Vector2(50, 50)
      ..x = size[0] * .3
      ..y = size[1] * .1;

    //add(rButton);

    // Oranges
    var orangeSprite1 = await Sprite.load('orange.png');
    var orangeSprite2 = await Sprite.load('orange.png');
    var orangeSprite3 = await Sprite.load('orange.png');

    var fruitSprites = [orangeSprite1, orangeSprite2, orangeSprite3];
    var xCoords = [size[0] * 0.1, size[0] * 0.4, size[0] * 0.7];

    for (var i = 0; i < 3; i++) {
      var fruit =
          SpriteComponent(sprite: fruitSprites[i], size: Vector2(40, 40));

      fruit.position = Vector2(xCoords[i].toDouble(), 200);
      fruits.add(fruit);
      // start a timer to create new fruits of the same type and x-coordinate every 2 seconds
      timers[xCoords[i].toInt()] = Timer(
        const Duration(seconds: 2).inSeconds.toDouble(),
        repeat: true,
        onTick: () {
          var newFruit = SpriteComponent(
            size: Vector2(20, 20),
            sprite: fruitSprites[i],
          );
          newFruit.position = Vector2(xCoords[i].toDouble(), 0);
          fruits.add(newFruit);
        },
      );
    }

    // Animation

    final spritesheet =
        await fromJSONAtlas('boy_sprite.png', 'boy_sprite.json');

    SpriteAnimation walk =
        SpriteAnimation.spriteList(spritesheet, stepTime: 0.1);
    boyWalking = SpriteAnimationComponent()
      ..animation = walk
      ..x = size[0] * 0.4
      ..y = size[1] / 1.28
      ..size = Vector2(size[1] / 5, size[1] / 5.5);

    // add(boyWalking);

    // falling oranges

    add(TimerComponent(
        period: 5,
        repeat: true,
        onTick: () async {
          SpriteComponent newFruit = SpriteComponent();
          double orangeX = size[0] * .1;
          for (int i = fruits.length - 1; i >= 0; i--) {
            var fruit = fruits[i];
            if (fruit.x >= 5000) {
              fruit.x = 6000;
              fruits.removeAt(i);
            }
          }

          // random number
          var random = Random();
          var randomNumber = random.nextInt(3);
          if (randomNumber == 0) {
            orangeX = size[0] * .1;
          } else if (randomNumber == 1) {
            orangeX = size[0] * .4;
          } else if (randomNumber == 2) {
            orangeX = size[0] * .7;
          }
          newFruit
            ..sprite = await loadSprite('orange.png')
            ..size = Vector2(30, 30)
            ..x = orangeX
            ..y = size[1] * .15;

          fruits.add(newFruit);
          //print("new fruit y is ${newFruit.position.y}");
          add(newFruit);
          //print(fruits.length);
        }));

    //print("boy y is ${boy.y}");
  }

  @override
  void update(double dt) {
    super.update(dt);

    final newText = "SCORE :${fruitCollected}";
    textComponent.text = newText;

    // To remove boy character

    if (boyRemoved) {
      if (runLeft) {
        if (head == "RIGHT") {
          head = "LEFT";
          boy.flipHorizontally();
          boyWalking.flipHorizontally();
          //flip problem

          boy.x += size[0] / 10;
          boyWalking.x += size[0] / 10;
        }
      } else {
        // runRight
        if (head == "LEFT") {
          head = "RIGHT";
          boy.flipHorizontally();
          boyWalking.flipHorizontally();

          boy.x -= size[0] / 10;
          boyWalking.x -= size[0] / 10;
        }
      }
      remove(boy);
      add(boyWalking);
      boyRemoved = false;
    }

    // Left Movements

    if (runLeft &&
        distanceRun < ((size[0] * .7 - size[0] * .4)) &&
        contains(boyWalking)) {
      distanceRun += 5;
      boyWalking.x -= 5;
    }

    if (runLeft && distanceRun >= (size[0] * .7 - size[0] * .4)) {
      boy.x = boyWalking.x;
      print("boyWalking.x (LEFT)");
      print(boyWalking.x);
      print("boy.x(LEFT)");
      print(boy.x);
      busy = false; // Boy reached at the place
      remove(boyWalking);
      add(boy);
      distanceRun = 0;
      runLeft = false;

      currentPosition = positionReachingAfterRun;
    }

    // Right Movements

    if (runRight &&
        distanceRun < (size[0] * .7 - size[0] * .4) &&
        contains(boyWalking)) {
      distanceRun += 5;
      boyWalking.x += 5;
    }

    if (runRight && distanceRun >= (size[0] * .7 - size[0] * .4)) {
      boy.x = boyWalking.x;
      print("boyWalking.x (RIGHT)");
      print(boyWalking.x);
      print("boy.x(RIGHT)");
      print(boy.x);
      busy = false; // Boy reached at the place

      remove(boyWalking);
      add(boy);
      distanceRun = 0;
      runRight = false;

      currentPosition = positionReachingAfterRun;
    }

    // oranges
    for (var fruit in fruits) {
      fruit.position.y += 100 * dt; // adjust the speed of falling as necessary
      // if the fruit has reached the bottom of the screen, reset its position to the top
      if (fruit.position.y > size.y - size.y * .1) {
        fruit.size = Vector2(100, 100);
        fruit.position.x = 5000;
      }

      // collision CENTER
      if (fruit.position.x == size[0] * .4 && currentPosition == "CENTER") {
        if (fruit.position.y >= boy.y) {
          print("HIT CENTER");
          fruitCollected++;
          fruit.y = 0;
          fruit.x = 20000;
        }
      }

      // collision RIGHT

      if (fruit.position.x == size[0] * .7 && currentPosition == "RIGHT") {
        if (fruit.position.y >= boy.y) {
          print("HIT RIGHT");
          fruitCollected++;
          fruit.y = 0;
          fruit.x = 20000;
        }
      }

      // collision LEFT

      if (fruit.position.x == size[0] * .1 && currentPosition == "LEFT") {
        if (fruit.position.y >= boy.y) {
          print("HIT LEFT");
          fruitCollected++;
          fruit.y = 0;
          fruit.x = 20000;
        }
      }
    }
  }
}

class LeftButton extends SpriteComponent with Tappable {
  @override
  bool onTapDown(TapDownInfo info) {
    try {
      if ((currentPosition == "CENTER" || currentPosition == "RIGHT") &&
          !busy) {
        distanceRun = 0;
        boyRemoved = true;
        runLeft = true;
        busy = true;

        // New position
        currentPosition == "CENTER"
            ? positionReachingAfterRun = "LEFT"
            : positionReachingAfterRun = "CENTER";

        currentPosition = "";
        print(positionReachingAfterRun);
      }
      return super.onTapDown(info);
    } catch (e) {
      print(e);
      return false;
    }
  }
}

class RightButton extends SpriteComponent with Tappable {
  @override
  bool onTapDown(TapDownInfo info) {
    try {
      if ((currentPosition == "CENTER" || currentPosition == "LEFT") && !busy) {
        distanceRun = 0;
        boyRemoved = true;
        runRight = true;
        busy = true;

        // New position
        currentPosition == "CENTER"
            ? positionReachingAfterRun = "RIGHT"
            : positionReachingAfterRun = "CENTER";

        currentPosition = "";
        print(positionReachingAfterRun);
      }
      return super.onTapDown(info);
    } catch (e) {
      print(e);
      return false;
    }
  }
}

void leftControl() {
  if ((currentPosition == "CENTER" || currentPosition == "RIGHT") && !busy) {
    distanceRun = 0;
    boyRemoved = true;
    runLeft = true;
    busy = true;

    // New position
    currentPosition == "CENTER"
        ? positionReachingAfterRun = "LEFT"
        : positionReachingAfterRun = "CENTER";

    currentPosition = "";
    print(positionReachingAfterRun);
  }
}

void rightControl() {
  if ((currentPosition == "CENTER" || currentPosition == "LEFT") && !busy) {
    distanceRun = 0;
    boyRemoved = true;
    runRight = true;
    busy = true;

    // New position
    currentPosition == "CENTER"
        ? positionReachingAfterRun = "RIGHT"
        : positionReachingAfterRun = "CENTER";

    currentPosition = "";
    print(positionReachingAfterRun);
  }
}
