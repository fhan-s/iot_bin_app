import 'package:flutter/material.dart';

class BinFillIcon extends StatelessWidget {
  const BinFillIcon({
    super.key,
    required this.fillLevel,
    this.size = 80,
    this.emptyColor = const Color.fromARGB(255, 143, 143, 143),
    this.icon = Icons.delete,
  });

  final int fillLevel;
  final double size;
  final Color emptyColor;
  final IconData icon;
  Color getFillColor(int fillLevel) {
    if (fillLevel >= 75) {
      return Colors.green;
    } else if (fillLevel >= 50) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  String fillLabel(int fillLevel) => '$fillLevel%';
  @override
  Widget build(BuildContext context) {
    final double fillPercent = (fillLevel / 100).clamp(0.0, 1.0);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // The bin icon with fill effect
          ShaderMask(
            blendMode: BlendMode.srcIn,
            shaderCallback: (Rect bounds) {
              return LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  getFillColor(fillLevel),
                  getFillColor(fillLevel),
                  emptyColor,
                  emptyColor,
                ],
                stops: [0.0, fillPercent, fillPercent, 1.0],
              ).createShader(bounds);
            },
            child: Icon(icon, size: size, color: Colors.white),
          ),

          // Fill percentage text
          Text(
            fillLabel(fillLevel),
            style: TextStyle(
              fontSize: size * 0.18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
