import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';

/// Shows [child] with animation when keyboard is NOT visible.
/// If keyboard is visible, returns child directly to avoid jank.
class ConditionalAnimation extends StatelessWidget {
  final Widget child;
  final Duration? delay;
  final Duration? duration;
  final AnimationType type;

  const ConditionalAnimation({
    Key? key,
    required this.child,
    this.delay,
    this.duration,
    this.type = AnimationType.fadeUp,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final keyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;
    if (keyboardVisible) return child;

    switch (type) {
      case AnimationType.fadeRight:
        return FadeInRight(
          child: child,
          delay: delay ?? Duration.zero,
          duration: duration ?? const Duration(milliseconds: 600),
        );

      case AnimationType.fadeUp:
        return FadeInUp(
          child: child,
          delay: delay ?? Duration.zero,
          duration: duration ?? const Duration(milliseconds: 600),
        );
    }
  }
}

enum AnimationType { fadeUp, fadeRight }
