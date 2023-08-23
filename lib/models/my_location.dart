import 'package:geolocator/geolocator.dart';

class MyLocation {
  final Position? position;
  final String? error;

  MyLocation({required this.position, required this.error});

  @override
  String toString() {
    return '''{
      lat : ${position?.latitude},
      long: ${position?.longitude},
      error: $error
    }''';
  }
}
