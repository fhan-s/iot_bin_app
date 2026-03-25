import 'package:flutter/material.dart';

class BinCard extends StatelessWidget {
  const BinCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.onTap,
    this.hasSelectedFilter = false,
  });

  final String title;
  final String value;
  final IconData icon;
  final bool hasSelectedFilter;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: hasSelectedFilter
            ? colorScheme.primaryContainer
            : colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(
            color: hasSelectedFilter
                ? colorScheme.primary
                : colorScheme.outlineVariant,
            width: hasSelectedFilter ? 2 : 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(1.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 1),
              Icon(
                icon,
                color: hasSelectedFilter
                    ? colorScheme.onPrimaryContainer
                    : colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 4),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: hasSelectedFilter
                      ? colorScheme.onPrimaryContainer
                      : colorScheme.onSurfaceVariant,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                value,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: hasSelectedFilter
                      ? colorScheme.onPrimaryContainer
                      : colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 1),
            ],
          ),
        ),
      ),
    );
  }
}
