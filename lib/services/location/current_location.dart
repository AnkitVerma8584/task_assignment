import 'package:black_coffer/models/my_location.dart';
import 'package:black_coffer/util/common.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

Future<Position> _determinePosition() async {
  bool serviceEnabled;
  LocationPermission permission;

  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    return Future.error('Location services are disabled.');
  }
  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return Future.error('Location permissions are denied');
    }
  }
  if (permission == LocationPermission.deniedForever) {
    return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.');
  }
  return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.low);
}

Future<String> getCurrentLocation() async {
  late MyLocation myLocation;
  await _determinePosition()
      .then((value) => myLocation = MyLocation(position: value, error: null))
      .catchError(
          (e) => myLocation = MyLocation(position: null, error: e.toString()));

  String address = "No location found!";
  if (myLocation.position != null) {
    List<Placemark> placemarks = await placemarkFromCoordinates(
        myLocation.position!.latitude, myLocation.position!.longitude);

    address =
        "${placemarks[0].street},  ${placemarks[0].administrativeArea}, ${placemarks[0].country}";
  } else {
    printLog(myLocation.error!);
  }
  return address;
}
