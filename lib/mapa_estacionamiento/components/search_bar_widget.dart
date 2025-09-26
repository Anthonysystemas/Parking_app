import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/flutter_flow/flutter_flow_theme.dart';

class SearchBarWidget extends StatelessWidget {
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? Function(String?)? validator;

  const SearchBarWidget({
    super.key,
    this.controller,
    this.focusNode,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: const AlignmentDirectional(0.0, -1.0),
      child: Container(
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(16.0, 16.0, 16.0, 0.0),
          child: TextFormField(
            controller: controller,
            focusNode: focusNode,
            autofocus: false,
            textInputAction: TextInputAction.search,
            obscureText: false,
            decoration: InputDecoration(
              hintText: 'Buscar estacionamiento...',
              hintStyle: FlutterFlowTheme.of(context).bodyMedium.override(
                font: GoogleFonts.inter(
                  fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                  fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                ),
                color: const Color(0xFF999999),
                fontSize: 16.0,
                letterSpacing: 0.0,
                fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  color: Colors.transparent,
                  width: 0.0,
                ),
                borderRadius: BorderRadius.circular(25.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  color: Color(0xFF00D4AA),
                  width: 0.0,
                ),
                borderRadius: BorderRadius.circular(25.0),
              ),
              errorBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  color: Color(0x00000000),
                  width: 0.0,
                ),
                borderRadius: BorderRadius.circular(25.0),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  color: Color(0x00000000),
                  width: 0.0,
                ),
                borderRadius: BorderRadius.circular(25.0),
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsetsDirectional.fromSTEB(20.0, 12.0, 20.0, 12.0),
              prefixIcon: const Icon(
                Icons.search_rounded,
                color: Color(0xFF666666),
                size: 20.0,
              ),
              suffixIcon: const Icon(
                Icons.my_location_rounded,
                color: Color(0xFF666666),
                size: 20.0,
              ),
            ),
            style: FlutterFlowTheme.of(context).bodyMedium.override(
              font: GoogleFonts.inter(
                fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
              ),
              fontSize: 16.0,
              letterSpacing: 0.0,
              fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
              fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
            ),
            cursorColor: const Color(0xFF00D4AA),
            validator: validator,
          ),
        ),
      ),
    );
  }
}