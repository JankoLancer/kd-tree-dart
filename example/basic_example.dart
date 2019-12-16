import 'dart:math';

import 'package:kdtree/kdtree.dart';

void runBasicExample() {
  var points = [
    {'x': 1, 'y': 2},
    {'x': 3, 'y': 4},
    {'x': 5, 'y': 6},
    {'x': 7, 'y': 8}
  ];

  var distance = (a, b) {
    return pow(a['x'] - b['x'], 2) + pow(a['y'] - b['y'], 2);
  };

  var tree = KDTree(points, distance, ['x', 'y']);

  var nearest = tree.nearest({'x': 5, 'y': 5}, 2);

  print(nearest);
}
