import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class GeoLocationService {
  // Solicitar permisos de ubicación
  Future<bool> checkLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Verificar si los servicios de ubicación están habilitados
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    // Verificar permisos
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  // Obtener ubicación actual
  Future<Position> getCurrentLocation() async {
    bool hasPermission = await checkLocationPermission();
    
    if (!hasPermission) {
      throw Exception('Permisos de ubicación denegados');
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  // Convertir dirección a coordenadas (geocoding)
  Future<Location?> getCoordinatesFromAddress(String address) async {
    try {
      List<Location> locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        return locations.first;
      }
      return null;
    } catch (e) {
      print('Error en geocoding: $e');
      return null;
    }
  }

  // Calcular distancia entre dos puntos (en km)
  double calculateDistance(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    ) / 1000; // Convertir a kilómetros
  }

  // Obtener dirección desde coordenadas (reverse geocoding)
  Future<String> getAddressFromCoordinates(double lat, double lng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
      
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        return '${place.street}, ${place.locality}, ${place.country}';
      }
      return 'Dirección no encontrada';
    } catch (e) {
      print('Error en reverse geocoding: $e');
      return 'Error al obtener dirección';
    }
  }
}