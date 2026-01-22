import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:iot_bin_app/utils/bin_fill_icon.dart';

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
          ''' bin_name, bin_status, fill_level, floor:floor_id ( floor_label, building:building_id (building_name) ), device:sensor_device ( device_id, device_name, device_serial_number, device_status, latest_battery_level ) ''',
        )
        .eq('bin_id', widget.binId)
        .single();
    return Map<String, dynamic>.from(binData);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          final binFloor = binInfo['floor'];
          final binBuilding = binFloor['building'];
          final binFillLevel = binInfo['fill_level'];
          final devices = (binInfo['device'] as List?) ?? [];
          final device = devices.isNotEmpty
              ? devices.first as Map<String, dynamic>
              : null;

          final deviceName = device?['device_name'];
          final deviceSerialNumber = device?['device_serial_number'];
          final deviceStatus = device?['device_status'];
          final deviceBatteryLevel = device?['latest_battery_level'];

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BinFillIcon(fillLevel: binFillLevel, size: 60),
                Text(
                  'Device Status: $deviceStatus',
                  style: const TextStyle(fontSize: 18),
                ),
                Text('Name: $binName', style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 8),
                Text(
                  'Fill Status: $binStatus',
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 8),
                Text(
                  'Location: ${binBuilding['building_name']}, Floor ${binFloor['floor_label']}',
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 8),
                Text(
                  'Fill Level: $binFillLevel',
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 8),
                Text(
                  'Device Serial Number: $deviceSerialNumber',
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 8),
                Text(
                  'Device Name: $deviceName',
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 8),
                Text(
                  'Battery Level: $deviceBatteryLevel%',
                  style: const TextStyle(fontSize: 18),
                ),
                Text('Last Updated: N/A', style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 8),
                ElevatedButton(onPressed: () {}, child: const Text('Update')),
                ElevatedButton(onPressed: () {}, child: const Text('Turn Off')),
              ],
            ),
          );
        },
      ),
    );
  }
}
