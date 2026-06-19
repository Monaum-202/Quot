import 'dart:io';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../features/company_profile/data/models/company_model.dart';
import '../../features/quotations/data/models/quotation_model.dart';
import 'currency_formatter.dart';
import 'date_formatter.dart';

class PdfGenerator {
  static Future<pw.Document> generate(QuotationModel q, CompanyModel? company) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (context) => [
          _buildLetterhead(company),
          pw.Divider(thickness: 1),
          pw.SizedBox(height: 20),
          _buildCenterTitle(),
          pw.SizedBox(height: 20),
          _buildHeaderInfo(q),
          pw.SizedBox(height: 20),
          _buildIntroText(q, company),
          pw.SizedBox(height: 10),
          _buildItemsList(q),
          pw.SizedBox(height: 20),
          _buildValidityText(q),
          pw.SizedBox(height: 30),
          _buildPriceSection(q, company),
          pw.SizedBox(height: 30),
          if (q.conditions.isNotEmpty) _buildConditionsSection(q),
          if (q.notes != null && q.notes!.isNotEmpty) ...[
            pw.SizedBox(height: 20),
            pw.Text(q.notes!, style: pw.TextStyle(fontSize: 11)),
          ],
          pw.Spacer(),
          _buildFooter(company),
        ],
      ),
    );

    return pdf;
  }

  static pw.Widget _buildLetterhead(CompanyModel? company) {
    return pw.Center(
      child: pw.Column(
        children: [
          pw.Text(
            (company?.name ?? 'COMPANY NAME').toUpperCase(),
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#2c3e50')),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            company?.ownerName ?? '',
            style: pw.TextStyle(fontSize: 10, color: PdfColor.fromHex('#7f8c8d')),
          ),
          pw.Text(
            company?.address ?? 'Address',
            style: pw.TextStyle(fontSize: 10, color: PdfColor.fromHex('#7f8c8d')),
          ),
          if (company?.taxNumber != null)
            pw.Text(
              'VAT NO: ${company!.taxNumber}',
              style: pw.TextStyle(fontSize: 10, color: PdfColor.fromHex('#7f8c8d')),
            ),
        ],
      ),
    );
  }

  static pw.Widget _buildCenterTitle() {
    return pw.Center(
      child: pw.Text(
        'Quotation',
        style: pw.TextStyle(
          fontSize: 14,
          fontWeight: pw.FontWeight.bold,
          decoration: pw.TextDecoration.underline,
        ),
      ),
    );
  }

  static pw.Widget _buildHeaderInfo(QuotationModel q) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Date. ${DateFormatter.format(q.createdAt)}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)),
        pw.SizedBox(height: 8),
        pw.Text('Company... ${q.customerName}', style: pw.TextStyle(fontSize: 11)),
        pw.SizedBox(height: 8),
        pw.RichText(
          text: pw.TextSpan(
            children: [
              pw.TextSpan(text: 'SUBJECT: ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)),
              pw.TextSpan(
                text: 'QUOTATION FOR ${q.projectName.toUpperCase()}.',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11, decoration: pw.TextDecoration.underline),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildIntroText(QuotationModel q, CompanyModel? company) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Dear Sir,', style: pw.TextStyle(fontSize: 11)),
        pw.SizedBox(height: 8),
        pw.Text(
          'We thank you for your giving an opportunity to provide us our quotation for the below mentioned work:',
          style: pw.TextStyle(fontSize: 11),
        ),
        pw.SizedBox(height: 8),
        pw.Text(
          '${company?.name ?? "Our company"} shall be responsible for the following.',
          style: pw.TextStyle(fontSize: 11, fontStyle: pw.FontStyle.italic),
        ),
      ],
    );
  }

  static pw.Widget _buildItemsList(QuotationModel q) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: List.generate(q.items.length, (index) {
        final item = q.items[index];
        return pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 6),
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.SizedBox(width: 20, child: pw.Text('${index + 1}... ', style: pw.TextStyle(fontSize: 11))),
              pw.Expanded(
                child: pw.Text(
                  '${item.description} (${item.quantity} ${item.unit})',
                  style: pw.TextStyle(fontSize: 11),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  static pw.Widget _buildValidityText(QuotationModel q) {
    final difference = q.validUntil.difference(q.createdAt).inDays;
    return pw.Text(
      'This offer is valid $difference days from the date of quotation.',
      style: pw.TextStyle(fontSize: 11),
    );
  }

  static pw.Widget _buildPriceSection(QuotationModel q, CompanyModel? company) {
    final currency = company?.currency ?? 'SR';
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Price.', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontStyle: pw.FontStyle.italic, fontSize: 11)),
        pw.SizedBox(height: 8),
        pw.Text(
          '${q.grandTotal.toStringAsFixed(0)} $currency',
          style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
        ),
      ],
    );
  }

  static pw.Widget _buildConditionsSection(QuotationModel q) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Term and Condition (Payment to be paid as follows).',
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11),
        ),
        pw.SizedBox(height: 8),
        ...q.conditions.map((condition) => pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 4),
              child: pw.Text(condition, style: pw.TextStyle(fontSize: 11)),
            )),
      ],
    );
  }

  static pw.Widget _buildFooter(CompanyModel? company) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(company?.phone ?? '', style: pw.TextStyle(fontSize: 11)),
        pw.SizedBox(height: 4),
        pw.Text(company?.ownerName ?? '', style: pw.TextStyle(fontSize: 11)),
      ],
    );
  }
}
