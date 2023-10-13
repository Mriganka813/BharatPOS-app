import 'dart:io';
import 'dart:typed_data';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shopos/src/models/expense.dart';

import 'package:shopos/src/models/order.dart';
import 'package:shopos/src/models/order_item.dart';

import 'package:pdf/widgets.dart' as pw;
import 'package:shopos/src/models/product.dart';
import 'package:shopos/src/services/global.dart';
import 'package:shopos/src/services/locator.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xcel;

class tableArg {
  final List<Order>? orders;
  final List<Expense>? expenses;
  final List<Product>? products;
  final String type;

  tableArg({this.orders, required this.type, this.expenses, this.products});
}

class ReportTable extends StatefulWidget {
  static const String routeName = '/table_page';
  final tableArg args;
  ReportTable({
    Key? key,
    required this.args,
  }) : super(key: key);

  @override
  State<ReportTable> createState() => _ReportTableState();
}

class _ReportTableState extends State<ReportTable> {
  List<String> datelist = [];
  List<String> timelist = [];
  List<String> partynamelist = [];
  List<String> productnamelist = [];
  List<String> basesplist = [];
  List<String> gstratelist = [];
  List<String> cgstlist = [];
  List<String> sgstlist = [];
  List<String> igstlist = [];
  List<String> totalsplist = [];
  List<String> moplist = [];
  List<String> totallist = [];
  List<String> mrplist = [];
  String taxfileType = "initailized";

  ScreenshotController screenshotController = ScreenshotController();
  late Uint8List _imageFile;

  @override
  void initState() {
    super.initState();
    if (widget.args.type == "ReportType.sale" ||
        widget.args.type == "ReportType.purchase") {
      itemSPRows();
      datelist.add("");
      timelist.add("");
      partynamelist.add("");
      productnamelist.add("");
      basesplist.add("");
      gstratelist.add("");
      cgstlist.add("");
      sgstlist.add("");
      mrplist.add("Total");
      igstlist.add("");
      totalsplist.add(total());
      moplist.add("");
    }
  }

  headerRows() {
    final headersSP = [
      'Date',
      'Time',
      'Party',
      'M.O.P.',
      'Product',
      'Amount/Unit',
      'GST Rate/Unit',
      'CGST/Unit',
      'SGST/Unit',
      'GST/Unit',
      'MRP/Unit',
      'Total',
    ];

    final headersQuaterly = [
      'Date',
      'Time',
      'Party',
      'M.O.P.',
      'Product',
      'MRP/Unit',
      'Total',
    ];
    final headersExpense = [
      'Date',
      'Time',
      'Header',
      'Description',
      'M.O.P',
      'Amount'
    ];
    final headersStock = [
      'Item Name',
      'Stock Quantity',
      'Stock Value',
    ];

    if (widget.args.type == "ReportType.sale") {
      if (taxfileType == "quarterly") {
        return List.generate(
          headersQuaterly.length,
          (int index) => DataColumn(
            label: Container(
              child: Text(headersQuaterly[index],
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
            ),
          ),
        );
      } else {
        return List.generate(
          headersSP.length,
          (int index) => DataColumn(
            label: Container(
              child: Text(headersSP[index],
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
            ),
          ),
        );
      }
    } else if (widget.args.type == "ReportType.purchase") {
      return List.generate(
        headersSP.length,
        (int index) => DataColumn(
          label: Container(
            child: Text(headersSP[index],
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
          ),
        ),
      );
    } else if (widget.args.type == "ReportType.expense") {
      return List.generate(
        headersExpense.length,
        (int index) => DataColumn(
          label: Container(
            child: Text(headersExpense[index],
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
          ),
        ),
      );
    } else if (widget.args.type == "ReportType.stock") {
      return List.generate(
        headersStock.length,
        (int index) => DataColumn(
          label: Container(
            child: Text(headersStock[index],
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
          ),
        ),
      );
    }
  }

  showSaleRow() {
    if (taxfileType == "quarterly") {
      return List.generate(
          datelist.length,
          (int index) => DataRow(cells: [
                DataCell(Text(datelist[index], style: TextStyle(fontSize: 6))),
                DataCell(Text(timelist[index], style: TextStyle(fontSize: 6))),
                DataCell(
                    Text(partynamelist[index], style: TextStyle(fontSize: 6))),
                DataCell(Text(moplist[index], style: TextStyle(fontSize: 6))),
                DataCell(Text(productnamelist[index],
                    style: TextStyle(fontSize: 6))),
                DataCell(Text(mrplist[index], style: TextStyle(fontSize: 6))),
                DataCell(
                    Text(totalsplist[index], style: TextStyle(fontSize: 6))),
              ]));
    } else {
      return List.generate(
          datelist.length,
          (int index) => DataRow(cells: [
                DataCell(Text(datelist[index], style: TextStyle(fontSize: 6))),
                DataCell(Text(timelist[index], style: TextStyle(fontSize: 6))),
                DataCell(
                    Text(partynamelist[index], style: TextStyle(fontSize: 6))),
                DataCell(Text(moplist[index], style: TextStyle(fontSize: 6))),
                DataCell(Text(productnamelist[index],
                    style: TextStyle(fontSize: 6))),
                DataCell(
                    Text(basesplist[index], style: TextStyle(fontSize: 6))),
                DataCell(
                    Text(gstratelist[index], style: TextStyle(fontSize: 6))),
                DataCell(Text(cgstlist[index], style: TextStyle(fontSize: 6))),
                DataCell(Text(sgstlist[index], style: TextStyle(fontSize: 6))),
                DataCell(Text(igstlist[index], style: TextStyle(fontSize: 6))),
                DataCell(Text(mrplist[index], style: TextStyle(fontSize: 6))),
                DataCell(
                    Text(totalsplist[index], style: TextStyle(fontSize: 6))),
              ]));
    }
  }

  showPurchaseRow() {
    return List.generate(
        datelist.length,
        (int index) => DataRow(cells: [
              DataCell(Text(datelist[index], style: TextStyle(fontSize: 6))),
              DataCell(Text(timelist[index], style: TextStyle(fontSize: 6))),
              DataCell(
                  Text(partynamelist[index], style: TextStyle(fontSize: 6))),
              DataCell(Text(moplist[index], style: TextStyle(fontSize: 6))),
              DataCell(
                  Text(productnamelist[index], style: TextStyle(fontSize: 6))),
              DataCell(Text(basesplist[index], style: TextStyle(fontSize: 6))),
              DataCell(Text(gstratelist[index], style: TextStyle(fontSize: 6))),
              DataCell(Text(cgstlist[index], style: TextStyle(fontSize: 6))),
              DataCell(Text(sgstlist[index], style: TextStyle(fontSize: 6))),
              DataCell(Text(igstlist[index], style: TextStyle(fontSize: 6))),
              DataCell(Text(mrplist[index], style: TextStyle(fontSize: 6))),
              DataCell(Text(totalsplist[index], style: TextStyle(fontSize: 6))),
            ]));
  }

  showExpenseRow() {
    return List.generate(
      widget.args.expenses!.length,
      (index) {
        final expense = widget.args.expenses?[index];
        final date = DateFormat('dd MMM, yyyy').format(expense!.createdAt!);
        final time = DateFormat('hh:mm a').format(expense.createdAt!);
        return DataRow(cells: [
          DataCell(Text("$date", style: TextStyle(fontSize: 6))),
          DataCell(Text("$time", style: TextStyle(fontSize: 6))),
          DataCell(Text("${expense.header}", style: TextStyle(fontSize: 6))),
          DataCell(
              Text("${expense.description}", style: TextStyle(fontSize: 6))),
          DataCell(
              Text("${expense.modeOfPayment}", style: TextStyle(fontSize: 6))),
          DataCell(Text("${expense.amount}", style: TextStyle(fontSize: 6))),
        ]);
      },
    ).toList();
  }

  showStockRow() {
    return List.generate(
      widget.args.products!.length,
      (index) {
        final product = widget.args.products?[index];
        return DataRow(cells: [
          DataCell(Text("${product!.name}", style: TextStyle(fontSize: 6))),
          DataCell(Text("${product.quantity}", style: TextStyle(fontSize: 6))),
          DataCell(Text("${product.quantity! * product.sellingPrice!}",
              style: TextStyle(fontSize: 6))),
        ]);
      },
    ).toList();
  }

  String breakruler = "";
  itemSPRows() {
    return widget.args.orders!.map((Order e) {
      return e.orderItems!.map((OrderItem item) {
        // print(e.user!.type);
        taxfileType = e.user!.type ?? "notdone";
        if (breakruler !=
            DateFormat('hh:mm a').format(DateTime.tryParse(e.createdAt!)!)) {
          datelist.add("");
          timelist.add("");
          partynamelist.add("");
          productnamelist.add("");
          basesplist.add("");
          gstratelist.add("");
          cgstlist.add("");
          sgstlist.add("");
          igstlist.add("");
          totalsplist.add("");
          mrplist.add("");
          moplist.add("");
        }
        datelist.add(DateFormat('dd MMM, yyyy')
            .format(DateTime.tryParse(e.createdAt!)!));
        timelist.add(
            DateFormat('hh:mm a').format(DateTime.tryParse(e.createdAt!)!));
        partynamelist.add(e.party?.name ?? "N/A");
        productnamelist.add("${item.quantity} x ${item.product?.name ?? ""}");
        gstratelist.add(
            "${item.product?.gstRate == "null" ? "N/A" : (item.product?.gstRate != "null" ? item.product?.gstRate : "N/A")}%");
        widget.args.type == "ReportType.sale"
            ? basesplist.add(
                "${item.baseSellingPrice != "null" ? double.parse(item.baseSellingPrice!).toStringAsFixed(2) : (item.product?.baseSellingPriceGst != "null" ? item.product?.baseSellingPriceGst : "N/A")}")
            : basesplist.add(
                "${item.product?.basePurchasePriceGst == "null" ? "N/A" : item.product?.basePurchasePriceGst}");
        widget.args.type == "ReportType.sale"
            ? cgstlist.add(
                "${item.saleCGST != "null" ? double.parse(item.saleCGST!).toStringAsFixed(2) : (item.product?.salecgst != "null" ? item.product?.salecgst : "N/A")}")
            : cgstlist.add(
                "${item.product?.purchasecgst == "null" ? "N/A" : item.product?.purchasecgst}");
        widget.args.type == "ReportType.sale"
            ? sgstlist.add(
                "${item.saleSGST != "null" ? double.parse(item.saleSGST!).toStringAsFixed(2) : (item.product?.salesgst != "null" ? item.product?.salesgst : "N/A")}")
            : sgstlist.add(
                "${item.product?.purchasesgst == "null" ? "N/A" : item.product?.purchasesgst}");
        widget.args.type == "ReportType.sale"
            ? igstlist.add(
                "${item.saleIGST != "null" ? double.parse(item.saleIGST!).toStringAsFixed(2) : (item.product?.saleigst != "null" ? item.product?.saleigst : "N/A")}")
            : igstlist.add(
                "${item.product?.purchaseigst == "null" ? "N/A" : item.product?.purchaseigst}");
        widget.args.type == "ReportType.sale"
            ? mrplist.add("${item.price}")
            : mrplist.add(
                "${item.product?.purchasePrice == "null" ? "N/A" : item.product?.purchasePrice}");
        widget.args.type == "ReportType.sale"
            ? totalsplist.add("${(item.quantity) * (item.price ?? 0)}")
            : totalsplist
                .add("${(item.quantity) * (item.product?.purchasePrice ?? 0)}");
        moplist.add("${e.modeOfPayment ?? "N/A"}");
        breakruler =
            DateFormat('hh:mm a').format(DateTime.tryParse(e.createdAt!)!);
      }).toList();
    }).toList();
  }

  String total() {
    for (int i = 0; i < totalsplist.length; i++) {
      print(totalsplist[i]);
    }
    int sum = 0;

    totalsplist.forEach(
      (element) {
        var sum_int = 0;
        if (element == "") {
          sum_int = 0;
        } else {
          var sum1 = double.parse(element);
          sum_int = sum1.toInt();
        }
        sum += sum_int;
      },
    );
    print(sum);
    return sum.toString();
  }

  Future<void> sharePDF() async {
    locator<GlobalServices>().infoSnackBar("Generating PDF");
    await screenshotController.capture().then((Uint8List? image) {
      setState(() {
        _imageFile = image!;
        _convertImageToPDF();
      });
    }).catchError((onError) {
      locator<GlobalServices>().errorSnackBar("Something went wrong");
    });
  }

  Future<void> _convertImageToPDF() async {
    final pdf = pw.Document();
    final image = pw.MemoryImage(
      _imageFile,
    );

    pdf.addPage(pw.Page(
        pageFormat: PdfPageFormat.roll57,
        build: (pw.Context context) {
          return pw.Container(
            child: pw.Image(image),
          );
        }));

    final targetPath = await getTemporaryDirectory();
    final path = targetPath.path;
    File file = widget.args.type == "ReportType.sale"
        ? File('$path/sale.pdf')
        : widget.args.type == "ReportType.purchase"
            ? File('$path/purchase.pdf')
            : widget.args.type == "ReportType.expense"
                ? File('$path/expense.pdf')
                : File('$path/stock.pdf');

    await file.writeAsBytes(await pdf.save());
    Share.shareFiles(
      [file.path],
      mimeTypes: ['application/pdf'],
    );
  }

  // Future<void> _convertImageToExcel() async {
  //   var excel = Excel.createExcel();
  //   var sheet = excel['Sheet1'];

  //   var headers = headerRows();
  //   for (var i = 0; i < headers.length; i++) {
  //     sheet
  //         .cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0))
  //         .value = headers[i].label;
  //   }

  //   var rows = widget.args.type == "ReportType.sale"
  //       ? showSaleRow()
  //       : widget.args.type == "ReportType.purchase"
  //           ? showPurchaseRow()
  //           : widget.args.type == "ReportType.expense"
  //               ? showExpenseRow()
  //               : showStockRow();

  //   for (var i = 0; i < rows.length; i++) {
  //     for (var j = 0; j < rows[i].cells.length; j++) {
  //       sheet
  //           .cell(CellIndex.indexByColumnRow(columnIndex: j, rowIndex: i + 1))
  //           .value = rows[i].cells[j].child.toString();
  //     }
  //   }

  //   var excelFile = excel.encode();
  //   Uint8List excelBytes = Uint8List.fromList(excelFile!);

  //   final directory = await getApplicationDocumentsDirectory();
  //   File excelFileLocal = File('${directory.path}/report.xlsx');
  //   await excelFileLocal.writeAsBytes(excelBytes);

  //   Share.shareFiles(
  //     [excelFileLocal.path],
  //     mimeTypes: [
  //       'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
  //     ],
  //   );
  // }

  saleExcelReport() async {
    final headersSP = [
      'Date',
      'Time',
      'Party',
      'M.O.P.',
      'Product',
      'Amount/Unit',
      'GST Rate/Unit',
      'CGST/Unit',
      'SGST/Unit',
      'GST/Unit',
      'MRP/Unit',
      'Total',
    ];

    final xcel.Workbook workbook = xcel.Workbook();
    final xcel.Worksheet sheet = workbook.worksheets[0];

    for (int i = 1; i <= headersSP.length; i++) {
      sheet.getRangeByIndex(1, i).setText(headersSP[i - 1]);
    }

    for (int i = 0; i < datelist.length; i++) {
      print(datelist.length);
      if (taxfileType == "quarterly") {
        sheet.getRangeByIndex(i + 2, 1).setText(datelist[i]);
        sheet.getRangeByIndex(i + 2, 2).setText(timelist[i]);
        sheet.getRangeByIndex(i + 2, 3).setText(partynamelist[i]);
        sheet.getRangeByIndex(i + 2, 4).setText(moplist[i]);
        sheet.getRangeByIndex(i + 2, 5).setText(productnamelist[i]);
        sheet.getRangeByIndex(i + 2, 6).setText(mrplist[i]);
        sheet.getRangeByIndex(i + 2, 7).setText(totalsplist[i]);
      } else {
        sheet.getRangeByIndex(i + 2, 1).setText(datelist[i] ?? '');
        sheet.getRangeByIndex(i + 2, 2).setText(timelist[i]);
        sheet.getRangeByIndex(i + 2, 3).setText(partynamelist[i]);
        sheet.getRangeByIndex(i + 2, 4).setText(moplist[i]);
        sheet.getRangeByIndex(i + 2, 5).setText(productnamelist[i]);
        sheet.getRangeByIndex(i + 2, 6).setText(basesplist[i]);
        sheet.getRangeByIndex(i + 2, 7).setText(gstratelist[i]);
        sheet.getRangeByIndex(i + 2, 8).setText(cgstlist[i]);
        sheet.getRangeByIndex(i + 2, 9).setText(sgstlist[i]);
        sheet.getRangeByIndex(i + 2, 10).setText(igstlist[i]);
        sheet.getRangeByIndex(i + 2, 11).setText(mrplist[i]);
        sheet.getRangeByIndex(i + 2, 12).setText(totalsplist[i]);
      }
    }

    final List<int> bytes = workbook.saveAsStream();
    final directory = await getApplicationDocumentsDirectory();
    File excelFileLocal = File('${directory.path}/sale.xlsx');
    await excelFileLocal.writeAsBytes(bytes);

    Share.shareFiles(
      [excelFileLocal.path],
      mimeTypes: [
        'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
      ],
    );

    workbook.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: widget.args.type == "ReportType.sale"
            ? Text("Sale Report")
            : widget.args.type == "ReportType.purchase"
                ? Text("Purchase Report")
                : widget.args.type == "ReportType.expense"
                    ? Text("Expense Report")
                    : Text("Stock Report"),
        actions: [
          IconButton(
            onPressed: () async {
              // sharePDF();
              // _convertImageToExcel();
              widget.args.type == "ReportType.sale"
                  ? saleExcelReport()
                  : sharePDF();

              // saleExcelReport();
            },
            icon: Icon(Icons.share),
          ),
        ],
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: InteractiveViewer(
            constrained: false,
            child: Screenshot(
              controller: screenshotController,
              child: DataTable(
                  columnSpacing: 5,
                  horizontalMargin: 5,
                  dataRowHeight: 10,
                  headingRowHeight: 20,
                  border: TableBorder.all(),
                  columns: headerRows(),
                  rows: widget.args.type == "ReportType.sale"
                      ? showSaleRow()
                      : widget.args.type == "ReportType.purchase"
                          ? showPurchaseRow()
                          : widget.args.type == "ReportType.expense"
                              ? showExpenseRow()
                              : showStockRow()),
            ),
          ),
        ),
      ),
    );
  }
}
