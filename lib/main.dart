import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'game_instance.dart';
import 'ui/hud.dart';

void main() {
  runApp(const MaterialApp(
    home: SkyHaulerApp(),
  ));
}

class SkyHaulerApp extends StatelessWidget {
  const SkyHaulerApp({super.key});

  @override
  Widget build(BuildContext context) {
    final game = SkyHaulerGame();
    return Scaffold(
      body: Stack(
        children: [
          GameWidget(game: game),
          GameHud(game: game),
        ],
      ),
    );
  }
}
