import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BarData {
  final SupabaseClient supabase;
  BarData(this.supabase);

  Future<Map<String, int>> getFullCountsPerBin({
    required String janitorId,
    required DateTime since,
  }) async {
    //Get bins assigned to janitor
    final allocatedBins = await supabase
        .from('bin_assignment')
        .select('bin_id, bin:bin_id(bin_name)')
        .eq('janitor_id', janitorId);

    final List<String> binListIds = [];
    final Map<String, String> binIdToName = {};

    for (final bin in (allocatedBins as List)) {
      final allocatedBinId = bin['bin_id']?.toString();

      if (allocatedBinId == null) continue;
      binListIds.add(allocatedBinId);

      //Get bin name for mapping
      final binName = bin['bin']?['bin_name']?.toString() ?? 'Unknown';
      binIdToName[allocatedBinId] = binName;
    }

    if (binListIds.isEmpty) return {};

    //Get notification events for bins in the time range
    final notificationEvents = await supabase
        .from('notification_event')
        .select('bin_id, created_at')
        .inFilter('bin_id', binListIds)
        .gte('created_at', since.toIso8601String());

    // bin frequency per bin name in the time range
    final Map<String, int> binFrequency = {};

    for (final row in (notificationEvents as List)) {
      final notificationId = row['bin_id']?.toString();
      if (notificationId == null) continue;

      final name = binIdToName[notificationId] ?? 'Unknown';
      binFrequency[name] = (binFrequency[name] ?? 0) + 1;
    }

    return binFrequency;
  }
}
