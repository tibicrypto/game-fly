import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../config.dart';

class Cargo extends PositionComponent {
  final CargoType type;

  Cargo({required this.type}) : super(size: Vector2(30, 20), anchor: Anchor.topCenter);

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final paint = Paint()..color;
    
    switch(type) {
      case CargoType.letter: paint.color = Colors.white; break;
      case CargoType.food: paint.color = Colors.brown; break;
      case CargoType.gold: paint.color = Colors.yellow; break;
      case CargoType.uranium: paint.color = Colors.greenAccent; break;
    }

    canvas.drawRect(size.toRect(), paint);
    
    // Draw label
    // Simplified, usually use TextComponent
  }
}
