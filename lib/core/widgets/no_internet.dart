import 'package:flutter/material.dart';

class NoConnectionView extends StatefulWidget {
  const NoConnectionView({super.key, this.onRetry});

  final Future<void> Function()? onRetry;

  @override
  State<NoConnectionView> createState() => _NoConnectionViewState();
}

class _NoConnectionViewState extends State<NoConnectionView> {
  bool _loading = false;

  Future<void> _handleRetry() async {
    if (widget.onRetry == null) return;

    setState(() => _loading = true);
    try {
      await widget.onRetry!();
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.wifi_off,
              size: 80,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 24),
            Text(
              'No internet connection',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Check your connection and try again.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _loading ? null : _handleRetry,
              icon: _loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.refresh),
              label: Text(_loading ? 'Retrying...' : 'Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
