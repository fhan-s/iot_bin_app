import 'package:flutter/material.dart';
import 'package:iot_bin_app/features/dashboard/bin%20information/bin_information.dart';
import 'package:iot_bin_app/features/dashboard/widgets/bin_fill_icon.dart';
import 'package:iot_bin_app/features/dashboard/widgets/deviceError.dart';

class BinListTile extends StatelessWidget {
  const BinListTile({
    super.key,
    required this.binId,
    required this.binName,
    required this.binStatus,
    required this.binFillLevel,
    required this.binLocation,
    this.assignedTo,
    this.onAssignPressed,
    this.deviceProblemLabel,
  });

  final String binId;
  final String binName;
  final String binStatus;
  final int binFillLevel;
  final String binLocation;
  final String? assignedTo;
  final String? deviceProblemLabel;
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
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              BinFillIcon(fillLevel: binFillLevel, size: 90),
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

                    Text(binStatus),
                    Text(binLocation),

                    if (assignedTo != null) ...[
                      Text('Assigned To: $assignedTo'),
                    ],
                    if (deviceProblemLabel != null) ...[
                      const SizedBox(height: 6),
                      DeviceStatusError(label: deviceProblemLabel!),
                    ],
                    const SizedBox(height: 4),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const SizedBox(width: 10),

                  if (onAssignPressed != null) ...[
                    TextButton(
                      onPressed: onAssignPressed,
                      child: Text(
                        assignedTo == null ||
                                assignedTo == 'No janitor allocated'
                            ? 'Assign'
                            : 'Reassign',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: appColourScheme.primary,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(width: 10),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
