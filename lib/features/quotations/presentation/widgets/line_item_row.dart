import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../data/models/line_item_model.dart';

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
    final isSmallScreen = MediaQuery.of(context).size.width < 360;

    if (isSmallScreen) {
      return Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: item.description,
                      decoration: const InputDecoration(hintText: 'Description'),
                      onChanged: onDescriptionChanged,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: onDelete,
                  ),
                ],
              ),
              const Gap(8),
              Row(
                children: [
                  SizedBox(
                    width: 60,
                    child: TextFormField(
                      initialValue: item.quantity.toString(),
                      decoration: const InputDecoration(hintText: 'Qty'),
                      keyboardType: TextInputType.number,
                      onChanged: (v) => onQuantityChanged(double.tryParse(v) ?? 0),
                    ),
                  ),
                  const Gap(8),
                  SizedBox(
                    width: 80,
                    child: DropdownButtonFormField<String>(
                      value: item.unit,
                      items: ['sqft', 'rft', 'job', 'pcs', 'kg', 'bag', 'day', 'hour', 'ls']
                          .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                          .toList(),
                      onChanged: (v) => onUnitChanged(v ?? 'pcs'),
                      decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 8)),
                    ),
                  ),
                  const Gap(8),
                  Expanded(
                    child: TextFormField(
                      initialValue: item.unitPrice.toString(),
                      decoration: const InputDecoration(hintText: 'Price'),
                      keyboardType: TextInputType.number,
                      onChanged: (v) => onPriceChanged(double.tryParse(v) ?? 0),
                    ),
                  ),
                  const Gap(8),
                  Text('৳${item.total.toStringAsFixed(0)}'),
                ],
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: TextFormField(
              initialValue: item.description,
              decoration: const InputDecoration(hintText: 'Description'),
              onChanged: onDescriptionChanged,
            ),
          ),
          const Gap(4),
          SizedBox(
            width: 50,
            child: TextFormField(
              initialValue: item.quantity.toString(),
              decoration: const InputDecoration(hintText: 'Qty'),
              keyboardType: TextInputType.number,
              onChanged: (v) => onQuantityChanged(double.tryParse(v) ?? 0),
            ),
          ),
          const Gap(4),
          SizedBox(
            width: 70,
            child: DropdownButtonFormField<String>(
              value: item.unit,
              items: ['sqft', 'rft', 'job', 'pcs', 'kg', 'bag', 'day', 'hour', 'ls']
                  .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                  .toList(),
              onChanged: (v) => onUnitChanged(v ?? 'pcs'),
              decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 4)),
            ),
          ),
          const Gap(4),
          Expanded(
            flex: 2,
            child: TextFormField(
              initialValue: item.unitPrice.toString(),
              decoration: const InputDecoration(hintText: 'Price'),
              keyboardType: TextInputType.number,
              onChanged: (v) => onPriceChanged(double.tryParse(v) ?? 0),
            ),
          ),
          const Gap(4),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red, size: 20),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}
