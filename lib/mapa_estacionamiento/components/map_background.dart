import 'package:flutter/material.dart';

class MapBackground extends StatelessWidget {
  const MapBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Imagen de fondo del mapa
        Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            color: Color(0xFFF5F5F5),
          ),
          child: Image.network(
            'https://images.unsplash.com/photo-1687673962358-372135a44ed2?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w0NTYyMDF8MHwxfHJhbmRvbXx8fHx8fHx8fDE3NTY3NTcxNzR8&ixlib=rb-4.1.0&q=80&w=1080',
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
        // Overlay oscuro
        Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            color: Color(0x4D000000),
          ),
        ),
      ],
    );
  }
}