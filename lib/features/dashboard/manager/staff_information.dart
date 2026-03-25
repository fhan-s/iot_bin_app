import 'package:flutter/material.dart';

class StaffInformation extends StatefulWidget {
  const StaffInformation({super.key, required this.staffId});

  final String staffId;

  @override
  State<StaffInformation> createState() => _StaffInformationState();
}

class _StaffInformationState extends State<StaffInformation> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Staff Information')),
      body: Center(child: Text('Staff ID: ${widget.staffId}')),
    );
  }
}
