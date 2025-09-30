import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'dart:ui';
import '../reservar_parking/reservar_parking_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'mapa_estacionamiento_model.dart';
import 'components/map_background.dart';
import 'services/parking_api_service.dart';
import 'package:geolocator/geolocator.dart';
export 'mapa_estacionamiento_model.dart';

class MapaEstacionamientoWidget extends StatefulWidget {
  const MapaEstacionamientoWidget({super.key});

  static String routeName = 'mapa_estacionamiento';
  static String routePath = '/mapaEstacionamiento';

  @override
  State<MapaEstacionamientoWidget> createState() =>
      _MapaEstacionamientoWidgetState();
}

class _MapaEstacionamientoWidgetState extends State<MapaEstacionamientoWidget> {
  late MapaEstacionamientoModel _model;
  int selectedParkingIndex = -1;
  List<Map<String, dynamic>> parkingData = [];
  bool isLoading = true;
  Position? currentPosition;
  Map<String, dynamic>? pendingSelectedParking;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => MapaEstacionamientoModel());

    _model.textController ??= TextEditingController();
    _model.textFieldFocusNode ??= FocusNode();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // RECIBIR parking seleccionado desde PaginaInicio
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args != null && args is Map<String, dynamic>) {
      final selectedParking = args['selectedParking'] as Map<String, dynamic>?;
      final userPosition = args['userPosition'] as Position?;
      
      if (userPosition != null) {
        currentPosition = userPosition;
      }
      
      // Guardar el parking para seleccionarlo después de cargar los datos
      if (selectedParking != null) {
        pendingSelectedParking = selectedParking;
      }
    }
    
    // Cargar parkings
    if (parkingData.isEmpty) {
      _loadNearbyParkings();
    }
  }

 void _loadNearbyParkings() async {
  setState(() {
    isLoading = true;
  });

  try {
    // Si no tenemos posición, intentar obtenerla
    if (currentPosition == null) {
      currentPosition = await ParkingApiService.getCurrentLocation();
    }
    
    final nearbyParkings = await ParkingApiService.getNearbyParkings(
      userLat: currentPosition?.latitude,
      userLng: currentPosition?.longitude,
      radiusKm: 5.0,
    );
    
    if (mounted) {
      setState(() {
        parkingData = nearbyParkings;
        isLoading = false;
      });
      
      // IMPORTANTE: Seleccionar el parking DESPUÉS de cargar los datos
      if (pendingSelectedParking != null && parkingData.isNotEmpty) {
        // Esperar un frame para que el mapa se renderice
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _selectPendingParking();
        });
      }
      
      if (currentPosition != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Encontrados ${parkingData.length} parkings cercanos'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  } catch (e) {
    print('Error cargando parkings: $e');
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }
}
  // Método para seleccionar el parking pendiente
  void _selectPendingParking() {
    if (pendingSelectedParking == null || parkingData.isEmpty) return;
    
    // Buscar el parking por ID o nombre
    int index = parkingData.indexWhere((p) => 
      p['id'] == pendingSelectedParking!['id'] || 
      p['name'] == pendingSelectedParking!['name']
    );
    
    if (index >= 0) {
      setState(() {
        selectedParkingIndex = index;
      });
      
      // Limpiar el parking pendiente
      pendingSelectedParking = null;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('Parking seleccionado en el mapa'),
            ],
          ),
          backgroundColor: Color(0xFF00BFA5),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void selectParking(int index) {
    setState(() {
      selectedParkingIndex = index;
    });
  }

  void _searchParkings(String query) async {
    if (query.isEmpty) {
      _loadNearbyParkings();
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final filteredParkings = parkingData.where((parking) {
        final name = parking['name']?.toString().toLowerCase() ?? '';
        final location = parking['location']?.toString().toLowerCase() ?? '';
        final address = parking['address']?.toString().toLowerCase() ?? '';
        final searchTerm = query.toLowerCase();
        
        return name.contains(searchTerm) || 
               location.contains(searchTerm) || 
               address.contains(searchTerm);
      }).toList();

      if (filteredParkings.isNotEmpty) {
        setState(() {
          parkingData = filteredParkings;
          isLoading = false;
          selectedParkingIndex = -1;
        });
        return;
      }

      final zoneCoordinates = _getCoordinatesForZone(query.toLowerCase());
      if (zoneCoordinates != null) {
        final nearbyParkings = await ParkingApiService.getNearbyParkings(
          userLat: zoneCoordinates['lat'],
          userLng: zoneCoordinates['lng'],
          radiusKm: 2.0,
        );
        
        setState(() {
          parkingData = nearbyParkings;
          isLoading = false;
          selectedParkingIndex = -1;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Encontrados ${parkingData.length} parkings en $query'),
            backgroundColor: Color(0xFF00BFA5),
          ),
        );
      } else {
        setState(() {
          isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No se encontraron parkings para "$query"'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error en la búsqueda: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Map<String, double>? _getCoordinatesForZone(String zone) {
    final Map<String, Map<String, double>> zones = {
      'carabayllo': {'lat': -11.8577, 'lng': -77.0428},
      'santo domingo': {'lat': -11.8577, 'lng': -77.0428},
      'san martin de porres': {'lat': -11.8876, 'lng': -77.0697},
      'los olivos': {'lat': -11.9058, 'lng': -77.0725},
      'independencia': {'lat': -11.9589, 'lng': -77.0544},
      'lima centro': {'lat': -12.0464, 'lng': -77.0428},
      'centro': {'lat': -12.0464, 'lng': -77.0428},
      'jesús maría': {'lat': -12.0685, 'lng': -77.0641},
      'jesus maria': {'lat': -12.0685, 'lng': -77.0641},
      'san isidro': {'lat': -12.0966, 'lng': -77.0365},
      'miraflores': {'lat': -12.1219, 'lng': -77.0365},
      'surco': {'lat': -12.1509, 'lng': -77.0175},
      'santiago de surco': {'lat': -12.1509, 'lng': -77.0175},
      'callao': {'lat': -12.0658, 'lng': -77.1589},
      'comas': {'lat': -11.9304, 'lng': -77.0573},
      'puente piedra': {'lat': -11.8319, 'lng': -77.0654},
      'san juan de lurigancho': {'lat': -11.9903, 'lng': -76.9981},
      'ate': {'lat': -12.0517, 'lng': -76.9206},
      'santa anita': {'lat': -12.0517, 'lng': -76.9738},
    };
    
    for (String zoneKey in zones.keys) {
      if (zoneKey.contains(zone) || zone.contains(zoneKey)) {
        return zones[zoneKey];
      }
    }
    
    return null;
  }

  void _goToUserLocation() async {
    setState(() {
      isLoading = true;
    });
    
    try {
      Position? position = await ParkingApiService.getCurrentLocation();
      if (position != null) {
        setState(() {
          currentPosition = position;
          isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.location_on, color: Colors.white),
                SizedBox(width: 8),
                Text('Ubicación actualizada con precisión'),
              ],
            ),
            backgroundColor: Color(0xFF00BFA5),
            duration: Duration(seconds: 2),
          ),
        );
        
        _loadNearbyParkings();
      } else {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error, color: Colors.white),
                SizedBox(width: 8),
                Text('No se pudo obtener tu ubicación exacta'),
              ],
            ),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Reintentar',
              textColor: Colors.white,
              onPressed: _goToUserLocation,
            ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 8),
              Expanded(child: Text('Error: ${e.toString()}')),
            ],
          ),
          backgroundColor: Colors.red,
          action: SnackBarAction(
            label: 'Reintentar',
            textColor: Colors.white,
            onPressed: _goToUserLocation,
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        body: SafeArea(
          top: true,
          child: Container(
            width: double.infinity,
            height: double.infinity,
            child: Stack(
              children: [
                if (isLoading)
                  Container(
                    color: Colors.white,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(color: Color(0xFF00BFA5)),
                          SizedBox(height: 20),
                          Text(
                            'Buscando parkings cercanos...',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF00BFA5),
                            ),
                          ),
                          if (currentPosition == null) ...[
                            Padding(
                              padding: EdgeInsets.only(top: 10),
                              child: Text(
                                'Obteniendo ubicación...',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                            SizedBox(height: 20),
                            ElevatedButton.icon(
                              onPressed: _loadNearbyParkings,
                              icon: Icon(Icons.refresh),
                              label: Text('Reintentar'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF00BFA5),
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  )
                else
                  MapBackground(
                    parkingData: parkingData,
                    selectedParkingIndex: selectedParkingIndex,
                    onParkingTapped: (index) => selectParking(index),
                    currentPosition: currentPosition,
                  ),
                
              if (!isLoading && selectedParkingIndex >= 0 && selectedParkingIndex < parkingData.length)
  Positioned(
    bottom: 0,
    left: 0,
    right: 0,
    child: Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.6, // Aumentado de 0.45 a 0.6
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 15,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header fijo
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      parkingData[selectedParkingIndex]['price'] ?? 'S/. --',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF00BFA5),
                      ),
                    ),
                    Text(
                      'por hora',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: IconButton(
                    onPressed: () {
                      setState(() {
                        selectedParkingIndex = -1;
                      });
                    },
                    icon: Icon(Icons.close, size: 18, color: Colors.grey[600]),
                    padding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ),
          
          // Contenido con scroll
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    parkingData[selectedParkingIndex]['name'] ?? 'Estacionamiento',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  
                  SizedBox(height: 8),
                  
                  Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.grey[600], size: 18),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          parkingData[selectedParkingIndex]['location'] ?? 
                          parkingData[selectedParkingIndex]['address'] ?? 
                          'Ubicación no disponible',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: 12),
                  
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Color(0xFF00BFA5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.access_time, color: Colors.white, size: 14),
                            SizedBox(width: 4),
                            Text(
                              parkingData[selectedParkingIndex]['opening_hours'] ?? '24h',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      SizedBox(width: 12),
                      
                      if (parkingData[selectedParkingIndex]['distanceText'] != null)
                        Row(
                          children: [
                            Icon(Icons.directions_walk, color: Color(0xFF00BFA5), size: 16),
                            SizedBox(width: 4),
                            Text(
                              parkingData[selectedParkingIndex]['distanceText'] ?? '',
                              style: TextStyle(
                                color: Color(0xFF00BFA5),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                  
                  SizedBox(height: 16),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: parkingData[selectedParkingIndex]['isAvailable'] ?? true 
                                      ? Color(0xFF00BFA5) 
                                      : Colors.red,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Espacios disponibles',
                                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                              ),
                            ],
                          ),
                          SizedBox(height: 4),
                          Text(
                            parkingData[selectedParkingIndex]['isAvailable'] ?? true
                                ? '${parkingData[selectedParkingIndex]['available'] ?? '15'} de ${parkingData[selectedParkingIndex]['total'] ?? '50'} disponibles'
                                : 'No hay espacios disponibles',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      if (parkingData[selectedParkingIndex]['rating'] != null)
                        Row(
                          children: [
                            Icon(Icons.star, color: Colors.amber, size: 16),
                            SizedBox(width: 4),
                            Text(
                              parkingData[selectedParkingIndex]['rating'].toStringAsFixed(1),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                  
                  if (parkingData[selectedParkingIndex]['features'] != null && 
                      parkingData[selectedParkingIndex]['features'].isNotEmpty) ...[
                    SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: parkingData[selectedParkingIndex]['features']
                          .take(4)
                          .map<Widget>((feature) => Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Color(0xFF00BFA5).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          feature.toString(),
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF00BFA5),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ))
                      .toList(),
                    ),
                  ],
                  
                  if (parkingData[selectedParkingIndex]['description'] != null) ...[
                    SizedBox(height: 8),
                    Text(
                      parkingData[selectedParkingIndex]['description'],
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
          
          // Botón RESERVAR fijo al fondo
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: parkingData[selectedParkingIndex]['isAvailable'] ?? true
                      ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ReservarParkingWidget(),
                              settings: RouteSettings(
                                arguments: parkingData[selectedParkingIndex],
                              ),
                            ),
                          );
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF00BFA5),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                    disabledBackgroundColor: Colors.grey[300],
                  ),
                  child: Text(
                    parkingData[selectedParkingIndex]['isAvailable'] ?? true 
                      ? 'RESERVAR' 
                      : 'NO DISPONIBLE',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}