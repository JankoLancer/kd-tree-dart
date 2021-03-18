import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:kdtree/kdtree.dart';
import 'package:test/test.dart';

class Location {
  String title;
  double latitude;
  double longitude;

  Location(this.title, this.latitude, this.longitude);

  static Location fromJson(Map<String, dynamic> json) {
    return Location(json['title'], double.parse(json['latitude'].toString()),
        double.parse(json['longitude'].toString()));
  }

  Map<String, dynamic> toJson() =>
      {'title': title, 'latitude': latitude, 'longitude': longitude};
}

void main() {
  test('Basic example: Find one nearest point in list of points', () {
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

    var nearest = tree.nearest({'x': 5, 'y': 5}, 1);

    // nearest point shoud be [5, 6] with distance of 1
    expect(nearest, hasLength(1));
    expect(nearest[0][0]['x'], 5);
    expect(nearest[0][0]['y'], 6);
    expect(nearest[0][1], 1);
  });

  test('Location example: Find nearest location from JSON list of locations.',
      () {
    Iterable fileJson = jsonDecode(
        File('test_resources/location_data.json').readAsStringSync());
    var locations = fileJson
        .map((model) => Location.fromJson(model))
        .map((model) => model.toJson())
        .toList();

    var distance = (location1, location2) {
      var lat1 = location1['latitude'],
          lon1 = location1['longitude'],
          lat2 = location2['latitude'],
          lon2 = location2['longitude'];
      var rad = pi / 180;
      var dLat = (lat2 - lat1) * rad;
      var dLon = (lon2 - lon1) * rad;
      lat1 = lat1 * rad;
      lat2 = lat2 * rad;
      var x = sin(dLat / 2);
      var y = sin(dLon / 2);
      var a = x * x + y * y * cos(lat1) * cos(lat2);
      return atan2(sqrt(a), sqrt(1 - a));
    };

    var tree = KDTree(locations, distance, ['latitude', 'longitude']);
    var latitude = 12.306817;
    var longitude = 120.071383;

    var point = {'latitude': latitude, 'longitude': longitude};
    var nearest = tree.nearest(point, 1);

    // nearest Location should be shoud be Cashew Beach
    expect(nearest, hasLength(1));
    var near = Location.fromJson(nearest[0][0]);
    expect(near.title, 'Cashew Beach');
  });
}
