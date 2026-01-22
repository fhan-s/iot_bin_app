import 'package:flutter/material.dart';

class BinFillIcon extends StatelessWidget {
  const BinFillIcon({
    super.key,
    required this.fillLevel,
    this.size = 100,
    this.filledColor = const Color.fromARGB(255, 63, 196, 51),
    this.emptyColor = const Color.fromARGB(255, 143, 143, 143),
    this.icon = Icons.delete,
  });

  final int fillLevel;
  final double size;
  final Color filledColor;
  final Color emptyColor;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final fillPercent = (fillLevel / 100).clamp(0.0, 1.0);

    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (Rect bounds) {
        return LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [filledColor, filledColor, emptyColor, emptyColor],
          stops: [0.0, fillPercent, fillPercent, 1.0],
        ).createShader(bounds);
      },
      child: Icon(icon, size: size, color: Colors.white),
    );
  }
}
