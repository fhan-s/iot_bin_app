import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:iot_bin_app/features/analytics/bin_frequency/bar_data.dart';

class BinAnalyticsViewModel extends ChangeNotifier {
  final supabase = Supabase.instance.client;

  String selectedGraph = 'bin_frequency';
  int numberOfActivityItems = 10;
  int days = 1;

  Future<Map<String, int>>? futureCounts;
  Future<List<Map<String, dynamic>>>? futureActivity;

  BinAnalyticsViewModel() {
    futureCounts = loadGraphData();
    futureActivity = loadRecentActivity();
  }

  Future<List<Map<String, dynamic>>> loadRecentActivity() async {
    final user = supabase.auth.currentUser;
    if (user == null) return [];

    final userRole = await supabase
        .from('janitorial_staff')
        .select('role')
        .eq('id', user.id)
        .single();

    final role = userRole['role'];

    // Retrieves the recent emptied bins using nested Supabase select.
    final emptiedBinsData = await supabase
        .from('bins_emptied')
        .select('''
          created_at,
          bin:bin_id (
            bin_id,
            bin_name,
            bin_assignment (
              janitor_id,
              janitorial_staff (
                full_name
              )
            )
          )
        ''')
        .order('created_at', ascending: false)
        .limit(numberOfActivityItems);

    final data = List<Map<String, dynamic>>.from(emptiedBinsData);

    if (role == 'janitor') {
      return data.where((item) {
        final bin = item['bin'] as Map<String, dynamic>?;
        final assignment = bin?['bin_assignment'] as Map<String, dynamic>?;

        if (assignment == null) return false;

        return assignment['janitor_id'] == user.id;
      }).toList();
    }

    return data;
  }

  Future<Map<String, int>> loadGraphData() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return {};

    final since = DateTime.now().subtract(Duration(days: days));
    //display bin frequency data graph if selected
    if (selectedGraph == 'bin_frequency') {
      final binGraphData = BinFrequencyData(supabase);
      return binGraphData.getFullCountsPerBin(userId: userId, since: since);
    }
    //display bin fill rate data graph if selected

    // if (selectedGraph == 'bin_fill_rate') {
    //   final binGraphData = BinFrequencyData(supabase);
    //   return binGraphData
    // }

    return {};
  }

  void changeDays(int newDays) {
    days = newDays;
    futureCounts = loadGraphData();
    notifyListeners();
  }

  void changeGraph(String graphType) {
    selectedGraph = graphType;
    futureCounts = loadGraphData();
    notifyListeners();
  }

  // function to format bin activity datetime string to human readable format eg 23/4/2026 13:00
  String formatTime(String isoString) {
    final dt = DateTime.parse(isoString).toLocal();
    return '${dt.day}/${dt.month}/${dt.year} '
        '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}';
  }
}
