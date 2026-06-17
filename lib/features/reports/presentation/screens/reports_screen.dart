import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:invoice_maker/features/quotations/providers/quotation_provider.dart';
import 'package:invoice_maker/features/invoices/providers/invoice_provider.dart';
import 'package:invoice_maker/core/utils/currency_formatter.dart';
import 'package:invoice_maker/features/quotations/data/models/quotation_status.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quotationsAsync = ref.watch(quotationsProvider);
    final invoicesAsync = ref.watch(invoicesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Reports')),
      body: quotationsAsync.when(
        data: (quotations) => invoicesAsync.when(
          data: (invoices) => _buildReport(context, quotations, invoices),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, s) => Center(child: Text('Error: $e')),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildReport(BuildContext context, quotations, invoices) {
    final now = DateTime.now();
    final thisMonthQuotations = quotations.where((q) => q.createdAt.month == now.month && q.createdAt.year == now.year).toList();

    final approvedCount = thisMonthQuotations.where((q) => q.status == QuotationStatus.approved || q.status == QuotationStatus.convertedToInvoice).length;
    final pendingCount = thisMonthQuotations.where((q) => q.status == QuotationStatus.sent).length;

    final totalRevenue = invoices.fold(0.0, (sum, i) => sum + i.grandTotal);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('This Month', style: Theme.of(context).textTheme.titleLarge),
          const Gap(16),
          Row(
            children: [
              _metricCard('Total QT', '${thisMonthQuotations.length}', Colors.blue),
              const Gap(12),
              _metricCard('Approved', '$approvedCount', Colors.green),
            ],
          ),
          const Gap(12),
          Row(
            children: [
              _metricCard('Pending', '$pendingCount', Colors.orange),
              const Gap(12),
              _metricCard('Revenue', CurrencyFormatter.format(totalRevenue), Colors.purple),
            ],
          ),
          const Gap(24),
          Text('Recent Activity', style: Theme.of(context).textTheme.titleLarge),
          const Gap(8),
          ...quotations.take(5).map((q) => ListTile(
            title: Text(q.customerName),
            subtitle: Text(q.quotationNumber),
            trailing: Text(CurrencyFormatter.format(q.grandTotal)),
          )),
        ],
      ),
    );
  }

  Widget _metricCard(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.5)),
        ),
        child: Column(
          children: [
            Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
            const Gap(4),
            Text(label, style: TextStyle(color: color, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
