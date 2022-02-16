import 'dart:ui' show Color;

import 'package:flutter/gestures.dart';

class ActionModel {
  final String label;
  final Color color;
  final GestureTapCallback function;

  ActionModel({
    required this.label,
    required this.color,
    required this.function,
  });
}
