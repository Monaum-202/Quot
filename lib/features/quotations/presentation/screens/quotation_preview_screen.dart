import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:uuid/uuid.dart';
import 'package:invoice_maker/features/company_profile/providers/company_provider.dart';
import 'package:invoice_maker/features/quotations/data/models/quotation_model.dart';
import 'package:invoice_maker/features/quotations/data/models/quotation_status.dart';
import 'package:invoice_maker/core/utils/pdf_generator.dart';
import 'package:invoice_maker/core/utils/invoice_number_gen.dart';
import 'package:invoice_maker/features/quotations/providers/quotation_provider.dart';
import 'package:invoice_maker/features/invoices/data/models/invoice_model.dart';
import 'package:invoice_maker/features/invoices/providers/invoice_provider.dart';
import 'signature_screen.dart';
import 'create_quotation_screen.dart';

class QuotationPreviewScreen extends ConsumerWidget {
  final QuotationModel quotation;

  const QuotationPreviewScreen({super.key, required this.quotation});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final company = ref.watch(companyProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(quotation.quotationNumber),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit Quotation',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CreateQuotationScreen(quotation: quotation)),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.history_edu),
            tooltip: 'Get Signature',
            onPressed: () async {
              final sigPath = await Navigator.push<String>(
                context,
                MaterialPageRoute(builder: (context) => SignatureScreen(quotationId: quotation.id)),
              );
              if (sigPath != null) {
                quotation.signaturePath = sigPath;
                await ref.read(quotationsProvider.notifier).saveQuotation(quotation);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () async {
              final pdf = await PdfGenerator.generate(quotation, company);
              final dir = await getApplicationDocumentsDirectory();
              final file = File('${dir.path}/${quotation.quotationNumber}.pdf');
              await file.writeAsBytes(await pdf.save());

              await Share.shareXFiles(
                [XFile(file.path)],
                text: 'Quotation ${quotation.quotationNumber} from ${company?.name ?? "Us"}',
              );
            },
          ),
        ],
      ),
      body: PdfPreview(
        build: (format) async {
          final pdf = await PdfGenerator.generate(quotation, company);
          return pdf.save();
        },
        canChangePageFormat: false,
        canChangeOrientation: false,
        onPrinted: (context) {
          // Could update status to sent
        },
      ),
      floatingActionButton: quotation.isConvertedToInvoice
        ? null
        : FloatingActionButton.extended(
            onPressed: () async {
              final invoice = InvoiceModel(
                id: const Uuid().v4(),
                invoiceNumber: InvoiceNumberGen.generate(),
                quotationId: quotation.id,
                customerId: quotation.customerId,
                customerName: quotation.customerName,
                projectName: quotation.projectName,
                items: List.from(quotation.items),
                discountAmount: quotation.discountAmount,
                taxPercent: quotation.taxPercent,
                paidAmount: 0,
                issuedAt: DateTime.now(),
                dueDate: DateTime.now().add(const Duration(days: 7)),
                notes: quotation.notes,
              );

              await ref.read(invoicesProvider.notifier).saveInvoice(invoice);

              quotation.isConvertedToInvoice = true;
              quotation.status = QuotationStatus.convertedToInvoice;
              await ref.read(quotationsProvider.notifier).saveQuotation(quotation);

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Converted to Invoice: ${invoice.invoiceNumber}')),
                );
              }
            },
            label: const Text('CONVERT TO INVOICE'),
            icon: const Icon(Icons.receipt_long),
            heroTag: null,
          ),
    );
  }
}
