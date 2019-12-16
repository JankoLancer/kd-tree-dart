import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:kdtree/kdtree.dart';

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

void runLocationExample(double latitute, double longitude) {
  var numMarkers = 30;
  Iterable l = jsonDecode(
      File(Directory.current.path + '\\location\\location_data.json').readAsStringSync());
  var locations = l
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

  var point = {'latitude': latitute, 'longitude': longitude};
  var nearest = tree.nearest(point, numMarkers, null);

  nearest.forEach((x) => print(x));
}
