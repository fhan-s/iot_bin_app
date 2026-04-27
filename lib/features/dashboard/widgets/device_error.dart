import 'package:flutter/material.dart';

class DeviceStatusError extends StatelessWidget {
  const DeviceStatusError({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final appColourScheme = Theme.of(context).colorScheme;

    // styling changes depending on whether the sensor is offline or device missing
    final bool isOffline = label == 'Offline';

    final Color backgroundColour = isOffline
        ? appColourScheme.errorContainer
        : appColourScheme.surfaceContainerHighest;

    final Color foregroundColour = isOffline
        ? appColourScheme.onErrorContainer
        : appColourScheme.onSurfaceVariant;

    final IconData icon = isOffline
        ? Icons.wifi_off_rounded
        : Icons.sensors_off_rounded;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: backgroundColour,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: foregroundColour),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: foregroundColour,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
