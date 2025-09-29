import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '/flutter_flow/flutter_flow_theme.dart';

class SearchBarWidget extends StatefulWidget {
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final Function(String)? onSubmitted;
  final Function(Map<String, dynamic>)? onPlaceSelected;
  final VoidCallback? onLocationPressed;

  const SearchBarWidget({
    super.key,
    this.controller,
    this.focusNode,
    this.onSubmitted,
    this.onPlaceSelected,
    this.onLocationPressed,
  });

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  List<Map<String, dynamic>> _suggestions = [];
  bool _showSuggestions = false;
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();
  final Dio _dio = Dio();

  @override
  void initState() {
    super.initState();
    widget.controller?.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_onSearchChanged);
    _removeOverlay();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = widget.controller?.text ?? '';
    if (query.length >= 3) {
      _searchPlaces(query);
    } else {
      _removeOverlay();
    }
  }

  Future<void> _searchPlaces(String query) async {
    try {
      final suggestions = await _fetchMapboxSuggestions(query);
      
      if (suggestions.isNotEmpty) {
        setState(() {
          _suggestions = suggestions;
          _showSuggestions = true;
        });
        _showOverlay();
      } else {
        _removeOverlay();
      }
    } catch (e) {
      print('Error buscando lugares: $e');
      _removeOverlay();
    }
  }

  Future<List<Map<String, dynamic>>> _fetchMapboxSuggestions(String query) async {
    const accessToken = 'pk.eyJ1IjoiYW50aG9ueS1kZXYiLCJhIjoiY21mNXB4MjF6MDhlazJtcHdvdTM1Zno4NSJ9.4qAgBXzM7DLHCji3aUtq_Q';
    
    final url = 'https://api.mapbox.com/geocoding/v5/mapbox.places/${Uri.encodeComponent(query)}.json';
    
    try {
      final response = await _dio.get(
        url,
        queryParameters: {
          'access_token': accessToken,
          'proximity': '-77.0428,-12.0464',
          'country': 'pe',
          'language': 'es',
          'limit': 5,
          'types': 'address,poi,place,locality,neighborhood',
        },
      );

      if (response.statusCode == 200) {
        final features = response.data['features'] ?? [];
        
        return features.map<Map<String, dynamic>>((feature) {
          final center = feature['center'] ?? [0, 0];
          return {
            'name': feature['text'] ?? '',
            'address': feature['place_name'] ?? '',
            'lat': (center[1] as num).toDouble(),
            'lng': (center[0] as num).toDouble(),
            'type': feature['place_type']?[0] ?? 'address',
          };
        }).toList();
      }
    } catch (e) {
      print('Error en Mapbox Geocoding: $e');
    }
    
    return [];
  }

  void _showOverlay() {
    _removeOverlay();
    
    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: MediaQuery.of(context).size.width - 32,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0, 60),
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              constraints: BoxConstraints(maxHeight: 250),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                padding: EdgeInsets.symmetric(vertical: 8),
                itemCount: _suggestions.length,
                separatorBuilder: (context, index) => Divider(height: 1),
                itemBuilder: (context, index) {
                  final suggestion = _suggestions[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Color(0xFF00D4AA).withOpacity(0.1),
                      child: Icon(
                        _getIconForType(suggestion['type']),
                        color: Color(0xFF00D4AA),
                        size: 20,
                      ),
                    ),
                    title: Text(
                      suggestion['name'],
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Colors.black, // NEGRO
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      suggestion['address'],
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () {
                      widget.controller?.text = suggestion['name'];
                      widget.onPlaceSelected?.call(suggestion);
                      _removeOverlay();
                      FocusScope.of(context).unfocus();
                    },
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    setState(() {
      _showSuggestions = false;
      _suggestions = [];
    });
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'poi':
        return Icons.place;
      case 'address':
        return Icons.home;
      case 'locality':
      case 'place':
        return Icons.location_city;
      case 'neighborhood':
        return Icons.map;
      default:
        return Icons.location_on;
    }
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              blurRadius: 10,
              color: Color(0x1A000000),
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: TextFormField(
          controller: widget.controller,
          focusNode: widget.focusNode,
          onFieldSubmitted: (value) {
            widget.onSubmitted?.call(value);
            _removeOverlay();
          },
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: 'Buscar por distrito, zona o nombre...',
            hintStyle: TextStyle(
              color: Color(0xFF999999),
              fontSize: 16,
            ),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: Color(0xFF666666),
              size: 20,
            ),
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.controller?.text.isNotEmpty ?? false)
                  GestureDetector(
                    onTap: () {
                      widget.controller?.clear();
                      _removeOverlay();
                    },
                    child: Container(
                      margin: EdgeInsets.all(8),
                      child: Icon(
                        Icons.clear,
                        color: Color(0xFF666666),
                        size: 18,
                      ),
                    ),
                  ),
                GestureDetector(
                  onTap: widget.onLocationPressed,
                  child: Container(
                    margin: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Color(0xFF00D4AA),
                      shape: BoxShape.circle,
                    ),
                    padding: EdgeInsets.all(8),
                    child: Icon(
                      Icons.my_location_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
          style: TextStyle(
            fontSize: 16,
            color: Colors.black, // CAMBIO PRINCIPAL: NEGRO
            fontWeight: FontWeight.w500,
          ),
          cursorColor: Color(0xFF00D4AA),
        ),
      ),
    );
  }
}