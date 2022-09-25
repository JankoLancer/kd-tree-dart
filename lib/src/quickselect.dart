// Copyright (c) 2021 Ilya Zverev, (c) 2018 Vladimir Agafonkin.
// Port of https://github.com/mourner/quickselect.
// Use of this code is governed by an ISC license.

// Copyright (c) 2021, Ilya Zverev

// Permission to use, copy, modify, and/or distribute this software for any purpose
// with or without fee is hereby granted, provided that the above copyright notice
// and this permission notice appear in all copies.

// THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH
// REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND
// FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT,
// INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS
// OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER
// TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF
// THIS SOFTWARE.

import 'dart:math' as math;

/// This function implements a fast
/// [selection algorithm](https://en.wikipedia.org/wiki/Selection_algorithm)
/// (specifically, [Floyd-Rivest selection](https://en.wikipedia.org/wiki/Floyd%E2%80%93Rivest_algorithm)).
///
/// Rearranges items so that all items in the `[left, k]` are the smallest.
/// The `k`-th element will have the `(k - left + 1)`-th smallest value in `[left, right]`.
///
/// - [arr]: the list to partially sort (in place)
/// - [k]: middle index for partial sorting (as defined above)
/// - [left]: left index of the range to sort (`0` by default)
/// - [right]: right index (last index of the array by default)
/// - [compare]: compare function, if items in the list are not `Comparable`.
///
/// Example:
///
/// ```dart
/// var arr = [65, 28, 59, 33, 21, 56, 22, 95, 50, 12, 90, 53, 28, 77, 39];
///
/// quickSelect(arr, 8);
///
/// // arr is [39, 28, 28, 33, 21, 12, 22, 50, 53, 56, 59, 65, 90, 77, 95]
/// //                                         ^^ middle index
/// ```
quickSelect<T>(List<T> arr, int k,
    {int left = 0, int? right, Comparator<T>? compare}) {
  if (arr.isEmpty) return;
  if (compare == null && arr.first is! Comparable) {
    throw ArgumentError(
        'Please either provide a comparator or use a list of Comparable elements.');
  }
  _quickSelectStep(arr, k, left, right ?? arr.length - 1,
      compare ?? (T a, T b) => (a as Comparable).compareTo(b));
}

_quickSelectStep<T>(
    List<T> arr, int k, int left, int right, Comparator<T> compare) {
  while (right > left) {
    if (right - left > 600) {
      final n = right - left + 1;
      final m = k - left + 1;
      final z = math.log(n);
      final s = 0.5 * math.exp(2 * z / 3);
      final sd = 0.5 * math.sqrt(z * s * (n - s) / n) * (m - n / 2 < 0 ? -1 : 1);
      final newLeft = math.max(left, (k - m * s / n + sd).floor());
      final newRight = math.min(right, (k + (n - m) * s / n + sd).floor());
      _quickSelectStep(arr, k, newLeft, newRight, compare);
    }

    final t = arr[k];
    var i = left;
    var j = right;

    _swap(arr, left, k);
    if (compare(arr[right], t) > 0) _swap(arr, left, right);

    while (i < j) {
      _swap(arr, i, j);
      i++;
      j--;
      while (compare(arr[i], t) < 0) i++;
      while (compare(arr[j], t) > 0) j--;
    }

    if (compare(arr[left], t) == 0) {
      _swap(arr, left, j);
    } else {
      j++;
      _swap(arr, j, right);
    }

    if (j <= k) left = j + 1;
    if (k <= j) right = j - 1;
  }
}

_swap<T>(List<T> arr, i, j) {
  final tmp = arr[i];
  arr[i] = arr[j];
  arr[j] = tmp;
}