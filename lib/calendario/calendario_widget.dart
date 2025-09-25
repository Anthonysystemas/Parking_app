import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
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

  // Variables para manejar el estado del calendario
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  DateTime currentMonth = DateTime.now();

  // Lista de nombres de meses
  final List<String> monthNames = [
    'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
    'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
  ];

  // Lista de nombres de días
  final List<String> weekDays = ['D', 'L', 'M', 'M', 'J', 'V', 'S'];
  final List<String> weekDayNames = ['Domingo', 'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado'];

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

  // Función para obtener los días del mes
  List<DateTime?> getDaysInMonth(DateTime month) {
    List<DateTime?> days = [];
    
    // Primer día del mes
    DateTime firstDay = DateTime(month.year, month.month, 1);
    
    // Último día del mes
    DateTime lastDay = DateTime(month.year, month.month + 1, 0);
    
    // Agregar días vacíos al inicio para alinear con el día de la semana
    int startWeekday = firstDay.weekday % 7; // Domingo = 0
    for (int i = 0; i < startWeekday; i++) {
      days.add(null);
    }
    
    // Agregar todos los días del mes
    for (int day = 1; day <= lastDay.day; day++) {
      days.add(DateTime(month.year, month.month, day));
    }
    
    return days;
  }

  // Función para cambiar mes
  void changeMonth(int delta) {
    setState(() {
      currentMonth = DateTime(currentMonth.year, currentMonth.month + delta, 1);
    });
  }

  // Función para seleccionar fecha
  void selectDate(DateTime date) {
    setState(() {
      selectedDate = date;
    });
  }

  // Función para seleccionar hora
  void selectTime() async {
    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: FlutterFlowTheme.of(context).primary,
              onPrimary: FlutterFlowTheme.of(context).primaryBackground,
              surface: FlutterFlowTheme.of(context).secondaryBackground,
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

  // Función para confirmar selección
  void confirmSelection() {
    // Combinar fecha y hora seleccionadas
    final DateTime finalDateTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedTime.hour,
      selectedTime.minute,
    );

    // Aquí puedes agregar la lógica para procesar la fecha/hora seleccionada
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Fecha y hora seleccionada: ${DateFormat('dd/MM/yyyy HH:mm').format(finalDateTime)}'),
        backgroundColor: FlutterFlowTheme.of(context).primary,
      ),
    );

    // Navegar de vuelta o proceder con la lógica de tu app
    // context.pushNamed(NextPageWidget.routeName);
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
                              borderColor: FlutterFlowTheme.of(context).alternate,
                              borderRadius: 20.0,
                              borderWidth: 1.0,
                              buttonSize: 40.0,
                              icon: Icon(
                                Icons.chevron_left,
                                color: FlutterFlowTheme.of(context).primaryText,
                                size: 20.0,
                              ),
                              onPressed: () async {
                                context.pushNamed(PaginaInicioWidget.routeName);
                              },
                            ),
                            Expanded(
                              child: Text(
                                'Seleccionar fecha y hora',
                                textAlign: TextAlign.center,
                                style: FlutterFlowTheme.of(context).titleLarge.override(
                                  font: GoogleFonts.interTight(
                                    fontWeight: FontWeight.w600,
                                  ),
                                  fontSize: MediaQuery.of(context).size.width > 600 ? 24.0 : 20.0,
                                  letterSpacing: 0.0,
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
                              style: FlutterFlowTheme.of(context).bodyMedium.override(
                                font: GoogleFonts.inter(fontWeight: FontWeight.w500),
                                color: FlutterFlowTheme.of(context).secondaryText,
                                fontSize: 16.0,
                                letterSpacing: 0.0,
                              ),
                            ),
                            SizedBox(height: 12.0),
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(16.0),
                              decoration: BoxDecoration(
                                color: FlutterFlowTheme.of(context).secondaryBackground,
                                borderRadius: BorderRadius.circular(12.0),
                                border: Border.all(
                                  color: FlutterFlowTheme.of(context).alternate,
                                  width: 1.0,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        weekDayNames[selectedDate.weekday % 7],
                                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                                          color: FlutterFlowTheme.of(context).secondaryText,
                                          fontSize: 14.0,
                                          letterSpacing: 0.0,
                                        ),
                                      ),
                                      Text(
                                        '${selectedDate.day} de ${monthNames[selectedDate.month - 1]}, ${selectedDate.year}',
                                        style: FlutterFlowTheme.of(context).titleMedium.override(
                                          font: GoogleFonts.interTight(fontWeight: FontWeight.w600),
                                          letterSpacing: 0.0,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Icon(
                                    Icons.calendar_today,
                                    color: FlutterFlowTheme.of(context).secondaryText,
                                    size: 20.0,
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
                              'Hora seleccionada',
                              style: FlutterFlowTheme.of(context).bodyMedium.override(
                                font: GoogleFonts.inter(fontWeight: FontWeight.w500),
                                color: FlutterFlowTheme.of(context).secondaryText,
                                fontSize: 16.0,
                                letterSpacing: 0.0,
                              ),
                            ),
                            SizedBox(height: 12.0),
                            GestureDetector(
                              onTap: selectTime,
                              child: Container(
                                width: double.infinity,
                                padding: EdgeInsets.all(16.0),
                                decoration: BoxDecoration(
                                  color: FlutterFlowTheme.of(context).secondaryBackground,
                                  borderRadius: BorderRadius.circular(12.0),
                                  border: Border.all(
                                    color: FlutterFlowTheme.of(context).alternate,
                                    width: 1.0,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      selectedTime.format(context),
                                      style: FlutterFlowTheme.of(context).titleLarge.override(
                                        font: GoogleFonts.interTight(fontWeight: FontWeight.w600),
                                        fontSize: 24.0,
                                        letterSpacing: 0.0,
                                      ),
                                    ),
                                    Icon(
                                      Icons.access_time,
                                      color: FlutterFlowTheme.of(context).secondaryText,
                                      size: 24.0,
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
                            color: FlutterFlowTheme.of(context).secondaryBackground,
                            borderRadius: BorderRadius.circular(16.0),
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
                                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                                        font: GoogleFonts.inter(fontWeight: FontWeight.w600),
                                        fontSize: 18.0,
                                        letterSpacing: 0.0,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        FlutterFlowIconButton(
                                          borderColor: FlutterFlowTheme.of(context).alternate,
                                          borderRadius: 16.0,
                                          borderWidth: 1.0,
                                          buttonSize: 32.0,
                                          icon: Icon(
                                            Icons.chevron_left,
                                            color: FlutterFlowTheme.of(context).primaryText,
                                            size: 16.0,
                                          ),
                                          onPressed: () => changeMonth(-1),
                                        ),
                                        SizedBox(width: 8.0),
                                        FlutterFlowIconButton(
                                          borderColor: FlutterFlowTheme.of(context).alternate,
                                          borderRadius: 16.0,
                                          borderWidth: 1.0,
                                          buttonSize: 32.0,
                                          icon: Icon(
                                            Icons.chevron_right,
                                            color: FlutterFlowTheme.of(context).primaryText,
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
                                  itemCount: 49, // 7 header + 42 days max
                                  itemBuilder: (context, index) {
                                    if (index < 7) {
                                      // Headers de días de la semana
                                      return Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(8.0),
                                        ),
                                        child: Center(
                                          child: Text(
                                            weekDays[index],
                                            textAlign: TextAlign.center,
                                            style: FlutterFlowTheme.of(context).bodySmall.override(
                                              font: GoogleFonts.inter(fontWeight: FontWeight.w500),
                                              color: FlutterFlowTheme.of(context).secondaryText,
                                              letterSpacing: 0.0,
                                            ),
                                          ),
                                        ),
                                      );
                                    }
                                    
                                    // Días del calendario
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
                                              ? FlutterFlowTheme.of(context).primary
                                              : isToday 
                                                  ? FlutterFlowTheme.of(context).accent1
                                                  : Colors.transparent,
                                          borderRadius: BorderRadius.circular(8.0),
                                          border: isToday && !isSelected
                                              ? Border.all(
                                                  color: FlutterFlowTheme.of(context).primary,
                                                  width: 1.0,
                                                )
                                              : null,
                                        ),
                                        child: Center(
                                          child: Text(
                                            '${day.day}',
                                            textAlign: TextAlign.center,
                                            style: FlutterFlowTheme.of(context).bodyMedium.override(
                                              font: GoogleFonts.inter(
                                                fontWeight: isSelected || isToday 
                                                    ? FontWeight.w600 
                                                    : FontWeight.w500,
                                              ),
                                              color: isSelected
                                                  ? FlutterFlowTheme.of(context).primaryBackground
                                                  : FlutterFlowTheme.of(context).primaryText,
                                              letterSpacing: 0.0,
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
                  color: FlutterFlowTheme.of(context).secondaryBackground,
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 4.0,
                      color: Color(0x33000000),
                      offset: Offset(0.0, -2.0),
                    ),
                  ],
                ),
                child: FFButtonWidget(
                  onPressed: confirmSelection,
                  text: 'Confirmar selección',
                  options: FFButtonOptions(
                    width: double.infinity,
                    height: 50.0,
                    padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                    iconPadding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                    color: FlutterFlowTheme.of(context).primary,
                    textStyle: FlutterFlowTheme.of(context).titleMedium.override(
                      font: GoogleFonts.interTight(fontWeight: FontWeight.w600),
                      color: FlutterFlowTheme.of(context).primaryBackground,
                      letterSpacing: 0.0,
                    ),
                    elevation: 0.0,
                    borderSide: BorderSide(
                      color: Colors.transparent,
                      width: 1.0,
                    ),
                    borderRadius: BorderRadius.circular(12.0),
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