import 'package:flutter/material.dart';
import 'package:iot_bin_app/utils/bin_card.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:iot_bin_app/pages/janitor/bin_information.dart';
import 'package:iot_bin_app/utils/fill_level_card_icon.dart';

class JanitorDashboardBinsPage extends StatefulWidget {
  const JanitorDashboardBinsPage({super.key});

  @override
  State<JanitorDashboardBinsPage> createState() =>
      _JanitorDashboardBinsPageState();
}

class _JanitorDashboardBinsPageState extends State<JanitorDashboardBinsPage> {
  final supabase = Supabase.instance.client;
  Future<List<Map<String, dynamic>>> getBins() async {
    final binData = await supabase
        .from('bin_assignment')
        .select('bin:bin (bin_id,bin_name, bin_status, fill_level)');
    return (binData as List)
        .map((row) => row['bin'] as Map<String, dynamic>)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          //4 boxes representing janitor bins
          Expanded(
            flex: 2,
            child: SizedBox(
              width: double.infinity,
              child: GridView.count(
                crossAxisCount: 2,
                childAspectRatio: 1.2,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.all(8),
                children: [
                  BinCard(
                    title: 'Total Bins',
                    value: 'n/a',
                    icon: Icons.delete,
                  ),
                  BinCard(
                    title: 'Bins Needing Attention',
                    value: 'n/a',
                    icon: Icons.warning,
                  ),
                  BinCard(
                    title: 'Bins emptied Today',
                    value: 'n/a',
                    icon: Icons.check_circle,
                  ),
                  BinCard(
                    title: 'Average response time',
                    value: 'n/a',
                    icon: Icons.bar_chart,
                  ),
                ],
              ),
            ),
          ),
          // Container(
          //   padding: const EdgeInsets.all(8.0),
          //   color: const Color.fromARGB(255, 141, 131, 196),
          //   child: Column(
          //     children: [
          //       const Align(
          //         alignment: Alignment.centerLeft,
          //         child: Text(
          //           'My Bins',
          //           style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          //         ),
          //       ),
          //       const SizedBox(height: 8),
          //       SearchBar(hintText: 'Search Bins'),
          //     ],
          //   ),
          // ),

          //tiles for each bin with status info
          Expanded(
            flex: 1,
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: getBins(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  print(snapshot.error);
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No bins found.'));
                }
                final bins = snapshot.data!;

                // sort bins in descending fill level
                bins.sort((a, b) {
                  final fillA = (a['fill_level'] ?? 0) as int;
                  final fillB = (b['fill_level'] ?? 0) as int;
                  return fillB.compareTo(fillA);
                });
                return ListView.builder(
                  itemCount: bins.length,
                  itemBuilder: (context, index) {
                    final bin = bins[index];

                    return Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.grey.shade400,
                          width: 1.5,
                        ),
                      ),
                      child: ListTile(
                        leading: const Icon(Icons.delete),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Bin name: ${bin['bin_name']}'),
                            Text('Status: ${bin['bin_status']}'),
                            const SizedBox(height: 4),
                            FillLevelCardIcon(
                              fillLevel: bin['fill_level'] ?? 0,
                            ),
                          ],
                        ),
                        isThreeLine: true,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BinInformationPage(
                                binId: bin['bin_id'].toString(),
                              ),
                            ),
                          );
                        },
                      ),
                    );
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
