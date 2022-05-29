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
    final content = await reportsExpenseTemplate(expenses: expenses);
    _viewPDf(content, 'expenses');
  }

  void generateOrdersPdfPreview(List<Order> orders) async {
    final content = await reportsOrderTemplate(orders: orders);
    _viewPDf(content, 'orders');
  }

  _viewPDf(String content, String fileName) async {
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
    final htmlContent = await reportsExpenseTemplate(expenses: expenses);
    final generatedPdfFile = await FlutterHtmlToPdf.convertFromHtmlContent(
      htmlContent,
      targetPath!.first.path,
      targetFileName,
    );
    OpenFile.open(generatedPdfFile.path);
    // final party = widget.args.orderInput.party;
    // if (party == null) {
    //   final path = generatedPdfFile.path;
    //   await Share.shareFiles([path], mimeTypes: ['application/pdf']);
    //   return;
    // }
    // await WhatsappShare.shareFile(
    //   text: 'Invoice',
    //   phone: '91${party.phoneNumber ?? ""}',
    //   filePath: [generatedPdfFile.path],
    // );
  }
}
