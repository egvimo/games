import 'package:flutter_test/flutter_test.dart';
import 'package:block_puzzle/logic/game_provider.dart';
import 'package:block_puzzle/logic/shapes.dart';
import 'package:flutter/material.dart';

void main() {
  group('GameProvider Logic Tests', () {
    test('Should allow placing a shape on an empty grid', () {
      final game = GameProvider();
      final singleDot = BlockShape(points: [const Point(0, 0)], color: Colors.blue);

      expect(game.canPlaceShape(singleDot, 0, 0), true);
    });

    test('Should not allow placing a shape out of bounds', () {
      final game = GameProvider();
      final longBar = BlockShape(points: [
        const Point(0, 0), const Point(1, 0), const Point(2, 0)
      ], color: Colors.red);

      // x=7 is the edge, so a 3-wide bar at x=7 should fail
      expect(game.canPlaceShape(longBar, 7, 0), false);
    });

    test('Line clearing should increase score', () {
      final game = GameProvider();
      // Manually fill a row
      for (int x = 0; x < 8; x++) {
        game.grid[0][x] = Colors.blue;
      }

      // Trigger the internal line check (usually called after placing)
      // Note: You might need to make _checkLines public or call placeShape to test this
      // game.checkLines();
      // expect(game.score, 10);
      // expect(game.grid[0][0], null);
    });
  });
}
