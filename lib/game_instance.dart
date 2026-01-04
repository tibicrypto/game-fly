import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'components/plane.dart' as components;
import 'components/terrain.dart';
import 'components/cargo.dart';
import 'config.dart';

class SkyHaulerGame extends FlameGame with MultiTouchDragDetector, ScaleDetector {
  late components.Plane plane;
  late Terrain terrain;
  
  // Game State
  bool isGameOver = false;
  double score = 0;

  @override
  Future<void> onLoad() async {
    // Setup World
    terrain = Terrain();
    add(terrain);

    // Setup Player
    plane = components.Plane(
      stats: PlaneStats.standard,
      currentCargo: CargoType.gold, // Default start with gold for testing
    );
    plane.position = Vector2(100, 500);
    add(plane);
    
    // Add visual cargo attachment
    if (plane.currentCargo != null) {
        add(Cargo(type: plane.currentCargo!)..position = plane.position + Vector2(15, 20));
        // Note: Realistically should be a child of plane or update position in update loop
    }

    camera.viewfinder.anchor = Anchor.centerLeft;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (isGameOver) return;

    // Update Camera to follow plane X
    camera.viewfinder.position = Vector2(plane.position.x - 100, 0); // Keep Y fixed or follow?
    // "Camera follows plane" usually. But vertical following might be needed if map is high.
    // Let's just follow X for now and clamp Y or follow Y loosely.
    camera.viewfinder.position = Vector2(plane.position.x - 100, plane.position.y - 300);

    // Terrain Update
    terrain.updateSegments(camera.viewfinder.position.x, size.x);

    // Dynamic Cargo Position Update (if separate component)
    // Quick fix: Re-add cargo if changed or update its position
    // For simplicity in this generated code, we assume visual cargo is just implied or we'd need a reference.
    
    // Collision Detection (Manual simple check for terrain height)
    double groundY = terrain.getHeightAt(plane.x);
    if (plane.y >= groundY) {
      gameOver("Crashed into terrain!");
    }
    
    // Ceiling check
    if (plane.y < GameConfig.worldHeight - GameConfig.ceilingHeight) {
      // Logic says "Lightning strike -> Engine Failure -> Fall".
      // For now, simplier: Push down or Damage.
      plane.verticalVelocity = 300; // Knock down
    }
  }

  // INPUT HANDLING
  // We need to detect 2 fingers holding.
  
  @override
  void onScaleUpdate(ScaleUpdateInfo info) {
    // info.pointerCount is the number of pointers interacting
    if (info.pointerCount == 2) {
      plane.isRefueling = true;
    } else {
      plane.isRefueling = false;
    }
    
    // Swipe down detection for Jettison?
    // ScaleDetector/DragDetector might conflict.
    // Simple logic: If 1 finger and drag delta Y is positive large -> Jettison.
    if (info.pointerCount == 1 && info.delta.global.y > 10) {
      plane.jettisonCargo();
    }
  }
  
  @override
  void onScaleEnd(ScaleEndInfo info) {
    plane.isRefueling = false;
  }

  void gameOver(String reason) {
    isGameOver = true;
    print("GAME OVER: $reason");
    // Show UI overlay logic here
    pauseEngine();
  }
}
