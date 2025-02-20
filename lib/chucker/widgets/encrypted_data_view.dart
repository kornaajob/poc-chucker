import 'package:flutter/material.dart';

class EncryptedDataView extends StatelessWidget {
  final String? originalData;
  final String? encryptedData;

  const EncryptedDataView({
    super.key,
    this.originalData,
    this.encryptedData,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (originalData != null) ...[
          Text(
            'Original Data:',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(originalData!),
          ),
        ],
        if (encryptedData != null) ...[
          const SizedBox(height: 16),
          Text(
            'Encrypted Data:',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(encryptedData!),
          ),
        ],
      ],
    );
  }
}
