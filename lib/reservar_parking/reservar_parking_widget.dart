import '/flutter_flow/flutter_flow_drop_down.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/form_field_controller.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'reservar_parking_model.dart';
export 'reservar_parking_model.dart';

class ReservarParkingWidget extends StatefulWidget {
  const ReservarParkingWidget({super.key});

  static String routeName = 'reservar_parking';
  static String routePath = '/reservarParking';

  @override
  State<ReservarParkingWidget> createState() => _ReservarParkingWidgetState();
}

class _ReservarParkingWidgetState extends State<ReservarParkingWidget> {
  late ReservarParkingModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  double basePrice = 15.0;
  int hours = 8;
  double extraServices = 0.0;
  Map<String, dynamic> parking = {};

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ReservarParkingModel());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // RECIBIR DATOS DEL PARKING
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args != null && args is Map<String, dynamic>) {
      setState(() {
        parking = args;
      });
      
      // Extraer precio base
      if (parking['price'] != null) {
        String priceStr = parking['price'].toString();
        RegExp regExp = RegExp(r'\d+');
        Match? match = regExp.firstMatch(priceStr);
        if (match != null) {
          setState(() {
            basePrice = double.tryParse(match.group(0)!) ?? 15.0;
          });
        }
      }
      
      print('Parking recibido: ${parking['name']}');
    }
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  void _calculateTotal() {
    setState(() {
      extraServices = 0;
      if (_model.checkboxValue1 == true) extraServices += 10;
      if (_model.checkboxValue2 == true) extraServices += 5;
      if (_model.checkboxValue3 == true) extraServices += 8;
    });
  }

  double get totalPrice => (basePrice * hours) + extraServices;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: Color(0xFFF8F9FA),
        floatingActionButton: Align(
          alignment: AlignmentDirectional(0.0, 1.0),
          child: Padding(
            padding: EdgeInsetsDirectional.fromSTEB(35.0, 0.0, 8.0, 16.0),
            child: Container(
              width: double.infinity,
              height: 56.0,
              decoration: BoxDecoration(
                color: Color(0xFF00BFA5),
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: FFButtonWidget(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Reserva Confirmada'),
                      content: Text(
                        'Tu estacionamiento "${parking['name'] ?? 'Parking'}" ha sido reservado por $hours horas.\n\nTotal: S/. ${totalPrice.toStringAsFixed(2)}'
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.pop(context);
                          },
                          child: Text('OK'),
                        ),
                      ],
                    ),
                  );
                },
                text: 'Reservar Ahora',
                options: FFButtonOptions(
                  width: double.infinity,
                  height: 50.0,
                  padding: EdgeInsets.all(8.0),
                  color: Color(0xFF00BFA5),
                  textStyle: TextStyle(
                    color: Colors.white,
                    fontSize: 18.0,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                  ),
                  elevation: 0.0,
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
            ),
          ),
        ),
        appBar: AppBar(
          backgroundColor: Colors.white,
          automaticallyImplyLeading: false,
          leading: FlutterFlowIconButton(
            borderRadius: 20.0,
            buttonSize: 40.0,
            icon: Icon(Icons.arrow_back, color: Color(0xFF2E2E2E), size: 24.0),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Reservar Estacionamiento',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2E2E2E),
            ),
          ),
          actions: [
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
              child: FlutterFlowIconButton(
                borderRadius: 20.0,
                buttonSize: 40.0,
                icon: Icon(Icons.favorite_border, color: Color(0xFF2E2E2E), size: 24.0),
                onPressed: () {},
              ),
            ),
          ],
          centerTitle: false,
          elevation: 0.0,
        ),
        body: SafeArea(
          top: true,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                // Imagen del parking
                Image.network(
                  'https://images.unsplash.com/photo-1590674899484-d5640e854abe?w=800',
                  width: double.infinity,
                  height: 200.0,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 200,
                    color: Colors.grey[300],
                    child: Icon(Icons.local_parking, size: 80, color: Colors.grey[600]),
                  ),
                ),
                
                // Card de información principal
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(16.0, 16.0, 16.0, 0.0),
                  child: Card(
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    color: Colors.white,
                    elevation: 2.0,
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      parking['name'] ?? 'Estacionamiento Central Plaza',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF2E2E2E),
                                      ),
                                    ),
                                    if (parking['rating'] != null)
                                      Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(0.0, 4.0, 0.0, 0.0),
                                        child: Row(
                                          children: [
                                            ...List.generate(
                                              5,
                                              (index) => Icon(
                                                index < (parking['rating'] ?? 0).floor()
                                                    ? Icons.star
                                                    : Icons.star_border,
                                                color: Colors.orange,
                                                size: 16.0,
                                              ),
                                            ),
                                            SizedBox(width: 4),
                                            Text(
                                              parking['rating']?.toStringAsFixed(1) ?? '4.2',
                                              style: TextStyle(color: Color(0xFF9E9E9E), fontSize: 14),
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              Text(
                                parking['price'] ?? 'S/. 15',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF00BFA5),
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 0.0, 0.0),
                            child: Row(
                              children: [
                                Icon(Icons.location_on, color: Color(0xFF9E9E9E), size: 18.0),
                                SizedBox(width: 8.0),
                                Expanded(
                                  child: Text(
                                    parking['address'] ?? parking['location'] ?? 'Av. Libertador 1234, Centro',
                                    style: TextStyle(color: Color(0xFF9E9E9E), fontSize: 14),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(0.0, 4.0, 0.0, 0.0),
                            child: Text(
                              'por hora',
                              style: TextStyle(color: Color(0xFF9E9E9E), fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                // Card Fecha y Hora
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(16.0, 16.0, 16.0, 0.0),
                  child: Card(
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    color: Colors.white,
                    elevation: 2.0,
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Seleccionar fecha y hora',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2E2E2E),
                            ),
                          ),
                          SizedBox(height: 16),
                          Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Color(0x4D00BFA5),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                'Duración total: $hours horas',
                                style: TextStyle(
                                  color: Color(0xFF00BFA5),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                // Card Detalles
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(16.0, 16.0, 16.0, 0.0),
                  child: Card(
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    color: Colors.white,
                    elevation: 2.0,
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Detalles',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2E2E2E),
                            ),
                          ),
                          SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Espacios disponibles', style: TextStyle(fontSize: 14)),
                              Text(
                                '${parking['available'] ?? '23'} de ${parking['total'] ?? '50'}',
                                style: TextStyle(
                                  color: Color(0xFF00BFA5),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          
                          // Servicios extras
                          CheckboxListTile(
                            value: _model.checkboxValue1 ?? false,
                            onChanged: (val) {
                              setState(() => _model.checkboxValue1 = val);
                              _calculateTotal();
                            },
                            title: Text('Lavado de auto (+S/. 10)', style: TextStyle(fontSize: 14)),
                            activeColor: Color(0xFF00BFA5),
                            controlAffinity: ListTileControlAffinity.leading,
                            contentPadding: EdgeInsets.zero,
                          ),
                          CheckboxListTile(
                            value: _model.checkboxValue2 ?? false,
                            onChanged: (val) {
                              setState(() => _model.checkboxValue2 = val);
                              _calculateTotal();
                            },
                            title: Text('Seguro adicional (+S/. 5)', style: TextStyle(fontSize: 14)),
                            activeColor: Color(0xFF00BFA5),
                            controlAffinity: ListTileControlAffinity.leading,
                            contentPadding: EdgeInsets.zero,
                          ),
                          CheckboxListTile(
                            value: _model.checkboxValue3 ?? false,
                            onChanged: (val) {
                              setState(() => _model.checkboxValue3 = val);
                              _calculateTotal();
                            },
                            title: Text('Carga eléctrica (+S/. 8)', style: TextStyle(fontSize: 14)),
                            activeColor: Color(0xFF00BFA5),
                            controlAffinity: ListTileControlAffinity.leading,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                // Card Resumen
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(16.0, 16.0, 16.0, 16.0),
                  child: Card(
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    color: Colors.white,
                    elevation: 2.0,
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Resumen',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2E2E2E),
                            ),
                          ),
                          SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Tiempo total', style: TextStyle(fontSize: 14)),
                              Text('$hours horas', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                            ],
                          ),
                          SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Estacionamiento', style: TextStyle(fontSize: 14)),
                              Text(
                                'S/. ${(basePrice * hours).toStringAsFixed(2)}',
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Servicios extras', style: TextStyle(fontSize: 14)),
                              Text(
                                'S/. ${extraServices.toStringAsFixed(2)}',
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 0.0, 8.0),
                            child: Divider(height: 1.0, thickness: 1.0, color: Color(0xFF9E9E9E)),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Total',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2E2E2E),
                                ),
                              ),
                              Text(
                                'S/. ${totalPrice.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF00BFA5),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
    );
  }
}