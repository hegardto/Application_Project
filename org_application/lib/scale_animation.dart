import 'dart:async';

import 'Bool.dart';
import 'package:flutter/cupertino.dart';

class ScaledAnimation extends StatefulWidget {
  Key key;
  Widget child;
  Bool hasPlayed;
  int delay_milliseconds = 0;

  ScaledAnimation(
      {@required this.child,
      this.delay_milliseconds,
      @required this.key,
      this.hasPlayed});

  @override
  ScaledAnimationState createState() {
    return ScaledAnimationState(
        child: child, delay: delay_milliseconds, hasPlayed: hasPlayed);
  }
}

class ScaledAnimationState extends State<ScaledAnimation>
    with SingleTickerProviderStateMixin {
  AnimationController controller;
  Animation<double> animation;
  Widget child;
  int delay;
  Bool hasPlayed;

  ScaledAnimationState({@required this.child, this.delay, this.hasPlayed});

  @override
  initState() {
    super.initState();
    controller = AnimationController(
        duration: const Duration(milliseconds: 600), vsync: this, value: 0);
    animation = CurvedAnimation(parent: controller, curve: Curves.bounceOut);
    Timer(Duration(milliseconds: delay), () {
      playAnimation();
    });
  }

  @override
  dispose() {
    hasPlayed.setValue(true);
    controller.dispose();
    super.dispose();
  }

  void playAnimation() async {
    if (!hasPlayed.value) {
      controller.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!hasPlayed.value) {
      return ScaleTransition(
          scale: animation, alignment: Alignment.center, child: child);
    } else
      return child;
  }
}
