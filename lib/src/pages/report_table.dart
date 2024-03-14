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
import 'package:shopos/src/pages/billing_list.dart';
import 'package:shopos/src/pages/checkout.dart';
import 'package:shopos/src/pages/create_estimate.dart';

import 'package:shopos/src/pages/create_party.dart';
import 'package:shopos/src/services/estimate.dart';

import 'package:shopos/src/services/global.dart';
import 'package:shopos/src/services/locator.dart';
import 'package:shopos/src/services/party.dart';
import 'package:shopos/src/services/sales.dart';
import 'package:shopos/src/widgets/custom_button.dart';
import 'package:shopos/src/widgets/custom_text_field.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xcel;

import '../models/input/kot_model.dart';
import '../services/kot_services.dart';
import '../widgets/custom_drop_down.dart';

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
  List<String> estimateNum =[];
  List<String> productnamelist = [];
  List<String> basesplist = [];
  List<String> gstratelist = [];
  List<String> cgstlist = [];
  List<String> sgstlist = [];
  List<String> igstlist = [];
  List<String> totalsplist = [];
  List<List<Map<String,dynamic>>> moplist = [];
  List<String> totallist = [];
  List<String> mrplist = [];
  List<String> hsn = [];
  List<String> discountAmt = [];
  List<String> invoiceNum = [];
  List<String> orginalbasePurchasePrice = [];

  String taxfileType = "initailized";

  String partynametoFilter = "";

  TextEditingController estimateNumController = TextEditingController();
  TextEditingController invoiceNumController = TextEditingController();
  ScreenshotController screenshotController = ScreenshotController();
  late Uint8List _imageFile;
  late final TextEditingController _typeAheadController = TextEditingController();
  String filterPaymentModeSelected="";

  @override
  void initState() {
    super.initState();
    if (widget.args.type == "ReportType.sale" || widget.args.type == "ReportType.purchase" || widget.args.type == "ReportType.estimate" || widget.args.type == "ReportType.saleReturn") {
      print("line 78 in report table");
      itemSPRows();
      print("line 80 in report table");
      print(datelist.length);
      print(estimateNum.length);
      datelist.add("");
      timelist.add("");
      estimateNum.add("");
      partynamelist.add("");
      productnamelist.add("");
      basesplist.add("");
      gstratelist.add("");
      cgstlist.add("");
      sgstlist.add("");
      mrplist.add("Total");
      igstlist.add("");
      totalsplist.add(total());
      moplist.add([]);
      hsn.add("");
      discountAmt.add("");
      invoiceNum.add("");
      orginalbasePurchasePrice.add("");
    }
  }

  headerRows() {
    final headersS = [
      'Date',
      'Time',
      'Invoice No',
      'Party',
      'Mode of Payment',
      'Product',
      'Hsn',
      "Rate",
      "Discount",
      "Taxable value", // 'Amount/Unit',
      'GST Rate',
      'CGST',
      'SGST',
      'GST',
      'Total',
    ];
    final headersSaleReturn = [
      'Date',
      'Time',
      'Invoice No',
      'Party',
      'Product',
      'Hsn',
      "Rate",
      "Discount",
      "Taxable value", // 'Amount/Unit',
      'GST Rate',
      'CGST',
      'SGST',
      'GST',
      'Total',
    ];
    final headersEstimate = [
      'Date',
      'Time',
      'Estimate No',
      'Product',
      'Hsn',
      "Rate",
      "Discount",
      "Taxable value", // 'Amount/Unit',
      'GST Rate',
      'CGST',
      'SGST',
      'GST',
      'Total',
    ];
    final headersP = [
      'Date',
      'Time',
      'Party',
      'Mode of Payment',
      'Product',
      'Hsn',
      "Rate",
      "Discount",
      "Taxable value", // 'Amount/Unit',
      'GST Rate',
      'CGST',
      'SGST',
      'GST',
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
          headersS.length,
              (int index) => DataColumn(
            label: Container(
              child: Text(headersS[index], style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
            ),
          ),
        );
      }
    } else if (widget.args.type == "ReportType.purchase") {
      print("lline 212 in report table");
      print(headersP.length);
      return List.generate(
        headersP.length,
            (int index) => DataColumn(
          label: Container(
            child: Text(headersP[index], style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
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
    }else if( widget.args.type == "ReportType.estimate"){
      return List.generate(headersEstimate.length, (int index) => DataColumn(
        label: Container(
          child: Text(headersEstimate[index], style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
        ),
      ),
      );
    }else if( widget.args.type == "ReportType.saleReturn"){
      return List.generate(headersSaleReturn.length, (int index) => DataColumn(
        label: Container(
          child: Text(headersSaleReturn[index], style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
        ),
      ),
      );
    }
  }

  showSaleRow() {
    if (taxfileType == "quarterly") {

      // print(partynamelist[0]);
      // print(partynamelist[1]);
      // print(partynametoFilter);
      List<DataRow> list = [];
      var total = 0;
      for (int i = 0; i < datelist.length; i++) {
        if (partynamelist[i] == partynametoFilter || partynametoFilter == "") {
          list.add(DataRow(cells: [
            DataCell(Text(datelist[i], style: TextStyle(fontSize: 6))),
            DataCell(Text(timelist[i], style: TextStyle(fontSize: 6))),
            DataCell(Text(partynamelist[i], style: TextStyle(fontSize: 6))),
            DataCell(Text(moplist[i].map((map) => "${map['mode'] ?? "N/A"} : ${map['amount'] ?? ""}")
                .join(', '), style: TextStyle(fontSize: 6))),
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
          DataCell(Text(moplist[datelist.length - 1].map((map) => "${map['mode'] ?? "N/A"} : ${map['amount'] ?? ""}")
              .join(', '), style: TextStyle(fontSize: 6))),
          DataCell(Text(productnamelist[datelist.length - 1], style: TextStyle(fontSize: 6))),
          DataCell(Text(mrplist[datelist.length - 1], style: TextStyle(fontSize: 6))),
          DataCell(Text("hsssssssn", style: TextStyle(fontSize: 6))),
          DataCell(Text(total.toString(), style: TextStyle(fontSize: 6))),
        ]));

      return list;
    } else {
      print("line 219 in report table.dart");
      // print(invoiceNum[0]);
      List<DataRow> list = [];

      /* for printing in the last row */
      double total = 0;
      double basesplitTotal = 0;
      double gstrateTotal = 0;
      double cgstTotal = 0;
      double sgstTotal = 0;
      double igstTotal = 0;
      double mrpTotal = 0;

      double totalCash = 0;
      double totalUPI = 0;
      double totalCredit = 0;
      double totalBankTransfer = 0;

      Set<String> uniqueIds = Set();//since this report table shows one row for each product so moplist may contain multiple same mop object with same ids
      //so discarding them and adding to totalCash, totalUPI ... etc.

      for (var sublist in moplist) {
        for (var entry in sublist) {
          if (entry.containsKey("mode") &&
              entry.containsKey("amount") &&
              entry.containsKey("_id")) {
            String id = entry["_id"];
            if (!uniqueIds.contains(id)) {
              double amount = entry["amount"].toDouble();
              switch (entry["mode"]) {
                case "Cash":
                  totalCash += amount;
                  break;
                case "UPI":
                  totalUPI += amount;
                  break;
                case "Credit":
                  totalCredit += amount;
                  break;
                case "Bank Transfer":
                  totalBankTransfer += amount;
                  break;
                default:
                  break;
              }
              uniqueIds.add(id);
            }
          }
        }
      }

      String totalMop = "Cash: ${totalCash.toStringAsFixed(2)}, UPI: ${totalUPI.toStringAsFixed(2)}, Bank: ${totalBankTransfer.toStringAsFixed(2)}, Credit: ${totalCredit.toStringAsFixed(2)}";

      //adding cells in the report table
      for (int i = 0; i < datelist.length; i++) {
        // print('partynametofiler= $partynametoFilter');
        // print("1: ${partynamelist[i] == partynametoFilter}");
        // print("2: ${moplist[i].any((map)=> map['mode']==filterPaymentModeSelected)}");
        // print("3: ${partynametoFilter == "" && filterPaymentModeSelected==""}");
        // print("mop list at i=$i is ${moplist[i]}");
        // print(totalsplist[i]);
        if ((partynamelist[i] == partynametoFilter && partynametoFilter!="") || moplist[i].any((map)=> map['mode']==filterPaymentModeSelected) ||(partynametoFilter == "" && filterPaymentModeSelected=="")) {
          // print(moplist[i].toString());
          if (i != datelist.length - 1 && totalsplist[i].length != 0 && totalsplist[i] != "null") total += double.parse(totalsplist[i]);

          if (i != datelist.length - 1 && basesplist[i].length != 0 && basesplist[i] != "N/A" && basesplist[i] != "null") basesplitTotal += double.parse(basesplist[i]);
          if (i != datelist.length - 1 && gstratelist[i].length != 0 && gstratelist[i] != "N/A%" && gstratelist[i] != "null%") gstrateTotal += double.parse(gstratelist[i].split("%")[0]);
          if (i != datelist.length - 1 && cgstlist[i].length != 0 && cgstlist[i] != "N/A" && cgstlist[i] != "null") cgstTotal += double.parse(cgstlist[i]);
          if (i != datelist.length - 1 && sgstlist[i].length != 0 && sgstlist[i] != "N/A" && sgstlist[i] != "null") sgstTotal += double.parse(sgstlist[i]);
          if (i != datelist.length - 1 && igstlist[i].length != 0 && igstlist[i] != "N/A" && igstlist[i] != "null") igstTotal += double.parse(igstlist[i]);
          if (i != datelist.length - 1 && mrplist[i].length != 0 && mrplist[i] != "N/A" && mrplist[i] != "null") mrpTotal += double.parse(mrplist[i]);
          list.add(DataRow(cells: [
            DataCell(Text(datelist[i], style: TextStyle(fontSize: 6))),
            DataCell(Text(timelist[i], style: TextStyle(fontSize: 6))),
            DataCell(Text(invoiceNum[i], style: TextStyle(fontSize: 6),)),
            DataCell(Text(partynamelist[i], style: TextStyle(fontSize: 6))),
            DataCell(Text(i == datelist.length - 1 ? totalMop :
                moplist[i].map((map) => "${map['mode'] ?? "N/A"} : ${map['amount'] ?? ""}").join(', '), style: TextStyle(fontSize: 6))),
            /*used if cash credit bankTransfer UPI would be 4 different columns*/
            // DataCell(Text(moplist[i].isEmpty? "":
            //     moplist[i].firstWhere((entry) => entry['mode'] == 'Cash',orElse: () => {'amount': 'N/A'})['amount'].toString(),style: TextStyle(fontSize: 6))),
            // DataCell(Text(moplist[i].isEmpty? "":
            //     moplist[i].firstWhere((entry) => entry['mode'] == 'Bank Transfer',orElse: () => {'amount': 'N/A'})['amount'].toString(), style: TextStyle(fontSize: 6))),
            // DataCell(Text(moplist[i].isEmpty? "":
            //     moplist[i].firstWhere((entry) => entry['mode'] == 'UPI',orElse: () => {'amount': 'N/A'})['amount'].toString(), style: TextStyle(fontSize: 6))),
            // DataCell(Text(moplist[i].isEmpty? "":
            //     moplist[i].firstWhere((entry) => entry['mode'] == 'Credit',orElse: () => {'amount': 'N/A'})['amount'].toString(), style: TextStyle(fontSize: 6))),

            DataCell(Text(productnamelist[i], style: TextStyle(fontSize: 6))),
            DataCell(Text(hsn[i], style: TextStyle(fontSize: 6))),
            DataCell(Text(orginalbasePurchasePrice[i], style: TextStyle(fontSize: 6))),
            DataCell(Text(discountAmt[i], style: TextStyle(fontSize: 6))),
            DataCell(Text(i == datelist.length - 1 ? basesplitTotal.toStringAsFixed(2) : basesplist[i], style: TextStyle(fontSize: 6))),
            DataCell(Text(gstratelist[i], style: TextStyle(fontSize: 6))),
            DataCell(Text(i == datelist.length - 1 ? cgstTotal.toStringAsFixed(2) : cgstlist[i], style: TextStyle(fontSize: 6))),
            DataCell(Text(i == datelist.length - 1 ? sgstTotal.toStringAsFixed(2) : sgstlist[i], style: TextStyle(fontSize: 6))),
            DataCell(Text(i == datelist.length - 1 ? igstTotal.toStringAsFixed(2) : igstlist[i], style: TextStyle(fontSize: 6))),
            // DataCell(Text(i == datelist.length - 1 ? mrpTotal.toStringAsFixed(2) : mrplist[i], style: TextStyle(fontSize: 6))),
            DataCell(Text(totalsplist[i], style: TextStyle(fontSize: 6))),
          ]));
        }
      }

      if (partynametoFilter != "" || filterPaymentModeSelected!=""){//for adding the last row in the table
        print("line 277 in report table.dart");
        print(datelist[datelist.length - 1]);
        list.add(DataRow(cells: [
          DataCell(Text(datelist[datelist.length - 1], style: TextStyle(fontSize: 6))),
          DataCell(Text(timelist[datelist.length - 1], style: TextStyle(fontSize: 6))),
          DataCell(Text(invoiceNum[datelist.length - 1], style: TextStyle(fontSize: 6),)),
          DataCell(Text(partynamelist[datelist.length - 1], style: TextStyle(fontSize: 6))),
          DataCell(Text(moplist[datelist.length - 1].map((map) => "${map['mode'] ?? "N/A"} : ${map['amount'] ?? ""}")
              .join(', '), style: TextStyle(fontSize: 6))),
          // DataCell(Text(moplist[datelist.length-1].isEmpty? "":
          //     moplist[datelist.length-1].firstWhere((entry) => entry['mode'] == 'Cash',orElse: () => {'amount': 'N/A'})['amount'].toString(), style: TextStyle(fontSize: 6))),
          // DataCell(Text(moplist[datelist.length-1].isEmpty? "":
          //     moplist[datelist.length-1].firstWhere((entry) => entry['mode'] == 'Bank Transfer',orElse: () => {'amount': 'N/A'})['amount'].toString(), style: TextStyle(fontSize: 6))),
          // DataCell(Text(moplist[datelist.length-1].isEmpty? "":
          //     moplist[datelist.length-1].firstWhere((entry) => entry['mode'] == 'UPI',orElse: () => {'amount': 'N/A'})['amount'].toString(), style: TextStyle(fontSize: 6))),
          // DataCell(Text(moplist[datelist.length-1].isEmpty? "":
          //     moplist[datelist.length-1].firstWhere((entry) => entry['mode'] == 'Credit',orElse: () => {'amount': 'N/A'})['amount'].toString(), style: TextStyle(fontSize: 6))),

          DataCell(Text(productnamelist[datelist.length - 1], style: TextStyle(fontSize: 6))),
          DataCell(Text(hsn[datelist.length - 1], style: TextStyle(fontSize: 6))),
          DataCell(Text(orginalbasePurchasePrice[datelist.length - 1], style: TextStyle(fontSize: 6))),
          DataCell(Text(discountAmt[datelist.length - 1], style: TextStyle(fontSize: 6))),
          DataCell(Text(basesplist[datelist.length - 1], style: TextStyle(fontSize: 6))),
          DataCell(Text(gstratelist[datelist.length - 1], style: TextStyle(fontSize: 6))),
          DataCell(Text(cgstlist[datelist.length - 1], style: TextStyle(fontSize: 6))),
          DataCell(Text(sgstlist[datelist.length - 1], style: TextStyle(fontSize: 6))),
          DataCell(Text(igstlist[datelist.length - 1], style: TextStyle(fontSize: 6))),
          // DataCell(Text(mrplist[datelist.length - 1], style: TextStyle(fontSize: 6))),
          DataCell(Text(total.toStringAsFixed(2), style: TextStyle(fontSize: 6))),
        ]));
      }
      return list;
    }
  }
  showSaleReturnReport(){
    List<DataRow> list = [];

    double total = 0;
    double basesplitTotal = 0;
    double gstrateTotal = 0;
    double cgstTotal = 0;
    double sgstTotal = 0;
    double igstTotal = 0;
    double mrpTotal = 0;

    for (int i = 0; i < datelist.length; i++) {
      if ((partynamelist[i] == partynametoFilter && partynametoFilter!="") || moplist[i].any((map)=> map['mode']==filterPaymentModeSelected) ||(partynametoFilter == "" && filterPaymentModeSelected=="")) {
        print("line 374 in report table.dart");
        if (i != datelist.length - 1 && totalsplist[i].length != 0 && totalsplist[i] != "null") total += double.parse(totalsplist[i]);

        if (i != datelist.length - 1 && basesplist[i].length != 0 && basesplist[i] != "N/A" && basesplist[i] != "null") basesplitTotal += double.parse(basesplist[i]);
        if (i != datelist.length - 1 && gstratelist[i].length != 0 && gstratelist[i] != "N/A%" && gstratelist[i] != "null%") gstrateTotal += double.parse(gstratelist[i].split("%")[0]);
        if (i != datelist.length - 1 && cgstlist[i].length != 0 && cgstlist[i] != "N/A" && cgstlist[i] != "null") cgstTotal += double.parse(cgstlist[i]);
        if (i != datelist.length - 1 && sgstlist[i].length != 0 && sgstlist[i] != "N/A" && sgstlist[i] != "null") sgstTotal += double.parse(sgstlist[i]);
        if (i != datelist.length - 1 && igstlist[i].length != 0 && igstlist[i] != "N/A" && igstlist[i] != "null") igstTotal += double.parse(igstlist[i]);
        if (i != datelist.length - 1 && mrplist[i].length != 0 && mrplist[i] != "N/A" && mrplist[i] != "null") mrpTotal += double.parse(mrplist[i]);
        list.add(DataRow(cells: [
          DataCell(Text(datelist[i], style: TextStyle(fontSize: 6))),
          DataCell(Text(timelist[i], style: TextStyle(fontSize: 6))),
          DataCell(Text(invoiceNum[i], style: TextStyle(fontSize: 6),)),
          DataCell(Text(partynamelist[i], style: TextStyle(fontSize: 6))),
          DataCell(Text(productnamelist[i], style: TextStyle(fontSize: 6))),
          DataCell(Text(hsn[i], style: TextStyle(fontSize: 6))),
          DataCell(Text(orginalbasePurchasePrice[i], style: TextStyle(fontSize: 6))),
          DataCell(Text(discountAmt[i], style: TextStyle(fontSize: 6))),
          DataCell(Text(i == datelist.length - 1 ? basesplitTotal.toStringAsFixed(2) : basesplist[i], style: TextStyle(fontSize: 6))),
          DataCell(Text(gstratelist[i], style: TextStyle(fontSize: 6))),
          DataCell(Text(i == datelist.length - 1 ? cgstTotal.toStringAsFixed(2) : cgstlist[i], style: TextStyle(fontSize: 6))),
          DataCell(Text(i == datelist.length - 1 ? sgstTotal.toStringAsFixed(2) : sgstlist[i], style: TextStyle(fontSize: 6))),
          DataCell(Text(i == datelist.length - 1 ? igstTotal.toStringAsFixed(2) : igstlist[i], style: TextStyle(fontSize: 6))),
          // DataCell(Text(i == datelist.length - 1 ? mrpTotal.toStringAsFixed(2) : mrplist[i], style: TextStyle(fontSize: 6))),
          DataCell(Text(totalsplist[i], style: TextStyle(fontSize: 6))),
        ]));
      }
    }
    if (partynametoFilter != "" || filterPaymentModeSelected!=""){
      print("line 277 in report table.dart");
      list.add(DataRow(cells: [
        DataCell(Text(datelist[datelist.length - 1], style: TextStyle(fontSize: 6))),
        DataCell(Text(timelist[datelist.length - 1], style: TextStyle(fontSize: 6))),
        DataCell(Text(invoiceNum[datelist.length - 1], style: TextStyle(fontSize: 6),)),
        DataCell(Text(partynamelist[datelist.length - 1], style: TextStyle(fontSize: 6))),
        DataCell(Text(productnamelist[datelist.length - 1], style: TextStyle(fontSize: 6))),
        DataCell(Text(hsn[datelist.length - 1], style: TextStyle(fontSize: 6))),
        DataCell(Text(orginalbasePurchasePrice[datelist.length - 1], style: TextStyle(fontSize: 6))),
        DataCell(Text(discountAmt[datelist.length - 1], style: TextStyle(fontSize: 6))),
        DataCell(Text(basesplist[datelist.length - 1], style: TextStyle(fontSize: 6))),
        DataCell(Text(gstratelist[datelist.length - 1], style: TextStyle(fontSize: 6))),
        DataCell(Text(cgstlist[datelist.length - 1], style: TextStyle(fontSize: 6))),
        DataCell(Text(sgstlist[datelist.length - 1], style: TextStyle(fontSize: 6))),
        DataCell(Text(igstlist[datelist.length - 1], style: TextStyle(fontSize: 6))),
        // DataCell(Text(mrplist[datelist.length - 1], style: TextStyle(fontSize: 6))),
        DataCell(Text(total.toString(), style: TextStyle(fontSize: 6))),
      ]));
    }
    // print("printing list in 287 in reporttable");
    // print(list[0].toString());
    return list;
  }
  showEstimateRow(){
    List<DataRow> list = [];

    double total = 0;
    double basesplitTotal = 0;
    double gstrateTotal = 0;
    double cgstTotal = 0;
    double sgstTotal = 0;
    double igstTotal = 0;
    double mrpTotal = 0;

    for (int i = 0; i < datelist.length; i++) {
      if ((partynamelist[i] == partynametoFilter && partynametoFilter!="") || moplist[i].any((map)=> map['mode']==filterPaymentModeSelected) ||(partynametoFilter == "" && filterPaymentModeSelected=="")) {
        print("line 452 in report table.dart");
        if (i != datelist.length - 1 && totalsplist[i].length != 0 && totalsplist[i] != "null") total += double.parse(totalsplist[i]);

        if (i != datelist.length - 1 && basesplist[i].length != 0 && basesplist[i] != "N/A" && basesplist[i] != "null") basesplitTotal += double.parse(basesplist[i]);
        if (i != datelist.length - 1 && gstratelist[i].length != 0 && gstratelist[i] != "N/A%" && gstratelist[i] != "null%") gstrateTotal += double.parse(gstratelist[i].split("%")[0]);
        if (i != datelist.length - 1 && cgstlist[i].length != 0 && cgstlist[i] != "N/A" && cgstlist[i] != "null") cgstTotal += double.parse(cgstlist[i]);
        if (i != datelist.length - 1 && sgstlist[i].length != 0 && sgstlist[i] != "N/A" && sgstlist[i] != "null") sgstTotal += double.parse(sgstlist[i]);
        if (i != datelist.length - 1 && igstlist[i].length != 0 && igstlist[i] != "N/A" && igstlist[i] != "null") igstTotal += double.parse(igstlist[i]);
        if (i != datelist.length - 1 && mrplist[i].length != 0 && mrplist[i] != "N/A" && mrplist[i] != "null") mrpTotal += double.parse(mrplist[i]);
        list.add(DataRow(cells: [
          DataCell(Text(datelist[i], style: TextStyle(fontSize: 6))),
          DataCell(Text(timelist[i], style: TextStyle(fontSize: 6))),
          DataCell(Text(estimateNum[i], style: TextStyle(fontSize: 6),)),
          DataCell(Text(productnamelist[i], style: TextStyle(fontSize: 6))),
          DataCell(Text(hsn[i], style: TextStyle(fontSize: 6))),
          DataCell(Text(orginalbasePurchasePrice[i], style: TextStyle(fontSize: 6))),
          DataCell(Text(discountAmt[i], style: TextStyle(fontSize: 6))),
          DataCell(Text(i == datelist.length - 1 ? basesplitTotal.toStringAsFixed(2) : basesplist[i], style: TextStyle(fontSize: 6))),
          DataCell(Text(gstratelist[i], style: TextStyle(fontSize: 6))),
          DataCell(Text(i == datelist.length - 1 ? cgstTotal.toStringAsFixed(2) : cgstlist[i], style: TextStyle(fontSize: 6))),
          DataCell(Text(i == datelist.length - 1 ? sgstTotal.toStringAsFixed(2) : sgstlist[i], style: TextStyle(fontSize: 6))),
          DataCell(Text(i == datelist.length - 1 ? igstTotal.toStringAsFixed(2) : igstlist[i], style: TextStyle(fontSize: 6))),
          // DataCell(Text(i == datelist.length - 1 ? mrpTotal.toStringAsFixed(2) : mrplist[i], style: TextStyle(fontSize: 6))),
          DataCell(Text(totalsplist[i], style: TextStyle(fontSize: 6))),
          // DataCell(Text(datelist[datelist.length - 1], style: TextStyle(fontSize: 6))),
          // DataCell(Text(timelist[datelist.length - 1], style: TextStyle(fontSize: 6))),
          // DataCell(Text(estimateNum[datelist.length - 1], style: TextStyle(fontSize: 6),)),
          // DataCell(Text(productnamelist[datelist.length - 1], style: TextStyle(fontSize: 6))),
          // DataCell(Text(hsn[datelist.length - 1], style: TextStyle(fontSize: 6))),
          // DataCell(Text(orginalbasePurchasePrice[datelist.length - 1], style: TextStyle(fontSize: 6))),
          // DataCell(Text(discountAmt[datelist.length - 1], style: TextStyle(fontSize: 6))),
          // DataCell(Text(basesplist[datelist.length - 1], style: TextStyle(fontSize: 6))),
          // DataCell(Text(gstratelist[datelist.length - 1], style: TextStyle(fontSize: 6))),
          // DataCell(Text(cgstlist[datelist.length - 1], style: TextStyle(fontSize: 6))),
          // DataCell(Text(sgstlist[datelist.length - 1], style: TextStyle(fontSize: 6))),
          // DataCell(Text(igstlist[datelist.length - 1], style: TextStyle(fontSize: 6))),
          // DataCell(Text(mrplist[datelist.length - 1], style: TextStyle(fontSize: 6))),
          // DataCell(Text(total.toString(), style: TextStyle(fontSize: 6))),
        ]));
      }
    }
    return list;
  }

  showPurchaseRow() {
    double total = 0;
    double basesplitTotal = 0;
    double gstrateTotal = 0;
    double cgstTotal = 0;
    double sgstTotal = 0;
    double igstTotal = 0;
    double mrpTotal = 0;

    List<DataRow> list = [];
    double totalCash = 0;
    double totalUPI = 0;
    double totalCredit = 0;
    double totalBankTransfer = 0;

    Set<String> uniqueIds = Set();//since this report table shows one row for each product so moplist may contain multiple same mop object with same ids
    //so discarding them and adding to totalCash, totalUPI ... etc.

    for (var sublist in moplist) {
      for (var entry in sublist) {
        if (entry.containsKey("mode") &&
            entry.containsKey("amount") &&
            entry.containsKey("_id")) {
          String id = entry["_id"];
          if (!uniqueIds.contains(id)) {
            double amount = entry["amount"].toDouble();
            switch (entry["mode"]) {
              case "Cash":
                totalCash += amount;
                break;
              case "UPI":
                totalUPI += amount;
                break;
              case "Credit":
                totalCredit += amount;
                break;
              case "Bank Transfer":
                totalBankTransfer += amount;
                break;
              default:
                break;
            }
            uniqueIds.add(id);
          }
        }
      }
    }

    String totalMop = "Cash: ${totalCash.toStringAsFixed(2)}, UPI: ${totalUPI.toStringAsFixed(2)}, Bank: ${totalBankTransfer.toStringAsFixed(2)}, Credit: ${totalCredit.toStringAsFixed(2)}";

    /* adding cells in the report table */
    for (int index = 0; index < datelist.length; index++) {
      if ((partynamelist[index] == partynametoFilter && partynametoFilter!="") || moplist[index].any((map)=> map['mode']==filterPaymentModeSelected) ||(partynametoFilter == "" && filterPaymentModeSelected=="")) {
        if (index != datelist.length - 1 && totalsplist[index].length != 0) total += double.parse(totalsplist[index]);

        if (index != datelist.length - 1 && basesplist[index].length != 0 && basesplist[index] != "N/A" && basesplist[index] != "null") basesplitTotal += double.parse(basesplist[index]);
        if (index != datelist.length - 1 && gstratelist[index].length != 0 && gstratelist[index] != "N/A%" && basesplist[index] != "null") gstrateTotal += double.parse(gstratelist[index].split("%")[0]);
        if (index != datelist.length - 1 && cgstlist[index].length != 0 && cgstlist[index] != "N/A" && basesplist[index] != "null") cgstTotal += double.parse(cgstlist[index]);
        if (index != datelist.length - 1 && sgstlist[index].length != 0 && sgstlist[index] != "N/A" && basesplist[index] != "null") sgstTotal += double.parse(sgstlist[index]);
        if (index != datelist.length - 1 && igstlist[index].length != 0 && igstlist[index] != "N/A" && basesplist[index] != "null") igstTotal += double.parse(igstlist[index]);
        if (index != datelist.length - 1 && mrplist[index].length != 0 && mrplist[index] != "N/A" && basesplist[index] != "null") mrpTotal += double.parse(mrplist[index]);

        list.add(DataRow(cells: [
          DataCell(Text(datelist[index], style: TextStyle(fontSize: 6))),
          DataCell(Text(timelist[index], style: TextStyle(fontSize: 6))),
          DataCell(Text(partynamelist[index], style: TextStyle(fontSize: 6))),
          DataCell(Text(index == datelist.length - 1 ? totalMop :
              moplist[index].map((map) => "${map['mode'] ?? "N/A"} : ${map['amount'] ?? ""}").join(', '), style: TextStyle(fontSize: 6))),
          DataCell(Text(productnamelist[index], style: TextStyle(fontSize: 6))),
          DataCell(Text(hsn[index], style: TextStyle(fontSize: 6))),
          DataCell(Text(orginalbasePurchasePrice[index], style: TextStyle(fontSize: 6))),
          DataCell(Text(discountAmt[index], style: TextStyle(fontSize: 6))),
          DataCell(Text(index == datelist.length - 1 ? basesplitTotal.toStringAsFixed(2) : basesplist[index], style: TextStyle(fontSize: 6))),
          DataCell(Text(gstratelist[index], style: TextStyle(fontSize: 6))),
          DataCell(Text(index == datelist.length - 1 ? cgstTotal.toStringAsFixed(2) : cgstlist[index], style: TextStyle(fontSize: 6))),
          DataCell(Text(index == datelist.length - 1 ? sgstTotal.toStringAsFixed(2) : sgstlist[index], style: TextStyle(fontSize: 6))),
          DataCell(Text(index == datelist.length - 1 ? igstTotal.toStringAsFixed(2) : igstlist[index], style: TextStyle(fontSize: 6))),
          // DataCell(Text(index == datelist.length - 1 ? mrpTotal.toStringAsFixed(2) : mrplist[index], style: TextStyle(fontSize: 6))),
          DataCell(Text(totalsplist[index], style: TextStyle(fontSize: 6))),
        ]));
      }
    }

    if (partynametoFilter != "" || filterPaymentModeSelected!="")
      list.add(DataRow(cells: [
        DataCell(Text(datelist[datelist.length - 1], style: TextStyle(fontSize: 6))),
        DataCell(Text(timelist[datelist.length - 1], style: TextStyle(fontSize: 6))),
        DataCell(Text(partynamelist[datelist.length - 1], style: TextStyle(fontSize: 6))),
        DataCell(Text(moplist[datelist.length - 1].map((map) => "${map['mode'] ?? "N/A"} : ${map['amount'] ?? ""}")
            .join(', '), style: TextStyle(fontSize: 6))),
        DataCell(Text(productnamelist[datelist.length - 1], style: TextStyle(fontSize: 6))),
        DataCell(Text(hsn[datelist.length-1], style: TextStyle(fontSize: 6))),
        DataCell(Text(orginalbasePurchasePrice[datelist.length-1], style: TextStyle(fontSize: 6))),
        DataCell(Text(gstratelist[datelist.length-1], style: TextStyle(fontSize: 6))),
        DataCell(Text(cgstlist[datelist.length-1], style: TextStyle(fontSize: 6))),
        DataCell(Text(sgstlist[datelist.length-1], style: TextStyle(fontSize: 6))),
        DataCell(Text(igstlist[datelist.length-1], style: TextStyle(fontSize: 6))),
        // DataCell(Text(mrplist[datelist.length-1], style: TextStyle(fontSize: 6))),
        DataCell(Text("", style: TextStyle(fontSize: 6))),
        DataCell(Text(" ", style: TextStyle(fontSize: 6))),
        DataCell(Text(total.toStringAsFixed(2), style: TextStyle(fontSize: 6))),
      ]));
    return list;
  }

  showExpenseRow() {
    double total = 0;
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
    double productQTYTotal = 0;
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
        DataCell(Text("${product.quantity?.toStringAsFixed(2)}", style: TextStyle(fontSize: 6))),
        DataCell(Text("${salesValue.toStringAsFixed(2)}", style: TextStyle(fontSize: 6))),
        DataCell(Text("$purchaseValue", style: TextStyle(fontSize: 6))),
        DataCell(Text("${(salesValue - purchaseValue).toStringAsFixed(2)}", style: TextStyle(fontSize: 6))),
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
      print("line 430 in report table");
      // print(e.estimateNum);
      return e.orderItems!.map((OrderItemInput item) {
        // print(e.user!.type);
        taxfileType = e.user?.type ?? "notdone";
        if (breakruler != DateFormat('hh:mm a').format(DateTime.tryParse(e.createdAt.toString())!)) {
          datelist.add("");
          timelist.add("");
          estimateNum.add("");
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
          moplist.add([]);
        }
        datelist.add(DateFormat('dd MMM, yyyy').format(DateTime.tryParse(e.createdAt.toString())!));
        timelist.add(DateFormat('hh:mm a').format(DateTime.tryParse(e.createdAt.toString())!));
        partynamelist.add(e.party?.name ?? "N/A");
        productnamelist.add("${item.quantity} x ${item.product?.name ?? ""}");
        gstratelist.add("${item.product?.gstRate == "null" || item.product?.gstRate == null ? "N/A" : (item.product?.gstRate != "null" ? item.product?.gstRate : "N/A")}%");
        widget.args.type == "ReportType.sale" || widget.args.type == "ReportType.estimate"
            ? basesplist.add(
            "${item.baseSellingPrice != "null" ? (double.parse(item.baseSellingPrice!) * item.quantity).toStringAsFixed(2) : (item.product?.baseSellingPriceGst != "null" && item.product?.baseSellingPriceGst != null ? (double.parse(item.product!.baseSellingPriceGst!) * item.quantity).toStringAsFixed(2) : "N/A")}")
            : basesplist.add("${item.product?.basePurchasePriceGst == "null" ? "N/A" : (double.parse(item.product!.basePurchasePriceGst!) * item.quantity).toStringAsFixed(2)}");
        widget.args.type == "ReportType.sale"|| widget.args.type == "ReportType.estimate"
            ? cgstlist.add("${item.saleCGST != "null" ? (double.parse(item.saleCGST!)*(item.quantity)).toStringAsFixed(2) : (item.product?.salecgst != "null" ? item.product?.salecgst : "N/A")}")
            : cgstlist.add("${item.product?.purchasecgst == "null" ? "N/A" : item.product?.purchasecgst}");
        widget.args.type == "ReportType.sale"|| widget.args.type == "ReportType.estimate"
            ? sgstlist.add("${item.saleSGST != "null" ? (double.parse(item.saleSGST!)* (item.quantity)).toStringAsFixed(2) : (item.product?.salesgst != "null" && item.product?.salesgst != null? (double.parse(item.product!.salesgst!)*(item.quantity)) : "N/A")}")
            : sgstlist.add("${item.product?.purchasesgst == "null" ? "N/A" : item.product?.purchasesgst}");
        widget.args.type == "ReportType.sale"|| widget.args.type == "ReportType.estimate"
            ? igstlist.add("${item.saleIGST != "null" ? (double.parse(item.saleIGST!) * (item.quantity)).toStringAsFixed(2) : (item.product?.saleigst != "null" && item.product?.saleigst != null ? (double.parse(item.product!.saleigst!)*(item.quantity)) : "N/A")}")
            : igstlist.add("${item.product?.purchaseigst == "null" ? "N/A" : item.product?.purchaseigst}");
        widget.args.type == "ReportType.sale" || widget.args.type == "ReportType.estimate"
            ? mrplist.add("${item.price?.toStringAsFixed(2)}") : mrplist.add("${item.product?.purchasePrice == "null" || item.product?.purchasePrice == null ? "N/A" : item.product?.purchasePrice}");
        hsn.add("${item.product?.hsn == "null" || item.product?.hsn == null ? "N/A" : item.product?.hsn}");
        discountAmt.add("${item.discountAmt == "null" ? "N/A" : item.discountAmt}");

        invoiceNum.add("${e.invoiceNum == null ? "N/A" : e.invoiceNum}");
        estimateNum.add("${e.estimateNum == null? "N/A": e.estimateNum}");
        orginalbasePurchasePrice.add(item.product?.sellingPrice=="null" || item.product?.sellingPrice==null ? "N/A" : "${item.product?.sellingPrice}");
        widget.args.type == "ReportType.sale" || widget.args.type == "ReportType.estimate"
            ? totalsplist.add("${((item.quantity) * (item.price ?? 0)).toStringAsFixed(2)}") : totalsplist.add("${((item.quantity) * (item.product?.purchasePrice ?? 0)).toStringAsFixed(2)}");

        moplist.add(e.modeOfPayment ?? [{"N/A":0}]);
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
    return sum.toStringAsFixed(2);
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
  saleReturnExcelReport() async{
    final headersSaleReturn = [
      'Date',
      'Time',
      'Invoice No',
      'Party',
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

    for (int i = 1; i <= headersSaleReturn.length; i++) {
      sheet.getRangeByIndex(1, i).setText(headersSaleReturn[i - 1]);
    }
    for (int i = 0; i < datelist.length; i++) {
      sheet.getRangeByIndex(i + 2, 1).setText(datelist[i] ?? '');
      sheet.getRangeByIndex(i + 2, 2).setText(timelist[i]);
      sheet.getRangeByIndex(i + 2, 3).setText(invoiceNum[i]);
      sheet.getRangeByIndex(i + 2, 4).setText(partynamelist[i]);
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




    final List<int> bytes = workbook.saveAsStream();
    final directory = await getApplicationDocumentsDirectory();
    File excelFileLocal = File('${directory.path}/SaleReturn.xlsx');
    await excelFileLocal.writeAsBytes(bytes);

    Share.shareFiles(
      [excelFileLocal.path],
      mimeTypes: ['application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'],
    );

    workbook.dispose();
  }
  saleExcelReport() async {
    print('line 509 in report_table.dart');
    final headersSP = [
      'Date',
      'Time',
      'invoice No',
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
        sheet.getRangeByIndex(i + 2, 3).setText(invoiceNum[i]);
        sheet.getRangeByIndex(i + 2, 4).setText(partynamelist[i]);
        sheet.getRangeByIndex(i + 2, 5).setText(moplist[i].map((map) => "${map['mode'] ?? "N/A"} : ${map['amount'] ?? ""}")
            .join(', '));
        sheet.getRangeByIndex(i + 2, 6).setText(productnamelist[i]);
        sheet.getRangeByIndex(i + 2, 7).setText(mrplist[i]);
        sheet.getRangeByIndex(i + 2, 8).setText(totalsplist[i]);
      } else {
        sheet.getRangeByIndex(i + 2, 1).setText(datelist[i] ?? '');
        sheet.getRangeByIndex(i + 2, 2).setText(timelist[i]);
        sheet.getRangeByIndex(i + 2, 3).setText(invoiceNum[i]);
        sheet.getRangeByIndex(i + 2, 4).setText(partynamelist[i]);
        sheet.getRangeByIndex(i + 2, 5).setText(moplist[i].map((map) => "${map['mode'] ?? "N/A"} : ${map['amount'] ?? ""}")
            .join(', '));
        sheet.getRangeByIndex(i + 2, 6).setText(productnamelist[i]);
        sheet.getRangeByIndex(i + 2, 7).setText(hsn[i]);
        sheet.getRangeByIndex(i + 2, 8).setText(orginalbasePurchasePrice[i]);
        sheet.getRangeByIndex(i + 2, 9).setText(discountAmt[i]);
        sheet.getRangeByIndex(i + 2, 10).setText(basesplist[i]);
        sheet.getRangeByIndex(i + 2, 11).setText(gstratelist[i]);
        sheet.getRangeByIndex(i + 2, 12).setText(cgstlist[i]);
        sheet.getRangeByIndex(i + 2, 13).setText(sgstlist[i]);
        sheet.getRangeByIndex(i + 2, 14).setText(igstlist[i]);
        sheet.getRangeByIndex(i + 2, 15).setText(mrplist[i]);
        sheet.getRangeByIndex(i + 2, 16).setText(totalsplist[i]);
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
  estimateExcelReport() async {
    final headersEstimate = [
      'Date',
      'Time',
      'Estimate No',
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

    for (int i = 1; i <= headersEstimate.length; i++) {
      sheet.getRangeByIndex(1, i).setText(headersEstimate[i - 1]);
    }
    for (int i = 0; i < datelist.length; i++) {
      sheet.getRangeByIndex(i + 2, 1).setText(datelist[i] ?? '');
      sheet.getRangeByIndex(i + 2, 2).setText(timelist[i]);
      sheet.getRangeByIndex(i + 2, 3).setText(estimateNum[i]);
      sheet.getRangeByIndex(i + 2, 4).setText(productnamelist[i]);
      sheet.getRangeByIndex(i + 2, 5).setText(hsn[i]);
      sheet.getRangeByIndex(i + 2, 6).setText(orginalbasePurchasePrice[i]);
      sheet.getRangeByIndex(i + 2, 7).setText(discountAmt[i]);
      sheet.getRangeByIndex(i + 2, 8).setText(basesplist[i]);
      sheet.getRangeByIndex(i + 2, 9).setText(gstratelist[i]);
      sheet.getRangeByIndex(i + 2, 10).setText(cgstlist[i]);
      sheet.getRangeByIndex(i + 2, 11).setText(sgstlist[i]);
      sheet.getRangeByIndex(i + 2, 12).setText(igstlist[i]);
      sheet.getRangeByIndex(i + 2, 13).setText(mrplist[i]);
      sheet.getRangeByIndex(i + 2, 14).setText(totalsplist[i]);
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
        sheet.getRangeByIndex(i + 2, 4).setText(moplist[i].map((map) => "${map['mode'] ?? "N/A"} : ${map['amount'] ?? ""}")
            .join(', '));
        sheet.getRangeByIndex(i + 2, 5).setText(productnamelist[i]);
        sheet.getRangeByIndex(i + 2, 6).setText(mrplist[i]);
        sheet.getRangeByIndex(i + 2, 7).setText(totalsplist[i]);
      } else {
        sheet.getRangeByIndex(i + 2, 1).setText(datelist[i] ?? '');
        sheet.getRangeByIndex(i + 2, 2).setText(timelist[i]);
        sheet.getRangeByIndex(i + 2, 3).setText(partynamelist[i]);
        sheet.getRangeByIndex(i + 2, 4).setText(moplist[i].map((entry) {
          String mode = entry["mode"];
          int amount = entry["amount"];
          return "$mode: $amount";
        }).join(", "));
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
        centerTitle: true,
        title: widget.args.type == "ReportType.sale"
            ? Text("Sale Report")
            : widget.args.type == "ReportType.purchase"
            ? Text("Purchase Report")
            : widget.args.type == "ReportType.expense"
            ? Text("Expense Report")
            : widget.args.type == "ReportType.estimate"
            ? Text("Estimate Report")
            : widget.args.type == "ReportType.saleReturn"
            ? Text("Sale Return Report")
            : Text("Stock Report"),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'edit' && (widget.args.type == "ReportType.estimate" || widget.args.type == "ReportType.sale")) {
                _goToEstimateDialog();
              } else if (value == 'filter' &&
                  (widget.args.type != "ReportType.stock" &&
                      widget.args.type != "ReportType.expense" &&
                      widget.args.type != "ReportType.estimate")) {
                _showFilterDialog();
              } else if (value == 'share') {
                if (widget.args.type == "ReportType.sale") {
                  saleExcelReport();
                } else if (widget.args.type == "ReportType.purchase") {
                  PurchaseExcelReport();
                } else if (widget.args.type == "ReportType.expense") {
                  ExpenseExcelReport();
                } else if (widget.args.type == "ReportType.estimate") {
                  estimateExcelReport();
                } else if (widget.args.type == "ReportType.saleReturn") {
                  saleReturnExcelReport();
                } else {
                  STOCKExcelReport();
                }
              } else if(value == 'Kot history' && widget.args.type == "ReportType.sale"){
                _showKotHistoryDialog();
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              if (widget.args.type == "ReportType.sale")
                PopupMenuItem<String>(
                  value: 'Kot history',
                  child: Row(
                    children: <Widget>[
                      Icon(Icons.print),
                      SizedBox(width: 8),
                      Text('Kot history'),
                    ],
                  ),
                ),
              if (widget.args.type == "ReportType.estimate" || widget.args.type == "ReportType.sale")
              PopupMenuItem<String>(
                  value: 'edit',
                  child: Row(
                    children: <Widget>[
                      Icon(Icons.edit),
                      SizedBox(width: 8),
                      Text('Edit'),
                    ],
                  ),
                ),
              if (widget.args.type != "ReportType.stock" &&
                  widget.args.type != "ReportType.expense" &&
                  widget.args.type != "ReportType.estimate")
                PopupMenuItem<String>(
                  value: 'filter',
                  child: Row(
                    children: <Widget>[
                      Icon(Icons.filter_alt),
                      SizedBox(width: 8),
                      Text('Filter'),
                    ],
                  ),
                ),
              PopupMenuItem<String>(
                value: 'share',
                child: Row(
                  children: <Widget>[
                    Icon(Icons.share),
                    SizedBox(width: 8),
                    Text('Share'),
                  ],
                ),
              ),
            ],
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
                      : widget.args.type == "ReportType.estimate"
                      ? showEstimateRow()
                      : widget.args.type == "ReportType.saleReturn"
                      ? showSaleReturnReport()
                      : showStockRow()),
            ),
          ),
        ),
      ),
    );
  }

  _goToEstimateDialog(){
    return showDialog(context: context,barrierDismissible: true, builder: (ctx){
      return AlertDialog(
        title: widget.args.type=="ReportType.estimate"
            ? Text("Go to Estimate") : Text("Go to Sale"),
        content: Container(
          height: 150,
          child: Column(
            children: [
              TextFormField(
                controller: estimateNumController,
                maxLines: 1,
                keyboardType:
                TextInputType.numberWithOptions(
                    signed: false, decimal: true),
                decoration: InputDecoration(
                    label: widget.args.type=="ReportType.estimate"
                        ? Text("Enter Estimate no") : Text("Enter Invoice no"),
                    border: OutlineInputBorder(
                        borderRadius:
                        BorderRadius.circular(10))),
                validator: (e) {
                  if (e!.contains(",")) {
                    return '(,) character are not allowed';
                  }
                  if (e.isNotEmpty) if (double.parse(e) >
                      99999.0) {
                    return 'Maximum value is 99999';
                  }
                  return null;
                },
              ),
              CustomButton(title: "  Submit  ", onTap: () async {
                goToEstimate();
              })
            ],
          ),
        ),
      );
    }) ;
  }

  _showKotHistoryDialog(){
    return showDialog(context: context,barrierDismissible: true, builder: (ctx){
      return AlertDialog(
        title: Text("Enter Invoice no."),
        content: Container(
          height: 150,
          child: Column(
            children: [
              TextFormField(
                controller: invoiceNumController,
                maxLines: 1,
                keyboardType:
                TextInputType.numberWithOptions(
                    signed: false, decimal: true),
                decoration: InputDecoration(
                    label: Text("Invoice no"),
                    border: OutlineInputBorder(
                        borderRadius:
                        BorderRadius.circular(10))),
                validator: (e) {
                  if (e!.contains(",")) {
                    return '(,) character are not allowed';
                  }
                  if (e.isNotEmpty) if (double.parse(e) >
                      99999.0) {
                    return 'Maximum value is 99999';
                  }
                  return null;
                },
              ),
              CustomButton(title: "  Submit  ", onTap: () async {
                kotHistory();
              })
            ],
          ),
        ),
      );
    }) ;
  }

  kotHistory() async {
    Map<String, dynamic> salesResponse = await SalesService.getSingleSaleOrder(invoiceNumController.text);
    Order order = Order.fromMap(salesResponse['salesOrder']);
    print("order.kotId is ${order.kotId.runtimeType}");
    if(order.kotId != 'null'){
      Navigator.pop(context);
      _showKotHistory(order.kotId!);
    }else{
      Navigator.pop(context);
      locator<GlobalServices>().infoSnackBar("kot id not available");
    }
  }
  _showKotHistory(String kotId) async {
    Map<String, dynamic> kotHistory = await KOTService.getKot(kotId);
    Kot kot = Kot.fromMap(kotHistory['kot']);
    return showModalBottomSheet(
      isScrollControlled: true,
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      context: context,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 5,
                blurRadius: 7,
                offset: Offset(0, 3), // changes position of shadow
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 20, left: 20, right: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  height: 4,
                  width: 40,
                  margin: EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Text(
                  "KOT History",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                SingleChildScrollView(
                  child: Column(
                    children: [
                      ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: kot.items?.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Container(
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if (kot.items?[index].name == "Printed")
                                      Icon(Icons.print),
                                    kot.items?[index].name == "Printed"
                                        ? Text(" KOT Printed at",style: TextStyle(fontSize: 16),)
                                        : Text('${kot.items?[index].name} x ${kot.items?[index].quantity}',style: TextStyle(fontSize: 16),),
                                    SizedBox(width: 5),
                                    currentdate(kot.items![index].createdAt!),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      )
                    ],
                  ),
                ),
                if(kot.items!.length < 5) SizedBox(height: 50),
              ],
            ),
          ),
        );
      },
    );

  }
  Widget currentdate(DateTime createdAt) {
    var datereq = DateFormat.MMMM().format(createdAt);

    final String _inputTime = '${createdAt.hour}:${createdAt.minute}';
    final DateFormat _inputFormat = DateFormat('HH:mm');
    final DateFormat _outputFormat = DateFormat('h:mm a');

    DateTime inputDateTime = _inputFormat.parse(_inputTime);
    String outputTime = _outputFormat.format(inputDateTime);

    String pmAmFlag = "AM";

    if (createdAt.hour >= 13) {
      pmAmFlag = "PM";
    } else {
      pmAmFlag = "AM";
    }
    return Text(
      '${createdAt.day.toString()}.${createdAt.month.toString()}.${createdAt.year.toString()} | $outputTime',
      style: const TextStyle(color: Colors.black45, fontSize: 13),
    );
  }
  goToEstimate() async {
    if(widget.args.type == "ReportType.estimate"){
      Map<String,dynamic> estimateResponse = await EstimateService.getEstimate(estimateNumController.text);
      print("line 1106 in report table");
      print(estimateResponse['estimate']['_id']);
      Order orders = Order.fromMap(estimateResponse['estimate']);
      Navigator.pushNamed(context, CreateEstimate.routeName,arguments: EstimateBillingPageArgs(order: orders, editFlag: true));
    }else if(widget.args.type == "ReportType.sale"){
      Map<String, dynamic> salesResponse = await SalesService.getSingleSaleOrder(estimateNumController.text);
      Order order = Order.fromMap(salesResponse['salesOrder']);

      Navigator.pushNamed(context, CheckoutPage.routeName, arguments: CheckoutPageArgs(invoiceType: OrderType.sale, order: order, canEdit: false));

    }

  }

  _showFilterDialog(){
    return showDialog(
      context: context,
      builder: (context){
        return AlertDialog(
          title: Text("Select Filter Type: "),
          content: Container(
            height: 150,
            child: Column(
              children: [
                InkWell(
                  onTap: (){
                    Navigator.pop(context);
                    _showFilterByPartyDialog();
                  },
                  child: Card(
                    elevation: 1,
                    child: ListTile(
                      leading: Icon(Icons.people),
                      title: Text("Party"),
                    ),
                  ),
                ),
                if(widget.args.type != "ReportType.saleReturn")
                InkWell(
                  onTap: (){
                    Navigator.pop(context);
                    _showFilterByPaymentModeDialog();
                  },
                  child: Card(
                    elevation: 1,
                    child: ListTile(
                      leading: Icon(Icons.payment),
                      title: Text("Payment Mode"),
                    ),
                  ),
                )
              ],
            ),
          ),
          actions: [
            if(filterPaymentModeSelected!="" || partynametoFilter!="")
              TextButton(
                  onPressed: (){
                      filterPaymentModeSelected="";
                      partynametoFilter="";
                    setState(() {
                    });
                      Navigator.pop(context);
                  },
                  child: Text('Remove Filter')),
            TextButton(
                onPressed: () {
                  Navigator.pop(context, false);
                },
                child: Text('Cancel')),
          ],
        );
      },

    );
  }

  _showFilterByPaymentModeDialog(){
    filterPaymentModeSelected="";
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context){
          return AlertDialog(
            title: Text("Select Payment Method to filter"),
            content: Container(
              child: CustomDropDownField(
                items: const ['Cash', 'Bank Transfer','UPI','Credit'],
                onSelected: (e) {
                  partynametoFilter="";
                  filterPaymentModeSelected=e;
                  setState(() {


                  });
                },
                hintText: 'Payment Mode',
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context, false);
                  },
                  child: Text('Cancel')),
              TextButton(
                  onPressed: () {
                    // setState(() {
                    //   filterPaymentModeSelected = "";
                    // });
                    if(filterPaymentModeSelected.isEmpty){
                      return locator<GlobalServices>().errorSnackBar("Please select a payment mode");
                    }else{
                      Navigator.pop(context, false);
                    }

                  },
                  child: Text(
                    'Submit',
                  )),
            ],
          );
        }
    );
  }

  Future<bool?> _showFilterByPartyDialog() {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          title: Row(
            children: [
              Text('Enter party name to filter'),
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
              print("------------line 948 in report_table.dart");
              filterPaymentModeSelected="";
              setState(() {
                partynametoFilter = party.name ?? "";
                print(partynametoFilter);
                _typeAheadController.text = party.name ?? "";
                Navigator.pop(ctx, false);
              });
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
