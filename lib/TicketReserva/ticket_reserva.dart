import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TicketReserva extends StatelessWidget {
  final Map<String, dynamic> parking;
  final DateTime selectedDate;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final double totalHours;
  final double totalPrice;
  final String codigoReserva;

  const TicketReserva({
    super.key,
    required this.parking,
    required this.selectedDate,
    required this.startTime,
    required this.endTime,
    required this.totalHours,
    required this.totalPrice,
    required this.codigoReserva,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              color: Colors.white,
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Text(
                      'Ticket de Reserva',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(width: 48),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 20,
                            offset: Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Header
                          Container(
                            padding: EdgeInsets.symmetric(vertical: 32),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xFF00BFA5), Color(0xFF26C6DA)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(20),
                                topRight: Radius.circular(20),
                              ),
                            ),
                            child: Column(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(Icons.check_circle_outline, color: Colors.white, size: 56),
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'RESERVA CONFIRMADA',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 20),
                                  child: Text(
                                    parking['name'] ?? 'Estacionamiento',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.95),
                                      fontSize: 17,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Código de reserva
                          Container(
                            padding: EdgeInsets.all(28),
                            child: Column(
                              children: [
                                Text(
                                  'CÓDIGO DE RESERVA',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[600],
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                SizedBox(height: 12),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: Color(0xFF00BFA5).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Color(0xFF00BFA5).withOpacity(0.3),
                                      width: 2,
                                    ),
                                  ),
                                  child: Text(
                                    codigoReserva,
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF00BFA5),
                                      letterSpacing: 4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Información
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 24),
                            child: Column(
                              children: [
                                _buildInfoRow(
                                  icon: Icons.calendar_today_rounded,
                                  label: 'Fecha',
                                  value: DateFormat('EEEE, dd MMMM yyyy', 'es').format(selectedDate),
                                ),
                                SizedBox(height: 14),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildCompactInfo(
                                        icon: Icons.login_rounded,
                                        label: 'Entrada',
                                        value: startTime.format(context),
                                        color: Colors.green,
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: _buildCompactInfo(
                                        icon: Icons.logout_rounded,
                                        label: 'Salida',
                                        value: endTime.format(context),
                                        color: Colors.orange,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 14),
                                _buildInfoRow(
                                  icon: Icons.schedule_rounded,
                                  label: 'Duración',
                                  value: '${totalHours.toStringAsFixed(1)} horas',
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: 28),

                          // Divider
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              children: List.generate(
                                50,
                                (index) => Expanded(
                                  child: Container(
                                    height: 2,
                                    color: index % 2 == 0 ? Colors.grey[300] : Colors.transparent,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          SizedBox(height: 28),

                          // Total
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 24),
                            padding: EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Color(0xFF00BFA5).withOpacity(0.15),
                                  Color(0xFF26C6DA).withOpacity(0.15),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'TOTAL A PAGAR',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey[700],
                                        letterSpacing: 1,
                                      ),
                                    ),
                                    SizedBox(height: 6),
                                    Text(
                                      'S/. ${totalPrice.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontSize: 36,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF00BFA5),
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: Color(0xFF00BFA5),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(Icons.payments_rounded, color: Colors.white, size: 32),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: 28),

                          // Instrucciones
                          Container(
                            padding: EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.amber[50],
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(20),
                                bottomRight: Radius.circular(20),
                              ),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.info_outline, color: Colors.amber[800], size: 22),
                                    SizedBox(width: 10),
                                    Text(
                                      'Instrucciones importantes',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.amber[900],
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 14),
                                _buildInstruction('Presenta este código al ingresar'),
                                _buildInstruction('Válido solo para fecha y hora indicadas'),
                                _buildInstruction('Cancelación gratuita hasta 1 hora antes'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 24),

                    // Botones
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {},
                            icon: Icon(Icons.share_rounded, size: 20),
                            label: Text('Compartir'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Color(0xFF00BFA5),
                              side: BorderSide(color: Color(0xFF00BFA5), width: 2),
                              padding: EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {},
                            icon: Icon(Icons.download_rounded, size: 20),
                            label: Text('Guardar'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Color(0xFF00BFA5),
                              side: BorderSide(color: Color(0xFF00BFA5), width: 2),
                              padding: EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 12),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF00BFA5),
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        child: Text(
                          'VOLVER AL INICIO',
                          style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                        ),
                      ),
                    ),

                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({required IconData icon, required String label, required String value}) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Color(0xFF00BFA5).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Color(0xFF00BFA5), size: 22),
          ),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[600], fontWeight: FontWeight.w500)),
                SizedBox(height: 4),
                Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black87)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactInfo({required IconData icon, required String label, required String value, required Color color}) {
    return Container(
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 26),
          SizedBox(height: 10),
          Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[600], fontWeight: FontWeight.w500)),
          SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _buildInstruction(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(top: 6),
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: Colors.amber[800], shape: BoxShape.circle),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(text, style: TextStyle(fontSize: 13, color: Colors.grey[800], height: 1.4)),
          ),
        ],
      ),
    );
  }
}