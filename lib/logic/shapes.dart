import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

// Represents a single coordinate
class Point extends Equatable {
  final int x;
  final int y;
  const Point(this.x, this.y);

  @override
  List<Object?> get props => [x, y];
}

// Definition of a block shape
class BlockShape {
  final List<Point> points; // Relative points, e.g., (0,0), (0,1)...
  final Color color;

  BlockShape({required this.points, required this.color});
}

class ShapeRepository {
  static final List<BlockShape> allShapes = [
    // I ⬛⬛⬛⬛
    BlockShape(
      points: const [
        Point(0, 0),
        Point(1, 0),
        Point(2, 0),
        Point(3, 0),
      ],
      color: Colors.cyan,
    ),

    // O ⬛⬛
    //   ⬛⬛
    BlockShape(
      points: const [
        Point(0, 0),
        Point(1, 0),
        Point(0, 1),
        Point(1, 1),
      ],
      color: Colors.yellow,
    ),

    // T ⬛⬛⬛
    //     ⬛
    BlockShape(
      points: const [
        Point(0, 0),
        Point(1, 0),
        Point(2, 0),
        Point(1, 1),
      ],
      color: Colors.purple,
    ),

    // S   ⬛⬛
    //   ⬛⬛
    BlockShape(
      points: const [
        Point(1, 0),
        Point(2, 0),
        Point(0, 1),
        Point(1, 1),
      ],
      color: Colors.green,
    ),

    // Z ⬛⬛
    //     ⬛⬛
    BlockShape(
      points: const [
        Point(0, 0),
        Point(1, 0),
        Point(1, 1),
        Point(2, 1),
      ],
      color: Colors.red,
    ),

    // J ⬛
    //   ⬛⬛⬛
    BlockShape(
      points: const [
        Point(0, 0),
        Point(0, 1),
        Point(1, 1),
        Point(2, 1),
      ],
      color: Colors.blue,
    ),

    // L     ⬛
    //   ⬛⬛⬛
    BlockShape(
      points: const [
        Point(2, 0),
        Point(0, 1),
        Point(1, 1),
        Point(2, 1),
      ],
      color: Colors.orange,
    ),
  ];
}
