import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../logic/game_provider.dart';
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

    // Render blocks with the SAME inset/size as board cells (margin = 2px -> visible = cellSize-4)
    final shapeVisual = SizedBox(
      width: (w + 1) * cellSize,
      height: (h + 1) * cellSize,
      child: Stack(
        children: shape.points.map((p) {
          return Positioned(
            left: p.x * cellSize + 2, // match board inset
            top: p.y * cellSize + 2, // match board inset
            child: Container(
              width: cellSize - 4, // match board visible size
              height: cellSize - 4, // match board visible size
              decoration: BoxDecoration(
                color: shape.color,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          );
        }).toList(),
      ),
    );

    // RELIABLE capture of the press using Listener (fires before Draggable's recognizer)
    final pressAwareShape = Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: (event) {
        final gp = Provider.of<GameProvider>(context, listen: false);
        final local = event.localPosition;

        // 1) Pixel offset: used for feedback anchoring so the pressed pixel stays under the cursor
        gp.setPickupPixelOffset(local);

        // 2) Pick the *nearest occupied block* (avoid gaps that cause TL bias)
        Point nearest = shape.points.first;
        double best = double.infinity;
        for (final p in shape.points) {
          // Centers are unaffected by the 2px inset:
          // (p.x*cellSize + 2) + (cellSize-4)/2 == p.x*cellSize + cellSize/2
          final cx = (p.x + 0.5) * cellSize;
          final cy = (p.y + 0.5) * cellSize;
          final dx = local.dx - cx;
          final dy = local.dy - cy;
          final d2 = dx * dx + dy * dy;
          if (d2 < best) {
            best = d2;
            nearest = Point(p.x, p.y);
          }
        }
        gp.setPickupOffset(nearest);
      },
      child: shapeVisual,
    );

    return Consumer<GameProvider>(
      builder: (context, gp, _) {
        final off = gp.pickupPixelOffset ?? Offset.zero;

        return Draggable<Map<String, dynamic>>(
          data: {'shape': shape, 'index': shapeIndex},

          // Anchor at child's top-left, then shift feedback so pressed pixel stays under pointer
          dragAnchorStrategy: childDragAnchorStrategy,
          feedbackOffset: Offset(-off.dx, -off.dy),

          onDragStarted: () {
            // Start dragging, but DO NOT overwrite offsets here.
            Provider.of<GameProvider>(context, listen: false)
                .startDragging(shape);
          },
          onDraggableCanceled: (_, __) {
            Provider.of<GameProvider>(context, listen: false).clearHoverState();
          },

          feedback: Opacity(opacity: 0.8, child: shapeVisual),
          childWhenDragging: Opacity(opacity: 0.3, child: shapeVisual),
          child: pressAwareShape,
        );
      },
    );
  }
}
