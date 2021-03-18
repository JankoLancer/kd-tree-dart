# k-d Tree Dart Library

A basic super fast Dart implementation of the k-dimensional tree data structure.
This library is dart port of Javascript implementation: https://github.com/ubilabs/kd-tree-javascript

In computer science, a [k-d tree](https://en.wikipedia.org/wiki/K-d_tree) (short for k-dimensional tree) is a space-partitioning data structure for organizing points in a k-dimensional space. k-d trees are a useful data structure for several applications, such as searches involving a multidimensional search key (e.g. range searches and nearest neighbor searches). k-d trees are a special case of binary space partitioning trees.

### Usage

#### Using library
```dart
// Create a new tree from a list of points, a distance function, and a
// list of dimensions.
var tree = KDTree(points, distance, dimensions);

// Query the nearest *count* neighbours to a point, with an optional
// maximal search distance.
// Result is an array with *count* elements.
// Each element is an array with two components: the searched point and
// the distance to it.
tree.nearest(point, count, [maxDistance]);

// Insert a new point into the tree. Must be consistent with previous
// contents.
tree.insert(point);

// Remove a point from the tree by reference.
tree.remove(point);

// Get an approximation of how unbalanced the tree is.
// The higher this number, the worse query performance will be.
// It indicates how many times worse it is than the optimal tree.
// Minimum is 1. Unreliable for small trees.
tree.balanceFactor();
```

### Example

```dart
import 'package:kdtree/kdtree.dart';

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
```