import 'package:flutter/material.dart';
import '/flutter_flow/flutter_flow_theme.dart';

class SearchBarWidget extends StatelessWidget {
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final Function(String)? onSubmitted;
  final VoidCallback? onLocationPressed;

  const SearchBarWidget({
    super.key,
    this.controller,
    this.focusNode,
    this.onSubmitted,
    this.onLocationPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
        controller: controller,
        focusNode: focusNode,
        onFieldSubmitted: onSubmitted,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: 'Buscar estacionamiento...',
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
          suffixIcon: GestureDetector(
            onTap: onLocationPressed,
            child: Container(
              margin: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Color(0xFF00D4AA),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.my_location_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ),
        style: TextStyle(
          fontSize: 16,
          color: Color(0xFF333333), // Color del texto negro para visibilidad
        ),
        cursorColor: Color(0xFF00D4AA),
      ),
    );
  }
}