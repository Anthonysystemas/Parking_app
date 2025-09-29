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
    if (widget.currentPosition != null && 
        oldWidget.currentPosition != widget.currentPosition) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _mapController.move(
          LatLng(
            widget.currentPosition!.latitude,
            widget.currentPosition!.longitude,
          ),
          16.0,
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
              center: widget.currentPosition != null
                  ? LatLng(widget.currentPosition!.latitude, widget.currentPosition!.longitude)
                  : widget.parkingData.isNotEmpty 
                      ? LatLng(widget.parkingData[0]['lat'], widget.parkingData[0]['lng'])
                      : LatLng(-12.0464, -77.0428),
              zoom: 15.0,
              minZoom: 12.0,
              maxZoom: 19.0,
              interactiveFlags: InteractiveFlag.all,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.estacionamiento',
                maxZoom: 19,
              ),
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
              MarkerLayer(
                markers: _buildParkingMarkers(),
              ),
            ],
          ),
          
          Positioned(
            right: 16,
            bottom: 150,
            child: Column(
              children: [
                _buildZoomButton(Icons.add, true),
                SizedBox(height: 12),
                _buildZoomButton(Icons.remove, false),
                SizedBox(height: 12),
                if (widget.currentPosition != null)
                  _buildLocationButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildZoomButton(IconData icon, bool zoomIn) {
    return Container(
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
            final currentZoom = _mapController.camera.zoom;
            final newZoom = zoomIn 
                ? (currentZoom + 1).clamp(12.0, 19.0)
                : (currentZoom - 1).clamp(12.0, 19.0);
            _mapController.move(_mapController.camera.center, newZoom);
            HapticFeedback.selectionClick();
          },
          child: Icon(icon, color: Color(0xFF00BFA6), size: 24),
        ),
      ),
    );
  }

  Widget _buildLocationButton() {
    return Container(
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
            HapticFeedback.selectionClick();
          },
          child: Icon(Icons.my_location, color: Colors.white, size: 24),
        ),
      ),
    );
  }

  List<Marker> _buildParkingMarkers() {
    List<Marker> markers = [];
    for (int i = 0; i < widget.parkingData.length; i++) {
      final parking = widget.parkingData[i];
      final isSelected = i == widget.selectedParkingIndex;
      
      if (parking['lat'] == null || parking['lng'] == null) continue;
      
      markers.add(
        Marker(
          point: LatLng(parking['lat'], parking['lng']),
          width: isSelected ? 80 : 50,
          height: isSelected ? 80 : 50,
          child: GestureDetector(
            onTap: () => widget.onParkingTapped(i),
            child: Container(
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
              child: Icon(
                Icons.local_parking,
                color: Colors.white,
                size: isSelected ? 20 : 16,
              ),
            ),
          ),
        ),
      );
    }
    return markers;
  }
}