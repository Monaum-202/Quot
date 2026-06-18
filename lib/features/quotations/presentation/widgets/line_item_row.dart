import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:invoice_maker/features/quotations/data/models/line_item_model.dart';

class LineItemRow extends StatelessWidget {
  final LineItemModel item;
  final VoidCallback onDelete;
  final Function(String) onDescriptionChanged;
  final Function(double) onQuantityChanged;
  final Function(String) onUnitChanged;
  final Function(double) onPriceChanged;

  const LineItemRow({
    super.key,
    required this.item,
    required this.onDelete,
    required this.onDescriptionChanged,
    required this.onQuantityChanged,
    required this.onUnitChanged,
    required this.onPriceChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Line 1: Description
            TextFormField(
              initialValue: item.description,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'e.g. Interior Painting',
                isDense: true,
                border: OutlineInputBorder(),
              ),
              onChanged: onDescriptionChanged,
            ),
            const Gap(12),
            // Line 2: Quantity, Unit, and Calculated Amount
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    initialValue: item.quantity > 0 ? item.quantity.toString() : '',
                    decoration: const InputDecoration(
                      labelText: 'Qty',
                      isDense: true,
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (v) => onQuantityChanged(double.tryParse(v) ?? 0),
                  ),
                ),
                const Gap(8),
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<String>(
                    value: item.unit,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Unit',
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                      border: OutlineInputBorder(),
                    ),
                    items: ['sqft', 'rft', 'job', 'pcs', 'kg', 'bag', 'day', 'hour', 'ls']
                        .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                        .toList(),
                    onChanged: (v) => onUnitChanged(v ?? 'pcs'),
                  ),
                ),
                const Gap(8),
                Expanded(
                  flex: 3,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50.withOpacity(0.3),
                      border: Border.all(color: Colors.blue.shade100),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('Amount', style: TextStyle(fontSize: 10, color: Colors.blueGrey)),
                        FittedBox(
                          child: Text(
                            '৳${item.total.toStringAsFixed(2)}',
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue.shade900),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const Gap(12),
            // Line 3: Unit Price and Delete
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: item.unitPrice > 0 ? item.unitPrice.toString() : '',
                    decoration: const InputDecoration(
                      labelText: 'Unit Price',
                      prefixText: '৳',
                      isDense: true,
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (v) => onPriceChanged(double.tryParse(v) ?? 0),
                  ),
                ),
                const Gap(12),
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  tooltip: 'Remove Item',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
