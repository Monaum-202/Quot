import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:uuid/uuid.dart';
import 'package:invoice_maker/core/utils/quotation_number_gen.dart';
import 'package:invoice_maker/core/utils/date_formatter.dart';
import 'package:invoice_maker/features/customers/data/models/customer_model.dart';
import 'package:invoice_maker/features/customers/providers/customer_provider.dart';
import 'package:invoice_maker/features/templates/providers/template_provider.dart';
import 'package:invoice_maker/features/quotations/data/models/quotation_model.dart';
import 'package:invoice_maker/features/quotations/data/models/line_item_model.dart';
import 'package:invoice_maker/features/quotations/data/models/quotation_status.dart';
import 'package:invoice_maker/features/quotations/providers/quotation_provider.dart';
import 'package:invoice_maker/features/quotations/presentation/widgets/line_item_row.dart';
import 'quotation_preview_screen.dart';

class CreateQuotationScreen extends ConsumerStatefulWidget {
  const CreateQuotationScreen({super.key});

  @override
  ConsumerState<CreateQuotationScreen> createState() => _CreateQuotationScreenState();
}

class _CreateQuotationScreenState extends ConsumerState<CreateQuotationScreen> {
  final _formKey = GlobalKey<FormState>();
  CustomerModel? _selectedCustomer;
  final _projectNameController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime _validUntil = DateTime.now().add(const Duration(days: 30));

  final List<LineItemModel> _items = [
    LineItemModel(description: '', quantity: 1, unit: 'pcs', unitPrice: 0),
  ];

  double _discountAmount = 0;
  double _taxPercent = 0;

  void _addItem() {
    setState(() {
      _items.add(LineItemModel(description: '', quantity: 1, unit: 'pcs', unitPrice: 0));
    });
  }

  void _loadTemplate() {
    final templates = ref.read(templatesProvider);
    showModalBottomSheet(
      context: context,
      builder: (context) => ListView.builder(
        itemCount: templates.length,
        itemBuilder: (context, index) {
          final t = templates[index];
          return ListTile(
            title: Text(t.name),
            subtitle: Text(t.description ?? ''),
            onTap: () {
              setState(() {
                _items.clear();
                for (var item in t.defaultItems) {
                  _items.add(LineItemModel(
                    description: item.description,
                    quantity: item.quantity,
                    unit: item.unit,
                    unitPrice: item.unitPrice,
                  ));
                }
              });
              Navigator.pop(context);
            },
          );
        },
      ),
    );
  }

  void _saveQuotation(QuotationStatus status, {bool showPreview = false}) async {
    if (_selectedCustomer == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a customer')));
      return;
    }

    final quotation = QuotationModel(
      id: const Uuid().v4(),
      quotationNumber: QuotationNumberGen.generate(),
      customerId: _selectedCustomer!.id,
      customerName: _selectedCustomer!.name,
      projectName: _projectNameController.text.trim(),
      items: List.from(_items),
      discountAmount: _discountAmount,
      taxPercent: _taxPercent,
      notes: _notesController.text.trim(),
      status: status,
      createdAt: DateTime.now(),
      validUntil: _validUntil,
      photoPaths: [],
      isConvertedToInvoice: false,
    );

    await ref.read(quotationsProvider.notifier).saveQuotation(quotation);

    if (mounted) {
      if (showPreview) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => QuotationPreviewScreen(quotation: quotation)),
        );
      } else {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final customers = ref.watch(customersProvider);
    final subtotal = _items.fold(0.0, (sum, item) => sum + item.total);
    final grandTotal = subtotal - _discountAmount + (subtotal * _taxPercent / 100);

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Quotation'),
        actions: [
          TextButton(
            onPressed: _loadTemplate,
            child: const Text('TEMPLATES', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Customer Selector
              DropdownButtonFormField<CustomerModel>(
                value: _selectedCustomer,
                decoration: const InputDecoration(labelText: 'Select Customer'),
                items: customers.map((c) => DropdownMenuItem(value: c, child: Text(c.name))).toList(),
                onChanged: (v) => setState(() => _selectedCustomer = v),
              ),
              const Gap(16),
              TextFormField(
                controller: _projectNameController,
                decoration: const InputDecoration(labelText: 'Project Name'),
              ),
              const Gap(16),
              ListTile(
                title: const Text('Valid Until'),
                subtitle: Text(DateFormatter.format(_validUntil)),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _validUntil,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null) setState(() => _validUntil = picked);
                },
              ),
              const Gap(24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Line Items', style: Theme.of(context).textTheme.titleMedium),
                  IconButton(onPressed: _addItem, icon: const Icon(Icons.add_circle, color: Colors.blue)),
                ],
              ),
              const Divider(),
              ...List.generate(_items.length, (index) {
                return LineItemRow(
                  item: _items[index],
                  onDelete: () => setState(() => _items.removeAt(index)),
                  onDescriptionChanged: (v) => _items[index].description = v,
                  onQuantityChanged: (v) => setState(() => _items[index].quantity = v),
                  onUnitChanged: (v) => _items[index].unit = v,
                  onPriceChanged: (v) => setState(() => _items[index].unitPrice = v),
                );
              }),
              const Gap(24),
              // Summary
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    _summaryRow('Subtotal', subtotal),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Discount'),
                        SizedBox(
                          width: 100,
                          child: TextFormField(
                            initialValue: _discountAmount.toString(),
                            decoration: const InputDecoration(prefixText: '৳'),
                            keyboardType: TextInputType.number,
                            onChanged: (v) => setState(() => _discountAmount = double.tryParse(v) ?? 0),
                          ),
                        ),
                      ],
                    ),
                    const Gap(8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Tax (%)'),
                        SizedBox(
                          width: 100,
                          child: TextFormField(
                            initialValue: _taxPercent.toString(),
                            decoration: const InputDecoration(suffixText: '%'),
                            keyboardType: TextInputType.number,
                            onChanged: (v) => setState(() => _taxPercent = double.tryParse(v) ?? 0),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 32),
                    _summaryRow('Grand Total', grandTotal, isBold: true),
                  ],
                ),
              ),
              const Gap(16),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(labelText: 'Notes / Terms'),
                maxLines: 3,
              ),
              const Gap(32),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _saveQuotation(QuotationStatus.draft),
                      child: const Text('SAVE AS DRAFT'),
                    ),
                  ),
                  const Gap(16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _saveQuotation(QuotationStatus.sent, showPreview: true),
                      child: const Text('PREVIEW PDF'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _summaryRow(String label, double value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: isBold ? FontWeight.bold : null)),
          Text(
            '৳${value.toStringAsFixed(2)}',
            style: TextStyle(fontWeight: isBold ? FontWeight.bold : null, fontSize: isBold ? 18 : null),
          ),
        ],
      ),
    );
  }
}
