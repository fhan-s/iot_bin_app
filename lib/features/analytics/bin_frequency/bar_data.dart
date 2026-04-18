import 'package:supabase_flutter/supabase_flutter.dart';

class BinFrequencyData {
  final SupabaseClient supabase;
  BinFrequencyData(this.supabase);

  Future<Map<String, int>> getFullCountsPerBin({
    required String userId,
    required DateTime since,
  }) async {
    final userRoleRow = await supabase
        .from('janitorial_staff')
        .select('role')
        .eq('id', userId)
        .maybeSingle();

    final role = userRoleRow?['role']?.toString().toLowerCase();

    final List<String> binListIds = [];
    final Map<String, String> binIdToName = {};

    if (role == 'manager') {
      final allBins = await supabase.from('bin').select('bin_id, bin_name');

      for (final bin in (allBins as List)) {
        final binId = bin['bin_id']?.toString();
        if (binId == null) continue;

        binListIds.add(binId);
        binIdToName[binId] = bin['bin_name']?.toString() ?? 'Unknown';
      }
    } else if (role == 'janitor') {
      final allocatedBins = await supabase
          .from('bin_assignment')
          .select('bin_id, bin:bin_id(bin_name)')
          .eq('janitor_id', userId);

      for (final bin in (allocatedBins as List)) {
        final binId = bin['bin_id']?.toString();
        if (binId == null) continue;

        binListIds.add(binId);
        binIdToName[binId] = bin['bin']?['bin_name']?.toString() ?? 'Unknown';
      }
    } else {
      return {};
    }

    if (binListIds.isEmpty) return {};

    final notificationEvents = await supabase
        .from('notification_event')
        .select('bin_id, created_at')
        .inFilter('bin_id', binListIds)
        .gte('created_at', since.toIso8601String()); // Filter by date

    final Map<String, int> binFrequency = {};

    for (final row in (notificationEvents as List)) {
      final notificationBinId = row['bin_id']?.toString();
      if (notificationBinId == null) continue;

      final name = binIdToName[notificationBinId] ?? 'Unknown';
      binFrequency[name] = (binFrequency[name] ?? 0) + 1;
    }

    return binFrequency;
  }
}
