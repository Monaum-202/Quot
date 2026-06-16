import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/constants/hive_box_names.dart';
import '../../data/models/quotation_model.dart';
import 'create_quotation_screen.dart';

class QuotationListScreen extends StatelessWidget {
  const QuotationListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quotations'),
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.lazyBox<QuotationModel>(HiveBoxNames.quotations).listenable(),
        builder: (context, box, _) {
          if (box.isEmpty) {
            return const Center(child: Text('No quotations yet. Tap + to create one.'));
          }

          return ListView.builder(
            itemCount: box.length,
            itemBuilder: (context, index) {
              final key = box.keyAt(index);
              // Since it's a lazy box, we need to await get(), but Builder is sync.
              // Better use FutureBuilder or a regular Box if data is small.
              // For simplicity in this step, I'll just show keys or use a regular box
              // but the prompt asked for LazyBox.
              return FutureBuilder(
                future: box.get(key),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const ListTile(title: Text('Loading...'));
                  final q = snapshot.data as QuotationModel;
                  return ListTile(
                    title: Text(q.quotationNumber),
                    subtitle: Text(q.customerName),
                    trailing: Text(q.status.name.toUpperCase()),
                    onTap: () {
                      // Navigate to preview
                    },
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
