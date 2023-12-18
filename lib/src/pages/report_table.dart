import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shopos/src/models/expense.dart';
import 'package:shopos/src/models/input/order.dart';

import 'package:pdf/widgets.dart' as pw;
import 'package:shopos/src/models/party.dart';
import 'package:shopos/src/models/product.dart';

import 'package:shopos/src/pages/create_party.dart';

import 'package:shopos/src/services/global.dart';
import 'package:shopos/src/services/locator.dart';
import 'package:shopos/src/services/party.dart';
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
  List<String> hsn = [];
  List<String> discountAmt = [];
  List<String> invoiceNum = [];
  List<String> orginalbasePurchasePrice = [];

  String taxfileType = "initailized";

  String partynametoFilter = "";
  TextEditingController FilterTextEditorController = TextEditingController();

  ScreenshotController screenshotController = ScreenshotController();
  late Uint8List _imageFile;
  late final TextEditingController _typeAheadController = TextEditingController();
  @override
  void initState() {
    super.initState();
    if (widget.args.type == "ReportType.sale" || widget.args.type == "ReportType.purchase") {
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
      hsn.add("");
      discountAmt.add("");
      invoiceNum.add("");
      orginalbasePurchasePrice.add("");
    }
  }

  headerRows() {
    final headersSP = [
      'Date',
      'Time',
      'Party',
      'M.O.P.',
      'Product',
      'Hsn',
      "Rate",
      "Discount",
      "Taxable value", // 'Amount/Unit',
      'GST Rate',
      'CGST',
      'SGST',
      'GST/Unit',
      'Amount',
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
    final headersExpense = ['Date', 'Time', 'Header', 'Description', 'M.O.P', 'Amount'];
    final headersStock = ['Item Name', 'Stock Quantity', 'Sales Value', 'Purchase Value', 'profit margin'];

    if (widget.args.type == "ReportType.sale") {
      if (taxfileType == "quarterly") {
        return List.generate(
          headersQuaterly.length,
          (int index) => DataColumn(
            label: Container(
              child: Text(headersQuaterly[index], style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
            ),
          ),
        );
      } else {
        return List.generate(
          headersSP.length,
          (int index) => DataColumn(
            label: Container(
              child: Text(headersSP[index], style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
            ),
          ),
        );
      }
    } else if (widget.args.type == "ReportType.purchase") {
      return List.generate(
        headersSP.length,
        (int index) => DataColumn(
          label: Container(
            child: Text(headersSP[index], style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
          ),
        ),
      );
    } else if (widget.args.type == "ReportType.expense") {
      return List.generate(
        headersExpense.length,
        (int index) => DataColumn(
          label: Container(
            child: Text(headersExpense[index], style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
          ),
        ),
      );
    } else if (widget.args.type == "ReportType.stock") {
      return List.generate(
        headersStock.length,
        (int index) => DataColumn(
          label: Container(
            child: Text(headersStock[index], style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
          ),
        ),
      );
    }
  }

  showSaleRow() {
    if (taxfileType == "quarterly") {
      List<DataRow> list = [];
      var total = 0;
      for (int i = 0; i < datelist.length; i++) {
        if (partynamelist[i] == partynametoFilter || partynametoFilter == "") {
          list.add(DataRow(cells: [
            DataCell(Text(datelist[i], style: TextStyle(fontSize: 6))),
            DataCell(Text(timelist[i], style: TextStyle(fontSize: 6))),
            DataCell(Text(partynamelist[i], style: TextStyle(fontSize: 6))),
            DataCell(Text(moplist[i], style: TextStyle(fontSize: 6))),
            DataCell(Text(productnamelist[i], style: TextStyle(fontSize: 6))),
            DataCell(Text(mrplist[i], style: TextStyle(fontSize: 6))),
            DataCell(Text("hsssssssn", style: TextStyle(fontSize: 6))),
            DataCell(Text(totalsplist[i], style: TextStyle(fontSize: 6))),
          ]));
          if (i != datelist.length - 1) total += int.parse(totalsplist[i]);
        }
      }

      if (partynametoFilter != "")
        list.add(DataRow(cells: [
          DataCell(Text(datelist[datelist.length - 1], style: TextStyle(fontSize: 6))),
          DataCell(Text(timelist[datelist.length - 1], style: TextStyle(fontSize: 6))),
          DataCell(Text(partynamelist[datelist.length - 1], style: TextStyle(fontSize: 6))),
          DataCell(Text(moplist[datelist.length - 1], style: TextStyle(fontSize: 6))),
          DataCell(Text(productnamelist[datelist.length - 1], style: TextStyle(fontSize: 6))),
          DataCell(Text(mrplist[datelist.length - 1], style: TextStyle(fontSize: 6))),
          DataCell(Text("hsssssssn", style: TextStyle(fontSize: 6))),
          DataCell(Text(total.toString(), style: TextStyle(fontSize: 6))),
        ]));

      return list;
    } else {
      List<DataRow> list = [];

      double total = 0;
      double basesplitTotal = 0;
      double gstrateTotal = 0;
      double cgstTotal = 0;
      double sgstTotal = 0;
      double igstTotal = 0;
      double mrpTotal = 0;

      for (int i = 0; i < datelist.length; i++) {
        if (partynamelist[i] == partynametoFilter || partynametoFilter == "") {
          /*
          print("ADadda");
          print(datelist[i]);
          print(timelist[i]);
          print(partynamelist[i]);
          print(productnamelist[i]);
          print(basesplist[i]);
          print(gstratelist[i]);
          print(cgstlist[i]);
          print(sgstlist[i]);
          print(mrplist[i]);
          print(igstlist[i]);
          print(totalsplist[i]);
          print(moplist[i]);*/

          if (i != datelist.length - 1 && totalsplist[i].length != 0 && totalsplist[i] != "null") total += double.parse(totalsplist[i]);

          if (i != datelist.length - 1 && basesplist[i].length != 0 && basesplist[i] != "N/A" && basesplist[i] != "null") basesplitTotal += double.parse(basesplist[i].split(".")[0]);
          if (i != datelist.length - 1 && gstratelist[i].length != 0 && gstratelist[i] != "N/A%" && gstratelist[i] != "null%") gstrateTotal += double.parse(gstratelist[i].split("%")[0]);
          if (i != datelist.length - 1 && cgstlist[i].length != 0 && cgstlist[i] != "N/A" && cgstlist[i] != "null") cgstTotal += double.parse(cgstlist[i].split(".")[0]);
          if (i != datelist.length - 1 && sgstlist[i].length != 0 && sgstlist[i] != "N/A" && sgstlist[i] != "null") sgstTotal += double.parse(sgstlist[i].split(".")[0]);
          if (i != datelist.length - 1 && igstlist[i].length != 0 && igstlist[i] != "N/A" && igstlist[i] != "null") igstTotal += double.parse(igstlist[i].split(".")[0]);
          if (i != datelist.length - 1 && mrplist[i].length != 0 && mrplist[i] != "N/A" && mrplist[i] != "null") mrpTotal += double.parse(mrplist[i]);
          list.add(DataRow(cells: [
            DataCell(Text(datelist[i], style: TextStyle(fontSize: 6))),
            DataCell(Text(timelist[i], style: TextStyle(fontSize: 6))),
            DataCell(Text(partynamelist[i], style: TextStyle(fontSize: 6))),
            DataCell(Text(moplist[i], style: TextStyle(fontSize: 6))),
            DataCell(Text(productnamelist[i], style: TextStyle(fontSize: 6))),
            DataCell(Text(hsn[i], style: TextStyle(fontSize: 6))),
            DataCell(Text(orginalbasePurchasePrice[i], style: TextStyle(fontSize: 6))),
            DataCell(Text(discountAmt[i], style: TextStyle(fontSize: 6))),
            DataCell(Text(i == datelist.length - 1 ? basesplitTotal.toString() : basesplist[i], style: TextStyle(fontSize: 6))),
            DataCell(Text(i == datelist.length - 1 ? gstrateTotal.toString() : gstratelist[i], style: TextStyle(fontSize: 6))),
            DataCell(Text(i == datelist.length - 1 ? cgstTotal.toString() : cgstlist[i], style: TextStyle(fontSize: 6))),
            DataCell(Text(i == datelist.length - 1 ? sgstTotal.toString() : sgstlist[i], style: TextStyle(fontSize: 6))),
            DataCell(Text(i == datelist.length - 1 ? igstTotal.toString() : igstlist[i], style: TextStyle(fontSize: 6))),
            DataCell(Text(i == datelist.length - 1 ? mrpTotal.toString() : mrplist[i], style: TextStyle(fontSize: 6))),
            DataCell(Text(totalsplist[i], style: TextStyle(fontSize: 6))),
          ]));
        }
      }
      if (partynametoFilter != "")
        list.add(DataRow(cells: [
          DataCell(Text(datelist[datelist.length - 1], style: TextStyle(fontSize: 6))),
          DataCell(Text(timelist[datelist.length - 1], style: TextStyle(fontSize: 6))),
          DataCell(Text(partynamelist[datelist.length - 1], style: TextStyle(fontSize: 6))),
          DataCell(Text(moplist[datelist.length - 1], style: TextStyle(fontSize: 6))),
          DataCell(Text(productnamelist[datelist.length - 1], style: TextStyle(fontSize: 6))),
          DataCell(Text(basesplist[datelist.length - 1], style: TextStyle(fontSize: 6))),
          DataCell(Text(gstratelist[datelist.length - 1], style: TextStyle(fontSize: 6))),
          DataCell(Text(cgstlist[datelist.length - 1], style: TextStyle(fontSize: 6))),
          DataCell(Text(sgstlist[datelist.length - 1], style: TextStyle(fontSize: 6))),
          DataCell(Text(igstlist[datelist.length - 1], style: TextStyle(fontSize: 6))),
          DataCell(Text(mrplist[datelist.length - 1], style: TextStyle(fontSize: 6))),
          DataCell(Text(total.toString(), style: TextStyle(fontSize: 6))),
        ]));
      return list;
    }
  }

  showPurchaseRow() {
    var total = 0;
    var basesplitTotal = 0;
    var gstrateTotal = 0;
    var cgstTotal = 0;
    var sgstTotal = 0;
    var igstTotal = 0;
    var mrpTotal = 0;

    List<DataRow> list = [];

    for (int index = 0; index < datelist.length; index++) {
      if (partynamelist[index] == partynametoFilter || partynametoFilter == "") {
        if (index != datelist.length - 1 && totalsplist[index].length != 0) total += int.parse(totalsplist[index].split(".")[0]);

        if (index != datelist.length - 1 && basesplist[index].length != 0 && basesplist[index] != "N/A" && basesplist[index] != "null") basesplitTotal += int.parse(basesplist[index].split(".")[0]);
        if (index != datelist.length - 1 && gstratelist[index].length != 0 && gstratelist[index] != "N/A%" && basesplist[index] != "null") gstrateTotal += int.parse(gstratelist[index].split("%")[0]);
        if (index != datelist.length - 1 && cgstlist[index].length != 0 && cgstlist[index] != "N/A" && basesplist[index] != "null") cgstTotal += int.parse(cgstlist[index].split(".")[0]);
        if (index != datelist.length - 1 && sgstlist[index].length != 0 && sgstlist[index] != "N/A" && basesplist[index] != "null") sgstTotal += int.parse(sgstlist[index].split(".")[0]);
        if (index != datelist.length - 1 && igstlist[index].length != 0 && igstlist[index] != "N/A" && basesplist[index] != "null") igstTotal += int.parse(igstlist[index].split(".")[0]);
        if (index != datelist.length - 1 && mrplist[index].length != 0 && mrplist[index] != "N/A" && basesplist[index] != "null") mrpTotal += int.parse(mrplist[index].split(".")[0]);

        list.add(DataRow(cells: [
          DataCell(Text(datelist[index], style: TextStyle(fontSize: 6))),
          DataCell(Text(timelist[index], style: TextStyle(fontSize: 6))),
          DataCell(Text(partynamelist[index], style: TextStyle(fontSize: 6))),
          DataCell(Text(moplist[index], style: TextStyle(fontSize: 6))),
          DataCell(Text(productnamelist[index], style: TextStyle(fontSize: 6))),
          DataCell(Text(hsn[index], style: TextStyle(fontSize: 6))),
          DataCell(Text(orginalbasePurchasePrice[index], style: TextStyle(fontSize: 6))),
          DataCell(Text(discountAmt[index], style: TextStyle(fontSize: 6))),
          DataCell(Text(index == datelist.length - 1 ? basesplitTotal.toString() : basesplist[index], style: TextStyle(fontSize: 6))),
          DataCell(Text(index == datelist.length - 1 ? gstrateTotal.toString() : gstratelist[index], style: TextStyle(fontSize: 6))),
          DataCell(Text(index == datelist.length - 1 ? cgstTotal.toString() : cgstlist[index], style: TextStyle(fontSize: 6))),
          DataCell(Text(index == datelist.length - 1 ? sgstTotal.toString() : sgstlist[index], style: TextStyle(fontSize: 6))),
          DataCell(Text(index == datelist.length - 1 ? igstTotal.toString() : igstlist[index], style: TextStyle(fontSize: 6))),
          DataCell(Text(index == datelist.length - 1 ? mrpTotal.toString() : mrplist[index], style: TextStyle(fontSize: 6))),
          DataCell(Text(totalsplist[index], style: TextStyle(fontSize: 6))),
        ]));
      }
    }

    if (partynametoFilter != "")
      list.add(DataRow(cells: [
        DataCell(Text(datelist[datelist.length - 1], style: TextStyle(fontSize: 6))),
        DataCell(Text(timelist[datelist.length - 1], style: TextStyle(fontSize: 6))),
        DataCell(Text(partynamelist[datelist.length - 1], style: TextStyle(fontSize: 6))),
        DataCell(Text(moplist[datelist.length - 1], style: TextStyle(fontSize: 6))),
        DataCell(Text(productnamelist[datelist.length - 1], style: TextStyle(fontSize: 6))),
        DataCell(Text(basesplitTotal.toString(), style: TextStyle(fontSize: 6))),
        DataCell(Text(gstrateTotal.toString(), style: TextStyle(fontSize: 6))),
        DataCell(Text(cgstTotal.toString(), style: TextStyle(fontSize: 6))),
        DataCell(Text(sgstTotal.toString(), style: TextStyle(fontSize: 6))),
        DataCell(Text(igstTotal.toString(), style: TextStyle(fontSize: 6))),
        DataCell(Text(mrpTotal.toString(), style: TextStyle(fontSize: 6))),
        DataCell(Text("", style: TextStyle(fontSize: 6))),
        DataCell(Text(" ", style: TextStyle(fontSize: 6))),
        DataCell(Text(total.toString(), style: TextStyle(fontSize: 6))),
      ]));
    return list;
  }

  showExpenseRow() {
    int total = 0;
    List<DataRow> list = [];

    for (int index = 0; index < widget.args.expenses!.length; index++) {
      final expense = widget.args.expenses?[index];
      final date = DateFormat('dd MMM, yyyy').format(expense!.createdAt!);
      final time = DateFormat('hh:mm a').format(expense.createdAt!);
      total = total + expense.amount!;
      list.add(DataRow(cells: [
        DataCell(Text("$date", style: TextStyle(fontSize: 6))),
        DataCell(Text("$time", style: TextStyle(fontSize: 6))),
        DataCell(Text("${expense.header}", style: TextStyle(fontSize: 6))),
        DataCell(Text("${expense.description}", style: TextStyle(fontSize: 6))),
        DataCell(Text("${expense.modeOfPayment}", style: TextStyle(fontSize: 6))),
        DataCell(Text("${expense.amount}", style: TextStyle(fontSize: 6))),
      ]));
    }
    list.add(DataRow(cells: [
      DataCell(Text("", style: TextStyle(fontSize: 6))),
      DataCell(Text("", style: TextStyle(fontSize: 6))),
      DataCell(Text("", style: TextStyle(fontSize: 6))),
      DataCell(Text("", style: TextStyle(fontSize: 6))),
      DataCell(Text("", style: TextStyle(fontSize: 6))),
      DataCell(Text("$total", style: TextStyle(fontSize: 6))),
    ]));

    return list;
  }

  showStockRow() {
    int productQTYTotal = 0;
    int salesValueTotal = 0;
    double purchaseValueTotal = 0;
    int marginValueTotal = 0;

    List<DataRow> list = [];
    for (int index = 0; index < widget.args.products!.length; index++) {
      final product = widget.args.products?[index];

      var salesValue = product!.quantity! * product.sellingPrice!;
      var purchaseValue = product.quantity! * product.purchasePrice;

      productQTYTotal += product.quantity!;
      salesValueTotal += salesValue.toInt();
      purchaseValueTotal += purchaseValue;
      marginValueTotal += (salesValue - purchaseValue).toInt();
      list.add(DataRow(cells: [
        DataCell(Text("${product.name}", style: TextStyle(fontSize: 6))),
        DataCell(Text("${product.quantity}", style: TextStyle(fontSize: 6))),
        DataCell(Text("$salesValue", style: TextStyle(fontSize: 6))),
        DataCell(Text("$purchaseValue", style: TextStyle(fontSize: 6))),
        DataCell(Text("${salesValue - purchaseValue}", style: TextStyle(fontSize: 6))),
      ]));
    }

    list.add(DataRow(cells: [
      DataCell(Text("", style: TextStyle(fontSize: 6))),
      DataCell(Text("$productQTYTotal", style: TextStyle(fontSize: 6))),
      DataCell(Text("$salesValueTotal", style: TextStyle(fontSize: 6))),
      DataCell(Text("$salesValueTotal", style: TextStyle(fontSize: 6))),
      DataCell(Text("$marginValueTotal", style: TextStyle(fontSize: 6))),
    ]));

    return list;
  }

  String breakruler = "";
  itemSPRows() {
    // print("discount ${widget.args.orders![0].discountAmt}");

    return widget.args.orders!.map((Order e) {
      return e.orderItems!.map((OrderItemInput item) {
        // print(e.user!.type);
        taxfileType = e.user!.type ?? "notdone";
        if (breakruler != DateFormat('hh:mm a').format(DateTime.tryParse(e.createdAt.toString())!)) {
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
          hsn.add("");
          invoiceNum.add("");
          discountAmt.add("");
          orginalbasePurchasePrice.add("");
          moplist.add("");
        }
        datelist.add(DateFormat('dd MMM, yyyy').format(DateTime.tryParse(e.createdAt.toString())!));
        timelist.add(DateFormat('hh:mm a').format(DateTime.tryParse(e.createdAt.toString())!));
        partynamelist.add(e.party?.name ?? "N/A");
        productnamelist.add("${item.quantity} x ${item.product?.name ?? ""}");
        gstratelist.add("${item.product?.gstRate == "null" ? "N/A" : (item.product?.gstRate != "null" ? item.product?.gstRate : "N/A")}%");
        widget.args.type == "ReportType.sale"
            ? basesplist.add(
                "${item.baseSellingPrice != "null" ? double.parse(item.baseSellingPrice!).toStringAsFixed(2) : (item.product?.baseSellingPriceGst != "null" ? item.product?.baseSellingPriceGst : "N/A")}")
            : basesplist.add("${item.product?.basePurchasePriceGst == "null" ? "N/A" : item.product?.basePurchasePriceGst}");
        widget.args.type == "ReportType.sale"
            ? cgstlist.add("${item.saleCGST != "null" ? double.parse(item.saleCGST!).toStringAsFixed(2) : (item.product?.salecgst != "null" ? item.product?.salecgst : "N/A")}")
            : cgstlist.add("${item.product?.purchasecgst == "null" ? "N/A" : item.product?.purchasecgst}");
        widget.args.type == "ReportType.sale"
            ? sgstlist.add("${item.saleSGST != "null" ? double.parse(item.saleSGST!).toStringAsFixed(2) : (item.product?.salesgst != "null" ? item.product?.salesgst : "N/A")}")
            : sgstlist.add("${item.product?.purchasesgst == "null" ? "N/A" : item.product?.purchasesgst}");
        widget.args.type == "ReportType.sale"
            ? igstlist.add("${item.saleIGST != "null" ? double.parse(item.saleIGST!).toStringAsFixed(2) : (item.product?.saleigst != "null" ? item.product?.saleigst : "N/A")}")
            : igstlist.add("${item.product?.purchaseigst == "null" ? "N/A" : item.product?.purchaseigst}");
        widget.args.type == "ReportType.sale" ? mrplist.add("${item.price}") : mrplist.add("${item.product?.purchasePrice == "null" ? "N/A" : item.product?.purchasePrice}");
        hsn.add("${item.product!.hsn == "null" ? "N/A" : item.product!.hsn}");
        discountAmt.add("${item.discountAmt == "null" ? "N/A" : item.discountAmt}");

        invoiceNum.add("${e.invoiceNum == null ? "N/A" : e.invoiceNum}");
        orginalbasePurchasePrice.add("${item.originalbaseSellingPrice}");
        widget.args.type == "ReportType.sale" ? totalsplist.add("${(item.quantity) * (item.price ?? 0)}") : totalsplist.add("${(item.quantity) * (item.product?.purchasePrice ?? 0)}");

        moplist.add("${e.modeOfPayment ?? "N/A"}");
        breakruler = DateFormat('hh:mm a').format(DateTime.tryParse(e.createdAt.toString())!);
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
      'Hsn',
      "Rate",
      "Discount",
      "Taxable value", // 'Amount/Unit',
      'GST Rate',
      'CGST',
      'SGST',
      'GST/Unit',
      'Amount',
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
        sheet.getRangeByIndex(i + 2, 6).setText(hsn[i]);
        sheet.getRangeByIndex(i + 2, 7).setText(orginalbasePurchasePrice[i]);
        sheet.getRangeByIndex(i + 2, 8).setText(discountAmt[i]);
        sheet.getRangeByIndex(i + 2, 9).setText(basesplist[i]);
        sheet.getRangeByIndex(i + 2, 10).setText(gstratelist[i]);
        sheet.getRangeByIndex(i + 2, 11).setText(cgstlist[i]);
        sheet.getRangeByIndex(i + 2, 12).setText(sgstlist[i]);
        sheet.getRangeByIndex(i + 2, 13).setText(igstlist[i]);
        sheet.getRangeByIndex(i + 2, 14).setText(mrplist[i]);
        sheet.getRangeByIndex(i + 2, 15).setText(totalsplist[i]);
      }
    }

    final List<int> bytes = workbook.saveAsStream();
    final directory = await getApplicationDocumentsDirectory();
    File excelFileLocal = File('${directory.path}/Sale.xlsx');
    await excelFileLocal.writeAsBytes(bytes);

    Share.shareFiles(
      [excelFileLocal.path],
      mimeTypes: ['application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'],
    );

    workbook.dispose();
  }

  PurchaseExcelReport() async {
    final headersSP = [
      'Date',
      'Time',
      'Party',
      'M.O.P.',
      'Product',
      'Hsn',
      "Rate",
      "Discount",
      "Taxable value", // 'Amount/Unit',
      'GST Rate',
      'CGST',
      'SGST',
      'GST/Unit',
      'Amount',
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
        sheet.getRangeByIndex(i + 2, 6).setText(hsn[i]);
        sheet.getRangeByIndex(i + 2, 7).setText(orginalbasePurchasePrice[i]);
        sheet.getRangeByIndex(i + 2, 8).setText(discountAmt[i]);
        sheet.getRangeByIndex(i + 2, 9).setText(basesplist[i]);
        sheet.getRangeByIndex(i + 2, 10).setText(gstratelist[i]);
        sheet.getRangeByIndex(i + 2, 11).setText(cgstlist[i]);
        sheet.getRangeByIndex(i + 2, 12).setText(sgstlist[i]);
        sheet.getRangeByIndex(i + 2, 13).setText(igstlist[i]);
        sheet.getRangeByIndex(i + 2, 14).setText(mrplist[i]);
        sheet.getRangeByIndex(i + 2, 15).setText(totalsplist[i]);
      }
    }

    final List<int> bytes = workbook.saveAsStream();
    final directory = await getApplicationDocumentsDirectory();
    File excelFileLocal = File('${directory.path}/Purchase.xlsx');
    await excelFileLocal.writeAsBytes(bytes);

    Share.shareFiles(
      [excelFileLocal.path],
      mimeTypes: ['application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'],
    );

    workbook.dispose();
  }

  ExpenseExcelReport() async {
    final headersExpense = ['Date', 'Time', 'Header', 'Description', 'M.O.P', 'Amount'];
    final xcel.Workbook workbook = xcel.Workbook();
    final xcel.Worksheet sheet = workbook.worksheets[0];

    for (int i = 1; i <= headersExpense.length; i++) {
      sheet.getRangeByIndex(1, i).setText(headersExpense[i - 1]);
    }

    for (int i = 0; i < widget.args.expenses!.length; i++) {
      print(datelist.length);
      final expense = widget.args.expenses![i];
      final date = DateFormat('dd MMM, yyyy').format(expense.createdAt!);
      final time = DateFormat('hh:mm a').format(expense.createdAt!);

      sheet.getRangeByIndex(i + 2, 1).setText(date.toString());
      sheet.getRangeByIndex(i + 2, 2).setText(time.toString());
      sheet.getRangeByIndex(i + 2, 3).setText(expense.header);
      sheet.getRangeByIndex(i + 2, 4).setText(expense.description);
      sheet.getRangeByIndex(i + 2, 5).setText(expense.modeOfPayment);
      sheet.getRangeByIndex(i + 2, 6).setText(expense.amount.toString());
    }

    final List<int> bytes = workbook.saveAsStream();
    final directory = await getApplicationDocumentsDirectory();
    File excelFileLocal = File('${directory.path}/Expense.xlsx');
    await excelFileLocal.writeAsBytes(bytes);

    Share.shareFiles(
      [excelFileLocal.path],
      mimeTypes: ['application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'],
    );

    workbook.dispose();
  }

  STOCKExcelReport() async {
    final headersStock = ['Item Name', 'Stock Quantity', 'Sales Value', 'Purchase Value', 'profit margin'];

    final xcel.Workbook workbook = xcel.Workbook();
    final xcel.Worksheet sheet = workbook.worksheets[0];

    for (int i = 1; i <= headersStock.length; i++) {
      sheet.getRangeByIndex(1, i).setText(headersStock[i - 1]);
    }

    for (int i = 0; i < widget.args.products!.length; i++) {
      final product = widget.args.products![i];
      var salesValue = product.quantity! * product.sellingPrice!;
      var purchaseValue = product.quantity! * product.purchasePrice;

      sheet.getRangeByIndex(i + 2, 1).setText(product.name);
      sheet.getRangeByIndex(i + 2, 2).setText(product.quantity.toString());
      sheet.getRangeByIndex(i + 2, 3).setText(salesValue.toString());
      sheet.getRangeByIndex(i + 2, 4).setText(purchaseValue.toString());
      sheet.getRangeByIndex(i + 2, 5).setText((salesValue - purchaseValue).toString());
    }

    final List<int> bytes = workbook.saveAsStream();
    final directory = await getApplicationDocumentsDirectory();
    File excelFileLocal = File('${directory.path}/Stock.xlsx');
    await excelFileLocal.writeAsBytes(bytes);

    Share.shareFiles(
      [excelFileLocal.path],
      mimeTypes: ['application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'],
    );

    workbook.dispose();
  }

  Future<Iterable<Party>> _searchParties(String pattern) async {
    if (pattern.isEmpty) {
      return [];
    }
    // final type =
    //   widget.args.invoiceType == OrderType.sale ? "customer" : "supplier";

    try {
      final response;
      if (widget.args.type == "ReportType.purchase") {
        response = await const PartyService().getCreditPurchaseParties();
      } else {
        response = await const PartyService().getCreditSaleParties();
      }
      //  final response =await const PartyService().getSearch(pattern, type: "customer");

      // final data = response.data['allParty'] as List<dynamic>;
      //  return data.map((e) => Party.fromMap(e));
      return response;
    } catch (err) {
      // log(err.toString());
      return [];
    }
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
          if (widget.args.type != "ReportType.stock" && widget.args.type != "ReportType.expense")
            IconButton(
                onPressed: () {
                  _showDialog();
                },
                icon: Icon(Icons.filter_alt)),
          IconButton(
            onPressed: () async {
              // sharePDF();
              // _convertImageToExcel();
              widget.args.type == "ReportType.sale"
                  ? saleExcelReport()
                  : widget.args.type == "ReportType.purchase"
                      ? PurchaseExcelReport()
                      : widget.args.type == "ReportType.expense"
                          ? ExpenseExcelReport()
                          : STOCKExcelReport();
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

  Future<bool?> _showDialog() {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          title: Row(
            children: [
              Text('Enter party name to Filter'),
            ],
          ),
          content: TypeAheadFormField<Party>(
            validator: (value) {
              return null;
            },
            debounceDuration: const Duration(milliseconds: 500),
            textFieldConfiguration: TextFieldConfiguration(
              controller: _typeAheadController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: "Party",
                suffixIcon: GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, CreatePartyPage.routeName,
                        arguments: CreatePartyArguments(
                            "",
                            "",
                            "",
                            "",
                            /* widget.args.invoiceType ==
                                                    OrderType.purchase
                                                ? 'supplier'
                                                : 'customer',*/
                            "supplier"));
                  },
                  child: const Icon(Icons.add_circle_outline_rounded),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 2,
                  horizontal: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            suggestionsCallback: (String pattern) {
              if (int.tryParse(pattern.trim()) != null) {
                return Future.value([]);
              }

              return _searchParties(pattern);
            },
            itemBuilder: (context, party) {
              return ListTile(
                leading: const Icon(Icons.person),
                title: Text(party.name ?? ""),
              );
            },
            onSuggestionSelected: (Party party) {
              setState(() {
                partynametoFilter = party.name!;
              });
              _typeAheadController.text = party.name ?? "";
              Navigator.pop(ctx, false);
            },
          ),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.pop(ctx, false);
                },
                child: Text('Cancel')),
            TextButton(
                onPressed: () {
                  setState(() {
                    partynametoFilter = "";
                  });

                  Navigator.pop(ctx, false);
                },
                child: Text('clear')),
          ],
        );
      },
    );
  }
}
