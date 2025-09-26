import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/index.dart';

class ParkingInfoCard extends StatelessWidget {
  final String parkingName;
  final String address;
  final String price;
  final String availableSpots;
  final VoidCallback? onReservarPressed;

  const ParkingInfoCard({
    super.key,
    required this.parkingName,
    required this.address,
    required this.price,
    required this.availableSpots,
    this.onReservarPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: const AlignmentDirectional(0.0, 1.0),
      child: Container(
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(20.0, 20.0, 20.0, 20.0),
          child: Container(
            width: double.infinity,
            height: 200.0,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: const [
                BoxShadow(
                  blurRadius: 10.0,
                  color: Color(0x33000000),
                  offset: Offset(0.0, -2.0),
                )
              ],
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              parkingName,
                              style: FlutterFlowTheme.of(context).titleLarge.override(
                                font: GoogleFonts.interTight(
                                  fontWeight: FontWeight.bold,
                                ),
                                letterSpacing: 0.0,
                                fontWeight: FontWeight.bold,
                                fontStyle: FlutterFlowTheme.of(context).titleLarge.fontStyle,
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                const Icon(
                                  Icons.location_on_rounded,
                                  color: Color(0xFF666666),
                                  size: 16.0,
                                ),
                                Text(
                                  address,
                                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                                    font: GoogleFonts.inter(),
                                    color: const Color(0xFF666666),
                                    letterSpacing: 0.0,
                                  ),
                                ),
                              ].divide(const SizedBox(width: 8.0)),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    const Icon(
                                      Icons.access_time_rounded,
                                      color: Color(0xFF666666),
                                      size: 16.0,
                                    ),
                                    Text(
                                      '24h',
                                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                                        font: GoogleFonts.inter(),
                                        color: const Color(0xFF666666),
                                        letterSpacing: 0.0,
                                      ),
                                    ),
                                  ].divide(const SizedBox(width: 4.0)),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    const Icon(
                                      Icons.security_rounded,
                                      color: Color(0xFF666666),
                                      size: 16.0,
                                    ),
                                    Text(
                                      'Vigilado',
                                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                                        font: GoogleFonts.inter(),
                                        color: const Color(0xFF666666),
                                        letterSpacing: 0.0,
                                      ),
                                    ),
                                  ].divide(const SizedBox(width: 4.0)),
                                ),
                              ].divide(const SizedBox(width: 12.0)),
                            ),
                          ].divide(const SizedBox(height: 8.0)),
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            price,
                            style: FlutterFlowTheme.of(context).headlineSmall.override(
                              font: GoogleFonts.interTight(
                                fontWeight: FontWeight.bold,
                              ),
                              color: const Color(0xFF00D4AA),
                              letterSpacing: 0.0,
                              fontWeight: FontWeight.bold,
                              fontStyle: FlutterFlowTheme.of(context).headlineSmall.fontStyle,
                            ),
                          ),
                          Text(
                            'por hora',
                            style: FlutterFlowTheme.of(context).bodySmall.override(
                              font: GoogleFonts.inter(),
                              color: const Color(0xFF666666),
                              letterSpacing: 0.0,
                            ),
                          ),
                        ].divide(const SizedBox(height: 4.0)),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Espacios disponibles',
                            style: FlutterFlowTheme.of(context).bodySmall.override(
                              font: GoogleFonts.inter(),
                              color: const Color(0xFF666666),
                              letterSpacing: 0.0,
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Container(
                                width: 12.0,
                                height: 12.0,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF00D4AA),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              Text(
                                availableSpots,
                                style: FlutterFlowTheme.of(context).bodyMedium.override(
                                  font: GoogleFonts.inter(
                                    fontWeight: FontWeight.w600,
                                  ),
                                  color: const Color(0xFF333333),
                                  letterSpacing: 0.0,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ].divide(const SizedBox(width: 8.0)),
                          ),
                        ].divide(const SizedBox(height: 4.0)),
                      ),
                      FFButtonWidget(
                        onPressed: onReservarPressed ?? () {
                          Navigator.of(context).pushNamed(ReservarParkingWidget.routeName);
                        },
                        text: 'RESERVAR',
                        options: FFButtonOptions(
                          height: 45.0,
                          padding: const EdgeInsetsDirectional.fromSTEB(32.0, 0.0, 32.0, 0.0),
                          iconPadding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                          color: const Color(0xFF00D4AA),
                          textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                            font: GoogleFonts.interTight(
                              fontWeight: FontWeight.bold,
                            ),
                            color: Colors.white,
                            letterSpacing: 0.0,
                            fontWeight: FontWeight.bold,
                            fontStyle: FlutterFlowTheme.of(context).titleSmall.fontStyle,
                          ),
                          elevation: 0.0,
                          borderSide: const BorderSide(
                            color: Colors.transparent,
                          ),
                          borderRadius: BorderRadius.circular(25.0),
                        ),
                      ),
                    ],
                  ),
                ].divide(const SizedBox(height: 16.0)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}