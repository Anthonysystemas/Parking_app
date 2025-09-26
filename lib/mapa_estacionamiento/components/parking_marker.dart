import 'package:flutter/material.dart';

class ParkingMarker extends StatefulWidget {
  final bool isAvailable;
  final AlignmentGeometry alignment;
  final bool isSelected;
  final String price;
  final VoidCallback? onTap;

  const ParkingMarker({
    super.key,
    required this.isAvailable,
    required this.alignment,
    this.isSelected = false,
    required this.price,
    this.onTap,
  });

  @override
  State<ParkingMarker> createState() => _ParkingMarkerState();
}

class _ParkingMarkerState extends State<ParkingMarker>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: widget.alignment,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value * (widget.isSelected ? 1.2 : 1.0),
            child: GestureDetector(
              onTap: widget.onTap,
              child: Container(
                width: 50,
                height: 60,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Sombra
                    Positioned(
                      bottom: 0,
                      child: Container(
                        width: 20,
                        height: 6,
                        decoration: BoxDecoration(
                          color: Colors.black26,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    
                    // Marcador principal
                    Positioned(
                      top: 0,
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        width: widget.isSelected ? 45 : 40,
                        height: widget.isSelected ? 45 : 40,
                        decoration: BoxDecoration(
                          color: widget.isAvailable ? Color(0xFF00D4AA) : Color(0xFFFF4444),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: widget.isSelected ? 3 : 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              blurRadius: widget.isSelected ? 12 : 8,
                              color: (widget.isAvailable ? Color(0xFF00D4AA) : Color(0xFFFF4444))
                                  .withOpacity(0.5),
                              offset: Offset(0, widget.isSelected ? 4 : 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            'P',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: widget.isSelected ? 20 : 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Precio
                    if (widget.isAvailable)
                      Positioned(
                        bottom: 8,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Color(0xFF00D4AA)),
                          ),
                          child: Text(
                            widget.price,
                            style: TextStyle(
                              color: Color(0xFF00D4AA),
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                    // Indicador "Lleno"
                    if (!widget.isAvailable)
                      Positioned(
                        bottom: 8,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'LLENO',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}