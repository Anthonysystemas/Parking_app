import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationService {
  static Future<Position?> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Verificar si el servicio de ubicación está habilitado
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return null;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return null;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      return null;
    }

    try {
      // CONFIGURACIÓN MEJORADA PARA MAYOR PRECISIÓN
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best, // Cambiar de high a best
        timeLimit: Duration(seconds: 15), // Más tiempo para mejor precisión
        forceAndroidLocationManager: false, // Usar Google Play Services
      );
    } catch (e) {
      print('Error obteniendo ubicación: $e');
      // Intentar con configuración de respaldo
      try {
        return await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        );
      } catch (e2) {
        print('Error en segundo intento: $e2');
        return null;
      }
    }
  }

  // NUEVO: Método para obtener ubicación con múltiples intentos
  static Future<Position?> getAccurateLocation() async {
    Position? bestPosition;
    double bestAccuracy = double.infinity;
    
    // Hacer 3 intentos para obtener la mejor precisión
    for (int i = 0; i < 3; i++) {
      try {
        Position? position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best,
          timeLimit: Duration(seconds: 10),
        );
        
        if (position != null) {
          // Si es la primera posición o es más precisa que la anterior
          if (bestPosition == null || position.accuracy < bestAccuracy) {
            bestPosition = position;
            bestAccuracy = position.accuracy;
          }
          
          // Si la precisión es muy buena (menos de 10 metros), usar esa
          if (position.accuracy <= 10.0) {
            print('Ubicación precisa obtenida: ${position.accuracy}m de precisión');
            return position;
          }
        }
        
        // Esperar un poco entre intentos
        if (i < 2) await Future.delayed(Duration(seconds: 2));
        
      } catch (e) {
        print('Intento ${i + 1} fallido: $e');
      }
    }
    
    if (bestPosition != null) {
      print('Mejor ubicación obtenida: ${bestPosition.accuracy}m de precisión');
    }
    
    return bestPosition;
  }

  // NUEVO: Método para obtener ubicación en tiempo real con stream
  static Stream<Position> getLocationStream() {
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.best,
      distanceFilter: 5, // Solo actualizar si se mueve más de 5 metros
      timeLimit: Duration(seconds: 15),
    );
    
    return Geolocator.getPositionStream(locationSettings: locationSettings);
  }

  // MEJORADO: Verificar si la ubicación es válida para Lima
  static bool isLocationInLima(Position position) {
    // Límites aproximados de Lima Metropolitana
    const double minLat = -12.35;
    const double maxLat = -11.65;
    const double minLon = -77.25;
    const double maxLon = -76.75;
    
    return position.latitude >= minLat && 
           position.latitude <= maxLat &&
           position.longitude >= minLon && 
           position.longitude <= maxLon;
  }

  // NUEVO: Método inteligente que filtra ubicaciones incorrectas
  static Future<Position?> getValidatedLocation() async {
    Position? position = await getAccurateLocation();
    
    if (position == null) {
      print('No se pudo obtener ubicación, usando ubicación por defecto');
      return getDefaultLimaLocation();
    }
    
    // Verificar si la ubicación está en un rango razonable para Lima
    if (!isLocationInLima(position)) {
      print('Ubicación fuera de Lima (${position.latitude}, ${position.longitude}), usando ubicación por defecto');
      return getDefaultLimaLocation();
    }
    
    // Verificar precisión
    if (position.accuracy > 100) {
      print('Precisión baja (${position.accuracy}m), usando ubicación por defecto');
      return getDefaultLimaLocation();
    }
    
    print('Ubicación válida obtenida: ${position.latitude}, ${position.longitude} (±${position.accuracy}m)');
    return position;
  }

  static double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
  }

  // MEJORADO: Ubicaciones por defecto más específicas según distrito
  static Position getDefaultLimaLocation([String? district]) {
    Map<String, Map<String, double>> districtLocations = {
      'miraflores': {'lat': -12.1219, 'lng': -77.0365},
      'san_isidro': {'lat': -12.0966, 'lng': -77.0365},
      'surco': {'lat': -12.1509, 'lng': -77.0175},
      'lima_centro': {'lat': -12.0464, 'lng': -77.0428},
      'callao': {'lat': -12.0658, 'lng': -77.1589},
      'san_borja': {'lat': -12.1090, 'lng': -77.0002},
    };
    
    Map<String, double> coords = districtLocations[district?.toLowerCase()] ?? 
                                districtLocations['lima_centro']!;
    
    return Position(
      latitude: coords['lat']!,
      longitude: coords['lng']!,
      timestamp: DateTime.now(),
      accuracy: 50.0, // Simular precisión de 50 metros
      altitude: 154.0, // Altitud promedio de Lima
      heading: 0,
      speed: 0,
      speedAccuracy: 0,
      altitudeAccuracy: 3.0,
      headingAccuracy: 0,
    );
  }

  // NUEVO: Método para verificar la calidad del GPS
  static Future<String> getLocationQuality() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
        timeLimit: Duration(seconds: 5),
      );
      
      if (position.accuracy <= 5) return 'Excelente';
      if (position.accuracy <= 15) return 'Muy bueno';
      if (position.accuracy <= 30) return 'Bueno';
      if (position.accuracy <= 50) return 'Regular';
      return 'Malo';
      
    } catch (e) {
      return 'Sin señal';
    }
  }
}