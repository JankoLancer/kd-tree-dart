import 'dart:math';

class Node {
  Map obj;
  int dimension;
  Node? parent;
  Node? left;
  Node? right;

  Node(this.obj, this.dimension, this.parent);

  Node.fromJson(Map<String, dynamic> json)
      : obj = json['obj'],
        dimension = json['dim'] {
    if (json['left'] == null) {
      left = null;
    } else {
      left = Node.fromJson(json['left']);
      left?.parent = this;
    }
    if (json['right'] == null) {
      right = null;
    } else {
      right = Node.fromJson(json['right']);
      right?.parent = this;
    }
  }

  Map<String, dynamic> toJson() => {
        'obj': obj,
        'dim': dimension,
        'left': left?.toJson(),
        'right': right?.toJson(),
      };

  int get length {
    return 1 +
        (left == null ? 0 : left!.length) +
        (right == null ? 0 : right!.length);
  }

  int get height {
    return 1 +
        max(
          left == null ? 0 : left!.height,
          right == null ? 0 : right!.height,
        );
  }

  int get depth {
    return 1 + (parent == null ? 0 : parent!.depth);
  }
}
