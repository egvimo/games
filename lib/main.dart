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
      appBar: AppBar(
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        title: Row(
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 16),
              child: Text(
                'BLOCK PUZZLE',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const Spacer(),
            Text(
              'Score: ${game.score}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.amber,
              ),
            ),
            const Spacer(),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Restart Game',
            onPressed: game.restartGame,
          ),
        ],
      ),
      body: Center(
        child: SizedBox(
          width: contentWidth,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (game.isGameOver)
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 20),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        "GAME OVER",
                        style: TextStyle(
                            fontSize: 30, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: game.restartGame,
                        icon: const Icon(Icons.refresh),
                        label: const Text("Restart"),
                      ),
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
                    if (shape == null) {
                      return SizedBox(width: cellSize * 2); // Empty placeholder
                    }

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
