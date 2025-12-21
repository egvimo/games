import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'shapes.dart';

class GameProvider extends ChangeNotifier {
  static const int gridSize = 8;
  List<List<Color?>> grid =
      List.generate(gridSize, (_) => List.filled(gridSize, null));
  List<BlockShape?> availableShapes = [];
  int score = 0;
  bool isGameOver = false;

  Set<Point> clearingCells = {};

  // --- NEW: Hover State Tracking ---
  Point? _hoverAnchorCell;
  BlockShape? _draggingShape;
  bool _isHoverValid = false;

  GameProvider() {
    _spawnShapes();
  }

  // --- NEW: Methods to update Hover State ---

  // Called when dragging starts
  void startDragging(BlockShape shape) {
    _draggingShape = shape;
    notifyListeners();
  }

  // Called constantly while moving over the grid
  void updateHover(int x, int y) {
    // Only update if changed to prevent too many rebuilds
    if (_hoverAnchorCell?.x == x && _hoverAnchorCell?.y == y) return;

    _hoverAnchorCell = Point(x, y);
    // Check if the shape fits at this new anchor point
    if (_draggingShape != null) {
      _isHoverValid = canPlaceShape(_draggingShape!, x, y);
    }
    notifyListeners();
  }

  // Called when drag ends (dropped or cancelled)
  void clearHoverState() {
    _draggingShape = null;
    _hoverAnchorCell = null;
    _isHoverValid = false;
    notifyListeners();
  }

  // Helper for the UI: Should cell (x,y) be highlighted?
  // Returns 0 for no highlight, 1 for valid highlight (white), 2 for invalid (red)
  int getHighlightState(int cellX, int cellY) {
    if (_draggingShape == null || _hoverAnchorCell == null) return 0;

    // Check if this specific cell (cellX, cellY) is part of the shape relative to the anchor
    for (var point in _draggingShape!.points) {
      if (_hoverAnchorCell!.x + point.x == cellX &&
          _hoverAnchorCell!.y + point.y == cellY) {
        // It is part of the shape projection. Return color based on validity.
        return _isHoverValid ? 1 : 2;
      }
    }
    return 0;
  }
  // ------------------------------------

  void restartGame() {
    grid = List.generate(gridSize, (_) => List.filled(gridSize, null));
    score = 0;
    isGameOver = false;
    _spawnShapes();
    clearHoverState(); // Ensure clean slate
    notifyListeners();
  }

  List<Point> rotateClockwise(List<Point> points) {
    // Rotate around origin (0,0)
    final rotated = points.map((p) => Point(p.y, -p.x)).toList();

    return _normalize(rotated);
  }

  List<Point> _normalize(List<Point> points) {
    final minX = points.map((p) => p.x).reduce((a, b) => a < b ? a : b);
    final minY = points.map((p) => p.y).reduce((a, b) => a < b ? a : b);

    return points.map((p) => Point(p.x - minX, p.y - minY)).toList();
  }

  BlockShape rotatedShape(BlockShape shape, int rotations) {
    var points = shape.points.map((p) => Point(p.x, p.y)).toList();

    for (var i = 0; i < rotations; i++) {
      points = rotateClockwise(points);
    }

    return BlockShape(
      points: points,
      color: shape.color,
    );
  }

  // ... existing _spawnShapes ...
  void _spawnShapes() {
    final random = Random();

    availableShapes = List.generate(3, (_) {
      final base = ShapeRepository
          .allShapes[random.nextInt(ShapeRepository.allShapes.length)];

      final rotations = random.nextInt(4); // 0,1,2,3

      return rotatedShape(base, rotations);
    });

    notifyListeners();
  }

  // ... existing canPlaceShape ...
  bool canPlaceShape(BlockShape shape, int startX, int startY) {
    for (var point in shape.points) {
      int targetX = startX + point.x;
      int targetY = startY + point.y;

      if (targetX < 0 ||
          targetX >= gridSize ||
          targetY < 0 ||
          targetY >= gridSize) {
        return false;
      }
      if (grid[targetY][targetX] != null) {
        return false;
      }
    }
    return true;
  }

  void _checkLines() {
    List<int> rowsToClear = [];
    List<int> colsToClear = [];

    for (int y = 0; y < gridSize; y++) {
      if (grid[y].every((cell) => cell != null)) rowsToClear.add(y);
    }

    for (int x = 0; x < gridSize; x++) {
      bool colFull = true;
      for (int y = 0; y < gridSize; y++) {
        if (grid[y][x] == null) {
          colFull = false;
          break;
        }
      }
      if (colFull) colsToClear.add(x);
    }

    if (rowsToClear.isNotEmpty || colsToClear.isNotEmpty) {
      // 1. Identify which points are clearing
      Set<Point> newClearingPoints = {};
      for (int y in rowsToClear) {
        for (int x = 0; x < gridSize; x++) {
          newClearingPoints.add(Point(x, y));
        }
      }
      for (int x in colsToClear) {
        for (int y = 0; y < gridSize; y++) {
          newClearingPoints.add(Point(x, y));
        }
      }

      // 2. Trigger Animation State
      clearingCells = newClearingPoints;
      score += (rowsToClear.length + colsToClear.length) * 10;
      notifyListeners();

      // 3. Wait for animation, then actually remove the blocks
      Timer(const Duration(milliseconds: 300), () {
        for (var p in clearingCells) {
          grid[p.y][p.x] = null;
        }
        clearingCells.clear();
        _checkGameOver(); // Re-check after grid is actually empty
        notifyListeners();
      });
    }
  }

  // Update placeShape slightly to ensure _checkGameOver isn't called too early
  void placeShape(BlockShape shape, int startX, int startY, int shapeIndex) {
    if (!canPlaceShape(shape, startX, startY)) {
      clearHoverState();
      return;
    }

    for (var point in shape.points) {
      grid[startY + point.y][startX + point.x] = shape.color;
    }

    availableShapes[shapeIndex] = null;
    _checkLines(); // This now handles scoring and clearing

    if (availableShapes.every((element) => element == null)) {
      _spawnShapes();
    }

    _checkGameOver();

    clearHoverState();
    notifyListeners();
  }

  void _checkGameOver() {
    for (final shape in availableShapes) {
      if (shape == null) continue;

      for (int y = 0; y < gridSize; y++) {
        for (int x = 0; x < gridSize; x++) {
          if (canPlaceShape(shape, x, y)) {
            isGameOver = false;
            return;
          }
        }
      }
    }

    isGameOver = true;
  }
}
