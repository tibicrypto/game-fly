class GameConfig {
  static const double gravity = 9.8;
  static const double refuelSpeed = 50.0; // Fuel units per second
  static const double fuelBurnRate = 10.0; // Fuel units per second when gliding
  static const double fuelWeightRatio = 0.8;
  
  static const double noiseFrequency = 0.05;
  static const double noiseAmplitude = 300.0;
  
  static const double windForce = -2.0;
  static const double bonusGoldMultiplier = 1.5;

  static const double worldHeight = 2000.0;
  static const double ceilingHeight = 1800.0; // Danger zone
}

enum CargoType {
  letter(name: 'Letter', weight: 10.0, reward: 100, difficulty: 'Easy'),
  food(name: 'Food', weight: 40.0, reward: 300, difficulty: 'Medium'),
  gold(name: 'Gold', weight: 100.0, reward: 1000, difficulty: 'Hard'),
  uranium(name: 'Uranium', weight: 200.0, reward: 5000, difficulty: 'Extreme');

  final String name;
  final double weight;
  final int reward;
  final String difficulty;

  const CargoType({
    required this.name,
    required this.weight,
    required this.reward,
    required this.difficulty,
  });
}

class PlaneStats {
  final double baseWeight;
  final double maxThrust;
  final double idleThrust;
  final double speed;
  final double maxFuel;

  const PlaneStats({
    required this.baseWeight,
    required this.maxThrust,
    required this.idleThrust,
    required this.speed,
    required this.maxFuel,
  });

  static const PlaneStats standard = PlaneStats(
    baseWeight: 100.0,
    maxThrust: 600.0, // Needs to overcome weight + gravity
    idleThrust: 50.0,
    speed: 200.0,
    maxFuel: 100.0,
  );
}
