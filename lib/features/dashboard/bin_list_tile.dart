import 'package:flutter/material.dart';
import 'package:iot_bin_app/features/dashboard/bin_information.dart';
import 'package:iot_bin_app/features/dashboard/janitor/widgets/bin_fill_icon.dart';

class BinListTile extends StatelessWidget {
  const BinListTile({
    super.key,
    required this.binId,
    required this.binName,
    required this.binStatus,
    required this.binFillLevel,
    this.assignedTo,
    this.onAssignPressed,
  });

  final String binId;
  final String binName;
  final String binStatus;
  final int binFillLevel;
  final String? assignedTo;
  final VoidCallback? onAssignPressed;

  @override
  Widget build(BuildContext context) {
    final appColourScheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 7),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: appColourScheme.outlineVariant),
      ),
      // when tapped, navigate to bin information page with binId
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BinInformationPage(binId: binId),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              // CircleAvatar(
              //   backgroundColor: appColourScheme.primary,
              //   child: Icon(Icons.delete, color: appColourScheme.onPrimary),
              // ),
              BinFillIcon(fillLevel: binFillLevel),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      binName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text('Status: $binStatus'),
                    if (assignedTo != null) ...[
                      const SizedBox(height: 8),
                      Text('Assigned To: $assignedTo'),
                    ],
                  ],
                ),
              ),
              Row(
                children: [
                  if (onAssignPressed != null) ...[
                    const SizedBox(height: 2, width: 10),
                    FilledButton(
                      onPressed: onAssignPressed,
                      child: Text(
                        assignedTo == null ||
                                assignedTo == 'No janitor allocated'
                            ? 'Assign'
                            : 'Reassign',
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],

                  const Icon(Icons.arrow_forward_ios),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
