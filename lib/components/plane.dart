import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../config.dart';

class Plane extends PositionComponent {
  double fuel;
  double verticalVelocity = 0;
  final PlaneStats stats;
  bool isRefueling = false;
  
  // Current attached cargo
  CargoType? currentCargo;

  Plane({
    required this.stats,
    this.currentCargo,
  }) : fuel = stats.maxFuel, super(size: Vector2(60, 40), anchor: Anchor.center);

  double get totalWeight {
    double cargoWeight = currentCargo?.weight ?? 0;
    // Jettisoned cargo has 0 weight (handled by setting currentCargo to null)
    return stats.baseWeight + cargoWeight + (fuel * GameConfig.fuelWeightRatio);
  }

  void jettisonCargo() {
    currentCargo = null;
  }

  @override
  void update(double dt) {
    super.update(dt);

    // 1. Input & Fuel Logic
    double currentThrust = stats.idleThrust;

    if (isRefueling) {
      // Refueling logic
      if (fuel < stats.maxFuel) {
        fuel += GameConfig.refuelSpeed * dt;
        if (fuel > stats.maxFuel) fuel = stats.maxFuel;
      }
      currentThrust = stats.maxThrust;
    } else {
      // Burn fuel
      if (fuel > 0) {
        fuel -= GameConfig.fuelBurnRate * dt;
        if (fuel < 0) fuel = 0;
      }
    }

    // If out of fuel, thrust is zero? Or just idle?
    // Doc says: "Plane glides... but if out of fuel falls free".
    // Let's say if fuel <= 0, engine stops completely (0 thrust).
    if (fuel <= 0) {
      currentThrust = 0;
    }

    // 2. Physics (Lift - Gravity)
    // F = ma => a = F/m
    // Net Force = Thrust - Weight (simplified for vertical) using Gravity as acceleration
    
    // In this game model described:
    // verticalVelocity = (Thrust - Weight) * Gravity factor? 
    // The doc says: verticalVelocity = (plane.thrust - totalWeight) * CONFIG.gravity;
    // Caution: If Thrust < TotalWeight, velocity becomes negative (falling).
    // This formula seems to treat 'thrust' as a force counteracting weight directly.
    
    double liftForce = currentThrust;
    double weightForce = totalWeight;
    
    // Scale factors to make the game feel right usually needed, but following pseudocode:
    // We add acceleration to velocity.
    // The pseudocode implies setting velocity directly? 
    // "plane.y += verticalVelocity * deltaTime" -> yes it is velocity.
    
    // Let's interpret the pseudocode "verticalVelocity = ..." as acceleration calculation or target velocity?
    // "verticalVelocity = (plane.thrust - totalWeight) * CONFIG.gravity" 
    // If thrust (600) > weight (100), val is 500 * 9.8 = 4900. High!
    // Might need scaling. Let's stick to the logic but add a time factor for acceleration if we want smooth movement,
    // OR just use it as instantaneous velocity as per "Pseudo-Code".
    // However, usually physics uses velocity += acceleration * dt.
    // The doc's pseudocode sets velocity directly based on forces. This acts like "terminal velocity" logic per frame.
    // We'll follow the doc's style for the specific "Game Feel" requested, but maybe scale it down.
    
    // Let's use a damping factor to make it controllable.
    double netForce = liftForce - weightForce;
    
    // Applying gravity scaling from config
    // Actually, usually Gravity is a constant downward acceleration.
    // Here it's a multiplier.
    
    // Let's try: Velocity = CurrentVelocity + (Force * dt)
    // But adhering to the doc:
    verticalVelocity = (netForce * 0.01) * GameConfig.gravity; 
    // * 0.01 to tame the values since 600 - 100 = 500 is huge.
    
    // Update Position
    // Y is positive downwards in Flame.
    // If verticalVelocity is positive (Thrust > Weight), we want to go UP (Negative Y).
    // So we subtract.
    
    y -= verticalVelocity * dt;
    // auto-forward movement handled by camera or world moving, but here we can move x too.
    x += stats.speed * dt;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    // Draw Plane
    final paint = Paint()..color = Colors.blue;
    final path = Path();
    path.moveTo(size.x, size.y / 2);
    path.lineTo(0, 0);
    path.lineTo(0, size.y);
    path.close();
    canvas.drawPath(path, paint);

    // Draw Thruster if refueling
    if (isRefueling && fuel > 0) {
      final firePaint = Paint()..color = Colors.orange;
      canvas.drawRect(Rect.fromLTWH(-20, size.y / 2 - 5, 20, 10), firePaint);
    }
  }
}
