import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:fast_noise/fast_noise.dart';
import '../config.dart';

class Terrain extends PositionComponent {
  final noise = PerlinNoise(frequency: GameConfig.noiseFrequency, octaves: 3);

  // We render a chunk of terrain around the player or just infinite scrolling?
  // For scrolling, we usually generate points based on camera X.
  
  double currentX = 0;
  List<Offset> points = [];
  final double segmentWidth = 10.0;
  
  Terrain() : super(priority: -1); // Behind plane

  double getHeightAt(double x) {
    // Noise returns -1 to 1. We map it to 0 -> Amplitude.
    // Also we want it to be ground, so Bottom of screen - Height.
    // Code says: groundHeight = Noise * Amplitude.
    // Plane checks: if plane.y <= groundHeight (Assuming Y grows up? No, Y grows down in Flame).
    // Usually Y=0 is top. Customarily ground is at bottom, high Y value.
    // Let's assume standard Flame coordinates: (0,0) top-left.
    // Ground should be at Y = WorldHeight - NoiseHeight.
    
    double n = noise.getSingleNoise(x, 0.0); // 2D noise with Y=0
    return GameConfig.worldHeight - (n.abs() * GameConfig.noiseAmplitude); 
    // Using abs() to make hills, or just map (-1,1).
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    if (points.isEmpty) return;

    final paint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(points.first.dx, GameConfig.worldHeight + 500); // Bottom left (deep)
    
    for (var p in points) {
      path.lineTo(p.dx, p.dy);
    }
    
    path.lineTo(points.last.dx, GameConfig.worldHeight + 500); // Bottom right
    path.close();

    canvas.drawPath(path, paint);
    
    // Draw Ceiling (Clouds)
    final cloudPaint = Paint()..color = Colors.grey.withOpacity(0.5);
    canvas.drawRect(Rect.fromLTRB(points.first.dx, 0, points.last.dx, GameConfig.worldHeight - GameConfig.ceilingHeight), cloudPaint);
  }

  void updateSegments(double cameraX, double viewportWidth) {
    points.clear();
    // Generate points covering camera view
    double startX = cameraX - 100;
    double endX = cameraX + viewportWidth + 100;

    for (double x = startX; x <= endX; x += segmentWidth) {
      points.add(Offset(x, getHeightAt(x)));
    }
  }
}
