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

    // Load logo if exists
    pw.ImageProvider? logo;
    if (company?.logoPath != null && File(company!.logoPath!).existsSync()) {
      logo = pw.MemoryImage(File(company.logoPath!).readAsBytesSync());
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          _buildHeader(company, logo),
          pw.SizedBox(height: 20),
          _buildTitle(q),
          pw.SizedBox(height: 20),
          _buildInfoSection(q, company),
          pw.SizedBox(height: 20),
          _buildTable(q),
          pw.SizedBox(height: 20),
          _buildTotals(q, company),
          if (q.notes != null && q.notes!.isNotEmpty) ...[
            pw.SizedBox(height: 20),
            pw.Text('Notes:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.Text(q.notes!),
          ],
          pw.Spacer(),
          _buildSignatures(q, company),
        ],
      ),
    );

    return pdf;
  }

  static pw.Widget _buildHeader(CompanyModel? company, pw.ImageProvider? logo) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        if (logo != null)
          pw.Container(width: 80, height: 80, child: pw.Image(logo))
        else
          pw.SizedBox(width: 80),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text(company?.name ?? 'Company Name', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
            pw.Text(company?.address ?? 'Address'),
            pw.Text('Phone: ${company?.phone ?? ''}'),
            if (company?.email != null) pw.Text('Email: ${company!.email}'),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildTitle(QuotationModel q) {
    return pw.Container(
      decoration: const pw.BoxDecoration(color: PdfColors.blue900),
      padding: const pw.EdgeInsets.all(8),
      width: double.infinity,
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text('QUOTATION', style: pw.TextStyle(color: PdfColors.white, fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.Text(q.quotationNumber, style: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold)),
        ],
      ),
    );
  }

  static pw.Widget _buildInfoSection(QuotationModel q, CompanyModel? company) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Bill To:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.Text(q.customerName, style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
            // We'd need more customer info here if we saved it in the model
          ],
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text('Date: ${DateFormatter.format(q.createdAt)}'),
            pw.Text('Valid Until: ${DateFormatter.format(q.validUntil)}'),
            pw.Text('Project: ${q.projectName}'),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildTable(QuotationModel q) {
    if (!q.showItemPrices) {
      final headers = ['#', 'Description', 'Qty', 'Unit'];
      final data = List.generate(q.items.length, (index) {
        final item = q.items[index];
        return [
          '${index + 1}',
          item.description,
          '${item.quantity}',
          item.unit,
        ];
      });

      return pw.TableHelper.fromTextArray(
        headers: headers,
        data: data,
        headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
        headerDecoration: const pw.BoxDecoration(color: PdfColors.blue800),
        cellAlignment: pw.Alignment.centerLeft,
        columnWidths: {
          0: const pw.FixedColumnWidth(30),
          1: const pw.FlexColumnWidth(),
          2: const pw.FixedColumnWidth(40),
          3: const pw.FixedColumnWidth(40),
        },
      );
    }

    final headers = ['#', 'Description', 'Qty', 'Unit', 'Price', 'Total'];
    final data = List.generate(q.items.length, (index) {
      final item = q.items[index];
      return [
        '${index + 1}',
        item.description,
        '${item.quantity}',
        item.unit,
        CurrencyFormatter.format(item.unitPrice),
        CurrencyFormatter.format(item.total),
      ];
    });

    return pw.TableHelper.fromTextArray(
      headers: headers,
      data: data,
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.blue800),
      cellAlignment: pw.Alignment.centerRight,
      columnWidths: {
        0: const pw.FixedColumnWidth(30),
        1: const pw.FlexColumnWidth(),
        2: const pw.FixedColumnWidth(40),
        3: const pw.FixedColumnWidth(40),
        4: const pw.FixedColumnWidth(80),
        5: const pw.FixedColumnWidth(80),
      },
      cellAlignments: {
        1: pw.Alignment.centerLeft,
      },
    );
  }

  static pw.Widget _buildTotals(QuotationModel q, CompanyModel? company) {
    final currency = company?.currency ?? 'SR';
    if (!q.showItemPrices) {
      return pw.Container(
        alignment: pw.Alignment.centerLeft,
        padding: const pw.EdgeInsets.only(top: 20),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Price:', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
            pw.Text('Total amount ${CurrencyFormatter.format(q.grandTotal, symbol: currency)} (LUMSAM)', 
              style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
          ],
        ),
      );
    }

    return pw.Container(
      alignment: pw.Alignment.centerRight,
      child: pw.SizedBox(
        width: 200,
        child: pw.Column(
          children: [
            _totalRow('Subtotal', q.subtotal, currency),
            if (q.discountAmount > 0) _totalRow('Discount', -q.discountAmount, currency),
            if (q.taxPercent > 0) _totalRow('Tax (${q.taxPercent}%)', q.subtotal * q.taxPercent / 100, currency),
            pw.Divider(),
            _totalRow('Grand Total', q.grandTotal, currency, isBold: true),
          ],
        ),
      ),
    );
  }

  static pw.Widget _totalRow(String label, double value, String currency, {bool isBold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: isBold ? pw.TextStyle(fontWeight: pw.FontWeight.bold) : null),
          pw.Text(CurrencyFormatter.format(value, symbol: currency), style: isBold ? pw.TextStyle(fontWeight: pw.FontWeight.bold) : null),
        ],
      ),
    );
  }

  static pw.Widget _buildSignatures(QuotationModel q, CompanyModel? company) {
    pw.ImageProvider? customerSig;
    if (q.signaturePath != null && File(q.signaturePath!).existsSync()) {
      customerSig = pw.MemoryImage(File(q.signaturePath!).readAsBytesSync());
    }

    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          children: [
            pw.Container(
              width: 120,
              height: 40,
              decoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide())),
              child: customerSig != null ? pw.Image(customerSig) : null,
            ),
            pw.SizedBox(height: 4),
            pw.Text('Customer Signature'),
          ],
        ),
        pw.Column(
          children: [
            pw.Container(width: 120, height: 40, decoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide()))),
            pw.SizedBox(height: 4),
            pw.Text('Authorized Signature'),
          ],
        ),
      ],
    );
  }
}
