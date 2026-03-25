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
    final janitordata = await supabase
        .from('janitorial_staff')
        .select('id, full_name')
        .eq('role', 'janitor');

    if (!mounted) return;

    setState(() {
      janitors = List<Map<String, dynamic>>.from(janitordata);
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

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const SizedBox(
        height: 250,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return SafeArea(
      child: SizedBox(
        height: 350,
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
                    leading: const CircleAvatar(child: Icon(Icons.person)),
                    title: Text(janitor['full_name'] ?? 'Unnamed Janitor'),
                    onTap: () async {
                      await assignJanitor(janitor['id'].toString());
                    },
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
