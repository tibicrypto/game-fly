import 'package:flutter/material.dart';
import '../game_instance.dart';

class GameHud extends StatelessWidget {
  final SkyHaulerGame game;

  const GameHud({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<double>(
      stream: Stream.periodic(const Duration(milliseconds: 100), (_) => game.plane.fuel),
      builder: (context, snapshot) {
        return Positioned(
          top: 20,
          left: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("FUEL: ${game.plane.fuel.toStringAsFixed(1)} / ${game.plane.stats.maxFuel}",
                  style: const TextStyle(color: Colors.white, fontSize: 16)),
              Text("ALTITUDE: ${(2000 - game.plane.y).toStringAsFixed(0)}",
                  style: const TextStyle(color: Colors.white, fontSize: 16)),
              Text("CARGO: ${game.plane.currentCargo?.name ?? 'None'}",
                  style: const TextStyle(color: Colors.white, fontSize: 16)),
            ],
          ),
        );
      }
    );
  }
}
