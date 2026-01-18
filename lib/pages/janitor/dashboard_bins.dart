import 'package:flutter/material.dart';
import 'package:iot_bin_app/utils/bin_card.dart';

class JanitorDashboardBinsPage extends StatefulWidget {
  const JanitorDashboardBinsPage({super.key});

  @override
  State<JanitorDashboardBinsPage> createState() =>
      _JanitorDashboardBinsPageState();
}

class _JanitorDashboardBinsPageState extends State<JanitorDashboardBinsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          //4 boxes representing janitor bins
          Expanded(
            flex: 1,
            child: SizedBox(
              width: double.infinity,
              child: GridView.count(
                crossAxisCount: 2,
                childAspectRatio: 1.2,
                children: [
                  BinCard(title: 'Total Bins', value: '0', icon: Icons.delete),
                  BinCard(
                    title: 'Bins Needing Attention',
                    value: '0',
                    icon: Icons.warning,
                  ),
                  BinCard(
                    title: 'Bins emptied Today',
                    value: '0',
                    icon: Icons.check_circle,
                  ),
                  BinCard(
                    title: 'Average response time',
                    value: '0 min',
                    icon: Icons.bar_chart,
                  ),
                ],
              ),
            ),
          ),
          Text(
            'All Bins',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          // SearchBar(hintText: 'Search Bins'),

          //tiles for each bin with status info
          Expanded(
            child: ListView.builder(
              itemCount: 20,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: const Icon(Icons.delete),
                  title: Text('Bin ${index + 1}'),
                  subtitle: const Text(
                    'Status: Empty\nLast Emptied: 2 days ago',
                  ),
                  isThreeLine: true,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
