import 'mapbox_service.dart';
import 'overpass_service.dart';
import 'package:geolocator/geolocator.dart';

class ParkingApiService {
  static final MapboxService _mapboxService = MapboxService();

  static Future<List<Map<String, dynamic>>> getNearbyParkings({
    double? userLat,
    double? userLng,
    double radiusKm = 2.0,
  }) async {
    final double centerLat = userLat ?? -12.0464;
    final double centerLng = userLng ?? -77.0428;
    
    print('🔍 Buscando parkings cerca de: $centerLat, $centerLng');
    
    // Intentar primero con OpenStreetMap (más datos reales en Lima)
    var parkings = await OverpassService.searchRealParkings(
      lat: centerLat,
      lng: centerLng,
      radiusKm: radiusKm,
    );
    
    // Si OpenStreetMap no encuentra, intentar Mapbox
    if (parkings.isEmpty) {
      print('⚠️ Probando con Mapbox...');
      parkings = await _mapboxService.searchNearbyParkings(
        lat: centerLat,
        lng: centerLng,
        radiusKm: radiusKm,
      );
    }
    
    // Si ambos fallan, usar Geocoding de Mapbox
    if (parkings.isEmpty) {
      print('⚠️ Probando Geocoding de Mapbox...');
      parkings = await _mapboxService.searchParkingsGeocode(
        lat: centerLat,
        lng: centerLng,
        radiusKm: radiusKm,
      );
    }
    
    print('✅ Total: ${parkings.length} parkings encontrados');
    return parkings;
  }

  static Future<List<Map<String, dynamic>>> getParkingData() async {
    return getNearbyParkings();
  }

  static Future<Map<String, dynamic>?> getRouteToParking({
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
  }) async {
    return await _mapboxService.getRoute(
      originLat: originLat,
      originLng: originLng,
      destLat: destLat,
      destLng: destLng,
    );
  }

  static Future<Position?> getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return null;
      }

      if (permission == LocationPermission.deniedForever) return null;

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation,
      );
    } catch (e) {
      print('Error obteniendo ubicación: $e');
      return null;
    }
  }

  static double calculateDistance(double lat1, double lng1, double lat2, double lng2) {
    return Geolocator.distanceBetween(lat1, lng1, lat2, lng2) / 1000;
  }
}