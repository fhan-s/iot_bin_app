import 'package:flutter/material.dart';
import 'package:iot_bin_app/features/dashboard/widgets/bin_card.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:iot_bin_app/features/dashboard/manager/assign_janitor.dart';
import 'package:iot_bin_app/features/dashboard/widgets/bin_list_tile.dart';

class ManagerDashboardBinsPage extends StatefulWidget {
  const ManagerDashboardBinsPage({super.key});

  @override
  State<ManagerDashboardBinsPage> createState() =>
      _ManagerDashboardBinsPageState();
}

class _ManagerDashboardBinsPageState extends State<ManagerDashboardBinsPage>
    with WidgetsBindingObserver {
  final supabase = Supabase.instance.client;

  String selectedBinCard = 'all';
  RealtimeChannel? channel;
  List<Map<String, dynamic>> bins = [];
  Set<String> allBinIDs = {};
  bool pageIsLoading = true;
  String? errorMessage;

  //fetch manager's allocated bins from bin_assignment table
  Future<List<Map<String, dynamic>>> getAllBins() async {
    final binData = await supabase.from('bin').select('''
    bin_id,
    bin_name,
    bin_status,
    floor:floor_id (
      floor_label,
      building:building_id (
        building_name
      )
    ),
    fill_level,
    sensor_device (
      device_id,
      device_status,
      last_seen_at,
      battery_level
    ),
    bin_assignment (
      janitorial_staff (
        full_name
      )
    )
  ''');
    return List<Map<String, dynamic>>.from(binData);
  }

  void sortBinsByFillLevel(List<Map<String, dynamic>> bins) {
    bins.sort((a, b) {
      final fillA = (a['fill_level'] ?? 0) as int;
      final fillB = (b['fill_level'] ?? 0) as int;
      return fillB.compareTo(fillA);
    });
  }

  String? getDeviceStatus(Map<String, dynamic> bin) {
    final sensor = bin['sensor_device'];

    if (sensor == null) {
      return 'No device attached';
    }

    final status = sensor['device_status']?.toString().toLowerCase();

    if (status == 'offline') {
      return 'Offline';
    }

    return null;
  }

  Future<void> loadBins() async {
    if (!mounted) return;

    setState(() {
      pageIsLoading = true;
      errorMessage = null;
    });

    try {
      final loadedBins = await getAllBins();

      if (!mounted) return;

      // sort bins in descending fill level
      sortBinsByFillLevel(loadedBins);

      setState(() {
        bins = loadedBins;
        allBinIDs = bins.map((bin) => bin['bin_id'].toString()).toSet();
        pageIsLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        errorMessage = 'Failed to load bins. Error: $e';
        pageIsLoading = false;
      });
    }
  }

  Future<void> updateDashboardRealTime() async {
    //load and get all manager allocated bins first
    await loadBins();

    if (!mounted) return;

    if (channel != null) {
      supabase.removeChannel(channel!);
    }
    //subscribe to real-time updates for the manager's bins
    channel = supabase.channel('bin_updates_channel');

    //listen for updates on the bin table
    channel!
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'bin',
          callback: (payload) async {
            if (!mounted) return;

            final updatedBin = payload.newRecord;
            final updatedBinId = updatedBin['bin_id']?.toString();
            // If the updated bin is in the manager's allocated bins, refresh the bin list
            if (updatedBinId != null && allBinIDs.contains(updatedBinId)) {
              await loadBins();
            }
          },
        )
        .subscribe();
  }

  // refresh the dashboard if manager switched to another app and back
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      updateDashboardRealTime();
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    updateDashboardRealTime();
  }

  @override
  void dispose() {
    if (channel != null) {
      supabase.removeChannel(channel!);
    }
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appColourScheme = Theme.of(context).colorScheme;
    final numBins = bins.length.toString();
    final numBinsNeedingAttention = bins
        .where((bin) => bin['bin_status'] == 'Full')
        .length
        .toString();

    List<Map<String, dynamic>> filteredBins = bins;

    if (selectedBinCard == 'attention') {
      filteredBins = bins.where((bin) => bin['bin_status'] == 'Full').toList();
    }
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(15, 15, 15, 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Overview',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            sliver: SliverGrid(
              delegate: SliverChildListDelegate.fixed([
                BinCard(
                  title: 'Total Bins',
                  value: numBins,
                  icon: Icons.delete,
                  hasSelectedFilter: selectedBinCard == 'all',
                  onTap: () {
                    setState(() {
                      selectedBinCard = 'all';
                    });
                  },
                ),
                BinCard(
                  title: 'Bins Needing Attention',
                  value: numBinsNeedingAttention,
                  icon: Icons.warning,
                  hasSelectedFilter: selectedBinCard == 'attention',
                  onTap: () {
                    setState(() {
                      selectedBinCard = 'attention';
                    });
                  },
                ),
              ]),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 1.05,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'All Bins',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.only(left: 16),
                    decoration: BoxDecoration(
                      color: appColourScheme.primary,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: GestureDetector(
                      onTap: () {
                        loadBins();
                      },
                      child: Row(
                        children: [
                          Text(
                            'Refresh',
                            style: TextStyle(color: appColourScheme.onPrimary),
                          ),
                          IconButton(
                            tooltip: 'Refresh',
                            padding: EdgeInsets.all(0),
                            onPressed: () {
                              loadBins();
                            },
                            icon: Icon(
                              Icons.refresh,
                              color: appColourScheme.onPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          //tiles for each bin with status info
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            sliver: SliverToBoxAdapter(
              child: Builder(
                builder: (context) {
                  if (pageIsLoading) {
                    return const Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  if (errorMessage != null) {
                    return Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Center(
                        child: Text(
                          errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    );
                  }
                  if (bins.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.only(top: 20.0),
                      child: Center(child: Text('No bins found.')),
                    );
                  }

                  if (filteredBins.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.only(top: 20.0),
                      child: Center(child: Text('No filtered bins found.')),
                    );
                  }

                  return Column(
                    children: List.generate(filteredBins.length, (index) {
                      final bin = filteredBins[index];
                      final binAssignments = bin['bin_assignment'];
                      String assignedTo = 'No janitor allocated';

                      if (binAssignments != null) {
                        final janitor =
                            binAssignments['janitorial_staff']
                                as Map<String, dynamic>?;
                        assignedTo =
                            janitor?['full_name']?.toString() ??
                            'No janitor allocated';
                      }

                      return BinListTile(
                        binId: bin['bin_id'].toString(),
                        binName: bin['bin_name'] ?? 'Unnamed Bin',
                        binStatus: bin['bin_status'] ?? 'Unknown',
                        binFillLevel: bin['fill_level'] ?? 0,
                        binLocation:
                            '${bin['floor']?['building']?['building_name'] ?? 'Unknown Building'}, ${bin['floor']?['floor_label'] ?? 'Unknown Floor'}',
                        binDeviceStatus: getDeviceStatus(bin),
                        assignedTo: assignedTo,
                        onAssignPressed: () async {
                          final result = await showModalBottomSheet<bool>(
                            context: context,
                            isScrollControlled: true,
                            builder: (_) => AssignJanitorBin(
                              binId: bin['bin_id'].toString(),
                            ),
                          );

                          if (result == true) {
                            await loadBins();
                          }
                        },
                        onReturnFromBinInfo: loadBins,
                      );
                    }),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
