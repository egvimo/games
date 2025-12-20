import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../logic/game_provider.dart'; // Import Provider
import '../logic/shapes.dart';

class DraggableShapeItem extends StatelessWidget {
  final BlockShape shape;
  final int shapeIndex;
  final double cellSize;

  const DraggableShapeItem({
    super.key,
    required this.shape,
    required this.shapeIndex,
    required this.cellSize,
  });

  @override
  Widget build(BuildContext context) {
    int w = 0;
    int h = 0;
    for (var p in shape.points) {
      if (p.x > w) w = p.x;
      if (p.y > h) h = p.y;
    }

    Widget shapeWidget = SizedBox(
      width: (w + 1) * cellSize,
      height: (h + 1) * cellSize,
      child: Stack(
        children: shape.points.map((p) {
          return Positioned(
            left: p.x * cellSize,
            top: p.y * cellSize,
            child: Container(
              width: cellSize - 2,
              height: cellSize - 2,
              decoration: BoxDecoration(
                color: shape.color,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          );
        }).toList(),
      ),
    );

    return Draggable<Map<String, dynamic>>(
      data: {'shape': shape, 'index': shapeIndex},
      // --- NEW: Notify provider on drag start/cancel ---
      onDragStarted: () {
        Provider.of<GameProvider>(context, listen: false).startDragging(shape);
      },
      onDraggableCanceled: (_, __) {
        // If dropped outside the board, reset state
        Provider.of<GameProvider>(context, listen: false).clearHoverState();
      },
      // --------------------------------------------------
      feedback: Opacity(opacity: 0.8, child: shapeWidget),
      childWhenDragging: Opacity(opacity: 0.3, child: shapeWidget),
      child: shapeWidget,
    );
  }
}
