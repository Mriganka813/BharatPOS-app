import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:share_plus/share_plus.dart';

class PdfPreviewPageArgs {
  final File file;
  final String title;
  const PdfPreviewPageArgs({
    required this.file,
    required this.title,
  });
}

class PdfPreviewPage extends StatefulWidget {
  final PdfPreviewPageArgs args;
  const PdfPreviewPage({
    Key? key,
    required this.args,
  }) : super(key: key);
  static const String routeName = '/pdf-preview';
  @override
  State<PdfPreviewPage> createState() => _PdfPreviewPageState();
}

class _PdfPreviewPageState extends State<PdfPreviewPage> {
  //
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(widget.args.title),
        actions: [
          IconButton(
            onPressed: () async {
              await Share.shareFiles(
                [widget.args.file.path],
                mimeTypes: ['application/pdf'],
              );
            },
            icon: Icon(Icons.share),
          ),
        ],
      ),
      body: Center(
        child: PDFView(
          filePath: widget.args.file.path,
          enableSwipe: true,
          swipeHorizontal: false,
          autoSpacing: true,
          pageFling: true,
          onRender: (_pages) {},
          onError: (error) {},
          onPageError: (page, error) {},
          onViewCreated: (PDFViewController pdfViewController) {
            // _controller.complete(pdfViewController);
          },
          onPageChanged: (int? page, int? total) {},
        ),
      ),
    );
  }
}
