import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
          'bin_name, bin_status, floor:floor_id (floor_label, building:building_id (building_name))',
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

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.delete,
                  size: 100,
                  color: Color.fromARGB(255, 126, 126, 126),
                ),
                Icon(
                  Icons.delete,
                  size: 100,
                  color: Color.fromARGB(255, 63, 196, 51),
                ),
                Text('Status: N/A', style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 8),
                Text(
                  'Battery Level: N/A',
                  style: const TextStyle(fontSize: 18),
                ),
                Text('Time Running: N/A', style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 8),
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
                Text('Fill Level: N/A', style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 8),
                const SizedBox(height: 8),
                Text('Device ID: N/A', style: const TextStyle(fontSize: 18)),
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
