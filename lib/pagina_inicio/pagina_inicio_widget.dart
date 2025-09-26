import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'pagina_inicio_model.dart';
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
  
  // Variables de estado
  int _selectedNavIndex = 0;
  String _currentLocation = 'Av. La Marina 890';
  bool _hasNotifications = true;
  int _notificationCount = 3;

  // Datos de ubicaciones recientes
  final List<Map<String, dynamic>> _recentLocations = [
    {
      'name': 'Centro Comercial Plaza Norte',
      'address': 'Av. Alfredo Mendiola 3698',
      'distance': '2.5 km',
      'availability': 'Disponible',
      'price': 'S/. 5.00/hora',
      'rating': 4.5,
    },
    {
      'name': 'Real Plaza Salaverry',
      'address': 'Av. Salaverry 2370',
      'distance': '3.2 km',
      'availability': 'Casi lleno',
      'price': 'S/. 6.00/hora',
      'rating': 4.2,
    },
    {
      'name': 'Centro Comercial Jockey Plaza',
      'address': 'Av. Javier Prado Este 4200',
      'distance': '5.1 km',
      'availability': 'Disponible',
      'price': 'S/. 8.00/hora',
      'rating': 4.8,
    },
  ];

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PaginaInicioModel());
    _model.textController ??= TextEditingController();
    _model.textFieldFocusNode ??= FocusNode();

    // Configurar animaciones
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _model.dispose();
    _animationController.dispose();
    super.dispose();
  }

  // Función para manejar búsqueda
  void _handleSearch() {
    String query = _model.textController.text.trim();
    if (query.isNotEmpty) {
      // Lógica de búsqueda
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Buscando: $query'),
          backgroundColor: Color(0xFF00BFA5),
          behavior: SnackBarBehavior.floating,
        ),
      );
      // Navegar a página de resultados
      // context.pushNamed(ResultadosWidget.routeName, extra: query);
    }
  }

  // Función para mostrar notificaciones
  void _showNotifications() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildNotificationSheet(),
    );
  }

  // Función para seleccionar ubicación
  void _selectLocation(Map<String, dynamic> location) {
    setState(() {
      _currentLocation = location['name'];
    });
    
    // Mostrar detalles de la ubicación
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildLocationDetailSheet(location),
    );
  }

  // Widget para el bottom sheet de notificaciones
  Widget _buildNotificationSheet() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            margin: EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Padding(
            padding: EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Notificaciones',
                  style: FlutterFlowTheme.of(context).headlineSmall.override(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E2E2E),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _hasNotifications = false;
                      _notificationCount = 0;
                    });
                    Navigator.pop(context);
                  },
                  child: Text('Marcar todo como leído'),
                ),
              ],
            ),
          ),

          // Lista de notificaciones
          Expanded(
            child: ListView.builder(
              itemCount: 3,
              itemBuilder: (context, index) {
                final notifications = [
                  {
                    'title': 'Reserva confirmada',
                    'message': 'Tu espacio en Plaza Norte está confirmado',
                    'time': '5 min',
                    'icon': Icons.check_circle,
                    'color': Colors.green,
                  },
                  {
                    'title': 'Espacio liberado',
                    'message': 'Nuevo espacio disponible en Jockey Plaza',
                    'time': '15 min',
                    'icon': Icons.local_parking,
                    'color': Color(0xFF00BFA5),
                  },
                  {
                    'title': 'Recordatorio',
                    'message': 'Tu reserva vence en 30 minutos',
                    'time': '1 hora',
                    'icon': Icons.access_time,
                    'color': Colors.orange,
                  },
                ];
                
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: notifications[index]['color'] as Color,
                    child: Icon(
                      notifications[index]['icon'] as IconData,
                      color: Colors.white,
                    ),
                  ),
                  title: Text(notifications[index]['title'] as String),
                  subtitle: Text(notifications[index]['message'] as String),
                  trailing: Text(
                    notifications[index]['time'] as String,
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Widget para el bottom sheet de detalles de ubicación
  Widget _buildLocationDetailSheet(Map<String, dynamic> location) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            margin: EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nombre y rating
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          location['name'],
                          style: FlutterFlowTheme.of(context).headlineSmall.override(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E2E2E),
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber, size: 20),
                          SizedBox(width: 4),
                          Text(location['rating'].toString()),
                        ],
                      ),
                    ],
                  ),
                  
                  SizedBox(height: 8),
                  
                  // Dirección
                  Text(
                    location['address'],
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  
                  SizedBox(height: 20),
                  
                  // Información detallada
                  _buildInfoCard('Distancia', location['distance'], Icons.location_on),
                  SizedBox(height: 12),
                  _buildInfoCard('Disponibilidad', location['availability'], Icons.local_parking),
                  SizedBox(height: 12),
                  _buildInfoCard('Precio', location['price'], Icons.payments),
                  
                  Spacer(),
                  
                  // Botones de acción
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            context.pushNamed(MapaEstacionamientoWidget.routeName);
                          },
                          icon: Icon(Icons.map),
                          label: Text('Ver en mapa'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Color(0xFF00BFA5),
                            side: BorderSide(color: Color(0xFF00BFA5)),
                            padding: EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            context.pushNamed(CalendarioWidget.routeName);
                          },
                          icon: Icon(Icons.calendar_today),
                          label: Text('Reservar'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF00BFA5),
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget para cards de información
  Widget _buildInfoCard(String title, String value, IconData icon) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Icon(icon, color: Color(0xFF00BFA5), size: 24),
          SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  color: Color(0xFF2E2E2E),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Widget para ubicaciones recientes mejorado
  Widget _buildLocationCard(Map<String, dynamic> location, int index) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300 + (index * 100)),
      margin: EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _selectLocation(location),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                blurRadius: 8,
                color: Color(0x1A000000),
                offset: Offset(0, 2),
                spreadRadius: 0,
              )
            ],
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                // Icono de estacionamiento
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Color(0xFF00BFA5),
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
                
                // Información
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              location['name'],
                              style: TextStyle(
                                color: Color(0xFF2E2E2E),
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: location['availability'] == 'Disponible' 
                                  ? Colors.green[50] 
                                  : Colors.orange[50],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              location['availability'],
                              style: TextStyle(
                                color: location['availability'] == 'Disponible' 
                                    ? Colors.green[700] 
                                    : Colors.orange[700],
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      SizedBox(height: 4),
                      
                      Text(
                        location['address'],
                        style: TextStyle(
                          color: Color(0xFF9E9E9E),
                          fontSize: 14,
                        ),
                      ),
                      
                      SizedBox(height: 8),
                      
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 14, color: Color(0xFF9E9E9E)),
                          SizedBox(width: 4),
                          Text(
                            location['distance'],
                            style: TextStyle(
                              color: Color(0xFF9E9E9E),
                              fontSize: 12,
                            ),
                          ),
                          SizedBox(width: 16),
                          Icon(Icons.payments, size: 14, color: Color(0xFF9E9E9E)),
                          SizedBox(width: 4),
                          Text(
                            location['price'],
                            style: TextStyle(
                              color: Color(0xFF00BFA5),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Spacer(),
                          Icon(Icons.star, size: 14, color: Colors.amber),
                          SizedBox(width: 2),
                          Text(
                            location['rating'].toString(),
                            style: TextStyle(
                              color: Color(0xFF2E2E2E),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
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
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: Color(0xFF00BFA5),
        body: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              // Header con gradiente
              Container(
                width: double.infinity,
                height: 280.0,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF00BFA5), Color(0xFF26C6DA)],
                    stops: [0.0, 1.0],
                    begin: AlignmentDirectional(1.0, -1.0),
                    end: AlignmentDirectional(-1.0, 1.0),
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header superior
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Icon(Icons.location_on, color: Colors.white, size: 20),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _currentLocation,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Stack(
                              children: [
                                FlutterFlowIconButton(
                                  borderRadius: 20.0,
                                  buttonSize: 40.0,
                                  icon: Icon(
                                    Icons.notifications_outlined,
                                    color: Colors.white,
                                    size: 24.0,
                                  ),
                                  onPressed: _showNotifications,
                                ),
                                if (_hasNotifications)
                                  Positioned(
                                    right: 8,
                                    top: 8,
                                    child: Container(
                                      padding: EdgeInsets.all(2),
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      constraints: BoxConstraints(
                                        minWidth: 16,
                                        minHeight: 16,
                                      ),
                                      child: Text(
                                        '$_notificationCount',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                        
                        // Título principal
                        Text(
                          'Encuentra el mejor\nespacio de\nestacionamiento',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              // Body principal
              Expanded(
                child: Container(
                  width: double.infinity,
                  margin: EdgeInsets.only(top: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 24),
                        
                        // Barra de búsqueda mejorada
                        Container(
                          height: 56,
                          decoration: BoxDecoration(
                            color: Color(0xFFF5F5F5),
                            boxShadow: [
                              BoxShadow(
                                blurRadius: 8,
                                color: Color(0x1A000000),
                                offset: Offset(0, 2),
                              )
                            ],
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              Padding(
                                padding: EdgeInsets.only(left: 16),
                                child: Icon(
                                  Icons.search,
                                  color: Color(0xFF9E9E9E),
                                  size: 24,
                                ),
                              ),
                              Expanded(
                                child: TextFormField(
                                  controller: _model.textController,
                                  focusNode: _model.textFieldFocusNode,
                                  onFieldSubmitted: (_) => _handleSearch(),
                                  decoration: InputDecoration(
                                    hintText: '¿Dónde quieres estacionar?',
                                    hintStyle: TextStyle(
                                      color: Color(0xFF9E9E9E),
                                      fontSize: 16,
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 16,
                                    ),
                                  ),
                                  style: TextStyle(
                                    color: Color(0xFF2E2E2E),
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              FlutterFlowIconButton(
                                borderRadius: 20,
                                buttonSize: 40,
                                icon: Icon(
                                  Icons.map_outlined,
                                  color: Color(0xFF00BFA5),
                                  size: 24,
                                ),
                                onPressed: () {
                                  context.pushNamed(MapaEstacionamientoWidget.routeName);
                                },
                              ),
                              SizedBox(width: 8),
                            ],
                          ),
                        ),
                        
                        SizedBox(height: 32),
                        
                        // Sección de ubicaciones recientes
                        Text(
                          'Ubicaciones recientes',
                          style: TextStyle(
                            color: Color(0xFF2E2E2E),
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        
                        SizedBox(height: 16),
                        
                        // Lista de ubicaciones
                        Expanded(
                          child: ListView.builder(
                            itemCount: _recentLocations.length,
                            itemBuilder: (context, index) {
                              return _buildLocationCard(_recentLocations[index], index);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              // Bottom Navigation mejorado
              Container(
                decoration: BoxDecoration(
                  color: Color(0xFF2E2E2E),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 8,
                      color: Color(0x1A000000),
                      offset: Offset(0, -2),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildNavItem(0, Icons.home, 'Inicio', () {
                          // Ya estamos en inicio
                        }),
                        _buildNavItem(1, Icons.calendar_today, 'Calendario', () {
                          context.pushNamed(CalendarioWidget.routeName);
                        }),
                        
                        // Botón central especial
                        GestureDetector(
                          onTap: _handleSearch,
                          child: Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: Color(0xFF00BFA5),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  blurRadius: 8,
                                  color: Color(0x3300BFA5),
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.search,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                        ),
                        
                        _buildNavItem(3, Icons.share, 'Compartir', () {
                          // Implementar compartir
                        }),
                        _buildNavItem(4, Icons.person_outline, 'Perfil', () {
                          // Navegar a perfil
                        }),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label, VoidCallback onTap) {
    bool isSelected = index == _selectedNavIndex;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedNavIndex = index;
        });
        onTap();
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? Color(0xFF00BFA5) : Color(0xFF9E9E9E),
            size: 28,
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Color(0xFF00BFA5) : Color(0xFF9E9E9E),
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}