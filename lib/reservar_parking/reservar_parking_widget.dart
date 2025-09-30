import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'reservar_parking_model.dart';
export 'reservar_parking_model.dart';
import 'package:estacionamiento/TicketReserva/ticket_reserva.dart';

class ReservarParkingWidget extends StatefulWidget {
  const ReservarParkingWidget({super.key});
  // ... resto del código

  static String routeName = 'reservar_parking';
  static String routePath = '/reservarParking';

  @override
  State<ReservarParkingWidget> createState() => _ReservarParkingWidgetState();
}

class _ReservarParkingWidgetState extends State<ReservarParkingWidget> {
  late ReservarParkingModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  Map<String, dynamic> parking = {};
  double basePrice = 4.0;
  
  DateTime selectedDate = DateTime.now();
  TimeOfDay? startTime;
  TimeOfDay? endTime;
  double totalHours = 8.0;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ReservarParkingModel());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args != null && args is Map<String, dynamic>) {
      parking = args;
      
      if (parking['price'] != null) {
        String priceStr = parking['price'].toString();
        RegExp regExp = RegExp(r'\d+');
        Match? match = regExp.firstMatch(priceStr);
        if (match != null) {
          basePrice = double.tryParse(match.group(0)!) ?? 4.0;
        }
      }
    }
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Future<void> selectDate(BuildContext ctx) async {
    final picked = await showDatePicker(
      context: ctx,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 90)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Color(0xFF00BFA5),
            colorScheme: ColorScheme.light(primary: Color(0xFF00BFA5)),
            buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

  Future<void> selectStartTime(BuildContext ctx) async {
    final picked = await showTimePicker(
      context: ctx,
      initialTime: startTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Color(0xFF00BFA5),
            colorScheme: ColorScheme.light(primary: Color(0xFF00BFA5)),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      setState(() {
        startTime = picked;
        if (endTime != null) calculateHours();
      });
    }
  }

  Future<void> selectEndTime(BuildContext ctx) async {
    if (startTime == null) {
      ScaffoldMessenger.of(ctx).showSnackBar(
        SnackBar(content: Text('Selecciona primero la hora de entrada')),
      );
      return;
    }
    
    final picked = await showTimePicker(
      context: ctx,
      initialTime: endTime ?? TimeOfDay(hour: (startTime!.hour + 8) % 24, minute: 0),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Color(0xFF00BFA5),
            colorScheme: ColorScheme.light(primary: Color(0xFF00BFA5)),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      setState(() {
        endTime = picked;
        calculateHours();
      });
    }
  }

  void calculateHours() {
    if (startTime == null || endTime == null) return;
    
    double start = startTime!.hour + startTime!.minute / 60.0;
    double end = endTime!.hour + endTime!.minute / 60.0;
    
    if (end <= start) end += 24.0;
    
    setState(() {
      totalHours = end - start;
      if (totalHours < 1.0) totalHours = 1.0;
    });
  }

  double get totalPrice => basePrice * totalHours;

  void confirmReservation() {
    if (startTime == null || endTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Completa todos los horarios'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    // Generar código de reserva único
    final codigoReserva = 'PK${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
    
    // Navegar al ticket
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TicketReserva(
          parking: parking,
          selectedDate: selectedDate,
          startTime: startTime!,
          endTime: endTime!,
          totalHours: totalHours,
          totalPrice: totalPrice,
          codigoReserva: codigoReserva,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Reservar Estacionamiento', style: TextStyle(color: Colors.black, fontSize: 17)),
        actions: [
          IconButton(icon: Icon(Icons.favorite_border, color: Colors.black), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    height: 180,
                    color: Colors.grey[300],
                    child: Icon(Icons.local_parking, size: 80, color: Colors.grey[600]),
                  ),
                  
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16),
                    color: Colors.white,
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(parking['name'] ?? 'Estacionamiento 19', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
                              SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.star, color: Colors.amber, size: 14),
                                  Icon(Icons.star, color: Colors.amber, size: 14),
                                  Icon(Icons.star, color: Colors.amber, size: 14),
                                  Icon(Icons.star_half, color: Colors.amber, size: 14),
                                  Icon(Icons.star_border, color: Colors.amber, size: 14),
                                  SizedBox(width: 4),
                                  Text('3.5', style: TextStyle(fontSize: 13)),
                                ],
                              ),
                              SizedBox(height: 2),
                              Text('Lima', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('S/. 4-6', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF00BFA5))),
                            Text('por hora', style: TextStyle(fontSize: 10, color: Colors.grey)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: 8),
                  
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16),
                    color: Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Fecha y Horarios', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        SizedBox(height: 16),
                        
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => selectDate(context),
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                border: Border.all(color: Color(0xFF00BFA5), width: 1.5),
                                borderRadius: BorderRadius.circular(10),
                                color: Color(0xFFE0F7F4),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Color(0xFF00BFA5),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(Icons.calendar_today, color: Colors.white, size: 20),
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('FECHA', style: TextStyle(fontSize: 10, color: Colors.grey[700], fontWeight: FontWeight.w600)),
                                        Text(DateFormat('dd/MM/yyyy').format(selectedDate), style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  ),
                                  Icon(Icons.edit, color: Color(0xFF00BFA5), size: 18),
                                ],
                              ),
                            ),
                          ),
                        ),
                        
                        SizedBox(height: 12),
                        
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => selectStartTime(context),
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                border: Border.all(color: startTime != null ? Color(0xFF00BFA5) : Colors.grey[300]!, width: 1.5),
                                borderRadius: BorderRadius.circular(10),
                                color: startTime != null ? Color(0xFF00BFA5).withOpacity(0.1) : Colors.grey[50],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: startTime != null ? Color(0xFF00BFA5) : Colors.grey[400],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(Icons.access_time, color: Colors.white, size: 20),
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('HORA ENTRADA', style: TextStyle(fontSize: 10, color: Colors.grey[700], fontWeight: FontWeight.w600)),
                                        Text(startTime?.format(context) ?? 'Seleccionar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: startTime != null ? Colors.black : Colors.grey[500])),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        
                        SizedBox(height: 12),
                        
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => selectEndTime(context),
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                border: Border.all(color: endTime != null ? Color(0xFF00BFA5) : Colors.grey[300]!, width: 1.5),
                                borderRadius: BorderRadius.circular(10),
                                color: endTime != null ? Color(0xFF00BFA5).withOpacity(0.1) : Colors.grey[50],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: endTime != null ? Color(0xFF00BFA5) : Colors.grey[400],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(Icons.logout, color: Colors.white, size: 20),
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('HORA SALIDA', style: TextStyle(fontSize: 10, color: Colors.grey[700], fontWeight: FontWeight.w600)),
                                        Text(endTime?.format(context) ?? 'Seleccionar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: endTime != null ? Colors.black : Colors.grey[500])),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        
                        SizedBox(height: 16),
                        
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Color(0xFF00BFA5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.schedule, color: Colors.white, size: 18),
                              SizedBox(width: 8),
                              Text('Duracion: ${totalHours.toStringAsFixed(1)} horas', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: 8),
                  
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16),
                    color: Colors.white,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Espacios disponibles', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                        Text('25 de 20', style: TextStyle(color: Color(0xFF00BFA5), fontSize: 14, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: 100),
                ],
              ),
            ),
          ),
          
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, -2))],
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('TOTAL', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                      Text('S/. ${totalPrice.toStringAsFixed(2)}', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF00BFA5))),
                    ],
                  ),
                  SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: confirmReservation,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF00BFA5),
                        padding: EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        elevation: 0,
                      ),
                      child: Text('CONFIRMAR RESERVA', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}