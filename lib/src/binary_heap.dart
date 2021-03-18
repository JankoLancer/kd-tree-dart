class BinaryHeap {
  Function scoreFunction;
  List content;

  BinaryHeap(this.scoreFunction) : content = [];

  void push(element) {
    content.add(element);
    // Allow it to bubble up.
    bubbleUp(content.length - 1);
  }

  dynamic pop() {
    // Store the first element so we can return it later.
    var result = content[0];
    // Get the element at the end of the array.
    var end = content.removeLast();
    // If there are any elements left, put the end element at the
    // start, and let it sink down.
    if (content.isNotEmpty) {
      content[0] = end;
      sinkDown(0);
    }
    return result;
  }

  dynamic peek() {
    return content[0];
  }

  void remove(node) {
    var len = content.length;
    // To remove a value, we must search through the array to find
    // it.
    for (var i = 0; i < len; i++) {
      if (content[i] == node) {
        // When it is found, the process seen in 'pop' is repeated
        // to fill up the hole.
        var end = content.removeLast();
        if (i != len - 1) {
          content[i] = end;
          if (scoreFunction(end) < scoreFunction(node)) {
            bubbleUp(i);
          } else {
            sinkDown(i);
          }
        }
        return;
      }
    }
    throw Exception('Node not found.');
  }

  int size() {
    return content.length;
  }

  void bubbleUp(n) {
    // Fetch the element that has to be moved.
    var element = content[n];
    // When at 0, an element can not go up any further.
    while (n > 0) {
      // Compute the parent element's index, and fetch it.
      var parentN = ((n + 1) / 2).floor() - 1, parent = content[parentN];
      // Swap the elements if the parent is greater.
      if (scoreFunction(element) < scoreFunction(parent)) {
        content[parentN] = element;
        content[n] = parent;
        // Update 'n' to continue at the new position.
        n = parentN;
      }
      // Found a parent that is less, no need to move it further.
      else {
        break;
      }
    }
  }

  void sinkDown(n) {
    // Look up the target element and its score.
    var length = content.length,
        element = content[n],
        elemScore = scoreFunction(element);

    while (true) {
      // Compute the indices of the child elements.
      var child2N = (n + 1) * 2, child1N = child2N - 1;
      // This is used to store the new position of the element,
      // if any.
      var swap;
      var child1Score;
      // If the first child exists (is inside the array)...
      if (child1N < length) {
        // Look it up and compute its score.
        var child1 = content[child1N];
        child1Score = scoreFunction(child1);
        // If the score is less than our element's, we need to swap.
        if (child1Score < elemScore) {
          swap = child1N;
        }
      }
      // Do the same checks for the other child.
      if (child2N < length) {
        var child2 = content[child2N], child2Score = scoreFunction(child2);
        if (child2Score < (swap == null ? elemScore : child1Score)) {
          swap = child2N;
        }
      }

      // If the element needs to be moved, swap it, and continue.
      if (swap != null) {
        content[n] = content[swap];
        content[swap] = element;
        n = swap;
      }
      // Otherwise, we are done.
      else {
        break;
      }
    }
  }
}
