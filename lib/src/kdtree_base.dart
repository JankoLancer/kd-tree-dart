import 'dart:math';

import 'binary_heap.dart';
import 'node.dart';

class KDTree {
  final List<String> _dimensions;
  late Node? _root;
  Function? _metric;

  KDTree(List<Map> points, this._metric, this._dimensions) {
    _root = _buildTree(points, 0, null);
  }

  Node? _buildTree(List<Map> points, depth, parent) {
    if (points.isEmpty) {
      return null;
    }

    var dim = depth % _dimensions.length, median, node;

    if (points.length == 1) {
      return Node(points[0], dim, parent);
    }

    points.sort((a, b) {
      return a[_dimensions[dim]].compareTo(b[_dimensions[dim]]);
    });

    median = (points.length / 2).floor();
    node = Node(points[median], dim, parent);
    node.left = _buildTree(points.sublist(0, median), depth + 1, node);
    node.right = _buildTree(points.sublist(median + 1), depth + 1, node);

    return node;
  }

  // Insert the Node in the K-d Tree
  void insert(point) {
    Node? innerSearch(Node? node, Node? parent) {
      if (node == null) {
        return parent;
      }

      var dimension = _dimensions[node.dimension];
      if (point[dimension] < node.obj[dimension]) {
        return innerSearch(node.left, node);
      } else {
        return innerSearch(node.right, node);
      }
    }

    var insertPosition = innerSearch(_root, null), newNode, dimension;

    if (insertPosition == null) {
      _root = Node(point, 0, null);
      return;
    }

    newNode = Node(point, (insertPosition.dimension + 1) % _dimensions.length,
        insertPosition);
    dimension = _dimensions[insertPosition.dimension];

    if (point[dimension] < insertPosition.obj[dimension]) {
      insertPosition.left = newNode;
    } else {
      insertPosition.right = newNode;
    }
  }

  /// Remove the Node from the K-d Tree
  void remove(point) {
    var node;

    Node? nodeSearch(Node? node) {
      if (node == null) {
        return null;
      }

      if (node.obj == point) {
        return node;
      }

      var dimension = _dimensions[node.dimension];

      if (point[dimension] < node.obj[dimension]) {
        return nodeSearch(node.left);
      } else {
        return nodeSearch(node.right);
      }
    }

    void removeNode(Node node) {
      var nextNode, nextObj, pDimension;

      Node? findMin(Node? node, dim) {
        var dimension, own, left, right, min;

        if (node == null) {
          return null;
        }

        dimension = _dimensions[dim];

        if (node.dimension == dim) {
          if (node.left != null) {
            return findMin(node.left, dim);
          }
          return node;
        }

        own = node.obj[dimension];
        left = findMin(node.left, dim);
        right = findMin(node.right, dim);
        min = node;

        if (left != null && left.obj[dimension] < own) {
          min = left;
        }
        if (right != null && right.obj[dimension] < min.obj[dimension]) {
          min = right;
        }
        return min;
      }

      if (node.left == null && node.right == null) {
        if (node.parent == null) {
          _root = null;
          return;
        }

        pDimension = _dimensions[node.parent!.dimension];

        if (node.obj[pDimension] < node.parent?.obj[pDimension]) {
          node.parent?.left = null;
        } else {
          node.parent?.right = null;
        }
        return;
      }

      // If the right subtree is not empty, swap with the minimum element on the
      // node's dimension. If it is empty, we swap the left and right subtrees and
      // do the same.
      if (node.right != null) {
        nextNode = findMin(node.right, node.dimension);
        nextObj = nextNode.obj;
        removeNode(nextNode);
        node.obj = nextObj;
      } else {
        nextNode = findMin(node.left, node.dimension);
        nextObj = nextNode.obj;
        removeNode(nextNode);
        node.right = node.left;
        node.left = null;
        node.obj = nextObj;
      }
    }

    node = nodeSearch(_root);

    if (node == null) {
      return;
    }

    removeNode(node);
  }

  /// Find the [maxNodes] of nearest Nodes.
  /// Distance is calculated via Metric function.
  /// Max distance can be set with [maxDistance] param
  List<dynamic> nearest(point, int maxNodes, [int? maxDistance]) {
    var i, result;
    BinaryHeap bestNodes;

    if (_metric == null) {
      throw Exception(
          'Metric function undefined. Please notice that, after deserialization, you must redefine the metric function.');
    }

    bestNodes = BinaryHeap((e) {
      return -e[1];
    });

    void nearestSearch(node) {
      var bestChild,
          dimension = _dimensions[node.dimension],
          ownDistance = _metric!(point, node.obj),
          linearPoint = {},
          linearDistance,
          otherChild,
          i;

      void saveNode(node, distance) {
        bestNodes.push([node, distance]);
        if (bestNodes.size() > maxNodes) {
          bestNodes.pop();
        }
      }

      for (i = 0; i < _dimensions.length; i += 1) {
        if (i == node.dimension) {
          linearPoint[_dimensions[i]] = point[_dimensions[i]];
        } else {
          linearPoint[_dimensions[i]] = node.obj[_dimensions[i]];
        }
      }

      linearDistance = _metric!(linearPoint, node.obj);

      if (node.right == null && node.left == null) {
        if (bestNodes.size() < maxNodes || ownDistance < bestNodes.peek()[1]) {
          saveNode(node, ownDistance);
        }
        return;
      }

      if (node.right == null) {
        bestChild = node.left;
      } else if (node.left == null) {
        bestChild = node.right;
      } else {
        if (point[dimension] < node.obj[dimension]) {
          bestChild = node.left;
        } else {
          bestChild = node.right;
        }
      }

      nearestSearch(bestChild);

      if (bestNodes.size() < maxNodes || ownDistance < bestNodes.peek()[1]) {
        saveNode(node, ownDistance);
      }

      if (bestNodes.size() < maxNodes ||
          linearDistance.abs() < bestNodes.peek()[1]) {
        if (bestChild == node.left) {
          otherChild = node.right;
        } else {
          otherChild = node.left;
        }
        if (otherChild != null) {
          nearestSearch(otherChild);
        }
      }
    }

    if (maxDistance != null) {
      for (i = 0; i < maxNodes; i += 1) {
        bestNodes.push([null, maxDistance]);
      }
    }

    if (_root != null) {
      nearestSearch(_root);
    }

    result = [];

    for (i = 0; i < min(maxNodes, bestNodes.content.length); i += 1) {
      if (bestNodes.content[i][0] != null) {
        result.add([bestNodes.content[i][0].obj, bestNodes.content[i][1]]);
      }
    }

    return result;
  }

  /// Calculate balance factor of K-d Tree
  double balanceFactor() => height / (log(length) / log(2));

  KDTree.fromJson(Map<String, dynamic> json)
      : _dimensions = List.from(json['dim']) {
    if (json['root'] != null) {
      _root = Node.fromJson(json['root']);
    }
  }

  Map<String, dynamic> toJson() => {
        'dim': _dimensions,
        'root': _root?.toJson(),
      };

  /// Calculate lenght of K-d Tree
  int get length {
    return _root?.length ?? 0;
  }

  /// Calculate height of K-d Tree
  int get height {
    return _root?.height ?? 0;
  }

  /// Return dimensions that was setted on Tree creation
  List<String> get dimensions {
    return _dimensions;
  }

  /// Set the new metric function. This must be done after JSON deserialization since JSON can't serialize Function.
  set metric(Function? newMetric) {
    _metric = newMetric;
  }
}
