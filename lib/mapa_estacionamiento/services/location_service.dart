import 'package:geolocator/geolocator.dart';
import 'dart:async';

class LocationService {
  
  // Obtener ubicación con máxima precisión
  static Future<Position?> getCurrentLocation() async {
    // Verificar que el GPS esté activado
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print('⚠️ GPS desactivado');
      return null;
    }

    // Verificar permisos
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print('⚠️ Permisos denegados');
        return null;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      print('⚠️ Permisos denegados permanentemente');
      return null;
    }

    try {
      print('🔄 Obteniendo ubicación GPS...');
      
      // ESTRATEGIA 1: Obtener última ubicación conocida primero (instantánea)
      Position? lastKnown = await Geolocator.getLastKnownPosition();
      if (lastKnown != null) {
        print('📍 Última ubicación conocida: ${lastKnown.latitude}, ${lastKnown.longitude} (±${lastKnown.accuracy}m)');
      }
      
      // ESTRATEGIA 2: Obtener ubicación actual con alta precisión
      Position currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation, // Máxima precisión posible
        timeLimit: Duration(seconds: 15), // Más tiempo para mejor precisión
      );
      
      print('✅ Ubicación actual: ${currentPosition.latitude}, ${currentPosition.longitude} (±${currentPosition.accuracy}m)');
      
      // ESTRATEGIA 3: Si la precisión no es buena, hacer stream para mejorar
      if (currentPosition.accuracy > 30) {
        print('⚠️ Precisión baja (${currentPosition.accuracy}m), mejorando...');
        
        Position? improvedPosition = await _getImprovedLocation(currentPosition);
        if (improvedPosition != null && improvedPosition.accuracy < currentPosition.accuracy) {
          print('✅ Ubicación mejorada: ${improvedPosition.latitude}, ${improvedPosition.longitude} (±${improvedPosition.accuracy}m)');
          return improvedPosition;
        }
      }
      
      return currentPosition;
      
    } catch (e) {
      print('❌ Error GPS: $e');
      
      // Fallback: intentar con precisión media
      try {
        print('🔄 Reintentando con precisión media...');
        Position fallbackPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        );
        print('✅ Ubicación obtenida: ${fallbackPosition.latitude}, ${fallbackPosition.longitude} (±${fallbackPosition.accuracy}m)');
        return fallbackPosition;
      } catch (e2) {
        print('❌ Error en fallback: $e2');
        return null;
      }
    }
  }

  // Método privado para mejorar la precisión con stream
  static Future<Position?> _getImprovedLocation(Position initialPosition) async {
    try {
      Position? bestPosition = initialPosition;
      double bestAccuracy = initialPosition.accuracy;
      
      final LocationSettings locationSettings = LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 0, // Actualizar con cualquier cambio
        timeLimit: Duration(seconds: 8),
      );
      
      final completer = Completer<Position?>();
      StreamSubscription<Position>? subscription;
      
      subscription = Geolocator.getPositionStream(locationSettings: locationSettings).listen(
        (Position position) {
          print('📡 Stream: ${position.latitude}, ${position.longitude} (±${position.accuracy}m)');
          
          if (position.accuracy < bestAccuracy) {
            bestPosition = position;
            bestAccuracy = position.accuracy;
          }
          
          // Si logramos buena precisión, terminar
          if (position.accuracy <= 15) {
            subscription?.cancel();
            completer.complete(bestPosition);
          }
        },
        onError: (error) {
          print('❌ Error en stream: $error');
          subscription?.cancel();
          completer.complete(bestPosition);
        },
      );
      
      // Timeout después de 8 segundos
      Future.delayed(Duration(seconds: 8), () {
        if (!completer.isCompleted) {
          subscription?.cancel();
          completer.complete(bestPosition);
        }
      });
      
      return await completer.future;
      
    } catch (e) {
      print('❌ Error mejorando ubicación: $e');
      return null;
    }
  }

  // Obtener stream continuo de ubicación (para seguimiento en tiempo real)
  static Stream<Position> getLocationStream() {
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.bestForNavigation,
      distanceFilter: 5, // Actualizar cada 5 metros
      timeLimit: Duration(seconds: 20),
    );
    
    return Geolocator.getPositionStream(locationSettings: locationSettings);
  }

  // Verificar calidad de la señal GPS
  static Future<String> getGPSQuality() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation,
        timeLimit: Duration(seconds: 5),
      );
      
      if (position.accuracy <= 10) return 'Excelente';
      if (position.accuracy <= 20) return 'Muy buena';
      if (position.accuracy <= 40) return 'Buena';
      if (position.accuracy <= 80) return 'Regular';
      return 'Mala';
      
    } catch (e) {
      return 'Sin señal';
    }
  }

  // Calcular distancia entre dos puntos
  static double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
  }
}