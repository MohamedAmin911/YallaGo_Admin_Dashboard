import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:yallago_admin_dashboard/models/driver.dart';

class DriverMarker {
  static BitmapDescriptor getMarkerIcon(
    Driver driver, {
    bool isSelected = false,
  }) {
    // You can use different marker icons based on driver status or selection
    return BitmapDescriptor.defaultMarkerWithHue(
      isSelected ? BitmapDescriptor.hueAzure : BitmapDescriptor.hueRed,
    );
  }

  static Marker createMarker(Driver driver, {bool isSelected = false}) {
    final location = driver.currentLocation;
    if (location == null) {
      throw Exception('Driver location is null');
    }

    return Marker(
      markerId: MarkerId(driver.id),
      position: LatLng(location.latitude, location.longitude),
      icon: getMarkerIcon(driver, isSelected: isSelected),
      infoWindow: InfoWindow(
        title: driver.fullName,
        snippet: 'ID: ${driver.id}',
      ),
      zIndex: isSelected ? 2 : 1,
    );
  }
}
