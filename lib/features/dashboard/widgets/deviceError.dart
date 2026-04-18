import 'package:flutter/material.dart';

class DeviceStatusError extends StatelessWidget {
  const DeviceStatusError({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final bool isOffline = label == 'Offline';

    final Color bg = isOffline
        ? scheme.errorContainer
        : scheme.surfaceContainerHighest;

    final Color fg = isOffline
        ? scheme.onErrorContainer
        : scheme.onSurfaceVariant;

    final IconData icon = isOffline
        ? Icons.wifi_off_rounded
        : Icons.sensors_off_rounded;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: fg),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: fg,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
