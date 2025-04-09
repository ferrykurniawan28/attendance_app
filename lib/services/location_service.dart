part of 'services.dart';

class LocationResult {
  final LatLng position;
  final bool isMocked;
  final double? distanceFromTarget;

  LocationResult({
    required this.position,
    this.isMocked = false,
    this.distanceFromTarget,
  });
}

class LocationService {
  final Location _location = Location();

  Future<LocationResult?> getLocationWithDistance({
    required LatLng destination,
    required BuildContext context,
  }) async {
    try {
      PermissionStatus permissionGranted = await _location.hasPermission();
      bool serviceEnabled = await _location.serviceEnabled();

      if (!serviceEnabled) {
        serviceEnabled = await _location.requestService();
        if (!serviceEnabled) return null;
      }

      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await _location.requestPermission();
        if (permissionGranted != PermissionStatus.granted) return null;
      }

      await Future.delayed(const Duration(seconds: 1));
      LocationData locationData = await _location.getLocation().timeout(
        const Duration(seconds: 30),
      );

      if (locationData.latitude == null || locationData.longitude == null) {
        return null;
      }

      LatLng current = LatLng(locationData.latitude!, locationData.longitude!);
      double distance = const Distance().as(
        LengthUnit.Meter,
        current,
        destination,
      );
      bool isMocked = locationData.isMock ?? false;

      return LocationResult(
        position: current,
        isMocked: isMocked,
        distanceFromTarget: distance,
      );
    } catch (e) {
      debugPrint("Error getting location: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Error getting location')));
      return null;
    }
  }
}
