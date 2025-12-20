import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'logic/game_provider.dart';
import 'widgets/game_board.dart';
import 'widgets/draggable_shape.dart';

void main() {
  runApp(const BlockPuzzleApp());
}

class BlockPuzzleApp extends StatelessWidget {
  const BlockPuzzleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GameProvider()),
      ],
      child: MaterialApp(
        title: 'Block Puzzle Game',
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: Colors.black,
        ),
        home: const GameScreen(),
      ),
    );
  }
}

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final game = Provider.of<GameProvider>(context);

    // Responsive helper
    double screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth > 500) screenWidth = 500;
    double contentWidth = screenWidth > 500 ? 500 : screenWidth;
    double cellSize = (contentWidth - 60) / 8; // Smaller for the tray
    double gridCellSize = (screenWidth - 32) / 8;

    return Scaffold(
      body: Center(
        child: SizedBox(
          width: contentWidth,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Header / Score
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("BLOCK PUZZLE",
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold)),
                    Text("Score: ${game.score}",
                        style:
                            const TextStyle(fontSize: 20, color: Colors.amber)),
                  ],
                ),
              ),

              if (game.isGameOver)
                Container(
                  padding: const EdgeInsets.all(20),
                  color: Colors.red.withValues(alpha: 0.8),
                  child: Column(
                    children: [
                      const Text("GAME OVER",
                          style: TextStyle(
                              fontSize: 30, fontWeight: FontWeight.bold)),
                      ElevatedButton(
                          onPressed: game.restartGame,
                          child: const Text("Restart"))
                    ],
                  ),
                ),

              const SizedBox(height: 20),

              // The Grid
              const GameBoard(),

              const Spacer(),

              // The Tray (Available Shapes)
              Container(
                height: 180,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: List.generate(3, (index) {
                    final shape = game.availableShapes.length > index
                        ? game.availableShapes[index]
                        : null;
                    if (shape == null)
                      return SizedBox(width: cellSize * 2); // Empty placeholder

                    return DraggableShapeItem(
                      shape: shape,
                      shapeIndex: index,
                      cellSize: gridCellSize,
                    );
                  }),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
