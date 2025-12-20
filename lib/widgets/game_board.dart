import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../logic/game_provider.dart';
import '../logic/shapes.dart';

class GameBoard extends StatelessWidget {
  const GameBoard({super.key});

  @override
  Widget build(BuildContext context) {
    // We don't listen here anymore, individual cells will listen
    Provider.of<GameProvider>(context, listen: false);

    double width = MediaQuery.of(context).size.width;
    if (width > 500) width = 500;
    double cellSize = (width - 32) / 8;

    return Center(
      child: Container(
        width: cellSize * 8,
        height: cellSize * 8,
        color: Colors.grey[900],
        child: Stack(
          children: [
            ...List.generate(8, (y) {
              return List.generate(8, (x) {
                // Wrap each cell in a Consumer so only affected cells rebuild
                return Positioned(
                  left: x * cellSize,
                  top: y * cellSize,
                  child: Consumer<GameProvider>(
                      builder: (ctx, gameProvider, child) {
                    return _buildCell(ctx, x, y, cellSize,
                        gameProvider.grid[y][x], gameProvider);
                  }),
                );
              });
            }).expand((i) => i),
          ],
        ),
      ),
    );
  }

  // Pass the gameProvider in directly
  Widget _buildCell(BuildContext context, int x, int y, double size,
      Color? actualColor, GameProvider gameProvider) {
    return DragTarget<Map<String, dynamic>>(onWillAccept: (data) {
      if (data == null) return false;
      BlockShape shape = data['shape'];

      // --- NEW: Tell provider where we are hovering ---
      // We use listen:false because onWillAccept runs frequently outside the build cycle
      Provider.of<GameProvider>(context, listen: false).updateHover(x, y);
      // -------------------------------------------------

      return gameProvider.canPlaceShape(shape, x, y);
    },
        // Fix from previous turn: use onAcceptWithDetails
        onAcceptWithDetails: (details) {
      BlockShape shape = details.data['shape'];
      int index = details.data['index'];
      // placeShape now handles clearing hover state on success
      Provider.of<GameProvider>(context, listen: false)
          .placeShape(shape, x, y, index);
    }, builder: (context, candidateData, rejectedData) {
      Color displayColor = actualColor ?? Colors.grey[800]!;
      int highlightState = gameProvider.getHighlightState(x, y);

      // --- NEW: Animation logic ---
      bool isClearing = gameProvider.clearingCells.contains(Point(x, y));

      Widget cellChild = Container(
        decoration: BoxDecoration(
          color: isClearing ? Colors.white : displayColor,
          borderRadius: BorderRadius.circular(4),
          // Add a glow effect during clearing
          boxShadow: isClearing
              ? [
                  BoxShadow(
                      color: Colors.white.withOpacity(0.8),
                      blurRadius: 10,
                      spreadRadius: 2)
                ]
              : null,
        ),
      );

      // Apply highlight logic for dragging
      if (!isClearing) {
        if (highlightState == 1) {
          displayColor = Colors.white.withOpacity(0.6);
        } else if (highlightState == 2) {
          displayColor = Colors.redAccent.withOpacity(0.6);
        }

        cellChild = Container(
          decoration: BoxDecoration(
            color: displayColor,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }

      return AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: size,
        height: size,
        padding: const EdgeInsets.all(2),
        child: cellChild,
      );
    });
  }
}
