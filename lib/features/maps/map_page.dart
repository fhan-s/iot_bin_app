import 'package:flutter/material.dart';
import 'package:iot_bin_app/features/maps/widgets/bin_marker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:iot_bin_app/features/maps/widgets/bin_icon_map.dart';
import 'package:flutter_svg/flutter_svg.dart';

class JanitorMapPage extends StatefulWidget {
  const JanitorMapPage({super.key});

  @override
  State<JanitorMapPage> createState() => _JanitorMapPageState();
}

class _JanitorMapPageState extends State<JanitorMapPage> {
  final supabase = Supabase.instance.client;
  String? selectedBuildingId;
  String? selectedFloorId;
  String? selectedFloorSvgAsset;
  Future<List<BinMapIcon>>? binsFuture;
  //map icon
  final TransformationController _mapController = TransformationController();

  String? editingBinId;
  final Map<String, Offset> draftPositions = {};
  bool isSavingPosition = false;

  Future<List<BinMapIcon>> getBins() async {
    if (selectedBuildingId == null || selectedFloorId == null) return [];

    final data = await supabase
        .from('bin')
        .select('bin_id, bin_name, bin_status, fill_level, pos_x, pos_y')
        .eq('floor_id', selectedFloorId!);
    return (data as List)
        .map((row) {
          if (row == null) return null;
          if (row['pos_x'] == null || row['pos_y'] == null) return null;

          return BinMapIcon(
            id: row['bin_id'].toString(),
            name: row['bin_name'] ?? '',
            x: (row['pos_x'] as num).toDouble(),
            y: (row['pos_y'] as num).toDouble(),
            fill: row['fill_level'] ?? 0,
          );
        })
        .whereType<BinMapIcon>()
        .toList();
  }

  void loadBins() {
    setState(() {
      binsFuture = getBins();
    });
  }

  Widget buildEditButtons() {
    return Positioned(
      right: 16,
      bottom: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            heroTag: 'confirm_move',
            onPressed: isSavingPosition
                ? null
                : () => saveBinPosition(editingBinId!),
            icon: isSavingPosition
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.check),
            label: Text(isSavingPosition ? 'Saving...' : 'Confirm'),
          ),
          const SizedBox(height: 12),
          FloatingActionButton.extended(
            heroTag: 'cancel_move',
            onPressed: cancelEditing,
            icon: const Icon(Icons.close),
            label: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  List<Widget> buildBinMarkers({
    required List<BinMapIcon> bins,
    required double mapImageWidth,
    required double mapImageHeight,
    required double markerSize,
  }) {
    return bins.map((bin) {
      final position = draftPositions[bin.id] ?? Offset(bin.x, bin.y);
      final isEditing = editingBinId == bin.id;

      return Positioned(
        left: (mapImageWidth * position.dx) - (markerSize / 2),
        top: (mapImageHeight * position.dy) - (markerSize / 2),
        child: GestureDetector(
          onTap: () {
            if (!isEditing) {
              _showBinDetails(bin);
            }
          },
          onPanUpdate: isEditing
              ? (details) {
                  final current =
                      draftPositions[bin.id] ?? Offset(bin.x, bin.y);

                  final nextLocalX =
                      (current.dx * mapImageWidth) + details.delta.dx;
                  final nextLocalY =
                      (current.dy * mapImageHeight) + details.delta.dy;

                  final normalized = _normalizedFromLocalPosition(
                    localPosition: Offset(
                      nextLocalX + markerSize / 2,
                      nextLocalY + markerSize / 2,
                    ),
                    mapWidth: mapImageWidth,
                    mapHeight: mapImageHeight,
                    markerSize: markerSize,
                  );

                  setState(() {
                    draftPositions[bin.id] = normalized;
                  });
                }
              : null,
          child: BinIconMapDot(
            fillColor: getFillColor(bin.fill),
            isSelected: selectedBinId == bin.id || isEditing,
            label: bin.name,
            onTap: () {
              if (!isEditing) {
                _showBinDetails(bin);
              }
            },
          ),
        ),
      );
    }).toList();
  }

  List<Map<String, dynamic>> buildingsList = [];
  List<Map<String, dynamic>> floorList = [];

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

  Future<void> saveBinPosition(String binId) async {
    final draft = draftPositions[binId];
    if (draft == null) return;

    setState(() => isSavingPosition = true);

    try {
      await supabase
          .from('bin')
          .update({'pos_x': draft.dx, 'pos_y': draft.dy})
          .eq('bin_id', binId);

      if (!mounted) return;

      setState(() {
        editingBinId = null;
        selectedBinId = binId;
        draftPositions.remove(binId);
        binsFuture = getBins();
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Bin position updated')));
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update bin position: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => isSavingPosition = false);
      }
    }
  }

  Offset _normalizedFromLocalPosition({
    required Offset localPosition,
    required double mapWidth,
    required double mapHeight,
    double markerSize = 32,
  }) {
    final x = ((localPosition.dx - markerSize / 2) / mapWidth).clamp(0.0, 1.0);
    final y = ((localPosition.dy - markerSize / 2) / mapHeight).clamp(0.0, 1.0);
    return Offset(x, y);
  }

  void cancelEditing() {
    if (editingBinId == null) return;

    setState(() {
      draftPositions.remove(editingBinId!);
      editingBinId = null;
    });
  }

  // Fetch buildings and floors from Supabase
  Future<void> fetchBuildings() async {
    final data = await supabase
        .from('building')
        .select('building_id, building_name');

    setState(() {
      buildingsList = List<Map<String, dynamic>>.from(data);
    });
  }

  Future<void> fetchFloors(String buildingId) async {
    final data = await supabase
        .from('floor')
        .select('floor_id, floor_label')
        // fetch floors only for the selected building
        .eq('building_id', buildingId);

    setState(() {
      floorList = List<Map<String, dynamic>>.from(data);
      // reset selected floor if building changes
      selectedFloorId = null;
      selectedFloorSvgAsset = null;
      selectedBinId = null;
      editingBinId = null;
      draftPositions.clear();
    });
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
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        setState(() {
                          editingBinId = bin.id;
                          draftPositions[bin.id] = Offset(bin.x, bin.y);
                        });
                      },
                      icon: const Icon(Icons.open_with),
                      label: const Text('Move'),
                    ),
                  ),
                  const SizedBox(width: 12),

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

  late final RealtimeChannel channel;

  @override
  void initState() {
    super.initState();

    channel = supabase
        .channel('bins')
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'bin',
          callback: (payload) {
            if (!mounted || selectedFloorId == null) return;

            setState(() {
              binsFuture = getBins();
            });
          },
        )
        .subscribe();

    fetchBuildings();
  }

  @override
  void dispose() {
    _mapController.dispose();
    supabase.removeChannel(channel);
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
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: selectedBuildingId,
                    hint: const Text('Select Building'),
                    items: buildingsList.map((b) {
                      return DropdownMenuItem<String>(
                        value: b['building_id'],
                        child: Text(b['building_name'] ?? 'Unnamed'),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedBuildingId = value;
                        selectedFloorId = null;
                        selectedBinId = null;
                        editingBinId = null;
                        draftPositions.clear();
                        binsFuture = null;
                      });
                      if (value != null) {
                        fetchFloors(value);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: selectedFloorId,
                    hint: const Text('Select Floor'),
                    items: floorList.map((f) {
                      return DropdownMenuItem<String>(
                        value: f['floor_id'],
                        child: Text(f['floor_label'] ?? 'Floor'),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedFloorId = value;
                        selectedBinId = null;
                        editingBinId = null;
                        draftPositions.clear();
                        binsFuture = value != null ? getBins() : null;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // The map area
            Expanded(
              child: FutureBuilder<List<BinMapIcon>>(
                future: binsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  if (!snapshot.hasData) {
                    return const Center(child: Text('No data'));
                  }

                  if (selectedBuildingId == null) {
                    return const Center(
                      child: Text('Select a building to view bins'),
                    );
                  }

                  if (selectedFloorId == null) {
                    return const Center(
                      child: Text('Select a floor to view bins'),
                    );
                  }

                  final bins = snapshot.data!;
                  if (bins.isEmpty) {
                    return const Center(
                      child: Text('No bins available for this floor'),
                    );
                  }
                  // Assuming the floor plan image has a fixed size, e.g., 1600x800 pixels
                  const double mapImageWidth = 1600;
                  const double mapImageHeight = 800;
                  const double markerSize = 32;

                  // return ClipRRect(
                  //   borderRadius: BorderRadius.circular(18),
                  //   child: Container(
                  //     decoration: BoxDecoration(
                  //       color: colorScheme.surface,
                  //       border: Border.all(color: colorScheme.outlineVariant),
                  //     ),
                  //     child: InteractiveViewer(
                  //       minScale: 0.3,
                  //       maxScale: 4.0,
                  //       boundaryMargin: const EdgeInsets.all(100),
                  //       constrained: false,
                  //       child: SizedBox(
                  //         width: mapImageWidth,
                  //         height: mapImageHeight,
                  //         child: Stack(
                  //           children: [
                  //             Positioned.fill(
                  //               child: SvgPicture.asset(
                  //                 'assets/maps/Floor-1.svg',
                  //                 fit: BoxFit.fill,
                  //               ),
                  //             ),

                  //             for (final bin in bins)
                  //               Positioned(
                  //                 left: (mapImageWidth * bin.x) - 16,
                  //                 top: (mapImageHeight * bin.y) - 16,
                  //                 child: BinIconMapDot(
                  //                   fillColor: getFillColor(bin.fill),
                  //                   isSelected: selectedBinId == bin.id,
                  //                   label: bin.name,
                  //                   onTap: () => _showBinDetails(bin),
                  //                 ),
                  //               ),
                  //           ],
                  //         ),
                  //       ),
                  //     ),
                  //   ),
                  // );
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Container(
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        border: Border.all(color: colorScheme.outlineVariant),
                      ),
                      child: Stack(
                        children: [
                          InteractiveViewer(
                            transformationController: _mapController,
                            minScale: 0.3,
                            maxScale: 4.0,
                            boundaryMargin: const EdgeInsets.all(100),
                            constrained: false,
                            panEnabled: editingBinId == null,
                            scaleEnabled: editingBinId == null,
                            child: SizedBox(
                              width: mapImageWidth,
                              height: mapImageHeight,
                              child: Stack(
                                children: [
                                  Positioned.fill(
                                    child: SvgPicture.asset(
                                      'assets/maps/Floor-1.svg',
                                      fit: BoxFit.fill,
                                    ),
                                  ),
                                  ...buildBinMarkers(
                                    bins: bins,
                                    mapImageWidth: mapImageWidth,
                                    mapImageHeight: mapImageHeight,
                                    markerSize: markerSize,
                                  ),
                                ],
                              ),
                            ),
                          ),

                          if (editingBinId != null) buildEditButtons(),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
