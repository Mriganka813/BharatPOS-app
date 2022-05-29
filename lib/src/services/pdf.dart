import 'package:flutter_html_to_pdf/flutter_html_to_pdf.dart';
import 'package:magicstep/src/models/expense.dart';
import 'package:magicstep/src/models/order.dart';
import 'package:magicstep/src/models/user.dart';
import 'package:magicstep/src/pdf_templates/expense_template.dart';
import 'package:magicstep/src/pdf_templates/orders_template.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

class PdfService {
  const PdfService();

  void generateExpensesPdfPreview(List<Expense> expenses) async {
    final content = reportsExpenseTemplate(expenses: expenses);
    _viewPDf(content, 'expenses');
  }

  void generateOrdersPdfPreview(List<Order> orders) async {
    final content = reportsOrderTemplate(orders: orders);
    _viewPDf(content, 'orders');
  }

  void downloadOrdersPdfPreview(List<Order> orders) async {
    final content = reportsOrderTemplate(orders: orders);
    _downloadPdf(content, 'orders');
  }

  void downloadExpensePdfPreview(List<Expense> expenses) async {
    final content = reportsExpenseTemplate(expenses: expenses);
    _downloadPdf(content, 'expenses');
  }

  void _downloadPdf(String content, String fileName) async {
    _viewPDf(content, fileName);
  }

  void _viewPDf(String content, String fileName) async {
    final targetPath = await getExternalCacheDirectories();
    final path = targetPath!.first.path;
    final pdf =
        await FlutterHtmlToPdf.convertFromHtmlContent(content, path, fileName);
    await OpenFile.open(pdf.path);
  }

  ///
  void pdfFromOrder(User user, List<Expense> expenses) async {
    final targetPath = await getExternalCacheDirectories();
    const targetFileName = "example_pdf_file";
    final htmlContent = reportsExpenseTemplate(expenses: expenses);
    final generatedPdfFile = await FlutterHtmlToPdf.convertFromHtmlContent(
      htmlContent,
      targetPath!.first.path,
      targetFileName,
    );
    await OpenFile.open(generatedPdfFile.path);
  }
}
