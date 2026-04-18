import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AssignJanitorBin extends StatefulWidget {
  const AssignJanitorBin({super.key, required this.binId});

  final String binId;

  @override
  State<AssignJanitorBin> createState() => _AssignJanitorBinState();
}

class _AssignJanitorBinState extends State<AssignJanitorBin> {
  final supabase = Supabase.instance.client;
  bool isLoading = true;
  List<Map<String, dynamic>> janitors = [];

  @override
  void initState() {
    super.initState();
    getJanitors();
  }

  Future<void> getJanitors() async {
    final janitorData = await supabase
        .from('janitorial_staff')
        .select('''
        id,
        full_name,
        bin_assignment (
          bin_id
        )
      ''')
        .eq('role', 'janitor');

    final processed = List<Map<String, dynamic>>.from(janitorData).map((
      janitor,
    ) {
      final assignments = janitor['bin_assignment'];

      int count = 0;

      if (assignments != null) {
        count = assignments.length;
      }
      return {
        'id': janitor['id'],
        'full_name': janitor['full_name'],
        'allocated_bins': count,
      };
    }).toList();

    if (!mounted) return;
    setState(() {
      janitors = processed;
      isLoading = false;
    });
  }

  Future<void> assignJanitor(String janitorId) async {
    await supabase.from('bin_assignment').upsert({
      'bin_id': widget.binId,
      'janitor_id': janitorId,
    }, onConflict: 'bin_id');

    if (!mounted) return;
    Navigator.pop(context, true);
  }

  // UI for assigning janitor to bin
  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Container(
        height: 250,
        alignment: Alignment.center,
        child: const CircularProgressIndicator(),
      );
    }
    return Container(
      height: 350,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 12),
          const Text(
            'Assign Janitor',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              itemCount: janitors.length,
              itemBuilder: (context, index) {
                final janitor = janitors[index];

                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: const Color.fromARGB(255, 216, 215, 215),
                    child: Icon(Icons.person_2),
                  ),
                  title: Text(janitor['full_name'] ?? 'Unnamed Janitor'),
                  subtitle: Text(
                    'Allocated Bins: ${janitor['allocated_bins'] ?? 0}',
                  ),
                  onTap: () async {
                    await assignJanitor(janitor['id'].toString());
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
