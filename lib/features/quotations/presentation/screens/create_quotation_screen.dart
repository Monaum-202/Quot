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
import 'package:invoice_maker/features/company_profile/providers/company_provider.dart';
import 'package:invoice_maker/core/utils/currency_formatter.dart';
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
  bool _showItemPrices = true;

  void _addItem() {
    setState(() {
      _items.add(LineItemModel(description: '', quantity: 1, unit: 'pcs', unitPrice: 0));
    });
  }

  void _loadTemplate() {
    final templates = ref.read(templatesProvider);
    if (templates.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No templates found')));
      return;
    }
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
      showItemPrices: _showItemPrices,
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
              // Customer Selection
              DropdownButtonFormField<CustomerModel>(
                value: _selectedCustomer,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Select Customer',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person_outline),
                ),
                items: customers.map((c) => DropdownMenuItem(value: c, child: Text(c.name))).toList(),
                onChanged: (v) => setState(() => _selectedCustomer = v),
              ),
              const Gap(16),
              // Project Name
              TextFormField(
                controller: _projectNameController,
                decoration: const InputDecoration(
                  labelText: 'Project Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.work_outline),
                ),
              ),
              const Gap(16),
              // Date Selection
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _validUntil,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null) setState(() => _validUntil = picked);
                },
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Valid Until',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.calendar_today_outlined),
                  ),
                  child: Text(DateFormatter.format(_validUntil)),
                ),
              ),
              const Gap(16),
              // Show Item Prices Toggle
              SwitchListTile(
                title: const Text('Show Item Prices in PDF'),
                subtitle: const Text('If off, will show as "Lump Sum" (no individual prices)'),
                value: _showItemPrices,
                onChanged: (v) => setState(() => _showItemPrices = v),
                contentPadding: EdgeInsets.zero,
              ),
              const Gap(16),
              // Line Items Section Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Line Items', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  TextButton.icon(
                    onPressed: _loadTemplate,
                    icon: const Icon(Icons.copy_all),
                    label: const Text('From Template'),
                  ),
                ],
              ),
              const Divider(),
              const Gap(16),
              // Line Items List
              ...List.generate(_items.length, (index) {
                return LineItemRow(
                  key: ValueKey('item_${index}_${_items.length}'), // Basic key to help with list state
                  item: _items[index],
                  onDelete: () => setState(() {
                    if (_items.length > 1) {
                      _items.removeAt(index);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('At least one item is required')),
                      );
                    }
                  }),
                  onDescriptionChanged: (v) => _items[index].description = v,
                  onQuantityChanged: (v) => setState(() => _items[index].quantity = v),
                  onUnitChanged: (v) => _items[index].unit = v,
                  onPriceChanged: (v) => setState(() => _items[index].unitPrice = v),
                );
              }),
              const Gap(8),
              // Add Item Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _addItem,
                  icon: const Icon(Icons.add),
                  label: const Text('ADD LINE ITEM'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const Gap(32),
              // Calculation Summary Section
              Card(
                elevation: 0,
                color: Colors.blueGrey.shade50,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.blueGrey.shade100),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Summary',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const Gap(16),
                      _summaryRow('Subtotal', subtotal),
                      const Gap(12),
                      // Discount Field
                      Row(
                        children: [
                          const Expanded(child: Text('Discount')),
                          SizedBox(
                            width: 140,
                            child: TextFormField(
                              initialValue: _discountAmount > 0 ? _discountAmount.toString() : '',
                              textAlign: TextAlign.end,
                              decoration: const InputDecoration(
                                prefixText: '৳',
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                border: OutlineInputBorder(),
                                filled: true,
                                fillColor: Colors.white,
                              ),
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              onChanged: (v) => setState(() => _discountAmount = double.tryParse(v) ?? 0),
                            ),
                          ),
                        ],
                      ),
                      const Gap(12),
                      // Tax Field
                      Row(
                        children: [
                          const Expanded(child: Text('Tax')),
                          SizedBox(
                            width: 140,
                            child: TextFormField(
                              initialValue: _taxPercent > 0 ? _taxPercent.toString() : '',
                              textAlign: TextAlign.end,
                              decoration: const InputDecoration(
                                suffixText: '%',
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                border: OutlineInputBorder(),
                                filled: true,
                                fillColor: Colors.white,
                              ),
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
              ),
              const Gap(24),
              // Notes
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes / Terms',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 3,
              ),
              const Gap(32),
              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _saveQuotation(QuotationStatus.draft),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('SAVE DRAFT'),
                    ),
                  ),
                  const Gap(16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _saveQuotation(QuotationStatus.sent, showPreview: true),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('PREVIEW PDF'),
                    ),
                  ),
                ],
              ),
              const Gap(24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _summaryRow(String label, double value, {bool isBold = false}) {
    final company = ref.watch(companyProvider);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : null,
            fontSize: isBold ? 16 : null,
          ),
        ),
        Text(
          CurrencyFormatter.format(value, symbol: company?.currency ?? 'SR'),
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : null,
            fontSize: isBold ? 20 : 16,
            color: isBold ? Colors.blue.shade800 : null,
          ),
        ),
      ],
    );
  }
}
