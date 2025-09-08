import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

// Utility class for handling animations

class AnimationUtils {
  static Future<void> animateSwap(StateController<double> animationController) async {
    const animationDuration = Duration(milliseconds: 600);

    animationController.state = 0.0;

    final completer = Completer<void>();
    final startTime = DateTime.now().millisecondsSinceEpoch;
    Timer? timer;

    timer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      final elapsed = DateTime.now().millisecondsSinceEpoch - startTime;
      final progress = elapsed / animationDuration.inMilliseconds;

      if (progress >= 1.0) {
        animationController.state = 1.0;
        timer.cancel();
        if (!completer.isCompleted) completer.complete();
      } else {
        animationController.state = progress;
      }
    });

    await completer.future;
    animationController.state = 0.0;
  }
}