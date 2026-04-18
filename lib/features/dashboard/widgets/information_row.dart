import 'package:flutter/material.dart';

class BinInfoRow extends StatelessWidget {
  const BinInfoRow({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      dense: true,
      leading: CircleAvatar(
        backgroundColor: colorScheme.secondaryContainer,
        child: Icon(icon, color: colorScheme.onSecondaryContainer),
      ),
      title: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
      ),
      subtitle: Text(
        value,
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
      ),
    );
  }
}
