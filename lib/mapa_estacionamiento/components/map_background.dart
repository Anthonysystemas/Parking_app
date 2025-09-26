import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class MapBackground extends StatefulWidget {
  final List<Map<String, dynamic>> parkingData;
  final int selectedParkingIndex;
  final Function(int) onParkingTapped;
  final Position? currentPosition;

  const MapBackground({
    super.key,
    required this.parkingData,
    required this.selectedParkingIndex,
    required this.onParkingTapped,
    this.currentPosition,
  });

  @override
  State<MapBackground> createState() => _MapBackgroundState();
}

class _MapBackgroundState extends State<MapBackground> {
  final MapController _mapController = MapController();

  @override
  void didUpdateWidget(MapBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Si la posición actual cambió, centrar el mapa
    if (widget.currentPosition != null && 
        oldWidget.currentPosition != widget.currentPosition) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _mapController.move(
          LatLng(
            widget.currentPosition!.latitude,
            widget.currentPosition!.longitude,
          ),
          16.0, // Zoom más cercano cuando se actualiza ubicación
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              // Centro: ubicación del usuario si existe, sino primer parking, sino Lima Centro
              center: widget.currentPosition != null
                  ? LatLng(widget.currentPosition!.latitude, widget.currentPosition!.longitude)
                  : widget.parkingData.isNotEmpty 
                      ? LatLng(widget.parkingData[0]['lat'], widget.parkingData[0]['lng'])
                      : LatLng(-12.0464, -77.0428),
              zoom: 15.0,
              minZoom: 12.0,
              maxZoom: 19.0,
              interactiveFlags: InteractiveFlag.all, // Permite zoom y movimiento
            ),
            children: [
              // Capa de tiles del mapa
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.estacionamiento',
                maxZoom: 19,
              ),
              // Marcador de ubicación actual
              if (widget.currentPosition != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: LatLng(
                        widget.currentPosition!.latitude,
                        widget.currentPosition!.longitude,
                      ),
                      width: 30,
                      height: 30,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.3),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              // Marcadores de parking con información
              MarkerLayer(
                markers: _buildParkingMarkers(),
              ),
            ],
          ),
          
          // Controles de zoom mejorados
          Positioned(
            right: 16,
            bottom: 150,
            child: Column(
              children: [
                // Botón zoom in
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 10,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(25),
                      onTap: () {
                        final currentZoom = _mapController.zoom;
                        final newZoom = (currentZoom + 1).clamp(12.0, 19.0);
                        _mapController.move(_mapController.center, newZoom);
                        
                        // Feedback visual
                        HapticFeedback.selectionClick();
                      },
                      child: Icon(
                        Icons.add,
                        color: Color(0xFF00BFA6),
                        size: 24,
                      ),
                    ),
                  ),
                ),
                
                SizedBox(height: 12),
                
                // Botón zoom out
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 10,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(25),
                      onTap: () {
                        final currentZoom = _mapController.zoom;
                        final newZoom = (currentZoom - 1).clamp(12.0, 19.0);
                        _mapController.move(_mapController.center, newZoom);
                        
                        // Feedback visual
                        HapticFeedback.selectionClick();
                      },
                      child: Icon(
                        Icons.remove,
                        color: Color(0xFF00BFA6),
                        size: 24,
                      ),
                    ),
                  ),
                ),
                
                SizedBox(height: 12),
                
                // Botón ir a mi ubicación
                if (widget.currentPosition != null)
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Color(0xFF00BFA6),
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 10,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(25),
                        onTap: () {
                          _mapController.move(
                            LatLng(
                              widget.currentPosition!.latitude,
                              widget.currentPosition!.longitude,
                            ),
                            16.0,
                          );
                          
                          // Feedback visual
                          HapticFeedback.selectionClick();
                        },
                        child: Icon(
                          Icons.my_location,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Marker> _buildParkingMarkers() {
    List<Marker> markers = [];

    for (int i = 0; i < widget.parkingData.length; i++) {
      final parking = widget.parkingData[i];
      final isSelected = i == widget.selectedParkingIndex;
      
      // Solo mostrar si tiene coordenadas válidas
      if (parking['lat'] == null || parking['lng'] == null) continue;
      
      double lat = parking['lat'];
      double lng = parking['lng'];

      markers.add(
        Marker(
          point: LatLng(lat, lng),
          width: isSelected ? 80 : 50,
          height: isSelected ? 80 : 50,
          child: GestureDetector(
            onTap: () => widget.onParkingTapped(i),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Indicador de cercanía (solo para los 3 primeros)
                if (i < 3)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${i + 1}° más cerca',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                if (i < 3) SizedBox(height: 2),
                
                // Marcador principal
                Container(
                  width: isSelected ? 60 : 40,
                  height: isSelected ? 60 : 40,
                  decoration: BoxDecoration(
                    color: parking['isAvailable'] 
                        ? Colors.green.withOpacity(0.9)
                        : Colors.red.withOpacity(0.9),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? Colors.blue : Colors.white, 
                      width: isSelected ? 3 : 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.4),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.local_parking,
                        color: Colors.white,
                        size: isSelected ? 20 : 16,
                      ),
                      if (isSelected && parking['distanceText'] != null)
                        Text(
                          parking['distanceText'],
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 6,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],
                  ),
                ),
                
                // Información adicional cuando está seleccionado
                if (isSelected)
                  Container(
                    margin: EdgeInsets.only(top: 4),
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          parking['name'] ?? 'Parking',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (parking['price'] != null)
                          Text(
                            parking['price'],
                            style: TextStyle(
                              color: Colors.green[300],
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        if (parking['isAvailable'] == true && parking['available'] != null)
                          Text(
                            '${parking['available']} espacios',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                            ),
                          ),
                        if (parking['isAvailable'] == false)
                          Text(
                            'COMPLETO',
                            style: TextStyle(
                              color: Colors.red[300],
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    }

    return markers;
  }
}