import 'package:flutter/material.dart';
import 'package:iot_bin_app/features/analytics/analytic_viewmodel.dart';
import 'package:iot_bin_app/features/analytics/bin_frequency/bar_graph.dart';

class BinAnalyticPage extends StatefulWidget {
  const BinAnalyticPage({super.key});

  @override
  State<BinAnalyticPage> createState() => _BinAnalyticPageState();
}

class _BinAnalyticPageState extends State<BinAnalyticPage> {
  late final BinAnalyticsViewModel controller;

  @override
  void initState() {
    super.initState();
    controller = BinAnalyticsViewModel();
    controller.addListener(_refresh);
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    controller.removeListener(_refresh);
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FilledButton(
                    onPressed: controller.selectedGraph == 'bin_frequency'
                        ? null
                        : () => controller.changeGraph('bin_frequency'),
                    child: const Text('Bin Frequency'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: controller.selectedGraph == 'bin_fill_rate'
                        ? null
                        : () => controller.changeGraph('bin_fill_rate'),
                    child: const Text('Fill Rate'),
                  ),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 12)),
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.fromLTRB(12, 12, 12, 12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  //graph colour
                  color: const Color.fromARGB(255, 235, 234, 234),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Color.fromARGB(255, 74, 74, 74),
                    width: 1,
                  ),
                ),
                child: FutureBuilder<Map<String, int>>(
                  future: controller.futureCounts,
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
                          'Bins Full Frequency',
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
                        SizedBox(
                          height: 250,
                          child: MyBarChart(counts: counts),
                        ),
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
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Center(
                child: SegmentedButton<int>(
                  showSelectedIcon: false,
                  segments: const [
                    ButtonSegment(value: 1, label: Text('Daily')),
                    ButtonSegment(value: 7, label: Text('Weekly')),
                    ButtonSegment(value: 30, label: Text('Monthly')),
                  ],
                  selected: {controller.days},
                  onSelectionChanged: (newSelection) {
                    final newDays = newSelection.first;
                    controller.changeDays(newDays);
                  },
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
          SliverToBoxAdapter(
            child: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Recent Bin Activity',
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                height: 220,
                width: double.infinity,
                color: Color.fromARGB(255, 245, 245, 245),
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: controller.futureActivity,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }

                    final binActivity = snapshot.data ?? [];

                    if (binActivity.isEmpty) {
                      return const Center(
                        child: Text('No recent activity found'),
                      );
                    }

                    return ListView.separated(
                      itemCount: binActivity.length,
                      itemBuilder: (context, index) {
                        final activityItem = binActivity[index];
                        final bin =
                            activityItem['bin'] as Map<String, dynamic>?;
                        final binName = bin?['bin_name'] ?? 'Unknown bin';
                        final createdAt = activityItem['created_at'] ?? '';
                        final assignment =
                            bin?['bin_assignment'] as Map<String, dynamic>?;

                        String janitorName = 'Unknown employee';

                        if (assignment != null) {
                          final staff =
                              assignment['janitorial_staff']
                                  as Map<String, dynamic>?;
                          janitorName =
                              staff?['full_name'] ?? 'Unknown employee';
                        }

                        return ListTile(
                          leading: Icon(Icons.circle, size: 8),
                          title: Text(
                            '$binName has been emptied by $janitorName',
                          ),
                          subtitle: Text(
                            'at ${controller.formatTime(createdAt)} ',
                          ),
                        );
                      },
                      separatorBuilder: (context, index) =>
                          const Divider(thickness: 1, height: 1),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
