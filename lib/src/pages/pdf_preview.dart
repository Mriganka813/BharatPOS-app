import 'package:flutter/material.dart';
import 'package:uc_pdfview/uc_pdfview.dart';

class PdfPreviewPage extends StatefulWidget {
  static const routeName = '/pdf_preview';
  final String pdfPath;
  const PdfPreviewPage({
    Key? key,
    required this.pdfPath,
  }) : super(key: key);

  @override
  State<PdfPreviewPage> createState() => _PdfPreviewPageState();
}

class _PdfPreviewPageState extends State<PdfPreviewPage> {
  @override
  Widget build(BuildContext context) {
    return UCPDFView(
      filePath: widget.pdfPath,
      enableSwipe: true,
      swipeHorizontal: true,
      autoSpacing: false,
      pageFling: false,
      onRender: (_pages) {
        // setState(() {
        //   pages = _pages;
        //   isReady = true;
        // });
      },
      onError: (error) {
        print(error.toString());
        if (error
            .toString()
            .contains("Password required or incorrect password.")) {
          // Show your Password Dialog supported both Android and IOS
        }
      },
      onPageError: (page, error) {
        print('$page: ${error.toString()}');
      },
      onViewCreated: (PDFViewController pdfViewController) {},
      onPageChanged: (int? page, int? total) {},
    );
  }
}
