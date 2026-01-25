import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:iot_bin_app/features/analytics/janitor/bar_graph.dart';
import 'package:iot_bin_app/features/analytics/janitor/bar_data.dart';

class JanitorAnalyticPage extends StatefulWidget {
  const JanitorAnalyticPage({super.key});

  @override
  State<JanitorAnalyticPage> createState() => _JanitorAnalyticPageState();
}

class _JanitorAnalyticPageState extends State<JanitorAnalyticPage> {
  final supabase = Supabase.instance.client;

  int days = 7;
  late Future<Map<String, int>> futureCounts;

  @override
  void initState() {
    super.initState();
    futureCounts = loadBins();
  }

  Future<Map<String, int>> loadBins() async {
    //Get current user janitor id
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return {};

    final binGraphData = BarData(supabase);
    final since = DateTime.now().subtract(Duration(days: days));

    return binGraphData.getFullCountsPerBin(janitorId: userId, since: since);
  }

  void _changeDays(int newDays) {
    setState(() {
      days = newDays;
      futureCounts = loadBins();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                const Text('Time range: '),
                const SizedBox(width: 8),
                DropdownButton<int>(
                  value: days,
                  items: const [
                    DropdownMenuItem(value: 1, child: Text('Last 24 hours')),
                    DropdownMenuItem(value: 7, child: Text('Last 7 days')),
                    DropdownMenuItem(value: 30, child: Text('Last 30 days')),
                  ],
                  onChanged: (newDays) {
                    if (newDays != null) _changeDays(newDays);
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: FutureBuilder<Map<String, int>>(
                future: futureCounts,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  final counts = snapshot.data ?? {};
                  return MyBarChart(counts: counts);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
