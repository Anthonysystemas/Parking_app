import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class RealMapWidget extends StatelessWidget {
  final double centerLat;
  final double centerLng;
  final List<Map<String, dynamic>> parkings;
  final int selectedParkingIndex;
  final Function(int) onParkingTap;

  const RealMapWidget({
    Key? key,
    required this.centerLat,
    required this.centerLng,
    required this.parkings,
    required this.selectedParkingIndex,
    required this.onParkingTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      options: MapOptions(
        initialCenter: LatLng(centerLat, centerLng),
        initialZoom: 15.0,
        minZoom: 10.0,
        maxZoom: 18.0,
        interactionOptions: InteractionOptions(
          flags: InteractiveFlag.all,
        ),
      ),
      children: [
        // Capa de tiles de OpenStreetMap
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.parking_app',
          maxZoom: 18,
        ),
        
        // Marcadores de estacionamientos
        MarkerLayer(
          markers: [
            // Marcador de ubicación del usuario
            Marker(
              point: LatLng(centerLat, centerLng),
              width: 40,
              height: 40,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 8,
                      color: Colors.blue.withOpacity(0.3),
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.person_pin,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
            
            // Marcadores de estacionamientos
            ...parkings.asMap().entries.map((entry) {
              final index = entry.key;
              final parking = entry.value;
              final isSelected = index == selectedParkingIndex;
              
              return Marker(
                point: LatLng(parking['lat'], parking['lng']),
                width: isSelected ? 60 : 50,
                height: isSelected ? 70 : 60,
                child: GestureDetector(
                  onTap: () => onParkingTap(index),
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 200),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Sombra
                        Positioned(
                          bottom: 0,
                          child: Container(
                            width: isSelected ? 25 : 20,
                            height: 6,
                            decoration: BoxDecoration(
                              color: Colors.black26,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        
                        // Marcador principal
                        Positioned(
                          top: 0,
                          child: Container(
                            width: isSelected ? 50 : 40,
                            height: isSelected ? 50 : 40,
                            decoration: BoxDecoration(
                              color: parking['isAvailable'] 
                                  ? Color(0xFF00D4AA) 
                                  : Color(0xFFFF4444),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: isSelected ? 3 : 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  blurRadius: isSelected ? 12 : 8,
                                  color: (parking['isAvailable'] 
                                      ? Color(0xFF00D4AA) 
                                      : Color(0xFFFF4444))
                                      .withOpacity(0.5),
                                  offset: Offset(0, isSelected ? 4 : 2),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                'P',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: isSelected ? 20 : 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Precio o estado
                        Positioned(
                          bottom: isSelected ? 12 : 8,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: isSelected ? 8 : 6, 
                              vertical: 2
                            ),
                            decoration: BoxDecoration(
                              color: parking['isAvailable'] ? Colors.white : Colors.red,
                              borderRadius: BorderRadius.circular(12),
                              border: parking['isAvailable'] 
                                  ? Border.all(color: Color(0xFF00D4AA))
                                  : null,
                            ),
                            child: Text(
                              parking['isAvailable'] 
                                  ? parking['price'] 
                                  : 'LLENO',
                              style: TextStyle(
                                color: parking['isAvailable'] 
                                    ? Color(0xFF00D4AA) 
                                    : Colors.white,
                                fontSize: isSelected ? 11 : 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ],
        ),
        
        // Capa de círculo de búsqueda (opcional)
        CircleLayer(
          circles: [
            CircleMarker(
              point: LatLng(centerLat, centerLng),
              radius: 2000, // 2km de radio
              useRadiusInMeter: true,
              color: Color(0xFF00D4AA).withOpacity(0.1),
              borderColor: Color(0xFF00D4AA).withOpacity(0.3),
              borderStrokeWidth: 2,
            ),
          ],
        ),
      ],
    );
  }
}