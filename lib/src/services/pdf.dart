import 'dart:io';

import 'package:flutter_html_to_pdf/flutter_html_to_pdf.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shopos/src/models/expense.dart';
import 'package:shopos/src/models/input/order.dart';

import 'package:shopos/src/pdf_templates/expense_template.dart';
import 'package:shopos/src/pdf_templates/orders_template.dart';

class PdfService {
  const PdfService();

  Future<File> generateExpensesPdfFile(List<Expense> expenses) async {
    final content = reportsExpenseTemplate(expenses: expenses);
    return await _genPdfFile(content, 'expenses');
  }

  Future<File> generateOrdersPdfFile(List<Order> orders) async {
    final content = reportsOrderTemplate(orders: orders);
    return await _genPdfFile(content, 'orders');
  }

  Future<File> _genPdfFile(String content, String fileName) async {
    final targetPath = await getTemporaryDirectory();
    final path = targetPath.path;
    final pdf =
        await FlutterHtmlToPdf.convertFromHtmlContent(content, path, fileName);
    return pdf;
  }
}
