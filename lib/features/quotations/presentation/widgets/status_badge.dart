import 'package:flutter/material.dart';
import '../data/models/quotation_status.dart';

class StatusBadge extends StatelessWidget {
  final QuotationStatus status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status) {
      case QuotationStatus.draft:
        color = Colors.grey;
        break;
      case QuotationStatus.sent:
        color = Colors.blue;
        break;
      case QuotationStatus.approved:
        color = Colors.green;
        break;
      case QuotationStatus.rejected:
        color = Colors.red;
        break;
      case QuotationStatus.convertedToInvoice:
        color = Colors.purple;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        status.name.toUpperCase(),
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}
