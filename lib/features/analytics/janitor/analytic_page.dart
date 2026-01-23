import 'package:flutter/material.dart';

class JanitorAnalyticPage extends StatefulWidget {
  const JanitorAnalyticPage({super.key});

  @override
  State<JanitorAnalyticPage> createState() => _JanitorAnalyticPageState();
}

class _JanitorAnalyticPageState extends State<JanitorAnalyticPage> {
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
                children: [],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
