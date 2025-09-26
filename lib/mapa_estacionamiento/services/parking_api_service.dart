import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math' as math;

class ParkingApiService {
  // Consulta específica para Lima Metropolitana (área más pequeña)
  static const String overpassUrl = 'https://overpass-api.de/api/interpreter';
  
  // Expandir área de búsqueda para incluir todo Lima Metropolitana y alrededores
  static const double minLat = -12.4;  // Incluye Carabayllo, San Martín de Porres
  static const double maxLat = -11.7;  // Incluye Comas, Los Olivos, zona norte
  static const double minLon = -77.3;  // Incluye Callao y zona oeste
  static const double maxLon = -76.7;  // Incluye zona este de Lima

  static Future<List<Map<String, dynamic>>> getParkingData() async {
    // Consulta Overpass más amplia para toda Lima Metropolitana
    final String query = '''
    [out:json][timeout:25];
    (
      node["amenity"="parking"](${minLat},${minLon},${maxLat},${maxLon});
      way["amenity"="parking"](${minLat},${minLon},${maxLat},${maxLon});
      relation["amenity"="parking"](${minLat},${minLon},${maxLat},${maxLon});
    );
    out center meta tags;
    ''';

    try {
      print('Consultando API de Overpass...');
      final response = await http.post(
        Uri.parse(overpassUrl),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'User-Agent': 'ParkingApp/1.0'
        },
        body: 'data=' + Uri.encodeComponent(query),
      );

      print('Respuesta API: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final String responseBody = response.body;
        
        // Verificar si hay error de memoria
        if (responseBody.contains('runtime error') || responseBody.contains('Query ran out of memory')) {
          print('Error de memoria en Overpass API, intentando consulta más específica');
          return []; // Retornar lista vacía en lugar de datos falsos
        }
        
        final data = json.decode(responseBody);
        return _parseOverpassData(data);
      } else {
        print('Error en API: ${response.statusCode}');
        return []; // Retornar lista vacía en lugar de datos falsos
      }
    } catch (e) {
      print('Error al obtener datos: $e');
      return []; // Retornar lista vacía en caso de error
    }
  }

  static List<Map<String, dynamic>> _parseOverpassData(Map<String, dynamic> data) {
    final List<Map<String, dynamic>> parkings = [];
    
    if (data['elements'] != null) {
      for (var element in data['elements']) {
        double lat, lon;
        
        // Obtener coordenadas según el tipo de elemento
        if (element['type'] == 'node') {
          lat = element['lat']?.toDouble() ?? 0.0;
          lon = element['lon']?.toDouble() ?? 0.0;
        } else if (element['center'] != null) {
          lat = element['center']['lat']?.toDouble() ?? 0.0;
          lon = element['center']['lon']?.toDouble() ?? 0.0;
        } else {
          continue;
        }

        final tags = element['tags'] ?? {};
        String parkingName = tags['name'] ?? 
                           tags['operator'] ?? 
                           tags['brand'] ?? 
                           '';
        
        // Generar nombres realistas si no tienen nombre específico
        if (parkingName.isEmpty) {
          parkingName = _generateRealisticName(tags, lat, lon, element['id']);
        }
        
        parkings.add({
          'id': element['id'] ?? 0,
          'name': parkingName,
          'address': _buildCompleteAddress(tags, lat, lon),
          'location': _buildCompleteAddress(tags, lat, lon),
          'price': _calculateRealisticPrice(tags, lat, lon),
          'available': _estimateRealisticAvailability(tags),
          'total': _estimateRealisticCapacity(tags),
          'isAvailable': _determineAvailability(tags),
          'lat': lat,
          'lng': lon,
          'rating': _calculateRating(tags),
          'features': _extractRealFeatures(tags),
          'type': tags['parking'] ?? 'surface',
          'fee': tags['fee'] ?? 'yes',
          'access': tags['access'] ?? 'customers',
          'surface': tags['surface'] ?? 'paved',
          'capacity': tags['capacity'],
          'operator': tags['operator'],
          'opening_hours': tags['opening_hours'] ?? '24/7',
          'phone': tags['phone'],
          'website': tags['website'],
          'description': _buildDescription(tags),
        });
      }
    }
    
    return parkings.isNotEmpty ? parkings : []; // Retornar lista vacía en lugar de datos falsos
  }

  // Métodos mejorados para datos más reales y completos
  static String _buildCompleteAddress(Map<String, dynamic> tags, double lat, double lng) {
    String address = '';
    
    // Construir dirección desde tags de OSM
    final street = tags['addr:street'] ?? '';
    final number = tags['addr:housenumber'] ?? '';
    final district = tags['addr:suburb'] ?? tags['addr:district'] ?? '';
    
    if (street.isNotEmpty) {
      address = street;
      if (number.isNotEmpty) address += ' $number';
    }
    
    // Agregar distrito si existe
    if (district.isNotEmpty) {
      address = address.isEmpty ? district : '$address, $district';
    }
    
    // Determinar zona de Lima basada en coordenadas
    String zone = _determineZoneFromCoordinates(lat, lng);
    if (zone.isNotEmpty) {
      address = address.isEmpty ? zone : '$address, $zone';
    }
    
    return address.isNotEmpty ? address : 'Ubicación: ${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}';
  }

  static String _determineZoneFromCoordinates(double lat, double lng) {
    // Zonas de Lima según coordenadas aproximadas
    if (lat > -11.85 && lng < -77.0) return 'Carabayllo';
    if (lat > -11.90 && lat <= -11.85 && lng < -77.0) return 'San Martín de Porres';
    if (lat > -11.95 && lat <= -11.90) return 'Los Olivos';
    if (lat > -12.00 && lat <= -11.95) return 'Independencia';
    if (lat > -12.05 && lat <= -12.00 && lng < -77.05) return 'Lima Centro';
    if (lat > -12.10 && lat <= -12.05 && lng > -77.05) return 'San Isidro';
    if (lat > -12.15 && lat <= -12.10 && lng > -77.05) return 'Miraflores';
    if (lat > -12.10 && lat <= -12.05 && lng < -77.05) return 'Jesús María';
    if (lat > -12.20 && lat <= -12.15) return 'Surco';
    if (lng < -77.1) return 'Callao';
    return 'Lima Metropolitana';
  }

  static String _calculateRealisticPrice(Map<String, dynamic> tags, double lat, double lng) {
    final fee = tags['fee'];
    if (fee == 'no') return 'Gratis';
    
    String zone = _determineZoneFromCoordinates(lat, lng);
    
    // Precios según zona y tipo
    switch (zone) {
      case 'San Isidro':
      case 'Miraflores':
        return 'S/. 8';
      case 'Lima Centro':
        return 'S/. 6';
      case 'Jesús María':
      case 'Surco':
        return 'S/. 7';
      case 'Carabayllo':
      case 'San Martín de Porres':
      case 'Los Olivos':
        return 'S/. 3';
      case 'Callao':
        return 'S/. 4';
      default:
        return 'S/. 5';
    }
  }

  static String _estimateRealisticAvailability(Map<String, dynamic> tags) {
    final capacity = tags['capacity'];
    int maxCapacity = 50;
    
    if (capacity != null) {
      maxCapacity = int.tryParse(capacity.toString()) ?? 50;
    }
    
    // Simular disponibilidad realista (60-85% ocupación promedio)
    final random = DateTime.now().millisecondsSinceEpoch % 100;
    final occupationRate = 0.60 + (random / 100) * 0.25; // 60-85%
    final available = (maxCapacity * (1 - occupationRate)).round();
    
    return available.toString();
  }

  static String _estimateRealisticCapacity(Map<String, dynamic> tags) {
    if (tags['capacity'] != null) {
      return tags['capacity'].toString();
    }
    
    // Estimar según tipo de parking
    final parkingType = tags['parking'] ?? 'surface';
    switch (parkingType) {
      case 'surface':
        return '30';
      case 'multi-storey':
        return '150';
      case 'underground':
        return '80';
      default:
        return '50';
    }
  }

  static bool _determineAvailability(Map<String, dynamic> tags) {
    final available = int.tryParse(_estimateRealisticAvailability(tags)) ?? 0;
    return available > 0;
  }

  static double _calculateRating(Map<String, dynamic> tags) {
    double baseRating = 3.5;
    
    // Bonus por características
    if (tags['covered'] == 'yes') baseRating += 0.3;
    if (tags['surveillance'] == 'yes') baseRating += 0.2;
    if (tags['fee'] == 'no') baseRating += 0.4;
    if (tags['surface'] == 'paved') baseRating += 0.1;
    if (tags['lighting'] == 'yes') baseRating += 0.1;
    
    return math.min(baseRating, 5.0);
  }

  static List<String> _extractRealFeatures(Map<String, dynamic> tags) {
    List<String> features = [];
    
    // Características basadas en tags reales de OSM
    if (tags['covered'] == 'yes') features.add('Techado');
    if (tags['surveillance'] == 'yes' || tags['surveillance:type'] != null) features.add('Vigilancia 24h');
    if (tags['fee'] == 'no') features.add('Gratuito');
    if (tags['parking'] == 'underground') features.add('Subterráneo');
    if (tags['parking'] == 'multi-storey') features.add('Varios niveles');
    if (tags['access'] == 'customers') features.add('Solo clientes');
    if (tags['surface'] == 'paved') features.add('Pavimentado');
    if (tags['lighting'] == 'yes') features.add('Iluminado');
    if (tags['maxstay'] != null) features.add('Tiempo limitado');
    if (tags['operator'] != null) features.add('Operador: ${tags['operator']}');
    
    // Si no hay características específicas, agregar por defecto
    if (features.isEmpty) {
      features.addAll(['Estacionamiento público', 'Acceso vehicular']);
    }
    
    return features;
  }

  static String _buildDescription(Map<String, dynamic> tags) {
    List<String> descriptions = [];
    
    final parkingType = tags['parking'] ?? 'surface';
    switch (parkingType) {
      case 'surface':
        descriptions.add('Estacionamiento en superficie');
        break;
      case 'multi-storey':
        descriptions.add('Edificio de estacionamiento de varios pisos');
        break;
      case 'underground':
        descriptions.add('Estacionamiento subterráneo');
        break;
    }
    
    if (tags['operator'] != null) {
      descriptions.add('Operado por ${tags['operator']}');
    }
    
    if (tags['opening_hours'] != null) {
      descriptions.add('Horarios: ${tags['opening_hours']}');
    }
    
    return descriptions.join('. ');
  }

  static String _generateRealisticName(Map<String, dynamic> tags, double lat, double lng, dynamic id) {
    String zone = _determineZoneFromCoordinates(lat, lng);
    String street = tags['addr:street'] ?? '';
    String operator = tags['operator'] ?? '';
    String parkingType = tags['parking'] ?? 'surface';
    
    // Nombres realistas según contexto
    List<String> possibleNames = [];
    
    // Si tiene operador conocido
    if (operator.isNotEmpty) {
      possibleNames.add('$operator $zone');
      possibleNames.add('Estacionamiento $operator');
    }
    
    // Si tiene calle específica
    if (street.isNotEmpty) {
      possibleNames.add('Parking $street');
      possibleNames.add('Estacionamiento $street');
      possibleNames.add('Plaza de Estacionamiento $street');
    }
    
    // Nombres por zona y tipo
    switch (zone.toLowerCase()) {
      case 'san isidro':
      case 'miraflores':
        possibleNames.addAll([
          'Parking Premium $zone',
          'Estacionamiento Ejecutivo',
          'Plaza Parking $zone',
          'Centro de Estacionamiento $zone'
        ]);
        break;
      case 'lima centro':
      case 'centro':
        possibleNames.addAll([
          'Parking Centro Histórico',
          'Estacionamiento Plaza Mayor',
          'Parking Municipal',
          'Estacionamiento Público Centro'
        ]);
        break;
      case 'carabayllo':
      case 'santo domingo':
        possibleNames.addAll([
          'Parking Norte $zone',
          'Estacionamiento $zone',
          'Plaza de Autos $zone',
          'Parking Comercial $zone'
        ]);
        break;
      default:
        possibleNames.addAll([
          'Parking $zone',
          'Estacionamiento $zone',
          'Plaza de Estacionamiento',
          'Parking Municipal $zone'
        ]);
    }
    
    // Nombres según tipo de parking
    switch (parkingType) {
      case 'multi-storey':
        possibleNames.addAll([
          'Torre de Estacionamiento',
          'Edificio Parking',
          'Centro de Estacionamiento Vertical'
        ]);
        break;
      case 'underground':
        possibleNames.addAll([
          'Parking Subterráneo',
          'Estacionamiento Subsuelo',
          'Sótano de Estacionamiento'
        ]);
        break;
    }
    
    // Si hay características especiales
    if (tags['covered'] == 'yes') {
      possibleNames.add('Parking Techado $zone');
    }
    if (tags['surveillance'] == 'yes') {
      possibleNames.add('Parking Seguro $zone');
    }
    
    // Seleccionar nombre basado en ID para consistencia
    if (possibleNames.isNotEmpty) {
      int index = (id.toString().hashCode.abs()) % possibleNames.length;
      return possibleNames[index];
    }
    
    // Fallback con zona
    return 'Estacionamiento $zone';
  }

  // Función para obtener ubicación actual
  static Future<Position?> getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('Servicios de ubicación deshabilitados');
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('Permisos de ubicación denegados');
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print('Permisos de ubicación denegados permanentemente');
        return null;
      }

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      print('Error obteniendo ubicación: $e');
      return null;
    }
  }

  // Obtener parkings cercanos a una ubicación específica
  static Future<List<Map<String, dynamic>>> getNearbyParkings({
    double? userLat,
    double? userLng,
    double radiusKm = 3.0,
  }) async {
    // Si no hay ubicación del usuario, usar centro de Lima
    final double centerLat = userLat ?? -12.0464;
    final double centerLng = userLng ?? -77.0428;
    
    // Obtener datos y calcular distancias
    final parkings = await getParkingData();
    
    // Calcular distancias y agregar información de distancia
    for (var parking in parkings) {
      final double distance = _calculateDistance(
        centerLat, centerLng, 
        parking['lat'], parking['lng']
      );
      parking['distance'] = distance;
      parking['distanceText'] = distance < 1.0 
          ? '${(distance * 1000).round()} m'
          : '${distance.toStringAsFixed(1)} km';
    }
    
    // Filtrar por radio y ordenar por cercanía
    parkings.removeWhere((p) => p['distance'] > radiusKm);
    parkings.sort((a, b) => a['distance'].compareTo(b['distance']));
    
    return parkings;
  }

  // Calcular distancia entre dos puntos en km
  static double _calculateDistance(double lat1, double lng1, double lat2, double lng2) {
    const double earthRadius = 6371; // Radio de la Tierra en km
    
    final double dLat = (lat2 - lat1) * math.pi / 180;
    final double dLng = (lng2 - lng1) * math.pi / 180;
    
    final double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1 * math.pi / 180) * math.cos(lat2 * math.pi / 180) *
        math.sin(dLng / 2) * math.sin(dLng / 2);
    
    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    
    return earthRadius * c;
  }
}