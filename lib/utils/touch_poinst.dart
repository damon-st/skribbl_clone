import 'package:flutter/cupertino.dart';

class TouchPoinst {
  Paint paint;
  Offset points;
  TouchPoinst({required this.paint, required this.points});

  Map<String, dynamic> toJson() {
    return {
      "points": {
        "dx": "${points.dx}",
        "dy": "${points.dy}",
      },
    };
  }
}
