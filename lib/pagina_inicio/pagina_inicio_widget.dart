import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart';
import 'pagina_inicio_model.dart';
import '../mapa_estacionamiento/mapa_estacionamiento_widget.dart';
import '/mapa_estacionamiento/services/parking_api_service.dart';
import '/mapa_estacionamiento/services/location_service.dart';
export 'pagina_inicio_model.dart';

class PaginaInicioWidget extends StatefulWidget {
  const PaginaInicioWidget({super.key});

  static String routeName = 'pagina_inicio';
  static String routePath = '/paginaInicio';

  @override
  State<PaginaInicioWidget> createState() => _PaginaInicioWidgetState();
}

class _PaginaInicioWidgetState extends State<PaginaInicioWidget> 
    with SingleTickerProviderStateMixin {
  late PaginaInicioModel _model;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  
  String _currentLocation = 'Obteniendo ubicación...';
  bool _isLoadingLocation = true;
  Position? _currentPosition;
  List<Map<String, dynamic>> _nearbyParkings = [];

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PaginaInicioModel());
    _model.textController ??= TextEditingController();
    _model.textFieldFocusNode ??= FocusNode();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();

    _loadLocationAndParkings();
  }

  @override
  void dispose() {
    _model.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadLocationAndParkings() async {
    setState(() {
      _isLoadingLocation = true;
      _currentLocation = 'Obteniendo ubicación GPS...';
    });

    try {
      Position? position = await LocationService.getCurrentLocation();
      
      if (position != null) {
        String locationName = await _getDetailedLocationName(position);
        
        setState(() {
          _currentPosition = position;
          _currentLocation = locationName;
        });

        final parkings = await ParkingApiService.getNearbyParkings(
          userLat: position.latitude,
          userLng: position.longitude,
          radiusKm: 5.0,
        );

        parkings.sort((a, b) => (a['distance'] as double).compareTo(b['distance'] as double));
        final closestParkings = parkings.take(5).toList();

        setState(() {
          _nearbyParkings = closestParkings;
          _isLoadingLocation = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 8),
                  Text('${closestParkings.length} parkings encontrados'),
                ],
              ),
              backgroundColor: Color(0xFF00BFA5),
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        setState(() {
          _currentLocation = 'Lima, Perú';
          _isLoadingLocation = false;
        });

        final parkings = await ParkingApiService.getNearbyParkings(
          userLat: -12.0464,
          userLng: -77.0428,
          radiusKm: 5.0,
        );

        parkings.sort((a, b) => (a['distance'] as double).compareTo(b['distance'] as double));

        setState(() {
          _nearbyParkings = parkings.take(5).toList();
        });
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        _isLoadingLocation = false;
        _currentLocation = 'Lima, Perú';
      });
    }
  }

  Future<String> _getDetailedLocationName(Position position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude, 
        position.longitude,
      );
      
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        
        String street = place.street ?? '';
        String subLocality = place.subLocality ?? '';
        String locality = place.locality ?? 'Lima';
        
        if (street.isNotEmpty && subLocality.isNotEmpty) {
          return '$street, $subLocality, $locality';
        } else if (subLocality.isNotEmpty) {
          return '$subLocality, $locality';
        } else if (locality.isNotEmpty) {
          return locality;
        }
      }
      
      return 'Lima, Perú';
    } catch (e) {
      print('Error geocoding: $e');
      return _getFallbackLocationName(position);
    }
  }

  String _getFallbackLocationName(Position position) {
    double lat = position.latitude;
    double lng = position.longitude;
    
    if (lat >= -12.08 && lat <= -12.05 && lng >= -77.08 && lng <= -77.02) {
      return 'San Isidro, Lima';
    } else if (lat >= -12.13 && lat <= -12.10 && lng >= -77.05 && lng <= -77.01) {
      return 'Miraflores, Lima';
    } else if (lat >= -12.16 && lat <= -12.13 && lng >= -77.03 && lng <= -76.97) {
      return 'Santiago de Surco, Lima';
    } else if (lat >= -12.07 && lat <= -12.03 && lng >= -77.08 && lng <= -77.02) {
      return 'Lima Centro';
    } else if (lat >= -11.95 && lat <= -11.92 && lng >= -77.08 && lng <= -77.04) {
      return 'Los Olivos, Lima';
    } else if (lat >= -11.89 && lat <= -11.86 && lng >= -77.08 && lng <= -77.04) {
      return 'San Martín de Porres, Lima';
    } else if (lat >= -11.88 && lat <= -11.83 && lng >= -77.06 && lng <= -77.02) {
      return 'Carabayllo, Lima';
    } else if (lat >= -12.08 && lat <= -12.04 && lng >= -77.18 && lng <= -77.12) {
      return 'Callao';
    } else if (lat >= -12.20 && lat <= -12.16 && lng >= -76.95 && lng <= -76.90) {
      return 'La Molina, Lima';
    } else if (lat >= -11.98 && lat <= -11.94 && lng >= -77.06 && lng <= -77.00) {
      return 'San Juan de Lurigancho, Lima';
    }
    
    return 'Lima, Perú';
  }

  void _goToMapWithParking(Map<String, dynamic> parking) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MapaEstacionamientoWidget(),
        settings: RouteSettings(
          arguments: {
            'selectedParking': parking,
            'userPosition': _currentPosition,
          },
        ),
      ),
    );
  }

  void _showParkingOptions(Map<String, dynamic> parking) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 20),
            Text(
              parking['name'] ?? 'Estacionamiento',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              parking['address'] ?? parking['location'] ?? 'Sin dirección',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
              textAlign: TextAlign.center,
            ),
            
            SizedBox(height: 16),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    Icon(Icons.location_on, color: Color(0xFF00BFA5), size: 20),
                    SizedBox(height: 4),
                    Text(
                      parking['distanceText'] ?? 'N/A',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Icon(Icons.payments, color: Color(0xFF00BFA5), size: 20),
                    SizedBox(height: 4),
                    Text(
                      parking['price'] ?? 'S/. --',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                if (parking['rating'] != null)
                  Column(
                    children: [
                      Icon(Icons.star, color: Colors.amber, size: 20),
                      SizedBox(height: 4),
                      Text(
                        parking['rating'].toStringAsFixed(1),
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
              ],
            ),
            
            SizedBox(height: 24),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _goToMapWithParking(parking);
                },
                icon: Icon(Icons.map, size: 20),
                label: Text('Ver en mapa'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF00BFA5),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
              ),
            ),
            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationCard(Map<String, dynamic> parking, int index) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showParkingOptions(parking),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                blurRadius: 8,
                color: Color(0x1A000000),
                offset: Offset(0, 2),
              )
            ],
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: parking['isAvailable'] ?? true 
                        ? Color(0xFF00BFA5) 
                        : Colors.grey,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      'P',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                
                SizedBox(width: 16),
                
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              parking['name'] ?? 'Estacionamiento',
                              style: TextStyle(
                                color: Color(0xFF2E2E2E),
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: parking['isAvailable'] ?? true 
                                  ? Colors.green[50] 
                                  : Colors.red[50],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              parking['isAvailable'] ?? true ? 'Disponible' : 'Lleno',
                              style: TextStyle(
                                color: parking['isAvailable'] ?? true 
                                    ? Colors.green[700] 
                                    : Colors.red[700],
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      SizedBox(height: 4),
                      
                      Text(
                        parking['address'] ?? parking['location'] ?? 'Lima',
                        style: TextStyle(
                          color: Color(0xFF9E9E9E),
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      
                      SizedBox(height: 8),
                      
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 14, color: Color(0xFF9E9E9E)),
                          SizedBox(width: 4),
                          Text(
                            parking['distanceText'] ?? 'N/A',
                            style: TextStyle(
                              color: Color(0xFF9E9E9E),
                              fontSize: 12,
                            ),
                          ),
                          SizedBox(width: 16),
                          Icon(Icons.payments, size: 14, color: Color(0xFF9E9E9E)),
                          SizedBox(width: 4),
                          Text(
                            parking['price'] ?? 'S/. --',
                            style: TextStyle(
                              color: Color(0xFF00BFA5),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Spacer(),
                          if (parking['rating'] != null) ...[
                            Icon(Icons.star, size: 14, color: Colors.amber),
                            SizedBox(width: 2),
                            Text(
                              parking['rating'].toStringAsFixed(1),
                              style: TextStyle(
                                color: Color(0xFF2E2E2E),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                
                SizedBox(width: 8),
                
                Icon(
                  Icons.chevron_right,
                  color: Color(0xFF9E9E9E),
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: Color(0xFF00BFA5),
        body: Column(
          children: [
            Container(
              width: double.infinity,
              height: 260.0,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF00BFA5), Color(0xFF26C6DA)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                if (_isLoadingLocation)
                                  SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                else
                                  Icon(Icons.location_on, color: Colors.white, size: 20),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _currentLocation,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          FlutterFlowIconButton(
                            borderRadius: 20,
                            buttonSize: 40,
                            icon: Icon(Icons.refresh, color: Colors.white, size: 24),
                            onPressed: _loadLocationAndParkings,
                          ),
                        ],
                      ),
                      Text(
                        'Encuentra el mejor\nespacio de\nestacionamiento',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            Expanded(
              child: Container(
                margin: EdgeInsets.only(top: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(24, 24, 24, 0),
                      child: Column(
                        children: [
                          Container(
                            height: 56,
                            decoration: BoxDecoration(
                              color: Color(0xFFF5F5F5),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  blurRadius: 8,
                                  color: Color(0x1A000000),
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(left: 16),
                                  child: Icon(Icons.search, color: Color(0xFF9E9E9E), size: 24),
                                ),
                                Expanded(
                                  child: TextField(
                                    controller: _model.textController,
                                    decoration: InputDecoration(
                                      hintText: '¿Dónde quieres estacionar?',
                                      hintStyle: TextStyle(color: Color(0xFF9E9E9E), fontSize: 16),
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                    ),
                                    style: TextStyle(color: Color(0xFF2E2E2E), fontSize: 16),
                                  ),
                                ),
                                FlutterFlowIconButton(
                                  borderRadius: 20,
                                  buttonSize: 40,
                                  icon: Icon(Icons.map_outlined, color: Color(0xFF00BFA5), size: 24),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => MapaEstacionamientoWidget(),
                                      ),
                                    );
                                  },
                                ),
                                SizedBox(width: 8),
                              ],
                            ),
                          ),
                          
                          SizedBox(height: 24),
                          
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Parkings cercanos',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF2E2E2E),
                                ),
                              ),
                              if (_nearbyParkings.isNotEmpty)
                                Text(
                                  '${_nearbyParkings.length} encontrados',
                                  style: TextStyle(color: Color(0xFF00BFA5), fontSize: 14),
                                ),
                            ],
                          ),
                          
                          SizedBox(height: 16),
                        ],
                      ),
                    ),
                    
                    Expanded(
                      child: _isLoadingLocation
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircularProgressIndicator(color: Color(0xFF00BFA5)),
                                  SizedBox(height: 16),
                                  Text('Buscando parkings cercanos...'),
                                ],
                              ),
                            )
                          : _nearbyParkings.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.local_parking, size: 80, color: Colors.grey),
                                      SizedBox(height: 16),
                                      Text('No hay parkings cercanos'),
                                      SizedBox(height: 8),
                                      TextButton(
                                        onPressed: _loadLocationAndParkings,
                                        child: Text('Reintentar'),
                                      ),
                                    ],
                                  ),
                                )
                              : Scrollbar(
                                  thumbVisibility: true,
                                  child: ListView.builder(
                                    padding: EdgeInsets.fromLTRB(24, 0, 24, 24),
                                    itemCount: _nearbyParkings.length,
                                    physics: AlwaysScrollableScrollPhysics(),
                                    itemBuilder: (context, index) {
                                      return _buildLocationCard(_nearbyParkings[index], index);
                                    },
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
    );
  }
}