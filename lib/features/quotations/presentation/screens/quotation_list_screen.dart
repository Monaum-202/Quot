import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:gap/gap.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../data/models/quotation_model.dart';
import '../data/models/quotation_status.dart';
import '../providers/quotation_provider.dart';
import '../widgets/status_badge.dart';
import 'create_quotation_screen.dart';
import 'quotation_preview_screen.dart';

class QuotationListScreen extends ConsumerWidget {
  const QuotationListScreen({super.key});

  void _showStatusUpdateSheet(BuildContext context, WidgetRef ref, QuotationModel q) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: QuotationStatus.values.map((status) {
          return ListTile(
            title: Text(status.name.toUpperCase()),
            leading: Icon(Icons.circle, color: _getStatusColor(status)),
            onTap: () async {
              q.status = status;
              await ref.read(quotationsProvider.notifier).saveQuotation(q);
              Navigator.pop(context);
            },
          );
        }).toList(),
      ),
    );
  }

  Color _getStatusColor(QuotationStatus status) {
    switch (status) {
      case QuotationStatus.draft: return Colors.grey;
      case QuotationStatus.sent: return Colors.blue;
      case QuotationStatus.approved: return Colors.green;
      case QuotationStatus.rejected: return Colors.red;
      case QuotationStatus.convertedToInvoice: return Colors.purple;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quotations'),
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.lazyBox<QuotationModel>(HiveBoxNames.quotations).listenable(),
        builder: (context, box, _) {
          if (box.isEmpty) {
            return const EmptyStateWidget(
              message: 'No quotations yet. Tap + to create one.',
              icon: Icons.description_outlined,
            );
          }

          final keys = box.keys.toList().reversed.toList();

          return ListView.builder(
            itemCount: keys.length,
            itemBuilder: (context, index) {
              final key = keys[index];
              return FutureBuilder(
                future: box.get(key),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const SizedBox();
                  final q = snapshot.data as QuotationModel;
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: ListTile(
                      title: Text(q.quotationNumber, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('${q.customerName} - ${q.projectName}'),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('৳${q.grandTotal.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                          const Gap(4),
                          StatusBadge(status: q.status),
                        ],
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => QuotationPreviewScreen(quotation: q)),
                        );
                      },
                      onLongPress: () => _showStatusUpdateSheet(context, ref, q),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateQuotationScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
