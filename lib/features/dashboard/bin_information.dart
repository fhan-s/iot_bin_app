import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:iot_bin_app/features/dashboard/janitor/widgets/bin_fill_icon.dart';
import 'package:iot_bin_app/features/dashboard/janitor/widgets/information_row.dart';

class BinInformationPage extends StatefulWidget {
  const BinInformationPage({super.key, required this.binId});

  final String binId;

  @override
  State<BinInformationPage> createState() => _BinInformationPageState();
}

class _BinInformationPageState extends State<BinInformationPage> {
  final supabase = Supabase.instance.client;

  Future<Map<String, dynamic>> getBinInformation() async {
    final binData = await supabase
        .from('bin')
        .select(
          ' bin_name, bin_status, fill_level, floor:floor_id ( floor_label, building:building_id (building_name) ), device:sensor_device ( device_id, device_name, device_serial_number, device_status, last_seen_at )',
        )
        .eq('bin_id', widget.binId)
        .single();
    return Map<String, dynamic>.from(binData);
  }

  String getLiveDeviceStatus(String? lastSeenAt) {
    if (lastSeenAt == null) return 'Offline';

    final lastSeen = DateTime.tryParse(lastSeenAt);
    if (lastSeen == null) return 'Offline';

    final difference = DateTime.now().difference(lastSeen.toLocal());

    // Consider device online if last seen within the past 5 days (432000 seconds)
    if (difference.inSeconds <= 432000) {
      return 'Online';
    } else {
      return 'Offline';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerHighest,
      appBar: AppBar(title: const Text('Bin Information')),
      body: FutureBuilder(
        future: getBinInformation(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('No data found'));
          }
          final binInfo = snapshot.data!;
          final binName = binInfo['bin_name'];
          final binStatus = binInfo['bin_status'];
          final binFillLevel = binInfo['fill_level'];

          final floor = binInfo['floor'] as Map<String, dynamic>?;
          final floorLabel =
              floor?['floor_label']?.toString() ?? 'Unknown floor';

          final building = floor?['building'] as Map<String, dynamic>?;
          final buildingName =
              building?['building_name']?.toString() ?? 'Unknown building';

          final binLocation = '$buildingName, $floorLabel';

          Map<String, dynamic>? device;

          final rawDevice = binInfo['device'];

          if (rawDevice is List && rawDevice.isNotEmpty) {
            device = Map<String, dynamic>.from(rawDevice.first);
          } else if (rawDevice is Map) {
            device = Map<String, dynamic>.from(rawDevice);
          }

          final deviceName = device?['device_name'];
          final deviceSerialNumber = device?['device_serial_number'];
          final deviceStatus = device?['device_status'];
          final deviceLastSeenAt = device?['last_seen_at']?.toString();
          final deviceLiveStatus = getLiveDeviceStatus(deviceLastSeenAt);

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(15, 15, 15, 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  color: colorScheme.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                    side: BorderSide(color: colorScheme.outlineVariant),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        BinFillIcon(fillLevel: binFillLevel, size: 64),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                binName,
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                binLocation,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                              ),
                              const SizedBox(height: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.percent, size: 18),
                                      const SizedBox(width: 6),
                                      Text('Fill level: $binFillLevel%'),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      const Icon(Icons.info_outline, size: 18),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Fill Status: ${binStatus ?? "n/a"}',
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Card(
                  elevation: 0,
                  color: colorScheme.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                    side: BorderSide(color: colorScheme.outlineVariant),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Column(
                      children: [
                        BinInfoRow(
                          icon: Icons.info_outline,
                          title: 'Fill Status',
                          value: binStatus?.toString() ?? 'n/a',
                        ),
                        BinInfoRow(
                          icon: Icons.place_outlined,
                          title: 'Location',
                          value: binLocation,
                        ),
                        BinInfoRow(
                          icon: Icons.perm_device_info,
                          title: 'Device Name',
                          value: deviceName?.toString() ?? 'n/a',
                        ),
                        BinInfoRow(
                          icon: Icons.confirmation_number_outlined,
                          title: 'Serial Number',
                          value: deviceSerialNumber?.toString() ?? 'n/a',
                        ),
                        BinInfoRow(
                          icon: Icons.battery_5_bar_outlined,
                          title: 'Battery Level',
                          value: 'n/a',
                        ),
                        BinInfoRow(
                          icon: Icons.toggle_on_outlined,
                          title: 'Device Status',
                          value: deviceLiveStatus,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.refresh),
                        label: const Text('Check Now'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.power_settings_new),
                        label: const Text('Turn Off'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
