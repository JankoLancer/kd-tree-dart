import 'basic_example.dart';
import 'location/location_example.dart';

void main() {
  print('Basic example: Find one nearest point in list of points');
  runBasicExample();
  print(
      'Location example: Find 30 nearest location to given latitude and longitude from JSON list of locations.');
  runLocationExample(44.815, 20.282);
}
