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

  void changeDays(int newDays) {
    setState(() {
      days = newDays;
      futureCounts = loadBins();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerHighest,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  'Time range: ',
                  style: TextStyle(color: colorScheme.onSurface),
                ),
                const SizedBox(width: 8),
                DropdownButton<int>(
                  value: days,
                  items: [
                    DropdownMenuItem(
                      value: 1,
                      child: Text(
                        'Last 24 hours',
                        style: TextStyle(color: colorScheme.onSurface),
                      ),
                    ),
                    DropdownMenuItem(
                      value: 7,
                      child: Text(
                        'Last 7 days',
                        style: TextStyle(color: colorScheme.onSurface),
                      ),
                    ),
                    DropdownMenuItem(
                      value: 30,
                      child: Text(
                        'Last 30 days',
                        style: TextStyle(color: colorScheme.onSurface),
                      ),
                    ),
                  ],
                  onChanged: (newDays) {
                    if (newDays != null) changeDays(newDays);
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
                  return Column(
                    children: [
                      Text(
                        'Bar Chart of Bins Full Frequency',
                        style: TextStyle(
                          color: colorScheme.onSurface,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Frequency of Bin being Full',
                          style: TextStyle(
                            color: colorScheme.onSurface,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(child: MyBarChart(counts: counts)),
                      Text(
                        'Bin names',
                        style: TextStyle(
                          color: colorScheme.onSurface,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
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
