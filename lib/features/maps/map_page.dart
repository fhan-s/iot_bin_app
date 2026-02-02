import 'package:flutter/material.dart';
import 'package:iot_bin_app/features/maps/widgets/bin_marker.dart';
import 'package:iot_bin_app/features/maps/widgets/create_grid.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class JanitorMapPage extends StatefulWidget {
  const JanitorMapPage({super.key});

  @override
  State<JanitorMapPage> createState() => _JanitorMapPageState();
}

class _JanitorMapPageState extends State<JanitorMapPage> {
  final supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> getBins() async {
    final binData = await supabase
        .from('bin_assignment')
        .select('bin:bin (bin_id,bin_name, bin_status, fill_level)');
    return (binData as List)
        .map((row) => row['bin'] as Map<String, dynamic>)
        .toList();
  }

  // static bin data for prototyping
  final List<BinMapIcon> bins = const [
    BinMapIcon(id: 'Bin 1', name: 'Bin 1 Name', x: 0.15, y: 0.20, fill: 12),
    BinMapIcon(id: 'Bin 2', name: 'Bin 2 Name', x: 0.20, y: 0.40, fill: 62),
    BinMapIcon(id: 'Bin 3', name: 'Bin 3 Name', x: 0.40, y: 0.50, fill: 88),
    BinMapIcon(id: 'Bin 4', name: 'Bin 4 Name', x: 0.60, y: 0.80, fill: 35),
  ];

  // List<BinMapIcon> bins = [];

  String? selectedBinId;

  Color getFillColor(int fillLevel) {
    if (fillLevel >= 75) {
      return Colors.green;
    } else if (fillLevel >= 50) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  void _showBinDetails(BinMapIcon bin) {
    setState(() => selectedBinId = bin.id);

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                bin.name,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.delete_outline, color: getFillColor(bin.fill)),
                  const SizedBox(width: 8),
                  Text('Bin ID: ${bin.id}'),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.percent, color: getFillColor(bin.fill)),
                  const SizedBox(width: 8),
                  Text('Fill level: ${bin.fill}%'),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.check),
                      label: const Text('OK'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    selectedBinId = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerHighest,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 6),
            Text(
              'Overview of bin locations and statuses',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),

            // The map area
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    border: Border.all(color: colorScheme.outlineVariant),
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final w = constraints.maxWidth;
                      final h = constraints.maxHeight;

                      return Stack(
                        children: [
                          // Background grid map
                          Positioned.fill(
                            child: CustomPaint(
                              painter: CreateMapGrid(
                                lineColor: colorScheme.outlineVariant,
                              ),
                            ),
                          ),
                          // Bin icons
                          // for (final bin in bins)
                          // Positioned(
                          //   left: (w * bin.x) - 16,
                          //   top: (h * bin.y) - 16,
                          //   child: BinIconMapDot(
                          //     fillColor: getFillColor(bin.fill),
                          //     isSelected: selectedBinId == bin.id,
                          //     label: bin.id,
                          //     onTap: () => _showBinDetails(bin),
                          //   ),
                          // ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
