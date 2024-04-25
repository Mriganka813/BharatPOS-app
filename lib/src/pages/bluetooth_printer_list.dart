// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:ui';
// import 'package:esc_pos_utils_plus/esc_pos_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:provider/provider.dart';

import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:shopos/src/pages/billing_list.dart';
import 'package:shopos/src/pages/checkout.dart';
import 'package:shopos/src/services/LocalDatabase.dart';
import 'package:shopos/src/services/billing_service.dart';
import 'package:shopos/src/widgets/custom_text_field2.dart';

import '../models/input/kot_model.dart';
import '../provider/billing_order.dart';
import '../services/kot_services.dart';

class CombineArgs {
  BluetoothArgs? bluetoothArgs;
  PrintBillArgs? billArgs;
  CombineArgs({
    this.bluetoothArgs,
    this.billArgs,
  });
}

class BluetoothPrinterList extends StatefulWidget {
  static const routeName = '/bluetooth-printers';
  BluetoothPrinterList({Key? key, required this.args}) : super(key: key);

  final CombineArgs args;

  @override
  State<BluetoothPrinterList> createState() => _BluetoothPrinterListState();
}

class _BluetoothPrinterListState extends State<BluetoothPrinterList> {
  // List<BluetoothDevice> _devices = [];
  List<BluetoothInfo> _devices = [];
  String _deviceMsg = "";
  TextEditingController tableNoController = TextEditingController();
  @override
  void initState() {
    super.initState();
    // var order = widget.args.bluetoothArgs?.order;
    // print('\n\n\nName : ${((order?.subUserName != null && order?.subUserName != "" && order?.subUserName != "null") ? order?.subUserName : (order?.userName != null && order?.userName != "" && order?.userName != "null" ? order?.userName : order?.businessName))}\n\n\n');
    // print('Table no : ${tableNoController.text}');
    // print(widget.args.billArgs?.user.address.toString());
    // List<String>? addressRows() => widget.args.billArgs?.user.address
    //     ?.toString()
    //     .split(',')
    //     .map((e) =>
    // '${e.replaceAll('{', '').replaceAll('}', '').replaceAll('[', '').replaceAll(']', '').replaceAll(',', '').replaceAll('locality:', '').replaceAll('city:', '').replaceAll('state:', '').replaceAll('country:', '')}')
    //     .toList();
    //
    // for(int i = 0; i < addressRows()!.length; i++) {
    //   print("${addressRows()!.elementAt(i)}");
    // }
    // init();
    getpermission();
    getDevices();
    // WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
    //   initPrinter();
    // });
    // Timer.periodic(Duration(seconds: 10), (timer) {
    //   initPrinter();

    // });

    if (widget.args.billArgs == null) {
      if (widget.args.bluetoothArgs!.order.tableNo != "-1")
        if(widget.args.bluetoothArgs!.order.tableNo!='null')
        tableNoController.text = widget.args.bluetoothArgs!.order.tableNo;
      // print(widget.args.bluetoothArgs!.order.tableNo);
    }
  }

  getDevices() async {
    final bool result = await PrintBluetoothThermal.bluetoothEnabled;
    _devices = await PrintBluetoothThermal.pairedBluetooths;
    await Future.forEach(_devices, (BluetoothInfo bluetooth) {
      String name = bluetooth.name;
      String mac = bluetooth.macAdress;
    });
    setState(() {});
    if(widget.args.bluetoothArgs!=null){
      final bargs = widget.args.bluetoothArgs!;
      // List<Map<String, dynamic>> list =
      // await DatabaseHelper().getKotData( bargs.order.id!  );
      // print("Kot Data:");
      // print(list);
    }
    // if(widget.args.bluetoothArgs!=null){
    //   final bargs = widget.args.bluetoothArgs!;
    //   List<Map<String, dynamic>> list =
    // }

  }

  // Future<void> initPrinter() async {
  //   await bluetoothPrint.startScan(timeout: Duration(seconds: 5));
  //   if (!mounted) return;
  //   bluetoothPrint.scanResults.listen((val) {
  //     if (!mounted) return;
  //     print(val);
  //     setState(() {
  //       _devices = val;
  //       if (_devices.isEmpty) {
  //         _deviceMsg = "No devices found";
  //       }
  //     });
  //   });
  //   await bluetoothPrint.stopScan();
  // }

  void getpermission() async {
    try {
      await Permission.bluetoothScan.request();
      if (await Permission.bluetoothScan.isDenied) {
        Navigator.of(context).pop();
      }

      await Permission.bluetoothAdvertise.request();

      await Permission.ignoreBatteryOptimizations;

      if (await Permission.bluetooth.request().isDenied) {
        Navigator.of(context).pop();
      }

      await Permission.bluetoothConnect.request();
      if (await Permission.bluetooth.status.isDenied) {
        Navigator.of(context).pop();
      }

      await Permission.locationWhenInUse.request();
      if (await Permission.location.status.isDenied) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      print(e.toString());
    }
  }

  // Future<void> getBluetooth() async {
  //   final List bluetooths = await BluetoothThermalPrinter.getBluetooths ?? [];
  //   if (!mounted) return;
  //   print("Print ${bluetooths}");
  //   setState(() {
  //     if (!mounted) return;
  //     _devices = bluetooths;
  //     if (_devices.isEmpty) {
  //       _deviceMsg = "No devices found";
  //     }
  //   });
  // }

  // Function to print PDF via Bluetooth
  // Future<void> printPdfViaBluetooth(BluetoothDevice device) async {
  //   if (device != null && device.address != null) {
  //     var isconnect = await bluetoothPrint.connect(device);
  //     print(device);
  //     print(isconnect);

  //     String dateFormat() => DateFormat('MMM d, y hh:mm:ss a')
  //         .format(widget.bluetoothArgs.dateTime);

  //     Map<String, dynamic> config = Map();
  //     List<LineText> list = [];

  //     list.add(LineText(
  //       type: LineText.TYPE_TEXT,
  //       content: "KOT",
  //       weight: 2,
  //       width: 2,
  //       height: 2,
  //       align: LineText.ALIGN_CENTER,
  //       linefeed: 1,
  //     ));

  //     list.add(LineText(
  //       type: LineText.TYPE_TEXT,
  //       content: dateFormat(),
  //       weight: 1,
  //       align: LineText.ALIGN_CENTER,
  //       linefeed: 1,
  //     ));

  //     list.add(LineText(
  //       type: LineText.TYPE_TEXT,
  //       content: 'Table',
  //       weight: 1,
  //       width: 2,
  //       height: 2,
  //       align: LineText.ALIGN_CENTER,
  //       linefeed: 1,
  //     ));

  //     list.add(LineText(
  //       content: 'Item',
  //       type: LineText.TYPE_TEXT,
  //       weight: 0,
  //       align: LineText.ALIGN_LEFT,
  //     ));

  //     list.add(LineText(
  //       content: 'Qty',
  //       type: LineText.TYPE_TEXT,
  //       weight: 0,
  //       align: LineText.ALIGN_RIGHT,
  //       linefeed: 1,
  //     ));

  //     for (var i = 0;
  //         i < widget.bluetoothArgs.Order.orderItems!.length;
  //         i++) {
  //       list.add(LineText(
  //         content: widget.bluetoothArgs.Order.orderItems![i].product!.name,
  //         type: LineText.TYPE_TEXT,
  //         weight: 0,
  //         align: LineText.ALIGN_LEFT,
  //       ));

  //       list.add(LineText(
  //         content: widget.bluetoothArgs.Order.orderItems![i].quantity
  //             .toString(),
  //         type: LineText.TYPE_TEXT,
  //         weight: 0,
  //         align: LineText.ALIGN_RIGHT,
  //         linefeed: 1,
  //       ));
  //     }

  //     // if (device.connected == null) {
  //     //   await bluetoothPrint.connect(device);
  //     // }
  //     print('0=${device.address}');
  //     print(isconnect);

  //     // await bluetoothPrint.printLabel(config, list);
  //     // await bluetoothPrint.disconnect();

  //     bluetoothPrint.state.listen((event) async {
  //       print(BluetoothPrint.CONNECTED);
  //       print(BluetoothPrint.DISCONNECTED);
  //       print(BluetoothPrint.NAMESPACE);
  //       print(isconnect);
  //       print(event);
  //       switch (event) {
  //         case BluetoothPrint.CONNECTED:
  //           print(BluetoothPrint.CONNECTED);
  //           await bluetoothPrint.printReceipt(config, list);
  //         // await bluetoothPrint.disconnect();
  //       }
  //     });
  //   }
  // }

  Future<void> printKot(String mac) async {
    final bool result =
        await PrintBluetoothThermal.connect(macPrinterAddress: mac);
    bool conecctionStatus = await PrintBluetoothThermal.connectionStatus;
    if (conecctionStatus) {
      List<int> ticket = await kotTicket();
      final result = await PrintBluetoothThermal.writeBytes(ticket);
      print("print result: $result");
    } else {
      //no connected
    }
  }
  Future<List<Map<String, dynamic>>> getKotData(String kotId) async {
    Map<String, dynamic> kotHistory = await KOTService.getKot(kotId);
    Kot kot = Kot.fromMap(kotHistory['kot']);
    print("kot.items ${kotHistory['kot']['item']}");
    List<Map<String, dynamic>> itemList = [];

// Iterate through kot.items in reverse order
    for (int i = kot.items!.length - 1; i >= 0; i--) {
      Map<String, dynamic> item = kotHistory['kot']['item'][i];

      // Check if the item name is "Printed"
      if (item['name'] == 'Printed') {
        break; // Stop the loop if "Printed" is encountered
      }

      // Check if the item name already exists in itemList
      int index = itemList.indexWhere((element) => element['name'] == item['name']);

      if (index != -1) {
        // If the item already exists, update its quantity
        itemList[index]['qty'] += item['quantity'];
      } else {
        // If the item doesn't exist, add it to itemList
        itemList.add({
          'name': item['name'],
          'qty': item['quantity'],
        });
        print("added");
      }
    }
    itemList.removeWhere((item) => item['qty'] <= 0);
    print("ITEM LIST IS $itemList");
      return itemList;

  }
  List<String> splitName(String name, bool isName, {int maxCharsPerLine = 24}) {
    List<String> words = name.split(' ');
    List<String> lines = [];
    String currentLine = isName ? "Name: " : "";
    for (String word in words) {
      if (currentLine.length + word.length + 1 <= maxCharsPerLine) {
        currentLine += word + " ";
      } else {
        lines.add(currentLine.trim());
        currentLine = word + " ";
      }
    }
    if (currentLine.isNotEmpty) {
      lines.add(currentLine.trim());
    }
    return lines;
  }
  Future<List<int>> kotTicket() async {
    final bargs = widget.args.bluetoothArgs!;

    // List<Map<String, dynamic>> list =
    //     await DatabaseHelper().getKotData(bargs.order.id!);
    List<Map<String, dynamic>> list = await getKotData(bargs.order.kotId!);

    List<int> bytes = [];
    // Using default profile
    final profile = await CapabilityProfile.load();
    final generator = Generator(
        bargs.type == kotType.is57mm ? PaperSize.mm58 : PaperSize.mm80,
        profile);
    //bytes += generator.setGlobalFont(PosFontType.fontA);
    bytes += generator.reset();

    // Using `ESC *`

    String dateFormat() =>
        DateFormat('MMM d, y hh:mm:ss a').format(bargs.dateTime);

    // print an image

//     final ByteData data = await rootBundle.load('assets/logo.png');
//     final Uint8List bytes = data.buffer.asUint8List();
//     final Image image = decodeImage(bytes);
// // Using `ESC *`
//     generator.image(image);
// // Using `GS v 0` (obsolete)
//     generator.imageRaster(image);
// // Using `GS ( L`
//     generator.imageRaster(image, imageFn: PosImageFn.graphics);

    bytes += generator.text('KOT',
        styles: PosStyles(fontType: PosFontType.fontA, align: PosAlign.center));
    bytes += generator.text(dateFormat(),
        styles: PosStyles(fontType: PosFontType.fontA, align: PosAlign.center));
    bytes += generator.text(
      'Table no : ${tableNoController.text}',
      styles: PosStyles(fontType: PosFontType.fontA, align: PosAlign.center),

    );
    var order = widget.args.bluetoothArgs?.order;
    String? name = ((order?.subUserName != null && order?.subUserName != "" && order?.subUserName != "null") ? order?.subUserName : (order?.userName != null && order?.userName != "" && order?.userName != "null" ? order?.userName : order?.businessName));
    List<String> nameLines = splitName(name!,true, maxCharsPerLine: (bargs.type == kotType.is57mm) ? 24 : 32);
    // bytes += generator.text(
    //
    //     'Name : ${((order?.subUserName != null && order?.subUserName != "" && order?.subUserName != "null") ? order?.subUserName : (order?.userName != null && order?.userName != "" && order?.userName != "null" ? order?.userName : order?.businessName))}',
    //     styles: PosStyles(fontType: PosFontType.fontA, align: PosAlign.center),
    //   linesAfter: 2,
    //   maxCharsPerLine: (bargs.type == kotType.is57mm) ? 24 : 32,
    //
    // );
    for(int i = 0; i < nameLines.length -1; i++) {
      bytes += generator.text(nameLines[i], styles: PosStyles(fontType: PosFontType.fontA, align: PosAlign.center),);
    }
    bytes += generator.text(nameLines[nameLines.length - 1],
        styles: PosStyles(fontType: PosFontType.fontA, align: PosAlign.center),
        linesAfter: 2,
    );
    // bytes +=
    //     generator.text('Align left', styles: PosStyles(align: PosAlign.left));
    // bytes += generator.text('Align center',
    //     styles: PosStyles(align: PosAlign.center));
    // bytes += generator.text('Align right',
    //     styles: PosStyles(align: PosAlign.right), linesAfter: 1);

    bytes += generator.row([
      PosColumn(
        text: 'item',
        width: 9,
        styles: PosStyles(bold: true, height: PosTextSize.size1),
      ),
      PosColumn(
        text: 'Qty',
        width: 3,
        styles: PosStyles(bold: true, height: PosTextSize.size1),
      ),
      // PosColumn(
      //   text: 'col3',
      //   width: 3,
      //   styles: PosStyles(align: PosAlign.center, underline: true),
      // ),
    ]);

    // for (int i = 0; i < list.length; i++) {
    //   bytes += generator.row([
    //     PosColumn(
    //       text: '${list[i]['name']}',
    //       width: 9,
    //       styles: PosStyles(height: PosTextSize.size1),
    //     ),
    //     PosColumn(
    //       text: '${list[i]['qty']}',
    //       width: 3,
    //       styles: PosStyles(height: PosTextSize.size1),
    //     ),
    //   ]);
    // }
    for (int i = 0; i < list.length; i++) {
      List<String> orderItemName = splitName(list[i]['name'].toString(), false,
          maxCharsPerLine: (widget.args.bluetoothArgs?.type == kotType.is57mm)
              ? 17
              : 22);
      for (int j = 0; j < orderItemName.length; j++) {
        if (j == 0) {
          bytes += generator.row([
            PosColumn(
              text: '${orderItemName[j]}',
              width: 9,
              styles: PosStyles(height: PosTextSize.size1),
            ),
            PosColumn(
              text: '${list[i]['qty']}',
              width: 3,
              styles: PosStyles(height: PosTextSize.size1),
            ),
          ]);
        }
        else {
          bytes += generator.row([
            PosColumn(
              text: '${orderItemName[j]}',
              width: 9,
              styles: PosStyles(height: PosTextSize.size1),
            ),
            PosColumn(
              text: ' ',
              width: 3,
              styles: PosStyles(height: PosTextSize.size1),
            ),
          ]);
        }
      }
    }

    //   else {
    //     for(int j = 0; j < orderItemName.length; j++) {
    //       if(j == 0) {
    //         bytes += generator.row([
    //           PosColumn(
    //             text: '${orderItemName[j]}',
    //             width: 9,
    //             styles: PosStyles(height: PosTextSize.size1),
    //           ),
    //           PosColumn(
    //             text: '${list[i]['qty']}',
    //             width: 3,
    //             styles: PosStyles(height: PosTextSize.size1),
    //           ),
    //         ]);
    //       }
    //       else {
    //         bytes += generator.row([
    //           PosColumn(
    //             text: '${orderItemName[j]}',
    //             width: 9,
    //             styles: PosStyles(height: PosTextSize.size1),
    //           ),
    //           PosColumn(
    //             text: ' ',
    //             width: 3,
    //             styles: PosStyles(height: PosTextSize.size1),
    //           ),
    //         ]);
    //       }
    //     }
    //   }
    // }

    //barcode
    // final List<int> barData = [1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 4];
    // bytes += generator.barcode(Barcode.upcA(barData));

    //QR code
    // bytes += generator.qrcode('example.com');

    // bytes += generator.text(
    //   'Text size 50%',
    //   styles: PosStyles(
    //     fontType: PosFontType.fontB,
    //   ),
    // );
    // bytes += generator.text(
    //   'Text size 100%',
    //   styles: PosStyles(
    //     fontType: PosFontType.fontA,
    //   ),
    // );
    // bytes += generator.text(
    //   'Text size 200%',
    //   styles: PosStyles(
    //     height: PosTextSize.size2,
    //     width: PosTextSize.size2,
    //   ),
    // );

    bytes += generator.feed(2);
    bytes += generator.cut();
    return bytes;
  }

  Future<void> printbill(String mac) async {
    print(widget.args.billArgs!.subtotalPrice);
    print(widget.args.billArgs!.gsttotalPrice);
    print(widget
        .args.billArgs!.order.orderItems![0].product!.baseSellingPriceGst);
    final bool result =
        await PrintBluetoothThermal.connect(macPrinterAddress: mac);
    bool conecctionStatus = await PrintBluetoothThermal.connectionStatus;
    if (conecctionStatus) {
      List<int> ticket = await billTicket();
      final result = await PrintBluetoothThermal.writeBytes(ticket);
      print("print result: $result");
    } else {
      //no connected
    }
  }

  Future<List<int>> billTicket() async {
    final args = widget.args.billArgs!;
    bool atLeastOneItemHasGst = false;
    for(int i = 0;i< args.order.orderItems!.length;i++){
      if(args.order.orderItems?[i].product?.gstRate != 'null'){
        atLeastOneItemHasGst = true;
        break;
      }
    }
    List<int> bytes = [];
    // Using default profile
    final profile = await CapabilityProfile.load();
    final generator = Generator(
        args.type == billType.is57mm ? PaperSize.mm58 : PaperSize.mm80,
        profile);
    //bytes += generator.setGlobalFont(PosFontType.fontA);
    bytes += generator.reset();

    // Using `ESC *`

    String dateFormat() => DateFormat('dd/MM/yy').format(args.dateTime);
    List<String>? addressRows() => args.user.address
        ?.toString()
        .split(',')
        .map((e) =>
    '${e.replaceAll('{', '').replaceAll('}', '').replaceAll('[', '').replaceAll(']', '').replaceAll(',', '').replaceAll('locality:', '').replaceAll('city:', '').replaceAll('state:', '').replaceAll('country:', '')}')
        .toList();
    String address = "";
    for(int i = 0; i < addressRows()!.length; i++) {
      address += addressRows()!.elementAt(i).toString() +",";
      // print("${addressRows()!.elementAt(i)}");
    }
    List<String> addressRows1 = splitName(address, false, maxCharsPerLine: (widget.args.bluetoothArgs?.type == kotType.is57mm) ? 24 : 32);


    bytes += generator.text('${args.user.businessName}',
        styles: PosStyles(height: PosTextSize.size3, align: PosAlign.center));

    for (int i = 0; i < addressRows1.length; i++) {
      bytes += generator.text('${addressRows1[i]}',
        styles: PosStyles(height: PosTextSize.size1, align: PosAlign.center),
      );
      if(atLeastOneItemHasGst)
        if (i == 0 && args.user.GstIN.toString() != "null" )
          bytes += generator.text('GSTIN ${args.user.GstIN}', styles: PosStyles(height: PosTextSize.size1, align: PosAlign.center));
    }

  


    bytes += generator.text('${args.user.phoneNumber}',
        styles: PosStyles(height: PosTextSize.size1, align: PosAlign.center));

    bytes += generator.row([
      PosColumn(
        text: 'Invoice ${args.invoiceNum}',
        width: 8,
        styles: PosStyles(height: PosTextSize.size1),
      ),
      PosColumn(
        text: '${dateFormat()}',
        width: 4,
        styles: PosStyles(height: PosTextSize.size1),
      ),
    ]);
    String time = DateTime.now().toString();
    bytes += generator.text(//time
      '${time.substring(11,16)}',
      styles: PosStyles(fontType: PosFontType.fontA, align: PosAlign.right),
      linesAfter: 2,
    );

    for (int i = 0; i < args.order.orderItems!.length; i++) {
      List<String> orderItemName = splitName(args.order.orderItems![i].product!.name.toString(), false, maxCharsPerLine: (widget.args.bluetoothArgs?.type == kotType.is57mm) ? 17 : 22);
      if(orderItemName.length == 1) {
        bytes += generator.row([
          PosColumn(
            text:
            '${args.order.orderItems![i].quantity}  ${args.order.orderItems![i]
                .product!.name}',
            width: 9,
            styles: PosStyles(
              height: PosTextSize.size1,
              underline: true,
            ),
          ),
          PosColumn(
            text:
            ' ${args.order.orderItems![i].product!.baseSellingPriceGst == 'null'
                ? args.order.orderItems![i].product!.sellingPrice
                : args.order.orderItems![i].product!.baseSellingPriceGst}  ',
            width: 3,
            styles: PosStyles(height: PosTextSize.size1, align: PosAlign.right),
          ),
        ]);
      }
      else {
        int len = args.order.orderItems![i].quantity.toString().length;
        for(int j = 0; j < orderItemName.length; j++) {
          if(j == 0) {
            bytes += generator.row([
              PosColumn(
                text:
                '${args.order.orderItems![i].quantity}  ${orderItemName[j]}',
                width: 9,
                styles: PosStyles(
                  height: PosTextSize.size1,
                  underline: true,
                ),
              ),
              PosColumn(
                text:
                ' ${args.order.orderItems![i].product!.baseSellingPriceGst == 'null'
                    ? args.order.orderItems![i].product!.sellingPrice
                    : args.order.orderItems![i].product!.baseSellingPriceGst}  ',
                width: 3,
                styles: PosStyles(height: PosTextSize.size1, align: PosAlign.right),
              ),
            ]);
          }
          else {
            orderItemName[j] = ' '*(len+1) + orderItemName[j];
            bytes += generator.row([
              PosColumn(
                text:
                '${orderItemName[j]}',
                width: 9,
                styles: PosStyles(
                  height: PosTextSize.size1,
                  underline: true,
                ),
              ),
              PosColumn(
                text:
                ' ',
                width: 3,
                styles: PosStyles(height: PosTextSize.size1, align: PosAlign.right),
              ),
            ]);

          }
        }
      }
    }

    bytes += generator.hr(linesAfter: 1);
    String? d = widget.args.billArgs?.totalDiscount;
    if(d != '' && d != null && d != "null") {
      bytes += generator.row([
        PosColumn(
          text: 'Amount',
          width: 6,
          styles: PosStyles(height: PosTextSize.size1),
        ),
        PosColumn(
          text: ' ${args.totalOriginalPrice}',
          width: 6,
          styles: PosStyles(height: PosTextSize.size1),
        ),
      ]);
      bytes += generator.row([
        PosColumn(
          text: 'Discount',
          width: 6,
          styles: PosStyles(height: PosTextSize.size1),
        ),
        PosColumn(
          text: ' ${args.totalDiscount}',
          width: 6,
          styles: PosStyles(height: PosTextSize.size1),
        ),
      ]);

    }
    bytes += generator.row([
      PosColumn(
        text: 'Subtotal',
        width: 6,
        styles: PosStyles(height: PosTextSize.size1),
      ),
      PosColumn(
        text: ' ${args.subtotalPrice}',
        width: 6,
        styles: PosStyles(height: PosTextSize.size1),
      ),
    ]);

    if(atLeastOneItemHasGst)
    bytes += generator.row([
      PosColumn(
        text: 'GST',
        width: 6,
        styles: PosStyles(height: PosTextSize.size1),
      ),
      PosColumn(
        text: ' ${args.gsttotalPrice}',
        width: 6,
        styles: PosStyles(height: PosTextSize.size1),
      ),
    ]);

    bytes += generator.hr(linesAfter: 1);

    bytes += generator.row([
      PosColumn(
        text: 'Grand Total',
        width: 6,
        styles: PosStyles(height: PosTextSize.size1),
      ),
      PosColumn(
        text: ' ${args.totalPrice}',
        width: 6,
        styles: PosStyles(height: PosTextSize.size1),
      ),
    ]);

    bytes += generator.hr(linesAfter: 1);

    bytes += generator.text('Thank you and see you again',
        styles: PosStyles(align: PosAlign.center, fontType: PosFontType.fontB));

    //barcode
    // final List<int> barData = [1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 4];
    // bytes += generator.barcode(Barcode.upcA(barData));

    //QR code
    // bytes += generator.qrcode('example.com');

    // bytes += generator.feed(2);
    bytes += generator.cut();
    return bytes;
  }

  bool isPrinted = false;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvoked: (_) async {

          if(widget.args.bluetoothArgs != null){
            final bargs = widget.args.bluetoothArgs!;
            if(isPrinted){
            //   await DatabaseHelper().updateKot(bargs.order.id! );
              Kot _kot = Kot(kotId: bargs.order.kotId!,items: []);
              List<Item> kotItems = [];
              Item item = Item(name: "Printed", quantity: 0, createdAt: DateTime.now());
              kotItems.add(item);
              _kot.items = kotItems;
              await KOTService.updateKot(_kot);
            }
            // await DatabaseHelper()
            //     .updateTableNo(tableNoController.text,bargs.order.id! );
            print("widget.args.bluetoothArgs!.order.tableNo is ${widget.args.bluetoothArgs!.order.tableNo} and runtype is ${widget.args.bluetoothArgs!.order.tableNo.runtimeType}");
            widget.args.bluetoothArgs!.order.tableNo =
                tableNoController.text;
            if(widget.args.bluetoothArgs!.order.tableNo != "null" && widget.args.bluetoothArgs!.order.tableNo != "")
                await BillingService().updateBillingOrder(widget.args.bluetoothArgs!.order);//for updating table No
            // final provider = Provider.of<Billing>(context,listen: false);
            // print("widget.args.bluetoothArgs!.order.id ${widget.args.bluetoothArgs!.order.id.toString()}");
            // provider.updateTableNoInSalesBill(widget.args.bluetoothArgs!.order.id.toString(),widget.args.bluetoothArgs!.order.tableNo);
            // print("popping bluetooth printer list and value is ${widget.args.bluetoothArgs!.order.tableNo}");
          }


      },
      child: Scaffold(
          appBar: AppBar(
            title: Text("Printer page"),
          ),
          backgroundColor: Colors.white,
          body: Column(
            children: [
              if (widget.args.billArgs == null)
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: CustomTextField2(
                            enabledBorderWidth: 0.3,
                            focusedBorderWidth: 1,
                    hintText: "Enter Table No (optional)",
                    controller: tableNoController,
                    value: "${widget.args.bluetoothArgs!.order.tableNo == 'null' ? "" : widget.args.bluetoothArgs!.order.tableNo}",
                    validator: (e) => null,
                  ),
                ),
              _devices.isNotEmpty
                  ? Expanded(
                      child: Container(
                        height: 400,
                        child: ListView.builder(
                          itemBuilder: (context, position) {
                            return ListTile(
                              onTap: () {
                                // printPdfViaBluetooth(_devices[position]);
                                // printkot(_devices[position].macAdress);
                                if (widget.args.bluetoothArgs != null &&
                                    widget.args.billArgs == null) {
                                  isPrinted = true;
                                  setState(() {});
                                  printKot(_devices[position].macAdress);
                                } else if (widget.args.billArgs != null &&
                                    widget.args.bluetoothArgs == null) {
                                  print('ok');
                                  printbill(_devices[position].macAdress);
                                }
                              },
                              leading: Icon(Icons.print),
                              title: Text(_devices[position].name),
                              subtitle: Text(_devices[position].macAdress),
                            );
                          },
                          itemCount: _devices.length,
                        ),
                      ),
                    )
                  : Center(
                      child: Text(
                        _deviceMsg ?? 'Ops something went wrong!',
                        style: TextStyle(fontSize: 24),
                      ),
                    ),
            ],
          )),
    );
  }

  init() async {
    List<Map<String, dynamic>> list = await getKotData(
        widget.args.bluetoothArgs!.order.kotId!);
    print(list);
    print("CAME HERE ||");
    var order = widget.args.bluetoothArgs?.order;
    for (int i = 0; i < list.length; i++) {
      print('${list[i]['name']}');
      print('${list[i]['qty']}');
    }
    for (int i = 0; i < list.length; i++) {
      List<String> orderItemName = splitName(list[i]['name'].toString(), false,
          maxCharsPerLine: (widget.args.bluetoothArgs?.type == kotType.is57mm)
              ? 17
              : 22);
      print("---------KOT ---------------");
      for(int j = 0; j < orderItemName.length; j++) {
        print('First is ${orderItemName[j]} ');
      }
    }




  }
}
