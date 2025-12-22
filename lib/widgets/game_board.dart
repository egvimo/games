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

  Widget _buildCell(
    BuildContext context,
    int x,
    int y,
    double size,
    Color? actualColor,
    GameProvider gameProvider,
  ) {
    return DragTarget<Map<String, dynamic>>(
      onWillAcceptWithDetails: (details) {
        final data = details.data;
        final BlockShape shape = data['shape'];

        final pickup = gameProvider.pickupOffset ?? const Point(0, 0);
        final anchorX = x - pickup.x;
        final anchorY = y - pickup.y;

        Provider.of<GameProvider>(context, listen: false)
            .updateHover(anchorX, anchorY);
        return gameProvider.canPlaceShape(shape, anchorX, anchorY);
      },
      onAcceptWithDetails: (details) {
        final BlockShape shape = details.data['shape'];
        final int index = details.data['index'];

        final pickup = gameProvider.pickupOffset ?? const Point(0, 0);
        final anchorX = x - pickup.x;
        final anchorY = y - pickup.y;

        Provider.of<GameProvider>(context, listen: false)
            .placeShape(shape, anchorX, anchorY, index);
      },
      builder: (context, candidateData, rejectedData) {
        Color displayColor = actualColor ?? Colors.grey[800]!;
        int highlightState = gameProvider.getHighlightState(x, y);

        bool isClearing = gameProvider.clearingCells.contains(Point(x, y));

        // Base (clearing) block
        Widget cellChild = Container(
          margin: const EdgeInsets.all(
              2), // <-- use margin instead of outer padding
          decoration: BoxDecoration(
            color: isClearing ? Colors.white : displayColor,
            borderRadius: BorderRadius.circular(4),
            boxShadow: isClearing
                ? [
                    BoxShadow(
                      color: Colors.white.withValues(alpha: 0.8),
                      blurRadius: 10,
                      spreadRadius: 2,
                    )
                  ]
                : null,
          ),
        );

        // Hover highlight (valid/invalid)
        if (!isClearing) {
          if (highlightState == 1) {
            displayColor = Colors.white.withValues(alpha: 0.6);
          } else if (highlightState == 2) {
            displayColor = Colors.redAccent.withValues(alpha: 0.6);
          }
          cellChild = Container(
            margin: const EdgeInsets.all(2), // <-- same margin here
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
          // IMPORTANT: no padding here anymore
          child: cellChild,
        );
      },
    );
  }
}
