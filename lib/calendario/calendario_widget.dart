import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'calendario_model.dart';
export 'calendario_model.dart';

class CalendarioWidget extends StatefulWidget {
  const CalendarioWidget({super.key});

  static String routeName = 'calendario';
  static String routePath = '/calendario';

  @override
  State<CalendarioWidget> createState() => _CalendarioWidgetState();
}

class _CalendarioWidgetState extends State<CalendarioWidget> {
  late CalendarioModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  DateTime currentMonth = DateTime.now();

  final List<String> monthNames = [
    'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
    'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
  ];

  final List<String> weekDays = ['D', 'L', 'M', 'M', 'J', 'V', 'S'];
  final List<String> weekDayNames = [
    'Domingo', 'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado'
  ];

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => CalendarioModel());
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  List<DateTime?> getDaysInMonth(DateTime month) {
    List<DateTime?> days = [];
    
    DateTime firstDay = DateTime(month.year, month.month, 1);
    DateTime lastDay = DateTime(month.year, month.month + 1, 0);
    
    int startWeekday = firstDay.weekday % 7;
    for (int i = 0; i < startWeekday; i++) {
      days.add(null);
    }
    
    for (int day = 1; day <= lastDay.day; day++) {
      days.add(DateTime(month.year, month.month, day));
    }
    
    return days;
  }

  void changeMonth(int delta) {
    setState(() {
      currentMonth = DateTime(currentMonth.year, currentMonth.month + delta, 1);
    });
  }

  void selectDate(DateTime date) {
    setState(() {
      selectedDate = date;
    });
  }

  void selectTime() async {
    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Color(0xFF00BFA5),
              onPrimary: Colors.white,
              surface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (time != null) {
      setState(() {
        selectedTime = time;
      });
    }
  }

  // CORREGIDO: Devuelve los datos en lugar de solo mostrar SnackBar
  void confirmSelection() {
    final DateTime finalDateTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedTime.hour,
      selectedTime.minute,
    );

    // Devolver los datos a la pantalla anterior
    Navigator.pop(context, {
      'date': selectedDate,
      'time': selectedTime,
      'dateTime': finalDateTime,
    });
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
        backgroundColor: Color(0xFFF5F5F5),
        body: SafeArea(
          top: true,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.all(
                      MediaQuery.of(context).size.width > 600 ? 32.0 : 16.0,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            FlutterFlowIconButton(
                              borderColor: Color(0xFFE0E0E0),
                              borderRadius: 20.0,
                              borderWidth: 1.0,
                              buttonSize: 40.0,
                              fillColor: Colors.white,
                              icon: Icon(
                                Icons.arrow_back,
                                color: Color(0xFF2E2E2E),
                                size: 20.0,
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                            Expanded(
                              child: Text(
                                'Seleccionar fecha y hora',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: MediaQuery.of(context).size.width > 600 ? 24.0 : 20.0,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF2E2E2E),
                                ),
                              ),
                            ),
                            Container(width: 40.0, height: 40.0),
                          ],
                        ),
                        
                        SizedBox(height: 24.0),
                        
                        // Fecha seleccionada
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Fecha seleccionada',
                              style: TextStyle(
                                fontSize: 14.0,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF9E9E9E),
                              ),
                            ),
                            SizedBox(height: 12.0),
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(16.0),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12.0),
                                border: Border.all(
                                  color: Color(0xFF00BFA5),
                                  width: 2.0,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Color(0xFF00BFA5).withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        weekDayNames[selectedDate.weekday % 7],
                                        style: TextStyle(
                                          fontSize: 14.0,
                                          color: Color(0xFF9E9E9E),
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        '${selectedDate.day} de ${monthNames[selectedDate.month - 1]}, ${selectedDate.year}',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF2E2E2E),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Icon(
                                    Icons.calendar_today,
                                    color: Color(0xFF00BFA5),
                                    size: 24.0,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 24.0),

                        // Hora seleccionada
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hora de entrada',
                              style: TextStyle(
                                fontSize: 14.0,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF9E9E9E),
                              ),
                            ),
                            SizedBox(height: 12.0),
                            GestureDetector(
                              onTap: selectTime,
                              child: Container(
                                width: double.infinity,
                                padding: EdgeInsets.all(16.0),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12.0),
                                  border: Border.all(
                                    color: Color(0xFF00BFA5),
                                    width: 2.0,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color(0xFF00BFA5).withOpacity(0.1),
                                      blurRadius: 8,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      selectedTime.format(context),
                                      style: TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF2E2E2E),
                                      ),
                                    ),
                                    Icon(
                                      Icons.access_time,
                                      color: Color(0xFF00BFA5),
                                      size: 28.0,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 24.0),

                        // Calendario
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(20.0),
                            child: Column(
                              children: [
                                // Header del calendario
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '${monthNames[currentMonth.month - 1]} ${currentMonth.year}',
                                      style: TextStyle(
                                        fontSize: 18.0,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF2E2E2E),
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        FlutterFlowIconButton(
                                          borderColor: Color(0xFFE0E0E0),
                                          borderRadius: 16.0,
                                          borderWidth: 1.0,
                                          buttonSize: 32.0,
                                          fillColor: Colors.white,
                                          icon: Icon(
                                            Icons.chevron_left,
                                            color: Color(0xFF2E2E2E),
                                            size: 16.0,
                                          ),
                                          onPressed: () => changeMonth(-1),
                                        ),
                                        SizedBox(width: 8.0),
                                        FlutterFlowIconButton(
                                          borderColor: Color(0xFFE0E0E0),
                                          borderRadius: 16.0,
                                          borderWidth: 1.0,
                                          buttonSize: 32.0,
                                          fillColor: Colors.white,
                                          icon: Icon(
                                            Icons.chevron_right,
                                            color: Color(0xFF2E2E2E),
                                            size: 16.0,
                                          ),
                                          onPressed: () => changeMonth(1),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),

                                SizedBox(height: 16.0),

                                // Grid del calendario
                                GridView.builder(
                                  padding: EdgeInsets.zero,
                                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 7,
                                    crossAxisSpacing: 4.0,
                                    mainAxisSpacing: 4.0,
                                    childAspectRatio: 1.0,
                                  ),
                                  primary: false,
                                  shrinkWrap: true,
                                  scrollDirection: Axis.vertical,
                                  itemCount: 49,
                                  itemBuilder: (context, index) {
                                    if (index < 7) {
                                      return Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(8.0),
                                        ),
                                        child: Center(
                                          child: Text(
                                            weekDays[index],
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFF9E9E9E),
                                            ),
                                          ),
                                        ),
                                      );
                                    }
                                    
                                    List<DateTime?> days = getDaysInMonth(currentMonth);
                                    int dayIndex = index - 7;
                                    
                                    if (dayIndex >= days.length || days[dayIndex] == null) {
                                      return Container();
                                    }
                                    
                                    DateTime day = days[dayIndex]!;
                                    bool isSelected = day.day == selectedDate.day && 
                                                    day.month == selectedDate.month && 
                                                    day.year == selectedDate.year;
                                    bool isToday = day.day == DateTime.now().day && 
                                                 day.month == DateTime.now().month && 
                                                 day.year == DateTime.now().year;
                                    
                                    return GestureDetector(
                                      onTap: () => selectDate(day),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: isSelected 
                                              ? Color(0xFF00BFA5)
                                              : isToday 
                                                  ? Color(0xFF00BFA5).withOpacity(0.1)
                                                  : Colors.transparent,
                                          borderRadius: BorderRadius.circular(8.0),
                                          border: isToday && !isSelected
                                              ? Border.all(
                                                  color: Color(0xFF00BFA5),
                                                  width: 2.0,
                                                )
                                              : null,
                                        ),
                                        child: Center(
                                          child: Text(
                                            '${day.day}',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: isSelected || isToday 
                                                  ? FontWeight.w600 
                                                  : FontWeight.w500,
                                              color: isSelected
                                                  ? Colors.white
                                                  : Color(0xFF2E2E2E),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
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
              
              // Botón de confirmación
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(
                  MediaQuery.of(context).size.width > 600 ? 32.0 : 16.0,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 10.0,
                      color: Colors.black.withOpacity(0.1),
                      offset: Offset(0.0, -2.0),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: confirmSelection,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF00BFA5),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle_outline, size: 24),
                      SizedBox(width: 12),
                      Text(
                        'Confirmar selección',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
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
    );
  }
}