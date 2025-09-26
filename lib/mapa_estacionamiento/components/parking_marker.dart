import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/flutter_flow/flutter_flow_theme.dart';

class ParkingMarker extends StatelessWidget {
  final bool isAvailable;
  final AlignmentGeometry alignment;
  final VoidCallback? onTap;

  const ParkingMarker({
    super.key,
    required this.isAvailable,
    required this.alignment,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 40.0,
          height: 40.0,
          decoration: BoxDecoration(
            color: isAvailable ? const Color(0xFF00D4AA) : const Color(0xFFFF4444),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white,
              width: 2.0,
            ),
          ),
          child: Align(
            alignment: const AlignmentDirectional(0.0, 0.0),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'P',
                style: FlutterFlowTheme.of(context).labelMedium.override(
                  font: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                  ),
                  color: Colors.white,
                  letterSpacing: 0.0,
                  fontWeight: FontWeight.bold,
                  fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}