import 'package:flutter/material.dart';

class FillLevelCardIcon extends StatelessWidget {
  const FillLevelCardIcon({super.key, required this.fillLevel});

  final int fillLevel;

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
    final color = getFillColor(fillLevel);
    return Container(
      width: 50,
      height: 70,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color, width: 2),
      ),
      alignment: Alignment.center,
      child: Text(
        fillLabel(fillLevel),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }
}
