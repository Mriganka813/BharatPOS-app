import 'dart:io';

import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:open_file_plus/open_file_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/widgets.dart';

import 'package:shopos/src/models/user.dart';

import '../models/input/order.dart';

class PdfUI {
  static Future<void> generate80mmPdf({
    required User user,
    required Order order,
    required List<String> headers,
    required DateTime date,
    required String invoiceNum,
    required String totalPrice,
    required String subtotal,
    required String gstTotal,
  }) async {
    print("date=$date");
    final pdf = pw.Document();
    final roll80 = PdfPageFormat.roll80;

    final font = await rootBundle.load('assets/OpenSans-Regular.ttf');
    final ttf = await Font.ttf(font);

    String dateFormat() => DateFormat('dd/MM/yy').format(date);

    List<String>? addressRows() => user.address
        ?.toString()
        .split(',')
        .map((e) =>
            '${e.replaceAll('{', '').replaceAll('}', '').replaceAll('[', '').replaceAll(']', '').replaceAll(',', '').replaceAll('locality:', '').replaceAll('city:', '').replaceAll('state:', '').replaceAll('country:', '')}')
        .toList();

    ///

    ///
    List<pw.TableRow> itemRows() => List.generate(
          (order.orderItems ?? []).length,
          (index) {
            final orderItem = order.orderItems![index];

            return pw.TableRow(children: [
              pw.Text('${orderItem.quantity}',
                  style: TextStyle(font: ttf, fontSize: 10)),
              pw.Container(
                constraints: BoxConstraints(maxWidth: 80),
                child: pw.Text(
                  '${orderItem.product!.name}',
                  style: TextStyle(font: ttf, fontSize: 10),
                ),
              ),
              pw.SizedBox(width: 30),
              pw.Text('${orderItem.product!.sellingPrice}',
                  style: TextStyle(font: ttf, fontSize: 10))
            ]);
          },
        );
    pdf.addPage(
      pw.Page(
        pageFormat: roll80,
        build: (context) {
          return pw.Center(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                // Title
                pw.Text(
                  '${user.businessName}',
                  style: pw.TextStyle(
                      font: ttf, fontSize: 16, fontWeight: pw.FontWeight.bold),
                ),

                if (user.GstIN != null && user.GstIN!.isNotEmpty)
                  pw.Text(
                    'GSTIN ${user.GstIN}'.toUpperCase(),
                    style: pw.TextStyle(font: ttf, fontSize: 9),
                  ),

                // Address lines
                for (var i = 0; i < 4; i++)
                  pw.Text(
                    '${addressRows()!.elementAt(i)}',
                    style: pw.TextStyle(fontSize: 10, font: ttf),
                  ),

                // Phone number
                pw.Text(
                  '${user.phoneNumber}',
                  style: pw.TextStyle(fontSize: 10, font: ttf),
                ),

                pw.SizedBox(height: 10),

                // bill to:
                if ((order.reciverName != null &&
                        order.reciverName!.isNotEmpty) ||
                    (order.businessName != null &&
                        order.businessName!.isNotEmpty) ||
                    (order.businessAddress != null &&
                        order.businessAddress!.isNotEmpty) ||
                    (order.gst != null && order.gst!.isNotEmpty))
                  pw.Row(children: [
                    pw.Text(
                      'Billed to: ',
                      style: pw.TextStyle(
                          fontSize: 9,
                          font: ttf,
                          fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Text(''),
                  ]),

                if (order.reciverName != null && order.reciverName!.isNotEmpty)
                  Row(children: [
                    Text(
                      'Receiver name: ',
                      style: pw.TextStyle(fontSize: 9, font: ttf),
                    ),
                    Text(
                      '${order.reciverName}',
                      style: pw.TextStyle(fontSize: 9, font: ttf),
                    )
                  ]),

                if (order.businessName != null &&
                    order.businessName!.isNotEmpty)
                  Row(children: [
                    Text(
                      'Business name: ',
                      style: pw.TextStyle(fontSize: 9, font: ttf),
                    ),
                    Text(
                      '${order.businessName}',
                      style: pw.TextStyle(fontSize: 9, font: ttf),
                    )
                  ]),

                if (order.businessAddress != null &&
                    order.businessAddress!.isNotEmpty)
                  Row(children: [
                    Text(
                      'Address: ',
                      style: pw.TextStyle(fontSize: 9, font: ttf),
                    ),
                    Text(
                      '${order.businessAddress}',
                      style: pw.TextStyle(fontSize: 9, font: ttf),
                    )
                  ]),

                if (order.gst != null && order.gst!.isNotEmpty)
                  Row(children: [
                    Text(
                      'GSTIN: ',
                      style: pw.TextStyle(fontSize: 9, font: ttf),
                    ),
                    Text(
                      '${order.gst}'.toUpperCase(),
                      style: pw.TextStyle(fontSize: 9, font: ttf),
                    )
                  ]),

                pw.SizedBox(height: 10),

                // Invoice details table

                pw.Table(
                  children: [
                    pw.TableRow(children: [
                      pw.Text('Invoice ',
                          style: TextStyle(font: ttf, fontSize: 10)),
                      pw.Text('$invoiceNum',
                          style: TextStyle(font: ttf, fontSize: 10)),
                      pw.SizedBox(width: 40),
                      pw.Text('${dateFormat()}',
                          style: TextStyle(font: ttf, fontSize: 10))
                    ]),

                    pw.TableRow(children: [
                      pw.Text(''),
                      pw.Text(''),
                      pw.SizedBox(width: 40),
                      pw.Text(
                          '${invoiceNum.substring(8, 10)}:${invoiceNum.substring(10, 12)}',
                          style: TextStyle(font: ttf, fontSize: 10))
                    ])

                    // ...itemRows(),
                  ],
                ),

                pw.Table(children: itemRows()),

                pw.Divider(),

                // Subtotal, GST, and Grand Total
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(''),
                    pw.Text('Subtotal',
                        textAlign: TextAlign.left,
                        style: pw.TextStyle(fontSize: 11, font: ttf)),
                    pw.Text('$subtotal',
                        style: pw.TextStyle(fontSize: 11, font: ttf)),
                  ],
                ),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(''),
                    pw.Text('GST',
                        textAlign: TextAlign.left,
                        textDirection: pw.TextDirection.ltr,
                        style: pw.TextStyle(fontSize: 11, font: ttf)),
                    pw.Text('$gstTotal',
                        style: pw.TextStyle(fontSize: 11, font: ttf)),
                  ],
                ),
                pw.Divider(color: PdfColor.fromHex('#808080')),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(''),
                    pw.Text('Grand Total',
                        textAlign: TextAlign.left,
                        style: pw.TextStyle(
                            fontSize: 12,
                            fontWeight: pw.FontWeight.bold,
                            font: ttf)),
                    pw.Text('$totalPrice',
                        style: pw.TextStyle(
                            fontSize: 12,
                            fontWeight: pw.FontWeight.bold,
                            font: ttf)),
                  ],
                ),

                pw.SizedBox(height: 30),

                pw.Divider(),
                pw.SizedBox(height: 30),

                // Thank You message
                pw.Text('Thank You and see you again.',
                    style: pw.TextStyle(fontSize: 12, font: ttf)),
              ],
            ),
          );
        },
      ),
    );

    // Get the directory for saving the PDF
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/Invoice.pdf';
    final file = File(filePath);

    // Write the PDF to a file
    await file.writeAsBytes(await pdf.save());

    // await Printing.layoutPdf(
    //     onLayout: (PdfPageFormat format) async => pdf.save());

    try {
      print('run');
      print(file.path);
      print(file.absolute.path);
      OpenFile.open(file.path);
      print('done');
    } catch (e) {
      print(e);
    }
  }

  static Future<void> generate57mmPdf({
    required User user,
    required Order order,
    required List<String> headers,
    required DateTime date,
    required String invoiceNum,
    required String totalPrice,
    required String subtotal,
    required String gstTotal,
  }) async {
    print("date=$date");
    final pdf = pw.Document();
    final roll57 = PdfPageFormat.roll57;

    final font = await rootBundle.load('assets/OpenSans-Regular.ttf');
    final ttf = await Font.ttf(font);

    String dateFormat() => DateFormat('dd/MM/yy').format(date);

    List<String>? addressRows() => user.address
        ?.toString()
        .split(',')
        .map((e) =>
            '${e.replaceAll('{', '').replaceAll('}', '').replaceAll('[', '').replaceAll(']', '').replaceAll(',', '').replaceAll('locality:', '').replaceAll('city:', '').replaceAll('state:', '').replaceAll('country:', '')}')
        .toList();

    ///
    String headerRows() => List.generate(
          headers.length,
          (int index) => '${headers[index]}',
        ).join(' ');

    ///
    List<pw.TableRow> itemRows() => List.generate(
          (order.orderItems ?? []).length,
          (index) {
            final orderItem = order.orderItems![index];

            return pw.TableRow(children: [
              pw.Text('${orderItem.quantity}',
                  style: TextStyle(font: ttf, fontSize: 7)),
              pw.SizedBox(width: 2),
              pw.Container(
                constraints: BoxConstraints(maxWidth: 80),
                child: pw.Text(
                  '${orderItem.product!.name}',
                  style: TextStyle(font: ttf, fontSize: 7),
                ),
              ),
              pw.SizedBox(width: 30),
              pw.Text('${orderItem.product!.sellingPrice}',
                  style: TextStyle(font: ttf, fontSize: 7))
            ]);
          },
        );
    pdf.addPage(
      pw.Page(
        pageFormat: roll57,
        build: (context) {
          return pw.Center(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                // Title
                pw.Text(
                  '${user.businessName}',
                  style: pw.TextStyle(
                      font: ttf, fontSize: 13, fontWeight: pw.FontWeight.bold),
                ),

                if (user.GstIN != null && user.GstIN!.isNotEmpty)
                  pw.Text(
                    'GSTIN ${user.GstIN}'.toUpperCase(),
                    style: pw.TextStyle(font: ttf, fontSize: 7),
                  ),

                // Address lines
                for (var i = 0; i < 4; i++)
                  pw.Text(
                    '${addressRows()!.elementAt(i)}',
                    style: pw.TextStyle(fontSize: 8, font: ttf),
                  ),

                // Phone number
                pw.Text(
                  '${user.phoneNumber}',
                  style: pw.TextStyle(fontSize: 8, font: ttf),
                ),

                pw.SizedBox(height: 10),

                // bill to:

                if ((order.reciverName != null &&
                        order.reciverName!.isNotEmpty) ||
                    (order.businessName != null &&
                        order.businessName!.isNotEmpty) ||
                    (order.businessAddress != null &&
                        order.businessAddress!.isNotEmpty) ||
                    (order.gst != null && order.gst!.isNotEmpty))
                  pw.Row(children: [
                    pw.Text(
                      'Billed to: ',
                      style: pw.TextStyle(
                          fontSize: 8,
                          font: ttf,
                          fontWeight: pw.FontWeight.bold),
                    ),
                  ]),

                if (order.reciverName != null && order.reciverName!.isNotEmpty)
                  Row(children: [
                    Text(
                      'Receiver name: ',
                      style: pw.TextStyle(fontSize: 7, font: ttf),
                    ),
                    Text(
                      '${order.reciverName}',
                      style: pw.TextStyle(fontSize: 7.5, font: ttf),
                    )
                  ]),

                if (order.businessName != null &&
                    order.businessName!.isNotEmpty)
                  Row(children: [
                    Text(
                      'Business name: ',
                      style: pw.TextStyle(fontSize: 7, font: ttf),
                    ),
                    Text(
                      '${order.businessName}',
                      style: pw.TextStyle(fontSize: 7, font: ttf),
                    )
                  ]),

                if (order.businessAddress != null &&
                    order.businessAddress!.isNotEmpty)
                  Row(children: [
                    Text(
                      'Address: ',
                      style: pw.TextStyle(fontSize: 7, font: ttf),
                    ),
                    Text(
                      '${order.businessAddress}',
                      style: pw.TextStyle(fontSize: 7, font: ttf),
                    )
                  ]),

                if (order.gst != null && order.gst!.isNotEmpty)
                  Row(children: [
                    Text(
                      'GSTIN: ',
                      style: pw.TextStyle(fontSize: 7, font: ttf),
                    ),
                    Text(
                      '${order.gst}'.toUpperCase(),
                      style: pw.TextStyle(fontSize: 7, font: ttf),
                    )
                  ]),

                pw.SizedBox(height: 10),

                // Invoice details table

                pw.Table(
                  children: [
                    pw.TableRow(children: [
                      pw.Text('Invoice ',
                          style: TextStyle(font: ttf, fontSize: 6)),
                      pw.Text('$invoiceNum',
                          style: TextStyle(font: ttf, fontSize: 6)),
                      pw.SizedBox(width: 40),
                      pw.Text('${dateFormat()}',
                          style: TextStyle(font: ttf, fontSize: 6))
                    ]),
                    pw.TableRow(children: [
                      pw.Text(''),
                      pw.Text(''),
                      pw.SizedBox(width: 40),
                      pw.Text(
                          '${invoiceNum.substring(8, 10)}:${invoiceNum.substring(10, 12)}',
                          style: TextStyle(font: ttf, fontSize: 6))
                    ])
                  ],
                ),
                pw.SizedBox(height: 10),

                pw.Table(children: itemRows()),

                pw.Divider(),

                // Subtotal, GST, and Grand Total
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(''),
                    pw.Text('Subtotal',
                        style: pw.TextStyle(fontSize: 7, font: ttf)),
                    pw.Text('$subtotal',
                        style: pw.TextStyle(fontSize: 7, font: ttf)),
                  ],
                ),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(''),
                    pw.Text('GST', style: pw.TextStyle(fontSize: 7, font: ttf)),
                    pw.Text('$gstTotal',
                        style: pw.TextStyle(fontSize: 7, font: ttf)),
                  ],
                ),
                pw.Divider(color: PdfColor.fromHex('#808080')),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(''),
                    pw.Text('Grand Total',
                        style: pw.TextStyle(
                            fontSize: 9,
                            fontWeight: pw.FontWeight.bold,
                            font: ttf)),
                    pw.Text('$totalPrice',
                        style: pw.TextStyle(
                            fontSize: 9,
                            fontWeight: pw.FontWeight.bold,
                            font: ttf)),
                  ],
                ),

                pw.SizedBox(height: 10),

                pw.Divider(),
                pw.SizedBox(height: 10),

                // Thank You message
                pw.Center(
                  child: pw.Text('Thank You and see you again.',
                      style: pw.TextStyle(fontSize: 8, font: ttf)),
                )
              ],
            ),
          );
        },
      ),
    );

    // Get the directory for saving the PDF
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/Invoice.pdf';
    final file = File(filePath);

    // Write the PDF to a file
    await file.writeAsBytes(await pdf.save());

    // await Printing.layoutPdf(
    //     onLayout: (PdfPageFormat format) async => pdf.save());

    try {
      print('run');
      print(file.path);
      print(file.absolute.path);
      OpenFile.open(file.path);
      print('done');
    } catch (e) {
      print(e);
    }
  }
}
