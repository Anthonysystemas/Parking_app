import 'dart:convert';
import 'package:dio/dio.dart';
import 'dart:math' as math;

class MapboxService {
  // TOKEN PÚBLICO CORRECTO
  static const String accessToken = 'pk.eyJ1IjoiYW50aG9ueS1kZXYiLCJhIjoiY21mNXB4MjF6MDhlazJtcHdvdTM1Zno4NSJ9.4qAgBXzM7DLHCji3aUtq_Q';
  
  static const String searchBaseUrl = 'https://api.mapbox.com/search/searchbox/v1';
  static const String directionsBaseUrl = 'https://api.mapbox.com/directions/v5/mapbox';
  static const String geocodingBaseUrl = 'https://api.mapbox.com/geocoding/v5/mapbox.places';
  
  final Dio _dio = Dio();

  // BUSCAR PARKINGS CERCANOS CON MAPBOX
  Future<List<Map<String, dynamic>>> searchNearbyParkings({
    required double lat,
    required double lng,
    double radiusKm = 3.0,
  }) async {
    try {
      final url = '$searchBaseUrl/category/parking';
      
      final response = await _dio.get(
        url,
        queryParameters: {
          'access_token': accessToken,
          'proximity': '$lng,$lat',
          'limit': 50,
          'language': 'es',
        },
      );

      if (response.statusCode == 200) {
        final List<Map<String, dynamic>> parkings = [];
        final features = response.data['features'] ?? [];
        
        for (var feature in features) {
          final properties = feature['properties'] ?? {};
          final geometry = feature['geometry'] ?? {};
          final coordinates = geometry['coordinates'] ?? [0, 0];
          
          final parkingLng = coordinates[0].toDouble();
          final parkingLat = coordinates[1].toDouble();
          
          final distance = _calculateDistance(lat, lng, parkingLat, parkingLng);
          
          if (distance <= radiusKm) {
            parkings.add({
              'id': feature['id']?.toString() ?? '',
              'name': properties['name']?.toString() ?? 'Estacionamiento',
              'address': properties['full_address']?.toString() ?? properties['place_formatted']?.toString() ?? '',
              'location': properties['place_formatted']?.toString() ?? '',
              'lat': parkingLat,
              'lng': parkingLng,
              'distance': distance,
              'distanceText': distance < 1.0 
                  ? '${(distance * 1000).round()} m'
                  : '${distance.toStringAsFixed(1)} km',
              'price': _estimatePrice(parkingLat, parkingLng),
              'available': '${10 + (DateTime.now().millisecond % 20)}',
              'total': '${30 + (DateTime.now().millisecond % 50)}',
              'isAvailable': true,
              'rating': 4.0 + (DateTime.now().millisecond % 10) / 10,
              'features': <String>['Estacionamiento público', 'Vigilancia', 'Techado'],
              'type': 'parking',
              'opening_hours': '24/7',
              'description': 'Estacionamiento en ${properties['place_formatted']?.toString() ?? "Lima"}',
            });
          }
        }
        
        parkings.sort((a, b) => (a['distance'] as double).compareTo(b['distance'] as double));
        
        print('✅ Mapbox encontró ${parkings.length} parkings');
        return parkings;
        
      } else {
        print('❌ Error en Mapbox API: ${response.statusCode}');
        return _getFallbackParkings(lat, lng, radiusKm);
      }
      
    } catch (e) {
      print('❌ Error buscando parkings en Mapbox: $e');
      return _getFallbackParkings(lat, lng, radiusKm);
    }
  }

  // BUSCAR PARKINGS USANDO GEOCODING (alternativa)
  Future<List<Map<String, dynamic>>> searchParkingsGeocode({
    required double lat,
    required double lng,
    double radiusKm = 3.0,
  }) async {
    try {
      final url = '$geocodingBaseUrl/parking.json';
      
      final response = await _dio.get(
        url,
        queryParameters: {
          'access_token': accessToken,
          'proximity': '$lng,$lat',
          'limit': 50,
          'language': 'es',
          'types': 'poi',
        },
      );

      if (response.statusCode == 200) {
        final List<Map<String, dynamic>> parkings = [];
        final features = response.data['features'] ?? [];
        
        for (var feature in features) {
          final center = feature['center'] ?? [0, 0];
          final parkingLng = (center[0] as num).toDouble();
          final parkingLat = (center[1] as num).toDouble();
          
          final distance = _calculateDistance(lat, lng, parkingLat, parkingLng);
          
          if (distance <= radiusKm) {
            parkings.add({
              'id': feature['id']?.toString() ?? '',
              'name': feature['text']?.toString() ?? 'Estacionamiento',
              'address': feature['place_name']?.toString() ?? '',
              'location': feature['place_name']?.toString() ?? '',
              'lat': parkingLat,
              'lng': parkingLng,
              'distance': distance,
              'distanceText': distance < 1.0 
                  ? '${(distance * 1000).round()} m'
                  : '${distance.toStringAsFixed(1)} km',
              'price': _estimatePrice(parkingLat, parkingLng),
              'available': '${10 + (DateTime.now().millisecond % 20)}',
              'total': '${30 + (DateTime.now().millisecond % 50)}',
              'isAvailable': true,
              'rating': 4.0 + (DateTime.now().millisecond % 10) / 10,
              'features': <String>['Parking disponible'],
              'type': 'parking',
              'opening_hours': '24/7',
              'description': 'Estacionamiento disponible',
            });
          }
        }
        
        parkings.sort((a, b) => (a['distance'] as double).compareTo(b['distance'] as double));
        return parkings;
        
      }
      return _getFallbackParkings(lat, lng, radiusKm);
      
    } catch (e) {
      print('Error en geocoding: $e');
      return _getFallbackParkings(lat, lng, radiusKm);
    }
  }

  // DATOS DE PRUEBA PARA LIMA (fallback)
  List<Map<String, dynamic>> _getFallbackParkings(double lat, double lng, double radiusKm) {
    print('📍 Usando datos de prueba de parkings en Lima');
    
    final List<Map<String, dynamic>> testParkings = [
      {
        'id': '1',
        'name': 'Parking Larcomar',
        'address': 'Malecón de la Reserva, Miraflores',
        'location': 'Miraflores, Lima',
        'lat': -12.1316,
        'lng': -77.0297,
        'price': 'S/. 8',
        'available': '15',
        'total': '50',
        'isAvailable': true,
        'rating': 4.5,
        'features': <String>['Techado', 'Vigilancia 24h', 'Centro Comercial'],
        'type': 'underground',
        'opening_hours': '24/7',
        'description': 'Estacionamiento subterráneo en Larcomar',
      },
      {
        'id': '2',
        'name': 'Real Plaza Salaverry',
        'address': 'Av. Salaverry 2370, Jesús María',
        'location': 'Jesús María, Lima',
        'lat': -12.0886,
        'lng': -77.0503,
        'price': 'S/. 5',
        'available': '23',
        'total': '80',
        'isAvailable': true,
        'rating': 4.2,
        'features': <String>['Techado', 'Centro Comercial', 'Seguro'],
        'type': 'multi-storey',
        'opening_hours': '09:00-22:00',
        'description': 'Parking en Real Plaza Salaverry',
      },
      {
        'id': '3',
        'name': 'Jockey Plaza',
        'address': 'Av. Javier Prado Este, Surco',
        'location': 'Santiago de Surco, Lima',
        'lat': -12.0950,
        'lng': -76.9780,
        'price': 'S/. 6',
        'available': '45',
        'total': '200',
        'isAvailable': true,
        'rating': 4.6,
        'features': <String>['Amplio', 'Vigilancia', 'Centro Comercial'],
        'type': 'multi-storey',
        'opening_hours': '24/7',
        'description': 'Estacionamiento Jockey Plaza',
      },
      {
        'id': '4',
        'name': 'Parking San Isidro',
        'address': 'Av. Camino Real, San Isidro',
        'location': 'San Isidro, Lima',
        'lat': -12.0966,
        'lng': -77.0365,
        'price': 'S/. 10',
        'available': '8',
        'total': '30',
        'isAvailable': true,
        'rating': 4.8,
        'features': <String>['Premium', 'Valet Parking', 'Seguro'],
        'type': 'underground',
        'opening_hours': '24/7',
        'description': 'Parking premium en San Isidro',
      },
      {
        'id': '5',
        'name': 'Plaza Norte',
        'address': 'Av. Tomás Valle, Independencia',
        'location': 'Independencia, Lima',
        'lat': -11.9881,
        'lng': -77.0620,
        'price': 'S/. 4',
        'available': '67',
        'total': '150',
        'isAvailable': true,
        'rating': 4.0,
        'features': <String>['Amplio', 'Centro Comercial'],
        'type': 'surface',
        'opening_hours': '09:00-22:00',
        'description': 'Estacionamiento Plaza Norte',
      },
      {
        'id': '6',
        'name': 'Mega Plaza',
        'address': 'Av. Alfredo Mendiola, Independencia',
        'location': 'Independencia, Lima',
        'lat': -11.9730,
        'lng': -77.0600,
        'price': 'S/. 3',
        'available': '52',
        'total': '120',
        'isAvailable': true,
        'rating': 3.9,
        'features': <String>['Amplio', 'Centro Comercial', 'Económico'],
        'type': 'surface',
        'opening_hours': '09:00-22:00',
        'description': 'Estacionamiento Mega Plaza',
      },
      {
        'id': '7',
        'name': 'Óvalo Gutiérrez',
        'address': 'Av. Santa Cruz, Miraflores',
        'location': 'Miraflores, Lima',
        'lat': -12.1180,
        'lng': -77.0320,
        'price': 'S/. 7',
        'available': '12',
        'total': '40',
        'isAvailable': true,
        'rating': 4.3,
        'features': <String>['Céntrico', 'Vigilancia', 'Iluminado'],
        'type': 'surface',
        'opening_hours': '24/7',
        'description': 'Parking cerca al Óvalo Gutiérrez',
      },
      {
        'id': '8',
        'name': 'Centro Comercial Caminos del Inca',
        'address': 'Av. Caminos del Inca, Surco',
        'location': 'Santiago de Surco, Lima',
        'lat': -12.1200,
        'lng': -76.9850,
        'price': 'S/. 5',
        'available': '31',
        'total': '90',
        'isAvailable': true,
        'rating': 4.1,
        'features': <String>['Techado', 'Centro Comercial', 'Seguro'],
        'type': 'multi-storey',
        'opening_hours': '10:00-22:00',
        'description': 'Parking en CC Caminos del Inca',
      },
    ];
    
    // Calcular distancias y filtrar
    final List<Map<String, dynamic>> nearbyParkings = [];
    
    for (var parking in testParkings) {
      final distance = _calculateDistance(
        lat, lng,
        parking['lat'], parking['lng']
      );
      
      if (distance <= radiusKm) {
        parking['distance'] = distance;
        parking['distanceText'] = distance < 1.0 
            ? '${(distance * 1000).round()} m'
            : '${distance.toStringAsFixed(1)} km';
        nearbyParkings.add(parking);
      }
    }
    
    nearbyParkings.sort((a, b) => (a['distance'] as double).compareTo(b['distance'] as double));
    
    print('✅ Mostrando ${nearbyParkings.length} parkings de prueba');
    return nearbyParkings;
  }

  // OBTENER RUTA CON TRÁFICO EN TIEMPO REAL
  Future<Map<String, dynamic>?> getRoute({
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
  }) async {
    try {
      final url = '$directionsBaseUrl/driving-traffic/$originLng,$originLat;$destLng,$destLat';
      
      final response = await _dio.get(
        url,
        queryParameters: {
          'access_token': accessToken,
          'geometries': 'geojson',
          'overview': 'full',
          'steps': true,
          'annotations': 'duration,distance,speed',
          'language': 'es',
        },
      );

      if (response.statusCode == 200 && response.data['routes'] != null) {
        final route = response.data['routes'][0];
        
        return {
          'duration': route['duration'],
          'durationText': _formatDuration((route['duration'] as num).toDouble()),
          'distance': route['distance'],
          'distanceText': _formatDistance((route['distance'] as num).toDouble()),
          'geometry': route['geometry']['coordinates'],
          'steps': route['legs'][0]['steps'],
        };
      }
      
      return null;
      
    } catch (e) {
      print('Error obteniendo ruta: $e');
      return null;
    }
  }

  // Calcular distancia entre dos puntos
  double _calculateDistance(double lat1, double lng1, double lat2, double lng2) {
    const double earthRadius = 6371;
    final double dLat = (lat2 - lat1) * math.pi / 180;
    final double dLng = (lng2 - lng1) * math.pi / 180;
    
    final double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1 * math.pi / 180) * math.cos(lat2 * math.pi / 180) *
        math.sin(dLng / 2) * math.sin(dLng / 2);
    
    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadius * c;
  }

  String _estimatePrice(double lat, double lng) {
    // San Isidro / Miraflores (zona premium)
    if (lat < -12.08 && lat > -12.15 && lng > -77.05) return 'S/. 8';
    // Lima Centro
    if (lat < -12.03 && lat > -12.07) return 'S/. 6';
    // Otras zonas
    return 'S/. 5';
  }

  String _formatDuration(double seconds) {
    final minutes = (seconds / 60).round();
    if (minutes < 60) return '$minutes min';
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    return '${hours}h ${mins}min';
  }

  String _formatDistance(double meters) {
    if (meters < 1000) return '${meters.round()} m';
    return '${(meters / 1000).toStringAsFixed(1)} km';
  }
}