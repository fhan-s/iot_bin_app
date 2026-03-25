import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:iot_bin_app/features/dashboard/manager/staff_information.dart';

class ManagerDashboardStaffPage extends StatefulWidget {
  const ManagerDashboardStaffPage({super.key});

  @override
  State<ManagerDashboardStaffPage> createState() =>
      _ManagerDashboardStaffPageState();
}

class _ManagerDashboardStaffPageState extends State<ManagerDashboardStaffPage>
    with WidgetsBindingObserver {
  final supabase = Supabase.instance.client;
  RealtimeChannel? channel;
  List<Map<String, dynamic>> staffList = [];
  Set<String> staffIDS = {};

  //fetch janitors with "janitor" role
  Future<List<Map<String, dynamic>>> getStaff() async {
    final staffData = await supabase
        .from('janitorial_staff')
        .select('id, full_name, role')
        .eq('role', 'janitor');

    return List<Map<String, dynamic>>.from(staffData);
  }

  Future<void> loadStaff() async {
    final loadedStaff = await getStaff();
    if (!mounted) return;
    setState(() {
      staffList = loadedStaff;
      staffIDS = staffList.map((staff) => staff['id'].toString()).toSet();
    });
  }

  Future<void> realTimeUpdates() async {
    //load and get all janitors
    await loadStaff();

    staffIDS = (await getStaff())
        .map((staff) => staff['id'].toString())
        .toSet();

    if (channel != null) {
      supabase.removeChannel(channel!);
    }
    // //subscribe to real-time updates for janitors
    channel = supabase.channel('realtime_staff_channel');

    //listen for updates on the bin table
    channel!
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'janitorial_staff',
          callback: (payload) async {
            final updatedStaff = payload.newRecord;
            final updatedStaffId = updatedStaff['id']?.toString();
            // If the updated staff is in the janitor's allocated bins, refresh the bin list
            if (updatedStaffId != null && staffIDS.contains(updatedStaffId)) {
              await loadStaff();
            }
          },
        )
        .subscribe();
  }

  // listen for app lifecycle changes
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // App has come to the foreground
      realTimeUpdates();
    }
  }

  // init state to setup real-time updates
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    realTimeUpdates();
  }

  // dispose to remove channel subscription
  @override
  void dispose() {
    if (channel != null) {
      supabase.removeChannel(channel!);
    }
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appColourScheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(15, 15, 15, 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Overview',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Janitors',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),
          //tiles for each bin with status info
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            sliver: SliverToBoxAdapter(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: getStaff(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  if (snapshot.hasError) {
                    debugPrint(snapshot.error.toString());
                    return Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Center(
                        child: Text(
                          'Error loading staff: ${snapshot.error}',
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    );
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.only(top: 20.0),
                      child: Center(child: Text('No staff found.')),
                    );
                  }
                  final staff = snapshot.data!;

                  return Column(
                    children: List.generate(staff.length, (index) {
                      final staffMember = staff[index];

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 7),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: appColourScheme.outlineVariant,
                          ),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          leading: CircleAvatar(
                            backgroundColor: appColourScheme.primary,
                            child: Icon(
                              Icons.delete,
                              color: appColourScheme.onPrimary,
                            ),
                          ),
                          title: Text(
                            staffMember['full_name'] ?? 'Unnamed Staff',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => StaffInformation(
                                  staffId: staffMember['id'].toString(),
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    }),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
